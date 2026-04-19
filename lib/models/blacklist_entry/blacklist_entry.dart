import 'package:freezed_annotation/freezed_annotation.dart';

part 'blacklist_entry.freezed.dart';
part 'blacklist_entry.g.dart';

@freezed
abstract class BlacklistEntry with _$BlacklistEntry {
  const factory BlacklistEntry({
    required String ip,
    required DateTime addedAt,
    required String reason,
    double? bruteForceScore,
    double? dosScore,
    String? notes,
  }) = _BlacklistEntry;

  factory BlacklistEntry.fromJson(Map<String, dynamic> json) =>
      _$BlacklistEntryFromJson(json);
}
