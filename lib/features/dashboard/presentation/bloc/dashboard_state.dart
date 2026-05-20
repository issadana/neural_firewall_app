import 'package:equatable/equatable.dart';

class DashboardState extends Equatable {
  final int packetsAnalyzed;
  final int ipsBlacklisted;
  final double maxThreatPercent;
  final int blockedCount;
  final int warnCount;
  final int safeCount;

  const DashboardState({
    this.packetsAnalyzed = 0,
    this.ipsBlacklisted = 0,
    this.maxThreatPercent = 0.0,
    this.blockedCount = 0,
    this.warnCount = 0,
    this.safeCount = 0,
  });

  DashboardState copyWith({
    int? packetsAnalyzed,
    int? ipsBlacklisted,
    double? maxThreatPercent,
    int? blockedCount,
    int? warnCount,
    int? safeCount,
  }) {
    return DashboardState(
      packetsAnalyzed: packetsAnalyzed ?? this.packetsAnalyzed,
      ipsBlacklisted: ipsBlacklisted ?? this.ipsBlacklisted,
      maxThreatPercent: maxThreatPercent ?? this.maxThreatPercent,
      blockedCount: blockedCount ?? this.blockedCount,
      warnCount: warnCount ?? this.warnCount,
      safeCount: safeCount ?? this.safeCount,
    );
  }

  @override
  List<Object?> get props => [
        packetsAnalyzed,
        ipsBlacklisted,
        maxThreatPercent,
        blockedCount,
        warnCount,
        safeCount,
      ];
}
