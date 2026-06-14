import 'dart:async';

import 'package:Sentri/features/blacklist/domain/entities/blacklist_entry.dart';
import 'package:Sentri/features/blacklist/domain/repositories/blacklist_repository.dart';
import 'package:Sentri/features/vpn/data/datasources/vpn_native_datasource.dart';
import '../datasources/blacklist_local_datasource.dart';

class BlacklistRepositoryImpl implements BlacklistRepository {
  final BlacklistLocalDataSource _dataSource;
  final VpnNativeDataSource _vpnDataSource;

  // Broadcast so multiple listeners (cubit, dashboard, etc.) can subscribe.
  final StreamController<void> _changes = StreamController<void>.broadcast();

  BlacklistRepositoryImpl(this._dataSource, this._vpnDataSource);

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
    // Also lift the block at the network level, otherwise the VPN keeps
    // dropping this IP even though it's gone from the user-visible list.
    await _vpnDataSource.unblockIp(ip);
    _changes.add(null);
  }

  @override
  Future<void> clearAll() async {
    await _dataSource.clearAll();
    // Forget every network-level block too (memory + persisted), so clearing
    // the list actually restores connectivity.
    await _vpnDataSource.clearAllBlockedIps();
    _changes.add(null);
  }
}
