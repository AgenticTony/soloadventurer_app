import 'package:equatable/equatable.dart';

/// User entity representing an authenticated user
class User extends Equatable {
  /// Unique identifier for the user
  final String id;

  /// User's email address
  final String email;

  /// User's username
  final String username;

  /// User's first name
  final String? firstName;

  /// User's last name
  final String? lastName;

  /// URL to the user's profile picture
  final String? profilePictureUrl;

  /// When the user was created
  final DateTime createdAt;

  /// When the user profile was last updated
  final DateTime? updatedAt;

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
    this.firstName,
    this.lastName,
    this.profilePictureUrl,
    this.updatedAt,
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
        firstName,
        lastName,
        profilePictureUrl,
        createdAt,
        updatedAt,
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
    String? firstName,
    String? lastName,
    String? profilePictureUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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

  /// The user's full name, prioritizing firstName and lastName, falling back to username
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    } else {
      return username;
    }
  }

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
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.profilePictureUrl == profilePictureUrl &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
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
        firstName.hashCode ^
        lastName.hashCode ^
        profilePictureUrl.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
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

  /// Creates a [User] from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      accessToken: json['accessToken'] as String?,
      idToken: json['idToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      tokenExpiresAt: json['tokenExpiresAt'] != null
          ? DateTime.parse(json['tokenExpiresAt'] as String)
          : null,
    );
  }

  /// Converts this [User] to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'accessToken': accessToken,
      'idToken': idToken,
      'refreshToken': refreshToken,
      'tokenExpiresAt': tokenExpiresAt?.toIso8601String(),
    };
  }
}
