import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'ws_server_message.dart';
import 'ws_status.dart';

/// Returns the current access JWT (or null if the user is signed out).
/// Wire this to `AuthLocalDataSource.getAccessToken` in main.dart.
typedef AccessTokenProvider = Future<String?> Function();

/// Manages the single, long-lived WebSocket that streams processed firewall
/// logs to the backend for persistence.
///
/// Design (see `FIREWALL_LOGS_WS_PLAN.md`):
///   • Logs are [enqueue]d non-blocking from the ML pipeline.
///   • The buffer flushes every [_flushInterval] OR when it hits
///     [_maxBufferSize], whichever comes first, as one `log_batch` message.
///   • Batches are chunked to [_maxBatchSize] to respect the server cap.
///   • While disconnected, logs accumulate in an in-memory backlog (bounded
///     by [_maxBacklog]) and drain first on the next successful connect.
///   • Auto-reconnects with exponential backoff, re-reading a fresh token
///     each attempt (so a refreshed token is picked up automatically).
///   • Sends `ping` every [_pingInterval] to stay under the server idle timeout.
///
/// This service holds no Flutter/UI dependencies — observe [statusStream] and
/// [pushStream] from a cubit/bloc to reflect connection state and react to
/// server-pushed messages.
class FirewallLogWsService {
  /// Base **HTTP(S)** URL of the API (e.g. `https://host:8000/`). The scheme is
  /// converted to `ws`/`wss` internally.
  final String _baseHttpUrl;
  final AccessTokenProvider _tokenProvider;

  FirewallLogWsService({
    required String baseHttpUrl,
    required AccessTokenProvider tokenProvider,
  }) : _baseHttpUrl = baseHttpUrl,
       _tokenProvider = tokenProvider;

  // ── Tuning ────────────────────────────────────────────────────────────
  static const _flushInterval = Duration(seconds: 2);
  static const _pingInterval = Duration(seconds: 25); // server idles at ~30s
  static const _maxBufferSize = 50; // flush immediately when reached
  static const _maxBatchSize = 100; // hard cap matching the server
  static const _maxBacklog = 2000; // drop oldest beyond this while offline
  static const _maxReconnectDelay = Duration(seconds: 30);
  // Min gap between two `log_batch` frames. The backend closes the socket on
  // the 6th batch within 1s (RATE_LIMIT=5); 300ms caps us at ~3.3/s — safely
  // under the limit even while draining a large backlog after reconnect.
  static const _sendInterval = Duration(milliseconds: 300);

  // ── State ─────────────────────────────────────────────────────────────
  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _flushTimer;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  Timer? _pumpTimer;

  final _buffer = <Map<String, dynamic>>[]; // pending, connection up
  final _backlog = <Map<String, dynamic>>[]; // accumulated while offline
  final _outbox =
      <List<Map<String, dynamic>>>[]; // ready-to-send batches, paced
  int _reconnectSeconds = 1;
  bool _started = false;
  bool _connecting = false;

  final _statusCtrl = StreamController<WsStatus>.broadcast();
  final _pushCtrl = StreamController<WsServerMessage>.broadcast();

  /// Connection lifecycle updates.
  Stream<WsStatus> get statusStream => _statusCtrl.stream;

  /// Typed server-push messages (ack / blacklist_update / settings_update / error).
  Stream<WsServerMessage> get pushStream => _pushCtrl.stream;

  bool get isConnected => _channel != null;

  // ── Public API ────────────────────────────────────────────────────────

  /// Opens the connection and starts the flush/ping loops. Idempotent — safe
  /// to call again after [stop] (e.g. on a fresh sign-in).
  Future<void> start() async {
    if (_started) return;
    _started = true;
    await _connect();
  }

  /// Queue a single log for transmission. Non-blocking. The map is the
  /// backend wire shape (snake_case keys). `created_at` is stamped here if the
  /// caller didn't provide it.
  void enqueue(Map<String, dynamic> log) {
    if (!_started) return;
    log.putIfAbsent(
      'created_at',
      () => DateTime.now().toUtc().toIso8601String(),
    );
    _buffer.add(log);
    if (_buffer.length >= _maxBufferSize) _flush();
  }

