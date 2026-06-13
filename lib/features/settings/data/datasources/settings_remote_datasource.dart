import 'package:Sentri/core/api/api_consumer.dart';

class SettingsRemoteDataSource {
  final ApiConsumer _api;
  SettingsRemoteDataSource(this._api);

  Future<Map<String, dynamic>> getSettings() async {
    final response = await _api.get('/settings');
    return response as Map<String, dynamic>;
  }

  Future<void> updateSettings(Map<String, dynamic> fields) async {
    await _api.put('/settings', body: fields);
  }
}
