import 'dart:convert';
import 'dart:io';

import 'package:Sentri/core/api/api_consumer.dart';
import 'package:Sentri/core/constants/api_constants.dart';
import 'package:Sentri/core/constants/app_constants.dart';
import 'package:Sentri/core/errors/network_exceptions.dart';
import 'package:Sentri/core/interceptors/error_interceptor.dart';
import 'package:Sentri/core/interceptors/logging_interceptor.dart';
import 'package:Sentri/core/interceptors/refresh_token_interceptor.dart';
import 'package:Sentri/core/resources/strings_manager.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: ApiConsumer)
class DioConsumer implements ApiConsumer {
  DioConsumer(
    this._client,
    this._errorInterceptor,
    this._loggingInterceptor, {
    RefreshTokenInterceptor? refreshTokenInterceptor,
  }) {
    _client.options
      ..sendTimeout = AppConstants.sendTimeout
      ..connectTimeout = AppConstants.connectTimeout
      ..receiveTimeout = AppConstants.receiveTimeout
      ..baseUrl = ApiConstants.baseUrl
      ..responseType = ResponseType.plain
      ..followRedirects = true
      ..headers = {
        StringsManager.accept: StringsManager.applicationJson,
        StringsManager.contentType: StringsManager.applicationJson,
      };


    // Refresh interceptor runs first so an expired-token 401 is transparently
    // retried before the error interceptor turns it into a NetworkException.
    if (refreshTokenInterceptor != null) {
      _client.interceptors.add(refreshTokenInterceptor);
    }

    // Add error interceptor (transforms errors to NetworkExceptions)
    _client.interceptors.add(_errorInterceptor);

    // Add logging interceptor only in debug mode
    if (kDebugMode) {
      _client.interceptors.add(_loggingInterceptor);
    }

    // Only bypass certificates in debug mode
    if (kDebugMode && !kIsWeb) {
      (_client.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
            client.badCertificateCallback =
                (X509Certificate cert, String host, int port) => true;
            return client;
          };
    }
  }

  final Dio _client;
  final ErrorInterceptor _errorInterceptor;
  final LoggingInterceptor _loggingInterceptor;

  @override
  Future get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    String? token,
  }) async {
    try {
      final Response response = await _client.get(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: _authOptions(token),
      );
      return _handleOnlineResponseAsJson(response);
    } catch (error) {
      throw NetworkExceptions.getException(error);
    }
  }

  @override
  Future post(
    String path, {
    Map<String, dynamic>? body,
    String? token,
    FormData? formData,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Response response = await _client.post(
        path,
        queryParameters: queryParameters,
        options: Options(
          contentType: formData == null ? StringsManager.jsonContentType : null,
          headers: _authHeaders(token),
        ),
        data: formData ?? body,
      );
      return _handleOnlineResponseAsJson(response);
    } catch (error) {
      throw NetworkExceptions.getException(error);
    }
  }

  @override
  Future put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      final Response response = await _client.put(
        path,
        queryParameters: queryParameters,
        data: body,
        options: Options(
          contentType: StringsManager.jsonContentType,
          headers: _authHeaders(token),
        ),
      );
      return _handleOnlineResponseAsJson(response);
    } catch (error) {
      throw NetworkExceptions.getException(error);
    }
  }

  @override
  Future patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    FormData? formData,
  }) async {
    try {
      final Response response = await _client.patch(
        path,
        queryParameters: queryParameters,
        data: formData ?? body,
        options: Options(
          contentType: formData != null ? null : StringsManager.jsonContentType,
        ),
      );
      return _handleOnlineResponseAsJson(response);
    } catch (error) {
      throw NetworkExceptions.getException(error);
    }
  }

  @override
  Future delete(String path) async {
    try {
      // Use standard delete method - AuthInterceptor will remove Content-Type header
      final Response response = await _client.delete(path);
      // Handle empty response body (204 No Content or empty 200 OK)
      if (response.data == null || response.data.toString().isEmpty) {
        return null;
      }
      return _handleOnlineResponseAsJson(response);
    } catch (error) {
      throw NetworkExceptions.getException(error);
    }
  }

  /// Builds an Authorization header map for the given bearer [token], or null
  /// when no token is supplied (so non-authenticated requests are untouched).
  Map<String, dynamic>? _authHeaders(String? token) => token == null
      ? null
      : {StringsManager.authorization: '${StringsManager.bearer}$token'};

  /// Convenience wrapper that returns request [Options] carrying the bearer
  /// token, or null when there is no token to attach.
  Options? _authOptions(String? token) {
    final headers = _authHeaders(token);
    return headers == null ? null : Options(headers: headers);
  }

  dynamic _handleOnlineResponseAsJson(Response response) {
    // Empty body (e.g. 204 No Content from logout) — nothing to decode.
    final raw = response.data?.toString() ?? '';
    if (raw.isEmpty) return null;
    return jsonDecode(raw);
  }
}