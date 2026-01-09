import 'package:drift/drift.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';

/// Data Access Object for Journals table
///
/// Provides type-safe database operations for journal data.
/// Supports offline-first scenarios with sync-aware queries.
class JournalDao extends DatabaseAccessor<AppDatabase> {
  /// Creates a new JournalDao
  ///
  /// The [db] parameter is the AppDatabase instance.
  JournalDao(super.db);

  // ==============================================================================
  // CRUD OPERATIONS
  // ==============================================================================

  /// Inserts a new journal entry into the database
  ///
  /// The [journal] parameter is a LocalJournal object with journal data.
  /// Returns the inserted journal with the database-generated ID (if applicable).
  ///
  /// Throws [InvalidDataException] if the journal data is invalid.
  Future<int> insertJournal(JournalsCompanion journal) async {
    return await into(db.journals).insert(journal);
  }

  /// Inserts multiple journal entries in a single transaction
  ///
  /// The [journals] parameter is a list of JournalsCompanion objects.
  /// Returns the count of journals inserted.
  ///
  /// This is more efficient than inserting journals one by one.
  Future<int> insertJournals(List<JournalsCompanion> journals) async {
    return await transaction(() async {
      var count = 0;
      for (final journal in journals) {
        await into(db.journals).insert(journal);
        count++;
      }
      return count;
    });
  }

  /// Updates an existing journal entry
  ///
  /// The [journal] parameter is a LocalJournal object with updated data.
  /// Returns the number of rows affected (should be 1).
  ///
  /// Uses the journal ID to identify which record to update.
  Future<bool> updateJournal(LocalJournal journal) async {
    return await update(db.journals).replace(journal);
  }

  /// Updates multiple journal entries in a single transaction
  ///
  /// The [journals] parameter is a list of LocalJournal objects.
  /// Returns the count of journals updated.
  ///
  /// This is more efficient than updating journals one by one.
  Future<int> updateJournals(List<LocalJournal> journals) async {
    return await transaction(() async {
      var count = 0;
      for (final journal in journals) {
        if (await update(db.journals).replace(journal)) {
          count++;
        }
      }
      return count;
    });
  }

  /// Deletes a journal entry by ID
  ///
  /// The [id] parameter is the journal ID to delete.
  /// Returns the number of rows affected (should be 1 or 0).
  ///
  /// This is a hard delete. For soft delete, use [softDeleteJournal].
  Future<int> deleteJournalById(String id) async {
    return await (delete(db.journals)..where((j) => j.id.equals(id))).go();
  }

  /// Soft deletes a journal entry by marking it as deleted
  ///
  /// The [id] parameter is the journal ID to soft delete.
  /// Returns the number of rows affected (should be 1 or 0).
  ///
  /// Soft delete sets isDeleted flag to true, allowing sync to server.
  Future<int> softDeleteJournalById(String id) async {
    return await (update(db.journals)..where((j) => j.id.equals(id)))
        .write(const JournalsCompanion(isDeleted: Value(true)));
  }

  /// Deletes all journals for a trip
  ///
  /// The [tripId] parameter is the trip ID.
  /// Returns the count of journals deleted.
  ///
  /// This is a hard delete. For soft delete, use [softDeleteJournalsByTripId].
  Future<int> deleteJournalsByTripId(String tripId) async {
    return await (delete(db.journals)..where((j) => j.tripId.equals(tripId)))
        .go();
  }

  /// Soft deletes all journals for a trip
  ///
  /// The [tripId] parameter is the trip ID.
  /// Returns the count of journals soft deleted.
  Future<int> softDeleteJournalsByTripId(String tripId) async {
    return await (update(db.journals)..where((j) => j.tripId.equals(tripId)))
        .write(const JournalsCompanion(isDeleted: Value(true)));
  }

  /// Deletes multiple journal entries by IDs
  ///
  /// The [ids] parameter is a list of journal IDs to delete.
  /// Returns the count of journals deleted.
  ///
  /// This is a hard delete. For soft delete, use [softDeleteJournalsByIds].
  Future<int> deleteJournalsByIds(List<String> ids) async {
    return await (delete(db.journals)..where((j) => j.id.isIn(ids))).go();
  }

  /// Soft deletes multiple journal entries by marking them as deleted
  ///
  /// The [ids] parameter is a list of journal IDs to soft delete.
  /// Returns the count of journals soft deleted.
  ///
  /// Soft delete sets isDeleted flag to true, allowing sync to server.
  Future<int> softDeleteJournalsByIds(List<String> ids) async {
    return await (update(db.journals)..where((j) => j.id.isIn(ids)))
        .write(const JournalsCompanion(isDeleted: Value(true)));
  }

