import 'package:soloadventurer/features/matching/domain/entities/connection.dart';
import 'package:soloadventurer/features/social/domain/enums/verification_tier.dart';

/// Data layer representation of [Connection] entity
class ConnectionModel extends Connection {
  /// Creates a new [ConnectionModel] instance
  const ConnectionModel({
    required super.id,
    required super.userAId,
    required super.userBId,
    super.matchType,
    super.status,
    required super.overlapStartDate,
    required super.overlapEndDate,
    required super.overlapDays,
    super.distanceMeters,
    super.matchScore,
    super.semanticScore,
    super.sharedActivityCount,
    super.isActive,
    required super.createdAt,
    super.matchedUserProfile,
  });

  /// Creates a [ConnectionModel] from JSON map (Supabase format)
  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    return ConnectionModel(
      id: json['id'] as String,
      userAId: json['user_a_id'] as String,
      userBId: json['user_b_id'] as String,
      matchType: _parseMatchType(json['match_type'] as String?),
      status: _parseConnectionStatus(json['status'] as String?),
      overlapStartDate: DateTime.parse(json['overlap_start_date'] as String),
      overlapEndDate: DateTime.parse(json['overlap_end_date'] as String),
      overlapDays: json['overlap_days'] as int,
      distanceMeters: json['distance_meters'] as double?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      matchedUserProfile: json['matched_user'] != null
          ? MatchedUserProfileModel.fromJson(
              json['matched_user'] as Map<String, dynamic>)
          : null,
      matchScore: (json['composite_score'] as num?)?.toDouble(),
      semanticScore: (json['semantic_score'] as num?)?.toDouble(),
      sharedActivityCount: json['shared_activities'] != null
          ? (json['shared_activities'] as List).length
          : null,
    );
  }

  /// Creates a [ConnectionModel] from the semantic matching Edge Function response
  factory ConnectionModel.fromMatchingJson(Map<String, dynamic> json) {
    return ConnectionModel(
      id: json['id'] as String? ?? '',
      userAId: json['user_a_id'] as String? ?? '',
      userBId: json['user_b_id'] as String? ?? json['matched_user_id'] as String? ?? '',
      matchType: _parseMatchType(json['match_type'] as String?),
      status: _parseConnectionStatus(json['status'] as String?),
      overlapStartDate: json['overlap_start_date'] != null
          ? DateTime.parse(json['overlap_start_date'] as String)
          : DateTime.now(),
      overlapEndDate: json['overlap_end_date'] != null
          ? DateTime.parse(json['overlap_end_date'] as String)
          : DateTime.now(),
      overlapDays: json['overlap_days'] as int? ?? 0,
      distanceMeters: json['distance_meters'] as double?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      matchedUserProfile: json['matched_user'] != null
          ? MatchedUserProfileModel.fromJson(
              json['matched_user'] as Map<String, dynamic>)
          : null,
      matchScore: (json['composite_score'] as num?)?.toDouble(),
      semanticScore: (json['semantic_score'] as num?)?.toDouble(),
      sharedActivityCount: json['shared_activities'] != null
          ? (json['shared_activities'] as List).length
          : (json['shared_activity_count'] as int?),
    );
  }

  /// Converts this [ConnectionModel] to JSON map (Supabase format)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_a_id': userAId,
      'user_b_id': userBId,
      'match_type': matchType.name,
      'status': status.name,
      'overlap_start_date': overlapStartDate.toIso8601String().split('T')[0],
      'overlap_end_date': overlapEndDate.toIso8601String().split('T')[0],
      'overlap_days': overlapDays,
      'distance_meters': distanceMeters,
      'composite_score': matchScore,
      'semantic_score': semanticScore,
      'shared_activity_count': sharedActivityCount,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a [ConnectionModel] from a [Connection] entity
  factory ConnectionModel.fromEntity(Connection connection) {
    return ConnectionModel(
      id: connection.id,
      userAId: connection.userAId,
      userBId: connection.userBId,
      matchType: connection.matchType,
      status: connection.status,
      overlapStartDate: connection.overlapStartDate,
      overlapEndDate: connection.overlapEndDate,
      overlapDays: connection.overlapDays,
      distanceMeters: connection.distanceMeters,
      isActive: connection.isActive,
      createdAt: connection.createdAt,
      matchedUserProfile: connection.matchedUserProfile,
      matchScore: connection.matchScore,
      semanticScore: connection.semanticScore,
      sharedActivityCount: connection.sharedActivityCount,
    );
  }

  /// Converts to a map for local database storage (Drift)
  Map<String, dynamic> toLocalDbMap() {
    return {
      'id': id,
      'user_a_id': userAId,
      'user_b_id': userBId,
      'match_type': matchType.name,
      'status': status.name,
      'overlap_start_date': overlapStartDate.toIso8601String().split('T')[0],
      'overlap_end_date': overlapEndDate.toIso8601String().split('T')[0],
      'overlap_days': overlapDays,
      'distance_meters': distanceMeters,
      'composite_score': matchScore,
      'semantic_score': semanticScore,
      'shared_activity_count': sharedActivityCount,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a [ConnectionModel] from local database map (Drift)
  factory ConnectionModel.fromLocalDbMap(Map<String, dynamic> map) {
    return ConnectionModel(
      id: map['id'] as String,
      userAId: map['user_a_id'] as String,
      userBId: map['user_b_id'] as String,
      matchType: _parseMatchType(map['match_type'] as String?),
      status: _parseConnectionStatus(map['status'] as String?),
      overlapStartDate: DateTime.parse(map['overlap_start_date'] as String),
      overlapEndDate: DateTime.parse(map['overlap_end_date'] as String),
      overlapDays: map['overlap_days'] as int,
      distanceMeters: map['distance_meters'] as double?,
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      matchScore: (map['composite_score'] as num?)?.toDouble(),
      semanticScore: (map['semantic_score'] as num?)?.toDouble(),
      sharedActivityCount: map['shared_activity_count'] as int?,
    );
  }

  /// Helper to parse match type from string
  static MatchType _parseMatchType(String? value) {
    switch (value?.toLowerCase()) {
      case 'geographic_overlap':
        return MatchType.geographicOverlap;
      case 'activity_match':
        return MatchType.activityMatch;
      case 'combined_match':
        return MatchType.combinedMatch;
      default:
        return MatchType.geographicOverlap;
    }
  }

  /// Helper to parse connection status from string
  static ConnectionStatus _parseConnectionStatus(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return ConnectionStatus.pending;
      case 'accepted':
        return ConnectionStatus.accepted;
      case 'declined':
        return ConnectionStatus.declined;
      case 'blocked':
        return ConnectionStatus.blocked;
      default:
        return ConnectionStatus.pending;
    }
  }
}

