import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';
import 'package:soloadventurer/features/profile/domain/entities/profile.dart';

/// Local data model for user profiles with offline-first sync tracking
///
/// This model wraps the [LocalUser] database entity and provides:
/// - JSON serialization for sync queue storage
/// - Entity conversion (domain entity ↔ database model)
/// - Validation methods
/// - Sync status helpers
class LocalUserProfileModel {
  /// Primary key - matches user ID from Cognito
  final String id;

  /// User's email address
  final String email;

  /// User's username
  final String username;

  /// Display name (may differ from username)
  final String displayName;

  /// Optional profile bio
  final String? bio;

  /// Optional avatar URL
  final String? avatarUrl;

  /// Whether profile is public
  final bool isPublic;

  /// List of interests (stored as JSON array string in database)
  final List<String> interests;

  /// User preferences map (stored as JSON string in database)
  final Map<String, dynamic> preferences;

  /// Timestamp when user was created
  final DateTime createdAt;

  /// Timestamp when user was last updated
  final DateTime updatedAt;

  /// Last login timestamp
  final DateTime? lastLoginAt;

  // ==============================================================================
  // SYNC FIELDS - Track synchronization state
  // ==============================================================================

  /// Whether this record has been synced with the server
  final bool isSynced;

  /// Whether this record has local modifications pending sync
  final bool hasPendingChanges;

  /// Version number for conflict resolution
  final int version;

  /// Last successful sync timestamp
  final DateTime? lastSyncedAt;

  /// Creates a new [LocalUserProfileModel]
  const LocalUserProfileModel({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    this.isPublic = false,
    this.interests = const [],
    this.preferences = const {},
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.isSynced = false,
    this.hasPendingChanges = false,
    this.version = 1,
    this.lastSyncedAt,
  });

  // ==============================================================================
  // FACTORY CONSTRUCTORS
  // ==============================================================================

  /// Creates a [LocalUserProfileModel] from a [LocalUser] database entity
  factory LocalUserProfileModel.fromDatabase(LocalUser user) {
    // Parse interests from JSON string
    final interestsJson = user.interests;
    final List<String> interests = interestsJson != null && interestsJson.isNotEmpty
        ? (const JsonDecoder().convert(interestsJson) as List<dynamic>)
            .cast<String>()
        : <String>[];

    // Parse preferences from JSON string
    final preferencesJson = user.preferences;
    final Map<String, dynamic> preferences = preferencesJson != null && preferencesJson.isNotEmpty
        ? (const JsonDecoder().convert(preferencesJson) as Map<String, dynamic>)
        : <String, dynamic>{};

    return LocalUserProfileModel(
      id: user.id,
      email: user.email,
      username: user.username,
      displayName: user.displayName,
      bio: user.bio,
      avatarUrl: user.avatarUrl,
      isPublic: user.isPublic,
      interests: interests,
      preferences: preferences,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      lastLoginAt: user.lastLoginAt,
      isSynced: user.isSynced,
      hasPendingChanges: user.hasPendingChanges,
      version: user.version,
      lastSyncedAt: user.lastSyncedAt,
    );
  }

  /// Creates a [LocalUserProfileModel] from a domain [Profile] entity
  factory LocalUserProfileModel.fromDomainEntity(Profile profile) {
    return LocalUserProfileModel(
      id: profile.userId, // Profile.id is different from userId
      email: profile.email,
      username: profile.username,
      displayName: profile.displayName,
      bio: profile.bio,
      avatarUrl: profile.avatarUrl,
      isPublic: profile.isPublic,
      interests: profile.interests,
      preferences: profile.preferences,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
      lastLoginAt: null, // Not tracked in domain entity
      isSynced: false, // New records are not synced
      hasPendingChanges: true, // New records need to be synced
      version: 1,
      lastSyncedAt: null,
    );
  }

  // ==============================================================================
  // CONVERSION METHODS
  // ==============================================================================

  /// Converts this [LocalUserProfileModel] to a domain [Profile] entity
  Profile toDomainEntity() {
    return Profile(
      id: id, // Use user ID as profile ID
      userId: id,
      username: username,
      email: email,
      displayName: displayName,
      bio: bio,
      avatarUrl: avatarUrl,
      isPublic: isPublic,
      interests: interests,
      preferences: preferences,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Converts this [LocalUserProfileModel] to a [LocalUser] database entity
  LocalUser toDatabaseEntity() {
    return LocalUser(
      id: id,
      email: email,
      username: username,
      displayName: displayName,
      bio: bio,
      avatarUrl: avatarUrl,
      isPublic: isPublic,
      interests: interests.isNotEmpty ? const JsonEncoder().convert(interests) : null,
      preferences: preferences.isNotEmpty ? const JsonEncoder().convert(preferences) : null,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLoginAt: lastLoginAt,
      isSynced: isSynced,
      hasPendingChanges: hasPendingChanges,
      version: version,
      lastSyncedAt: lastSyncedAt,
    );
  }

  // ==============================================================================
  // JSON SERIALIZATION
  // ==============================================================================

  /// Creates a [LocalUserProfileModel] from JSON
  factory LocalUserProfileModel.fromJson(Map<String, dynamic> json) {
    // Parse interests from JSON
    final interestsList = json['interests'] as List<dynamic>?;
    final List<String> interests = interestsList?.cast<String>() ?? [];

    // Parse preferences from JSON
    final preferencesMap = json['preferences'] as Map<String, dynamic>?;
    final Map<String, dynamic> preferences = preferencesMap ?? {};

    return LocalUserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isPublic: json['isPublic'] as bool? ?? false,
      interests: interests,
      preferences: preferences,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      isSynced: json['isSynced'] as bool? ?? false,
      hasPendingChanges: json['hasPendingChanges'] as bool? ?? false,
      version: json['version'] as int? ?? 1,
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'] as String)
          : null,
    );
  }

  /// Converts this [LocalUserProfileModel] to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'displayName': displayName,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'isPublic': isPublic,
      'interests': interests,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isSynced': isSynced,
      'hasPendingChanges': hasPendingChanges,
      'version': version,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  // ==============================================================================
  // SYNC STATUS HELPERS
  // ==============================================================================

  /// Whether this profile needs to be synced with the server
  bool get needsSync => !isSynced || hasPendingChanges;

  /// Whether this profile is currently being synced
  bool get isSyncing => hasPendingChanges && !isSynced;

  /// Creates a copy with sync status updated
  LocalUserProfileModel copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
    bool? isPublic,
    List<String>? interests,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? isSynced,
    bool? hasPendingChanges,
    int? version,
    DateTime? lastSyncedAt,
  }) {
    return LocalUserProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPublic: isPublic ?? this.isPublic,
      interests: interests ?? this.interests,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isSynced: isSynced ?? this.isSynced,
      hasPendingChanges: hasPendingChanges ?? this.hasPendingChanges,
      version: version ?? this.version,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return 'LocalUserProfileModel(id: $id, username: $username, '
        'email: $email, displayName: $displayName, isSynced: $isSynced, '
        'hasPendingChanges: $hasPendingChanges, version: $version)';
  }
}
