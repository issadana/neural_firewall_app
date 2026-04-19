// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acl_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AclEntry _$AclEntryFromJson(Map<String, dynamic> json) => _AclEntry(
  ip: json['ip'] as String,
  addedAt: DateTime.parse(json['addedAt'] as String),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$AclEntryToJson(_AclEntry instance) => <String, dynamic>{
  'ip': instance.ip,
  'addedAt': instance.addedAt.toIso8601String(),
  'notes': instance.notes,
};
