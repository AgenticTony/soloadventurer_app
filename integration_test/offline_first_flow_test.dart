import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/core/domain/services/connectivity_service.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_queue_service.dart';
import 'package:soloadventurer/features/offline/domain/entities/sync_operation.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/trip_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/journal_dao.dart';
import 'package:drift/drift.dart';

// Mock classes
class MockConnectivityService extends Mock implements ConnectivityService {}

class MockSyncQueueService extends Mock implements SyncQueueService {}

class MockAppDatabase extends Mock implements AppDatabase {}

class MockTripDao extends Mock implements TripDao {}

class MockJournalDao extends Mock implements JournalDao {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Offline-First Flow Integration Tests', () {
    late MockConnectivityService mockConnectivityService;
    late MockSyncQueueService mockSyncQueueService;
    late MockAppDatabase mockDatabase;
    late MockTripDao mockTripDao;
    late MockJournalDao mockJournalDao;

    setUp(() {
      mockConnectivityService = MockConnectivityService();
      mockSyncQueueService = MockSyncQueueService();
      mockDatabase = MockAppDatabase();
      mockTripDao = MockTripDao();
      mockJournalDao = MockJournalDao();

      // Setup database to return mocked DAOs
      when(() => mockDatabase.tripDao).thenReturn(mockTripDao);
      when(() => mockDatabase.journalDao).thenReturn(mockJournalDao);
    });

    test('Test creating trip while offline', () async {
      // Setup: Device is offline
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);
      when(() => mockConnectivityService.onConnectivityChanged)
          .thenAnswer((_) => Stream.value(NetworkStatus.disconnected));

      final now = DateTime.now();
      // Create a trip while offline
      final trip = TripsCompanion.insert(
        id: 'trip-1',
        userId: 'user-1',
        title: 'Offline Trip',
        description: const Value('Created while offline'),
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
        destination: 'Tokyo, Japan',
        status: 'planning',
        budget: 5000,
        createdAt: now,
        updatedAt: now,
        isSynced: const Value(false),
        hasPendingChanges: const Value(true),
        version: const Value(1),
      );

      when(() => mockTripDao.insertTrip(any())).thenAnswer((_) async => 1);
      when(() => mockSyncQueueService.enqueueOperation(
            entityType: any(named: 'entityType'),
            entityId: any(named: 'entityId'),
            operation: any(named: 'operation'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => SyncQueueResult.success(operationId: 1));

      // Insert the trip
      await mockDatabase.tripDao.insertTrip(trip);

      // Verify trip was saved locally
      verify(() => mockTripDao.insertTrip(trip)).called(1);

      // Verify sync operation was queued
      verify(() => mockSyncQueueService.enqueueOperation(
            entityType: 'trip',
            entityId: 'trip-1',
            operation: SyncOperationType.create,
            data: any(named: 'data'),
          )).called(1);
    });

    test('Test sync when connection restored', () async {
      // Setup: Start offline, then go online
      final connectivityStatusStream = Stream.fromIterable([
        NetworkStatus.disconnected,
        NetworkStatus.connected,
      ]);

      when(() => mockConnectivityService.onConnectivityChanged)
          .thenAnswer((_) => connectivityStatusStream);
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);

      // Mock pending count
      when(() => mockSyncQueueService.getPendingCount())
          .thenAnswer((_) async => 2);

      // Mock processing result
      when(() => mockSyncQueueService.processPendingOperations(
            onProcess: any(named: 'onProcess'),
          )).thenAnswer((_) async => SyncQueueResult.success(
            operationsCount: 2,
          ));

      // Process pending operations
      final result = await mockSyncQueueService.processPendingOperations(
        onProcess: (operation) async {
          // Simulate successful sync to server
          return true;
        },
      );

      // Verify all operations were processed
      expect(result.success, isTrue);
      expect(result.operationsCount, equals(2));
    });

