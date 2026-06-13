import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? email;
  final String? username;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.email,
    this.username,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? email,
    String? username,
    String? errorMessage,
  }) =>
      AuthState(
        status: status ?? this.status,
        email: email ?? this.email,
        username: username ?? this.username,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, email, username, errorMessage];
}
