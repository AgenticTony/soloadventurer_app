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

  /// The access token for AWS resources
  final String? accessToken;

  /// The ID token containing user claims
  final String? idToken;

  /// The refresh token for getting new access/ID tokens
  final String? refreshToken;

  /// When the tokens expire
  final DateTime? tokenExpiresAt;

  /// Creates a new [User] instance
  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
    this.lastLoginAt,
    this.accessToken,
    this.idToken,
    this.refreshToken,
    this.tokenExpiresAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        createdAt,
        lastLoginAt,
        accessToken,
        idToken,
        refreshToken,
        tokenExpiresAt,
      ];

  /// Creates a copy of this user with the given fields replaced with new values
  User copyWith({
    String? id,
    String? email,
    String? username,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? accessToken,
    String? idToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      accessToken: accessToken ?? this.accessToken,
      idToken: idToken ?? this.idToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
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

  /// Whether the user has valid tokens
  bool get hasValidTokens =>
      accessToken != null &&
      idToken != null &&
      tokenExpiresAt != null &&
      DateTime.now().isBefore(tokenExpiresAt!);

  /// Time until token expiration
  Duration? get timeUntilTokenExpiry =>
      tokenExpiresAt?.difference(DateTime.now());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.email == email &&
        other.username == username &&
        other.createdAt == createdAt &&
        other.lastLoginAt == lastLoginAt &&
        other.accessToken == accessToken &&
        other.idToken == idToken &&
        other.refreshToken == refreshToken &&
        other.tokenExpiresAt == tokenExpiresAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        username.hashCode ^
        createdAt.hashCode ^
        lastLoginAt.hashCode ^
        accessToken.hashCode ^
        idToken.hashCode ^
        refreshToken.hashCode ^
        tokenExpiresAt.hashCode;
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, username: $username, createdAt: $createdAt, lastLoginAt: $lastLoginAt, hasValidTokens: $hasValidTokens}';
  }
}