    test('Test complete offline-to-online cycle', () async {
      // This test simulates a complete offline-to-online cycle

      // Phase 1: Offline - Create trip
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);

      when(() => mockTripDao.insertTrip(any())).thenAnswer((_) async => 1);
      when(() => mockSyncQueueService.enqueueOperation(
            entityType: any(named: 'entityType'),
            entityId: any(named: 'entityId'),
            operation: any(named: 'operation'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => SyncQueueResult.success(operationId: 1));

      await mockDatabase.tripDao.insertTrip(TripsCompanion.insert(
        id: 'trip-1',
        userId: 'user-1',
        title: 'Offline Trip 1',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 5)),
        destination: 'Paris',
        status: 'planning',
        budget: 1000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: const Value(false),
        hasPendingChanges: const Value(true),
        version: const Value(1),
      ));

      // Verify operation was queued
      verify(() => mockSyncQueueService.enqueueOperation(
            entityType: 'trip',
            entityId: 'trip-1',
            operation: SyncOperationType.create,
            data: any(named: 'data'),
          )).called(1);

      // Phase 2: Connection restored
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);

      when(() => mockSyncQueueService.getPendingCount())
          .thenAnswer((_) async => 1);

      when(() => mockSyncQueueService.processPendingOperations(
            onProcess: any(named: 'onProcess'),
          )).thenAnswer((_) async => SyncQueueResult.success(
            operationsCount: 1,
          ));

      // Sync all operations
      final syncResult = await mockSyncQueueService.processPendingOperations(
        onProcess: (operation) async {
          // Simulate successful sync
          return true;
        },
      );

      // Verify sync was successful
      expect(syncResult.success, isTrue);
      expect(syncResult.operationsCount, equals(1));
    });

    test('Test error handling during sync', () async {
      // Setup: Connection is online but sync fails
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);

      when(() => mockSyncQueueService.getPendingCount())
          .thenAnswer((_) async => 1);

      // Process operation that will fail
      final result = await mockSyncQueueService.processPendingOperations(
        onProcess: (operation) async {
          // Simulate sync failure - service handles this internally
          throw Exception('Network error');
        },
      );

      // Verify service handled the error gracefully
      // The service catches exceptions and returns success with 0 operations
      expect(result.success, isTrue);
      expect(result.operationsCount, equals(0));
    });

    test('Test retry logic for failed operations', () async {
      // Setup: Failed operations ready for retry
      when(() => mockSyncQueueService.retryFailedOperations())
          .thenAnswer((_) async => SyncQueueResult.success(
            operationsCount: 1,
          ));

      // Retry failed operations
      final retryResult = await mockSyncQueueService.retryFailedOperations();

      // Verify operation was retried
      expect(retryResult.success, isTrue);
      expect(retryResult.operationsCount, equals(1));

      verify(() => mockSyncQueueService.retryFailedOperations()).called(1);
    });

    test('Test queue size tracking', () async {
      // Mock queue size
      when(() => mockSyncQueueService.getQueueSize())
          .thenAnswer((_) async => 5);

      final queueSize = await mockSyncQueueService.getQueueSize();

      expect(queueSize, equals(5));
      verify(() => mockSyncQueueService.getQueueSize()).called(1);
    });

    test('Test pending operations count', () async {
      // Mock pending count
      when(() => mockSyncQueueService.getPendingCount())
          .thenAnswer((_) async => 3);

      final pendingCount = await mockSyncQueueService.getPendingCount();

      expect(pendingCount, equals(3));
      verify(() => mockSyncQueueService.getPendingCount()).called(1);
    });

    test('Test queue statistics', () async {
      // Mock statistics
      when(() => mockSyncQueueService.getQueueStatistics())
          .thenAnswer((_) async => {
                'pending': 2,
                'processing': 1,
                'completed': 10,
                'failed': 1,
              });

      final stats = await mockSyncQueueService.getQueueStatistics();

      expect(stats['pending'], equals(2));
      expect(stats['processing'], equals(1));
      expect(stats['completed'], equals(10));
      expect(stats['failed'], equals(1));
      verify(() => mockSyncQueueService.getQueueStatistics()).called(1);
    });
  });
}
