import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  final AuthRepository _repository;
  CheckAuthStatusUseCase(this._repository);

  /// Returns the current user when a valid session exists, otherwise null.
  Future<User?> call() => _repository.checkSession();
}
