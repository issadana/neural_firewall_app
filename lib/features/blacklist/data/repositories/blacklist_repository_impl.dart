import 'dart:async';

import 'package:Sentri/features/blacklist/domain/entities/blacklist_entry.dart';
import 'package:Sentri/features/blacklist/domain/repositories/blacklist_repository.dart';
import '../datasources/blacklist_local_datasource.dart';

class BlacklistRepositoryImpl implements BlacklistRepository {
  final BlacklistLocalDataSource _dataSource;

  // Broadcast so multiple listeners (cubit, dashboard, etc.) can subscribe.
  final StreamController<void> _changes = StreamController<void>.broadcast();

  BlacklistRepositoryImpl(this._dataSource);

  @override
  Stream<void> get changes => _changes.stream;

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
  }) async {
    await _dataSource.add(ip, reason, bfScore: bfScore, dosScore: dosScore, notes: notes);
    _changes.add(null);
  }

  @override
  Future<void> remove(String ip) async {
    await _dataSource.remove(ip);
    _changes.add(null);
  }

  @override
  Future<void> clearAll() async {
    await _dataSource.clearAll();
    _changes.add(null);
  }
}
