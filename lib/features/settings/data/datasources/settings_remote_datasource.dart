import 'package:Sentri/core/api/api_consumer.dart';

import '../endpoints/settings_endpoints.dart';

/// Thin wrapper over the `/settings` endpoints. Both calls are authenticated;
/// the access token is supplied by the repository.
class SettingsRemoteDataSource {
  final ApiConsumer _api;
  SettingsRemoteDataSource(this._api);

  /// GET /settings — the user's security & firewall settings.
  Future<Map<String, dynamic>> getSettings(String accessToken) async {
    final response = await _api.get(
      SettingsEndpoints.settings,
      token: accessToken,
    );
    return response as Map<String, dynamic>;
  }

  /// PUT /settings — partial update; only the supplied [fields] are changed.
  Future<void> updateSettings(
    Map<String, dynamic> fields,
    String accessToken,
  ) async {
    await _api.put(
      SettingsEndpoints.settings,
      body: fields,
      token: accessToken,
    );
  }
}
