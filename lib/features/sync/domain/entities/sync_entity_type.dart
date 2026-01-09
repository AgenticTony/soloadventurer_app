/// Entity types that can be synchronized
///
/// This enum defines all data types in the application that participate
/// in sync operations. Each entity type has specific sync requirements
/// and conflict resolution strategies.
enum SyncEntityType {
  /// User profile and preferences
  profile,

  /// Trip data (main trip records)
  trip,

  /// Trip planning operations
  tripPlanning,

  /// Travel notes (text, photo, voice, location, expense)
  travelNote,

  /// Location updates
  locationUpdate,

  /// Travel preferences
  travelPreference,

  /// User authentication tokens (managed separately)
  authTokens,

  /// Companion/user relationships
  companions,

  /// Shared trip data
  sharedTrips,
}

/// Extension on SyncEntityType for metadata and configuration
extension SyncEntityTypeExtension on SyncEntityType {
  /// Whether this entity type supports automatic conflict resolution
  bool get supportsAutoMerge {
    switch (this) {
      case SyncEntityType.locationUpdate:
      case SyncEntityType.travelNote:
        return true; // These can be merged by timestamp
      case SyncEntityType.trip:
      case SyncEntityType.profile:
      case SyncEntityType.tripPlanning:
      case SyncEntityType.travelPreference:
      case SyncEntityType.authTokens:
      case SyncEntityType.companions:
      case SyncEntityType.sharedTrips:
        return false; // These require manual conflict resolution
    }
  }

  /// Priority for sync ordering (higher = synced first)
  int get syncPriority {
    switch (this) {
      case SyncEntityType.authTokens:
        return 100; // Always sync auth first
      case SyncEntityType.profile:
        return 90;
      case SyncEntityType.trip:
        return 80;
      case SyncEntityType.tripPlanning:
        return 70;
      case SyncEntityType.travelNote:
        return 60;
      case SyncEntityType.locationUpdate:
        return 50;
      case SyncEntityType.travelPreference:
        return 40;
      case SyncEntityType.companions:
        return 30;
      case SyncEntityType.sharedTrips:
        return 20;
    }
  }

  /// Whether this entity type requires network to sync
  bool get requiresNetwork {
    switch (this) {
      case SyncEntityType.travelNote:
      case SyncEntityType.locationUpdate:
        return false; // These can be created offline
      case SyncEntityType.profile:
      case SyncEntityType.trip:
      case SyncEntityType.tripPlanning:
      case SyncEntityType.travelPreference:
      case SyncEntityType.authTokens:
      case SyncEntityType.companions:
      case SyncEntityType.sharedTrips:
        return true; // These require network
    }
  }

  /// API endpoint path for this entity type
  String get apiPath {
    switch (this) {
      case SyncEntityType.profile:
        return '/profile';
      case SyncEntityType.trip:
        return '/trips';
      case SyncEntityType.tripPlanning:
        return '/trip-planning';
      case SyncEntityType.travelNote:
        return '/travel-notes';
      case SyncEntityType.locationUpdate:
        return '/location-updates';
      case SyncEntityType.travelPreference:
        return '/travel-preferences';
      case SyncEntityType.authTokens:
        return '/auth/tokens';
      case SyncEntityType.companions:
        return '/companions';
      case SyncEntityType.sharedTrips:
        return '/shared-trips';
    }
  }

  /// User-friendly display name
  String get displayName {
    switch (this) {
      case SyncEntityType.profile:
        return 'Profile';
      case SyncEntityType.trip:
        return 'Trips';
      case SyncEntityType.tripPlanning:
        return 'Trip Plans';
      case SyncEntityType.travelNote:
        return 'Travel Notes';
      case SyncEntityType.locationUpdate:
        return 'Location Updates';
      case SyncEntityType.travelPreference:
        return 'Preferences';
      case SyncEntityType.authTokens:
        return 'Authentication';
      case SyncEntityType.companions:
        return 'Travel Companions';
      case SyncEntityType.sharedTrips:
        return 'Shared Trips';
    }
  }

  /// Icon code point for Material Icons
  int get iconCodePoint {
    switch (this) {
      case SyncEntityType.profile:
        return 0xe790; // person
      case SyncEntityType.trip:
        return 0xe0c8; // flight
      case SyncEntityType.tripPlanning:
        return 0xe916; // plan
      case SyncEntityType.travelNote:
        return 0xe866; // note
      case SyncEntityType.locationUpdate:
        return 0xe55b; // place
      case SyncEntityType.travelPreference:
        return 0xe8b8; // settings
      case SyncEntityType.authTokens:
        return 0xe3af; // lock
      case SyncEntityType.companions:
        return 0xe7fb; // group
      case SyncEntityType.sharedTrips:
        return 0xe80d; // share
    }
  }
}
