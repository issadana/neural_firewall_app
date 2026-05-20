import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Sentri/features/acl/domain/entities/acl_entry.dart';

final _log = Logger();

class AclLocalDataSource {
  static const String _key = 'acl_entries';

  final List<AclEntry> _cache = [];
  bool _initialized = false;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      try {
        final List<dynamic> decoded = jsonDecode(json);
        _cache.addAll(decoded.map((e) => AclEntry.fromJson(e as Map<String, dynamic>)));
      } catch (e) {
        _log.e('Error loading ACL: $e');
      }
    }
    _initialized = true;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_cache.map((e) => e.toJson()).toList()));
  }

  Future<List<AclEntry>> getAll() async {
    await _ensureInit();
    return List.unmodifiable(_cache);
  }

  Future<bool> isBlocked(String ip) async {
    await _ensureInit();
    return _cache.any((e) => e.ip == ip);
  }

  Future<void> add(String ip, {String? notes}) async {
    await _ensureInit();
    _cache.removeWhere((e) => e.ip == ip);
    _cache.add(AclEntry(ip: ip, addedAt: DateTime.now(), notes: notes));
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
