// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) =>
    _DashboardStats(
      packetsAnalyzed: (json['packetsAnalyzed'] as num).toInt(),
      ipsBlacklisted: (json['ipsBlacklisted'] as num).toInt(),
      maxThreatPercent: (json['maxThreatPercent'] as num).toDouble(),
      blockedCount: (json['blockedCount'] as num).toInt(),
      warnCount: (json['warnCount'] as num).toInt(),
      safeCount: (json['safeCount'] as num).toInt(),
    );

Map<String, dynamic> _$DashboardStatsToJson(_DashboardStats instance) =>
    <String, dynamic>{
      'packetsAnalyzed': instance.packetsAnalyzed,
      'ipsBlacklisted': instance.ipsBlacklisted,
      'maxThreatPercent': instance.maxThreatPercent,
      'blockedCount': instance.blockedCount,
      'warnCount': instance.warnCount,
      'safeCount': instance.safeCount,
    };
