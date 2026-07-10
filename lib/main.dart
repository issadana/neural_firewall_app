import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/bootstrap/app_bootstrap.dart';
import 'core/injection/injection.dart';
import 'core/websocket/firewall_log_ws_service.dart';
import 'core/widgets/navigation_bar/app.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/blacklist/domain/repositories/blacklist_repository.dart';
import 'features/blacklist/presentation/bloc/blacklist_cubit.dart';
import 'features/chatbot/presentation/bloc/chat_cubit.dart';
import 'features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'features/firewall_logs/presentation/bloc/firewall_logs_cubit.dart';
import 'features/hardware_metrics/presentation/bloc/hardware_metrics_cubit.dart';
import 'features/settings/presentation/bloc/settings_cubit.dart';
import 'features/traffic/presentation/bloc/traffic_bloc.dart';
import 'features/vpn/presentation/bloc/vpn_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Wire the entire dependency graph. Object construction lives in injectable
  // (annotations + register_module.dart / injection.config.dart); this single
  // call registers all of it, awaiting the async @preResolve deps
  // (SharedPreferences, the ML models).
  await configureDependencies();

  // Runtime orchestration DI can't express: cross-cubit stream wiring, seeding
  // the traffic pipeline from settings, resuming a sticky VPN session, and
  // tearing down the authed socket on session expiry.
  getIt<AppBootstrap>().start();

  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            // App-global singletons resolved from the container. `.value` so the
            // provider never closes a shared singleton on widget disposal.
            BlocProvider.value(value: getIt<AuthCubit>()),
            BlocProvider.value(value: getIt<VpnCubit>()),
            BlocProvider.value(value: getIt<TrafficBloc>()),
            BlocProvider.value(value: getIt<DashboardCubit>()),
            BlocProvider.value(value: getIt<HardwareMetricsCubit>()),
            BlocProvider.value(value: getIt<FirewallLogsCubit>()),
            BlocProvider.value(value: getIt<BlacklistCubit>()),
            BlocProvider.value(value: getIt<SettingsCubit>()),
            BlocProvider.value(value: getIt<ChatCubit>()),
          ],
          // Each time the user becomes authenticated (e.g. a fresh sign-in),
          // re-pull server settings/blacklist and open the log WebSocket now
          // that a valid token exists.
          child: BlocListener<AuthCubit, AuthState>(
            listenWhen: (prev, curr) =>
                prev.status != curr.status &&
                curr.status == AuthStatus.authenticated,
            listener: (context, state) {
              getIt<SettingsCubit>().syncFromServer();
              getIt<BlacklistRepository>().syncFromServer();
              getIt<FirewallLogWsService>().start();
            },
            child: const SentriApp(),
          ),
        );
      },
    ),
  );
}
