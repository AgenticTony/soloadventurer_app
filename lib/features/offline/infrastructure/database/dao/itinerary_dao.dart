import 'package:drift/drift.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';

/// Data Access Object for Itineraries and ItineraryItems tables
///
/// Provides type-safe database operations for itinerary data.
/// Supports offline-first scenarios with sync-aware queries.
///
/// This DAO manages both:
/// - **Itineraries**: Top-level trip itineraries
/// - **ItineraryItems**: Individual items within an itinerary
class ItineraryDao extends DatabaseAccessor<AppDatabase> {
  /// Creates a new ItineraryDao
  ///
  /// The [db] parameter is the AppDatabase instance.
  ItineraryDao(super.db);

  // ==============================================================================
  // ITINERARIES CRUD OPERATIONS
  // ==============================================================================

  /// Inserts a new itinerary into the database
  ///
  /// The [itinerary] parameter is an ItinerariesCompanion object with itinerary data.
  /// Returns the inserted itinerary ID.
  Future<int> insertItinerary(ItinerariesCompanion itinerary) async {
    return await into(db.itineraries).insert(itinerary);
  }

  /// Updates an existing itinerary
  ///
  /// The [itinerary] parameter is a LocalItinerary object with updated data.
  /// Returns true if successful, false otherwise.
  Future<bool> updateItinerary(LocalItinerary itinerary) async {
    return await update(db.itineraries).replace(itinerary);
  }

  /// Deletes an itinerary by ID
  ///
  /// The [id] parameter is the itinerary ID to delete.
  /// Returns the number of rows affected (should be 1 or 0).
  ///
  /// **Note**: This is a hard delete. Use [softDeleteItineraryById] for soft delete.
  Future<int> deleteItineraryById(String id) async {
    // First delete all associated items
    await deleteItineraryItemsByItineraryId(id);
    // Then delete the itinerary
    return await (delete(db.itineraries)..where((i) => i.id.equals(id))).go();
  }

  /// Soft deletes an itinerary by marking it as deleted
  ///
  /// The [id] parameter is the itinerary ID to soft delete.
  /// Returns the number of rows affected (should be 1 or 0).
  Future<int> softDeleteItineraryById(String id) async {
    return await (update(db.itineraries)..where((i) => i.id.equals(id)))
        .write(const ItinerariesCompanion(isDeleted: Value(true)));
  }

  /// Gets an itinerary by ID
  ///
  /// The [id] parameter is the itinerary ID to retrieve.
  /// Returns the itinerary if found, null otherwise.
  Future<LocalItinerary?> getItineraryById(String id) {
    return (select(db.itineraries)..where((i) => i.id.equals(id)))
        .getSingleOrNull();
  }

  /// Gets all itineraries for a specific user
  ///
  /// The [userId] parameter is the user ID to filter itineraries.
  /// Returns a list of itineraries belonging to the user.
  ///
  /// Excludes soft-deleted itineraries by default.
  Future<List<LocalItinerary>> getItinerariesByUserId(String userId) {
    return (select(db.itineraries)
          ..where((i) => i.userId.equals(userId))
          ..where((i) => i.isDeleted.equals(false))
          ..orderBy([(i) => OrderingTerm.desc(i.createdAt)]))
        .get();
  }

  /// Gets all itineraries in the database
  ///
  /// Returns a list of all itineraries.
  ///
  /// Excludes soft-deleted itineraries by default.
  Future<List<LocalItinerary>> getAllItineraries() {
    return (select(db.itineraries)
          ..where((i) => i.isDeleted.equals(false))
          ..orderBy([(i) => OrderingTerm.desc(i.createdAt)]))
        .get();
  }

  /// Gets all starter itineraries (generated during onboarding)
  ///
  /// Returns a list of starter itineraries.
  Future<List<LocalItinerary>> getStarterItineraries() {
    return (select(db.itineraries)
          ..where((i) => i.isStarter.equals(true))
          ..where((i) => i.isDeleted.equals(false))
          ..orderBy([(i) => OrderingTerm.desc(i.createdAt)]))
        .get();
  }

  /// Gets itineraries that need sync (unsynced or with pending changes)
  ///
  /// Returns a list of itineraries that need to be synced to the server.
  Future<List<LocalItinerary>> getItinerariesNeedingSync() {
    return (select(db.itineraries)
          ..where((i) =>
              i.isSynced.equals(false) | i.hasPendingChanges.equals(true))
          ..where((i) => i.isDeleted.equals(false))
          ..orderBy([(i) => OrderingTerm.asc(i.updatedAt)]))
        .get();
  }

