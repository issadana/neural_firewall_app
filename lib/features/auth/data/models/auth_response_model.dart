import 'user_model.dart';

/// Parsed payload of the `/auth/register` and `/auth/login` responses:
/// the freshly minted token pair plus the authenticated user.
class AuthResponseModel {
  final String accessToken;
  final String? refreshToken;
  final UserModel user;

  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) => AuthResponseModel(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String?,
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      );
}
