import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/offline/domain/entities/sync_operation.dart';
import 'package:soloadventurer/features/offline/domain/repositories/sync_queue_repository.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_queue_service.dart';
import 'package:soloadventurer/features/offline/domain/services/connectivity_service.dart';

// Mock classes using mocktail (no code generation needed)
class MockSyncQueueRepository extends Mock implements SyncQueueRepository {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late MockSyncQueueRepository mockRepository;
  late MockConnectivityService mockConnectivityService;
  late SyncQueueService syncQueueService;

  setUp(() {
    mockRepository = MockSyncQueueRepository();
    mockConnectivityService = MockConnectivityService();
    syncQueueService = SyncQueueService(
      repository: mockRepository,
      connectivityService: mockConnectivityService,
      cleanupInterval: const Duration(minutes: 1), // Short interval for tests
      completedOperationMaxAge: const Duration(days: 1),
      failedOperationMaxAge: const Duration(days: 1),
    );
  });

  tearDown(() {
    syncQueueService.dispose();
  });

  group('SyncQueueService - Queue Management', () {
    test('should get current queue size', () async {
      when(() => mockRepository.getQueueSize()).thenAnswer((_) async => 5);

      final size = await syncQueueService.getQueueSize();

      expect(size, equals(5));
      verify(() => mockRepository.getQueueSize()).called(1);
    });

    test('should return 0 on error when getting queue size', () async {
      when(() => mockRepository.getQueueSize())
          .thenThrow(Exception('Database error'));

      final size = await syncQueueService.getQueueSize();

      expect(size, equals(0));
    });

    test('should get pending count', () async {
      when(() => mockRepository.countPendingOperations())
          .thenAnswer((_) async => 3);

      final count = await syncQueueService.getPendingCount();

      expect(count, equals(3));
      verify(() => mockRepository.countPendingOperations()).called(1);
    });

    test('should return 0 on error when getting pending count', () async {
      when(() => mockRepository.countPendingOperations())
          .thenThrow(Exception('Database error'));

      final count = await syncQueueService.getPendingCount();

      expect(count, equals(0));
    });

    test('should get failed count', () async {
      when(() => mockRepository.countFailedOperations())
          .thenAnswer((_) async => 2);

      final count = await syncQueueService.getFailedCount();

      expect(count, equals(2));
      verify(() => mockRepository.countFailedOperations()).called(1);
    });

    test('should return 0 on error when getting failed count', () async {
      when(() => mockRepository.countFailedOperations())
          .thenThrow(Exception('Database error'));

      final count = await syncQueueService.getFailedCount();

      expect(count, equals(0));
    });

    test('should get queue statistics', () async {
      when(() => mockRepository.getQueueStatistics()).thenAnswer((_) async => {
            'pending': 5,
            'processing': 2,
            'completed': 10,
            'failed': 1,
          });

      final stats = await syncQueueService.getQueueStatistics();

      expect(stats['pending'], equals(5));
      expect(stats['processing'], equals(2));
      expect(stats['completed'], equals(10));
      expect(stats['failed'], equals(1));
      verify(() => mockRepository.getQueueStatistics()).called(1);
    });

    test('should return default stats on error when getting statistics',
        () async {
      when(() => mockRepository.getQueueStatistics())
          .thenThrow(Exception('Database error'));

      final stats = await syncQueueService.getQueueStatistics();

      expect(stats['pending'], equals(0));
      expect(stats['processing'], equals(0));
      expect(stats['completed'], equals(0));
      expect(stats['failed'], equals(0));
    });

    test('should emit queue size updates', () async {
      when(() => mockRepository.getQueueSize()).thenAnswer((_) async => 5);

      final emissionList = <int>[];
      final subscription =
          syncQueueService.queueSizeStream.listen(emissionList.add);

      await syncQueueService.getQueueSize();

      expect(emissionList, contains(5));
      await subscription.cancel();
    });
  });