  /// Force an immediate reconnect using the latest token — call this right
  /// after a successful token refresh or a fresh sign-in.
  Future<void> reconnect() async {
    _teardownSocket(emitDisconnected: false);
    _reconnectSeconds = 1;
    await _connect();
  }

  /// Closes the connection and stops all timers. Buffered/backlogged logs are
  /// preserved in memory for the next [start].
  Future<void> stop() async {
    _started = false;
    _reconnectTimer?.cancel();
    _teardownSocket(emitDisconnected: true);
  }

  /// Permanent shutdown — closes the streams. Use only when the app is
  /// disposing the service for good.
  void dispose() {
    stop();
    _statusCtrl.close();
    _pushCtrl.close();
  }

  // ── Connection ────────────────────────────────────────────────────────

  Future<void> _connect() async {
    if (!_started || _connecting || _channel != null) return;
    _connecting = true;
    _statusCtrl.add(WsStatus.connecting);

    final token = await _tokenProvider();
    if (token == null || token.isEmpty) {
      // Not signed in yet — back off and retry; start() may be called again
      // on auth, but this keeps us resilient either way.
      _connecting = false;
      _scheduleReconnect();
      return;
    }

    try {
      _channel = await _openChannel(token);
      _sub = _channel!.stream.listen(
        _onMessage,
        onError: (_) => _handleDrop(),
        onDone: _handleDrop,
        cancelOnError: true,
      );

      _statusCtrl.add(WsStatus.connected);
      _reconnectSeconds = 1;
      _connecting = false;

      _drainBacklog();
      _startFlushTimer();
      _startPingTimer();
    } catch (_) {
      _connecting = false;
      _statusCtrl.add(WsStatus.error);
      _teardownSocket(emitDisconnected: false);
      _scheduleReconnect();
    }
  }

  /// Builds the WebSocket. In debug we accept the self-signed dev cert (same
  /// bypass the Dio client uses); in release the OS trust store is enforced.
  Future<WebSocketChannel> _openChannel(String token) async {
    final uri = _wsUri(token);
    final headers = {'Authorization': 'Bearer $token'};

    if (kDebugMode) {
      final httpClient = HttpClient()
        ..badCertificateCallback = (cert, host, port) => true;
      final socket = await WebSocket.connect(
        uri.toString(),
        headers: headers,
        customClient: httpClient,
      );
      return IOWebSocketChannel(socket);
    }

    return IOWebSocketChannel.connect(uri, headers: headers);
  }

  /// `https://host/` → `wss://host/ws/logs?token=...` (and `http` → `ws`).
  ///
  /// The path is `/ws/logs` because the backend registers the socket via
  /// `@sock.route("/ws/logs")` on the global flask-sock instance — it is NOT
  /// under the `/firewall-logs` blueprint prefix. The token rides both as a
  /// query param and an `Authorization: Bearer` header; flask_jwt_extended's
  /// `verify_jwt_in_request()` reads the header we send on the handshake.
  Uri _wsUri(String token) {
    final base = Uri.parse(_baseHttpUrl);
    final scheme = base.scheme == 'https' ? 'wss' : 'ws';
    return base.replace(
      scheme: scheme,
      path: '/ws/logs',
      queryParameters: {'token': token},
    );
  }

