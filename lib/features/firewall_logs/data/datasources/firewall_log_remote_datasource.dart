import 'package:injectable/injectable.dart';
import 'package:Sentri/core/api/api_consumer.dart';
import 'package:Sentri/features/auth/data/datasources/auth_local_datasource.dart';
import '../../domain/entities/firewall_log.dart';

/// Talks to the authenticated `/firewall-logs` REST endpoints. Pulls the access
/// token from the auth session and attaches it to every request — the backend
/// rejects missing/absent JWTs with 401.
@lazySingleton
class FirewallLogRemoteDataSource {
  final ApiConsumer _api;
  final AuthLocalDataSource _auth;

  FirewallLogRemoteDataSource(this._api, this._auth);

  Future<String?> _token() => _auth.getAccessToken();

  Future<List<FirewallLog>> getLogs({
    String? action,
    String? threatType,
    String? serviceName,
    String? appName,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 20,
    int offset = 0,
  }) async {
    final token = await _token();
    if (token == null) return const [];
    final params = <String, dynamic>{
      'limit': limit,
      'offset': offset,
      if (action != null) 'action': action,
      if (threatType != null) 'threat_type': threatType,
      if (serviceName != null) 'service_name': serviceName,
      if (appName != null) 'app_name': appName,
      if (fromDate != null) 'from_date': fromDate.toIso8601String(),
      if (toDate != null) 'to_date': toDate.toIso8601String(),
    };
    final response = await _api.get(
      '/firewall-logs',
      queryParameters: params,
      token: token,
    );
    return (response as List<dynamic>)
        .map((e) => FirewallLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> postLog(FirewallLog log) async {
    final token = await _token();
    if (token == null) return;
    await _api.post('/firewall-logs', body: log.toJson(), token: token);
  }
}
