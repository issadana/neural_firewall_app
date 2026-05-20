import '../repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  final AuthRepository _repository;
  CheckAuthStatusUseCase(this._repository);

  Future<({bool isActive, String? email})> call() async {
    final isActive = await _repository.isSessionActive();
    final email = isActive ? await _repository.getSessionEmail() : null;
    return (isActive: isActive, email: email);
  }
}
