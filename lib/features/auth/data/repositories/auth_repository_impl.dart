import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _dataSource;
  AuthRepositoryImpl(this._dataSource);

  @override
  Future<bool> isSessionActive() async => _dataSource.isSessionActive();

  @override
  Future<String?> getSessionEmail() async => _dataSource.getSessionEmail();

  @override
  Future<String?> getSessionUsername() async => _dataSource.getSessionUsername();

  @override
  Future<void> signIn(String email, String password) =>
      _dataSource.signIn(email, password);

  @override
  Future<void> signUp(String email, String username, String password) =>
      _dataSource.signUp(email, username, password);

  @override
  Future<void> signOut() => _dataSource.signOut();

  @override
  Future<void> updateProfile({String? username, String? newPassword, String? currentPassword}) =>
      _dataSource.updateProfile(
        username: username,
        newPassword: newPassword,
        currentPassword: currentPassword,
      );
}
