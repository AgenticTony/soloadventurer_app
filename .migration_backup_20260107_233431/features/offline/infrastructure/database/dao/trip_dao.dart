import 'package:drift/drift.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';

/// Data Access Object for Trips table
///
/// Provides type-safe database operations for trip data.
/// Supports offline-first scenarios with sync-aware queries.
class TripDao extends DatabaseAccessor<AppDatabase> {
  /// Creates a new TripDao
  ///
  /// The [db] parameter is the AppDatabase instance.
  TripDao(super.db);

  // ==============================================================================
  // CRUD OPERATIONS
  // ==============================================================================

  /// Inserts a new trip into the database
  ///
  /// The [trip] parameter is a LocalTrip object with trip data.
  /// Returns the inserted trip with the database-generated ID (if applicable).
  ///
  /// Throws [InvalidDataException] if the trip data is invalid.
  Future<LocalTrip> insertTrip(TripsCompanion trip) async {
    return db.trips.insert(trip);
  }

  /// Inserts multiple trips in a single transaction
  ///
  /// The [trips] parameter is a list of TripsCompanion objects.
  /// Returns the count of trips inserted.
  ///
  /// This is more efficient than inserting trips one by one.
  Future<int> insertTrips(List<TripsCompanion> trips) async {
    return await transaction(() async {
      var count = 0;
      for (final trip in trips) {
        db.trips.insert(trip);
        count++;
      }
      return count;
    });
  }

  /// Updates an existing trip
  ///
  /// The [trip] parameter is a LocalTrip object with updated data.
  /// Returns the number of rows affected (should be 1).
  ///
  /// Uses the trip ID to identify which record to update.
  Future<int> updateTrip(LocalTrip trip) async {
    return await db.trips.update.replace(trip);
  }

  /// Updates multiple trips in a single transaction
  ///
  /// The [trips] parameter is a list of LocalTrip objects.
  /// Returns the count of trips updated.
  ///
  /// This is more efficient than updating trips one by one.
  Future<int> updateTrips(List<LocalTrip> trips) async {
    return await transaction(() async {
      var count = 0;
      for (final trip in trips) {
        count += await db.trips.update.replace(trip);
      }
      return count;
    });
  }

  /// Deletes a trip by ID
  ///
  /// The [id] parameter is the trip ID to delete.
  /// Returns the number of rows affected (should be 1 or 0).
  ///
  /// This is a hard delete. For soft delete, use [softDeleteTrip].
  Future<int> deleteTripById(String id) async {
    return await (db.trips.delete..where((t) => t.id.equals(id))).go();
  }

  /// Soft deletes a trip by marking it as deleted
  ///
  /// The [id] parameter is the trip ID to soft delete.
  /// Returns the number of rows affected (should be 1 or 0).
  ///
  /// Soft delete sets isDeleted flag to true, allowing sync to server.
  Future<int> softDeleteTripById(String id) async {
    return await (db.trips.update..where((t) => t.id.equals(id)))
        .write(const TripsCompanion(isDeleted: Value(true)));
  }

  /// Deletes multiple trips by IDs
  ///
  /// The [ids] parameter is a list of trip IDs to delete.
  /// Returns the count of trips deleted.
  ///
  /// This is a hard delete. For soft delete, use [softDeleteTripsByIds].
  Future<int> deleteTripsByIds(List<String> ids) async {
    return await (db.trips.delete..where((t) => t.id.isIn(ids))).go();
  }

  /// Soft deletes multiple trips by marking them as deleted
  ///
  /// The [ids] parameter is a list of trip IDs to soft delete.
  /// Returns the count of trips soft deleted.
  ///
  /// Soft delete sets isDeleted flag to true, allowing sync to server.
  Future<int> softDeleteTripsByIds(List<String> ids) async {
    return await (db.trips.update..where((t) => t.id.isIn(ids)))
        .write(const TripsCompanion(isDeleted: Value(true)));
  }

  // ==============================================================================
  // QUERY OPERATIONS
  // ==============================================================================

