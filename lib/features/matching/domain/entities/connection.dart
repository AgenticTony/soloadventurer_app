import 'package:equatable/equatable.dart';
import 'package:soloadventurer/features/social/domain/enums/verification_tier.dart';

/// Status of a connection between travelers
enum ConnectionStatus {
  /// Connection pending acceptance
  pending,
  
  /// Connection accepted by both parties
  accepted,
  
  /// Connection declined by one party
  declined,
  
  /// Connection blocked by one party
  blocked,
}

/// Connection entity representing a match between two travelers
class Connection extends Equatable {
  /// Unique identifier for the connection
  final String id;

  /// First user in the connection
  final String userAId;

  /// Second user in the connection
  final String userBId;

  /// Type of match
  final MatchType matchType;

  /// Status of the connection
  final ConnectionStatus status;

  /// Start of date overlap
  final DateTime overlapStartDate;

  /// End of date overlap
  final DateTime overlapEndDate;

  /// Number of overlapping days
  final int overlapDays;

  /// Distance between users in meters
  final double? distanceMeters;

  /// Composite ML match score (0.0-1.0)
  final double? matchScore;

  /// Pure semantic similarity score (0.0-1.0)
  final double? semanticScore;

  /// Number of shared activities
  final int? sharedActivityCount;

  /// Whether the connection is currently active
  final bool isActive;

  /// When the connection was created
  final DateTime createdAt;

  /// Other user's profile info (populated when fetching matches)
  final MatchedUserProfile? matchedUserProfile;

  /// Creates a new [Connection] instance
  const Connection({
    required this.id,
    required this.userAId,
    required this.userBId,
    this.matchType = MatchType.geographicOverlap,
    this.status = ConnectionStatus.pending,
    required this.overlapStartDate,
    required this.overlapEndDate,
    required this.overlapDays,
    this.distanceMeters,
    this.matchScore,
    this.semanticScore,
    this.sharedActivityCount,
    this.isActive = true,
    required this.createdAt,
    this.matchedUserProfile,
  });

  @override
  List<Object?> get props => [
        id,
        userAId,
        userBId,
        matchType,
        status,
        overlapStartDate,
        overlapEndDate,
        overlapDays,
        distanceMeters,
        matchScore,
        semanticScore,
        sharedActivityCount,
        isActive,
        createdAt,
        matchedUserProfile,
      ];

  /// Creates a copy of this connection with the given fields replaced
  Connection copyWith({
    String? id,
    String? userAId,
    String? userBId,
    MatchType? matchType,
    ConnectionStatus? status,
    DateTime? overlapStartDate,
    DateTime? overlapEndDate,
    int? overlapDays,
    double? distanceMeters,
    double? matchScore,
    double? semanticScore,
    int? sharedActivityCount,
    bool? isActive,
    DateTime? createdAt,
    MatchedUserProfile? matchedUserProfile,
  }) {
    return Connection(
      id: id ?? this.id,
      userAId: userAId ?? this.userAId,
      userBId: userBId ?? this.userBId,
      matchType: matchType ?? this.matchType,
      status: status ?? this.status,
      overlapStartDate: overlapStartDate ?? this.overlapStartDate,
      overlapEndDate: overlapEndDate ?? this.overlapEndDate,
      overlapDays: overlapDays ?? this.overlapDays,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      matchScore: matchScore ?? this.matchScore,
      semanticScore: semanticScore ?? this.semanticScore,
      sharedActivityCount: sharedActivityCount ?? this.sharedActivityCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      matchedUserProfile: matchedUserProfile ?? this.matchedUserProfile,
    );
  }

  /// Creates an empty connection
  factory Connection.empty() {
    final now = DateTime.now();
    return Connection(
      id: '',
      userAId: '',
      userBId: '',
      overlapStartDate: now,
      overlapEndDate: now,
      overlapDays: 0,
      createdAt: now,
    );
  }

  /// Whether this connection is empty
  bool get isEmpty => id.isEmpty;

  /// Whether this connection is not empty
  bool get isNotEmpty => !isEmpty;

  /// Display-friendly match percentage
  String get matchPercentage => matchScore != null
      ? '${(matchScore! * 100).round()}%'
      : 'New';

  @override
  String toString() {
    return 'Connection{id: $id, users: $userAId ↔ $userBId, overlap: $overlapDays days, active: $isActive}';
  }
}

/// Types of matches
enum MatchType {
  /// Users have overlapping trips in same geographic area
  geographicOverlap,

  /// Users share similar activity interests
  activityMatch,

  /// Multiple matching criteria
  combinedMatch,
}

/// Profile information for a matched user
class MatchedUserProfile extends Equatable {
  /// User's ID
  final String id;

  /// User's first name
  final String firstName;

  /// User's age range
  final String ageRange;

  /// User's home country (ISO 3166-1 alpha-2 code)
  final String homeCountry;

  /// User's gender
  final String gender;

  /// User's avatar URL (optional)
  final String? avatarUrl;

  /// User's verification tier
  final VerificationTier verificationTier;

  /// Matched user's trip info
  final MatchedUserTrip? trip;

  /// Creates a new [MatchedUserProfile] instance
  const MatchedUserProfile({
    required this.id,
    required this.firstName,
    required this.ageRange,
    required this.homeCountry,
    required this.gender,
    this.avatarUrl,
    this.verificationTier = VerificationTier.unverified,
    this.trip,
  });

  @override
  List<Object?> get props => [
        id,
        firstName,
        ageRange,
        homeCountry,
        gender,
        avatarUrl,
        verificationTier,
        trip,
      ];

  /// Creates an empty profile
  factory MatchedUserProfile.empty() {
    return const MatchedUserProfile(
      id: '',
      firstName: '',
      ageRange: '',
      homeCountry: '',
      gender: '',
    );
  }

  /// Whether this profile is empty
  bool get isEmpty => id.isEmpty;

  /// Whether this profile is not empty
  bool get isNotEmpty => !isEmpty;
}

/// Trip information for a matched user
class MatchedUserTrip extends Equatable {
  /// Trip's destination name
  final String destinationName;

  /// Trip's start date
  final DateTime startDate;

  /// Trip's end date
  final DateTime endDate;

  /// Creates a new [MatchedUserTrip] instance
  const MatchedUserTrip({
    required this.destinationName,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [destinationName, startDate, endDate];

  /// Duration of the trip in days
  int get durationInDays => endDate.difference(startDate).inDays + 1;
}
