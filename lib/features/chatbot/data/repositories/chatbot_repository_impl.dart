import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../datasources/chatbot_remote_datasource.dart';

class ChatbotRepositoryImpl implements ChatbotRepository {
  final ChatbotRemoteDataSource _dataSource;
  ChatbotRepositoryImpl(this._dataSource);

  @override
  Stream<String> sendMessage(String message, int? sessionId) =>
      _dataSource.streamMessage(message, sessionId);

  @override
  Future<String> getDigest() => _dataSource.getDigest();

  @override
  Future<List<ChatSession>> getSessions() => _dataSource.getSessions();

  @override
  Future<List<ChatMessage>> getSessionMessages(int sessionId) =>
      _dataSource.getSessionMessages(sessionId);

  @override
  Future<void> deleteSession(int sessionId) => _dataSource.deleteSession(sessionId);
}
