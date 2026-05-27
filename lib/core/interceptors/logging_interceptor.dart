import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@singleton
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logPrint('*** Api Error - Start ***:');

    _logPrint('URI: ${err.requestOptions.uri}');
    if (err.response != null) {
      _logPrint('STATUS CODE: ${err.response?.statusCode?.toString()}');
    }
    _logPrint('$err');
    if (err.response != null) {
      _logPrint('ERROR BODY:');
      _printError(err.response?.data ?? '{}');
    }

    _logPrint('*** Api Error - End ***:');
    super.onError(err, handler);
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    _logPrint('*** API Request - Start ***');

    _printKV('URI', options.uri);
    _printKV('METHOD', options.method);
    _logPrint('HEADERS:');
    options.headers.forEach((String key, v) => _printKV(' - $key', v));
    _logPrint('REQUEST BODY:');
    _printRequest(options.data ?? '{}');

    _logPrint('*** API Request - End ***');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    _logPrint('*** Api Response - Start ***');

    _printKV('URI', response.realUri);
    _printKV('STATUS CODE', response.statusCode);
    _printKV('REDIRECT', response.isRedirect);
    _logPrint('RESPONSE BODY:');
    _printResponse(response.data ?? '{}');

    _logPrint('*** Api Response - End ***');
    super.onResponse(response, handler);
  }

  void _printKV(String key, v) {
    _logPrint('$key: $v');
  }

  void _printResponse(msg) {
    final object = json.decode(msg.toString());
    final String prettyString =
        const JsonEncoder.withIndent('  ').convert(object);
    if (kDebugMode) {
      print(prettyString);
    }
  }

  void _printError(msg) {
    final object = json.decode(msg.toString());
    final String prettyString =
        const JsonEncoder.withIndent('  ').convert(object);
    if (kDebugMode) {
      print(prettyString);
    }
  }

  void _printRequest(msg) {
    if (msg is FormData) {
      print(msg.fields);
      return;
    }
    
    if (msg == null || msg == '' || msg == '{}') {
      if (kDebugMode) {
        print('{}');
      }
      return;
    }
    
    try {
      String prettyString;
      if (msg is Map || msg is List) {
        prettyString = const JsonEncoder.withIndent('  ').convert(msg);
      } else if (msg is String) {
        // Try to parse as JSON first
        try {
          final decoded = json.decode(msg);
          prettyString = const JsonEncoder.withIndent('  ').convert(decoded);
        } catch (_) {
          // If not valid JSON, print as-is
          prettyString = msg;
        }
      } else {
        prettyString = msg.toString();
      }
      
      if (kDebugMode) {
        print(prettyString);
      }
    } catch (e) {
      if (kDebugMode) {
        print(msg.toString());
      }
    }
  }

  void _logPrint(String content) {
    if (kDebugMode) {
      print(content);
    }
  }
}
