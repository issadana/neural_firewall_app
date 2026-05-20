abstract class AuthRepository {
  Future<bool> isSessionActive();
  Future<String?> getSessionEmail();
  Future<void> signIn(String email, String password);
  Future<void> signUp(String email, String password);
  Future<void> signOut();
}
