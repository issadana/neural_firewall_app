import 'package:Sentri/features/blacklist/domain/entities/blacklist_entry.dart';
import 'package:Sentri/features/blacklist/domain/repositories/blacklist_repository.dart';
import '../datasources/blacklist_local_datasource.dart';

class BlacklistRepositoryImpl implements BlacklistRepository {
  final BlacklistLocalDataSource _dataSource;

  const BlacklistRepositoryImpl(this._dataSource);

  @override
  Future<List<BlacklistEntry>> getAll() => _dataSource.getAll();

  @override
  Future<bool> isBlocked(String ip) => _dataSource.isBlocked(ip);

  @override
  Future<void> add(
    String ip,
    String reason, {
    double? bfScore,
    double? dosScore,
    String? notes,
  }) =>
      _dataSource.add(ip, reason, bfScore: bfScore, dosScore: dosScore, notes: notes);

  @override
  Future<void> remove(String ip) => _dataSource.remove(ip);

  @override
  Future<void> clearAll() => _dataSource.clearAll();
}
