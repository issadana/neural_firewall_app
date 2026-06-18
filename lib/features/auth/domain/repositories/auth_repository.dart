import '../entities/user.dart';

abstract class AuthRepository {
  /// Registers a new account, persists the session, returns the user.
  Future<User> signUp(String email, String username, String password);

  /// Authenticates, persists the session, returns the user.
  Future<User> signIn(String email, String password);

  /// Validates the stored session against `/auth/me` (refreshing the access
  /// token once if it has expired). Returns the current user, or null when
  /// there is no usable session. Falls back to the cached user when offline.
  Future<User?> checkSession();

  /// Revokes the refresh token server-side and clears the local session.
  Future<void> signOut();

  /// Updates the signed-in user's profile and returns the refreshed user.
  Future<User> updateProfile({
    String? username,
    String? newPassword,
    String? currentPassword,
  });
}
