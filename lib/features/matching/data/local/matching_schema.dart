import 'package:drift/drift.dart';

/// Matching trips table
///
/// Stores trip data for the matching feature with sync tracking.
/// This is separate from the journal Trips table to support the matching use case.
@DataClassName('MatchingTripRecord')
class MatchingTrips extends Table {
  /// Primary key - matches server-generated trip ID
  TextColumn get id => text()();

  /// User ID who owns this trip
  TextColumn get userId => text()();

  /// Human-readable destination name
  TextColumn get destinationName => text()();

  /// Latitude coordinate
  RealColumn get latitude => real()();

  /// Longitude coordinate
  RealColumn get longitude => real()();

  /// Location precision level (city, neighborhood, exact)
  TextColumn get locationPrecision => text().withDefault(const Constant('city'))();

  /// Trip start date
  DateTimeColumn get startDate => dateTime()();

  /// Trip end date
  DateTimeColumn get endDate => dateTime()();

  /// Whether the trip is currently active
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Timestamp when trip was created
  DateTimeColumn get createdAt => dateTime()();

  /// Timestamp when trip was last updated
  DateTimeColumn get updatedAt => dateTime()();

  // ==============================================================================
  // SYNC FIELDS
  // ==============================================================================

  /// Whether this record has been synced with the server
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  /// Whether this record has local modifications pending sync
  BoolColumn get hasPendingChanges =>
      boolean().withDefault(const Constant(false))();

  /// Version number for conflict resolution
  IntColumn get version => integer().withDefault(const Constant(1))();

  /// Soft delete flag
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// Last successful sync timestamp
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Connections table
///
/// Stores connections/matches between travelers with sync tracking.
@DataClassName('MatchingConnectionRecord')
class MatchingConnections extends Table {
  /// Primary key - matches server-generated connection ID
  TextColumn get id => text()();

  /// First user in the connection
  TextColumn get userAId => text()();

  /// Second user in the connection
  TextColumn get userBId => text()();

  /// Type of match (geographic_overlap, activity_match, combined_match)
  TextColumn get matchType => text().withDefault(const Constant('geographic_overlap'))();

  /// Status of the connection (pending, accepted, declined, blocked)
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// Start of date overlap
  DateTimeColumn get overlapStartDate => dateTime()();

  /// End of date overlap
  DateTimeColumn get overlapEndDate => dateTime()();

  /// Number of overlapping days
  IntColumn get overlapDays => integer()();

  /// Distance between users in meters
  RealColumn get distanceMeters => real().nullable()();

  /// Whether the connection is currently active
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Timestamp when connection was created
  DateTimeColumn get createdAt => dateTime()();

  // ==============================================================================
  // SYNC FIELDS
  // ==============================================================================

  /// Whether this record has been synced with the server
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  /// Whether this record has local modifications pending sync
  BoolColumn get hasPendingChanges =>
      boolean().withDefault(const Constant(false))();

  /// Version number for conflict resolution
  IntColumn get version => integer().withDefault(const Constant(1))();

  /// Soft delete flag
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// Last successful sync timestamp
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Activities table
///
/// Stores available activities for matching.
@DataClassName('MatchingActivityRecord')
class MatchingActivities extends Table {
  /// Primary key - activity ID
  TextColumn get id => text()();

  /// Activity name
  TextColumn get name => text()();

  /// Activity description
  TextColumn get description => text().nullable()();

  /// Activity category
  TextColumn get category => text()();

  /// Activity icon name
  TextColumn get iconName => text().nullable()();

  /// Whether the activity is active
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Display order
  IntColumn get displayOrder => integer().withDefault(const Constant(0))();

  /// Timestamp when activity was created
  DateTimeColumn get createdAt => dateTime()();

  /// Timestamp when activity was last updated
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// User activities junction table
///
/// Links users to their selected activities.
@DataClassName('UserActivityRecord')
class UserActivities extends Table {
  /// Primary key - composite key
  TextColumn get userId => text()();

  /// Activity ID
  TextColumn get activityId => text()();

  /// Timestamp when activity was added
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId, activityId};
}

/// Sync metadata table for matching feature
///
/// Tracks synchronization state for the matching module.
@DataClassName('MatchingSyncMetadataRecord')
class MatchingSyncMetadata extends Table {
  /// Primary key - auto-increment
  IntColumn get id => integer().autoIncrement()();

  /// Last sync timestamp
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  /// Whether sync is in progress
  BoolColumn get syncInProgress => boolean().withDefault(const Constant(false))();

  /// Last error message
  TextColumn get lastError => text().nullable()();

  /// Timestamp of last error
  DateTimeColumn get lastErrorAt => dateTime().nullable()();
}
