import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Sentri/features/blacklist/domain/entities/blacklist_entry.dart';

final _log = Logger();

class BlacklistLocalDataSource {
  static const String _key = 'blacklist_entries';

  final List<BlacklistEntry> _cache = [];
  bool _initialized = false;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      try {
        final List<dynamic> decoded = jsonDecode(json);
        _cache.addAll(
          decoded.map(
            (e) => BlacklistEntry.fromJson(e as Map<String, dynamic>),
          ),
        );
      } catch (e) {
        _log.e('Error loading blacklist: $e');
      }
    }
    _initialized = true;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_cache.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<BlacklistEntry>> getAll() async {
    await _ensureInit();
    return List.unmodifiable(_cache);
  }

  Future<bool> isBlocked(String ip) async {
    await _ensureInit();
    return _cache.any((e) => e.ip == ip);
  }

  Future<BlacklistEntry?> findByIp(String ip) async {
    await _ensureInit();
    for (final e in _cache) {
      if (e.ip == ip) return e;
    }
    return null;
  }

  /// Inserts [entry], replacing any existing entry with the same ip. Used to
  /// stamp a server id onto a local entry after it syncs.
  Future<void> upsert(BlacklistEntry entry) async {
    await _ensureInit();
    _cache.removeWhere((e) => e.ip == entry.ip);
    _cache.add(entry);
    await _persist();
  }

  /// Replaces the entire cache (used when reconciling with the server list).
  Future<void> replaceAll(Iterable<BlacklistEntry> entries) async {
    await _ensureInit();
    _cache
      ..clear()
      ..addAll(entries);
    await _persist();
  }

  Future<void> add(
    String ip,
    String reason, {
    double? bfScore,
    double? dosScore,
    String? notes,
  }) async {
    await _ensureInit();
    _cache.removeWhere((e) => e.ip == ip);
    _cache.add(
      BlacklistEntry(
        ip: ip,
        addedAt: DateTime.now(),
        reason: reason,
        bruteForceScore: bfScore,
        dosScore: dosScore,
        notes: notes,
      ),
    );
    await _persist();
  }

  Future<void> remove(String ip) async {
    await _ensureInit();
    _cache.removeWhere((e) => e.ip == ip);
    await _persist();
  }

  Future<void> clearAll() async {
    await _ensureInit();
    _cache.clear();
    await _persist();
  }
}
