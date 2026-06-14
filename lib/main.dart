import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/api/dio_consumer.dart';
import 'core/constants/api_constants.dart';
import 'core/constants/app_constants.dart';
import 'core/interceptors/error_interceptor.dart';
import 'core/interceptors/logging_interceptor.dart';
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
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_out_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/domain/usecases/update_profile_usecase.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/blacklist/data/datasources/blacklist_local_datasource.dart';
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

  // ── Data sources ────────────────────────────────────────────────────────────
  final blacklistDs  = BlacklistLocalDataSource();
  final mlDs         = MlDataSource();
  await mlDs.init();
  final vpnDs = VpnNativeDataSource();

  // ── Repositories ────────────────────────────────────────────────────────────
  final blacklistRepo = BlacklistRepositoryImpl(blacklistDs);
  final trafficRepo   = TrafficRepositoryImpl(
    blacklistRepository: blacklistRepo,
    mlDataSource: mlDs,
    vpnDataSource: vpnDs,
    scanSystemTraffic: prefs.getBool('scanSystemTraffic') ?? false,
  );
  final vpnRepo = VpnRepositoryImpl(vpnDs);
  final authDs  = AuthLocalDataSource(prefs);
  final authRepo = AuthRepositoryImpl(authDs);

  // ── Use cases ───────────────────────────────────────────────────────────────
  final checkAuth      = CheckAuthStatusUseCase(authRepo);
  final signIn         = SignInUseCase(authRepo);
  final signUp         = SignUpUseCase(authRepo);
  final signOut        = SignOutUseCase(authRepo);
  final updateProfile  = UpdateProfileUseCase(authRepo);

  final getBlacklist    = GetBlacklistUseCase(blacklistRepo);
  final addBlacklist    = AddToBlacklistUseCase(blacklistRepo);
  final removeBlacklist = RemoveFromBlacklistUseCase(blacklistRepo);
  final clearBlacklist  = ClearBlacklistUseCase(blacklistRepo);
  final watchBlacklist  = WatchBlacklistUseCase(blacklistRepo);

  final processPacket   = ProcessPacketUseCase(trafficRepo);
  final getPacketStream = GetPacketStreamUseCase(vpnRepo);
  final startVpn        = StartVpnUseCase(vpnRepo);
  final stopVpn         = StopVpnUseCase(vpnRepo);

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
  );

  final vpnCubit = VpnCubit(startVpn: startVpn, stopVpn: stopVpn);

  final dashboardCubit = DashboardCubit(
    trafficBloc: trafficBloc,
    blacklistCubit: blacklistCubit,
  );

  // ── Hardware metrics ─────────────────────────────────────────────────────────
  // Shared API client used to POST snapshots to the backend.
  final apiDio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
    ),
  );
  final apiConsumer = DioConsumer(apiDio, ErrorInterceptor(), LoggingInterceptor());

  final hardwareRepo = HardwareMetricsRepositoryImpl(
    local: HardwareLocalDataSource(),
    remote: HardwareRemoteDataSource(apiConsumer),
  );
  final hardwareMetricsCubit = HardwareMetricsCubit(
    collect: CollectSnapshotUseCase(hardwareRepo),
    sync: SyncSnapshotUseCase(hardwareRepo),
  )..startPeriodicSync();

  // ── Firewall logs ────────────────────────────────────────────────────────────
  // Reuses the shared API client; powers the Dashboard tab (overview + logs).
  final firewallLogRepo = FirewallLogRepositoryImpl(
    FirewallLogRemoteDataSource(apiConsumer),
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
  // scanning in sync with the user's choice (initial value read above).
  final settingsCubit = SettingsCubit(prefs);
  settingsCubit.stream.listen(
    (s) => trafficRepo.setScanSystemTraffic(s.scanSystemTraffic),
  );

  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => AuthCubit(
                checkAuthStatusUseCase: checkAuth,
                signInUseCase: signIn,
                signUpUseCase: signUp,
                signOutUseCase: signOut,
                updateProfileUseCase: updateProfile,
              ),
            ),
            BlocProvider.value(value: vpnCubit),
            BlocProvider.value(value: trafficBloc),
            BlocProvider.value(value: dashboardCubit),
            BlocProvider.value(value: hardwareMetricsCubit),
            BlocProvider.value(value: firewallLogsCubit),
            BlocProvider.value(value: blacklistCubit),
            BlocProvider.value(value: settingsCubit),
            BlocProvider.value(value: chatCubit),
          ],
          child: const SentriApp(),
        );
      },
    ),
  );
}
