import 'package:injectable/injectable.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class SignInUseCase {
  final AuthRepository _repository;
  SignInUseCase(this._repository);

  Future<User> call(String email, String password) =>
      _repository.signIn(email, password);
}
