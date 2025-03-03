import 'package:equatable/equatable.dart';

/// Represents a user's profile information
class Profile extends Equatable {
  final String id;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> preferences;
  final List<String> interests;
  final bool isPublic;

  const Profile({
    required this.id,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
    this.preferences = const {},
    this.interests = const [],
    this.isPublic = false,
  });

  /// Creates a copy of this Profile with the given fields replaced with the new values
  Profile copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? avatarUrl,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
    List<String>? interests,
    bool? isPublic,
  }) {
    return Profile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      interests: interests ?? this.interests,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        displayName,
        avatarUrl,
        bio,
        createdAt,
        updatedAt,
        preferences,
        interests,
        isPublic,
      ];
}
