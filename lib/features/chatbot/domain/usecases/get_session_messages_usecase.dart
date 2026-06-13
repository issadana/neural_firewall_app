import '../entities/chat_message.dart';
import '../repositories/chatbot_repository.dart';

class GetSessionMessagesUseCase {
  final ChatbotRepository _repository;
  GetSessionMessagesUseCase(this._repository);

  Future<List<ChatMessage>> call(int sessionId) =>
      _repository.getSessionMessages(sessionId);
}
