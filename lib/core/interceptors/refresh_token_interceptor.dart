import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:Sentri/core/interceptors/logging_interceptor.dart';
import 'package:Sentri/core/resources/strings_manager.dart';
import 'package:Sentri/core/session/session_event_bus.dart';
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
@lazySingleton
class RefreshTokenInterceptor extends Interceptor {
  RefreshTokenInterceptor({
    @Named('apiDio') required Dio dio,
    required AuthLocalDataSource local,
    required SessionEventBus bus,
  }) : _dio = dio,
       _local = local,
       _bus = bus {
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
    // Log the refresh round-trip too — otherwise an expired-token refresh is
    // invisible in the console (it doesn't go through the main client's
    // interceptors), making it look like no refresh was ever attempted.
    if (kDebugMode) {
      _tokenDio.interceptors.add(LoggingInterceptor());
    }
  }

  final Dio _dio;
  final AuthLocalDataSource _local;
  late final Dio _tokenDio;

  /// Notified right after the session is wiped because the refresh token is
  /// dead. Listeners (the AuthCubit, the log WebSocket) drive the UI back to
  /// sign-in and tear down authed connections — without this interceptor ever
  /// holding a direct reference to them.
  final SessionEventBus _bus;

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
      // Refresh didn't yield a token. Either the refresh token is dead (session
      // already cleared) or it was a transient failure (session left intact) —
      // let the original 401 propagate; callers decide based on session state.
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

  /// Wipes the session and notifies the app that it's dead, so the UI can drop
  /// back to sign-in instead of looping on 401s with tokens already gone.
  Future<void> _clearSession() async {
    await _local.clear();
    _bus.notifyExpired();
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await _local.getRefreshToken();
    if (refreshToken == null) {
      await _clearSession();
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
      // Some backends rotate the refresh token on every use; persist the new one
      // so the next expiry doesn't fail against a now-invalidated token.
      final newRefresh = map['refresh_token'];
      if (newRefresh is String) {
        await _local.saveRefreshToken(newRefresh);
      }
      return newAccess;
    } on DioException catch (e) {
      // Only a genuine rejection (the server answered with an auth error) means
      // the refresh token is dead — wipe the session so the app re-logs in.
      // Transient/network failures (timeout, no response) must NOT log the user
      // out: leave the session intact and just fail this refresh round.
      final status = e.response?.statusCode;
      if (status == 401 || status == 403 || status == 422) {
        await _clearSession();
      }
      return null;
    } catch (_) {
      // Unexpected (e.g. a malformed body) — fail safe without nuking the session.
      return null;
    }
  }
}
