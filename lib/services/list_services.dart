import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_models.dart';

final _log = Logger();

class BlacklistService {
  late SharedPreferences _prefs;
  bool _initialized = false;
  final List<BlacklistEntry> _cache = [];

  static const String _blacklistKey = 'blacklist_entries';

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _loadFromStorage();
    _initialized = true;
  }

  void _loadFromStorage() {
    final json = _prefs.getString(_blacklistKey);
    if (json != null) {
      try {
        final List<dynamic> decoded = jsonDecode(json);
        _cache.clear();
        _cache.addAll(
          decoded.map((e) => BlacklistEntry.fromJson(e as Map<String, dynamic>)),
        );
      } catch (e) {
        _log.e('Error loading blacklist: $e');
      }
    }
  }

  Future<void> _saveToStorage() async {
    final json = jsonEncode(_cache.map((e) => e.toJson()).toList());
    await _prefs.setString(_blacklistKey, json);
  }

  Future<void> add(
    String ip,
    BlacklistReason reason, {
    double? bfScore,
    double? dosScore,
    String? notes,
  }) async {
    await init();
    _cache.removeWhere((e) => e.ip == ip);
    _cache.add(BlacklistEntry(
      ip: ip,
      addedAt: DateTime.now(),
      reason: reason.toString(),
      bruteForceScore: bfScore,
      dosScore: dosScore,
      notes: notes,
    ));
    await _saveToStorage();
  }

  Future<void> remove(String ip) async {
    await init();
    _cache.removeWhere((e) => e.ip == ip);
    await _saveToStorage();
  }

  Future<void> clearAll() async {
    await init();
    _cache.clear();
    await _saveToStorage();
  }

  Future<List<BlacklistEntry>> getAll() async {
    await init();
    return List.from(_cache);
  }

  Future<BlacklistEntry?> get(String ip) async {
    await init();
    try {
      return _cache.firstWhere((e) => e.ip == ip);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isBlocked(String ip) async {
    await init();
    return _cache.any((e) => e.ip == ip);
  }

  Future<int> count() async {
    await init();
    return _cache.length;
  }
}

class AclService {
  late SharedPreferences _prefs;
  bool _initialized = false;
  final List<AclEntry> _cache = [];

  static const String _aclKey = 'acl_entries';

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _loadFromStorage();
    _initialized = true;
  }

  void _loadFromStorage() {
    final json = _prefs.getString(_aclKey);
    if (json != null) {
      try {
        final List<dynamic> decoded = jsonDecode(json);
        _cache.clear();
        _cache.addAll(
          decoded.map((e) => AclEntry.fromJson(e as Map<String, dynamic>)),
        );
      } catch (e) {
        _log.e('Error loading ACL: $e');
      }
    }
  }

  Future<void> _saveToStorage() async {
    final json = jsonEncode(_cache.map((e) => e.toJson()).toList());
    await _prefs.setString(_aclKey, json);
  }

  Future<void> add(String ip, {String? notes}) async {
    await init();
    _cache.removeWhere((e) => e.ip == ip);
    _cache.add(AclEntry(
      ip: ip,
      addedAt: DateTime.now(),
      notes: notes,
    ));
    await _saveToStorage();
  }

  Future<void> remove(String ip) async {
    await init();
    _cache.removeWhere((e) => e.ip == ip);
    await _saveToStorage();
  }

  Future<void> clearAll() async {
    await init();
    _cache.clear();
    await _saveToStorage();
  }

  Future<List<AclEntry>> getAll() async {
    await init();
    return List.from(_cache);
  }

  Future<AclEntry?> get(String ip) async {
    await init();
    try {
      return _cache.firstWhere((e) => e.ip == ip);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isBlocked(String ip) async {
    await init();
    return _cache.any((e) => e.ip == ip);
  }

  Future<int> count() async {
    await init();
    return _cache.length;
  }
}
