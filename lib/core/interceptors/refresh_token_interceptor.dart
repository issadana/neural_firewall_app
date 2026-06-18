import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import 'package:Sentri/core/resources/strings_manager.dart';
import 'package:Sentri/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:Sentri/features/auth/data/endpoints/auth_endpoints.dart';

/// Centralised access-token refresh. When any authenticated request comes back
/// `401`, this interceptor mints a fresh access token from the stored refresh
/// token, replays the original request with it, and resolves the call as if the
/// expiry never happened — so every endpoint gets transparent refresh for free.
///
/// Design notes:
/// - A dedicated [_tokenDio] (no interceptors) performs the refresh call, so the
///   refresh itself can never recurse back into this interceptor.
/// - A single in-flight [_inFlightRefresh] future coalesces concurrent 401s into
///   one refresh, instead of firing N parallel refreshes.
/// - `extra['retried']` on the request guards against an infinite retry loop if
///   the replayed request also 401s.
/// - Auth-flow endpoints (login/register/refresh/logout) are skipped: a 401
///   there is a real credential/token error, not an expiry to paper over.
class RefreshTokenInterceptor extends Interceptor {
  RefreshTokenInterceptor({
    required Dio dio,
    required AuthLocalDataSource local,
  }) : _dio = dio,
       _local = local {
    _tokenDio = Dio(
      BaseOptions(
        baseUrl: dio.options.baseUrl,
        connectTimeout: dio.options.connectTimeout,
        receiveTimeout: dio.options.receiveTimeout,
        sendTimeout: dio.options.sendTimeout,
      ),
    );
    // Mirror the main client's debug-only self-signed-cert bypass so refreshing
    // against the local HTTPS dev server works.
    if (kDebugMode && !kIsWeb) {
      (_tokenDio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
            client.badCertificateCallback =
                (X509Certificate cert, String host, int port) => true;
            return client;
          };
    }
  }

  final Dio _dio;
  final AuthLocalDataSource _local;
  late final Dio _tokenDio;

  /// Shared across concurrent 401s so only one refresh runs at a time.
  Future<String?>? _inFlightRefresh;

  static const _retriedFlag = 'retried';

  bool _isAuthFlow(String path) =>
      path.contains(AuthEndpoints.login) ||
      path.contains(AuthEndpoints.register) ||
      path.contains(AuthEndpoints.refresh) ||
      path.contains(AuthEndpoints.logout);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final shouldRefresh =
        err.response?.statusCode == 401 &&
        !_isAuthFlow(request.path) &&
        request.extra[_retriedFlag] != true;

    if (!shouldRefresh) {
      return handler.next(err);
    }

    final newAccessToken = await _refreshAccessToken();
    if (newAccessToken == null) {
      // Refresh impossible/failed → session is dead; let the 401 propagate.
      return handler.next(err);
    }

    try {
      request.extra[_retriedFlag] = true;
      request.headers[StringsManager.authorization] =
          '${StringsManager.bearer}$newAccessToken';
      final response = await _dio.fetch(request);
      return handler.resolve(response);
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }

  /// Returns a fresh access token, coalescing concurrent callers onto a single
  /// refresh. Clears the session and returns null when refresh is not possible.
  Future<String?> _refreshAccessToken() {
    return _inFlightRefresh ??= _performRefresh().whenComplete(
      () => _inFlightRefresh = null,
    );
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await _local.getRefreshToken();
    if (refreshToken == null) {
      await _local.clear();
      return null;
    }
    try {
      final response = await _tokenDio.post(
        AuthEndpoints.refresh,
        options: Options(
          headers: {
            StringsManager.authorization:
                '${StringsManager.bearer}$refreshToken',
          },
        ),
      );
      final data = response.data;
      final map = data is String
          ? jsonDecode(data) as Map<String, dynamic>
          : data as Map<String, dynamic>;
      final newAccess = map['access_token'] as String;
      await _local.saveAccessToken(newAccess);
      return newAccess;
    } catch (_) {
      // Refresh token rejected/expired → wipe the session.
      await _local.clear();
      return null;
    }
  }
}
