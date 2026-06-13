import '../entities/chat_message.dart';
import '../entities/chat_session.dart';

abstract class ChatbotRepository {
  Stream<String> sendMessage(String message, int? sessionId);
  Future<String> getDigest();
  Future<List<ChatSession>> getSessions();
  Future<List<ChatMessage>> getSessionMessages(int sessionId);
  Future<void> deleteSession(int sessionId);
}
