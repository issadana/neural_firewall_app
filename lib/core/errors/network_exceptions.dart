import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'network_exceptions.freezed.dart';

@freezed
abstract class NetworkExceptions with _$NetworkExceptions implements Exception {
  const factory NetworkExceptions.requestCancelled() = RequestCancelled;
  
  const factory NetworkExceptions.unauthorizedRequest(String reason) = UnauthorizedRequest;
  
  const factory NetworkExceptions.badRequest(String reason) = BadRequest;
  
  const factory NetworkExceptions.notFound(String reason) = NotFound;
  
  const factory NetworkExceptions.methodNotAllowed() = MethodNotAllowed;
  
  const factory NetworkExceptions.requestTimeout() = RequestTimeout;
  
  const factory NetworkExceptions.sendTimeout() = SendTimeout;
  
  const factory NetworkExceptions.conflict() = Conflict;
  
  const factory NetworkExceptions.internalServerError() = InternalServerError;
  
  const factory NetworkExceptions.notImplemented() = NotImplemented;
  
  const factory NetworkExceptions.serviceUnavailable() = ServiceUnavailable;
  
  const factory NetworkExceptions.noInternetConnection() = NoInternetConnection;
  
  const factory NetworkExceptions.formatException() = FormatException;
  
  const factory NetworkExceptions.unableToProcess() = UnableToProcess;
  
  const factory NetworkExceptions.defaultError(String error) = DefaultError;
  
  const factory NetworkExceptions.unexpectedError() = UnexpectedError;

  static NetworkExceptions handleResponse(Response? response) {
    int statusCode = response?.statusCode ?? 0;

    switch (statusCode) {
      case 400:
        return NetworkExceptions.badRequest(_serverMessage(response, 'Bad request'));
      case 401:
        return NetworkExceptions.unauthorizedRequest(_serverMessage(response, 'Unauthorized'));
      case 404:
        return NetworkExceptions.notFound(_serverMessage(response, 'Not found'));
      case 408:
        return const NetworkExceptions.requestTimeout();
      case 409:
        return NetworkExceptions.defaultError(_serverMessage(response, 'Conflict occurred'));
      case 500:
        return const NetworkExceptions.internalServerError();
      case 503:
        return const NetworkExceptions.serviceUnavailable();
      default:
        return NetworkExceptions.defaultError(
          _serverMessage(response, 'Received invalid status code: $statusCode'),
        );
    }
  }

  /// Pulls a human-readable message out of an error response body, falling back
  /// to [fallback]. The body arrives as a raw String (ResponseType.plain), so it
  /// is decoded here; backends use either an `error` or a `message` key.
  static String _serverMessage(Response? response, String fallback) {
    final data = response?.data;
    Map<String, dynamic>? json;
    if (data is Map<String, dynamic>) {
      json = data;
    } else if (data is String && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) json = decoded;
      } catch (_) {
        // Non-JSON body — fall through to the fallback.
      }
    }
    final message = json?['error'] ?? json?['message'];
    return message is String && message.isNotEmpty ? message : fallback;
  }

  static NetworkExceptions getException(Object error) {
    if (error is Exception) {
      try {
        if (error is DioException) {
          switch (error.type) {
            case DioExceptionType.cancel:
              return const NetworkExceptions.requestCancelled();
            case DioExceptionType.connectionTimeout:
              return const NetworkExceptions.requestTimeout();
            case DioExceptionType.unknown:
              return const NetworkExceptions.noInternetConnection();
            case DioExceptionType.receiveTimeout:
              return const NetworkExceptions.sendTimeout();
            case DioExceptionType.badResponse:
              return NetworkExceptions.handleResponse(error.response);
            case DioExceptionType.sendTimeout:
              return const NetworkExceptions.sendTimeout();
            case DioExceptionType.badCertificate:
              return const NetworkExceptions.unableToProcess();
            case DioExceptionType.connectionError:
              return const NetworkExceptions.noInternetConnection();
          }
        } else {
          return const NetworkExceptions.unexpectedError();
        }
      } catch (_) {
        return const NetworkExceptions.unexpectedError();
      }
    } else {
      return const NetworkExceptions.unexpectedError();
    }
  }

  static String getErrorMessage(NetworkExceptions networkExceptions) {
    return networkExceptions.when(
      requestCancelled: () => 'Request cancelled',
      unauthorizedRequest: (reason) => reason,
      badRequest: (reason) => reason,
      notFound: (reason) => reason,
      methodNotAllowed: () => 'Method not allowed',
      requestTimeout: () => 'Connection timeout',
      sendTimeout: () => 'Send timeout',
      conflict: () => 'Conflict occurred',
      internalServerError: () => 'Internal server error',
      notImplemented: () => 'Not implemented',
      serviceUnavailable: () => 'Service unavailable',
      noInternetConnection: () => 'No internet connection',
      formatException: () => 'Format exception',
      unableToProcess: () => 'Unable to process',
      defaultError: (error) => error,
      unexpectedError: () => 'Unexpected error occurred',
    );
  }
}