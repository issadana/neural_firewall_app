import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repository;
  SignUpUseCase(this._repository);

  Future<User> call(String email, String username, String password) =>
      _repository.signUp(email, username, password);
}
