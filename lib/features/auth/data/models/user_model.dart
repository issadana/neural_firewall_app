import '../../domain/entities/user.dart';

/// Data-layer [User] that knows how to (de)serialize the API/cache JSON shape.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.isAdmin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: (json['id'] as num).toInt(),
        username: json['username'] as String,
        email: json['email'] as String,
        // `is_admin` is absent from the /auth/register response — default false.
        isAdmin: json['is_admin'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'is_admin': isAdmin,
      };
}
