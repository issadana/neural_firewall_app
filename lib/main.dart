import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neural_firewall_app/core/injection/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import 'app.dart';
import 'blocs/acl/acl_cubit.dart';
import 'blocs/auth/auth_cubit.dart';
import 'blocs/blacklist/blacklist_cubit.dart';
import 'blocs/dashboard/dashboard_cubit.dart';
import 'blocs/settings/settings_cubit.dart';
import 'blocs/traffic/traffic_bloc.dart';
import 'blocs/vpn/vpn_cubit.dart';
import 'services/list_services.dart';
import 'services/ml_services.dart';
import 'services/packet_processor_service.dart';
import 'services/vpn_bridge_service.dart';

final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await configureDependencies();

  // Get SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize services
  final mlService = MlInferenceService();
  await mlService.init();

  final blacklistService = BlacklistService();
  await blacklistService.init();

  final aclService = AclService();
  await aclService.init();

  final heuristicService = HeuristicService();
  final vpnBridgeService = VpnBridgeService();

  // Create Cubits/Blocs
  final blacklistCubit = BlacklistCubit(blacklistService);
  final aclCubit = AclCubit(aclService);
  final settingsCubit = SettingsCubit(prefs);

  final packetProcessor = PacketProcessorService(
    blacklist: blacklistService,
    acl: aclService,
    heuristics: heuristicService,
    ml: mlService,
    blockThreshold: settingsCubit.state.blockThreshold,
    warnThreshold: settingsCubit.state.warnThreshold,
  );

  final trafficBloc = TrafficBloc(vpnBridgeService, packetProcessor);
  final vpnCubit = VpnCubit(vpnBridgeService);
  final dashboardCubit = DashboardCubit(
    trafficBloc: trafficBloc,
    blacklistCubit: blacklistCubit,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(prefs)),
        BlocProvider.value(value: vpnCubit),
        BlocProvider.value(value: trafficBloc),
        BlocProvider.value(value: dashboardCubit),
        BlocProvider.value(value: blacklistCubit),
        BlocProvider.value(value: aclCubit),
        BlocProvider.value(value: settingsCubit),
      ],
      child: const NeuralFirewallApp(),
    ),
  );
}



