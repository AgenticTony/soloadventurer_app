import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/profile/domain/entities/profile.dart';
import 'package:soloadventurer/features/social/domain/enums/verification_tier.dart';

/// Model class for Profile that handles JSON serialization/deserialization and validation
class ProfileModel extends Profile {
  static const int maxDisplayNameLength = 50;
  static const int maxBioLength = 500;
  static const int maxInterestsCount = 20;
  static const int maxPreferencesCount = 50;

  const ProfileModel({
    required super.id,
    required super.userId,
    required super.username,
    required super.email,
    required super.displayName,
    super.bio,
    super.avatarUrl,
    super.isPublic = false,
    super.verificationTier = VerificationTier.unverified,
    super.interests = const [],
    super.preferences = const {},
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates a [ProfileModel] from a domain [Profile] entity
  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      id: profile.id,
      userId: profile.userId,
      username: profile.username,
      email: profile.email,
      displayName: profile.displayName,
      bio: profile.bio,
      avatarUrl: profile.avatarUrl,
      isPublic: profile.isPublic,
      verificationTier: profile.verificationTier,
      interests: profile.interests,
      preferences: profile.preferences,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }

  /// Converts this [ProfileModel] to a domain [Profile] entity
  Profile toEntity() {
    return Profile(
      id: id,
      userId: userId,
      username: username,
      email: email,
      displayName: displayName,
      bio: bio,
      avatarUrl: avatarUrl,
      isPublic: isPublic,
      verificationTier: verificationTier,
      interests: interests,
      preferences: preferences,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

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

    // Parse verification tier
    VerificationTier tier = VerificationTier.unverified;
    if (json['verificationTier'] != null) {
      try {
        tier = VerificationTier.fromString(json['verificationTier'] as String);
      } catch (_) {
        tier = VerificationTier.unverified;
      }
    }

    return ProfileModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      displayName: displayName,
      bio: bio,
      avatarUrl: json['avatarUrl'] as String?,
      isPublic: json['isPublic'] as bool? ?? false,
      verificationTier: tier,
      interests: interests,
      preferences: preferences,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'email': email,
      'displayName': displayName,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'isPublic': isPublic,
      'verificationTier': verificationTier.value,
      'interests': interests,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy of this ProfileModel with the given fields replaced with the new values
  @override
  ProfileModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? email,
    String? displayName,
    String? bio,
    String? avatarUrl,
    bool? isPublic,
    VerificationTier? verificationTier,
    List<String>? interests,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPublic: isPublic ?? this.isPublic,
      verificationTier: verificationTier ?? this.verificationTier,
      interests: interests ?? this.interests,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
}
