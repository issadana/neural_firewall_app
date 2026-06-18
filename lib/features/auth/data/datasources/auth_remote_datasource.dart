import 'package:Sentri/core/api/api_consumer.dart';

import '../endpoints/auth_endpoints.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

/// Thin wrapper over the auth HTTP endpoints. Every method speaks raw JSON in
/// and typed models out; token storage and orchestration live in the repository.
class AuthRemoteDataSource {
  final ApiConsumer _api;
  AuthRemoteDataSource(this._api);

  /// POST /auth/register
  Future<AuthResponseModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _api.post(
      AuthEndpoints.register,
      body: {'username': username, 'email': email, 'password': password},
    );
    return AuthResponseModel.fromJson(response as Map<String, dynamic>);
  }

  /// POST /auth/login
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post(
      AuthEndpoints.login,
      body: {'email': email, 'password': password},
    );
    return AuthResponseModel.fromJson(response as Map<String, dynamic>);
  }

  /// GET /auth/me — needs the access token.
  Future<UserModel> getCurrentUser(String accessToken) async {
    final response = await _api.get(AuthEndpoints.me, token: accessToken);
    return UserModel.fromJson(response as Map<String, dynamic>);
  }

  /// POST /auth/refresh — needs the refresh token, returns a new access token.
  Future<String> refreshToken(String refreshToken) async {
    final response = await _api.post(AuthEndpoints.refresh, token: refreshToken);
    return (response as Map<String, dynamic>)['access_token'] as String;
  }

  /// POST /auth/logout — needs the refresh token. Server replies 204 No Content.
  Future<void> logout(String refreshToken) async {
    await _api.post(AuthEndpoints.logout, token: refreshToken);
  }

  /// PUT /users/me — update profile, authenticated with the access token.
  Future<void> updateProfile({
    required String accessToken,
    String? username,
    String? newPassword,
    String? currentPassword,
  }) async {
    await _api.put(
      AuthEndpoints.updateProfile,
      token: accessToken,
      body: {
        if (username != null) 'username': username,
        if (newPassword != null) 'new_password': newPassword,
        if (currentPassword != null) 'current_password': currentPassword,
      },
    );
  }
}
