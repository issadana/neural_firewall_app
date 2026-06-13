import '../repositories/chatbot_repository.dart';

class GetDigestUseCase {
  final ChatbotRepository _repository;
  GetDigestUseCase(this._repository);

  Future<String> call() => _repository.getDigest();
}
