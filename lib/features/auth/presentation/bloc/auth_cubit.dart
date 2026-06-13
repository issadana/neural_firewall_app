import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'auth_state.dart';

export 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  AuthCubit({
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
  })  : _checkAuthStatusUseCase = checkAuthStatusUseCase,
        _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _signOutUseCase = signOutUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        super(const AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final result = await _checkAuthStatusUseCase();
    if (result.isActive) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        email: result.email,
        username: result.username,
      ));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _signInUseCase(email, password);
      final result = await _checkAuthStatusUseCase();
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        email: result.email,
        username: result.username,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> signUp(String email, String username, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _signUpUseCase(email, username, password);
      final result = await _checkAuthStatusUseCase();
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        email: result.email,
        username: result.username,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> updateProfile({String? username, String? newPassword, String? currentPassword}) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _updateProfileUseCase(
        username: username,
        newPassword: newPassword,
        currentPassword: currentPassword,
      );
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        username: username ?? state.username,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> signOut() async {
    await _signOutUseCase();
    emit(state.copyWith(status: AuthStatus.unauthenticated, email: null));
  }
}
