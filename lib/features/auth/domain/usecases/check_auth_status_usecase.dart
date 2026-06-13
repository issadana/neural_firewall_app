import '../repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  final AuthRepository _repository;
  CheckAuthStatusUseCase(this._repository);

  Future<({bool isActive, String? email, String? username})> call() async {
    final isActive = await _repository.isSessionActive();
    final email = isActive ? await _repository.getSessionEmail() : null;
    final username = isActive ? await _repository.getSessionUsername() : null;
    return (isActive: isActive, email: email, username: username);
  }
}
