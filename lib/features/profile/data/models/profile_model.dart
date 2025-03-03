import 'package:soloadventurer/features/profile/domain/entities/profile.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';

/// Model class for Profile that handles JSON serialization/deserialization
class ProfileModel extends Profile {
  static const int maxDisplayNameLength = 50;
  static const int maxBioLength = 500;
  static const int maxInterestsCount = 20;
  static const int maxPreferencesCount = 50;

  const ProfileModel({
    required super.id,
    required super.userId,
    required super.displayName,
    super.avatarUrl,
    super.bio,
    required super.createdAt,
    required super.updatedAt,
    super.preferences = const {},
    super.interests = const [],
    super.isPublic = false,
  });

  /// Creates a [ProfileModel] from JSON data with validation
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final displayName = json['displayName'] as String;
    final bio = json['bio'] as String?;
    final interests =
        (json['interests'] as List<dynamic>?)?.cast<String>() ?? [];
    final preferences = (json['preferences'] as Map<String, dynamic>?) ?? {};

    // Validate fields
    _validateDisplayName(displayName);
    if (bio != null) _validateBio(bio);
    _validateInterests(interests);
    _validatePreferences(preferences);

    return ProfileModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      displayName: displayName,
      avatarUrl: json['avatarUrl'] as String?,
      bio: bio,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      preferences: preferences,
      interests: interests,
      isPublic: json['isPublic'] as bool? ?? false,
    );
  }

  /// Validates all fields of the profile
  void validate() {
    _validateDisplayName(displayName);
    if (bio != null) _validateBio(bio!);
    _validateInterests(interests);
    _validatePreferences(preferences);
  }

  static void _validateDisplayName(String displayName) {
    if (displayName.isEmpty) {
      throw const ValidationException(
        message: 'Display name cannot be empty',
        errors: {
          'displayName': ['Display name cannot be empty']
        },
      );
    }
    if (displayName.length > maxDisplayNameLength) {
      throw const ValidationException(
        message: 'Display name cannot exceed $maxDisplayNameLength characters',
        errors: {
          'displayName': [
            'Display name cannot exceed $maxDisplayNameLength characters'
          ]
        },
      );
    }
  }

  static void _validateBio(String bio) {
    if (bio.length > maxBioLength) {
      throw const ValidationException(
        message: 'Bio cannot exceed $maxBioLength characters',
        errors: {
          'bio': ['Bio cannot exceed $maxBioLength characters']
        },
      );
    }
  }

  static void _validateInterests(List<String> interests) {
    if (interests.length > maxInterestsCount) {
      throw const ValidationException(
        message: 'Cannot have more than $maxInterestsCount interests',
        errors: {
          'interests': ['Cannot have more than $maxInterestsCount interests']
        },
      );
    }
  }

  static void _validatePreferences(Map<String, dynamic> preferences) {
    if (preferences.length > maxPreferencesCount) {
      throw const ValidationException(
        message: 'Cannot have more than $maxPreferencesCount preferences',
        errors: {
          'preferences': [
            'Cannot have more than $maxPreferencesCount preferences'
          ]
        },
      );
    }
  }

  /// Converts this [ProfileModel] to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'preferences': preferences,
      'interests': interests,
      'isPublic': isPublic,
    };
  }

  /// Creates a copy of this ProfileModel with the given fields replaced with the new values
  @override
  ProfileModel copyWith({
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
    return ProfileModel(
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

  /// Creates a [ProfileModel] from a [Profile] entity
  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      id: profile.id,
      userId: profile.userId,
      displayName: profile.displayName,
      avatarUrl: profile.avatarUrl,
      bio: profile.bio,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
      preferences: profile.preferences,
      interests: profile.interests,
      isPublic: profile.isPublic,
    );
  }
}
