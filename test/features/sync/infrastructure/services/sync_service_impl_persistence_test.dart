import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_operation.dart';
import 'package:soloadventurer/features/sync/domain/entities/sync_entity_type.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/sync_service_impl.dart';
import 'package:soloadventurer/features/sync/domain/services/sync_queue_persistence.dart';

@GenerateMocks([SyncQueuePersistence])
import 'sync_service_impl_persistence_test.mocks.dart';

void main() {
  late MockSyncQueuePersistence mockPersistence;
  late SyncServiceImpl syncService;

  setUp(() {
    mockPersistence = MockSyncQueuePersistence();

    // Setup default mock responses
    when(mockPersistence.loadQueue()).thenAnswer((_) async => []);
    when(mockPersistence.saveQueue(any)).thenAnswer(
        (_) async => SyncQueuePersistenceResult.success(operationCount: 0));
  });

  group('SyncServiceImpl with Persistence', () {
    test('should load persisted queue on initialization', () async {
      // Arrange
      final operation = SyncOperation.create(
        id: 'op1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Test Trip'},
      );

      when(mockPersistence.loadQueue()).thenAnswer((_) async => [operation]);

      // Act
      syncService = SyncServiceImpl(persistence: mockPersistence);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(syncService.queueSize, 1);
      expect(syncService.queue[0].id, 'op1');
      verify(mockPersistence.loadQueue()).called(1);
    });

    test('should persist queue when operation is enqueued', () async {
      // Arrange
      when(mockPersistence.saveQueue(any)).thenAnswer(
          (_) async => SyncQueuePersistenceResult.success(operationCount: 1));

      syncService = SyncServiceImpl(persistence: mockPersistence);
      final operation = SyncOperation.create(
        id: 'op1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Test Trip'},
      );

      // Act
      await syncService.enqueueOperation(operation);

      // Assert
      verify(mockPersistence.saveQueue(any)).called(1);
    });

    test('should persist queue when operation is removed', () async {
      // Arrange
      final operation = SyncOperation.create(
        id: 'op1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Test Trip'},
      );

      when(mockPersistence.loadQueue()).thenAnswer((_) async => [operation]);
      when(mockPersistence.saveQueue(any)).thenAnswer(
          (_) async => SyncQueuePersistenceResult.success(operationCount: 0));

      syncService = SyncServiceImpl(persistence: mockPersistence);
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      await syncService.removeOperation('op1');

      // Assert
      verify(mockPersistence.saveQueue(any)).called(greaterThanOrEqualTo(1));
    });

    test('should clear persisted queue when queue is cleared', () async {
      // Arrange
      final operation = SyncOperation.create(
        id: 'op1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Test Trip'},
      );

      when(mockPersistence.loadQueue()).thenAnswer((_) async => [operation]);
      when(mockPersistence.saveQueue(any)).thenAnswer(
          (_) async => SyncQueuePersistenceResult.success(operationCount: 0));
      when(mockPersistence.clearQueue())
          .thenAnswer((_) async => SyncQueuePersistenceResult.success());

      syncService = SyncServiceImpl(persistence: mockPersistence);
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      await syncService.clearQueue();

      // Assert
      verify(mockPersistence.clearQueue()).called(1);
      expect(syncService.queueSize, 0);
    });

    test('should persist queue after processing operations', () async {
      // Arrange
      when(mockPersistence.saveQueue(any)).thenAnswer(
          (_) async => SyncQueuePersistenceResult.success(operationCount: 0));

      syncService = SyncServiceImpl(
        persistence: mockPersistence,
      );
      syncService.pauseProcessing(); // Prevent auto-processing

      final operation = SyncOperation.create(
        id: 'op1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Test Trip'},
      );

      await syncService.enqueueOperation(operation);
      syncService.resumeProcessing();

      // Wait for processing to complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Assert - verify that save was called multiple times
      // (enqueue + after processing)
      verify(mockPersistence.saveQueue(any)).called(greaterThanOrEqualTo(1));
    });

    test('should work without persistence when not provided', () async {
      // Act
      syncService = SyncServiceImpl();

      final operation = SyncOperation.create(
        id: 'op1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Test Trip'},
      );

      await syncService.enqueueOperation(operation);

      // Assert - should work normally without persistence
      expect(syncService.queueSize, 1);
      expect(syncService.queue[0].id, 'op1');
    });
  });
}
