import '../entities/blacklist_entry.dart';

abstract class BlacklistRepository {
  Future<List<BlacklistEntry>> getAll();
  Future<bool> isBlocked(String ip);
  Future<void> add(String ip, String reason, {double? bfScore, double? dosScore, String? notes});
  Future<void> remove(String ip);
  Future<void> clearAll();

  /// Emits whenever the blacklist is mutated (add/remove/clear) from anywhere —
  /// including auto-blocks triggered by the traffic pipeline. Listeners (e.g.
  /// the BlacklistCubit) reload so the UI reflects the change immediately.
  Stream<void> get changes;
}
