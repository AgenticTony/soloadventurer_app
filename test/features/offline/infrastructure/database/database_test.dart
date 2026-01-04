import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/trip_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/journal_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/user_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/sync_queue_dao.dart';
import 'package:path/path.dart' as p;

void main() {
  late AppDatabase database;

  // Create in-memory database for testing
  AppDatabase createTestDatabase() {
    return AppDatabase(
      executor: NativeDatabase.memory(
        logStatements: false,
      ),
    );
  }

  setUp(() {
    database = createTestDatabase();
  });

  tearDown(() async {
    await database.close();
  });

  group('Database Initialization', () {
    test('should initialize database successfully', () async {
      expect(database, isNotNull);
      expect(database.schemaVersion, equals(1));
    });

    test('should verify all tables exist', () async {
      // Try to query each table to verify existence
      final result = await database.customSelect(
        'SELECT name FROM sqlite_master WHERE type="table" ORDER BY name',
      ).get();

      final tableNames = result.map((row) => row.read<String>('name')).toList();

      expect(tableNames, contains('trips'));
      expect(tableNames, contains('journals'));
      expect(tableNames, contains('users'));
      expect(tableNames, contains('sync_queue'));
      expect(tableNames, contains('sync_metadata_table'));
    });

    test('should have correct indexes on trips table', () async {
      final result = await database.customSelect(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='trips'",
      ).get();

      final indexNames =
          result.map((row) => row.read<String>('name')).toList();

      expect(indexNames, contains('idx_trips_user_id'));
      expect(indexNames, contains('idx_trips_sync_status'));
      expect(indexNames, contains('idx_trips_deleted'));
      expect(indexNames, contains('idx_trips_user_active'));
    });
  });

  group('TripDao - CRUD Operations', () {
    late TripDao tripDao;

    setUp(() {
      tripDao = TripDao(database);
    });

    test('should insert a trip successfully', () async {
      final trip = TripsCompanion.insert(
        id: const Value('trip-1'),
        userId: 'user-1',
        title: 'Test Trip',
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 10),
        destination: 'Paris',
        status: 'planning',
        budget: 5000,
        createdAt: DateTime(2024, 5, 1),
        updatedAt: DateTime(2024, 5, 1),
      );

      final inserted = await tripDao.insertTrip(trip);

      expect(inserted.id, equals('trip-1'));
      expect(inserted.title, equals('Test Trip'));
      expect(inserted.userId, equals('user-1'));
    });

    test('should get a trip by ID', () async {
      final trip = TripsCompanion.insert(
        id: const Value('trip-2'),
        userId: 'user-1',
        title: 'Trip to Get',
        startDate: DateTime(2024, 7, 1),
        endDate: DateTime(2024, 7, 10),
        destination: 'London',
        status: 'planning',
        budget: 3000,
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      await tripDao.insertTrip(trip);

      final retrieved = await tripDao.getTripById('trip-2');

      expect(retrieved, isNotNull);
      expect(retrieved?.title, equals('Trip to Get'));
      expect(retrieved?.destination, equals('London'));
    });

    test('should return null when getting non-existent trip', () async {
      final retrieved = await tripDao.getTripById('non-existent');
      expect(retrieved, isNull);
    });

    test('should update a trip successfully', () async {
      final trip = TripsCompanion.insert(
        id: const Value('trip-3'),
        userId: 'user-1',
        title: 'Original Title',
        startDate: DateTime(2024, 8, 1),
        endDate: DateTime(2024, 8, 10),
        destination: 'Rome',
        status: 'planning',
        budget: 4000,
        createdAt: DateTime(2024, 7, 1),
        updatedAt: DateTime(2024, 7, 1),
      );

      final inserted = await tripDao.insertTrip(trip);
      final updated = inserted.copyWith.copyWith(
        title: 'Updated Title',
        budget: 4500,
        updatedAt: DateTime(2024, 7, 15),
      );

      final affectedRows = await tripDao.updateTrip(updated);
      expect(affectedRows, equals(1));

      final retrieved = await tripDao.getTripById('trip-3');
      expect(retrieved?.title, equals('Updated Title'));
      expect(retrieved?.budget, equals(4500));
    });

    test('should delete a trip by ID', () async {
      final trip = TripsCompanion.insert(
        id: const Value('trip-4'),
        userId: 'user-1',
        title: 'To Delete',
        startDate: DateTime(2024, 9, 1),
        endDate: DateTime(2024, 9, 10),
        destination: 'Berlin',
        status: 'planning',
        budget: 2000,
        createdAt: DateTime(2024, 8, 1),
        updatedAt: DateTime(2024, 8, 1),
      );

      await tripDao.insertTrip(trip);

      final affectedRows = await tripDao.deleteTripById('trip-4');
      expect(affectedRows, equals(1));

      final retrieved = await tripDao.getTripById('trip-4');
      expect(retrieved, isNull);
    });

    test('should soft delete a trip', () async {
      final trip = TripsCompanion.insert(
        id: const Value('trip-5'),
        userId: 'user-1',
        title: 'To Soft Delete',
        startDate: DateTime(2024, 10, 1),
        endDate: DateTime(2024, 10, 10),
        destination: 'Madrid',
        status: 'planning',
        budget: 2500,
        createdAt: DateTime(2024, 9, 1),
        updatedAt: DateTime(2024, 9, 1),
      );

      await tripDao.insertTrip(trip);

      final affectedRows = await tripDao.softDeleteTripById('trip-5');
      expect(affectedRows, equals(1));

      // Trip should still exist but be marked as deleted
      final allTrips = await tripDao.getAllTrips();
      expect(allTrips, isEmpty); // getAllTrips excludes deleted

      final softDeleted = await tripDao.getSoftDeletedTrips();
      expect(softDeleted, hasLength(1));
      expect(softDeleted.first.id, equals('trip-5'));
      expect(softDeleted.first.isDeleted, isTrue);
    });

    test('should get all trips for a user', () async {
      // Insert trips for user-1
      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-user1-1'),
        userId: 'user-1',
        title: 'User 1 Trip 1',
        startDate: DateTime(2024, 11, 1),
        endDate: DateTime(2024, 11, 10),
        destination: 'Tokyo',
        status: 'planning',
        budget: 5000,
        createdAt: DateTime(2024, 10, 1),
        updatedAt: DateTime(2024, 10, 1),
      ));

      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-user1-2'),
        userId: 'user-1',
        title: 'User 1 Trip 2',
        startDate: DateTime(2024, 12, 1),
        endDate: DateTime(2024, 12, 10),
        destination: 'Seoul',
        status: 'planning',
        budget: 4500,
        createdAt: DateTime(2024, 11, 1),
        updatedAt: DateTime(2024, 11, 1),
      ));

      // Insert trip for different user
      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-user2-1'),
        userId: 'user-2',
        title: 'User 2 Trip',
        startDate: DateTime(2024, 11, 15),
        endDate: DateTime(2024, 11, 25),
        destination: 'Bangkok',
        status: 'planning',
        budget: 3000,
        createdAt: DateTime(2024, 10, 15),
        updatedAt: DateTime(2024, 10, 15),
      ));

      final user1Trips = await tripDao.getTripsByUserId('user-1');
      expect(user1Trips, hasLength(2));
      expect(user1Trips.every((t) => t.userId == 'user-1'), isTrue);
    });

    test('should get trips with pagination', () async {
      // Insert 25 trips
      for (int i = 1; i <= 25; i++) {
        await tripDao.insertTrip(TripsCompanion.insert(
          id: const Value('trip-$i'),
          userId: 'user-1',
          title: 'Trip $i',
          startDate: DateTime(2024, 1, i),
          endDate: DateTime(2024, 1, i + 5),
          destination: 'Destination $i',
          status: 'planning',
          budget: 1000 * i,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ));
      }

      final page1 = await tripDao.getTripsPaginated(limit: 10, offset: 0);
      expect(page1, hasLength(10));

      final page2 = await tripDao.getTripsPaginated(limit: 10, offset: 10);
      expect(page2, hasLength(10));

      final page3 = await tripDao.getTripsPaginated(limit: 10, offset: 20);
      expect(page3, hasLength(5));
    });

    test('should get trips by status', () async {
      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-status-1'),
        userId: 'user-1',
        title: 'Planning Trip',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 10),
        destination: 'Paris',
        status: 'planning',
        budget: 2000,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ));

      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-status-2'),
        userId: 'user-1',
        title: 'Ongoing Trip',
        startDate: DateTime(2024, 1, 15),
        endDate: DateTime(2024, 1, 20),
        destination: 'London',
        status: 'ongoing',
        budget: 3000,
        createdAt: DateTime(2024, 1, 10),
        updatedAt: DateTime(2024, 1, 10),
      ));

      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-status-3'),
        userId: 'user-1',
        title: 'Another Planning Trip',
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 2, 10),
        destination: 'Rome',
        status: 'planning',
        budget: 2500,
        createdAt: DateTime(2024, 1, 20),
        updatedAt: DateTime(2024, 1, 20),
      ));

      final planningTrips = await tripDao.getTripsByStatus('planning');
      expect(planningTrips, hasLength(2));
      expect(planningTrips.every((t) => t.status == 'planning'), isTrue);

      final ongoingTrips = await tripDao.getTripsByStatus('ongoing');
      expect(ongoingTrips, hasLength(1));
      expect(ongoingTrips.first.status, equals('ongoing'));
    });

    test('should search trips by title or destination', () async {
      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-search-1'),
        userId: 'user-1',
        title: 'Paris Adventure',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 10),
        destination: 'Paris',
        status: 'planning',
        budget: 2000,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ));

      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-search-2'),
        userId: 'user-1',
        title: 'London Trip',
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 2, 10),
        destination: 'London',
        status: 'planning',
        budget: 3000,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      ));

      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-search-3'),
        userId: 'user-1',
        title: 'Paris Explorer',
        startDate: DateTime(2024, 3, 1),
        endDate: DateTime(2024, 3, 10),
        destination: 'Nice',
        status: 'planning',
        budget: 2500,
        createdAt: DateTime(2024, 2, 15),
        updatedAt: DateTime(2024, 2, 15),
      ));

      final parisResults = await tripDao.searchTrips('Paris');
      expect(parisResults, hasLength(2)); // Two trips with "Paris" in title/destination

      final londonResults = await tripDao.searchTrips('London');
      expect(londonResults, hasLength(1));
    });

    test('should count trips for a user', () async {
      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-count-1'),
        userId: 'user-1',
        title: 'Trip 1',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 10),
        destination: 'Paris',
        status: 'planning',
        budget: 2000,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ));

      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-count-2'),
        userId: 'user-1',
        title: 'Trip 2',
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 2, 10),
        destination: 'London',
        status: 'planning',
        budget: 3000,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      ));

      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-count-3'),
        userId: 'user-1',
        title: 'Trip 3',
        startDate: DateTime(2024, 3, 1),
        endDate: DateTime(2024, 3, 10),
        destination: 'Rome',
        status: 'planning',
        budget: 2500,
        createdAt: DateTime(2024, 2, 15),
        updatedAt: DateTime(2024, 2, 15),
      ));

      final count = await tripDao.countTripsByUserId('user-1');
      expect(count, equals(3));
    });
  });

  group('TripDao - Sync-Aware Operations', () {
    late TripDao tripDao;

    setUp(() {
      tripDao = TripDao(database);
    });

    test('should get unsynced trips', () async {
      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-sync-1'),
        userId: 'user-1',
        title: 'Synced Trip',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 10),
        destination: 'Paris',
        status: 'planning',
        budget: 2000,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        isSynced: const Value(true),
      ));

      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-sync-2'),
        userId: 'user-1',
        title: 'Unsynced Trip',
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 2, 10),
        destination: 'London',
        status: 'planning',
        budget: 3000,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
        isSynced: const Value(false),
      ));

      final unsynced = await tripDao.getUnsyncedTrips();
      expect(unsynced, hasLength(1));
      expect(unsynced.first.id, equals('trip-sync-2'));
      expect(unsynced.first.isSynced, isFalse);
    });

    test('should get trips with pending changes', () async {
      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-pending-1'),
        userId: 'user-1',
        title: 'Clean Trip',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 10),
        destination: 'Paris',
        status: 'planning',
        budget: 2000,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        hasPendingChanges: const Value(false),
      ));

      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-pending-2'),
        userId: 'user-1',
        title: 'Modified Trip',
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 2, 10),
        destination: 'London',
        status: 'planning',
        budget: 3000,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
        hasPendingChanges: const Value(true),
      ));

      final pending = await tripDao.getTripsWithPendingChanges();
      expect(pending, hasLength(1));
      expect(pending.first.id, equals('trip-pending-2'));
      expect(pending.first.hasPendingChanges, isTrue);
    });

    test('should update trip sync status', () async {
      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-status-1'),
        userId: 'user-1',
        title: 'Trip to Sync',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 10),
        destination: 'Paris',
        status: 'planning',
        budget: 2000,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        isSynced: const Value(false),
      ));

      final affectedRows =
          await tripDao.updateTripSyncStatus('trip-status-1', true);
      expect(affectedRows, equals(1));

      final trip = await tripDao.getTripById('trip-status-1');
      expect(trip?.isSynced, isTrue);
    });

    test('should mark trip as synced', () async {
      final syncTime = DateTime(2024, 1, 15, 10, 30);

      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-mark-1'),
        userId: 'user-1',
        title: 'Trip to Mark',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 10),
        destination: 'Paris',
        status: 'planning',
        budget: 2000,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        isSynced: const Value(false),
        hasPendingChanges: const Value(true),
      ));

      await tripDao.markTripAsSynced('trip-mark-1', syncTime);

      final trip = await tripDao.getTripById('trip-mark-1');
      expect(trip?.isSynced, isTrue);
      expect(trip?.hasPendingChanges, isFalse);
      expect(trip?.lastSyncedAt, equals(syncTime));
    });

    test('should get trips updated after timestamp', () async {
      final timestamp = DateTime(2024, 6, 15);

      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-timestamp-1'),
        userId: 'user-1',
        title: 'Old Trip',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 10),
        destination: 'Paris',
        status: 'planning',
        budget: 2000,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 6, 10),
      ));

      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-timestamp-2'),
        userId: 'user-1',
        title: 'New Trip',
        startDate: DateTime(2024, 7, 1),
        endDate: DateTime(2024, 7, 10),
        destination: 'London',
        status: 'planning',
        budget: 3000,
        createdAt: DateTime(2024, 6, 20),
        updatedAt: DateTime(2024, 6, 20),
      ));

      final recentTrips = await tripDao.getTripsUpdatedAfter(timestamp);
      expect(recentTrips, hasLength(1));
      expect(recentTrips.first.id, equals('trip-timestamp-2'));
    });
  });

  group('JournalDao - CRUD Operations', () {
    late JournalDao journalDao;
    late TripDao tripDao;

    setUp(() {
      journalDao = JournalDao(database);
      tripDao = TripDao(database);
    });

    test('should insert a journal successfully', () async {
      // First create a trip
      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-journal-1'),
        userId: 'user-1',
        title: 'Test Trip',
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 10),
        destination: 'Paris',
        status: 'ongoing',
        budget: 5000,
        createdAt: DateTime(2024, 5, 1),
        updatedAt: DateTime(2024, 5, 1),
      ));

      final journal = JournalsCompanion.insert(
        id: const Value('journal-1'),
        tripId: 'trip-journal-1',
        userId: 'user-1',
        title: 'Day 1 in Paris',
        content: 'Arrived safely and visited the Eiffel Tower',
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      final inserted = await journalDao.insertJournal(journal);

      expect(inserted.id, equals('journal-1'));
      expect(inserted.title, equals('Day 1 in Paris'));
      expect(inserted.tripId, equals('trip-journal-1'));
    });

    test('should get journals by trip ID', () async {
      // Create trip
      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-journal-2'),
        userId: 'user-1',
        title: 'Paris Trip',
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 10),
        destination: 'Paris',
        status: 'ongoing',
        budget: 5000,
        createdAt: DateTime(2024, 5, 1),
        updatedAt: DateTime(2024, 5, 1),
      ));

      // Insert journals
      await journalDao.insertJournal(JournalsCompanion.insert(
        id: const Value('journal-2-1'),
        tripId: 'trip-journal-2',
        userId: 'user-1',
        title: 'Day 1',
        content: 'First day',
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      ));

      await journalDao.insertJournal(JournalsCompanion.insert(
        id: const Value('journal-2-2'),
        tripId: 'trip-journal-2',
        userId: 'user-1',
        title: 'Day 2',
        content: 'Second day',
        createdAt: DateTime(2024, 6, 2),
        updatedAt: DateTime(2024, 6, 2),
      ));

      final journals = await journalDao.getJournalsByTripId('trip-journal-2');
      expect(journals, hasLength(2));
      expect(journals.every((j) => j.tripId == 'trip-journal-2'), isTrue);
    });

    test('should update a journal', () async {
      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-journal-3'),
        userId: 'user-1',
        title: 'Test Trip',
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 10),
        destination: 'Paris',
        status: 'ongoing',
        budget: 5000,
        createdAt: DateTime(2024, 5, 1),
        updatedAt: DateTime(2024, 5, 1),
      ));

      final journal = await journalDao.insertJournal(JournalsCompanion.insert(
        id: const Value('journal-3'),
        tripId: 'trip-journal-3',
        userId: 'user-1',
        title: 'Original Title',
        content: 'Original content',
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      ));

      final updated = journal.copyWith.copyWith(
        title: 'Updated Title',
        content: 'Updated content',
        updatedAt: DateTime(2024, 6, 2),
      );

      final affectedRows = await journalDao.updateJournal(updated);
      expect(affectedRows, equals(1));

      final retrieved = await journalDao.getJournalById('journal-3');
      expect(retrieved?.title, equals('Updated Title'));
      expect(retrieved?.content, equals('Updated content'));
    });

    test('should delete a journal', () async {
      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-journal-4'),
        userId: 'user-1',
        title: 'Test Trip',
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 10),
        destination: 'Paris',
        status: 'ongoing',
        budget: 5000,
        createdAt: DateTime(2024, 5, 1),
        updatedAt: DateTime(2024, 5, 1),
      ));

      await journalDao.insertJournal(JournalsCompanion.insert(
        id: const Value('journal-4'),
        tripId: 'trip-journal-4',
        userId: 'user-1',
        title: 'To Delete',
        content: 'Will be deleted',
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      ));

      final affectedRows = await journalDao.deleteJournalById('journal-4');
      expect(affectedRows, equals(1));

      final retrieved = await journalDao.getJournalById('journal-4');
      expect(retrieved, isNull);
    });
  });

  group('UserDao - CRUD Operations', () {
    late UserDao userDao;

    setUp(() {
      userDao = UserDao(database);
    });

    test('should insert a user successfully', () async {
      final user = UsersCompanion.insert(
        id: const Value('user-1'),
        email: 'test@example.com',
        username: 'testuser',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final inserted = await userDao.insertUser(user);

      expect(inserted.id, equals('user-1'));
      expect(inserted.email, equals('test@example.com'));
      expect(inserted.username, equals('testuser'));
    });

    test('should get a user by ID', () async {
      await userDao.insertUser(UsersCompanion.insert(
        id: const Value('user-2'),
        email: 'user2@example.com',
        username: 'user2',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ));

      final retrieved = await userDao.getUserById('user-2');

      expect(retrieved, isNotNull);
      expect(retrieved?.username, equals('user2'));
      expect(retrieved?.email, equals('user2@example.com'));
    });

    test('should get a user by email', () async {
      await userDao.insertUser(UsersCompanion.insert(
        id: const Value('user-3'),
        email: 'user3@example.com',
        username: 'user3',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ));

      final retrieved = await userDao.getUserByEmail('user3@example.com');

      expect(retrieved, isNotNull);
      expect(retrieved?.id, equals('user-3'));
      expect(retrieved?.username, equals('user3'));
    });

    test('should update a user', () async {
      final inserted = await userDao.insertUser(UsersCompanion.insert(
        id: const Value('user-4'),
        email: 'user4@example.com',
        username: 'user4',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ));

      final updated = inserted.copyWith.copyWith(
        username: 'user4updated',
        updatedAt: DateTime(2024, 1, 2),
      );

      final affectedRows = await userDao.updateUser(updated);
      expect(affectedRows, equals(1));

      final retrieved = await userDao.getUserById('user-4');
      expect(retrieved?.username, equals('user4updated'));
    });

    test('should delete a user', () async {
      await userDao.insertUser(UsersCompanion.insert(
        id: const Value('user-5'),
        email: 'user5@example.com',
        username: 'user5',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ));

      final affectedRows = await userDao.deleteUserById('user-5');
      expect(affectedRows, equals(1));

      final retrieved = await userDao.getUserById('user-5');
      expect(retrieved, isNull);
    });
  });

  group('SyncQueueDao - CRUD Operations', () {
    late SyncQueueDao syncQueueDao;

    setUp(() {
      syncQueueDao = SyncQueueDao(database);
    });

    test('should enqueue a sync operation', () async {
      final operation = SyncQueueCompanion.insert(
        id: const Value('sync-1'),
        entityType: 'trip',
        entityId: 'trip-1',
        operationType: 'create',
        data: const Value('{"title":"Test Trip"}'),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final inserted = await syncQueueDao.enqueueOperation(operation);

      expect(inserted.id, equals('sync-1'));
      expect(inserted.entityType, equals('trip'));
      expect(inserted.operationType, equals('create'));
    });

    test('should get pending operations', () async {
      await syncQueueDao.enqueueOperation(SyncQueueCompanion.insert(
        id: const Value('sync-2'),
        entityType: 'trip',
        entityId: 'trip-2',
        operationType: 'update',
        data: const Value('{"title":"Updated"}'),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        status: const Value('pending'),
      ));

      await syncQueueDao.enqueueOperation(SyncQueueCompanion.insert(
        id: const Value('sync-3'),
        entityType: 'journal',
        entityId: 'journal-1',
        operationType: 'create',
        data: const Value('{"content":"New journal"}'),
        createdAt: DateTime(2024, 1, 2),
        updatedAt: DateTime(2024, 1, 2),
        status: const Value('completed'),
      ));

      final pending = await syncQueueDao.getPendingOperations();
      expect(pending, hasLength(1));
      expect(pending.first.id, equals('sync-2'));
      expect(pending.first.status, equals('pending'));
    });

    test('should get operations by entity', () async {
      await syncQueueDao.enqueueOperation(SyncQueueCompanion.insert(
        id: const Value('sync-4'),
        entityType: 'trip',
        entityId: 'trip-1',
        operationType: 'update',
        data: const Value('{"title":"Update 1"}'),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ));

      await syncQueueDao.enqueueOperation(SyncQueueCompanion.insert(
        id: const Value('sync-5'),
        entityType: 'trip',
        entityId: 'trip-1',
        operationType: 'update',
        data: const Value('{"title":"Update 2"}'),
        createdAt: DateTime(2024, 1, 2),
        updatedAt: DateTime(2024, 1, 2),
      ));

      await syncQueueDao.enqueueOperation(SyncQueueCompanion.insert(
        id: const Value('sync-6'),
        entityType: 'journal',
        entityId: 'journal-1',
        operationType: 'create',
        data: const Value('{"content":"New"}'),
        createdAt: DateTime(2024, 1, 3),
        updatedAt: DateTime(2024, 1, 3),
      ));

      final tripOperations = await syncQueueDao.getOperationsByEntity(
        entityType: 'trip',
        entityId: 'trip-1',
      );

      expect(tripOperations, hasLength(2));
      expect(tripOperations.every((op) => op.entityType == 'trip'), isTrue);
    });

    test('should update operation status', () async {
      await syncQueueDao.enqueueOperation(SyncQueueCompanion.insert(
        id: const Value('sync-7'),
        entityType: 'trip',
        entityId: 'trip-1',
        operationType: 'create',
        data: const Value('{"title":"New"}'),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        status: const Value('pending'),
      ));

      final affectedRows = await syncQueueDao.updateOperationStatus(
        id: 'sync-7',
        status: 'completed',
      );

      expect(affectedRows, equals(1));

      final operation = await syncQueueDao.getOperationById('sync-7');
      expect(operation?.status, equals('completed'));
    });

    test('should increment retry count', () async {
      await syncQueueDao.enqueueOperation(SyncQueueCompanion.insert(
        id: const Value('sync-8'),
        entityType: 'trip',
        entityId: 'trip-1',
        operationType: 'create',
        data: const Value('{"title":"New"}'),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        retryCount: const Value(0),
      ));

      final newCount = await syncQueueDao.incrementRetryCount('sync-8');

      expect(newCount, equals(1));

      final operation = await syncQueueDao.getOperationById('sync-8');
      expect(operation?.retryCount, equals(1));
    });

    test('should delete completed operations', () async {
      await syncQueueDao.enqueueOperation(SyncQueueCompanion.insert(
        id: const Value('sync-9'),
        entityType: 'trip',
        entityId: 'trip-1',
        operationType: 'create',
        data: const Value('{"title":"New"}'),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        status: const Value('completed'),
      ));

      await syncQueueDao.enqueueOperation(SyncQueueCompanion.insert(
        id: const Value('sync-10'),
        entityType: 'trip',
        entityId: 'trip-2',
        operationType: 'create',
        data: const Value('{"title":"New 2"}'),
        createdAt: DateTime(2024, 1, 2),
        updatedAt: DateTime(2024, 1, 2),
        status: const Value('pending'),
      ));

      final deletedCount = await syncQueueDao.deleteCompletedOperations();
      expect(deletedCount, equals(1));

      final pending = await syncQueueDao.getPendingOperations();
      expect(pending, hasLength(1));
      expect(pending.first.id, equals('sync-10'));
    });
  });

  group('Transaction Rollback', () {
    late TripDao tripDao;

    setUp(() {
      tripDao = TripDao(database);
    });

    test('should rollback transaction on error', () async {
      // Insert initial trip
      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-rollback-1'),
        userId: 'user-1',
        title: 'Original Title',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 10),
        destination: 'Paris',
        status: 'planning',
        budget: 2000,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ));

      // Get original trip
      final original = await tripDao.getTripById('trip-rollback-1');
      expect(original?.title, equals('Original Title'));

      // Attempt to update with invalid data that will cause an error
      try {
        await database.transaction(() async {
          // Update trip
          await tripDao.updateTrip(original!.copyWith.copyWith(
            title: 'Updated Title',
            updatedAt: DateTime(2024, 1, 2),
          ));

          // Force an error to trigger rollback
          throw Exception('Intentional error for rollback test');
        });
      } catch (e) {
        // Expected error
      }

      // Verify trip was not updated (transaction rolled back)
      final retrieved = await tripDao.getTripById('trip-rollback-1');
      expect(retrieved?.title, equals('Original Title'));
    });

    test('should commit transaction when no error occurs', () async {
      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-rollback-2'),
        userId: 'user-1',
        title: 'Before Transaction',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 10),
        destination: 'Paris',
        status: 'planning',
        budget: 2000,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ));

      // Successful transaction
      await database.transaction(() async {
        final trip = await tripDao.getTripById('trip-rollback-2');
        await tripDao.updateTrip(trip!.copyWith.copyWith(
          title: 'After Transaction',
          updatedAt: DateTime(2024, 1, 2),
        ));
      });

      // Verify trip was updated
      final retrieved = await tripDao.getTripById('trip-rollback-2');
      expect(retrieved?.title, equals('After Transaction'));
    });

    test('should rollback batch operations on error', () async {
      // Insert multiple trips
      for (int i = 1; i <= 5; i++) {
        await tripDao.insertTrip(TripsCompanion.insert(
          id: Value('trip-batch-$i'),
          userId: 'user-1',
          title: 'Trip $i',
          startDate: DateTime(2024, i, 1),
          endDate: DateTime(2024, i, 10),
          destination: 'Destination $i',
          status: 'planning',
          budget: 1000 * i,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ));
      }

      final beforeUpdate = await tripDao.getTripById('trip-batch-1');
      expect(beforeUpdate?.title, equals('Trip 1'));

      // Try to update multiple trips in transaction with error
      try {
        await database.transaction(() async {
          for (int i = 1; i <= 5; i++) {
            final trip = await tripDao.getTripById('trip-batch-$i');
            await tripDao.updateTrip(trip!.copyWith.copyWith(
              title: 'Updated Trip $i',
              updatedAt: DateTime(2024, 1, i + 1),
            ));
          }

          // Force rollback
          throw Exception('Batch rollback test');
        });
      } catch (e) {
        // Expected
      }

      // Verify none of the trips were updated
      final afterUpdate = await tripDao.getTripById('trip-batch-1');
      expect(afterUpdate?.title, equals('Trip 1'));
    });
  });

  group('Query Performance Tests', () {
    late TripDao tripDao;

    setUp(() {
      tripDao = TripDao(database);
    });

    test('should handle large dataset efficiently', () async {
      final stopwatch = Stopwatch()..start();

      // Insert 1000 trips
      for (int i = 1; i <= 1000; i++) {
        await tripDao.insertTrip(TripsCompanion.insert(
          id: Value('trip-perf-$i'),
          userId: i % 10 == 0 ? 'user-2' : 'user-1',
          title: 'Performance Trip $i',
          startDate: DateTime(2024, 1, i % 28 + 1),
          endDate: DateTime(2024, 1, (i % 28 + 1) % 28 + 1),
          destination: 'Destination ${i % 50}',
          status: ['planning', 'ongoing', 'completed'][i % 3],
          budget: 1000 + (i * 100),
          createdAt: DateTime(2024, 1, 1).add(Duration(milliseconds: i)),
          updatedAt: DateTime(2024, 1, 1).add(Duration(milliseconds: i)),
        ));
      }

      final insertTime = stopwatch.elapsedMilliseconds;
      stopwatch.reset();

      // Query all trips
      final allTrips = await tripDao.getAllTrips();
      final queryTime = stopwatch.elapsedMilliseconds;

      expect(allTrips, hasLength(1000));

      // Performance assertions (adjust thresholds based on requirements)
      expect(insertTime, lessThan(30000), // Insert should take less than 30s
          reason: 'Inserting 1000 trips took too long: ${insertTime}ms');
      expect(queryTime, lessThan(5000), // Query should take less than 5s
          reason: 'Querying 1000 trips took too long: ${queryTime}ms');
    });

    test('should handle pagination efficiently with large dataset', () async {
      // Insert 500 trips
      for (int i = 1; i <= 500; i++) {
        await tripDao.insertTrip(TripsCompanion.insert(
          id: Value('trip-page-$i'),
          userId: 'user-1',
          title: 'Trip $i',
          startDate: DateTime(2024, 1, i % 28 + 1),
          endDate: DateTime(2024, 1, (i % 28 + 1) % 28 + 1),
          destination: 'Destination ${i % 50}',
          status: 'planning',
          budget: 1000 * i,
          createdAt: DateTime(2024, 1, 1).add(Duration(milliseconds: i)),
          updatedAt: DateTime(2024, 1, 1).add(Duration(milliseconds: i)),
        ));
      }

      final stopwatch = Stopwatch()..start();

      // Query with pagination
      final page1 = await tripDao.getTripsPaginated(limit: 50, offset: 0);
      final pageTime = stopwatch.elapsedMilliseconds;

      expect(page1, hasLength(50));
      expect(pageTime, lessThan(1000),
          reason: 'Paginated query took too long: ${pageTime}ms');
    });

    test('should handle filtered queries efficiently', () async {
      // Insert mix of trips for different users and statuses
      for (int i = 1; i <= 300; i++) {
        await tripDao.insertTrip(TripsCompanion.insert(
          id: Value('trip-filter-$i'),
          userId: 'user-${i % 5}',
          title: 'Trip $i',
          startDate: DateTime(2024, i % 12 + 1, 1),
          endDate: DateTime(2024, i % 12 + 1, 10),
          destination: 'Destination ${i % 20}',
          status: ['planning', 'ongoing', 'completed'][i % 3],
          budget: 1000 + (i * 100),
          createdAt: DateTime(2024, 1, 1).add(Duration(milliseconds: i)),
          updatedAt: DateTime(2024, 1, 1).add(Duration(milliseconds: i)),
        ));
      }

      final stopwatch = Stopwatch()..start();

      // Query with filters
      final filtered = await tripDao.getTripsByStatus('ongoing', userId: 'user-1');
      final filterTime = stopwatch.elapsedMilliseconds;

      expect(filterTime, lessThan(1000),
          reason: 'Filtered query took too long: ${filterTime}ms');
    });

    test('should handle search queries efficiently', () async {
      // Insert trips with searchable content
      final destinations = List.generate(50, (i) => 'City $i');
      for (int i = 1; i <= 200; i++) {
        await tripDao.insertTrip(TripsCompanion.insert(
          id: Value('trip-search-perf-$i'),
          userId: 'user-1',
          title: 'Trip to ${destinations[i % 50]}',
          startDate: DateTime(2024, i % 12 + 1, 1),
          endDate: DateTime(2024, i % 12 + 1, 10),
          destination: destinations[i % 50],
          status: 'planning',
          budget: 1000 * i,
          createdAt: DateTime(2024, 1, 1).add(Duration(milliseconds: i)),
          updatedAt: DateTime(2024, 1, 1).add(Duration(milliseconds: i)),
        ));
      }

      final stopwatch = Stopwatch()..start();

      final results = await tripDao.searchTrips('City 5');
      final searchTime = stopwatch.elapsedMilliseconds;

      expect(results.isNotEmpty, isTrue);
      expect(searchTime, lessThan(1000),
          reason: 'Search query took too long: ${searchTime}ms');
    });

    test('should handle concurrent access safely', () async {
      // Insert 100 trips
      for (int i = 1; i <= 100; i++) {
        await tripDao.insertTrip(TripsCompanion.insert(
          id: Value('trip-concurrent-$i'),
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

      // Simulate concurrent reads
      final futures = List.generate(
        10,
        (index) => tripDao.getTripsPaginated(limit: 10, offset: index * 10),
      );

      final results = await Future.wait(futures);

      // Verify all queries succeeded
      expect(results, hasLength(10));
      expect(results.fold<int>(0, (sum, list) => sum + list.length), equals(100));

      // Verify no duplicate trips across pages
      final allIds = results.expand((list) => list.map((t) => t.id)).toSet();
      expect(allIds, hasLength(100));
    });
  });

  group('Database Operations - Clear All', () {
    test('should clear all tables', () async {
      final tripDao = TripDao(database);
      final journalDao = JournalDao(database);
      final userDao = UserDao(database);
      final syncQueueDao = SyncQueueDao(database);

      // Insert data in all tables
      await tripDao.insertTrip(TripsCompanion.insert(
        id: const Value('trip-clear-1'),
        userId: 'user-1',
        title: 'Trip',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 10),
        destination: 'Paris',
        status: 'planning',
        budget: 2000,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ));

      await userDao.insertUser(UsersCompanion.insert(
        id: const Value('user-clear-1'),
        email: 'user@example.com',
        username: 'user',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ));

      await syncQueueDao.enqueueOperation(SyncQueueCompanion.insert(
        id: const Value('sync-clear-1'),
        entityType: 'trip',
        entityId: 'trip-1',
        operationType: 'create',
        data: const Value('{}'),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ));

      // Verify data exists
      expect(await tripDao.getAllTrips(), hasLength(1));
      expect(await userDao.getAllUsers(), hasLength(1));
      expect(await syncQueueDao.getPendingOperations(), hasLength(1));

      // Clear all tables
      await database.clearAllTables();

      // Verify all tables are empty
      expect(await tripDao.getAllTrips(), isEmpty);
      expect(await userDao.getAllUsers(), isEmpty);
      expect(await syncQueueDao.getPendingOperations(), isEmpty);
    });
  });
}
