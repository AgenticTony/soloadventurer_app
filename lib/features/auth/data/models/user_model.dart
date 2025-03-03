import 'package:soloadventurer/features/auth/domain/entities/user.dart';

/// Data layer representation of [User] entity
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.username,
    required super.createdAt,
    super.lastLoginAt,
  });

  /// Creates a [UserModel] from JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
    );
  }

  /// Converts this [UserModel] to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  /// Creates a [UserModel] from a [User] entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      username: user.username,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt,
    );
  }
}