  // ==============================================================================
  // QUERY OPERATIONS
  // ==============================================================================

  /// Gets a journal entry by ID
  ///
  /// The [id] parameter is the journal ID to retrieve.
  /// Returns the journal if found, null otherwise.
  Future<LocalJournal?> getJournalById(String id) {
    return (select(db.journals)..where((j) => j.id.equals(id)))
        .getSingleOrNull();
  }

  /// Gets all journals for a specific trip
  ///
  /// The [tripId] parameter is the trip ID to filter journals.
  /// Returns a list of journals belonging to the trip.
  ///
  /// Excludes soft-deleted journals by default.
  /// Ordered by entry date (newest first).
  Future<List<LocalJournal>> getJournalsByTripId(String tripId) {
    return (select(db.journals)
          ..where((j) => j.tripId.equals(tripId))
          ..where((j) => j.isDeleted.equals(false))
          ..orderBy([(j) => OrderingTerm.desc(j.entryDate)]))
        .get();
  }

  /// Gets all journals for a specific user
  ///
  /// The [userId] parameter is the user ID to filter journals.
  /// Returns a list of journals belonging to the user.
  ///
  /// Excludes soft-deleted journals by default.
  /// Ordered by entry date (newest first).
  Future<List<LocalJournal>> getJournalsByUserId(String userId) {
    return (select(db.journals)
          ..where((j) => j.userId.equals(userId))
          ..where((j) => j.isDeleted.equals(false))
          ..orderBy([(j) => OrderingTerm.desc(j.entryDate)]))
        .get();
  }

  /// Gets all journals in the database
  ///
  /// Returns a list of all journals.
  ///
  /// Excludes soft-deleted journals by default.
  Future<List<LocalJournal>> getAllJournals() {
    return (select(db.journals)
          ..where((j) => j.isDeleted.equals(false))
          ..orderBy([(j) => OrderingTerm.desc(j.createdAt)]))
        .get();
  }

  /// Gets journals with pagination
  ///
  /// The [limit] parameter is the maximum number of journals to return.
  /// The [offset] parameter is the number of journals to skip.
  /// The [tripId] parameter is optional. If provided, filters by trip.
  /// Returns a list of journals.
  ///
  /// Excludes soft-deleted journals by default.
  Future<List<LocalJournal>> getJournalsPaginated({
    int limit = 20,
    int offset = 0,
    String? tripId,
  }) {
    final query = select(db.journals)
      ..where((j) => j.isDeleted.equals(false))
      ..limit(limit, offset: offset)
      ..orderBy([(j) => OrderingTerm.desc(j.entryDate)]);

    if (tripId != null) {
      query.where((j) => j.tripId.equals(tripId));
    }

    return query.get();
  }

  /// Gets journals by mood
  ///
  /// The [mood] parameter is the mood to filter (e.g., 'happy', 'sad', 'excited').
  /// The [userId] parameter is optional. If provided, filters by user as well.
  /// Returns a list of journals with the specified mood.
  Future<List<LocalJournal>> getJournalsByMood(String mood, {String? userId}) {
    final query = select(db.journals)
      ..where((j) => j.mood.equals(mood))
      ..where((j) => j.isDeleted.equals(false))
      ..orderBy([(j) => OrderingTerm.desc(j.entryDate)]);

    if (userId != null) {
      query.where((j) => j.userId.equals(userId));
    }

    return query.get();
  }

