import '../repositories/chatbot_repository.dart';

class DeleteSessionUseCase {
  final ChatbotRepository _repository;
  DeleteSessionUseCase(this._repository);

  Future<void> call(int sessionId) => _repository.deleteSession(sessionId);
}
