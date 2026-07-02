import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/api/dio_consumer.dart';
import 'core/constants/api_constants.dart';
import 'core/constants/app_constants.dart';
import 'core/websocket/firewall_log_ws_service.dart';
import 'core/websocket/ws_server_message.dart';
import 'core/interceptors/error_interceptor.dart';
import 'core/interceptors/logging_interceptor.dart';
import 'core/interceptors/refresh_token_interceptor.dart';
import 'core/widgets/navigation_bar/app.dart';
import 'features/hardware_metrics/data/datasources/hardware_local_datasource.dart';
import 'features/hardware_metrics/data/datasources/hardware_remote_datasource.dart';
import 'features/hardware_metrics/data/repositories/hardware_metrics_repository_impl.dart';
import 'features/hardware_metrics/domain/usecases/collect_snapshot_usecase.dart';
import 'features/hardware_metrics/domain/usecases/sync_snapshot_usecase.dart';
import 'features/hardware_metrics/presentation/bloc/hardware_metrics_cubit.dart';
import 'features/chatbot/data/datasources/chatbot_remote_datasource.dart';
import 'features/chatbot/data/repositories/chatbot_repository_impl.dart';
import 'features/chatbot/domain/usecases/delete_session_usecase.dart';
import 'features/chatbot/domain/usecases/get_digest_usecase.dart';
import 'features/chatbot/domain/usecases/get_session_messages_usecase.dart';
import 'features/chatbot/domain/usecases/send_message_usecase.dart';
import 'features/chatbot/presentation/bloc/chat_cubit.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_out_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/domain/usecases/update_profile_usecase.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/blacklist/data/datasources/blacklist_local_datasource.dart';
import 'features/blacklist/data/datasources/blacklist_remote_datasource.dart';
import 'features/blacklist/data/repositories/blacklist_repository_impl.dart';
import 'features/blacklist/domain/usecases/add_to_blacklist_usecase.dart';
import 'features/blacklist/domain/usecases/clear_blacklist_usecase.dart';
import 'features/blacklist/domain/usecases/get_blacklist_usecase.dart';
import 'features/blacklist/domain/usecases/remove_from_blacklist_usecase.dart';
import 'features/blacklist/domain/usecases/watch_blacklist_usecase.dart';
import 'features/blacklist/presentation/bloc/blacklist_cubit.dart';
import 'features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'features/firewall_logs/data/datasources/firewall_log_remote_datasource.dart';
import 'features/firewall_logs/data/repositories/firewall_log_repository_impl.dart';
import 'features/firewall_logs/domain/usecases/get_firewall_logs_usecase.dart';
import 'features/firewall_logs/domain/usecases/post_firewall_log_usecase.dart';
import 'features/firewall_logs/presentation/bloc/firewall_logs_cubit.dart';
import 'features/settings/data/datasources/settings_remote_datasource.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/presentation/bloc/settings_cubit.dart';
import 'features/traffic/data/datasources/ml_datasource.dart';
import 'features/traffic/data/repositories/traffic_repository_impl.dart';
import 'features/traffic/domain/usecases/process_packet_usecase.dart';
import 'features/traffic/presentation/bloc/traffic_bloc.dart';
import 'features/vpn/data/datasources/vpn_native_datasource.dart';
import 'features/vpn/data/repositories/vpn_repository_impl.dart';
import 'features/vpn/domain/usecases/get_packet_stream_usecase.dart';
import 'features/vpn/domain/usecases/start_vpn_usecase.dart';
import 'features/vpn/domain/usecases/stop_vpn_usecase.dart';
import 'features/vpn/presentation/bloc/vpn_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // Encrypted session store, shared by the auth repository and the refresh
  // interceptor so they read/write the same tokens.
  final authLocal = AuthLocalDataSource(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  // Shared API client used across features (auth, hardware, firewall logs).
  final apiDio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
    ),
  );

  // Real-time write path: streams every processed firewall log to the backend
  // over a single WebSocket. Reads the current access token from secure
  // storage on each (re)connect, so a refreshed token is picked up
  // automatically. Started once the user is authenticated (see listener below).
  final firewallLogWs = FirewallLogWsService(
    baseHttpUrl: ApiConstants.baseUrl,
    tokenProvider: authLocal.getAccessToken,
  );

  // Bound below once its dependencies exist. The interceptor's onSessionExpired
  // callback only fires at request time (well after startup), by which point
  // this holds the live cubit.
  AuthCubit? authCubit;
  final apiConsumer = DioConsumer(
    apiDio,
    ErrorInterceptor(),
    LoggingInterceptor(),
    // Transparently refreshes expired access tokens and replays the request,
    // so every authenticated endpoint survives token expiry.
    refreshTokenInterceptor: RefreshTokenInterceptor(
      dio: apiDio,
      local: authLocal,
      // Refresh token is dead and the session is already wiped: tear down the
      // authed socket and drop the UI back to sign-in.
      onSessionExpired: () async {
        await firewallLogWs.stop();
        authCubit?.onSessionExpired();
      },
    ),
  );

  // ── Data sources ────────────────────────────────────────────────────────────
  final blacklistDs = BlacklistLocalDataSource();
  final mlDs = MlDataSource();
  await mlDs.init();
  final vpnDs = VpnNativeDataSource();

  // ── Repositories ────────────────────────────────────────────────────────────
  final blacklistRepo = BlacklistRepositoryImpl(
    blacklistDs,
    vpnDs,
    BlacklistRemoteDataSource(apiConsumer, authLocal),
  );
  final trafficRepo = TrafficRepositoryImpl(
    blacklistRepository: blacklistRepo,
    mlDataSource: mlDs,
    vpnDataSource: vpnDs,
    scanSystemTraffic: prefs.getBool('scanSystemTraffic') ?? false,
  );
  final vpnRepo = VpnRepositoryImpl(vpnDs);
  final authRepo = AuthRepositoryImpl(
    AuthRemoteDataSource(apiConsumer),
    authLocal,
  );

  // ── Use cases ───────────────────────────────────────────────────────────────
  final checkAuth = CheckAuthStatusUseCase(authRepo);
  final signIn = SignInUseCase(authRepo);
  final signUp = SignUpUseCase(authRepo);
  final signOut = SignOutUseCase(authRepo);
  final updateProfile = UpdateProfileUseCase(authRepo);

  // Built eagerly (not in the BlocProvider factory) so the refresh interceptor's
  // onSessionExpired callback can drive it back to unauthenticated mid-session.
  authCubit = AuthCubit(
    checkAuthStatusUseCase: checkAuth,
    signInUseCase: signIn,
    signUpUseCase: signUp,
    signOutUseCase: signOut,
    updateProfileUseCase: updateProfile,
  );

  final getBlacklist = GetBlacklistUseCase(blacklistRepo);
  final addBlacklist = AddToBlacklistUseCase(blacklistRepo);
  final removeBlacklist = RemoveFromBlacklistUseCase(blacklistRepo);
  final clearBlacklist = ClearBlacklistUseCase(blacklistRepo);
  final watchBlacklist = WatchBlacklistUseCase(blacklistRepo);

  final processPacket = ProcessPacketUseCase(trafficRepo);
  final getPacketStream = GetPacketStreamUseCase(vpnRepo);
  final startVpn = StartVpnUseCase(vpnRepo);
  final stopVpn = StopVpnUseCase(vpnRepo);

  // ── Cubits / Blocs ──────────────────────────────────────────────────────────
  final blacklistCubit = BlacklistCubit(
    getBlacklist: getBlacklist,
    addToBlacklist: addBlacklist,
    removeFromBlacklist: removeBlacklist,
    clearBlacklist: clearBlacklist,
    watchBlacklist: watchBlacklist,
  );

  final trafficBloc = TrafficBloc(
    getPacketStream: getPacketStream,
    processPacket: processPacket,
    logWs: firewallLogWs,
  );

  final vpnCubit = VpnCubit(startVpn: startVpn, stopVpn: stopVpn);

  final dashboardCubit = DashboardCubit(
    trafficBloc: trafficBloc,
    blacklistCubit: blacklistCubit,
  );

  // ── Hardware metrics ─────────────────────────────────────────────────────────
  // Reuses the shared API client created above to POST snapshots to the backend.
  final hardwareRepo = HardwareMetricsRepositoryImpl(
    local: HardwareLocalDataSource(),
    remote: HardwareRemoteDataSource(apiConsumer, authLocal),
  );
  final hardwareMetricsCubit = HardwareMetricsCubit(
    collect: CollectSnapshotUseCase(hardwareRepo),
    sync: SyncSnapshotUseCase(hardwareRepo),
  )..startPeriodicSync();

  // ── Firewall logs ────────────────────────────────────────────────────────────
  // Reuses the shared API client; powers the Dashboard tab (overview + logs).
  final firewallLogRepo = FirewallLogRepositoryImpl(
    FirewallLogRemoteDataSource(apiConsumer, authLocal),
  );
  final firewallLogsCubit = FirewallLogsCubit(
    getLogs: GetFirewallLogsUseCase(firewallLogRepo),
    postLog: PostFirewallLogUseCase(firewallLogRepo),
  );

  // ── Nova chatbot ─────────────────────────────────────────────────────────────
  final chatDio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
    ),
  );
  final chatbotRepo = ChatbotRepositoryImpl(ChatbotRemoteDataSource(chatDio));
  final chatCubit = ChatCubit(
    sendMessage: SendMessageUseCase(chatbotRepo),
    getDigest: GetDigestUseCase(chatbotRepo),
    getSessionMessages: GetSessionMessagesUseCase(chatbotRepo),
    deleteSession: DeleteSessionUseCase(chatbotRepo),
  );

  // Settings drive the live pipeline: keep the traffic repo's system-traffic
  // scanning and enabled-model set in sync with the user's choices.
  final settingsRepo = SettingsRepositoryImpl(
    SettingsRemoteDataSource(apiConsumer),
    authLocal,
  );
  final settingsCubit = SettingsCubit(prefs, settingsRepo);
  Set<String> enabledModelIds(SettingsState s) =>
      s.models.entries.where((e) => e.value).map((e) => e.key).toSet();
  // Seed from the cubit's initial (already-loaded) state.
  trafficRepo.setScanSystemTraffic(settingsCubit.state.scanSystemTraffic);
  trafficRepo.setEnabledModels(enabledModelIds(settingsCubit.state));
  trafficRepo.updateThresholds(
    settingsCubit.state.blockThreshold,
    settingsCubit.state.warnThreshold,
  );
  settingsCubit.stream.listen((s) {
    trafficRepo.setScanSystemTraffic(s.scanSystemTraffic);
    trafficRepo.setEnabledModels(enabledModelIds(s));
    trafficRepo.updateThresholds(s.blockThreshold, s.warnThreshold);
  });

  // React to messages the backend pushes down the log WebSocket:
  //  • blacklist_update → the server auto-blocked an IP; refresh local cache.
  //  • settings_update  → admin changed thresholds; apply to the live pipeline.
  firewallLogWs.pushStream.listen((msg) {
    switch (msg) {
      case WsBlacklistUpdate():
        blacklistRepo.syncFromServer();
      case WsSettingsUpdate(
        blockThreshold: final block,
        warnThreshold: final warn,
      ):
        if (block != null && warn != null) {
          trafficRepo.updateThresholds(block, warn);
        }
      default:
        break; // ack / pong / error — nothing to apply here
    }
  });

  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: authCubit!),
            BlocProvider.value(value: vpnCubit),
            BlocProvider.value(value: trafficBloc),
            BlocProvider.value(value: dashboardCubit),
            BlocProvider.value(value: hardwareMetricsCubit),
            BlocProvider.value(value: firewallLogsCubit),
            BlocProvider.value(value: blacklistCubit),
            BlocProvider.value(value: settingsCubit),
            BlocProvider.value(value: chatCubit),
          ],
          // Re-pull server settings each time the user becomes authenticated
          // (e.g. a fresh sign-in), so they aren't stuck with local defaults.
          child: BlocListener<AuthCubit, AuthState>(
            listenWhen: (prev, curr) =>
                prev.status != curr.status &&
                curr.status == AuthStatus.authenticated,
            listener: (context, state) {
              settingsCubit.syncFromServer();
              blacklistRepo.syncFromServer();
              // Open the log WebSocket now that a valid token exists.
              firewallLogWs.start();
            },
            child: const SentriApp(),
          ),
        );
      },
    ),
  );
}
