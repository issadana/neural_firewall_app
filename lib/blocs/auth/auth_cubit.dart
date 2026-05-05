import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_state.dart';

const _keyEmail = 'auth_email';
const _keyPasswordHash = 'auth_password_hash';
const _keySessionActive = 'auth_session_active';

class AuthCubit extends Cubit<AuthState> {
  final SharedPreferences _prefs;

  AuthCubit(this._prefs) : super(const AuthState()) {
    checkAuthStatus();
  }

  void checkAuthStatus() {
    final active = _prefs.getBool(_keySessionActive) ?? false;
    if (active) {
      final email = _prefs.getString(_keyEmail) ?? '';
      emit(state.copyWith(status: AuthStatus.authenticated, email: email));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final storedEmail = _prefs.getString(_keyEmail);
    final storedHash = _prefs.getString(_keyPasswordHash);

    if (storedEmail == null || storedHash == null) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'No account found. Please sign up first.',
      ));
      return;
    }

    if (storedEmail != email.trim().toLowerCase()) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Incorrect email or password.',
      ));
      return;
    }

    if (storedHash != _hash(password)) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Incorrect email or password.',
      ));
      return;
    }

    await _prefs.setBool(_keySessionActive, true);
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      email: storedEmail,
    ));
  }

  Future<void> signUp(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final trimmed = email.trim().toLowerCase();
    await _prefs.setString(_keyEmail, trimmed);
    await _prefs.setString(_keyPasswordHash, _hash(password));
    await _prefs.setBool(_keySessionActive, true);

    emit(state.copyWith(
      status: AuthStatus.authenticated,
      email: trimmed,
    ));
  }

  Future<void> signOut() async {
    await _prefs.setBool(_keySessionActive, false);
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      email: null,
    ));
  }

  String _hash(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}
