import 'package:equatable/equatable.dart';

/// The authenticated account, as the rest of the app sees it.
class User extends Equatable {
  final int id;
  final String username;
  final String email;
  final bool isAdmin;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.isAdmin = false,
  });

  User copyWith({int? id, String? username, String? email, bool? isAdmin}) => User(
        id: id ?? this.id,
        username: username ?? this.username,
        email: email ?? this.email,
        isAdmin: isAdmin ?? this.isAdmin,
      );

  @override
  List<Object?> get props => [id, username, email, isAdmin];
}
