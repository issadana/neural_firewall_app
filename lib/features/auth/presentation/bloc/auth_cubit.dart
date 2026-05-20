import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import 'auth_state.dart';

export 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;

  AuthCubit({
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
  })  : _checkAuthStatusUseCase = checkAuthStatusUseCase,
        _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _signOutUseCase = signOutUseCase,
        super(const AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final result = await _checkAuthStatusUseCase();
    if (result.isActive) {
      emit(state.copyWith(status: AuthStatus.authenticated, email: result.email));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _signInUseCase(email, password);
      final result = await _checkAuthStatusUseCase();
      emit(state.copyWith(status: AuthStatus.authenticated, email: result.email));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> signUp(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _signUpUseCase(email, password);
      final result = await _checkAuthStatusUseCase();
      emit(state.copyWith(status: AuthStatus.authenticated, email: result.email));
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
