import 'package:drift/drift.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/itinerary_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';
import 'package:soloadventurer/features/travel/data/models/itinerary_local_model.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary_item.dart';
import 'itinerary_local_data_source.dart';

/// Production implementation of ItineraryLocalDataSource
///
/// Uses the ItineraryDao from the offline database to provide real
/// data persistence for itinerary operations in the recommendations feature.
class ItineraryLocalDataSourceImpl implements ItineraryLocalDataSource {
  final ItineraryDao _dao;

  /// Creates a new [ItineraryLocalDataSourceImpl]
  ///
  /// The [dao] parameter provides database access through the ItineraryDao.
  ItineraryLocalDataSourceImpl(this._dao);

  @override
  Future<ItineraryItem> addItem(String itineraryId, ItineraryItem item) async {
    try {
      // Get the itinerary to calculate day number and sort order
      final localItinerary = await _dao.getItineraryById(itineraryId);
      if (localItinerary == null) {
        throw const CacheException(
          message: 'Itinerary not found',
          code: 'itinerary_not_found',
        );
      }

      // Calculate day number from item time
      final dayNumber = _calculateDayNumber(
        localItinerary.startDate,
        localItinerary.endDate,
        item.time,
      );

      // Get current max sort order for this day
      final dayItems = await _dao.getItemsByDay(itineraryId, dayNumber);
      final maxSortOrder = dayItems.isEmpty
          ? 0
          : dayItems.map((i) => i.sortOrder).reduce((a, b) => a > b ? a : b);

      // Convert domain model to database entity
      final localItem = item.toDatabaseEntity(
        itineraryId: itineraryId,
        dayNumber: dayNumber,
        sortOrder: maxSortOrder + 1,
      );

      // Insert the item
      await _dao.insertItineraryItem(
        ItineraryItemsCompanion(
          id: Value(localItem.id),
          itineraryId: Value(localItem.itineraryId),
          type: Value(localItem.type),
          time: Value(localItem.time),
          isCompleted: Value(localItem.isCompleted),
          name: Value(localItem.name),
          note: Value(localItem.note),
          location: Value(localItem.location),
          latitude: Value(localItem.latitude),
          longitude: Value(localItem.longitude),
          dayNumber: Value(localItem.dayNumber),
          sortOrder: Value(localItem.sortOrder),
          createdAt: Value(localItem.createdAt),
          updatedAt: Value(localItem.updatedAt),
          isSynced: const Value(false),
          hasPendingChanges: const Value(true),
          version: const Value(1),
          isDeleted: const Value(false),
          lastSyncedAt: const Value(null),
        ),
      );

      // Update completion stats
      await _dao.updateItineraryCompletionStats(itineraryId);

      return item;
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(
        message: 'Failed to add item to itinerary: ${e.toString()}',
        code: 'itinerary_item_add_failed',
      );
    }
  }

  @override
  Future<Itinerary> getItinerary(String itineraryId) async {
    try {
      final localItinerary = await _dao.getItineraryById(itineraryId);
      if (localItinerary == null) {
        throw const CacheException(
          message: 'Itinerary not found',
          code: 'itinerary_not_found',
        );
      }

      final items = await _dao.getItemsByItineraryId(itineraryId);
      return localItinerary.toDomainEntity(items);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get itinerary: ${e.toString()}',
        code: 'itinerary_fetch_failed',
      );
    }
  }

  /// Calculates the day number (1-based) for a given datetime
  ///
  /// The [startDate] and [endDate] define the itinerary date range.
  /// The [itemTime] is the time of the item being added.
  /// Returns the day number clamped to the valid range.
  int _calculateDayNumber(
    DateTime startDate,
    DateTime endDate,
    DateTime itemTime,
  ) {
    final dayDiff = itemTime.difference(startDate).inDays;
    final numberOfDays = endDate.difference(startDate).inDays + 1;
    return (dayDiff + 1).clamp(1, numberOfDays);
  }
}