  void _handleDrop() {
    if (!_started) return;
    _teardownSocket(emitDisconnected: true);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (!_started) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: _reconnectSeconds), _connect);
    final next = _reconnectSeconds * 2;
    _reconnectSeconds = next > _maxReconnectDelay.inSeconds
        ? _maxReconnectDelay.inSeconds
        : next;
  }

  void _teardownSocket({required bool emitDisconnected}) {
    _flushTimer?.cancel();
    _pingTimer?.cancel();
    _pumpTimer?.cancel();
    _pumpTimer = null;
    _sub?.cancel();
    _sub = null;
    // Anything still buffered or queued-to-send goes back to the backlog so it
    // survives the outage and drains on the next connect.
    if (_buffer.isNotEmpty) {
      _pushToBacklog(_buffer);
      _buffer.clear();
    }
    _spillOutboxToBacklog();
    _channel?.sink.close();
    _channel = null;
    if (emitDisconnected) _statusCtrl.add(WsStatus.disconnected);
  }

  // ── Sending ───────────────────────────────────────────────────────────
  //
  // All outbound logs funnel into [_outbox] as ≤[_maxBatchSize] batches, and a
  // single paced pump ([_pump], every [_sendInterval]) emits one `log_batch`
  // per tick. That keeps us under the backend's 5-batches/sec limit whether
  // we're trickling live logs or draining a big backlog after a reconnect.

  /// Periodic flush of the live buffer — moves it into the paced outbox.
  void _flush() {
    if (_buffer.isEmpty) return;
    if (_channel == null) {
      _pushToBacklog(_buffer);
      _buffer.clear();
      return;
    }
    _enqueueBatches(_buffer);
    _buffer.clear();
    _kickPump();
  }

  /// On (re)connect, move everything accumulated while offline into the outbox
  /// ahead of new live logs, then start pumping.
  void _drainBacklog() {
    if (_backlog.isEmpty) return;
    final batches = _chunk(_backlog);
    _backlog.clear();
    _outbox.insertAll(0, batches); // backlog first, preserving order
    _kickPump();
  }

  /// Splits [logs] into [_maxBatchSize] batches and appends them to the outbox.
  void _enqueueBatches(List<Map<String, dynamic>> logs) {
    _outbox.addAll(_chunk(logs));
  }

  List<List<Map<String, dynamic>>> _chunk(List<Map<String, dynamic>> logs) {
    final batches = <List<Map<String, dynamic>>>[];
    for (var i = 0; i < logs.length; i += _maxBatchSize) {
      final end = (i + _maxBatchSize < logs.length)
          ? i + _maxBatchSize
          : logs.length;
      batches.add(logs.sublist(i, end));
    }
    return batches;
  }

  /// Starts the paced pump if there's something to send and it isn't running.
  void _kickPump() {
    if (_pumpTimer != null || _outbox.isEmpty || _channel == null) return;
    _pump(); // send one now, then schedule the rest
  }

  /// Emits exactly one `log_batch`, then reschedules itself while the outbox
  /// has more (respecting [_sendInterval]). Stops cleanly when drained.
  void _pump() {
    _pumpTimer = null;
    final channel = _channel;
    if (channel == null) {
      _spillOutboxToBacklog();
      return;
    }
    if (_outbox.isEmpty) return;

    final batch = _outbox.removeAt(0);
    try {
      channel.sink.add(jsonEncode({'type': 'log_batch', 'logs': batch}));
    } catch (_) {
      // Send failed: requeue this batch and treat as a dropped connection.
      _outbox.insert(0, batch);
      _spillOutboxToBacklog();
      _handleDrop();
      return;
    }

    if (_outbox.isNotEmpty) {
      _pumpTimer = Timer(_sendInterval, _pump);
    }
  }

  void _spillOutboxToBacklog() {
    if (_outbox.isEmpty) return;
    for (final batch in _outbox) {
      _pushToBacklog(batch);
    }
    _outbox.clear();
  }

  void _pushToBacklog(List<Map<String, dynamic>> logs) {
    _backlog.addAll(logs);
    if (_backlog.length > _maxBacklog) {
      _backlog.removeRange(0, _backlog.length - _maxBacklog); // drop oldest
    }
  }

  // ── Receiving ─────────────────────────────────────────────────────────

  void _onMessage(dynamic raw) {
    if (raw is! String) return;
    Map<String, dynamic> json;
    try {
      json = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    final msg = WsServerMessage.fromJson(json);
    if (msg == null) return;

    // token_expired: drop and let the reconnect loop re-read a fresh token.
    if (msg is WsError && msg.code == 'token_expired') {
      _pushCtrl.add(msg);
      _handleDrop();
      return;
    }
    _pushCtrl.add(msg);
  }

  // ── Timers ────────────────────────────────────────────────────────────

  void _startFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(_flushInterval, (_) => _flush());
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (_) {
      try {
        _channel?.sink.add(jsonEncode({'type': 'ping'}));
      } catch (_) {}
    });
  }
}
