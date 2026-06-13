import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';

class ChatStreamException implements Exception {
  final String message;
  ChatStreamException(this.message);
  @override
  String toString() => message;
}

class ChatbotRemoteDataSource {
  final Dio _dio;
  int? _lastSessionId;

  ChatbotRemoteDataSource(this._dio);

  int? get lastSessionId => _lastSessionId;

  Stream<String> streamMessage(String message, int? sessionId) async* {
    final response = await _dio.post(
      '/chat/stream',
      data: {
        'message': message,
        if (sessionId != null) 'session_id': sessionId,
      },
      options: Options(responseType: ResponseType.stream),
    );

    final byteStream = (response.data as ResponseBody).stream;
    var buffer = '';

    await for (final bytes in byteStream) {
      buffer += utf8.decode(bytes);
      final lines = buffer.split('\n');
      buffer = lines.removeLast();

      for (final line in lines) {
        if (!line.startsWith('data: ')) continue;
        final payload = jsonDecode(line.substring(6)) as Map<String, dynamic>;
        switch (payload['type'] as String?) {
          case 'session_created':
            _lastSessionId = payload['session_id'] as int?;
          case 'chunk':
            yield payload['content'] as String;
          case 'done':
            return;
          case 'error':
            throw ChatStreamException(payload['message'] as String? ?? 'Stream error');
        }
      }
    }
  }

  Future<String> getDigest() async {
    final response = await _dio.get('/chat/digest');
    return (response.data as Map<String, dynamic>)['summary'] as String? ?? '';
  }

  Future<List<ChatSession>> getSessions() async {
    final response = await _dio.get('/chat/sessions');
    return (response.data as List<dynamic>)
        .map((e) => ChatSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ChatMessage>> getSessionMessages(int sessionId) async {
    final response = await _dio.get('/chat/sessions/$sessionId/messages');
    return (response.data as List<dynamic>)
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteSession(int sessionId) async {
    await _dio.delete('/chat/sessions/$sessionId');
  }
}
