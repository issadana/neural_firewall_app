// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'packet_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PacketRecord _$PacketRecordFromJson(Map<String, dynamic> json) =>
    _PacketRecord(
      id: json['id'] as String,
      srcIp: json['srcIp'] as String,
      srcPort: (json['srcPort'] as num).toInt(),
      dstIp: json['dstIp'] as String,
      dstPort: (json['dstPort'] as num).toInt(),
      protocol: $enumDecode(_$ProtocolEnumMap, json['protocol']),
      status: $enumDecode(_$PacketStatusEnumMap, json['status']),
      sizeBytes: (json['sizeBytes'] as num).toInt(),
      bruteForceScore: (json['bruteForceScore'] as num).toDouble(),
      dosScore: (json['dosScore'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isBlacklisted: json['isBlacklisted'] as bool,
      isAclBlocked: json['isAclBlocked'] as bool,
    );

Map<String, dynamic> _$PacketRecordToJson(_PacketRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'srcIp': instance.srcIp,
      'srcPort': instance.srcPort,
      'dstIp': instance.dstIp,
      'dstPort': instance.dstPort,
      'protocol': _$ProtocolEnumMap[instance.protocol]!,
      'status': _$PacketStatusEnumMap[instance.status]!,
      'sizeBytes': instance.sizeBytes,
      'bruteForceScore': instance.bruteForceScore,
      'dosScore': instance.dosScore,
      'timestamp': instance.timestamp.toIso8601String(),
      'isBlacklisted': instance.isBlacklisted,
      'isAclBlocked': instance.isAclBlocked,
    };

const _$ProtocolEnumMap = {
  Protocol.tcp: 'tcp',
  Protocol.udp: 'udp',
  Protocol.icmp: 'icmp',
  Protocol.unknown: 'unknown',
};

const _$PacketStatusEnumMap = {
  PacketStatus.aiBlock: 'aiBlock',
  PacketStatus.warn: 'warn',
  PacketStatus.safe: 'safe',
  PacketStatus.tcp: 'tcp',
  PacketStatus.quic: 'quic',
  PacketStatus.ping: 'ping',
  PacketStatus.err: 'err',
};
