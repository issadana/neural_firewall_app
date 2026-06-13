import 'package:Sentri/core/api/api_consumer.dart';
import '../../domain/entities/firewall_log.dart';

class FirewallLogRemoteDataSource {
  final ApiConsumer _api;
  FirewallLogRemoteDataSource(this._api);

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
    final response = await _api.get('/firewall-logs', queryParameters: params);
    return (response as List<dynamic>)
        .map((e) => FirewallLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> postLog(FirewallLog log) async {
    await _api.post('/firewall-logs', body: log.toJson());
  }
}
