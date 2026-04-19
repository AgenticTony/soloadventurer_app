import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/trip_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/journal_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/sync_queue_dao.dart';

void main() {
  late AppDatabase database;
  late TripDao tripDao;
  late JournalDao journalDao;
  late SyncQueueDao syncQueueDao;

  AppDatabase createTestDatabase() {
    return AppDatabase(
      executor: NativeDatabase.memory(logStatements: false),
    );
  }

  setUp(() {
    database = createTestDatabase();
    tripDao = TripDao(database);
    journalDao = JournalDao(database);
    syncQueueDao = SyncQueueDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('Large Dataset Performance Tests', () {
    test('Test with 1000+ trips - Insert performance', () async {
      const int tripCount = 1000;
      final stopwatch = Stopwatch()..start();

      for (int i = 1; i <= tripCount; i++) {
        await tripDao.insertTrip(TripsCompanion.insert(
          id: 'perf-trip-$i',
          userId: i % 10 == 0 ? 'user-2' : 'user-1',
          title: 'Performance Trip $i',
          description:
              Value('Description for trip $i' * 5),
          startDate: DateTime(2024, 1, i % 28 + 1),
          endDate: DateTime(2024, 1, (i % 28 + 1) % 28 + 1),
          destination: 'Destination ${i % 50}',
          status: ['planning', 'ongoing', 'completed'][i % 3],
          budget: 1000 + (i * 100),
          isSynced: Value(i % 2 != 0),
          hasPendingChanges: Value(i % 2 == 0),
          createdAt: DateTime(2024, 1, 1).add(Duration(milliseconds: i)),
          updatedAt: DateTime(2024, 1, 1).add(Duration(milliseconds: i)),
        ));
      }

      final insertTime = stopwatch.elapsedMilliseconds;
      final avgInsertTime = insertTime / tripCount;

      print('Inserted $tripCount trips in ${insertTime}ms');
      print(
          'Average insert time: ${avgInsertTime.toStringAsFixed(2)}ms per trip');

      expect(insertTime, lessThan(60000),
          reason:
              'Inserting 1000 trips should take less than 60 seconds, took ${insertTime}ms');
      expect(avgInsertTime, lessThan(60),
          reason: 'Average insert time should be less than 60ms per trip');
    });

    test('Test with 1000+ trips - Query performance', () async {
      const int tripCount = 1000;
      for (int i = 1; i <= tripCount; i++) {
        await tripDao.insertTrip(TripsCompanion.insert(
          id: 'query-trip-$i',
          userId: 'user-${i % 5}',
          title: 'Query Trip $i',
          startDate: DateTime(2024, i % 12 + 1, 1),
          endDate: DateTime(2024, i % 12 + 1, 10),
          destination: 'Destination ${i % 50}',
          status: ['planning', 'ongoing', 'completed'][i % 3],
          budget: 1000 + (i * 100),
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ));
      }

      final stopwatch = Stopwatch()..start();
      final allTrips = await tripDao.getAllTrips();
      final queryTime = stopwatch.elapsedMilliseconds;

      print('Queried ${allTrips.length} trips in ${queryTime}ms');
      print(
          'Average query time: ${(queryTime / allTrips.length).toStringAsFixed(3)}ms per trip');

      expect(allTrips.length, equals(tripCount));
      expect(queryTime, lessThan(10000),
          reason:
              'Querying 1000 trips should take less than 10 seconds, took ${queryTime}ms');
    });

    test('Test with 10000+ journal entries - Insert performance', () async {
      await tripDao.insertTrip(TripsCompanion.insert(
        id: 'journal-trip',
        userId: 'user-1',
        title: 'Trip with many journals',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        destination: 'World Tour',
        status: 'ongoing',
        budget: 100000,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ));

      const int journalCount = 10000;
      final stopwatch = Stopwatch()..start();

      for (int i = 1; i <= journalCount; i++) {
        await journalDao.insertJournal(JournalsCompanion.insert(
          id: 'perf-journal-$i',
          tripId: 'journal-trip',
          userId: 'user-1',
          title: 'Journal Entry $i',
          content: 'Content for journal entry $i. ' * 20,
          mood: Value(['happy', 'sad', 'excited', 'tired'][i % 4]),
          location: Value('Location ${i % 100}'),
          isSynced: Value(i % 3 != 0),
          hasPendingChanges: Value(i % 2 == 0),
          createdAt: DateTime(2024, 1, 1).add(Duration(days: i ~/ 30)),
          updatedAt: DateTime(2024, 1, 1).add(Duration(days: i ~/ 30)),
        ));
      }

      final insertTime = stopwatch.elapsedMilliseconds;
      final avgInsertTime = insertTime / journalCount;

      print('Inserted $journalCount journal entries in ${insertTime}ms');
      print(
          'Average insert time: ${avgInsertTime.toStringAsFixed(2)}ms per journal');

      expect(insertTime, lessThan(300000),
          reason:
              'Inserting 10000 journals should take less than 5 minutes, took ${insertTime}ms');
      expect(avgInsertTime, lessThan(50),
          reason: 'Average insert time should be less than 50ms per journal');
    });

    test('Test with 10000+ journal entries - Query performance', () async {
      await tripDao.insertTrip(TripsCompanion.insert(
        id: 'query-journal-trip',
        userId: 'user-1',
        title: 'Query Trip',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        destination: 'Test',
        status: 'ongoing',
        budget: 10000,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ));

      const int journalCount = 10000;
      for (int i = 1; i <= journalCount; i++) {
        await journalDao.insertJournal(JournalsCompanion.insert(
          id: 'query-journal-$i',
          tripId: 'query-journal-trip',
          userId: 'user-1',
          title: 'Journal $i',
          content: 'Content $i',
          createdAt: DateTime(2024, 1, 1).add(Duration(days: i % 365)),
          updatedAt: DateTime(2024, 1, 1).add(Duration(days: i % 365)),
        ));
      }

      final stopwatch = Stopwatch()..start();
      final journals =
          await journalDao.getJournalsByTripId('query-journal-trip');
      final queryTime = stopwatch.elapsedMilliseconds;

      print('Queried ${journals.length} journals in ${queryTime}ms');
      print(
          'Average query time: ${(queryTime / journals.length).toStringAsFixed(3)}ms per journal');

      expect(journals.length, equals(journalCount));
      expect(queryTime, lessThan(15000),
          reason:
              'Querying 10000 journals should take less than 15 seconds, took ${queryTime}ms');
    });

    test('Pagination performance with large dataset', () async {
      const int tripCount = 1000;
      for (int i = 1; i <= tripCount; i++) {
        await tripDao.insertTrip(TripsCompanion.insert(
          id: 'page-trip-$i',
          userId: 'user-1',
          title: 'Trip $i',
          startDate: DateTime(2024, 1, i % 28 + 1),
          endDate: DateTime(2024, 1, (i % 28 + 1) % 28 + 1),
          destination: 'Destination ${i % 50}',
          status: 'planning',
          budget: 1000 * i,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ));
      }

      final stopwatch = Stopwatch()..start();

      const pageSize = 50;
      final pageCount = (tripCount / pageSize).ceil();
      final List<List<LocalTrip>> pages = [];

      for (int page = 0; page < pageCount; page++) {
        final pageData = await tripDao.getTripsPaginated(
          limit: pageSize,
          offset: page * pageSize,
        );
        pages.add(pageData);
      }

      final totalTime = stopwatch.elapsedMilliseconds;
      final avgPageTime = totalTime / pageCount;

      print('Retrieved $pageCount pages in ${totalTime}ms');
      print('Average page retrieval time: ${avgPageTime.toStringAsFixed(2)}ms');
      print(
          'Total trips retrieved: ${pages.fold<int>(0, (sum, page) => sum + page.length)}');

      expect(pages.fold<int>(0, (sum, page) => sum + page.length),
          equals(tripCount));
      expect(avgPageTime, lessThan(100),
          reason: 'Average page retrieval should be less than 100ms');
    });

    test('Filtered query performance with large dataset', () async {
      const int tripCount = 1000;
      for (int i = 1; i <= tripCount; i++) {
        await tripDao.insertTrip(TripsCompanion.insert(
          id: 'filter-trip-$i',
          userId: 'user-${i % 5}',
          title: 'Trip $i',
          startDate: DateTime(2024, i % 12 + 1, 1),
          endDate: DateTime(2024, i % 12 + 1, 10),
          destination: 'Destination ${i % 20}',
          status: ['planning', 'ongoing', 'completed'][i % 3],
          budget: 1000 + (i * 100),
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ));
      }

      final stopwatch = Stopwatch()..start();
      final planningTrips = await tripDao.getTripsByStatus('planning');
      final filterTime = stopwatch.elapsedMilliseconds;

      print('Found ${planningTrips.length} planning trips in ${filterTime}ms');

      expect(planningTrips.isNotEmpty, isTrue);
      expect(filterTime, lessThan(5000),
          reason:
              'Filtered query should take less than 5 seconds, took ${filterTime}ms');
    });

    test('Search performance with large dataset', () async {
      const int tripCount = 1000;
      final destinations = List.generate(100, (i) => 'City $i');
      for (int i = 1; i <= tripCount; i++) {
        await tripDao.insertTrip(TripsCompanion.insert(
          id: 'search-trip-$i',
          userId: 'user-1',
          title: 'Trip to ${destinations[i % 100]}',
          startDate: DateTime(2024, i % 12 + 1, 1),
          endDate: DateTime(2024, i % 12 + 1, 10),
          destination: destinations[i % 100],
          status: 'planning',
          budget: 1000 * i,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ));
      }

      final stopwatch = Stopwatch()..start();
      final results = await tripDao.searchTrips('City 5');
      final searchTime = stopwatch.elapsedMilliseconds;

      print('Search returned ${results.length} results in ${searchTime}ms');

      expect(results.isNotEmpty, isTrue);
      expect(searchTime, lessThan(3000),
          reason:
              'Search query should take less than 3 seconds, took ${searchTime}ms');
    });

    test('Sync queue performance with large operations', () async {
      const int operationCount = 1000;
      final stopwatch = Stopwatch()..start();

      for (int i = 1; i <= operationCount; i++) {
        await syncQueueDao.enqueueOperation(SyncQueueCompanion.insert(
          entityType: ['trip', 'journal', 'user'][i % 3],
          entityId: 'entity-$i',
          operation: ['create', 'update', 'delete'][i % 3],
          data: '{"data":"$i"}',
          status: const Value('pending'),
          priority: const Value('normal'),
          createdAt: DateTime(2024, 1, 1).add(Duration(milliseconds: i)),
        ));
      }

      final enqueueTime = stopwatch.elapsedMilliseconds;
      final avgEnqueueTime = enqueueTime / operationCount;

      print('Enqueued $operationCount operations in ${enqueueTime}ms');
      print(
          'Average enqueue time: ${avgEnqueueTime.toStringAsFixed(2)}ms per operation');

      expect(enqueueTime, lessThan(60000),
          reason:
              'Enqueueing 1000 operations should take less than 60 seconds');
      expect(avgEnqueueTime, lessThan(60),
          reason: 'Average enqueue time should be less than 60ms');
    });

    test('Pending operations query performance', () async {
      const int operationCount = 1000;
      for (int i = 1; i <= operationCount; i++) {
        await syncQueueDao.enqueueOperation(SyncQueueCompanion.insert(
          entityType: 'trip',
          entityId: 'trip-$i',
          operation: 'update',
          data: '{"data":"$i"}',
          status: Value(i % 3 == 0 ? 'completed' : 'pending'),
          createdAt: DateTime(2024, 1, 1),
        ));
      }

      final stopwatch = Stopwatch()..start();
      final pendingOps = await syncQueueDao.getPendingOperations();
      final queryTime = stopwatch.elapsedMilliseconds;

      print('Found ${pendingOps.length} pending operations in ${queryTime}ms');

      expect(pendingOps.length, greaterThan(0));
      expect(queryTime, lessThan(5000),
          reason:
              'Querying pending operations should take less than 5 seconds');
    });

    test('Batch update performance', () async {
      const int tripCount = 500;
      for (int i = 1; i <= tripCount; i++) {
        await tripDao.insertTrip(TripsCompanion.insert(
          id: 'batch-trip-$i',
          userId: 'user-1',
          title: 'Trip $i',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 10),
          destination: 'Destination $i',
          status: 'planning',
          budget: 1000,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ));
      }

      final stopwatch = Stopwatch()..start();
      await database.transaction(() async {
        for (int i = 1; i <= tripCount; i++) {
          final trip = await tripDao.getTripById('batch-trip-$i');
          if (trip != null) {
            await tripDao.updateTrip(trip.copyWith(
              budget: trip.budget * 2,
              updatedAt: DateTime.now(),
            ));
          }
        }
      });
      final updateTime = stopwatch.elapsedMilliseconds;

      print('Updated $tripCount trips in ${updateTime}ms');
      print(
          'Average update time: ${(updateTime / tripCount).toStringAsFixed(2)}ms per trip');

      expect(updateTime, lessThan(60000),
          reason: 'Batch updating 500 trips should take less than 60 seconds');
    });

    test('Concurrent read performance', () async {
      const int tripCount = 1000;
      for (int i = 1; i <= tripCount; i++) {
        await tripDao.insertTrip(TripsCompanion.insert(
          id: 'concurrent-trip-$i',
          userId: 'user-1',
          title: 'Trip $i',
          startDate: DateTime(2024, 1, i % 28 + 1),
          endDate: DateTime(2024, 1, (i % 28 + 1) % 28 + 1),
          destination: 'Destination $i',
          status: 'planning',
          budget: 1000 * i,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ));
      }

      final stopwatch = Stopwatch()..start();
      final futures = List.generate(
        20,
        (index) => tripDao.getTripsPaginated(limit: 50, offset: index * 50),
      );

      final results = await Future.wait(futures);
      final totalTime = stopwatch.elapsedMilliseconds;

      final totalRetrieved =
          results.fold<int>(0, (sum, list) => sum + list.length);

      print(
          'Retrieved $totalRetrieved trips across ${results.length} concurrent queries in ${totalTime}ms');
      print(
          'Average query time: ${(totalTime / results.length).toStringAsFixed(2)}ms per query');

      expect(totalRetrieved, equals(tripCount));
      expect(totalTime, lessThan(10000),
          reason: 'Concurrent queries should complete in less than 10 seconds');
    });

    test('Index effectiveness test', () async {
      for (int i = 1; i <= 1000; i++) {
        await tripDao.insertTrip(TripsCompanion.insert(
          id: 'index-trip-$i',
          userId: 'user-${i % 10}',
          title: 'Trip $i',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 10),
          destination: 'Destination $i',
          status: ['planning', 'ongoing', 'completed'][i % 3],
          budget: 1000 * i,
          isSynced: Value(i % 2 == 0),
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ));
      }

      final stopwatch = Stopwatch()..start();

      final userTrips = await tripDao.getTripsByUserId('user-1');
      final indexedTime1 = stopwatch.elapsedMilliseconds;

      stopwatch.reset();
      stopwatch.start();

      final unsyncedTrips = await tripDao.getUnsyncedTrips();
      final indexedTime2 = stopwatch.elapsedMilliseconds;

      print(
          'Query by user_id (indexed): ${indexedTime1}ms for ${userTrips.length} trips');
      print(
          'Query unsynced (indexed): ${indexedTime2}ms for ${unsyncedTrips.length} trips');

      expect(indexedTime1, lessThan(1000),
          reason: 'Indexed query should be very fast (< 1s)');
      expect(indexedTime2, lessThan(1000),
          reason: 'Indexed query should be very fast (< 1s)');
    });
  });

  group('Sync Performance Tests', () {
    test('Simulated sync time for large dataset', () async {
      const int tripCount = 500;
      for (int i = 1; i <= tripCount; i++) {
        await tripDao.insertTrip(TripsCompanion.insert(
          id: 'sync-trip-$i',
          userId: 'user-1',
          title: 'Sync Trip $i',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 10),
          destination: 'Destination',
          status: 'planning',
          budget: 1000,
          isSynced: const Value(false),
          hasPendingChanges: const Value(true),
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ));

        await syncQueueDao.enqueueOperation(SyncQueueCompanion.insert(
          entityType: 'trip',
          entityId: 'sync-trip-$i',
          operation: 'create',
          data: '{"title":"Sync Trip $i"}',
          status: const Value('pending'),
          createdAt: DateTime(2024, 1, 1),
        ));
      }

      final stopwatch = Stopwatch()..start();

      final pendingOps = await syncQueueDao.getPendingOperations();
      final queryTime = stopwatch.elapsedMilliseconds;

      stopwatch.reset();
      stopwatch.start();

      for (final op in pendingOps) {
        await syncQueueDao.markAsCompleted(op.id);
      }
      final processTime = stopwatch.elapsedMilliseconds;

      final totalSyncTime = queryTime + processTime;

      print(
          'Queried ${pendingOps.length} pending operations in ${queryTime}ms');
      print('Processed ${pendingOps.length} operations in ${processTime}ms');
      print('Total sync time: ${totalSyncTime}ms');
      print(
          'Average sync time per operation: ${(totalSyncTime / pendingOps.length).toStringAsFixed(2)}ms');

      expect(totalSyncTime, lessThan(60000),
          reason: 'Syncing 500 operations should take less than 60 seconds');
    });

    test('Incremental sync performance', () async {
      for (int i = 1; i <= 500; i++) {
        await tripDao.insertTrip(TripsCompanion.insert(
          id: 'incremental-trip-$i',
          userId: 'user-1',
          title: 'Trip $i',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 10),
          destination: 'Destination',
          status: 'planning',
          budget: 1000,
          isSynced: const Value(true),
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ));
      }

      final stopwatch = Stopwatch()..start();

      for (int i = 501; i <= 510; i++) {
        await tripDao.insertTrip(TripsCompanion.insert(
          id: 'incremental-trip-$i',
          userId: 'user-1',
          title: 'New Trip $i',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 10),
          destination: 'Destination',
          status: 'planning',
          budget: 1000,
          isSynced: const Value(false),
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ));
      }

      final unsyncedTrips = await tripDao.getUnsyncedTrips();
      final incrementalSyncTime = stopwatch.elapsedMilliseconds;

      print(
          'Incremental sync found ${unsyncedTrips.length} unsynced trips in ${incrementalSyncTime}ms');

      expect(unsyncedTrips.length, equals(10));
      expect(incrementalSyncTime, lessThan(5000),
          reason: 'Incremental sync should be very fast for few changes');
    });
  });
}
