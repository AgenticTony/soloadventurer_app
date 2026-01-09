import 'package:equatable/equatable.dart';

/// Represents a user profile in the application
class Profile extends Equatable {
  /// Creates a new [Profile]
  const Profile({
    required this.id,
    required this.userId,
    required this.username,
    required this.email,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    this.isPublic = false,
    this.interests = const [],
    this.preferences = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// The unique identifier of the profile
  final String id;

  /// The user ID associated with this profile
  final String userId;

  /// The username of the profile
  final String username;

  /// The email address of the profile
  final String email;

  /// The display name of the profile
  final String displayName;

  /// The bio/description of the profile
  final String? bio;

  /// The URL of the profile avatar
  final String? avatarUrl;

  /// Whether the profile is publicly visible
  final bool isPublic;

  /// The user's interests
  final List<String> interests;

  /// The user's preferences
  final Map<String, dynamic> preferences;

  /// When the profile was created
  final DateTime createdAt;

  /// When the profile was last updated
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        userId,
        username,
        email,
        displayName,
        bio,
        avatarUrl,
        isPublic,
        interests,
        preferences,
        createdAt,
        updatedAt,
      ];

  /// Creates a copy of this profile with the given fields replaced with new values
  Profile copyWith({
    String? id,
    String? userId,
    String? username,
    String? email,
    String? displayName,
    String? bio,
    String? avatarUrl,
    bool? isPublic,
    List<String>? interests,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPublic: isPublic ?? this.isPublic,
      interests: interests ?? this.interests,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
