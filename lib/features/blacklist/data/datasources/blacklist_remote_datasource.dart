import 'package:Sentri/core/api/api_consumer.dart';
import 'package:Sentri/features/auth/data/datasources/auth_local_datasource.dart';

import '../../domain/entities/blacklist_entry.dart';
import '../endpoints/blacklist_endpoints.dart';

/// Talks to the authenticated `/blacklist` endpoints. Pulls the access token
/// from the auth session itself; every method returns null / no-ops when the
/// user is signed out, so callers can treat the backend as best-effort.
class BlacklistRemoteDataSource {
  final ApiConsumer _api;
  final AuthLocalDataSource _auth;

  BlacklistRemoteDataSource(this._api, this._auth);

  Future<String?> _token() => _auth.getAccessToken();

  /// GET /blacklist → all entries (newest first), or null when signed out.
  Future<List<BlacklistEntry>?> getAll() async {
    final token = await _token();
    if (token == null) return null;
    final response = await _api.get(BlacklistEndpoints.blacklist, token: token);
    return (response as List<dynamic>)
        .map((e) => BlacklistEntry.fromApi(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /blacklist → the created entry (with its server id), or null when
  /// signed out. Throws on real errors (e.g. 409 already blacklisted).
  Future<BlacklistEntry?> add(BlacklistEntry entry) async {
    final token = await _token();
    if (token == null) return null;
    final response = await _api.post(
      BlacklistEndpoints.blacklist,
      token: token,
      body: entry.toApiJson(),
    );
    final created = (response as Map<String, dynamic>)['entry'];
    return created is Map<String, dynamic>
        ? BlacklistEntry.fromApi(created)
        : null;
  }

  /// DELETE /blacklist/{id}
  Future<void> remove(int id) async {
    final token = await _token();
    if (token == null) return;
    await _api.delete(BlacklistEndpoints.entry(id), token: token);
  }

  /// DELETE /blacklist — clears every entry.
  Future<void> clear() async {
    final token = await _token();
    if (token == null) return;
    await _api.delete(BlacklistEndpoints.blacklist, token: token);
  }
}
