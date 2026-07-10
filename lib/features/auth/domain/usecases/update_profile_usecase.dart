import 'package:injectable/injectable.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class UpdateProfileUseCase {
  final AuthRepository _repository;
  UpdateProfileUseCase(this._repository);

  Future<User> call({String? username, String? newPassword, String? currentPassword}) =>
      _repository.updateProfile(
        username: username,
        newPassword: newPassword,
        currentPassword: currentPassword,
      );
}
