import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:Sentri/core/enums.dart';
import 'package:Sentri/features/blacklist/presentation/bloc/blacklist_cubit.dart';
import 'package:Sentri/features/traffic/presentation/bloc/traffic_bloc.dart';
import 'dashboard_state.dart';

export 'dashboard_state.dart';

@lazySingleton
class DashboardCubit extends Cubit<DashboardState> {
  final TrafficBloc _trafficBloc;
  final BlacklistCubit _blacklistCubit;

  late final StreamSubscription<TrafficState> _trafficSub;
  late final StreamSubscription<BlacklistState> _blacklistSub;
  int _blacklistedCount = 0;

  DashboardCubit({
    required TrafficBloc trafficBloc,
    required BlacklistCubit blacklistCubit,
  })  : _trafficBloc = trafficBloc,
        _blacklistCubit = blacklistCubit,
        super(const DashboardState()) {
    _trafficSub = _trafficBloc.stream.listen(_onTrafficUpdated);
    _blacklistSub = _blacklistCubit.stream.listen(_onBlacklistUpdated);
  }

  void _onTrafficUpdated(TrafficState traffic) {
    final records = traffic.records;
    if (records.isEmpty) return;

    final maxThreat =
        records.map((r) => max(r.bruteForceScore, r.dosScore) * 100).reduce(max);

    emit(DashboardState(
      packetsAnalyzed: records.length,
      ipsBlacklisted: _blacklistedCount,
      maxThreatPercent: maxThreat,
      blockedCount: records.where((r) => r.status == PacketStatus.aiBlock).length,
      warnCount: records.where((r) => r.status == PacketStatus.warn).length,
      safeCount: records.where((r) => r.status == PacketStatus.safe).length,
    ));
  }

  void _onBlacklistUpdated(BlacklistState bl) {
    _blacklistedCount = bl.entries.length;
    emit(state.copyWith(ipsBlacklisted: _blacklistedCount));
  }

  @override
  Future<void> close() async {
    await _trafficSub.cancel();
    await _blacklistSub.cancel();
    return super.close();
  }
}
