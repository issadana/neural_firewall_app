import 'package:Sentri/core/api/api_consumer.dart';

class AuthRemoteDataSource {
  final ApiConsumer _api;
  AuthRemoteDataSource(this._api);

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final response = await _api.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> signUp(String email, String username, String password) async {
    final response = await _api.post(
      '/auth/register',
      body: {'email': email, 'username': username, 'password': password},
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> refreshToken(String token) async {
    final response = await _api.post(
      '/auth/refresh',
      body: {'refresh_token': token},
    );
    return response as Map<String, dynamic>;
  }

  Future<void> updateProfile({
    String? username,
    String? newPassword,
    String? currentPassword,
  }) async {
    await _api.put(
      '/users/me',
      body: {
        if (username != null) 'username': username,
        if (newPassword != null) 'new_password': newPassword,
        if (currentPassword != null) 'current_password': currentPassword,
      },
    );
  }
}
