import '../entities/blacklist_entry.dart';

abstract class BlacklistRepository {
  Future<List<BlacklistEntry>> getAll();
  Future<bool> isBlocked(String ip);
  Future<void> add(
    String ip,
    String reason, {
    String? selectedModel,
    double? selectedScore,
    Map<String, double>? allModelScores,
    String? notes,
  });
  Future<void> remove(String ip);
  Future<void> clearAll();

  /// Reconciles the local list with the backend: pulls the server entries,
  /// keeps any not-yet-synced local ones, and pushes them up. Best-effort —
  /// no-ops when signed out or offline.
  Future<void> syncFromServer();

  /// Emits whenever the blacklist is mutated (add/remove/clear) from anywhere —
  /// including auto-blocks triggered by the traffic pipeline. Listeners (e.g.
  /// the BlacklistCubit) reload so the UI reflects the change immediately.
  Stream<void> get changes;
}
