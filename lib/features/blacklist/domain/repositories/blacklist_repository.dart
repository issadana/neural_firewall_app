import '../entities/blacklist_entry.dart';

abstract class BlacklistRepository {
  Future<List<BlacklistEntry>> getAll();
  Future<bool> isBlocked(String ip);
  Future<void> add(String ip, String reason, {double? bfScore, double? dosScore, String? notes});
  Future<void> remove(String ip);
  Future<void> clearAll();
}
