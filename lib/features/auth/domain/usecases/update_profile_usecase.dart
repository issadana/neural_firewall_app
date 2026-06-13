import '../repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository _repository;
  UpdateProfileUseCase(this._repository);

  Future<void> call({String? username, String? newPassword, String? currentPassword}) =>
      _repository.updateProfile(
        username: username,
        newPassword: newPassword,
        currentPassword: currentPassword,
      );
}
