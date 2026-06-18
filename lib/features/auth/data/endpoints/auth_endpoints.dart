/// Endpoint paths for the authentication feature.
///
/// Kept separate from the core [Endpoints] class so auth-related routes live
/// next to the code that consumes them (see lib/core/api/endpoints.dart).
class AuthEndpoints {
  AuthEndpoints._();

  /// POST — register a new account. Returns tokens + user.
  static const String register = '/auth/register';

  /// POST — exchange credentials for tokens + user.
  static const String login = '/auth/login';

  /// GET — current user profile. Requires `Authorization: Bearer <access>`.
  static const String me = '/auth/me';

  /// POST — mint a fresh access token. Requires `Authorization: Bearer <refresh>`.
  static const String refresh = '/auth/refresh';

  /// POST — revoke the refresh token. Requires `Authorization: Bearer <refresh>`.
  static const String logout = '/auth/logout';

  /// PUT — update the signed-in user's profile.
  static const String updateProfile = '/users/me';
}
