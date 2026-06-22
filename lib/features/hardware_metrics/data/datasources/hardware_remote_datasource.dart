import 'package:Sentri/core/api/api_consumer.dart';
import 'package:Sentri/features/auth/data/datasources/auth_local_datasource.dart';
import '../../domain/entities/hardware_snapshot.dart';
import '../endpoints/hardware_metrics_endpoints.dart';

/// Talks to the authenticated `/hardware-metrics` endpoints. Pulls the access
/// token from the auth session itself; every method no-ops / returns empty when
/// the user is signed out, so callers can treat the backend as best-effort.
class HardwareRemoteDataSource {
  final ApiConsumer _api;
  final AuthLocalDataSource _auth;

  HardwareRemoteDataSource(this._api, this._auth);

  Future<String?> _token() => _auth.getAccessToken();

  /// POST /hardware-metrics — saves a snapshot. No-ops when signed out.
  Future<void> postSnapshot(HardwareSnapshot snapshot) async {
    final token = await _token();
    if (token == null) return;
    await _api.post(
      HardwareMetricsEndpoints.metrics,
      token: token,
      body: snapshot.toJson(),
    );
  }

  /// GET /hardware-metrics — history (newest first), optionally date-filtered.
  /// Returns an empty list when signed out.
  Future<List<HardwareSnapshot>> getHistory({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final token = await _token();
    if (token == null) return const [];
    final params = <String, dynamic>{
      if (fromDate != null) 'from_date': fromDate.toIso8601String(),
      if (toDate != null) 'to_date': toDate.toIso8601String(),
    };
    final response = await _api.get(
      HardwareMetricsEndpoints.metrics,
      token: token,
      queryParameters: params,
    );
    return (response as List<dynamic>)
        .map((e) => HardwareSnapshot.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
