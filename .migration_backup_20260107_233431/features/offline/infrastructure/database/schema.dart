import 'package:drift/drift.dart';

/// Trips table
///
/// Stores trip data locally with sync tracking.
/// Supports offline access and automatic synchronization with the server.
@DataClassName('LocalTrip')
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

  /// Create indexes for common queries
  ///
  /// Note: Indexes are created via custom SQL statements in the migration
  /// strategy (see database.dart) rather than here due to Drift 2.x syntax
  /// limitations. The @Index annotation from Drift 1.x is no longer supported
  /// in Drift 2.x for multi-column indexes.
  List<Index> get indexes => const [];
}

/// Journals table
///
/// Stores journal entries linked to trips with sync tracking.
/// Supports offline access and automatic synchronization with the server.
@DataClassName('LocalJournal')
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

  /// Create indexes for common queries
  ///
  /// Note: Indexes are created via custom SQL statements in the migration
  /// strategy (see database.dart) rather than here due to Drift 2.x syntax
  /// limitations.
  List<Index> get indexes => const [];
}

/// Users table
///
/// Caches user profile data locally for offline access.
/// Primary source is AWS Cognito + user profile service.
@DataClassName('LocalUser')
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

  /// Create indexes for common queries
  ///
  /// Note: Indexes are created via custom SQL statements in the migration
  /// strategy (see database.dart) rather than here due to Drift 2.x syntax
  /// limitations.
  List<Index> get indexes => const [];
}

/// SyncQueue table
///
/// Tracks operations that need to be synchronized with the server.
/// Operations are queued when offline and processed when connectivity is restored.
@DataClassName('SyncQueueItem')
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
  TextColumn get priority => text()
      .withDefault(const Constant('normal'))();

  /// Number of retry attempts
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  /// Maximum retry attempts before marking as failed
  IntColumn get maxRetries => integer().withDefault(const Constant(3))();

  /// Operation status: 'pending', 'processing', 'completed', 'failed'
  TextColumn get status => text()
      .withDefault(const Constant('pending'))();

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

  /// Create indexes for common queries
  ///
  /// Note: Indexes are created via custom SQL statements in the migration
  /// strategy (see database.dart) rather than here due to Drift 2.x syntax
  /// limitations.
  List<Index> get indexes => const [];
}

/// Itineraries table
///
/// Stores itinerary data locally with sync tracking.
/// Supports offline access and automatic synchronization with the server.
/// An itinerary contains a collection of itinerary items (activities, flights, etc.).
@DataClassName('LocalItinerary')
class Itineraries extends Table {
  /// Primary key - matches server-generated itinerary ID
  TextColumn get id => text()();

  /// Optional user ID who owns this itinerary
  /// Null for itineraries created during onboarding before auth
  TextColumn get userId => text().nullable()();

  /// Itinerary name/title
  TextColumn get name => text()();

  /// Destination place ID (from Google Places)
  TextColumn get destinationPlaceId => text()();

  /// Destination name
  TextColumn get destinationName => text()();

  /// Destination latitude
  RealColumn get destinationLatitude => real()();

  /// Destination longitude
  RealColumn get destinationLongitude => real()();

  /// Optional destination airport code
  TextColumn get destinationAirportCode => text().nullable()();

  /// Trip start date
  DateTimeColumn get startDate => dateTime()();

  /// Trip end date
  DateTimeColumn get endDate => dateTime()();

  /// Number of days in itinerary
  IntColumn get numberOfDays => integer()();

  /// Whether this is a starter itinerary (generated during onboarding)
  BoolColumn get isStarter => boolean().withDefault(const Constant(false))();

  /// Optional cover image URL
  TextColumn get coverImageUrl => text().nullable()();

  /// Number of items in itinerary (cached for performance)
  IntColumn get itemsCount => integer().withDefault(const Constant(0))();

  /// Number of completed items (cached for performance)
  IntColumn get completedItemsCount => integer().withDefault(const Constant(0))();

  /// Completion percentage (0-100)
  IntColumn get completionPercentage => integer().withDefault(const Constant(0))();

  /// Timestamp when itinerary was created on server
  DateTimeColumn get createdAt => dateTime()();

  /// Timestamp when itinerary was last updated on server
  DateTimeColumn get updatedAt => dateTime().nullable()();

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

  /// Create indexes for common queries
  ///
  /// Note: Indexes are created via custom SQL statements in the migration
  /// strategy (see database.dart) rather than here due to Drift 2.x syntax
  /// limitations.
  List<Index> get indexes => const [];
}

/// ItineraryItems table
///
/// Stores individual items within an itinerary.
/// Each item represents an activity, flight, hotel, meal, etc.
@DataClassName('LocalItineraryItem')
class ItineraryItems extends Table {
  /// Primary key - matches server-generated item ID
  TextColumn get id => text()();

  /// Foreign key to parent itinerary
  TextColumn get itineraryId => text()();

  /// Item type: flight_arrival, flight_departure, hotel_check_in,
  /// hotel_check_out, activity, lunch, dinner
  TextColumn get type => text()();

  /// Item start/time
  DateTimeColumn get time => dateTime()();

  /// Whether this item is completed
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  /// Item name/title (for activities, meals, etc.)
  TextColumn get name => text().nullable()();

  /// Optional notes/details about the item
  TextColumn get note => text().nullable()();

  /// Optional location name
  TextColumn get location => text().nullable()();

  /// Optional location latitude
  RealColumn get latitude => real().nullable()();

  /// Optional location longitude
  RealColumn get longitude => real().nullable()();

  /// Day number in the itinerary (1-based)
  IntColumn get dayNumber => integer()();

  /// Sort order within the day
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Timestamp when item was created
  DateTimeColumn get createdAt => dateTime()();

  /// Timestamp when item was last updated
  DateTimeColumn get updatedAt => dateTime().nullable()();

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

  /// Create indexes for common queries
  ///
  /// Note: Indexes are created via custom SQL statements in the migration
  /// strategy (see database.dart) rather than here due to Drift 2.x syntax
  /// limitations.
  List<Index> get indexes => const [];
}

/// SyncMetadata table
///
/// Tracks synchronization state and metadata for the offline-first system.
/// Maintains one row per entity type with the last sync timestamp and state.
@DataClassName('SyncMetadata')
class SyncMetadataTable extends Table {
  /// Primary key - entity type name (e.g., 'trips', 'journals', 'users')
  TextColumn get entityType => text()();

  /// Last successful sync timestamp for this entity type
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

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

  /// Create index for finding stale entity types needing sync
  ///
  /// Note: Indexes are created via custom SQL statements in the migration
  /// strategy (see database.dart) rather than here due to Drift 2.x syntax
  /// limitations.
  List<Index> get indexes => const [];
}
