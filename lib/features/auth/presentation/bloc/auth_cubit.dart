import 'package:Sentri/core/errors/network_exceptions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
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
  }) : _checkAuthStatusUseCase = checkAuthStatusUseCase,
       _signInUseCase = signInUseCase,
       _signUpUseCase = signUpUseCase,
       _signOutUseCase = signOutUseCase,
       _updateProfileUseCase = updateProfileUseCase,
       super(const AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final user = await _checkAuthStatusUseCase();
    if (user != null) {
      emit(_authenticated(user));
    } else {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _signInUseCase(email, password);
      emit(_authenticated(user));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: _message(e)));
    }
  }

  Future<void> signUp(String email, String username, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _signUpUseCase(email, username, password);
      emit(_authenticated(user));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: _message(e)));
    }
  }

  Future<void> updateProfile({
    String? username,
    String? newPassword,
    String? currentPassword,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _updateProfileUseCase(
        username: username,
        newPassword: newPassword,
        currentPassword: currentPassword,
      );
      emit(_authenticated(user));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: _message(e)));
    }
  }

  Future<void> signOut() async {
    await _signOutUseCase();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  /// The refresh token is dead and the interceptor already wiped the session —
  /// drop to unauthenticated so the navigation gate routes back to sign-in.
  /// Idempotent: safe to call for each in-flight request that 401s at once.
  void onSessionExpired() {
    if (state.status == AuthStatus.unauthenticated) return;
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  AuthState _authenticated(User user) => AuthState(
    status: AuthStatus.authenticated,
    userId: user.id,
    email: user.email,
    username: user.username,
    isAdmin: user.isAdmin,
  );

  /// Maps thrown errors to a user-facing message, unwrapping [NetworkExceptions].
  String _message(Object error) {
    if (error is NetworkExceptions) {
      return NetworkExceptions.getErrorMessage(error);
    }
    return error.toString().replaceFirst('Exception: ', '');
  }
}
