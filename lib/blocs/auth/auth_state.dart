part of 'auth_cubit.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? email;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.email,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? email,
    String? errorMessage,
  }) =>
      AuthState(
        status: status ?? this.status,
        email: email ?? this.email,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, email, errorMessage];
}
