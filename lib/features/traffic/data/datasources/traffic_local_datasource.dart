import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Sentri/features/traffic/domain/entities/packet_record.dart';

final _log = Logger();

/// Persists the most recent traffic log locally so it survives app restarts.
/// Mirrors the SharedPreferences + JSON approach used by the blacklist cache.
class TrafficLocalDataSource {
  static const String _key = 'traffic_log_records';

  /// Loads the persisted records, newest first (the same order the UI holds
  /// them in). Returns an empty list if nothing is stored or the data is
  /// corrupt.
  Future<List<PacketRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded
          .map((e) => PacketRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log.e('Error loading traffic log: $e');
      return [];
    }
  }

  /// Overwrites the stored log with [records] (expected newest-first, already
  /// capped to the in-memory limit by the caller).
  Future<void> save(Iterable<PacketRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString(
        _key,
        jsonEncode(records.map((r) => r.toJson()).toList()),
      );
    } catch (e) {
      _log.e('Error saving traffic log: $e');
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
