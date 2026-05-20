import 'package:Sentri/features/acl/domain/entities/acl_entry.dart';
import 'package:Sentri/features/acl/domain/repositories/acl_repository.dart';
import '../datasources/acl_local_datasource.dart';

class AclRepositoryImpl implements AclRepository {
  final AclLocalDataSource _dataSource;

  const AclRepositoryImpl(this._dataSource);

  @override
  Future<List<AclEntry>> getAll() => _dataSource.getAll();

  @override
  Future<bool> isBlocked(String ip) => _dataSource.isBlocked(ip);

  @override
  Future<void> add(String ip, {String? notes}) => _dataSource.add(ip, notes: notes);

  @override
  Future<void> remove(String ip) => _dataSource.remove(ip);

  @override
  Future<void> clearAll() => _dataSource.clearAll();
}
