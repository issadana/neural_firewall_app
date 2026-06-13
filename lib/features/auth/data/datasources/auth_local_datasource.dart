import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  static const _keyEmail = 'auth_email';
  static const _keyUsername = 'auth_username';
  static const _keyPasswordHash = 'auth_password_hash';
  static const _keySessionActive = 'auth_session_active';

  final SharedPreferences _prefs;
  AuthLocalDataSource(this._prefs);

  bool isSessionActive() => _prefs.getBool(_keySessionActive) ?? false;

  String? getSessionEmail() => _prefs.getString(_keyEmail);

  String? getSessionUsername() => _prefs.getString(_keyUsername);

  Future<void> signIn(String email, String password) async {
    final storedEmail = _prefs.getString(_keyEmail);
    final storedHash = _prefs.getString(_keyPasswordHash);

    if (storedEmail == null || storedHash == null) {
      throw Exception('No account found. Please sign up first.');
    }
    if (storedEmail != email.trim().toLowerCase()) {
      throw Exception('Incorrect email or password.');
    }
    if (storedHash != _hash(password)) {
      throw Exception('Incorrect email or password.');
    }
    await _prefs.setBool(_keySessionActive, true);
  }

  Future<void> signUp(String email, String username, String password) async {
    final trimmed = email.trim().toLowerCase();
    await _prefs.setString(_keyEmail, trimmed);
    await _prefs.setString(_keyUsername, username.trim());
    await _prefs.setString(_keyPasswordHash, _hash(password));
    await _prefs.setBool(_keySessionActive, true);
  }

  Future<void> signOut() => _prefs.setBool(_keySessionActive, false);

  Future<void> updateProfile({String? username, String? newPassword, String? currentPassword}) async {
    if (newPassword != null) {
      final storedHash = _prefs.getString(_keyPasswordHash);
      if (currentPassword == null || _hash(currentPassword) != storedHash) {
        throw Exception('Current password is incorrect.');
      }
      await _prefs.setString(_keyPasswordHash, _hash(newPassword));
    }
    if (username != null) {
      await _prefs.setString(_keyUsername, username.trim());
    }
  }

  String _hash(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}
