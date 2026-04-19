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
        return NetworkExceptions.badRequest(response?.data['message'] ?? 'Bad request');
      case 401:
        return NetworkExceptions.unauthorizedRequest(response?.data['message'] ?? 'Unauthorized');
      case 404:
        return NetworkExceptions.notFound(response?.data['message'] ?? 'Not found');
      case 408:
        return const NetworkExceptions.requestTimeout();
      case 409:
        return const NetworkExceptions.conflict();
      case 500:
        return const NetworkExceptions.internalServerError();
      case 503:
        return const NetworkExceptions.serviceUnavailable();
      default:
        return NetworkExceptions.defaultError('Received invalid status code: $statusCode');
    }
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