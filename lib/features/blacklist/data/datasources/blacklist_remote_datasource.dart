import 'package:Sentri/core/api/api_consumer.dart';

class BlacklistRemoteDataSource {
  final ApiConsumer _api;
  BlacklistRemoteDataSource(this._api);

  Future<List<dynamic>> getBlacklist() async {
    final response = await _api.get('/blacklist');
    return response as List<dynamic>;
  }

  Future<Map<String, dynamic>> addToBlacklist(String ip, {String? reason, String? notes}) async {
    final response = await _api.post(
      '/blacklist',
      body: {
        'ip': ip,
        if (reason != null) 'reason': reason,
        if (notes != null) 'notes': notes,
      },
    );
    return response as Map<String, dynamic>;
  }

  Future<void> removeFromBlacklist(int id) async {
    await _api.delete('/blacklist/$id');
  }
}
