import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_state.freezed.dart';

@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState({
    @Default(0) int packetsAnalyzed,
    @Default(0) int ipsBlacklisted,
    @Default(0.0) double maxThreatPercent,
    @Default(0) int blockedCount,
    @Default(0) int warnCount,
    @Default(0) int safeCount,
  }) = _DashboardState;
}
