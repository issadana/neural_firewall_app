import 'package:freezed_annotation/freezed_annotation.dart';

part 'acl_entry.freezed.dart';
part 'acl_entry.g.dart';

@freezed
abstract class AclEntry with _$AclEntry {
  const factory AclEntry({
    required String ip,
    required DateTime addedAt,
    String? notes,
  }) = _AclEntry;

  factory AclEntry.fromJson(Map<String, dynamic> json) => _$AclEntryFromJson(json);
}
