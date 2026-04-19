import '../../domain/entities/privacy_settings.dart';
import '../../domain/enums/profile_visibility.dart';

/// Data model for profile privacy settings, mapping to/from Supabase JSON
class PrivacySettingsModel {
  /// Creates a new [PrivacySettingsModel]
  const PrivacySettingsModel({
    required this.userId,
    required this.visibility,
    this.minViewerAge,
    required this.verifiedOnly,
    this.genderFilter,
    required this.showLocation,
    required this.discoverableByDestination,
  });

  /// The user ID these settings belong to
  final String userId;

  /// Who can see this profile
  final ProfileVisibility visibility;

  /// Minimum age required to view
  final int? minViewerAge;

  /// Whether only verified users can view
  final bool verifiedOnly;

  /// Gender filter list
  final List<String>? genderFilter;

  /// Whether location is shown
  final bool showLocation;

  /// Whether discoverable by destination
  final bool discoverableByDestination;

  /// Creates a [PrivacySettingsModel] from Supabase JSON
  factory PrivacySettingsModel.fromJson(Map<String, dynamic> json) {
    return PrivacySettingsModel(
      userId: json['user_id'] as String? ?? '',
      visibility: ProfileVisibility.fromString(
        json['visibility'] as String? ?? 'community',
      ),
      minViewerAge: json['min_viewer_age'] as int?,
      verifiedOnly: json['verified_only'] as bool? ?? false,
      genderFilter: (json['gender_filter'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      showLocation: json['show_location'] as bool? ?? true,
      discoverableByDestination:
          json['discoverable_by_destination'] as bool? ?? true,
    );
  }

  /// Converts to Supabase JSON map
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'visibility': visibility.value,
      'min_viewer_age': minViewerAge,
      'verified_only': verifiedOnly,
      'gender_filter': genderFilter,
      'show_location': showLocation,
      'discoverable_by_destination': discoverableByDestination,
    };
  }

  /// Converts to a domain [PrivacySettings] entity
  PrivacySettings toEntity() {
    return PrivacySettings(
      visibility: visibility,
      minViewerAge: minViewerAge,
      verifiedOnly: verifiedOnly,
      genderFilter: genderFilter,
      showLocation: showLocation,
      discoverableByDestination: discoverableByDestination,
    );
  }

  /// Creates from a domain [PrivacySettings] entity
  factory PrivacySettingsModel.fromEntity(
    String userId,
    PrivacySettings entity,
  ) {
    return PrivacySettingsModel(
      userId: userId,
      visibility: entity.visibility,
      minViewerAge: entity.minViewerAge,
      verifiedOnly: entity.verifiedOnly,
      genderFilter: entity.genderFilter,
      showLocation: entity.showLocation,
      discoverableByDestination: entity.discoverableByDestination,
    );
  }
}
