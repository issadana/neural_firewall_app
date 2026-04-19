// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flow_features.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FlowFeatures _$FlowFeaturesFromJson(Map<String, dynamic> json) =>
    _FlowFeatures(
      srcIp: json['srcIp'] as String,
      srcPort: (json['srcPort'] as num).toInt(),
      dstIp: json['dstIp'] as String,
      dstPort: (json['dstPort'] as num).toInt(),
      packetCount: (json['packetCount'] as num).toInt(),
      totalBytes: (json['totalBytes'] as num).toInt(),
      iatMean: (json['iatMean'] as num).toInt(),
      iatStd: (json['iatStd'] as num).toInt(),
      duration: (json['duration'] as num).toInt(),
      tcpSynFlag: json['tcpSynFlag'] as bool,
      tcpFinFlag: json['tcpFinFlag'] as bool,
      tcpResetFlag: json['tcpResetFlag'] as bool,
    );

Map<String, dynamic> _$FlowFeaturesToJson(_FlowFeatures instance) =>
    <String, dynamic>{
      'srcIp': instance.srcIp,
      'srcPort': instance.srcPort,
      'dstIp': instance.dstIp,
      'dstPort': instance.dstPort,
      'packetCount': instance.packetCount,
      'totalBytes': instance.totalBytes,
      'iatMean': instance.iatMean,
      'iatStd': instance.iatStd,
      'duration': instance.duration,
      'tcpSynFlag': instance.tcpSynFlag,
      'tcpFinFlag': instance.tcpFinFlag,
      'tcpResetFlag': instance.tcpResetFlag,
    };