  /// Gets journals by date range
  ///
  /// The [startDate] parameter is the start of the date range.
  /// The [endDate] parameter is the end of the date range.
  /// The [tripId] parameter is optional. If provided, filters by trip as well.
  /// Returns a list of journals that fall within the date range.
  Future<List<LocalJournal>> getJournalsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? tripId,
  }) {
    final query = select(db.journals)
      ..where((j) => j.entryDate.isBiggerOrEqualValue(startDate))
      ..where((j) => j.entryDate.isSmallerOrEqualValue(endDate))
      ..where((j) => j.isDeleted.equals(false))
      ..orderBy([(j) => OrderingTerm.desc(j.entryDate)]);

    if (tripId != null) {
      query.where((j) => j.tripId.equals(tripId));
    }

    return query.get();
  }

  /// Gets journals by location
  ///
  /// The [location] parameter is the location name to filter.
  /// The [userId] parameter is optional. If provided, filters by user as well.
  /// Returns a list of journals with the specified location.
  Future<List<LocalJournal>> getJournalsByLocation(String location,
      {String? userId}) {
    final query = select(db.journals)
      ..where((j) => j.location.equals(location))
      ..where((j) => j.isDeleted.equals(false))
      ..orderBy([(j) => OrderingTerm.desc(j.entryDate)]);

    if (userId != null) {
      query.where((j) => j.userId.equals(userId));
    }

    return query.get();
  }

  /// Searches journals by title or content
  ///
  /// The [searchTerm] parameter is the search query.
  /// The [userId] parameter is optional. If provided, filters by user as well.
  /// Returns a list of journals matching the search term.
  Future<List<LocalJournal>> searchJournals(String searchTerm,
      {String? userId}) {
    final query = select(db.journals)
      ..where(
          (j) => j.title.contains(searchTerm) | j.content.contains(searchTerm))
      ..where((j) => j.isDeleted.equals(false))
      ..orderBy([(j) => OrderingTerm.desc(j.entryDate)]);

    if (userId != null) {
      query.where((j) => j.userId.equals(userId));
    }

    return query.get();
  }

  /// Counts all journals for a trip
  ///
  /// The [tripId] parameter is the trip ID to count journals for.
  /// Returns the count of journals.
  ///
  /// Excludes soft-deleted journals.
  Future<int> countJournalsByTripId(String tripId) async {
    final query = selectOnly(db.journals)
      ..addColumns([db.journals.id.count()])
      ..where(db.journals.tripId.equals(tripId))
      ..where(db.journals.isDeleted.equals(false));

    final result = await query.getSingle();
    return result.read(db.journals.id.count()) ?? 0;
  }

  /// Counts all journals for a user
  ///
  /// The [userId] parameter is the user ID to count journals for.
  /// Returns the count of journals.
  ///
  /// Excludes soft-deleted journals.
  Future<int> countJournalsByUserId(String userId) async {
    final query = selectOnly(db.journals)
      ..addColumns([db.journals.id.count()])
      ..where(db.journals.userId.equals(userId))
      ..where(db.journals.isDeleted.equals(false));

    final result = await query.getSingle();
    return result.read(db.journals.id.count()) ?? 0;
  }

  // ==============================================================================
  // SYNC-AWARE QUERIES
  // ==============================================================================

  /// Gets all journals that are not synced
  ///
  /// Returns a list of journals where isSynced is false.
  ///
  /// These journals need to be synced to the server.
  Future<List<LocalJournal>> getUnsyncedJournals() {
    return (select(db.journals)
          ..where((j) => j.isSynced.equals(false))
          ..where((j) => j.isDeleted.equals(false))
          ..orderBy([(j) => OrderingTerm.asc(j.createdAt)]))
        .get();
  }

  /// Gets all journals with pending changes
  ///
  /// Returns a list of journals where hasPendingChanges is true.
  ///
  /// These journals have local modifications that need to be synced.
  Future<List<LocalJournal>> getJournalsWithPendingChanges() {
    return (select(db.journals)
          ..where((j) => j.hasPendingChanges.equals(true))
          ..where((j) => j.isDeleted.equals(false))
          ..orderBy([(j) => OrderingTerm.asc(j.updatedAt)]))
        .get();
  }

  /// Gets all journals that need sync (unsynced or with pending changes)
  ///
  /// Returns a list of journals that need to be synced to the server.
  Future<List<LocalJournal>> getJournalsNeedingSync() {
    return (select(db.journals)
          ..where((j) =>
              j.isSynced.equals(false) | j.hasPendingChanges.equals(true))
          ..where((j) => j.isDeleted.equals(false))
          ..orderBy([(j) => OrderingTerm.asc(j.updatedAt)]))
        .get();
  }

  /// Gets soft-deleted journals that need to be synced
  ///
  /// Returns a list of journals where isDeleted is true.
  ///
  /// These journals need to be deleted from the server.
  Future<List<LocalJournal>> getSoftDeletedJournals() {
    return (select(db.journals)
          ..where((j) => j.isDeleted.equals(true))
          ..orderBy([(j) => OrderingTerm.asc(j.updatedAt)]))
        .get();
  }

  /// Gets journals by their sync status
  ///
  /// The [synced] parameter indicates whether to get synced or unsynced journals.
  /// Returns a list of journals matching the sync status.
  Future<List<LocalJournal>> getJournalsBySyncStatus(bool synced) {
    return (select(db.journals)
          ..where((j) => j.isSynced.equals(synced))
          ..where((j) => j.isDeleted.equals(false))
          ..orderBy([(j) => OrderingTerm.asc(j.createdAt)]))
        .get();
  }

  /// Updates sync status for a journal
  ///
  /// The [id] parameter is the journal ID.
  /// The [isSynced] parameter indicates the new sync status.
  /// Returns the number of rows affected.
  Future<int> updateJournalSyncStatus(String id, bool isSynced) {
    return (update(db.journals)..where((j) => j.id.equals(id)))
        .write(JournalsCompanion(isSynced: Value(isSynced)));
  }

  /// Updates pending changes flag for a journal
  ///
  /// The [id] parameter is the journal ID.
  /// The [hasPendingChanges] parameter indicates whether there are pending changes.
  /// Returns the number of rows affected.
  Future<int> updateJournalPendingChanges(String id, bool hasPendingChanges) {
    return (update(db.journals)..where((j) => j.id.equals(id)))
        .write(JournalsCompanion(hasPendingChanges: Value(hasPendingChanges)));
  }

  /// Marks a journal as synced
  ///
  /// The [id] parameter is the journal ID.
  /// The [lastSyncedAt] parameter is the timestamp of the sync.
  /// Returns the number of rows affected.
  Future<int> markJournalAsSynced(String id, DateTime lastSyncedAt) {
    return (update(db.journals)..where((j) => j.id.equals(id))).write(
      JournalsCompanion(
        isSynced: const Value(true),
        hasPendingChanges: const Value(false),
        lastSyncedAt: Value(lastSyncedAt),
      ),
    );
  }

  /// Marks multiple journals as synced in a transaction
  ///
  /// The [ids] parameter is a list of journal IDs.
  /// The [lastSyncedAt] parameter is the timestamp of the sync.
  /// Returns the count of journals updated.
  Future<int> markJournalsAsSynced(List<String> ids, DateTime lastSyncedAt) {
    return (update(db.journals)..where((j) => j.id.isIn(ids))).write(
      JournalsCompanion(
        isSynced: const Value(true),
        hasPendingChanges: const Value(false),
        lastSyncedAt: Value(lastSyncedAt),
      ),
    );
  }

  /// Updates version for a journal (after conflict resolution)
  ///
  /// The [id] parameter is the journal ID.
  /// The [version] parameter is the new version number.
  /// Returns the number of rows affected.
  Future<int> updateJournalVersion(String id, int version) {
    return (update(db.journals)..where((j) => j.id.equals(id)))
        .write(JournalsCompanion(version: Value(version)));
  }

  /// Gets all journals updated after a given timestamp
  ///
  /// The [timestamp] parameter is the timestamp to compare against.
  /// Returns a list of journals updated after the timestamp.
  ///
  /// Useful for incremental sync operations.
  Future<List<LocalJournal>> getJournalsUpdatedAfter(DateTime timestamp) {
    return (select(db.journals)
          ..where((j) => j.updatedAt.isBiggerThanValue(timestamp))
          ..where((j) => j.isDeleted.equals(false))
          ..orderBy([(j) => OrderingTerm.asc(j.updatedAt)]))
        .get();
  }

  // ==============================================================================
  // BATCH OPERATIONS
  // ==============================================================================

  /// Deletes all soft-deleted journals that have been synced
  ///
  /// Returns the count of journals permanently deleted.
  ///
  /// This is a cleanup operation for journals that were soft deleted
  /// and successfully synced to the server.
  Future<int> cleanupSyncedDeletedJournals() async {
    return await (delete(db.journals)
          ..where((j) => j.isDeleted.equals(true))
          ..where((j) => j.isSynced.equals(true)))
        .go();
  }

  /// Deletes all journals for a user
  ///
  /// The [userId] parameter is the user ID.
  /// Returns the count of journals deleted.
  ///
  /// This is a hard delete. For soft delete, use [softDeleteAllJournalsForUser].
  Future<int> deleteAllJournalsForUser(String userId) async {
    return await (delete(db.journals)..where((j) => j.userId.equals(userId)))
        .go();
  }

  /// Soft deletes all journals for a user
  ///
  /// The [userId] parameter is the user ID.
  /// Returns the count of journals soft deleted.
  Future<int> softDeleteAllJournalsForUser(String userId) async {
    return await (update(db.journals)..where((j) => j.userId.equals(userId)))
        .write(const JournalsCompanion(isDeleted: Value(true)));
  }
}
