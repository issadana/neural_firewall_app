// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/datasources/auth_local_datasource.dart'
    as _i992;
import '../../features/auth/data/datasources/auth_remote_datasource.dart'
    as _i161;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/check_auth_status_usecase.dart'
    as _i52;
import '../../features/auth/domain/usecases/sign_in_usecase.dart' as _i259;
import '../../features/auth/domain/usecases/sign_out_usecase.dart' as _i915;
import '../../features/auth/domain/usecases/sign_up_usecase.dart' as _i860;
import '../../features/auth/domain/usecases/update_profile_usecase.dart'
    as _i798;
import '../../features/auth/presentation/bloc/auth_cubit.dart' as _i52;
import '../../features/blacklist/data/datasources/blacklist_local_datasource.dart'
    as _i529;
import '../../features/blacklist/data/datasources/blacklist_remote_datasource.dart'
    as _i301;
import '../../features/blacklist/data/repositories/blacklist_repository_impl.dart'
    as _i421;
import '../../features/blacklist/domain/repositories/blacklist_repository.dart'
    as _i454;
import '../../features/blacklist/domain/usecases/add_to_blacklist_usecase.dart'
    as _i656;
import '../../features/blacklist/domain/usecases/clear_blacklist_usecase.dart'
    as _i589;
import '../../features/blacklist/domain/usecases/get_blacklist_usecase.dart'
    as _i142;
import '../../features/blacklist/domain/usecases/remove_from_blacklist_usecase.dart'
    as _i119;
import '../../features/blacklist/domain/usecases/watch_blacklist_usecase.dart'
    as _i48;
import '../../features/blacklist/presentation/bloc/blacklist_cubit.dart'
    as _i364;
import '../../features/chatbot/data/datasources/chatbot_remote_datasource.dart'
    as _i344;
import '../../features/chatbot/data/repositories/chatbot_repository_impl.dart'
    as _i741;
import '../../features/chatbot/domain/repositories/chatbot_repository.dart'
    as _i719;
import '../../features/chatbot/domain/usecases/send_message_usecase.dart'
    as _i346;
import '../../features/chatbot/presentation/bloc/chat_cubit.dart' as _i1035;
import '../../features/dashboard/presentation/bloc/dashboard_cubit.dart'
    as _i58;
import '../../features/firewall_logs/data/datasources/firewall_log_remote_datasource.dart'
    as _i788;
import '../../features/firewall_logs/data/repositories/firewall_log_repository_impl.dart'
    as _i26;
import '../../features/firewall_logs/domain/repositories/firewall_log_repository.dart'
    as _i137;
import '../../features/firewall_logs/domain/usecases/get_firewall_logs_usecase.dart'
    as _i160;
import '../../features/firewall_logs/domain/usecases/post_firewall_log_usecase.dart'
    as _i664;
import '../../features/firewall_logs/presentation/bloc/firewall_logs_cubit.dart'
    as _i342;
import '../../features/hardware_metrics/data/datasources/hardware_local_datasource.dart'
    as _i150;
import '../../features/hardware_metrics/data/datasources/hardware_remote_datasource.dart'
    as _i684;
import '../../features/hardware_metrics/data/repositories/hardware_metrics_repository_impl.dart'
    as _i463;
import '../../features/hardware_metrics/domain/repositories/hardware_metrics_repository.dart'
    as _i74;
import '../../features/hardware_metrics/domain/usecases/collect_snapshot_usecase.dart'
    as _i654;
import '../../features/hardware_metrics/domain/usecases/sync_snapshot_usecase.dart'
    as _i364;
import '../../features/hardware_metrics/presentation/bloc/hardware_metrics_cubit.dart'
    as _i748;
import '../../features/settings/data/datasources/settings_remote_datasource.dart'
    as _i140;
import '../../features/settings/data/repositories/settings_repository_impl.dart'
    as _i955;
import '../../features/settings/presentation/bloc/settings_cubit.dart' as _i819;
import '../../features/traffic/data/datasources/ml_datasource.dart' as _i1039;
import '../../features/traffic/data/datasources/traffic_local_datasource.dart'
    as _i279;
import '../../features/traffic/domain/repositories/traffic_repository.dart'
    as _i830;
