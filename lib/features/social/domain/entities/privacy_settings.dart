import 'package:equatable/equatable.dart';
import '../enums/profile_visibility.dart';

/// Profile privacy settings controlling visibility and access
class PrivacySettings extends Equatable {
  /// Creates a new [PrivacySettings]
  const PrivacySettings({
    this.visibility = ProfileVisibility.community,
    this.minViewerAge,
    this.verifiedOnly = false,
    this.genderFilter,
    this.showLocation = true,
    this.discoverableByDestination = true,
  });

  /// Who can see this profile
  final ProfileVisibility visibility;

  /// Minimum age required to view this profile
  final int? minViewerAge;

  /// Whether only verified users can view this profile
  final bool verifiedOnly;

  /// Gender filter for profile visibility
  final List<String>? genderFilter;

  /// Whether to show the user's location on their profile
  final bool showLocation;

  /// Whether the user can be discovered by destination
  final bool discoverableByDestination;

  @override
  List<Object?> get props => [
        visibility,
        minViewerAge,
        verifiedOnly,
        genderFilter,
        showLocation,
        discoverableByDestination,
      ];

  /// Creates a copy with the given fields replaced
  PrivacySettings copyWith({
    ProfileVisibility? visibility,
    int? minViewerAge,
    bool? verifiedOnly,
    List<String>? genderFilter,
    bool? showLocation,
    bool? discoverableByDestination,
  }) {
    return PrivacySettings(
      visibility: visibility ?? this.visibility,
      minViewerAge: minViewerAge ?? this.minViewerAge,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      genderFilter: genderFilter ?? this.genderFilter,
      showLocation: showLocation ?? this.showLocation,
      discoverableByDestination:
          discoverableByDestination ?? this.discoverableByDestination,
    );
  }
}
