import 'package:dio/dio.dart';

abstract class ApiConsumer {
  Future<dynamic> get(
    String path, {
    Map<String, dynamic> queryParameters,
    CancelToken? cancelToken,
    String? token,
  });

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    FormData? formData,
    String? token,
    Map<String, dynamic>? queryParameters,
  });
  Future<dynamic> put(String path, {Map<String, dynamic>? body, String? token});
  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    FormData? formData,
  });
  Future<dynamic> delete(String path, {String? token});
}