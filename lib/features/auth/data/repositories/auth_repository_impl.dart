import 'package:Sentri/core/errors/network_exceptions.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl(this._remote, this._local);

  @override
  Future<User> signUp(String email, String username, String password) async {
    final res = await _remote.register(
      username: username,
      email: email,
      password: password,
    );
    await _local.saveSession(
      accessToken: res.accessToken,
      refreshToken: res.refreshToken,
      user: res.user,
    );
    return res.user;
  }

  @override
  Future<User> signIn(String email, String password) async {
    final res = await _remote.login(email: email, password: password);
    await _local.saveSession(
      accessToken: res.accessToken,
      refreshToken: res.refreshToken,
      user: res.user,
    );
    return res.user;
  }

  @override
  Future<User?> checkSession() async {
    final accessToken = await _local.getAccessToken();
    if (accessToken == null) return null;

    try {
      // RefreshTokenInterceptor transparently refreshes an expired access token
      // and replays this call, so reaching here means the session is valid
      // (possibly after a silent refresh).
      final user = await _remote.getCurrentUser(accessToken);
      await _local.cacheUser(user);
      return user;
    } on NetworkExceptions {
      // The interceptor already had its chance to refresh. If it wiped the
      // session, the refresh token itself is dead → force re-login. Otherwise
      // the failure was transient/offline → stay signed in with cached data.
      if (await _local.getRefreshToken() == null) {
        await _local.clear();
        return null;
      }
      return await _local.getCachedUser();
    }
  }

  @override
  Future<void> signOut() async {
    final refreshToken = await _local.getRefreshToken();
    if (refreshToken != null) {
      // Best-effort revoke; the local session is cleared regardless of outcome.
      try {
        await _remote.logout(refreshToken);
      } on NetworkExceptions {
        // Ignore — signing out locally must always succeed.
      }
    }
    await _local.clear();
  }

  @override
  Future<User> updateProfile({
    String? username,
    String? newPassword,
    String? currentPassword,
  }) async {
    final accessToken = await _local.getAccessToken();
    if (accessToken == null) {
      throw const NetworkExceptions.unauthorizedRequest('Not signed in');
    }
    // Expired-token refresh is handled centrally by RefreshTokenInterceptor.
    await _remote.updateProfile(
      accessToken: accessToken,
      username: username,
      newPassword: newPassword,
      currentPassword: currentPassword,
    );
    // Re-fetch so the cache reflects the server's canonical state.
    final user = await _remote.getCurrentUser(accessToken);
    await _local.cacheUser(user);
    return user;
  }
}
