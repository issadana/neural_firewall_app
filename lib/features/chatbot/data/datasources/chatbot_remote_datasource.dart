import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';

/// Tag every Nova log line so it's easy to filter the console (`grep NovaChat`).
final _log = Logger(printer: PrettyPrinter(methodCount: 0));

const _logTag = 'NovaChat';

class ChatStreamException implements Exception {
  final String message;
  ChatStreamException(this.message);
  @override
  String toString() => message;
}

/// Talks to the backend's stateless Nova assistant endpoint:
///
///   `GET /api/mobile_chat?prompt=<text>`  (JWT-protected)
///
/// The reply streams back over Server-Sent Events as a sequence of
/// `init` → `message`* → `end` events. Each `message` event carries a token of
/// the answer; `end` closes the stream. The endpoint is stateless — every
/// request is answered on its own, with no conversation memory or history.
@lazySingleton
class ChatbotRemoteDataSource {
  final Dio _dio;
  final AuthLocalDataSource _authLocal;

  ChatbotRemoteDataSource(@Named('chatDio') this._dio, this._authLocal);

  /// Streams the assistant's reply to [message] token-by-token.
  ///
  /// The JWT rides in the `Authorization` header (which `@jwt_required()`
  /// reads), so an active session is required.
  Stream<String> streamMessage(String message) async* {
    final url = '${_dio.options.baseUrl}api/mobile_chat';
    _log.i('[$_logTag] → GET $url  prompt="$message"');

    final token = await _authLocal.getAccessToken();
    if (token == null) {
      _log.w('[$_logTag] no access token — user is not signed in');
      throw ChatStreamException('You need to be signed in to chat with Nova.');
    }
    _log.d('[$_logTag] auth token present (len=${token.length})');

    final Response<ResponseBody> response;
    try {
      response = await _dio.get<ResponseBody>(
        '/api/mobile_chat',
        queryParameters: {'prompt': message},
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'text/event-stream',
          },
        ),
      );
      _log.i(
        '[$_logTag] ← HTTP ${response.statusCode} '
        '(${response.headers.value('content-type')})',
      );
    } on DioException catch (e) {
      // With responseType.stream the error body is an unread ResponseBody —
      // drain it so the real backend message is visible, not "Instance of…".
      final body = await _readErrorBody(e);
      _log.e(
        '[$_logTag] request failed: ${e.type} '
        'status=${e.response?.statusCode} body=$body',
      );
      throw ChatStreamException(_describeError(e, body));
    }

    // Decode through utf8.decoder so multi-byte characters split across network
    // chunks are stitched back together correctly.
    final textStream = response.data!.stream.cast<List<int>>().transform(
      utf8.decoder,
    );

    // SSE framing: events are separated by a blank line; within an event,
    // `event:` names it and one or more `data:` lines carry the payload.
    var buffer = '';
    String? eventName;
    final dataLines = <String>[];

    var eventCount = 0;
    var tokenCount = 0;
    final sb = StringBuffer();

    void reset() {
      eventName = null;
      dataLines.clear();
    }

    try {
      await for (final text in textStream) {
        buffer += text;

        int newlineIndex;
        while ((newlineIndex = buffer.indexOf('\n')) != -1) {
          var line = buffer.substring(0, newlineIndex);
          buffer = buffer.substring(newlineIndex + 1);
          if (line.endsWith('\r')) line = line.substring(0, line.length - 1);

          // Blank line → dispatch the accumulated event.
          if (line.isEmpty) {
            if (dataLines.isEmpty) {
              reset();
              continue;
            }
            final data = dataLines.join('\n');
            eventCount++;
            _log.d(
              '[$_logTag] event #$eventCount '
              'type=${eventName ?? "(none)"} data=$data',
            );
            switch (eventName) {
              case 'end':
                _log.i(
                  '[$_logTag] ✓ done — $tokenCount tokens, '
                  '${sb.length} chars: "$sb"',
                );
                return;
              case 'error':
                final msg = _extractContent(data).ifEmpty('Stream error');
                _log.e('[$_logTag] server error event: $msg');
                throw ChatStreamException(msg);
              case 'init':
                break; // handshake — nothing to render
              default: // 'message' or unnamed
                final content = _extractContent(data);
                if (content.isNotEmpty) {
                  tokenCount++;
                  sb.write(content);
                  yield content;
                } else {
                  _log.w('[$_logTag] empty token — no known field in: $data');
                }
            }
            reset();
            continue;
          }

          if (line.startsWith(':')) continue; // SSE comment / keep-alive
          if (line.startsWith('event:')) {
            eventName = line.substring(6).trim();
          } else if (line.startsWith('data:')) {
            dataLines.add(line.substring(5).trimLeft());
          }
        }
      }
      // Stream closed without an explicit `end` event.
      _log.w(
        '[$_logTag] stream closed after $eventCount events '
        '(no "end") — $tokenCount tokens, ${sb.length} chars',
      );
    } catch (e) {
      if (e is! ChatStreamException) {
        _log.e('[$_logTag] stream read error: $e');
      }
      rethrow;
    }
  }

  /// Pulls the token text out of a `data:` payload. The backend may send a
  /// JSON object (`{"content": "..."}`), a bare JSON string, or raw text —
  /// this tolerates all three plus a few common field names.
  String _extractContent(String data) {
    final trimmed = data.trim();
    if (trimmed.isEmpty) return '';
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is String) return decoded;
      if (decoded is Map<String, dynamic>) {
        for (final key in const [
          'content',
          'text',
          'data',
          'token',
          'message',
          'delta',
          'chunk',
          'answer',
        ]) {
          final value = decoded[key];
          if (value is String) return value;
        }
        return '';
      }
      return trimmed;
    } catch (_) {
      // Not JSON — treat the payload as a raw text token.
      return trimmed;
    }
  }

  /// Reads the body of a failed streamed request. Under `responseType.stream`
  /// Dio leaves the error body as an undrained [ResponseBody], so we consume
  /// it here to recover the backend's actual error text.
  Future<String> _readErrorBody(DioException e) async {
    final data = e.response?.data;
    if (data is ResponseBody) {
      try {
        final bytes = <int>[];
        await for (final chunk in data.stream) {
          bytes.addAll(chunk);
        }
        return utf8.decode(bytes, allowMalformed: true).trim();
      } catch (_) {
        return '<unreadable stream body>';
      }
    }
    return data?.toString() ?? '';
  }

  String _describeError(DioException e, [String body = '']) {
    final status = e.response?.statusCode;
    if (status == 401) return 'Your session has expired. Please sign in again.';
    if (status == 400) return 'Please enter a message before sending.';
    if (status == 500) {
      // Surface the backend's own message when it sent one (the mobile_chat
      // route returns {"status":"error","message":"..."} on failure).
      final serverMsg = _serverMessage(body);
      return serverMsg == null
          ? 'Nova hit a server error. Please try again.'
          : 'Nova server error: $serverMsg';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Could not reach Nova. Check your connection and try again.';
    }
    return 'Nova is unavailable right now. Please try again.';
  }

  /// Extracts `message` from a JSON error body, if present.
  String? _serverMessage(String body) {
    if (body.isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final msg = decoded['message'] ?? decoded['error'];
        if (msg is String && msg.isNotEmpty) return msg;
      }
    } catch (_) {
      /* not JSON — fall through */
    }
    return null;
  }
}

extension _EmptyFallback on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