  /// Gets a trip by ID
  ///
  /// The [id] parameter is the trip ID to retrieve.
  /// Returns the trip if found, null otherwise.
  Future<LocalTrip?> getTripById(String id) {
    return (select(trips)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Gets all trips for a specific user
  ///
  /// The [userId] parameter is the user ID to filter trips.
  /// Returns a list of trips belonging to the user.
  ///
  /// Excludes soft-deleted trips by default.
  Future<List<LocalTrip>> getTripsByUserId(String userId) {
    return (select(trips)
          ..where((t) => t.userId.equals(userId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Gets all trips in the database
  ///
  /// Returns a list of all trips.
  ///
  /// Excludes soft-deleted trips by default.
  Future<List<LocalTrip>> getAllTrips() {
    return (select(trips)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Gets trips with pagination
  ///
  /// The [limit] parameter is the maximum number of trips to return.
  /// The [offset] parameter is the number of trips to skip.
  /// Returns a list of trips.
  ///
  /// Excludes soft-deleted trips by default.
  Future<List<LocalTrip>> getTripsPaginated({int limit = 20, int offset = 0}) {
    return (select(trips)
          ..where((t) => t.isDeleted.equals(false))
          ..limit(limit, offset: offset)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Gets trips by status
  ///
  /// The [status] parameter is the trip status to filter (e.g., 'planning', 'ongoing').
  /// The [userId] parameter is optional. If provided, filters by user as well.
  /// Returns a list of trips with the specified status.
  Future<List<LocalTrip>> getTripsByStatus(String status, {String? userId}) {
    final query = select(trips)
      ..where((t) => t.status.equals(status))
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.asc(t.startDate)]);

    if (userId != null) {
      query.where((t) => t.userId.equals(userId));
    }

    return query.get();
  }

  /// Gets trips by date range
  ///
  /// The [startDate] parameter is the start of the date range.
  /// The [endDate] parameter is the end of the date range.
  /// The [userId] parameter is optional. If provided, filters by user as well.
  /// Returns a list of trips that fall within the date range.
  Future<List<LocalTrip>> getTripsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? userId,
  }) {
    final query = select(trips)
      ..where((t) => t.startDate.isBiggerOrEqualValue(startDate))
      ..where((t) => t.endDate.isSmallerOrEqualValue(endDate))
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.asc(t.startDate)]);

    if (userId != null) {
      query.where((t) => t.userId.equals(userId));
    }

    return query.get();
  }

  /// Searches trips by title or destination
  ///
  /// The [searchTerm] parameter is the search query.
  /// The [userId] parameter is optional. If provided, filters by user as well.
  /// Returns a list of trips matching the search term.
  Future<List<LocalTrip>> searchTrips(String searchTerm, {String? userId}) {
    final query = select(trips)
      ..where((t) => t.title.contains(searchTerm) |
          t.destination.contains(searchTerm))
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);

    if (userId != null) {
      query.where((t) => t.userId.equals(userId));
    }

    return query.get();
  }

  /// Counts all trips for a user
  ///
  /// The [userId] parameter is the user ID to count trips for.
  /// Returns the count of trips.
  ///
  /// Excludes soft-deleted trips.
  Future<int> countTripsByUserId(String userId) async {
    final query = selectOnly(trips)
      ..addColumns([trips.id.count()])
      ..where(trips.userId.equals(userId))
      ..where(trips.isDeleted.equals(false));

    final result = await query.getSingle();
    return result.read(trips.id.count());
  }

  // ==============================================================================
  // SYNC-AWARE QUERIES
  // ==============================================================================

  /// Gets all trips that are not synced
  ///
  /// Returns a list of trips where isSynced is false.
  ///
  /// These trips need to be synced to the server.
  Future<List<LocalTrip>> getUnsyncedTrips() {
    return (select(trips)
          ..where((t) => t.isSynced.equals(false))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Gets all trips with pending changes
  ///
  /// Returns a list of trips where hasPendingChanges is true.
  ///
  /// These trips have local modifications that need to be synced.
  Future<List<LocalTrip>> getTripsWithPendingChanges() {
    return (select(trips)
          ..where((t) => t.hasPendingChanges.equals(true))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.updatedAt)]))
        .get();
  }

  /// Gets all trips that need sync (unsynced or with pending changes)
  ///
  /// Returns a list of trips that need to be synced to the server.
  Future<List<LocalTrip>> getTripsNeedingSync() {
    return (select(trips)
          ..where((t) => t.isSynced.equals(false) |
              t.hasPendingChanges.equals(true))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.updatedAt)]))
        .get();
  }

  /// Gets soft-deleted trips that need to be synced
  ///
  /// Returns a list of trips where isDeleted is true.
  ///
  /// These trips need to be deleted from the server.
  Future<List<LocalTrip>> getSoftDeletedTrips() {
    return (select(trips)
          ..where((t) => t.isDeleted.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.updatedAt)]))
        .get();
  }

  /// Gets trips by their sync status
  ///
  /// The [synced] parameter indicates whether to get synced or unsynced trips.
  /// Returns a list of trips matching the sync status.
  Future<List<LocalTrip>> getTripsBySyncStatus(bool synced) {
    return (select(trips)
          ..where((t) => t.isSynced.equals(synced))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Updates sync status for a trip
  ///
  /// The [id] parameter is the trip ID.
  /// The [isSynced] parameter indicates the new sync status.
  /// Returns the number of rows affected.
  Future<int> updateTripSyncStatus(String id, bool isSynced) {
    return (db.trips.update..where((t) => t.id.equals(id)))
        .write(TripsCompanion(isSynced: Value(isSynced)));
  }

  /// Updates pending changes flag for a trip
  ///
  /// The [id] parameter is the trip ID.
  /// The [hasPendingChanges] parameter indicates whether there are pending changes.
  /// Returns the number of rows affected.
  Future<int> updateTripPendingChanges(String id, bool hasPendingChanges) {
    return (db.trips.update..where((t) => t.id.equals(id)))
        .write(TripsCompanion(hasPendingChanges: Value(hasPendingChanges)));
  }

  /// Marks a trip as synced
  ///
  /// The [id] parameter is the trip ID.
  /// The [lastSyncedAt] parameter is the timestamp of the sync.
  /// Returns the number of rows affected.
  Future<int> markTripAsSynced(String id, DateTime lastSyncedAt) {
    return (db.trips.update..where((t) => t.id.equals(id))).write(
      TripsCompanion(
        isSynced: const Value(true),
        hasPendingChanges: const Value(false),
        lastSyncedAt: Value(lastSyncedAt),
      ),
    );
  }

  /// Marks multiple trips as synced in a transaction
  ///
  /// The [ids] parameter is a list of trip IDs.
  /// The [lastSyncedAt] parameter is the timestamp of the sync.
  /// Returns the count of trips updated.
  Future<int> markTripsAsSynced(List<String> ids, DateTime lastSyncedAt) {
    return (db.trips.update..where((t) => t.id.isIn(ids))).write(
      TripsCompanion(
        isSynced: const Value(true),
        hasPendingChanges: const Value(false),
        lastSyncedAt: Value(lastSyncedAt),
      ),
    );
  }

  /// Updates version for a trip (after conflict resolution)
  ///
  /// The [id] parameter is the trip ID.
  /// The [version] parameter is the new version number.
  /// Returns the number of rows affected.
  Future<int> updateTripVersion(String id, int version) {
    return (db.trips.update..where((t) => t.id.equals(id)))
        .write(TripsCompanion(version: Value(version)));
  }

  /// Gets all trips updated after a given timestamp
  ///
  /// The [timestamp] parameter is the timestamp to compare against.
  /// Returns a list of trips updated after the timestamp.
  ///
  /// Useful for incremental sync operations.
  Future<List<LocalTrip>> getTripsUpdatedAfter(DateTime timestamp) {
    return (select(trips)
          ..where((t) => t.updatedAt.isBiggerThanValue(timestamp))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.updatedAt)]))
        .get();
  }

  // ==============================================================================
  // BATCH OPERATIONS
  // ==============================================================================

  /// Deletes all soft-deleted trips that have been synced
  ///
  /// Returns the count of trips permanently deleted.
  ///
  /// This is a cleanup operation for trips that were soft deleted
  /// and successfully synced to the server.
  Future<int> cleanupSyncedDeletedTrips() async {
    return await (db.trips.delete
          ..where((t) => t.isDeleted.equals(true))
          ..where((t) => t.isSynced.equals(true)))
        .go();
  }

  /// Deletes all trips for a user
  ///
  /// The [userId] parameter is the user ID.
  /// Returns the count of trips deleted.
  ///
  /// This is a hard delete. For soft delete, use [softDeleteAllTripsForUser].
  Future<int> deleteAllTripsForUser(String userId) async {
    return await (db.trips.delete..where((t) => t.userId.equals(userId))).go();
  }

  /// Soft deletes all trips for a user
  ///
  /// The [userId] parameter is the user ID.
  /// Returns the count of trips soft deleted.
  Future<int> softDeleteAllTripsForUser(String userId) async {
    return await (db.trips.update..where((t) => t.userId.equals(userId)))
        .write(const TripsCompanion(isDeleted: Value(true)));
  }
}
