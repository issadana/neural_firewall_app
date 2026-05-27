import 'package:dio/dio.dart';

abstract class ApiConsumer {
  Future<dynamic> get(
    String path, {
    Map<String, dynamic> queryParameters,
    CancelToken? cancelToken,
  });

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    FormData? formData,
    String? token,
    Map<String, dynamic>? queryParameters,
  });
  Future<dynamic> put(String path, {Map<String, dynamic>? body});
  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    FormData? formData,
  });
  Future<dynamic> delete(String path);
}