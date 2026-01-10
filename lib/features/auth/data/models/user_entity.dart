import '../../domain/entities/user.dart';

/// Data layer representation of a User
class UserEntity {
  /// Unique identifier for the user
  final String id;

  /// User's email address
  final String email;

  /// User's username
  final String username;

  /// When the user was created
  final DateTime createdAt;

  /// When the user last logged in
  final DateTime? lastLoginAt;

  /// Creates a new [UserEntity] instance
  const UserEntity({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
    this.lastLoginAt,
  });

  /// Creates a [UserEntity] from a JSON map
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
    );
  }

  /// Converts this [UserEntity] to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  /// Converts this [UserEntity] to a domain [User]
  User toDomain() {
    return User(
      id: id,
      email: email,
      username: username,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }

  /// Creates a [UserEntity] from a domain [User]
  factory UserEntity.fromDomain(User user) {
    return UserEntity(
      id: user.id,
      email: user.email,
      username: user.username,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt,
    );
  }

  /// Creates a copy of this entity with the given fields replaced with new values
  UserEntity copyWith({
    String? id,
    String? email,
    String? username,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
