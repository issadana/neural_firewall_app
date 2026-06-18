import 'dart:async';

import 'package:Sentri/features/blacklist/domain/entities/blacklist_entry.dart';
import 'package:Sentri/features/blacklist/domain/repositories/blacklist_repository.dart';
import 'package:Sentri/features/vpn/data/datasources/vpn_native_datasource.dart';
import '../datasources/blacklist_local_datasource.dart';
import '../datasources/blacklist_remote_datasource.dart';

/// Local-first blacklist with best-effort backend mirroring. The local store is
/// the authoritative, offline-safe source the VPN and traffic pipeline read; the
/// backend is kept in sync on top so the list follows the user across devices.
///
/// Every mutation updates local state first (and emits [changes] immediately),
/// then mirrors to the server. Remote failures never break the local operation.
class BlacklistRepositoryImpl implements BlacklistRepository {
  final BlacklistLocalDataSource _dataSource;
  final VpnNativeDataSource _vpnDataSource;
  final BlacklistRemoteDataSource _remote;

  // Broadcast so multiple listeners (cubit, dashboard, etc.) can subscribe.
  final StreamController<void> _changes = StreamController<void>.broadcast();

  BlacklistRepositoryImpl(this._dataSource, this._vpnDataSource, this._remote);

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
    await _dataSource.add(ip, reason,
        bfScore: bfScore, dosScore: dosScore, notes: notes);
    _changes.add(null);

    // Mirror to the backend; capture the server id so the entry can be deleted
    // server-side later.
    try {
      final local = await _dataSource.findByIp(ip);
      if (local == null) return;
      final created = await _remote.add(local);
      if (created != null) {
        await _dataSource.upsert(created);
        _changes.add(null);
      }
    } catch (_) {
      // Offline / 409 already-blacklisted / etc. — the local entry stands.
    }
  }

  @override
  Future<void> remove(String ip) async {
    final entry = await _dataSource.findByIp(ip);
    await _dataSource.remove(ip);
    // Also lift the block at the network level, otherwise the VPN keeps
    // dropping this IP even though it's gone from the user-visible list.
    await _vpnDataSource.unblockIp(ip);
    _changes.add(null);

    if (entry?.id != null) {
      try {
        await _remote.remove(entry!.id!);
      } catch (_) {
        // Best-effort; local removal already succeeded.
      }
    }
  }

  @override
  Future<void> clearAll() async {
    await _dataSource.clearAll();
    // Forget every network-level block too (memory + persisted), so clearing
    // the list actually restores connectivity.
    await _vpnDataSource.clearAllBlockedIps();
    _changes.add(null);

    try {
      await _remote.clear();
    } catch (_) {
      // Best-effort.
    }
  }

  @override
  Future<void> syncFromServer() async {
    final List<BlacklistEntry>? remote;
    try {
      remote = await _remote.getAll();
    } catch (_) {
      return; // Offline / server error — keep the local list as-is.
    }
    if (remote == null) return; // Signed out.

    // Server is authoritative for synced entries; preserve any purely-local
    // entries (offline auto-blocks with no id) that the server doesn't know yet.
    final serverIps = remote.map((e) => e.ip).toSet();
    final local = await _dataSource.getAll();
    final unsynced =
        local.where((e) => e.id == null && !serverIps.contains(e.ip)).toList();

    await _dataSource.replaceAll([...remote, ...unsynced]);
    _changes.add(null);

    // Push the still-unsynced local entries up so the mirror is complete.
    var pushed = false;
    for (final entry in unsynced) {
      try {
        final created = await _remote.add(entry);
        if (created != null) {
          await _dataSource.upsert(created);
          pushed = true;
        }
      } catch (_) {
        // Leave it local; it'll retry on the next sync.
      }
    }
    if (pushed) _changes.add(null);
  }
}
