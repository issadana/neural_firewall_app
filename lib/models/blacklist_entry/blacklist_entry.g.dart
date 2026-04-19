// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blacklist_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BlacklistEntry _$BlacklistEntryFromJson(Map<String, dynamic> json) =>
    _BlacklistEntry(
      ip: json['ip'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
      reason: json['reason'] as String,
      bruteForceScore: (json['bruteForceScore'] as num?)?.toDouble(),
      dosScore: (json['dosScore'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$BlacklistEntryToJson(_BlacklistEntry instance) =>
    <String, dynamic>{
      'ip': instance.ip,
      'addedAt': instance.addedAt.toIso8601String(),
      'reason': instance.reason,
      'bruteForceScore': instance.bruteForceScore,
      'dosScore': instance.dosScore,
      'notes': instance.notes,
    };
