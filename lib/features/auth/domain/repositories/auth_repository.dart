abstract class AuthRepository {
  Future<bool> isSessionActive();
  Future<String?> getSessionEmail();
  Future<String?> getSessionUsername();
  Future<void> signIn(String email, String password);
  Future<void> signUp(String email, String username, String password);
  Future<void> signOut();
  Future<void> updateProfile({String? username, String? newPassword, String? currentPassword});
}
