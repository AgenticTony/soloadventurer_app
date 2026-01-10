import 'package:soloadventurer/features/auth/data/models/user_model.dart';

/// Model representing an authentication response from the API
class AuthResponseModel {
  /// The authenticated user
  final UserModel user;

  /// The access token for API requests
  final String accessToken;

  /// The refresh token for getting new access tokens
  final String refreshToken;

  /// When the access token expires
  final DateTime expiresAt;

  /// Creates a new [AuthResponseModel]
  const AuthResponseModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  /// Creates an [AuthResponseModel] from JSON map
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  /// Converts this [AuthResponseModel] to JSON map
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.toIso8601String(),
    };
  }
}
