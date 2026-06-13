import '../entities/chat_session.dart';
import '../repositories/chatbot_repository.dart';

class GetSessionsUseCase {
  final ChatbotRepository _repository;
  GetSessionsUseCase(this._repository);

  Future<List<ChatSession>> call() => _repository.getSessions();
}
