import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  static const _keyEmail = 'auth_email';
  static const _keyPasswordHash = 'auth_password_hash';
  static const _keySessionActive = 'auth_session_active';

  final SharedPreferences _prefs;
  AuthLocalDataSource(this._prefs);

  bool isSessionActive() => _prefs.getBool(_keySessionActive) ?? false;

  String? getSessionEmail() => _prefs.getString(_keyEmail);

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

  Future<void> signUp(String email, String password) async {
    final trimmed = email.trim().toLowerCase();
    await _prefs.setString(_keyEmail, trimmed);
    await _prefs.setString(_keyPasswordHash, _hash(password));
    await _prefs.setBool(_keySessionActive, true);
  }

  Future<void> signOut() => _prefs.setBool(_keySessionActive, false);

  String _hash(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}