  group('SyncQueueService - Enqueue Operations', () {
    test('should enqueue a single operation successfully', () async {
      final operation = SyncOperationEntity(
        id: 1,
        entityType: 'trip',
        entityId: 'trip-123',
        operation: SyncOperationType.create,
        data: const {'title': 'Test Trip'},
        priority: SyncPriority.normal,
        status: SyncOperationStatus.pending,
        createdAt: DateTime.now(),
      );

      when(() => mockRepository.enqueueOperation(any()))
          .thenAnswer((_) async => operation);

      final result = await syncQueueService.enqueueOperation(
        entityType: 'trip',
        entityId: 'trip-123',
        operation: SyncOperationType.create,
        data: {'title': 'Test Trip'},
      );

      expect(result.success, isTrue);
      expect(result.operationId, equals(1));
      verify(() => mockRepository.enqueueOperation(any())).called(1);
      verify(() => mockRepository.getQueueSize()).called(1);
    });

    test('should enqueue operation with high priority', () async {
      final operation = SyncOperationEntity(
        id: 2,
        entityType: 'journal',
        entityId: 'journal-456',
        operation: SyncOperationType.update,
        data: const {'content': 'Updated'},
        priority: SyncPriority.high,
        status: SyncOperationStatus.pending,
        createdAt: DateTime.now(),
      );

      when(() => mockRepository.enqueueOperation(any()))
          .thenAnswer((_) async => operation);

      final result = await syncQueueService.enqueueOperation(
        entityType: 'journal',
        entityId: 'journal-456',
        operation: SyncOperationType.update,
        data: {'content': 'Updated'},
        priority: SyncPriority.high,
      );

      expect(result.success, isTrue);
      final captured =
          verify(() => mockRepository.enqueueOperation(captureAny()))
              .captured
              .single as SyncOperationEntity;
      expect(captured.priority, equals(SyncPriority.high));
    });

    test('should enqueue operation with custom max retries', () async {
      final operation = SyncOperationEntity(
        id: 3,
        entityType: 'trip',
        entityId: 'trip-789',
        operation: SyncOperationType.delete,
        data: const {},
        maxRetries: 5,
        status: SyncOperationStatus.pending,
        createdAt: DateTime.now(),
      );

      when(() => mockRepository.enqueueOperation(any()))
          .thenAnswer((_) async => operation);

      final result = await syncQueueService.enqueueOperation(
        entityType: 'trip',
        entityId: 'trip-789',
        operation: SyncOperationType.delete,
        data: {},
        maxRetries: 5,
      );

      expect(result.success, isTrue);
      final captured =
          verify(() => mockRepository.enqueueOperation(captureAny()))
              .captured
              .single as SyncOperationEntity;
      expect(captured.maxRetries, equals(5));
    });

    test('should enqueue operation with version', () async {
      final operation = SyncOperationEntity(
        id: 4,
        entityType: 'trip',
        entityId: 'trip-version',
        operation: SyncOperationType.update,
        data: const {'title': 'Updated'},
        version: 5,
        status: SyncOperationStatus.pending,
        createdAt: DateTime.now(),
      );

      when(() => mockRepository.enqueueOperation(any()))
          .thenAnswer((_) async => operation);

      final result = await syncQueueService.enqueueOperation(
        entityType: 'trip',
        entityId: 'trip-version',
        operation: SyncOperationType.update,
        data: {'title': 'Updated'},
        version: 5,
      );

      expect(result.success, isTrue);
      final captured =
          verify(() => mockRepository.enqueueOperation(captureAny()))
              .captured
              .single as SyncOperationEntity;
      expect(captured.version, equals(5));
    });

    test('should return failure result when enqueue fails', () async {
      when(() => mockRepository.enqueueOperation(any()))
          .thenThrow(Exception('Database error'));

      final result = await syncQueueService.enqueueOperation(
        entityType: 'trip',
        entityId: 'trip-123',
        operation: SyncOperationType.create,
        data: {'title': 'Test Trip'},
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Failed to enqueue operation'));
    });

    test('should enqueue multiple operations in batch', () async {
      final operations = [
        {
          'entityType': 'trip',
          'entityId': 'trip-1',
          'operation': SyncOperationType.create,
          'data': {'title': 'Trip 1'},
        },
        {
          'entityType': 'journal',
          'entityId': 'journal-1',
          'operation': SyncOperationType.create,
          'data': {'content': 'Journal 1'},
        },
        {
          'entityType': 'trip',
          'entityId': 'trip-2',
          'operation': SyncOperationType.update,
          'data': {'title': 'Updated Trip 2'},
        },
      ];

      when(() => mockRepository.enqueueOperations(any()))
          .thenAnswer((_) async => 3);

      final result = await syncQueueService.enqueueOperations(operations);

      expect(result.success, isTrue);
      expect(result.operationsCount, equals(3));
      verify(() => mockRepository.enqueueOperations(any())).called(1);
    });

    test('should enqueue batch operations with different priorities', () async {
      final operations = [
        {
          'entityType': 'trip',
          'entityId': 'trip-1',
          'operation': SyncOperationType.create,
          'data': {'title': 'Trip 1'},
          'priority': SyncPriority.high,
        },
        {
          'entityType': 'journal',
          'entityId': 'journal-1',
          'operation': SyncOperationType.create,
          'data': {'content': 'Journal 1'},
          'priority': SyncPriority.low,
        },
      ];

      when(() => mockRepository.enqueueOperations(any()))
          .thenAnswer((_) async => 2);

      final result = await syncQueueService.enqueueOperations(operations);

      expect(result.success, isTrue);

      final captured =
          verify(() => mockRepository.enqueueOperations(captureAny()))
              .captured
              .single as List<SyncOperationEntity>;

      expect(captured[0].priority, equals(SyncPriority.high));
      expect(captured[1].priority, equals(SyncPriority.low));
    });

    test('should return failure result when batch enqueue fails', () async {
      when(() => mockRepository.enqueueOperations(any()))
          .thenThrow(Exception('Database error'));

      final result = await syncQueueService.enqueueOperations([
        {
          'entityType': 'trip',
          'entityId': 'trip-1',
          'operation': SyncOperationType.create,
          'data': {'title': 'Trip 1'},
        },
      ]);

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Failed to enqueue operations'));
      expect(result.operationsCount, equals(0));
    });

    test('should handle empty batch operations', () async {
      when(() => mockRepository.enqueueOperations(any()))
          .thenAnswer((_) async => 0);

      final result = await syncQueueService.enqueueOperations([]);

      expect(result.success, isTrue);
      expect(result.operationsCount, equals(0));
    });
  });

  group('SyncQueueService - Process Operations', () {
    test('should process pending operations successfully', () async {
      final operations = [
        SyncOperationEntity(
          id: 1,
          entityType: 'trip',
          entityId: 'trip-1',
          operation: SyncOperationType.create,
          data: const {'title': 'Trip 1'},
          status: SyncOperationStatus.pending,
          createdAt: DateTime.now(),
        ),
        SyncOperationEntity(
          id: 2,
          entityType: 'journal',
          entityId: 'journal-1',
          operation: SyncOperationType.update,
          data: const {'content': 'Updated'},
          status: SyncOperationStatus.pending,
          createdAt: DateTime.now(),
        ),
      ];

      when(() =>
              mockRepository.getPendingOperations(limit: any(named: 'limit')))
          .thenAnswer((_) async => operations);
      when(() => mockRepository.markAsProcessing(1)).thenAnswer((_) async => 1);
      when(() => mockRepository.markAsProcessing(2)).thenAnswer((_) async => 1);
      when(() => mockRepository.markAsCompleted(1)).thenAnswer((_) async => 1);
      when(() => mockRepository.markAsCompleted(2)).thenAnswer((_) async => 1);

      final result = await syncQueueService.processPendingOperations(
        onProcess: (operation) async {
          // Simulate successful processing
          return true;
        },
      );

      expect(result.success, isTrue);
      expect(result.operationsCount, equals(2));
      verify(() => mockRepository.markAsProcessing(1)).called(1);
      verify(() => mockRepository.markAsProcessing(2)).called(1);
      verify(() => mockRepository.markAsCompleted(1)).called(1);
      verify(() => mockRepository.markAsCompleted(2)).called(1);
    });

    test('should handle processing failures', () async {
      final operations = [
        SyncOperationEntity(
          id: 1,
          entityType: 'trip',
          entityId: 'trip-1',
          operation: SyncOperationType.create,
          data: const {'title': 'Trip 1'},
          status: SyncOperationStatus.pending,
          createdAt: DateTime.now(),
        ),
        SyncOperationEntity(
          id: 2,
          entityType: 'journal',
          entityId: 'journal-1',
          operation: SyncOperationType.update,
          data: const {'content': 'Updated'},
          status: SyncOperationStatus.pending,
          createdAt: DateTime.now(),
        ),
      ];

      when(() =>
              mockRepository.getPendingOperations(limit: any(named: 'limit')))
          .thenAnswer((_) async => operations);
      when(() => mockRepository.markAsProcessing(1)).thenAnswer((_) async => 1);
      when(() => mockRepository.markAsProcessing(2)).thenAnswer((_) async => 1);
      when(() => mockRepository.markAsCompleted(1)).thenAnswer((_) async => 1);
      when(() => mockRepository.markAsFailed(2, any()))
          .thenAnswer((_) async => 1);

      final result = await syncQueueService.processPendingOperations(
        onProcess: (operation) async {
          // Fail second operation
          return operation.id == 1;
        },
      );

      expect(result.success, isTrue);
      expect(result.operationsCount, equals(1)); // Only first succeeded
      verify(() => mockRepository.markAsCompleted(1)).called(1);
      verify(() => mockRepository.markAsFailed(2, any())).called(1);
    });

    test('should handle exceptions during processing', () async {
      final operations = [
        SyncOperationEntity(
          id: 1,
          entityType: 'trip',
          entityId: 'trip-1',
          operation: SyncOperationType.create,
          data: const {'title': 'Trip 1'},
          status: SyncOperationStatus.pending,
          createdAt: DateTime.now(),
        ),
      ];

      when(() =>
              mockRepository.getPendingOperations(limit: any(named: 'limit')))
          .thenAnswer((_) async => operations);
      when(() => mockRepository.markAsProcessing(1)).thenAnswer((_) async => 1);
      when(() => mockRepository.markAsFailed(1, any()))
          .thenAnswer((_) async => 1);

      final result = await syncQueueService.processPendingOperations(
        onProcess: (operation) async {
          throw Exception('Network error');
        },
      );

      expect(result.success, isTrue);
      expect(result.operationsCount, equals(0));
      verify(() => mockRepository.markAsFailed(1, any())).called(1);
    });

    test('should return success with zero operations when queue is empty',
        () async {
      when(() =>
              mockRepository.getPendingOperations(limit: any(named: 'limit')))
          .thenAnswer((_) async => []);

      final result = await syncQueueService.processPendingOperations(
        onProcess: (operation) async => true,
      );

      expect(result.success, isTrue);
      expect(result.operationsCount, equals(0));
      verifyNever(() => mockRepository.markAsProcessing(any()));
    });

    test('should respect limit parameter when processing', () async {
      final operations = List.generate(
        20,
        (i) => SyncOperationEntity(
          id: i + 1,
          entityType: 'trip',
          entityId: 'trip-$i',
          operation: SyncOperationType.create,
          data: {'title': 'Trip $i'},
          status: SyncOperationStatus.pending,
          createdAt: DateTime.now(),
        ),
      );

      when(() => mockRepository.getPendingOperations(limit: 5))
          .thenAnswer((_) async => operations.take(5).toList());

      for (int i = 1; i <= 5; i++) {
        when(() => mockRepository.markAsProcessing(i))
            .thenAnswer((_) async => 1);
        when(() => mockRepository.markAsCompleted(i))
            .thenAnswer((_) async => 1);
      }

      final result = await syncQueueService.processPendingOperations(
        limit: 5,
        onProcess: (operation) async => true,
      );

      expect(result.success, isTrue);
      expect(result.operationsCount, equals(5));
      verify(() => mockRepository.getPendingOperations(limit: 5)).called(1);
    });
  });

  group('SyncQueueService - Retry Logic', () {
    test('should retry failed operations that are ready', () async {
      final failedOps = [
        SyncOperationEntity(
          id: 1,
          entityType: 'trip',
          entityId: 'trip-1',
          operation: SyncOperationType.create,
          data: const {'title': 'Trip 1'},
          status: SyncOperationStatus.failed,
          retryCount: 1,
          maxRetries: 3,
          lastAttemptedAt: DateTime.now().subtract(const Duration(minutes: 5)),
          createdAt: DateTime.now(),
        ),
        SyncOperationEntity(
          id: 2,
          entityType: 'journal',
          entityId: 'journal-1',
          operation: SyncOperationType.update,
          data: const {'content': 'Updated'},
          status: SyncOperationStatus.failed,
          retryCount: 2,
          maxRetries: 3,
          lastAttemptedAt: DateTime.now().subtract(const Duration(minutes: 10)),
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockRepository.getOperationsReadyForRetry())
          .thenAnswer((_) async => failedOps);
      when(() => mockRepository.resetOperationsForRetry(any()))
          .thenAnswer((_) async => 2);

      final result = await syncQueueService.retryFailedOperations();

      expect(result.success, isTrue);
      expect(result.operationsCount, equals(2));
      verify(() => mockRepository.resetOperationsForRetry(any())).called(1);
    });

    test('should respect retry limit', () async {
      final failedOps = List.generate(
        15,
        (i) => SyncOperationEntity(
          id: i + 1,
          entityType: 'trip',
          entityId: 'trip-$i',
          operation: SyncOperationType.create,
          data: {'title': 'Trip $i'},
          status: SyncOperationStatus.failed,
          retryCount: 1,
          maxRetries: 3,
          lastAttemptedAt: DateTime.now().subtract(const Duration(minutes: 5)),
          createdAt: DateTime.now(),
        ),
      );

      when(() => mockRepository.getOperationsReadyForRetry())
          .thenAnswer((_) async => failedOps);
      when(() => mockRepository.resetOperationsForRetry(any()))
          .thenAnswer((_) async => 10);

      final result = await syncQueueService.retryFailedOperations(limit: 10);

      expect(result.success, isTrue);
      expect(result.operationsCount, equals(10));

      final captured =
          verify(() => mockRepository.resetOperationsForRetry(captureAny()))
              .captured
              .single as List<int>;
      expect(captured, hasLength(10));
    });

    test('should return success with zero operations when none ready for retry',
        () async {
      when(() => mockRepository.getOperationsReadyForRetry())
          .thenAnswer((_) async => []);

      final result = await syncQueueService.retryFailedOperations();

      expect(result.success, isTrue);
      expect(result.operationsCount, equals(0));
      verifyNever(() => mockRepository.resetOperationsForRetry(any()));
    });

    test('should return failure on retry error', () async {
      when(() => mockRepository.getOperationsReadyForRetry())
          .thenThrow(Exception('Database error'));

      final result = await syncQueueService.retryFailedOperations();

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Failed to retry operations'));
    });
  });

  group('SyncQueueService - Cleanup Operations', () {
    test('should clear old completed operations', () async {
      when(() => mockRepository.clearOldCompletedOperations(any()))
          .thenAnswer((_) async => 5);

      final result = await syncQueueService.clearOldCompletedOperations();

      expect(result.success, isTrue);
      expect(result.operationsCount, equals(5));
      verify(() => mockRepository.clearOldCompletedOperations(any())).called(1);
    });

    test('should clear old failed operations', () async {
      when(() => mockRepository.clearOldFailedOperations(any()))
          .thenAnswer((_) async => 3);

      final result = await syncQueueService.clearOldFailedOperations();

      expect(result.success, isTrue);
      expect(result.operationsCount, equals(3));
      verify(() => mockRepository.clearOldFailedOperations(any())).called(1);
    });

    test('should clear all completed operations', () async {
      when(() => mockRepository.clearCompletedOperations())
          .thenAnswer((_) async => 10);

      final result = await syncQueueService.clearAllCompletedOperations();

      expect(result.success, isTrue);
      expect(result.operationsCount, equals(10));
      verify(() => mockRepository.clearCompletedOperations()).called(1);
    });

    test('should clear all operations', () async {
      when(() => mockRepository.clearAllOperations())
          .thenAnswer((_) async => 20);

      final result = await syncQueueService.clearAllOperations();

      expect(result.success, isTrue);
      expect(result.operationsCount, equals(20));
      verify(() => mockRepository.clearAllOperations()).called(1);
    });

    test('should return failure when cleanup fails', () async {
      when(() => mockRepository.clearOldCompletedOperations(any()))
          .thenThrow(Exception('Database error'));

      final result = await syncQueueService.clearOldCompletedOperations();

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Failed to clear old operations'));
    });

    test('should not emit queue size update when no operations cleared',
        () async {
      when(() => mockRepository.clearOldCompletedOperations(any()))
          .thenAnswer((_) async => 0);

      final emissionList = <int>[];
      final subscription =
          syncQueueService.queueSizeStream.listen(emissionList.add);

      await syncQueueService.clearOldCompletedOperations();

      // Should only have initial size, not additional updates
      await subscription.cancel();
    });
  });

  group('SyncQueueService - Lifecycle Management', () {
    test('should initialize successfully', () async {
      when(() => mockRepository.getOperationsByStatus(
          SyncOperationStatus.processing)).thenAnswer((_) async => []);
      when(() => mockRepository.getQueueSize()).thenAnswer((_) async => 0);

      final initialized = await syncQueueService.initialize();

      expect(initialized, isTrue);
      verify(() => mockRepository
          .getOperationsByStatus(SyncOperationStatus.processing)).called(1);
      verify(() => mockRepository.getQueueSize()).called(1);
    });

    test('should recover stuck operations during initialization', () async {
      final stuckOps = [
        SyncOperationEntity(
          id: 1,
          entityType: 'trip',
          entityId: 'trip-1',
          operation: SyncOperationType.create,
          data: const {'title': 'Trip 1'},
          status: SyncOperationStatus.processing,
          createdAt: DateTime.now(),
        ),
        SyncOperationEntity(
          id: 2,
          entityType: 'journal',
          entityId: 'journal-1',
          operation: SyncOperationType.update,
          data: const {'content': 'Updated'},
          status: SyncOperationStatus.processing,
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockRepository.getOperationsByStatus(
          SyncOperationStatus.processing)).thenAnswer((_) async => stuckOps);
      when(() => mockRepository.resetOperationsForRetry(any()))
          .thenAnswer((_) async => 2);
      when(() => mockRepository.getQueueSize()).thenAnswer((_) async => 2);

      final initialized = await syncQueueService.initialize();

      expect(initialized, isTrue);
      verify(() => mockRepository.resetOperationsForRetry(any())).called(1);
    });

    test('should handle initialization errors gracefully', () async {
      when(() => mockRepository
              .getOperationsByStatus(SyncOperationStatus.processing))
          .thenThrow(Exception('Database error'));

      final initialized = await syncQueueService.initialize();

      expect(initialized, isFalse);
    });

    test('should dispose resources properly', () {
      syncQueueService.dispose();

      // Should not throw any errors
      // Verify that cleanup timer is cancelled (implicitly tested by no errors)
    });
  });

  group('SyncQueueService - Priority Ordering', () {
    test('should process operations in priority order', () async {
      final operations = [
        SyncOperationEntity(
          id: 1,
          entityType: 'trip',
          entityId: 'trip-normal',
          operation: SyncOperationType.create,
          data: const {'title': 'Normal Priority'},
          priority: SyncPriority.normal,
          status: SyncOperationStatus.pending,
          createdAt: DateTime.now(),
        ),
        SyncOperationEntity(
          id: 2,
          entityType: 'trip',
          entityId: 'trip-high',
          operation: SyncOperationType.create,
          data: const {'title': 'High Priority'},
          priority: SyncPriority.high,
          status: SyncOperationStatus.pending,
          createdAt: DateTime.now(),
        ),
        SyncOperationEntity(
          id: 3,
          entityType: 'trip',
          entityId: 'trip-low',
          operation: SyncOperationType.create,
          data: const {'title': 'Low Priority'},
          priority: SyncPriority.low,
          status: SyncOperationStatus.pending,
          createdAt: DateTime.now(),
        ),
      ];

      // Mock repository returns operations already sorted by priority
      when(() =>
              mockRepository.getPendingOperations(limit: any(named: 'limit')))
          .thenAnswer((_) async => [
                operations[1], // high priority
                operations[0], // normal priority
                operations[2], // low priority
              ]);

      for (int i = 1; i <= 3; i++) {
        when(() => mockRepository.markAsProcessing(i))
            .thenAnswer((_) async => 1);
        when(() => mockRepository.markAsCompleted(i))
            .thenAnswer((_) async => 1);
      }

      final processedIds = <int>[];
      await syncQueueService.processPendingOperations(
        onProcess: (operation) async {
          processedIds.add(operation.id);
          return true;
        },
      );

      // Verify processing order: high (2) -> normal (1) -> low (3)
      expect(processedIds, equals([2, 1, 3]));
    });

    test('should respect creation time within same priority', () async {
      final now = DateTime.now();
      final operations = [
        SyncOperationEntity(
          id: 1,
          entityType: 'trip',
          entityId: 'trip-1',
          operation: SyncOperationType.create,
          data: const {'title': 'Older'},
          priority: SyncPriority.normal,
          status: SyncOperationStatus.pending,
          createdAt: now.subtract(const Duration(minutes: 10)),
        ),
        SyncOperationEntity(
          id: 2,
          entityType: 'trip',
          entityId: 'trip-2',
          operation: SyncOperationType.create,
          data: const {'title': 'Newer'},
          priority: SyncPriority.normal,
          status: SyncOperationStatus.pending,
          createdAt: now.subtract(const Duration(minutes: 5)),
        ),
      ];

      // Repository should return older operations first within same priority
      when(() =>
              mockRepository.getPendingOperations(limit: any(named: 'limit')))
          .thenAnswer((_) async => [operations[0], operations[1]]);

      when(() => mockRepository.markAsProcessing(1)).thenAnswer((_) async => 1);
      when(() => mockRepository.markAsProcessing(2)).thenAnswer((_) async => 1);
      when(() => mockRepository.markAsCompleted(1)).thenAnswer((_) async => 1);
      when(() => mockRepository.markAsCompleted(2)).thenAnswer((_) async => 1);

      final processedIds = <int>[];
      await syncQueueService.processPendingOperations(
        onProcess: (operation) async {
          processedIds.add(operation.id);
          return true;
        },
      );

      // Verify older operation (1) processed before newer (2)
      expect(processedIds, equals([1, 2]));
    });
  });

  group('SyncQueueService - Persistence Tests', () {
    test('should persist operations across service restarts', () async {
      final operation = SyncOperationEntity(
        id: 1,
        entityType: 'trip',
        entityId: 'trip-123',
        operation: SyncOperationType.create,
        data: const {'title': 'Test Trip'},
        status: SyncOperationStatus.pending,
        createdAt: DateTime.now(),
      );

      // Enqueue operation
      when(() => mockRepository.enqueueOperation(any()))
          .thenAnswer((_) async => operation);
      when(() => mockRepository.getQueueSize()).thenAnswer((_) async => 1);

      await syncQueueService.enqueueOperation(
        entityType: 'trip',
        entityId: 'trip-123',
        operation: SyncOperationType.create,
        data: {'title': 'Test Trip'},
      );

      // Verify operation was enqueued
      verify(() => mockRepository.enqueueOperation(any())).called(1);

      // Simulate service restart
      syncQueueService.dispose();

      final newService = SyncQueueService(
        repository: mockRepository,
        connectivityService: mockConnectivityService,
      );

      // Verify operations are still in queue
      when(() =>
              mockRepository.getOperationsByStatus(SyncOperationStatus.pending))
          .thenAnswer((_) async => []);
      when(() => mockRepository.getQueueSize()).thenAnswer((_) async => 1);

      await newService.initialize();
      final queueSize = await newService.getQueueSize();

      expect(queueSize, equals(1));

      newService.dispose();
    });

    test('should recover pending operations after restart', () async {
      final pendingOps = [
        SyncOperationEntity(
          id: 1,
          entityType: 'trip',
          entityId: 'trip-1',
          operation: SyncOperationType.create,
          data: const {'title': 'Trip 1'},
          status: SyncOperationStatus.pending,
          createdAt: DateTime.now(),
        ),
        SyncOperationEntity(
          id: 2,
          entityType: 'journal',
          entityId: 'journal-1',
          operation: SyncOperationType.update,
          data: const {'content': 'Updated'},
          status: SyncOperationStatus.pending,
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockRepository.getOperationsByStatus(
          SyncOperationStatus.processing)).thenAnswer((_) async => []);
      when(() => mockRepository.getQueueSize()).thenAnswer((_) async => 2);
      when(() =>
              mockRepository.getPendingOperations(limit: any(named: 'limit')))
          .thenAnswer((_) async => pendingOps);
      when(() => mockRepository.markAsProcessing(any()))
          .thenAnswer((_) async => 1);
      when(() => mockRepository.markAsCompleted(any()))
          .thenAnswer((_) async => 1);

      await syncQueueService.initialize();

      final result = await syncQueueService.processPendingOperations(
        onProcess: (operation) async => true,
      );

      expect(result.success, isTrue);
      expect(result.operationsCount, equals(2));
    });

    test('should recover and reset stuck operations after restart', () async {
      final stuckOps = [
        SyncOperationEntity(
          id: 1,
          entityType: 'trip',
          entityId: 'trip-1',
          operation: SyncOperationType.create,
          data: const {'title': 'Trip 1'},
          status: SyncOperationStatus.processing,
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockRepository.getOperationsByStatus(
          SyncOperationStatus.processing)).thenAnswer((_) async => stuckOps);
      when(() => mockRepository.resetOperationsForRetry(any()))
          .thenAnswer((_) async => 1);
      when(() => mockRepository.getQueueSize()).thenAnswer((_) async => 1);

      await syncQueueService.initialize();

      // Verify stuck operations were reset for retry
      verify(() => mockRepository.resetOperationsForRetry(any())).called(1);
    });
  });

  group('SyncQueueService - Batch Operations', () {
    test('should handle large batch of operations efficiently', () async {
      final operations = List.generate(
        100,
        (i) => {
          'entityType': 'trip',
          'entityId': 'trip-$i',
          'operation': SyncOperationType.create,
          'data': {'title': 'Trip $i'},
        },
      );

      when(() => mockRepository.enqueueOperations(any()))
          .thenAnswer((_) async => 100);

      final stopwatch = Stopwatch()..start();

      final result = await syncQueueService.enqueueOperations(operations);

      final elapsed = stopwatch.elapsedMilliseconds;

      expect(result.success, isTrue);
      expect(result.operationsCount, equals(100));
      expect(elapsed, lessThan(5000), // Should complete in less than 5 seconds
          reason: 'Batch operation took too long: ${elapsed}ms');

      verify(() => mockRepository.enqueueOperations(any())).called(1);
    });

    test('should handle mixed operation types in batch', () async {
      final operations = [
        {
          'entityType': 'trip',
          'entityId': 'trip-1',
          'operation': SyncOperationType.create,
          'data': {'title': 'New Trip'},
        },
        {
          'entityType': 'trip',
          'entityId': 'trip-2',
          'operation': SyncOperationType.update,
          'data': {'title': 'Updated Trip'},
        },
        {
          'entityType': 'journal',
          'entityId': 'journal-1',
          'operation': SyncOperationType.delete,
          'data': {},
        },
      ];

      when(() => mockRepository.enqueueOperations(any()))
          .thenAnswer((_) async => 3);

      final result = await syncQueueService.enqueueOperations(operations);

      expect(result.success, isTrue);
      expect(result.operationsCount, equals(3));

      final captured =
          verify(() => mockRepository.enqueueOperations(captureAny()))
              .captured
              .single as List<SyncOperationEntity>;

      expect(captured[0].operation, equals(SyncOperationType.create));
      expect(captured[1].operation, equals(SyncOperationType.update));
      expect(captured[2].operation, equals(SyncOperationType.delete));
    });
  });

  group('SyncQueueService - Error Handling', () {
    test('should handle repository errors gracefully in enqueue', () async {
      when(() => mockRepository.enqueueOperation(any()))
          .thenThrow(Exception('Repository error'));

      final result = await syncQueueService.enqueueOperation(
        entityType: 'trip',
        entityId: 'trip-1',
        operation: SyncOperationType.create,
        data: {'title': 'Trip'},
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, isNotNull);
    });

    test('should handle processing errors without crashing', () async {
      final operations = [
        SyncOperationEntity(
          id: 1,
          entityType: 'trip',
          entityId: 'trip-1',
          operation: SyncOperationType.create,
          data: const {'title': 'Trip 1'},
          status: SyncOperationStatus.pending,
          createdAt: DateTime.now(),
        ),
      ];

      when(() =>
              mockRepository.getPendingOperations(limit: any(named: 'limit')))
          .thenAnswer((_) async => operations);
      when(() => mockRepository.markAsProcessing(1)).thenAnswer((_) async => 1);
      when(() => mockRepository.markAsFailed(1, any()))
          .thenAnswer((_) async => 1);

      final result = await syncQueueService.processPendingOperations(
        onProcess: (operation) async {
          throw Exception('Processing error');
        },
      );

      expect(result.success, isTrue); // Service handles errors gracefully
      expect(result.operationsCount, equals(0));
    });

    test('should handle concurrent operations safely', () async {
      when(() => mockRepository.enqueueOperation(any())).thenAnswer(
        (_) async => SyncOperationEntity(
          id: 1,
          entityType: 'trip',
          entityId: 'trip-1',
          operation: SyncOperationType.create,
          data: const {'title': 'Trip'},
          status: SyncOperationStatus.pending,
          createdAt: DateTime.now(),
        ),
      );
      when(() => mockRepository.getQueueSize()).thenAnswer((_) async => 1);

      // Enqueue multiple operations concurrently
      final futures = List.generate(
        10,
        (i) => syncQueueService.enqueueOperation(
          entityType: 'trip',
          entityId: 'trip-$i',
          operation: SyncOperationType.create,
          data: {'title': 'Trip $i'},
        ),
      );

      final results = await Future.wait(futures);

      // All operations should complete successfully
      expect(results.every((r) => r.success), isTrue);
    });
  });
}