import '../../features/traffic/domain/usecases/process_packet_usecase.dart'
    as _i750;
import '../../features/traffic/presentation/bloc/traffic_bloc.dart' as _i455;
import '../../features/vpn/data/datasources/vpn_native_datasource.dart'
    as _i733;
import '../../features/vpn/data/repositories/vpn_repository_impl.dart' as _i124;
import '../../features/vpn/domain/repositories/vpn_repository.dart' as _i335;
import '../../features/vpn/domain/usecases/get_packet_stream_usecase.dart'
    as _i658;
import '../../features/vpn/domain/usecases/is_vpn_running_usecase.dart'
    as _i952;
import '../../features/vpn/domain/usecases/start_vpn_usecase.dart' as _i327;
import '../../features/vpn/domain/usecases/stop_vpn_usecase.dart' as _i534;
import '../../features/vpn/presentation/bloc/vpn_cubit.dart' as _i764;
import '../api/api_consumer.dart' as _i207;
import '../api/dio_consumer.dart' as _i82;
import '../bootstrap/app_bootstrap.dart' as _i358;
import '../interceptors/error_interceptor.dart' as _i1065;
import '../interceptors/logging_interceptor.dart' as _i707;
import '../interceptors/refresh_token_interceptor.dart' as _i307;
import '../services/toast/toast_service.dart' as _i427;
import '../session/session_event_bus.dart' as _i223;
import '../websocket/firewall_log_ws_service.dart' as _i473;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.sharedPreferences(),
      preResolve: true,
    );
    await gh.factoryAsync<_i1039.MlDataSource>(
      () => registerModule.mlDataSource(),
      preResolve: true,
    );
    gh.singleton<_i1065.ErrorInterceptor>(() => _i1065.ErrorInterceptor());
    gh.singleton<_i707.LoggingInterceptor>(() => _i707.LoggingInterceptor());
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i427.ToastService>(() => _i427.ToastService());
    gh.lazySingleton<_i223.SessionEventBus>(
      () => _i223.SessionEventBus(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i529.BlacklistLocalDataSource>(
      () => _i529.BlacklistLocalDataSource(),
    );
    gh.lazySingleton<_i150.HardwareLocalDataSource>(
      () => _i150.HardwareLocalDataSource(),
    );
    gh.lazySingleton<_i279.TrafficLocalDataSource>(
      () => _i279.TrafficLocalDataSource(),
    );
    gh.lazySingleton<_i733.VpnNativeDataSource>(
      () => _i733.VpnNativeDataSource(),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.chatDio,
      instanceName: 'chatDio',
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.apiDio,
      instanceName: 'apiDio',
    );
    gh.lazySingleton<_i992.AuthLocalDataSource>(
      () => _i992.AuthLocalDataSource(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i335.VpnRepository>(
      () => _i124.VpnRepositoryImpl(gh<_i733.VpnNativeDataSource>()),
    );
    gh.lazySingleton<_i207.ApiConsumer>(
      () => _i82.DioConsumer(
        gh<_i361.Dio>(instanceName: 'apiDio'),
        gh<_i1065.ErrorInterceptor>(),
        gh<_i707.LoggingInterceptor>(),
        refreshTokenInterceptor: gh<_i307.RefreshTokenInterceptor>(),
      ),
    );
    gh.lazySingleton<_i301.BlacklistRemoteDataSource>(
      () => _i301.BlacklistRemoteDataSource(
        gh<_i207.ApiConsumer>(),
        gh<_i992.AuthLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i788.FirewallLogRemoteDataSource>(
      () => _i788.FirewallLogRemoteDataSource(
        gh<_i207.ApiConsumer>(),
        gh<_i992.AuthLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i684.HardwareRemoteDataSource>(
      () => _i684.HardwareRemoteDataSource(
        gh<_i207.ApiConsumer>(),
        gh<_i992.AuthLocalDataSource>(),
      ),
    );
    gh.factory<_i658.GetPacketStreamUseCase>(
      () => _i658.GetPacketStreamUseCase(gh<_i335.VpnRepository>()),
    );
    gh.factory<_i952.IsVpnRunningUseCase>(
      () => _i952.IsVpnRunningUseCase(gh<_i335.VpnRepository>()),
    );
    gh.factory<_i327.StartVpnUseCase>(
      () => _i327.StartVpnUseCase(gh<_i335.VpnRepository>()),
    );
    gh.factory<_i534.StopVpnUseCase>(
      () => _i534.StopVpnUseCase(gh<_i335.VpnRepository>()),
    );
    gh.lazySingleton<_i307.RefreshTokenInterceptor>(
      () => _i307.RefreshTokenInterceptor(
        dio: gh<_i361.Dio>(instanceName: 'apiDio'),
        local: gh<_i992.AuthLocalDataSource>(),
        bus: gh<_i223.SessionEventBus>(),
      ),
    );
    gh.lazySingleton<_i473.FirewallLogWsService>(
      () => registerModule.firewallLogWs(gh<_i992.AuthLocalDataSource>()),
    );
    gh.lazySingleton<_i344.ChatbotRemoteDataSource>(
      () => _i344.ChatbotRemoteDataSource(
        gh<_i361.Dio>(instanceName: 'chatDio'),
        gh<_i992.AuthLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i161.AuthRemoteDataSource>(
      () => _i161.AuthRemoteDataSource(gh<_i207.ApiConsumer>()),
    );
    gh.lazySingleton<_i140.SettingsRemoteDataSource>(
      () => _i140.SettingsRemoteDataSource(gh<_i207.ApiConsumer>()),
    );
    gh.lazySingleton<_i764.VpnCubit>(
      () => _i764.VpnCubit(
        startVpn: gh<_i327.StartVpnUseCase>(),
        stopVpn: gh<_i534.StopVpnUseCase>(),
        isVpnRunning: gh<_i952.IsVpnRunningUseCase>(),
      ),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i161.AuthRemoteDataSource>(),
        gh<_i992.AuthLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i719.ChatbotRepository>(
      () => _i741.ChatbotRepositoryImpl(gh<_i344.ChatbotRemoteDataSource>()),
    );
    gh.factory<_i52.CheckAuthStatusUseCase>(
      () => _i52.CheckAuthStatusUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i259.SignInUseCase>(
      () => _i259.SignInUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i915.SignOutUseCase>(
      () => _i915.SignOutUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i860.SignUpUseCase>(
      () => _i860.SignUpUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i798.UpdateProfileUseCase>(
      () => _i798.UpdateProfileUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i74.HardwareMetricsRepository>(
      () => _i463.HardwareMetricsRepositoryImpl(
        local: gh<_i150.HardwareLocalDataSource>(),
        remote: gh<_i684.HardwareRemoteDataSource>(),
      ),
    );
    gh.factory<_i346.SendMessageUseCase>(
      () => _i346.SendMessageUseCase(gh<_i719.ChatbotRepository>()),
    );
    gh.lazySingleton<_i137.FirewallLogRepository>(
      () => _i26.FirewallLogRepositoryImpl(
        gh<_i788.FirewallLogRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i955.SettingsRepositoryImpl>(
      () => _i955.SettingsRepositoryImpl(
        gh<_i140.SettingsRemoteDataSource>(),
        gh<_i992.AuthLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i454.BlacklistRepository>(
      () => _i421.BlacklistRepositoryImpl(
        gh<_i529.BlacklistLocalDataSource>(),
        gh<_i733.VpnNativeDataSource>(),
        gh<_i301.BlacklistRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i52.AuthCubit>(
      () => _i52.AuthCubit(
        checkAuthStatusUseCase: gh<_i52.CheckAuthStatusUseCase>(),
        signInUseCase: gh<_i259.SignInUseCase>(),
        signUpUseCase: gh<_i860.SignUpUseCase>(),
        signOutUseCase: gh<_i915.SignOutUseCase>(),
        updateProfileUseCase: gh<_i798.UpdateProfileUseCase>(),
        sessionEventBus: gh<_i223.SessionEventBus>(),
      ),
    );
    gh.factory<_i654.CollectSnapshotUseCase>(
      () => _i654.CollectSnapshotUseCase(gh<_i74.HardwareMetricsRepository>()),
    );
    gh.factory<_i364.SyncSnapshotUseCase>(
      () => _i364.SyncSnapshotUseCase(gh<_i74.HardwareMetricsRepository>()),
    );
    gh.lazySingleton<_i830.TrafficRepository>(
      () => registerModule.trafficRepository(
        gh<_i454.BlacklistRepository>(),
        gh<_i1039.MlDataSource>(),
        gh<_i733.VpnNativeDataSource>(),
      ),
    );
    gh.lazySingleton<_i819.SettingsCubit>(
      () => _i819.SettingsCubit(
        gh<_i460.SharedPreferences>(),
        gh<_i955.SettingsRepositoryImpl>(),
      ),
    );
    gh.factory<_i656.AddToBlacklistUseCase>(
      () => _i656.AddToBlacklistUseCase(gh<_i454.BlacklistRepository>()),
    );
    gh.factory<_i589.ClearBlacklistUseCase>(
      () => _i589.ClearBlacklistUseCase(gh<_i454.BlacklistRepository>()),
    );
    gh.factory<_i142.GetBlacklistUseCase>(
      () => _i142.GetBlacklistUseCase(gh<_i454.BlacklistRepository>()),
    );
    gh.factory<_i119.RemoveFromBlacklistUseCase>(
      () => _i119.RemoveFromBlacklistUseCase(gh<_i454.BlacklistRepository>()),
    );
    gh.factory<_i48.WatchBlacklistUseCase>(
      () => _i48.WatchBlacklistUseCase(gh<_i454.BlacklistRepository>()),
    );
    gh.lazySingleton<_i1035.ChatCubit>(
      () => _i1035.ChatCubit(sendMessage: gh<_i346.SendMessageUseCase>()),
    );
    gh.factory<_i160.GetFirewallLogsUseCase>(
      () => _i160.GetFirewallLogsUseCase(gh<_i137.FirewallLogRepository>()),
    );
    gh.factory<_i664.PostFirewallLogUseCase>(
      () => _i664.PostFirewallLogUseCase(gh<_i137.FirewallLogRepository>()),
    );
    gh.lazySingleton<_i748.HardwareMetricsCubit>(
      () => _i748.HardwareMetricsCubit(
        collect: gh<_i654.CollectSnapshotUseCase>(),
        sync: gh<_i364.SyncSnapshotUseCase>(),
      ),
    );
    gh.factory<_i750.ProcessPacketUseCase>(
      () => _i750.ProcessPacketUseCase(gh<_i830.TrafficRepository>()),
    );
    gh.lazySingleton<_i364.BlacklistCubit>(
      () => _i364.BlacklistCubit(
        getBlacklist: gh<_i142.GetBlacklistUseCase>(),
        addToBlacklist: gh<_i656.AddToBlacklistUseCase>(),
        removeFromBlacklist: gh<_i119.RemoveFromBlacklistUseCase>(),
        clearBlacklist: gh<_i589.ClearBlacklistUseCase>(),
        watchBlacklist: gh<_i48.WatchBlacklistUseCase>(),
      ),
    );
    gh.lazySingleton<_i455.TrafficBloc>(
      () => _i455.TrafficBloc(
        getPacketStream: gh<_i658.GetPacketStreamUseCase>(),
        processPacket: gh<_i750.ProcessPacketUseCase>(),
        logWs: gh<_i473.FirewallLogWsService>(),
        local: gh<_i279.TrafficLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i342.FirewallLogsCubit>(
      () => _i342.FirewallLogsCubit(
        getLogs: gh<_i160.GetFirewallLogsUseCase>(),
        postLog: gh<_i664.PostFirewallLogUseCase>(),
      ),
    );
    gh.lazySingleton<_i58.DashboardCubit>(
      () => _i58.DashboardCubit(
        trafficBloc: gh<_i455.TrafficBloc>(),
        blacklistCubit: gh<_i364.BlacklistCubit>(),
      ),
    );
    gh.lazySingleton<_i358.AppBootstrap>(
      () => _i358.AppBootstrap(
        gh<_i819.SettingsCubit>(),
        gh<_i830.TrafficRepository>(),
        gh<_i473.FirewallLogWsService>(),
        gh<_i454.BlacklistRepository>(),
        gh<_i764.VpnCubit>(),
        gh<_i455.TrafficBloc>(),
        gh<_i748.HardwareMetricsCubit>(),
        gh<_i223.SessionEventBus>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
