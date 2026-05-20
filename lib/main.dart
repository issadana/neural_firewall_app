import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

import 'features/acl/data/datasources/acl_local_datasource.dart';
import 'features/acl/data/repositories/acl_repository_impl.dart';
import 'features/acl/domain/usecases/add_acl_usecase.dart';
import 'features/acl/domain/usecases/clear_acl_usecase.dart';
import 'features/acl/domain/usecases/get_acl_usecase.dart';
import 'features/acl/domain/usecases/remove_acl_usecase.dart';
import 'features/acl/presentation/bloc/acl_cubit.dart';

import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_out_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';

import 'features/blacklist/data/datasources/blacklist_local_datasource.dart';
import 'features/blacklist/data/repositories/blacklist_repository_impl.dart';
import 'features/blacklist/domain/usecases/add_to_blacklist_usecase.dart';
import 'features/blacklist/domain/usecases/clear_blacklist_usecase.dart';
import 'features/blacklist/domain/usecases/get_blacklist_usecase.dart';
import 'features/blacklist/domain/usecases/remove_from_blacklist_usecase.dart';
import 'features/blacklist/presentation/bloc/blacklist_cubit.dart';

import 'features/dashboard/presentation/bloc/dashboard_cubit.dart';

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
  final aclDs        = AclLocalDataSource();
  final blacklistDs  = BlacklistLocalDataSource();
  final mlDs         = MlDataSource();
  await mlDs.init();
  final vpnDs = VpnNativeDataSource();

  // ── Repositories ────────────────────────────────────────────────────────────
  final aclRepo       = AclRepositoryImpl(aclDs);
  final blacklistRepo = BlacklistRepositoryImpl(blacklistDs);
  final trafficRepo   = TrafficRepositoryImpl(
    blacklistRepository: blacklistRepo,
    aclRepository: aclRepo,
    mlDataSource: mlDs,
  );
  final vpnRepo = VpnRepositoryImpl(vpnDs);
  final authDs  = AuthLocalDataSource(prefs);
  final authRepo = AuthRepositoryImpl(authDs);

  // ── Use cases ───────────────────────────────────────────────────────────────
  final getAcl    = GetAclUseCase(aclRepo);
  final addAcl    = AddAclUseCase(aclRepo);
  final removeAcl = RemoveAclUseCase(aclRepo);
  final clearAcl  = ClearAclUseCase(aclRepo);

  final checkAuth = CheckAuthStatusUseCase(authRepo);
  final signIn    = SignInUseCase(authRepo);
  final signUp    = SignUpUseCase(authRepo);
  final signOut   = SignOutUseCase(authRepo);

  final getBlacklist    = GetBlacklistUseCase(blacklistRepo);
  final addBlacklist    = AddToBlacklistUseCase(blacklistRepo);
  final removeBlacklist = RemoveFromBlacklistUseCase(blacklistRepo);
  final clearBlacklist  = ClearBlacklistUseCase(blacklistRepo);

  final processPacket   = ProcessPacketUseCase(trafficRepo);
  final getPacketStream = GetPacketStreamUseCase(vpnRepo);
  final startVpn        = StartVpnUseCase(vpnRepo);
  final stopVpn         = StopVpnUseCase(vpnRepo);

  // ── Cubits / Blocs ──────────────────────────────────────────────────────────
  final aclCubit = AclCubit(
    getAcl: getAcl,
    addAcl: addAcl,
    removeAcl: removeAcl,
    clearAcl: clearAcl,
  );

  final blacklistCubit = BlacklistCubit(
    getBlacklist: getBlacklist,
    addToBlacklist: addBlacklist,
    removeFromBlacklist: removeBlacklist,
    clearBlacklist: clearBlacklist,
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

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit(
            checkAuthStatusUseCase: checkAuth,
            signInUseCase: signIn,
            signUpUseCase: signUp,
            signOutUseCase: signOut,
          ),
        ),
        BlocProvider.value(value: vpnCubit),
        BlocProvider.value(value: trafficBloc),
        BlocProvider.value(value: dashboardCubit),
        BlocProvider.value(value: blacklistCubit),
        BlocProvider.value(value: aclCubit),
        BlocProvider(create: (_) => SettingsCubit(prefs)),
      ],
      child: const SentriApp(),
    ),
  );
}
