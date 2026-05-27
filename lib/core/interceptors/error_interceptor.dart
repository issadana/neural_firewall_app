import 'package:Sentri/core/errors/network_exceptions.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Interceptor to handle and transform API errors
/// NOTE: 401 errors are handled by RefreshTokenInterceptor
/// This interceptor transforms errors to NetworkExceptions for consistent error handling
@singleton
class ErrorInterceptor extends Interceptor {
  ErrorInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final networkException = NetworkExceptions.getException(err);

    // Transform DioException to NetworkExceptions for consistent error handling
    final transformedError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: networkException,
      stackTrace: err.stackTrace,
    );

    super.onError(transformedError, handler);
  }
}
