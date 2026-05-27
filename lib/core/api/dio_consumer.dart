import 'dart:convert';
import 'dart:io';

import 'package:Sentri/core/api/api_consumer.dart';
import 'package:Sentri/core/constants/api_constants.dart';
import 'package:Sentri/core/constants/app_constants.dart';
import 'package:Sentri/core/errors/network_exceptions.dart';
import 'package:Sentri/core/interceptors/error_interceptor.dart';
import 'package:Sentri/core/interceptors/logging_interceptor.dart';
import 'package:Sentri/core/resources/strings_manager.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: ApiConsumer)
class DioConsumer implements ApiConsumer {
  DioConsumer(
    this._client,
    // this._authInterceptor,
    // this._refreshTokenInterceptor,
    this._errorInterceptor,
    this._loggingInterceptor,
  ) {
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


    // Add auth interceptor first (adds Bearer token to requests)
    // _client.interceptors.add(_authInterceptor);

    // Add refresh token interceptor (handles 401 errors and token refresh)
    // _client.interceptors.add(_refreshTokenInterceptor);

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
  // final AuthInterceptor _authInterceptor;
  // final RefreshTokenInterceptor _refreshTokenInterceptor;
  final ErrorInterceptor _errorInterceptor;
  final LoggingInterceptor _loggingInterceptor;

  @override
  Future get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      final Response response = await _client.get(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
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
  }) async {
    try {
      final Response response = await _client.put(
        path,
        queryParameters: queryParameters,
        data: body,
        options: Options(contentType: StringsManager.jsonContentType),
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

  dynamic _handleOnlineResponseAsJson(Response response) {
    final responseJson = jsonDecode(response.data.toString());
    return responseJson;
  }
}