/// Data layer representation of [MatchedUserProfile] entity
class MatchedUserProfileModel extends MatchedUserProfile {
  /// Creates a new [MatchedUserProfileModel] instance
  const MatchedUserProfileModel({
    required super.id,
    required super.firstName,
    required super.ageRange,
    required super.homeCountry,
    required super.gender,
    super.avatarUrl,
    super.verificationTier,
    super.trip,
  });

  /// Creates a [MatchedUserProfileModel] from JSON map
  factory MatchedUserProfileModel.fromJson(Map<String, dynamic> json) {
    VerificationTier tier = VerificationTier.unverified;
    final tierStr = json['verification_tier'] as String?;
    if (tierStr != null) {
      try {
        tier = VerificationTier.fromString(tierStr);
      } catch (_) {}
    }

    return MatchedUserProfileModel(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      ageRange: json['age_range'] as String,
      homeCountry: json['home_country'] as String,
      gender: json['gender'] as String,
      avatarUrl: json['avatar_url'] as String?,
      verificationTier: tier,
      trip: json['trip'] != null
          ? MatchedUserTripModel.fromJson(
              json['trip'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts this [MatchedUserProfileModel] to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'age_range': ageRange,
      'home_country': homeCountry,
      'gender': gender,
      'avatar_url': avatarUrl,
      'verification_tier': verificationTier.value,
      'trip': (trip as MatchedUserTripModel?)?.toJson(),
    };
  }

  /// Creates a [MatchedUserProfileModel] from a [MatchedUserProfile] entity
  factory MatchedUserProfileModel.fromEntity(MatchedUserProfile profile) {
    return MatchedUserProfileModel(
      id: profile.id,
      firstName: profile.firstName,
      ageRange: profile.ageRange,
      homeCountry: profile.homeCountry,
      gender: profile.gender,
      avatarUrl: profile.avatarUrl,
      verificationTier: profile.verificationTier,
      trip: profile.trip != null
          ? MatchedUserTripModel.fromEntity(profile.trip!)
          : null,
    );
  }
}

/// Data layer representation of [MatchedUserTrip] entity
class MatchedUserTripModel extends MatchedUserTrip {
  /// Creates a new [MatchedUserTripModel] instance
  const MatchedUserTripModel({
    required super.destinationName,
    required super.startDate,
    required super.endDate,
  });

  /// Creates a [MatchedUserTripModel] from JSON map
  factory MatchedUserTripModel.fromJson(Map<String, dynamic> json) {
    return MatchedUserTripModel(
      destinationName: json['destination_name'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
    );
  }

  /// Converts this [MatchedUserTripModel] to JSON map
  Map<String, dynamic> toJson() {
    return {
      'destination_name': destinationName,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
    };
  }

  /// Creates a [MatchedUserTripModel] from a [MatchedUserTrip] entity
  factory MatchedUserTripModel.fromEntity(MatchedUserTrip trip) {
    return MatchedUserTripModel(
      destinationName: trip.destinationName,
      startDate: trip.startDate,
      endDate: trip.endDate,
    );
  }
}
