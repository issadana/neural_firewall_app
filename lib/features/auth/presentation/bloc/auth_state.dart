import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final int? userId;
  final String? email;
  final String? username;
  final bool isAdmin;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.email,
    this.username,
    this.isAdmin = false,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    int? userId,
    String? email,
    String? username,
    bool? isAdmin,
    String? errorMessage,
  }) =>
      AuthState(
        status: status ?? this.status,
        userId: userId ?? this.userId,
        email: email ?? this.email,
        username: username ?? this.username,
        isAdmin: isAdmin ?? this.isAdmin,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, userId, email, username, isAdmin, errorMessage];
}
