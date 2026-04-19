import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums.dart';

part 'packet_record.freezed.dart';
part 'packet_record.g.dart';

@freezed
abstract class PacketRecord with _$PacketRecord {
  const factory PacketRecord({
    required String id,
    required String srcIp,
    required int srcPort,
    required String dstIp,
    required int dstPort,
    required Protocol protocol,
    required PacketStatus status,
    required int sizeBytes,
    required double bruteForceScore,
    required double dosScore,
    required DateTime timestamp,
    required bool isBlacklisted,
    required bool isAclBlocked,
  }) = _PacketRecord;

  factory PacketRecord.fromJson(Map<String, dynamic> json) =>
      _$PacketRecordFromJson(json);
}
