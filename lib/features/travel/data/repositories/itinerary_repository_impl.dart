import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:soloadventurer/core/error/failures.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/itinerary_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';
import 'package:soloadventurer/features/travel/data/models/itinerary_local_model.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary_item.dart';
import 'package:soloadventurer/features/travel/domain/repositories/itinerary_repository.dart';

/// Implementation of [ItineraryRepository] using local database
///
/// This repository manages itinerary data using the local Drift database
/// via [ItineraryDao]. For production, this should be extended to support
/// remote sync via the offline-aware pattern.
class ItineraryRepositoryImpl implements ItineraryRepository {
  final ItineraryDao _dao;
  final AppDatabase _database;

  /// Creates a new [ItineraryRepositoryImpl]
  ///
  /// The [dao] parameter provides database access.
  /// The [database] parameter is the database instance for transactions.
  ItineraryRepositoryImpl({
    required ItineraryDao dao,
    required AppDatabase database,
  })  : _dao = dao,
        _database = database;

  // ==============================================================================
  // ITINERARY CRUD OPERATIONS
  // ==============================================================================

  @override
  Future<Either<Failure, Itinerary>> getItinerary(String id) async {
    try {
      final localItinerary = await _dao.getItineraryById(id);
      if (localItinerary == null) {
        return left(Failure.notFound(
          message: 'Itinerary not found',
          resourceType: 'Itinerary',
        ));
      }

      final items = await _dao.getItemsByItineraryId(id);
      final itinerary = localItinerary.toDomainEntity(items);

      return right(itinerary);
    } catch (e) {
      return left(Failure.cache(
        message: 'Failed to retrieve itinerary from local database',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Itinerary>>> getItineraries(
      {String? userId}) async {
    try {
      final localItineraries = userId != null
          ? await _dao.getItinerariesByUserId(userId)
          : await _dao.getAllItineraries();

      final itineraries = <Itinerary>[];
      for (final local in localItineraries) {
        final items = await _dao.getItemsByItineraryId(local.id);
        itineraries.add(local.toDomainEntity(items));
      }

      return right(itineraries);
    } catch (e) {
      return left(Failure.cache(
        message: 'Failed to retrieve itineraries from local database',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Itinerary>>> getStarterItineraries() async {
    try {
      final localItineraries = await _dao.getStarterItineraries();

      final itineraries = <Itinerary>[];
      for (final local in localItineraries) {
        final items = await _dao.getItemsByItineraryId(local.id);
        itineraries.add(local.toDomainEntity(items));
      }

      return right(itineraries);
    } catch (e) {
      return left(Failure.cache(
        message: 'Failed to retrieve starter itineraries from local database',
      ));
    }
  }

  @override
  Future<Either<Failure, Itinerary>> createItinerary(
      Itinerary itinerary) async {
    try {
      // Validate itinerary
      if (!itinerary.isValid) {
        return left(Failure.validation(
          message:
              'Itinerary must have a name, valid destination, date range, and at least one item',
        ));
      }

      // Generate ID if not provided
      final id = itinerary.id.isNotEmpty
          ? itinerary.id
          : DateTime.now().millisecondsSinceEpoch.toString();

      // Create the itinerary entity
      final localItinerary = itinerary.copyWith(id: id).toDatabaseEntity();
      final companion = ItinerariesCompanion(
        id: Value(localItinerary.id),
        userId: Value(localItinerary.userId),
        name: Value(localItinerary.name),
        destinationPlaceId: Value(localItinerary.destinationPlaceId),
        destinationName: Value(localItinerary.destinationName),
        destinationLatitude: Value(localItinerary.destinationLatitude),
        destinationLongitude: Value(localItinerary.destinationLongitude),
        destinationAirportCode: Value(localItinerary.destinationAirportCode),
        startDate: Value(localItinerary.startDate),
        endDate: Value(localItinerary.endDate),
        numberOfDays: Value(localItinerary.numberOfDays),
        isStarter: Value(localItinerary.isStarter),
        coverImageUrl: Value(localItinerary.coverImageUrl),
        itemsCount: Value(localItinerary.itemsCount),
        completedItemsCount: Value(localItinerary.completedItemsCount),
        completionPercentage: Value(localItinerary.completionPercentage),
        createdAt: Value(localItinerary.createdAt),
        updatedAt: Value(localItinerary.updatedAt),
        isSynced: const Value(false),
        hasPendingChanges: const Value(true),
        version: const Value(0),
        isDeleted: const Value(false),
        lastSyncedAt: const Value(null),
      );

      // Insert itinerary and items in a transaction
      final created = await _database.transaction(() async {
        await _dao.insertItinerary(companion);

        // Insert items
        var sortOrder = 0;
        for (var day = 1; day <= itinerary.numberOfDays; day++) {
          final dayItems = itinerary.getItemsForDay(day);
          for (final item in dayItems) {
            final localItem = item.toDatabaseEntity(
              itineraryId: id,
              dayNumber: day,
              sortOrder: sortOrder++,
            );
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
                version: const Value(0),
                isDeleted: const Value(false),
                lastSyncedAt: const Value(null),
              ),
            );
          }
        }

        // Return the created itinerary with items
        final createdWithItems = await _dao.getItineraryById(id);
        final createdItems = await _dao.getItemsByItineraryId(id);
        return createdWithItems!.toDomainEntity(createdItems);
      });

      return right(created);
    } catch (e) {
      return left(Failure.cache(
        message: 'Failed to create itinerary in local database',
      ));
    }
  }

  @override
  Future<Either<Failure, Itinerary>> updateItinerary(
    String id,
    Itinerary itinerary,
  ) async {
    try {
      final existing = await _dao.getItineraryById(id);
      if (existing == null) {
        return left(Failure.notFound(
          message: 'Itinerary not found',
          resourceType: 'Itinerary',
        ));
      }

      // Update the itinerary
      final localItinerary = itinerary.toDatabaseEntity();
      await _dao.updateItinerary(localItinerary);

      // Refresh completion stats
      await _dao.updateItineraryCompletionStats(id);

      // Return updated itinerary
      final items = await _dao.getItemsByItineraryId(id);
      final updated = localItinerary.toDomainEntity(items);

      return right(updated);
    } catch (e) {
      return left(Failure.cache(
        message: 'Failed to update itinerary in local database',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItinerary(String id) async {
    try {
      await _dao.softDeleteItineraryById(id);
      return right(null);
    } catch (e) {
      return left(Failure.cache(
        message: 'Failed to delete itinerary from local database',
      ));
    }
  }

  // ==============================================================================
  // ITINERARY ITEM OPERATIONS
  // ==============================================================================

  @override
  Future<Either<Failure, Itinerary>> addItem(
    String itineraryId,
    ItineraryItem item,
  ) async {
    try {
      final itineraryResult = await getItinerary(itineraryId);
      return itineraryResult.fold(
        (failure) => left(failure),
        (itinerary) async {
          // Calculate day number from item time
          final dayNumber = _calculateDayNumber(itinerary, item.time);

          // Get current max sort order for this day
          final dayItems = await _dao.getItemsByDay(itineraryId, dayNumber);
          final maxSortOrder = dayItems.isEmpty
              ? 0
              : dayItems
                  .map((i) => i.sortOrder)
                  .reduce((a, b) => a > b ? a : b);

          // Create the item
          final localItem = item.toDatabaseEntity(
            itineraryId: itineraryId,
            dayNumber: dayNumber,
            sortOrder: maxSortOrder + 1,
          );

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
              version: const Value(0),
              isDeleted: const Value(false),
              lastSyncedAt: const Value(null),
            ),
          );

          // Update completion stats
          await _dao.updateItineraryCompletionStats(itineraryId);

          // Return updated itinerary
          return await getItinerary(itineraryId);
        },
      );
    } catch (e) {
      return left(Failure.cache(
        message: 'Failed to add item to itinerary',
      ));
    }
  }

  @override
  Future<Either<Failure, Itinerary>> updateItem(
    String itineraryId,
    ItineraryItem item,
  ) async {
    try {
      final existing = await _dao.getItemsByItineraryId(itineraryId);
      final existingItem = existing.firstWhere(
        (i) => i.id == item.id,
        orElse: () => throw Exception('Item not found'),
      );

      final dayNumber = await _calculateDayNumberFromTime(
        itineraryId,
        item.time,
      );

      final updatedItem = item.toDatabaseEntity(
        itineraryId: itineraryId,
        dayNumber: dayNumber,
        sortOrder: existingItem.sortOrder,
      );

      await _dao.updateItineraryItem(updatedItem);
      await _dao.updateItineraryCompletionStats(itineraryId);

      return await getItinerary(itineraryId);
    } catch (e) {
      return left(Failure.cache(
        message: 'Failed to update item in itinerary',
      ));
    }
  }

  @override
  Future<Either<Failure, Itinerary>> removeItem(
    String itineraryId,
    String itemId,
  ) async {
    try {
      await _dao.softDeleteItineraryItemById(itemId);
      await _dao.updateItineraryCompletionStats(itineraryId);

      return await getItinerary(itineraryId);
    } catch (e) {
      return left(Failure.cache(
        message: 'Failed to remove item from itinerary',
      ));
    }
  }

  @override
  Future<Either<Failure, Itinerary>> reorderItems(
    String itineraryId,
    List<String> itemIdsInNewOrder,
  ) async {
    try {
      // Get all items for the itinerary
      final allItems = await _dao.getItemsByItineraryId(itineraryId);

      // Update sort orders
      for (var i = 0; i < itemIdsInNewOrder.length; i++) {
        final itemId = itemIdsInNewOrder[i];
        final item = allItems.firstWhere(
          (item) => item.id == itemId,
          orElse: () => throw Exception('Item not found: $itemId'),
        );

        await _dao.updateItineraryItem(
          item.copyWith(sortOrder: i),
        );
      }

      // Return updated itinerary
      return await getItinerary(itineraryId);
    } catch (e) {
      return left(Failure.cache(
        message: 'Failed to reorder items in itinerary',
      ));
    }
  }

  @override
  Future<Either<Failure, Itinerary>> toggleItemCompletion(
    String itineraryId,
    String itemId,
  ) async {
    try {
      await _dao.toggleItemCompletion(itemId);
      await _dao.updateItineraryCompletionStats(itineraryId);

      return await getItinerary(itineraryId);
    } catch (e) {
      return left(Failure.cache(
        message: 'Failed to toggle item completion',
      ));
    }
  }

  // ==============================================================================
  // QUERY OPERATIONS
  // ==============================================================================

  @override
  Future<Either<Failure, List<ItineraryItem>>> getItemsForDay(
    String itineraryId,
    int dayNumber,
  ) async {
    try {
      final items = await _dao.getItemsByDay(itineraryId, dayNumber);
      return right(items.map((item) => item.toDomainEntity()).toList());
    } catch (e) {
      return left(Failure.cache(
        message: 'Failed to retrieve items for day',
      ));
    }
  }

  @override
  Future<Either<Failure, List<ItineraryItem>>> getUncompletedItems(
    String itineraryId,
  ) async {
    try {
      final items = await _dao.getUncompletedItems(itineraryId);
      return right(items.map((item) => item.toDomainEntity()).toList());
    } catch (e) {
      return left(Failure.cache(
        message: 'Failed to retrieve uncompleted items',
      ));
    }
  }

  @override
  Future<Either<Failure, List<ItineraryItem>>> getCompletedItems(
    String itineraryId,
  ) async {
    try {
      final items = await _dao.getCompletedItems(itineraryId);
      return right(items.map((item) => item.toDomainEntity()).toList());
    } catch (e) {
      return left(Failure.cache(
        message: 'Failed to retrieve completed items',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Itinerary>>> getItinerariesByStatus(
    String status, {
    String? userId,
  }) async {
    try {
      final localItineraries = await _database.transaction(() async {
        if (userId != null) {
          return await _database.getItinerariesByStatus(status, userId: userId);
        } else {
          return await _database.getItinerariesByStatus(status);
        }
      });

      final itineraries = <Itinerary>[];
      for (final local in localItineraries) {
        final items = await _dao.getItemsByItineraryId(local.id);
        itineraries.add(local.toDomainEntity(items));
      }

      return right(itineraries);
    } catch (e) {
      return left(Failure.cache(
        message: 'Failed to retrieve itineraries by status',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Itinerary>>> getItinerariesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? userId,
  }) async {
    try {
      final localItineraries = await _database.transaction(() async {
        if (userId != null) {
          return await _database.getItinerariesByDateRange(
            startDate,
            endDate,
            userId: userId,
          );
        } else {
          return await _database.getItinerariesByDateRange(startDate, endDate);
        }
      });

      final itineraries = <Itinerary>[];
      for (final local in localItineraries) {
        final items = await _dao.getItemsByItineraryId(local.id);
        itineraries.add(local.toDomainEntity(items));
      }

      return right(itineraries);
    } catch (e) {
      return left(Failure.cache(
        message: 'Failed to retrieve itineraries by date range',
      ));
    }
  }

  // ==============================================================================
  // HELPER METHODS
  // ==============================================================================

  /// Calculates the day number (-based) for a given datetime
  int _calculateDayNumber(Itinerary itinerary, DateTime dateTime) {
    final dayDiff = dateTime.difference(itinerary.dateRange.start).inDays;
    return (dayDiff + 1).clamp(1, itinerary.numberOfDays);
  }

  /// Calculates the day number from itinerary and item time
  Future<int> _calculateDayNumberFromTime(
      String itineraryId, DateTime time) async {
    final itinerary = await _dao.getItineraryById(itineraryId);
    if (itinerary == null) return 1;

    final dayDiff = time.difference(itinerary.startDate).inDays;
    return (dayDiff + 1).clamp(1, itinerary.numberOfDays);
  }
}

// Extension methods for database queries not in DAO
extension AppDatabaseItineraryExtensions on AppDatabase {
  Future<List<LocalItinerary>> getItinerariesByStatus(
    String status, {
    String? userId,
  }) async {
    final query = select(itineraries)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..where((tbl) => tbl.destinationName
          .equals(status)); // Using destinationName as status placeholder

    if (userId != null) {
      query.where((tbl) => tbl.userId.equals(userId));
    }

    return await query.get();
  }

  Future<List<LocalItinerary>> getItinerariesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? userId,
  }) async {
    final query = select(itineraries)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..where((tbl) => tbl.startDate.isBiggerOrEqualValue(startDate))
      ..where((tbl) => tbl.endDate.isSmallerOrEqualValue(endDate));

    if (userId != null) {
      query.where((tbl) => tbl.userId.equals(userId));
    }

    return await query.get();
  }
}
