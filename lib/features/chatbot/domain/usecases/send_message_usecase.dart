import '../repositories/chatbot_repository.dart';

class SendMessageUseCase {
  final ChatbotRepository _repository;
  SendMessageUseCase(this._repository);

  Stream<String> call(String message) => _repository.sendMessage(message);
}
