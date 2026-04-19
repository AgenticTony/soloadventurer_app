import 'package:drift/drift.dart';

// Index definitions for frequently queried columns across all tables.
// Each table uses @TableIndex annotations that Drift processes
// during schema generation.

/// Trips table
///
/// Stores trip data locally with sync tracking.
/// Supports offline access and automatic synchronization with the server.
@DataClassName('LocalTrip')
@TableIndex(name: 'idx_trips_userId', columns: {#userId})
@TableIndex(name: 'idx_trips_status', columns: {#status})
@TableIndex(name: 'idx_trips_isSynced', columns: {#isSynced})
class Trips extends Table {
  /// Primary key - matches server-generated trip ID
  TextColumn get id => text()();

  /// User ID who owns this trip
  TextColumn get userId => text()();

  /// Trip title
  TextColumn get title => text()();

  /// Optional trip description
  TextColumn get description => text().nullable()();

  /// Trip start date
  DateTimeColumn get startDate => dateTime()();

  /// Trip end date
  DateTimeColumn get endDate => dateTime()();

  /// Destination name/location
  TextColumn get destination => text()();

  /// Optional latitude coordinate
  RealColumn get latitude => real().nullable()();

  /// Optional longitude coordinate
  RealColumn get longitude => real().nullable()();

  /// Trip status (e.g., 'planning', 'ongoing', 'completed', 'cancelled')
  TextColumn get status => text()();

  /// Budget amount
  IntColumn get budget => integer()();

  /// Optional cover image URL
  TextColumn get coverImageUrl => text().nullable()();

  /// List of travel companion IDs (stored as JSON array)
  TextColumn get travelCompanionIds => text().nullable()();

  /// Timestamp when trip was created on server
  DateTimeColumn get createdAt => dateTime()();

  /// Timestamp when trip was last updated on server
  DateTimeColumn get updatedAt => dateTime()();

  // ==============================================================================
  // SYNC FIELDS - Track synchronization state
  // ==============================================================================

  /// Whether this record has been synced with the server
  /// - false: Locally created/modified, pending sync
  /// - true: Successfully synced with server
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  /// Whether this record has local modifications pending sync
  BoolColumn get hasPendingChanges =>
      boolean().withDefault(const Constant(false))();

  /// Version number for conflict resolution
  /// Incremented on each update from server
  IntColumn get version => integer().withDefault(const Constant(1))();

  /// Soft delete flag - true if deleted locally pending sync
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// Last successful sync timestamp
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  /// Set id as primary key
  @override
  Set<Column> get primaryKey => {id};
}

/// Journals table
///
/// Stores journal entries linked to trips with sync tracking.
/// Supports offline access and automatic synchronization with the server.
@DataClassName('LocalJournal')
@TableIndex(name: 'idx_journals_tripId', columns: {#tripId})
@TableIndex(name: 'idx_journals_userId', columns: {#userId})
@TableIndex(name: 'idx_journals_isSynced', columns: {#isSynced})
class Journals extends Table {
  /// Primary key - matches server-generated journal ID
  TextColumn get id => text()();

  /// Foreign key to associated trip
  TextColumn get tripId => text()();

  /// User ID who created this journal
  TextColumn get userId => text()();

  /// Journal entry title
  TextColumn get title => text()();

  /// Journal content/body text
  TextColumn get content => text()();

  /// Optional journal entry date (defaults to createdAt)
  DateTimeColumn get entryDate => dateTime().nullable()();

  /// Optional mood/feeling tag
  TextColumn get mood => text().nullable()();

  /// Optional location name where journal was written
  TextColumn get location => text().nullable()();

  /// List of attached image URLs (stored as JSON array)
  TextColumn get imageUrls => text().nullable()();

  /// Optional list of tags
  TextColumn get tags => text().nullable()();

  /// Timestamp when journal was created on server
  DateTimeColumn get createdAt => dateTime()();

  /// Timestamp when journal was last updated on server
  DateTimeColumn get updatedAt => dateTime()();

  // ==============================================================================
  // SYNC FIELDS - Track synchronization state
  // ==============================================================================

  /// Whether this record has been synced with the server
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  /// Whether this record has local modifications pending sync
  BoolColumn get hasPendingChanges =>
      boolean().withDefault(const Constant(false))();

  /// Version number for conflict resolution
  IntColumn get version => integer().withDefault(const Constant(1))();

  /// Soft delete flag - true if deleted locally pending sync
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// Last successful sync timestamp
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  /// Set id as primary key
  @override
  Set<Column> get primaryKey => {id};
}

/// Users table
///
/// Caches user profile data locally for offline access.
/// Primary source is AWS Cognito + user profile service.
@DataClassName('LocalUser')
@TableIndex(name: 'idx_users_id', columns: {#id})
class Users extends Table {
  /// Primary key - matches user ID from Cognito
  TextColumn get id => text()();

  /// User's email address
  TextColumn get email => text()();

  /// User's username
  TextColumn get username => text()();

  /// Display name (may differ from username)
  TextColumn get displayName => text()();

  /// Optional profile bio
  TextColumn get bio => text().nullable()();

  /// Optional avatar URL
  TextColumn get avatarUrl => text().nullable()();

  /// Whether profile is public
  BoolColumn get isPublic => boolean().withDefault(const Constant(false))();

  /// List of interests (stored as JSON array)
  TextColumn get interests => text().nullable()();

  /// User preferences map (stored as JSON object)
  TextColumn get preferences => text().nullable()();

  /// Timestamp when user was created
  DateTimeColumn get createdAt => dateTime()();

  /// Timestamp when user was last updated
  DateTimeColumn get updatedAt => dateTime()();

  /// Last login timestamp
  DateTimeColumn get lastLoginAt => dateTime().nullable()();

  // ==============================================================================
  // SYNC FIELDS - Track synchronization state
  // ==============================================================================

  /// Whether this record has been synced with the server
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  /// Whether this record has local modifications pending sync
  BoolColumn get hasPendingChanges =>
      boolean().withDefault(const Constant(false))();

  /// Version number for conflict resolution
  IntColumn get version => integer().withDefault(const Constant(1))();

  /// Last successful sync timestamp
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  /// Set id as primary key
  @override
  Set<Column> get primaryKey => {id};
}

/// SyncQueue table
///
/// Tracks operations that need to be synchronized with the server.
/// Operations are queued when offline and processed when connectivity is restored.
@DataClassName('SyncQueueItem')
@TableIndex(name: 'idx_syncqueue_status', columns: {#status})
@TableIndex(name: 'idx_syncqueue_priority', columns: {#priority})
@TableIndex(name: 'idx_syncqueue_entityType', columns: {#entityType})
@TableIndex(name: 'idx_syncqueue_status_priority', columns: {#status, #priority})
class SyncQueue extends Table {
  /// Primary key - local unique identifier
  IntColumn get id => integer().autoIncrement()();

  /// Entity type being synced (e.g., 'trip', 'journal', 'user')
  TextColumn get entityType => text()();

  /// Entity ID that this operation applies to
  TextColumn get entityId => text()();

  /// Operation type: 'create', 'update', 'delete'
  TextColumn get operation => text()();

  /// Operation data payload (JSON encoded)
  /// Contains the full entity data for create/update operations
  TextColumn get data => text()();

  /// Sync priority: 'high', 'normal', 'low'
  /// High priority: user-initiated actions
  /// Normal priority: background data
  /// Low priority: analytics, logging
  TextColumn get priority => text().withDefault(const Constant('normal'))();

  /// Number of retry attempts
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  /// Maximum retry attempts before marking as failed
  IntColumn get maxRetries => integer().withDefault(const Constant(3))();

  /// Operation status: 'pending', 'processing', 'completed', 'failed'
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// Error message if operation failed
  TextColumn get errorMessage => text().nullable()();

  /// Timestamp when operation was queued
  DateTimeColumn get createdAt => dateTime()();

  /// Timestamp when operation was last attempted
  DateTimeColumn get lastAttemptedAt => dateTime().nullable()();

  /// Timestamp when operation completed or failed
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// Optional version for conflict resolution
  IntColumn get version => integer().nullable()();
}

/// SyncMetadata table
///
/// Tracks synchronization state and metadata for the offline-first system.
/// Maintains one row per entity type with the last sync timestamp and state.
@DataClassName('SyncMetadata')
@TableIndex(name: 'idx_syncmetadata_entityType', columns: {#entityType})
class SyncMetadataTable extends Table {
  /// Primary key - entity type name (e.g., 'trips', 'journals', 'users')
  TextColumn get entityType => text()();

  /// User ID for multi-user sync tracking (optional for single-user apps)
  TextColumn get userId => text().nullable()();

  /// Last successful sync timestamp for this entity type
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  /// Last incremental sync timestamp for delta updates
  DateTimeColumn get lastIncrementalSyncAt => dateTime().nullable()();

  /// Last sync attempt timestamp (may be successful or failed)
  DateTimeColumn get lastSyncAttemptAt => dateTime().nullable()();

  /// Last sync status: 'success', 'failed', 'partial'
  TextColumn get lastSyncStatus => text().nullable()();

  /// Error message if last sync failed
  TextColumn get lastSyncError => text().nullable()();

  /// Version vector or token for incremental sync
  TextColumn get syncToken => text().nullable()();

  /// Number of pending operations for this entity type
  IntColumn get pendingCount => integer().withDefault(const Constant(0))();

  /// Number of failed operations for this entity type
  IntColumn get failedCount => integer().withDefault(const Constant(0))();

  /// Timestamp when metadata was last updated
  DateTimeColumn get updatedAt => dateTime()();

  /// Set entityType as primary key
  @override
  Set<Column> get primaryKey => {entityType};
}

/// Itineraries table
///
/// Stores trip itineraries with day-by-day planning.
/// Supports offline access and automatic synchronization with the server.
@DataClassName('LocalItinerary')
@TableIndex(name: 'idx_itineraries_userId', columns: {#userId})
@TableIndex(name: 'idx_itineraries_isSynced', columns: {#isSynced})
class Itineraries extends Table {
  /// Primary key - matches server-generated itinerary ID
  TextColumn get id => text()();

  /// User ID who owns this itinerary
  TextColumn get userId => text()();

  /// Itinerary name/title
  TextColumn get name => text()();

  /// Destination place ID (Google Places API)
  TextColumn get destinationPlaceId => text()();

  /// Destination name
  TextColumn get destinationName => text()();

  /// Destination latitude coordinate
  RealColumn get destinationLatitude => real()();

  /// Destination longitude coordinate
  RealColumn get destinationLongitude => real()();

  /// Destination airport code (optional)
  TextColumn get destinationAirportCode => text().nullable()();

  /// Trip start date
  DateTimeColumn get startDate => dateTime()();

  /// Trip end date
  DateTimeColumn get endDate => dateTime()();

  /// Number of days in the itinerary
  IntColumn get numberOfDays => integer()();

  /// Whether this is a starter itinerary (generated during onboarding)
  BoolColumn get isStarter => boolean().withDefault(const Constant(false))();

  /// Optional cover image URL
  TextColumn get coverImageUrl => text().nullable()();

  /// Total number of items in the itinerary (cached for performance)
  IntColumn get itemsCount => integer().withDefault(const Constant(0))();

  /// Number of completed items (cached for performance)
  IntColumn get completedItemsCount =>
      integer().withDefault(const Constant(0))();

  /// Completion percentage (cached for performance)
  IntColumn get completionPercentage =>
      integer().withDefault(const Constant(0))();

  /// Timestamp when itinerary was created on server
  DateTimeColumn get createdAt => dateTime()();

  /// Timestamp when itinerary was last updated on server
  DateTimeColumn get updatedAt => dateTime()();

  // ==============================================================================
  // SYNC FIELDS - Track synchronization state
  // ==============================================================================

  /// Whether this record has been synced with the server
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  /// Whether this record has local modifications pending sync
  BoolColumn get hasPendingChanges =>
      boolean().withDefault(const Constant(false))();

  /// Version number for conflict resolution
  IntColumn get version => integer().withDefault(const Constant(1))();

  /// Soft delete flag - true if deleted locally pending sync
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// Last successful sync timestamp
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  /// Set id as primary key
  @override
  Set<Column> get primaryKey => {id};
}

/// ItineraryItems table
///
/// Stores individual items within an itinerary (activities, meals, flights, etc.).
/// Supports offline access and automatic synchronization with the server.
@DataClassName('LocalItineraryItem')
@TableIndex(name: 'idx_itineraryitems_itineraryId', columns: {#itineraryId})
@TableIndex(name: 'idx_itineraryitems_id', columns: {#id})
class ItineraryItems extends Table {
  /// Primary key - matches server-generated item ID
  TextColumn get id => text()();

  /// Foreign key to parent itinerary
  TextColumn get itineraryId => text()();

  /// Item type: 'flight_arrival', 'flight_departure', 'hotel_check_in',
  /// 'hotel_check_out', 'activity', 'lunch', 'dinner'
  TextColumn get type => text()();

  /// Item time (date and time)
  DateTimeColumn get time => dateTime()();

  /// Whether the item is completed
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  /// Optional item name
  TextColumn get name => text().nullable()();

  /// Optional note/description
  TextColumn get note => text().nullable()();

  /// Optional location name/address
  TextColumn get location => text().nullable()();

  /// Optional latitude coordinate
  RealColumn get latitude => real().nullable()();

  /// Optional longitude coordinate
  RealColumn get longitude => real().nullable()();

  /// Day number in the itinerary (1-based)
  IntColumn get dayNumber => integer()();

  /// Sort order within the day (for ordering items)
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Timestamp when item was created on server
  DateTimeColumn get createdAt => dateTime()();

  /// Timestamp when item was last updated on server
  DateTimeColumn get updatedAt => dateTime()();

  // ==============================================================================
  // SYNC FIELDS - Track synchronization state
  // ==============================================================================

  /// Whether this record has been synced with the server
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  /// Whether this record has local modifications pending sync
  BoolColumn get hasPendingChanges =>
      boolean().withDefault(const Constant(false))();

  /// Version number for conflict resolution
  IntColumn get version => integer().withDefault(const Constant(1))();

  /// Soft delete flag - true if deleted locally pending sync
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// Last successful sync timestamp
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  /// Set id as primary key
  @override
  Set<Column> get primaryKey => {id};
}
