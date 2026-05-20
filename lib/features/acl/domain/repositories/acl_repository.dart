import '../entities/acl_entry.dart';

abstract class AclRepository {
  Future<List<AclEntry>> getAll();
  Future<bool> isBlocked(String ip);
  Future<void> add(String ip, {String? notes});
  Future<void> remove(String ip);
  Future<void> clearAll();
}
