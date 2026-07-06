import 'dart:async';

import 'package:injectable/injectable.dart';

import 'package:Sentri/core/session/session_event_bus.dart';
import 'package:Sentri/core/websocket/firewall_log_ws_service.dart';
import 'package:Sentri/core/websocket/ws_server_message.dart';
import 'package:Sentri/features/blacklist/domain/repositories/blacklist_repository.dart';
import 'package:Sentri/features/hardware_metrics/presentation/bloc/hardware_metrics_cubit.dart';
import 'package:Sentri/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:Sentri/features/traffic/domain/repositories/traffic_repository.dart';
import 'package:Sentri/features/traffic/presentation/bloc/traffic_bloc.dart';
import 'package:Sentri/features/vpn/presentation/bloc/vpn_cubit.dart';

/// Runtime orchestration that the DI container can't express: cross-cubit stream
/// wiring, seeding the traffic pipeline from settings, resuming a sticky VPN
/// session, and reacting to server pushes / session expiry.
///
/// Injectable owns *construction*; this owns the one-time *wiring* between the
/// already-constructed singletons. Call [start] once, after the container is
/// ready and before `runApp`.
@lazySingleton
class AppBootstrap {
  AppBootstrap(
    this._settings,
    this._trafficRepo,
    this._logWs,
    this._blacklistRepo,
    this._vpn,
    this._traffic,
    this._hardware,
    this._sessionBus,
  );

  final SettingsCubit _settings;
  final TrafficRepository _trafficRepo;
  final FirewallLogWsService _logWs;
  final BlacklistRepository _blacklistRepo;
  final VpnCubit _vpn;
  final TrafficBloc _traffic;
  final HardwareMetricsCubit _hardware;
  final SessionEventBus _sessionBus;

  Timer? _backendIpRefresh;

  Set<String> _enabledModelIds(SettingsState s) =>
      s.models.entries.where((e) => e.value).map((e) => e.key).toSet();

  void _applyFloodSettings(SettingsState s) => _trafficRepo.updateFloodSettings(
        floodDetection: s.floodDetection,
        floodPktPerSec: s.floodPktPerSec,
        synFloodDetection: s.synFloodDetection,
        synFloodPerSec: s.synFloodPerSec,
      );

  void start() {
    // Resolve our own backend to its live IP(s) and keep it trusted so the
    // firewall never blocks the app's control channel. Refresh periodically
    // because the host's IPs can rotate (load balancer / CDN / DNS TTL).
    _trafficRepo.refreshTrustedBackendIps();
    _backendIpRefresh = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _trafficRepo.refreshTrustedBackendIps(),
    );

    // Seed the live pipeline from the settings cubit's already-loaded state,
    // then keep the traffic repo in sync with the user's choices.
    _trafficRepo.setScanSystemTraffic(_settings.state.scanSystemTraffic);
    _trafficRepo.setEnabledModels(_enabledModelIds(_settings.state));
    _trafficRepo.updateThresholds(
      _settings.state.blockThreshold,
      _settings.state.warnThreshold,
    );
    _applyFloodSettings(_settings.state);
    _settings.stream.listen((s) {
      _trafficRepo.setScanSystemTraffic(s.scanSystemTraffic);
      _trafficRepo.setEnabledModels(_enabledModelIds(s));
      _trafficRepo.updateThresholds(s.blockThreshold, s.warnThreshold);
      _applyFloodSettings(s);
    });

    // React to messages the backend pushes down the log WebSocket:
    //  • blacklist_update → the server auto-blocked an IP; refresh local cache.
    //  • settings_update  → admin changed thresholds; apply to the live pipeline.
    _logWs.pushStream.listen((msg) {
      switch (msg) {
        case WsBlacklistUpdate():
          _blacklistRepo.syncFromServer();
        case WsSettingsUpdate(
          blockThreshold: final block,
          warnThreshold: final warn,
        ):
          if (block != null && warn != null) {
            _trafficRepo.updateThresholds(block, warn);
          }
        default:
          break; // ack / pong / error — nothing to apply here
      }
    });

    // A dead refresh token (announced by the interceptor over the bus) tears
    // down the authed socket. The AuthCubit drops the UI to sign-in off the
    // same bus, independently.
    _sessionBus.onExpired.listen((_) => _logWs.stop());

    // The native VPN service is START_STICKY + foreground, so it can already be
    // running from a previous session (swipe-away, process kill, app restart).
    // Re-sync the UI to that live session and resume packet listening so
    // detection continues right where it left off.
    _vpn.restore().then((wasRunning) {
      if (wasRunning) _traffic.add(const StartListeningEvent());
    });

    // Begin periodic hardware-metric snapshots to the backend.
    _hardware.startPeriodicSync();
  }

  /// Cancels the periodic backend-IP refresh. AppBootstrap is an app-lifetime
  /// singleton, so this is here for completeness / test teardown.
  void dispose() {
    _backendIpRefresh?.cancel();
  }
}
