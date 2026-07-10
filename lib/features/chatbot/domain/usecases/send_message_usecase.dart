import 'package:injectable/injectable.dart';
import '../repositories/chatbot_repository.dart';

@injectable
class SendMessageUseCase {
  final ChatbotRepository _repository;
  SendMessageUseCase(this._repository);

  Stream<String> call(String message) => _repository.sendMessage(message);
}
