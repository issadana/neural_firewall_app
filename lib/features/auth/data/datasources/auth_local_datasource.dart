import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../models/user_model.dart';

/// Persists the auth session — token pair + cached user — in encrypted,
/// platform-backed secure storage (iOS Keychain / Android EncryptedSharedPrefs).
/// A session is considered active whenever an access token is present.
///
/// Every accessor is async because secure storage I/O is async on all platforms.
@lazySingleton
class AuthLocalDataSource {
  static const _keyAccessToken = 'auth_access_token';
  static const _keyRefreshToken = 'auth_refresh_token';
  static const _keyUser = 'auth_user';

  final FlutterSecureStorage _storage;
  AuthLocalDataSource(this._storage);

  Future<bool> isSessionActive() async => (await getAccessToken()) != null;

  Future<String?> getAccessToken() => _storage.read(key: _keyAccessToken);

  Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);

  Future<UserModel?> getCachedUser() async {
    final raw = await _storage.read(key: _keyUser);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Persists a complete session after a successful login/register.
  Future<void> saveSession({
    required String accessToken,
    required String? refreshToken,
    required UserModel user,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _keyRefreshToken, value: refreshToken);
    }
    await cacheUser(user);
  }

  /// Updates just the access token (e.g. after a refresh).
  Future<void> saveAccessToken(String accessToken) =>
      _storage.write(key: _keyAccessToken, value: accessToken);

  /// Updates just the refresh token (e.g. when the backend rotates it on refresh).
  Future<void> saveRefreshToken(String refreshToken) =>
      _storage.write(key: _keyRefreshToken, value: refreshToken);

  Future<void> cacheUser(UserModel user) =>
      _storage.write(key: _keyUser, value: jsonEncode(user.toJson()));

  /// Wipes every trace of the session.
  Future<void> clear() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyUser);
  }
}