  // ==============================================================================
  // ITINERARY ITEMS CRUD OPERATIONS
  // ==============================================================================

  /// Inserts a new itinerary item into the database
  ///
  /// The [item] parameter is an ItineraryItemsCompanion object.
  /// Returns the inserted item ID.
  Future<int> insertItineraryItem(ItineraryItemsCompanion item) async {
    return await into(db.itineraryItems).insert(item);
  }

  /// Inserts multiple itinerary items in a single transaction
  ///
  /// The [items] parameter is a list of ItineraryItemsCompanion objects.
  /// Returns the count of items inserted.
  Future<int> insertItineraryItems(List<ItineraryItemsCompanion> items) async {
    return await transaction(() async {
      var count = 0;
      for (final item in items) {
        await into(db.itineraryItems).insert(item);
        count++;
      }
      return count;
    });
  }

  /// Updates an existing itinerary item
  ///
  /// The [item] parameter is a LocalItineraryItem object with updated data.
  /// Returns true if successful, false otherwise.
  Future<bool> updateItineraryItem(LocalItineraryItem item) async {
    return await update(db.itineraryItems).replace(item);
  }

  /// Deletes an itinerary item by ID
  ///
  /// The [id] parameter is the item ID to delete.
  /// Returns the number of rows affected (should be 1 or 0).
  Future<int> deleteItineraryItemById(String id) async {
    return await (delete(db.itineraryItems)..where((i) => i.id.equals(id)))
        .go();
  }

  /// Deletes all items for a specific itinerary
  ///
  /// The [itineraryId] parameter is the parent itinerary ID.
  /// Returns the count of items deleted.
  Future<int> deleteItineraryItemsByItineraryId(String itineraryId) async {
    return await (delete(db.itineraryItems)
          ..where((i) => i.itineraryId.equals(itineraryId)))
        .go();
  }

  /// Soft deletes an itinerary item by marking it as deleted
  ///
  /// The [id] parameter is the item ID to soft delete.
  /// Returns the number of rows affected.
  Future<int> softDeleteItineraryItemById(String id) async {
    return await (update(db.itineraryItems)..where((i) => i.id.equals(id)))
        .write(const ItineraryItemsCompanion(isDeleted: Value(true)));
  }

  /// Gets an itinerary item by ID
  ///
  /// The [id] parameter is the item ID to retrieve.
  /// Returns the item if found, null otherwise.
  Future<LocalItineraryItem?> getItineraryItemById(String id) {
    return (select(db.itineraryItems)..where((i) => i.id.equals(id)))
        .getSingleOrNull();
  }

  /// Gets all items for a specific itinerary
  ///
  /// The [itineraryId] parameter is the parent itinerary ID.
  /// Returns a list of items ordered by day number and sort order.
  ///
  /// Excludes soft-deleted items by default.
  Future<List<LocalItineraryItem>> getItemsByItineraryId(String itineraryId) {
    return (select(db.itineraryItems)
          ..where((i) => i.itineraryId.equals(itineraryId))
          ..where((i) => i.isDeleted.equals(false))
          ..orderBy([
            (i) => OrderingTerm.asc(i.dayNumber),
            (i) => OrderingTerm.asc(i.sortOrder)
          ]))
        .get();
  }

  /// Gets items for a specific day in an itinerary
  ///
  /// The [itineraryId] parameter is the parent itinerary ID.
  /// The [dayNumber] parameter is the day number (1-based).
  /// Returns a list of items for that day.
  Future<List<LocalItineraryItem>> getItemsByDay(
    String itineraryId,
    int dayNumber,
  ) {
    return (select(db.itineraryItems)
          ..where((i) => i.itineraryId.equals(itineraryId))
          ..where((i) => i.dayNumber.equals(dayNumber))
          ..where((i) => i.isDeleted.equals(false))
          ..orderBy([(i) => OrderingTerm.asc(i.sortOrder)]))
        .get();
  }

  /// Gets items grouped by day number for an itinerary
  ///
  /// The [itineraryId] parameter is the parent itinerary ID.
  /// Returns a map where keys are day numbers and values are lists of items.
  Future<Map<int, List<LocalItineraryItem>>> getItemsGroupedByDay(
    String itineraryId,
  ) async {
    final items = await getItemsByItineraryId(itineraryId);
    final Map<int, List<LocalItineraryItem>> grouped = {};
    for (final item in items) {
      grouped.putIfAbsent(item.dayNumber, () => []).add(item);
    }
    return grouped;
  }

