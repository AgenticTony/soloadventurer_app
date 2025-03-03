import 'package:equatable/equatable.dart';

/// User entity representing an authenticated user
class User extends Equatable {
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

  /// Creates a new [User] instance
  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
    this.lastLoginAt,
  });

  @override
  List<Object?> get props => [id, email, username, createdAt, lastLoginAt];

  /// Creates a copy of this user with the given fields replaced with new values
  User copyWith({
    String? id,
    String? email,
    String? username,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// Creates an empty user
  factory User.empty() {
    return User(
      id: '',
      email: '',
      username: '',
      createdAt: DateTime.now(),
      lastLoginAt: null,
    );
  }

  /// Whether this user is empty (not authenticated)
  bool get isEmpty => id.isEmpty;

  /// Whether this user is not empty (authenticated)
  bool get isNotEmpty => !isEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.email == email &&
        other.username == username &&
        other.createdAt == createdAt &&
        other.lastLoginAt == lastLoginAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        username.hashCode ^
        createdAt.hashCode ^
        lastLoginAt.hashCode;
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, username: $username, createdAt: $createdAt, lastLoginAt: $lastLoginAt}';
  }
}
