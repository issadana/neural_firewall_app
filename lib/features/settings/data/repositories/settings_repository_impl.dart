import 'package:Sentri/core/errors/network_exceptions.dart';
import 'package:Sentri/features/auth/data/datasources/auth_local_datasource.dart';

import '../datasources/settings_remote_datasource.dart';

/// Bridges the settings cubit to the backend `/settings` endpoints, pulling the
/// access token from the auth session. All methods degrade gracefully: when the
/// user is signed out or the server is unreachable they no-op (push) or return
/// null (fetch), so settings keep working from the local cache.
class SettingsRepositoryImpl {
  final SettingsRemoteDataSource _remote;
  final AuthLocalDataSource _auth;

  SettingsRepositoryImpl(this._remote, this._auth);

  /// Returns the server's settings, or null when signed out / unreachable.
  Future<Map<String, dynamic>?> fetch() async {
    final token = await _auth.getAccessToken();
    if (token == null) return null;
    try {
      return await _remote.getSettings(token);
    } on NetworkExceptions {
      return null;
    }
  }

  /// Pushes [fields] to the server. Silently no-ops when signed out, and lets
  /// the caller decide what to do with a [NetworkExceptions] on real failures.
  Future<void> push(Map<String, dynamic> fields) async {
    final token = await _auth.getAccessToken();
    if (token == null) return;
    await _remote.updateSettings(fields, token);
  }
}
