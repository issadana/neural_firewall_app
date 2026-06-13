import '../repositories/chatbot_repository.dart';

class SendMessageUseCase {
  final ChatbotRepository _repository;
  SendMessageUseCase(this._repository);

  Stream<String> call(String message, int? sessionId) =>
      _repository.sendMessage(message, sessionId);
}