  /// Updates the completion status of an itinerary item
  ///
  /// The [itemId] parameter is the item ID.
  /// The [isCompleted] parameter indicates whether the item is completed.
  /// Returns the number of rows affected.
  Future<int> updateItemCompletionStatus(
    String itemId,
    bool isCompleted,
  ) async {
    return await (update(db.itineraryItems)..where((i) => i.id.equals(itemId)))
        .write(ItineraryItemsCompanion(
      isCompleted: Value(isCompleted),
      hasPendingChanges: const Value(true),
    ));
  }

  /// Toggles the completion status of an item
  ///
  /// The [itemId] parameter is the item ID.
  /// Returns the updated item, or null if not found.
  Future<LocalItineraryItem?> toggleItemCompletion(String itemId) async {
    final item = await getItineraryItemById(itemId);
    if (item == null) return null;

    await updateItemCompletionStatus(itemId, !item.isCompleted);
    return await getItineraryItemById(itemId);
  }

  /// Gets all uncompleted items for an itinerary
  ///
  /// The [itineraryId] parameter is the parent itinerary ID.
  /// Returns a list of items where isCompleted is false.
  Future<List<LocalItineraryItem>> getUncompletedItems(String itineraryId) {
    return (select(db.itineraryItems)
          ..where((i) => i.itineraryId.equals(itineraryId))
          ..where((i) => i.isCompleted.equals(false))
          ..where((i) => i.isDeleted.equals(false))
          ..orderBy([
            (i) => OrderingTerm.asc(i.dayNumber),
            (i) => OrderingTerm.asc(i.sortOrder)
          ]))
        .get();
  }

  /// Gets all completed items for an itinerary
  ///
  /// The [itineraryId] parameter is the parent itinerary ID.
  /// Returns a list of items where isCompleted is true.
  Future<List<LocalItineraryItem>> getCompletedItems(String itineraryId) {
    return (select(db.itineraryItems)
          ..where((i) => i.itineraryId.equals(itineraryId))
          ..where((i) => i.isCompleted.equals(true))
          ..where((i) => i.isDeleted.equals(false))
          ..orderBy([
            (i) => OrderingTerm.desc(i.dayNumber),
            (i) => OrderingTerm.desc(i.sortOrder)
          ]))
        .get();
  }

  /// Gets itinerary items that need sync
  ///
  /// Returns a list of items that need to be synced to the server.
  Future<List<LocalItineraryItem>> getItemsNeedingSync() {
    return (select(db.itineraryItems)
          ..where((i) =>
              i.isSynced.equals(false) | i.hasPendingChanges.equals(true))
          ..where((i) => i.isDeleted.equals(false))
          ..orderBy([(i) => OrderingTerm.asc(i.updatedAt)]))
        .get();
  }

  // ==============================================================================
  // SYNC OPERATIONS
  // ==============================================================================

  /// Marks an itinerary as synced
  ///
  /// The [id] parameter is the itinerary ID.
  /// The [lastSyncedAt] parameter is the timestamp of the sync.
  /// Returns the number of rows affected.
  Future<int> markItineraryAsSynced(String id, DateTime lastSyncedAt) {
    return (update(db.itineraries)..where((i) => i.id.equals(id))).write(
      ItinerariesCompanion(
        isSynced: const Value(true),
        hasPendingChanges: const Value(false),
        lastSyncedAt: Value(lastSyncedAt),
      ),
    );
  }

  /// Marks an itinerary item as synced
  ///
  /// The [id] parameter is the item ID.
  /// The [lastSyncedAt] parameter is the timestamp of the sync.
  /// Returns the number of rows affected.
  Future<int> markItemAsSynced(String id, DateTime lastSyncedAt) {
    return (update(db.itineraryItems)..where((i) => i.id.equals(id))).write(
      ItineraryItemsCompanion(
        isSynced: const Value(true),
        hasPendingChanges: const Value(false),
        lastSyncedAt: Value(lastSyncedAt),
      ),
    );
  }

  /// Updates itinerary cached completion stats
  ///
  /// The [itineraryId] parameter is the itinerary ID.
  /// Recalculates and updates itemsCount, completedItemsCount, and completionPercentage.
  Future<int> updateItineraryCompletionStats(String itineraryId) async {
    final allItems = await getItemsByItineraryId(itineraryId);
    final completedItems = allItems.where((i) => i.isCompleted).toList();
    final totalCount = allItems.length;
    final completedCount = completedItems.length;
    final percentage =
        totalCount > 0 ? ((completedCount / totalCount) * 100).round() : 0;

    return (update(db.itineraries)..where((i) => i.id.equals(itineraryId)))
        .write(
      ItinerariesCompanion(
        itemsCount: Value(totalCount),
        completedItemsCount: Value(completedCount),
        completionPercentage: Value(percentage),
      ),
    );
  }
}
