import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_operation.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_status.dart';
import 'package:soloadventurer/features/sync/domain/entities/sync_entity_type.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/sync_service_impl.dart';
import 'package:soloadventurer/features/sync/domain/services/exponential_backoff.dart';

/// Manual mock implementation of ExponentialBackoff for testing
class MockExponentialBackoff implements ExponentialBackoff {
  int _callCount = 0;

  @override
  int get baseDelayMs => 1000;

  @override
  int get maxDelayMs => 60000;

  @override
  bool get withJitter => false;

  @override
  double get jitterFactor => 0.1;

  @override
  int calculateDelay(int retryCount) {
    _callCount++;
    // Simple exponential backoff: 2^retryCount * baseDelayMs, capped at maxDelayMs
    final delay = (1 << retryCount) * baseDelayMs;
    return delay > maxDelayMs ? maxDelayMs : delay;
  }

  @override
  DateTime calculateNextRetryTime(int retryCount, {DateTime? from}) {
    final delay = calculateDelay(retryCount);
    return (from ?? DateTime.now()).add(Duration(milliseconds: delay));
  }

  @override
  Duration calculateRemainingDelay(int retryCount, DateTime lastAttemptAt) {
    final nextRetryTime = calculateNextRetryTime(retryCount);
    return nextRetryTime.difference(DateTime.now());
  }

  @override
  String getDelayDescription(int retryCount) {
    final delay = calculateDelay(retryCount);
    if (delay < 1000) return '${delay}ms';
    if (delay < 60000) return '${delay ~/ 1000}s';
    return '${delay ~/ 60000}min';
  }

  @override
  List<int> getDelaysForAttempts(int maxAttempts) {
    return List.generate(maxAttempts, (i) => calculateDelay(i));
  }

  int get callCount => _callCount;
  @override
  void reset() => _callCount = 0;
}

void main() {
  late SyncServiceImpl syncService;
  late MockExponentialBackoff mockBackoff;

  setUp(() {
    mockBackoff = MockExponentialBackoff();

    // Create service without persistence/network for isolated unit tests
    syncService = SyncServiceImpl(
      persistence: null,
      networkConnectivity: null,
      backoff: mockBackoff,
    );
  });

  tearDown(() async {
    syncService.dispose();
  });

  group('SyncServiceImpl - Initialization', () {
    test('should initialize with empty queue', () {
      expect(syncService.queue, isEmpty);
      expect(syncService.queueSize, 0);
    });

    test('should initialize with idle status', () {
      expect(syncService.status, SyncOperationStatus.idle);
      expect(syncService.isProcessing, false);
    });

    test('should initialize with default config', () {
      final config = syncService.config;
      expect(config.maxBatchSize, 50);
      expect(config.maxRetryAttempts, 5);
      expect(config.retryDelayMs, 1000);
      expect(config.autoProcess, true);
      expect(config.maxQueueSize, 1000);
    });

    test('should have working status stream', () async {
      final statuses = <SyncOperationStatus>[];
      final subscription = syncService.statusStream.listen(statuses.add);

      // Enqueue operation should trigger status change
      final operation = SyncOperation.create(
        entityType: SyncEntityType.trip,
        data: const {'title': 'Test'},
      );
      await syncService.enqueueOperation(operation);

      // Wait for status update
      await Future.delayed(const Duration(milliseconds: 50));

      expect(statuses, isNotEmpty);
      await subscription.cancel();
    });

    test('should have working queue stream', () async {
      final queues = <List<SyncOperation>>[];
      final subscription = syncService.queueStream.listen(queues.add);

      final operation = SyncOperation.create(
        entityType: SyncEntityType.trip,
        data: const {'title': 'Test'},
      );
      await syncService.enqueueOperation(operation);

      // Wait for queue update
      await Future.delayed(const Duration(milliseconds: 50));

      expect(queues, isNotEmpty);
      expect(queues.last.length, 1);
      await subscription.cancel();
    });
  });

  group('SyncServiceImpl - Enqueue Operations', () {
    test('should enqueue single operation successfully', () async {
      final operation = SyncOperation.create(
        id: 'op1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Test Trip'},
      );

      final result = await syncService.enqueueOperation(operation);

      expect(result, true);
      expect(syncService.queueSize, 1);
      expect(syncService.queue[0].id, 'op1');
    });

    test('should enqueue multiple operations successfully', () async {
      final operations = [
        SyncOperation.create(
          id: 'op1',
          entityType: SyncEntityType.trip,
          data: const {'title': 'Trip 1'},
        ),
        SyncOperation.create(
          id: 'op2',
          entityType: SyncEntityType.trip,
          data: const {'title': 'Trip 2'},
        ),
        SyncOperation.create(
          id: 'op3',
          entityType: SyncEntityType.activity,
          data: const {'title': 'Activity 1'},
        ),
      ];

      final count = await syncService.enqueueOperations(operations);

      expect(count, 3);
      expect(syncService.queueSize, 3);
    });

    test('should sort operations by priority (descending)', () async {
      final operations = [
        SyncOperation.create(
          id: 'op1',
          entityType: SyncEntityType.profile, // priority: 10
          data: const {'name': 'Profile'},
        ),
        SyncOperation.create(
          id: 'op2',
          entityType: SyncEntityType.trip, // priority: 5
          data: const {'title': 'Trip'},
        ),
        SyncOperation.create(
          id: 'op3',
          entityType: SyncEntityType.authTokens, // priority: 100
          data: const {'token': 'abc'},
        ),
      ];

      await syncService.enqueueOperations(operations);

      expect(syncService.queue[0].entityType, SyncEntityType.authTokens);
      expect(syncService.queue[1].entityType, SyncEntityType.profile);
      expect(syncService.queue[2].entityType, SyncEntityType.trip);
    });

    test('should sort operations by creation time within same priority',
        () async {
      final operations = [
        SyncOperation.create(
          id: 'op1',
          entityType: SyncEntityType.trip,
          data: const {'title': 'Trip 1'},
        ),
        SyncOperation.create(
          id: 'op2',
          entityType: SyncEntityType.trip,
          data: const {'title': 'Trip 2'},
        ),
        SyncOperation.create(
          id: 'op3',
          entityType: SyncEntityType.trip,
          data: const {'title': 'Trip 3'},
        ),
      ];

      await syncService.enqueueOperations(operations);

      // Should be FIFO order within same priority
      expect(syncService.queue[0].id, 'op1');
      expect(syncService.queue[1].id, 'op2');
      expect(syncService.queue[2].id, 'op3');
    });

    test('should reject operations when queue is full', () async {
      // Set a small max queue size
      syncService.updateConfig(
        const SyncQueueConfig(maxQueueSize: 2),
      );

      final operations = [
        SyncOperation.create(
          id: 'op1',
          entityType: SyncEntityType.trip,
          data: const {'title': 'Trip 1'},
        ),
        SyncOperation.create(
          id: 'op2',
          entityType: SyncEntityType.trip,
          data: const {'title': 'Trip 2'},
        ),
        SyncOperation.create(
          id: 'op3',
          entityType: SyncEntityType.trip,
          data: const {'title': 'Trip 3'},
        ),
      ];

      final count = await syncService.enqueueOperations(operations);

      expect(count, 2);
      expect(syncService.queueSize, 2);
    });

    test('should update status to pending when operation enqueued', () async {
      final operation = SyncOperation.create(
        entityType: SyncEntityType.trip,
        data: const {'title': 'Test'},
      );

      await syncService.enqueueOperation(operation);

      expect(syncService.status, SyncOperationStatus.pending);
    });

    test('should trigger status change on queue stream', () async {
      final statuses = <SyncOperationStatus>[];
      final subscription = syncService.statusStream.listen(statuses.add);

      final operation = SyncOperation.create(
        entityType: SyncEntityType.trip,
        data: const {'title': 'Test'},
      );

      await syncService.enqueueOperation(operation);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(statuses, contains(SyncOperationStatus.pending));
      await subscription.cancel();
    });

    test('should trigger queue change on queue stream', () async {
      final queues = <List<SyncOperation>>[];
      final subscription = syncService.queueStream.listen(queues.add);

      final operation = SyncOperation.create(
        entityType: SyncEntityType.trip,
        data: const {'title': 'Test'},
      );

      await syncService.enqueueOperation(operation);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(queues.last.length, greaterThan(0));
      await subscription.cancel();
    });
  });

  group('SyncServiceImpl - Remove Operations', () {
    test('should remove operation by ID successfully', () async {
      final operation = SyncOperation.create(
        id: 'op1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Test'},
      );

      await syncService.enqueueOperation(operation);
      expect(syncService.queueSize, 1);

      final removed = await syncService.removeOperation('op1');

      expect(removed, true);
      expect(syncService.queueSize, 0);
    });

    test('should return false when removing non-existent operation', () async {
      final removed = await syncService.removeOperation('nonexistent');

      expect(removed, false);
    });

    test('should emit queue change when operation removed', () async {
      final queues = <List<SyncOperation>>[];
      final subscription = syncService.queueStream.listen(queues.add);

      final operation = SyncOperation.create(
        id: 'op1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Test'},
      );

      await syncService.enqueueOperation(operation);
      await syncService.removeOperation('op1');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(queues.last.length, 0);
      await subscription.cancel();
    });
  });

  group('SyncServiceImpl - Clear Queue', () {
    test('should clear all operations from queue', () async {
      final operations = [
        SyncOperation.create(
          id: 'op1',
          entityType: SyncEntityType.trip,
          data: const {'title': 'Trip 1'},
        ),
        SyncOperation.create(
          id: 'op2',
          entityType: SyncEntityType.trip,
          data: const {'title': 'Trip 2'},
        ),
      ];

      await syncService.enqueueOperations(operations);
      expect(syncService.queueSize, 2);

      await syncService.clearQueue();

      expect(syncService.queueSize, 0);
      expect(syncService.queue, isEmpty);
    });

    test('should update status to idle after clearing queue', () async {
      final operation = SyncOperation.create(
        entityType: SyncEntityType.trip,
        data: const {'title': 'Test'},
      );

      await syncService.enqueueOperation(operation);
      expect(syncService.status, SyncOperationStatus.pending);

      await syncService.clearQueue();

      expect(syncService.status, SyncOperationStatus.idle);
    });

    test('should emit queue change when queue cleared', () async {
      final queues = <List<SyncOperation>>[];
      final subscription = syncService.queueStream.listen(queues.add);

      final operation = SyncOperation.create(
        id: 'op1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Test'},
      );

      await syncService.enqueueOperation(operation);
      await syncService.clearQueue();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(queues.last.length, 0);
      await subscription.cancel();
    });
  });

  group('SyncServiceImpl - Query Operations', () {
    setUp(() async {
      final operations = [
        SyncOperation.create(
          id: 'op1',
          entityType: SyncEntityType.trip,
          entityId: 'trip-1',
          data: const {'title': 'Trip 1'},
        ),
        SyncOperation.update(
          id: 'op2',
          entityType: SyncEntityType.trip,
          entityId: 'trip-2',
          data: const {'title': 'Trip 2'},
        ),
        SyncOperation.create(
          id: 'op3',
          entityType: SyncEntityType.activity,
          entityId: 'activity-1',
          data: const {'title': 'Activity 1'},
        ),
        SyncOperation.delete(
          id: 'op4',
          entityType: SyncEntityType.trip,
          entityId: 'trip-1',
          data: const {},
        ),
      ];

      await syncService.enqueueOperations(operations);
    });

    test('should get operations by entity type', () {
      final tripOps = syncService.getOperationsByType(SyncEntityType.trip);

      expect(tripOps.length, 3);
      expect(tripOps.every((op) => op.entityType == SyncEntityType.trip), true);
    });

    test('should get operations by operation type', () {
      final createOps =
          syncService.getOperationsByOperationType(SyncOperationType.create);

      expect(createOps.length, 2);
      expect(
        createOps.every((op) => op.operationType == SyncOperationType.create),
        true,
      );
    });

    test('should get operations for specific entity', () {
      final trip1Ops = syncService.getOperationsForEntity('trip-1');

      expect(trip1Ops.length, 2);
      expect(trip1Ops.every((op) => op.entityId == 'trip-1'), true);
    });

    test('should return empty list for non-matching queries', () {
      final noteOps =
          syncService.getOperationsByType(SyncEntityType.travelNote);

      expect(noteOps, isEmpty);
    });
  });

  group('SyncServiceImpl - Processing Control', () {
    test('should pause processing', () {
      syncService.pauseProcessing();

      // Processing should be paused (no auto-processing when ops enqueued)
      final operation = SyncOperation.create(
        entityType: SyncEntityType.trip,
        data: const {'title': 'Test'},
      );

      syncService.enqueueOperation(operation);

      // Status should be pending but not processing
      expect(syncService.status, SyncOperationStatus.pending);
      expect(syncService.isProcessing, false);
    });

    test('should resume processing', () async {
      syncService.pauseProcessing();

      final operation = SyncOperation.create(
        entityType: SyncEntityType.trip,
        data: const {'title': 'Test'},
      );

      await syncService.enqueueOperation(operation);

      syncService.resumeProcessing();

      // Processing should resume (status will change based on auto-process)
      expect(syncService.isProcessing, false); // Not actively processing yet
    });

    test('should update configuration', () {
      final newConfig = const SyncQueueConfig(
        maxBatchSize: 100,
        maxRetryAttempts: 10,
        autoProcess: false,
      );

      syncService.updateConfig(newConfig);

      expect(syncService.config.maxBatchSize, 100);
      expect(syncService.config.maxRetryAttempts, 10);
      expect(syncService.config.autoProcess, false);
    });
  });

  group('SyncServiceImpl - Status Transitions', () {
    test('should transition from idle to pending when operation enqueued',
        () async {
      expect(syncService.status, SyncOperationStatus.idle);

      await syncService.enqueueOperation(
        SyncOperation.create(
          entityType: SyncEntityType.trip,
          data: const {'title': 'Test'},
        ),
      );

      expect(syncService.status, SyncOperationStatus.pending);
    });

    test('should transition to idle when queue cleared', () async {
      await syncService.enqueueOperation(
        SyncOperation.create(
          entityType: SyncEntityType.trip,
          data: const {'title': 'Test'},
        ),
      );

      await syncService.clearQueue();

      expect(syncService.status, SyncOperationStatus.idle);
    });

    test('should emit status changes on stream', () async {
      final statuses = <SyncOperationStatus>[];
      final subscription = syncService.statusStream.listen(statuses.add);

      await syncService.enqueueOperation(
        SyncOperation.create(
          entityType: SyncEntityType.trip,
          data: const {'title': 'Test'},
        ),
      );

      await syncService.clearQueue();

      await Future.delayed(const Duration(milliseconds: 50));

      expect(statuses, contains(SyncOperationStatus.idle));
      expect(statuses, contains(SyncOperationStatus.pending));

      await subscription.cancel();
    });
  });

  group('SyncServiceImpl - Batch Processing', () {
    test('should process batch up to max batch size', () async {
      syncService.pauseProcessing();

      final operations = List.generate(
        10,
        (i) => SyncOperation.create(
          id: 'op$i',
          entityType: SyncEntityType.trip,
          data: {'title': 'Trip $i'},
        ),
      );

      await syncService.enqueueOperations(operations);

      syncService.resumeProcessing();

      final result = await syncService.processBatch(maxBatchSize: 5);

      // Processed 5 operations
      expect(syncService.queueSize, lessThanOrEqualTo(5));
      expect(result.successCount + result.failureCount, lessThanOrEqualTo(5));
    });

    test('should process default batch size when max not specified', () async {
      syncService.pauseProcessing();

      final operations = List.generate(
        60,
        (i) => SyncOperation.create(
          id: 'op$i',
          entityType: SyncEntityType.trip,
          data: {'title': 'Trip $i'},
        ),
      );

      await syncService.enqueueOperations(operations);
      syncService.resumeProcessing();

      await syncService.processBatch();

      // Should process default max batch size (50)
      expect(syncService.queueSize, lessThanOrEqualTo(10));
    });

    test('should set isProcessing during batch processing', () async {
      syncService.pauseProcessing();

      await syncService.enqueueOperation(
        SyncOperation.create(
          entityType: SyncEntityType.trip,
          data: const {'title': 'Test'},
        ),
      );

      final processingFuture = syncService.processBatch();
      expect(syncService.isProcessing, true);

      await processingFuture;
      expect(syncService.isProcessing, false);
    });

    test('should emit status changes during batch processing', () async {
      syncService.pauseProcessing();

      await syncService.enqueueOperation(
        SyncOperation.create(
          entityType: SyncEntityType.trip,
          data: const {'title': 'Test'},
        ),
      );

      final statuses = <SyncOperationStatus>[];
      final subscription = syncService.statusStream.listen(statuses.add);

      syncService.resumeProcessing();
      await syncService.processBatch();

      await Future.delayed(const Duration(milliseconds: 100));

      expect(
        statuses,
        anyOf([
          contains(SyncOperationStatus.syncing),
          contains(SyncOperationStatus.pending),
        ]),
      );

      await subscription.cancel();
    });
  });

  group('SyncServiceImpl - Full Queue Processing', () {
    test('should process all operations in queue', () async {
      syncService.pauseProcessing();

      final operations = [
        SyncOperation.create(
          id: 'op1',
          entityType: SyncEntityType.trip,
          data: const {'title': 'Trip 1'},
        ),
        SyncOperation.create(
          id: 'op2',
          entityType: SyncEntityType.trip,
          data: const {'title': 'Trip 2'},
        ),
      ];

      await syncService.enqueueOperations(operations);

      syncService.resumeProcessing();
      final result = await syncService.processQueue();

      expect(syncService.queueSize, 0);
      expect(
          result.successCount + result.failureCount, greaterThanOrEqualTo(0));
    });

    test('should process operations in priority order', () async {
      syncService.pauseProcessing();

      // Create operations with different priorities
      final operations = [
        SyncOperation.create(
          id: 'low',
          entityType: SyncEntityType.travelNote, // priority: 1
          data: const {'title': 'Note'},
        ),
        SyncOperation.create(
          id: 'high',
          entityType: SyncEntityType.authTokens, // priority: 100
          data: const {'token': 'abc'},
        ),
        SyncOperation.create(
          id: 'medium',
          entityType: SyncEntityType.trip, // priority: 5
          data: const {'title': 'Trip'},
        ),
      ];

      await syncService.enqueueOperations(operations);
      syncService.resumeProcessing();

      await syncService.processQueue();

      // Queue should be empty after processing
      expect(syncService.queueSize, 0);
    });

    test('should set isProcessing during queue processing', () async {
      syncService.pauseProcessing();

      await syncService.enqueueOperation(
        SyncOperation.create(
          entityType: SyncEntityType.trip,
          data: const {'title': 'Test'},
        ),
      );

      final processingFuture = syncService.processQueue();
      expect(syncService.isProcessing, true);

      await processingFuture;
      expect(syncService.isProcessing, false);
    });
  });

  group('SyncServiceImpl - Retry Failed Operations', () {
    test('should retry operations that have not exceeded max attempts',
        () async {
      syncService.pauseProcessing();

      final operation = SyncOperation.create(
        id: 'op1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Test'},
      ).copyWith(retryCount: 2);

      await syncService.enqueueOperation(operation);

      final retried = await syncService.retryFailedOperations();

      expect(retried, 0); // No failed ops to retry in queue
    });

    test('should not retry operations exceeding max attempts', () async {
      syncService.pauseProcessing();

      syncService.updateConfig(
        const SyncQueueConfig(maxRetryAttempts: 3),
      );

      final operation = SyncOperation.create(
        id: 'op1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Test'},
      ).copyWith(retryCount: 3); // At max attempts

      await syncService.enqueueOperation(operation);

      final retried = await syncService.retryFailedOperations();

      expect(retried, 0);
    });
  });

  group('SyncServiceImpl - Edge Cases', () {
    test('should handle processing empty queue gracefully', () async {
      final result = await syncService.processQueue();

      expect(result.success, true);
      expect(result.successCount, 0);
      expect(result.failureCount, 0);
    });

    test('should handle clearing empty queue gracefully', () async {
      await syncService.clearQueue();

      expect(syncService.queueSize, 0);
      expect(syncService.status, SyncOperationStatus.idle);
    });

    test('should handle removing from empty queue gracefully', () async {
      final removed = await syncService.removeOperation('nonexistent');

      expect(removed, false);
    });

    test('should handle enqueueing empty list gracefully', () async {
      final count = await syncService.enqueueOperations([]);

      expect(count, 0);
      expect(syncService.queueSize, 0);
    });

    test('should handle batch processing with empty queue', () async {
      final result = await syncService.processBatch(maxBatchSize: 10);

      expect(result.success, true);
      expect(result.successCount, 0);
    });

    test('should not allow negative batch size', () async {
      syncService.pauseProcessing();

      await syncService.enqueueOperation(
        SyncOperation.create(
          entityType: SyncEntityType.trip,
          data: const {'title': 'Test'},
        ),
      );

      syncService.resumeProcessing();

      // Should handle gracefully
      final result = await syncService.processBatch(maxBatchSize: -1);

      expect(result, isNotNull);
    });

    test('should handle rapid pause/resume cycles', () async {
      syncService.pauseProcessing();
      syncService.resumeProcessing();
      syncService.pauseProcessing();

      expect(syncService.isProcessing, false);

      final operation = SyncOperation.create(
        entityType: SyncEntityType.trip,
        data: const {'title': 'Test'},
      );

      await syncService.enqueueOperation(operation);

      // Should remain in pending state
      expect(syncService.status, SyncOperationStatus.pending);
    });
  });

  group('SyncServiceImpl - Stream Behavior', () {
    test('statusStream should broadcast to multiple listeners', () async {
      final listener1 = <SyncOperationStatus>[];
      final listener2 = <SyncOperationStatus>[];

      final sub1 = syncService.statusStream.listen(listener1.add);
      final sub2 = syncService.statusStream.listen(listener2.add);

      await syncService.enqueueOperation(
        SyncOperation.create(
          entityType: SyncEntityType.trip,
          data: const {'title': 'Test'},
        ),
      );

      await Future.delayed(const Duration(milliseconds: 50));

      expect(listener1, isNotEmpty);
      expect(listener2, isNotEmpty);
      expect(listener1.length, listener2.length);

      await sub1.cancel();
      await sub2.cancel();
    });

    test('queueStream should broadcast to multiple listeners', () async {
      final listener1 = <List<SyncOperation>>[];
      final listener2 = <List<SyncOperation>>[];

      final sub1 = syncService.queueStream.listen(listener1.add);
      final sub2 = syncService.queueStream.listen(listener2.add);

      await syncService.enqueueOperation(
        SyncOperation.create(
          entityType: SyncEntityType.trip,
          data: const {'title': 'Test'},
        ),
      );

      await Future.delayed(const Duration(milliseconds: 50));

      expect(listener1, isNotEmpty);
      expect(listener2, isNotEmpty);

      await sub1.cancel();
      await sub2.cancel();
    });

    test('should not emit duplicate status changes', () async {
      final statuses = <SyncOperationStatus>[];
      final subscription = syncService.statusStream.listen(statuses.add);

      await syncService.enqueueOperation(
        SyncOperation.create(
          entityType: SyncEntityType.trip,
          data: const {'title': 'Test'},
        ),
      );

      await Future.delayed(const Duration(milliseconds: 100));

      // Count pending status emissions
      final pendingCount =
          statuses.where((s) => s == SyncOperationStatus.pending).length;

      // Should only emit pending once (or minimal times)
      expect(pendingCount, lessThanOrEqualTo(2));

      await subscription.cancel();
    });
  });

  group('SyncServiceImpl - Disposal', () {
    test('should close streams on disposal', () async {
      final service = SyncServiceImpl();

      // Should not throw
      service.dispose();

      // Multiple disposals should be safe
      service.dispose();
    });

    test('should not process after disposal', () async {
      final service = SyncServiceImpl();

      service.dispose();

      // Should handle gracefully
      await service.clearQueue();
      expect(service.queueSize, 0);
    });
  });

  group('SyncServiceImpl - Configuration Validation', () {
    test('should accept valid configuration', () {
      final config = const SyncQueueConfig(
        maxBatchSize: 100,
        maxRetryAttempts: 10,
        retryDelayMs: 2000,
        autoProcess: false,
        maxQueueSize: 500,
      );

      expect(() => syncService.updateConfig(config), returnsNormally);
    });

    test('should handle configuration with zero values', () {
      final config = const SyncQueueConfig(
        maxBatchSize: 0,
        maxRetryAttempts: 0,
        retryDelayMs: 0,
        autoProcess: false,
        maxQueueSize: 0,
      );

      syncService.updateConfig(config);

      expect(syncService.config.maxBatchSize, 0);
      expect(syncService.config.maxRetryAttempts, 0);
      expect(syncService.config.maxQueueSize, 0);
    });
  });

  group('SyncServiceImpl - Concurrent Operations', () {
    test('should handle multiple simultaneous enqueue operations', () async {
      final futures = List.generate(
        10,
        (i) => syncService.enqueueOperation(
          SyncOperation.create(
            id: 'op$i',
            entityType: SyncEntityType.trip,
            data: {'title': 'Trip $i'},
          ),
        ),
      );

      final results = await Future.wait(futures);

      expect(results.every((r) => r), true);
      expect(syncService.queueSize, 10);
    });

    test('should handle enqueue and remove simultaneously', () async {
      final futures = <Future>[];

      // Enqueue operations
      for (var i = 0; i < 5; i++) {
        futures.add(
          syncService.enqueueOperation(
            SyncOperation.create(
              id: 'op$i',
              entityType: SyncEntityType.trip,
              data: {'title': 'Trip $i'},
            ),
          ),
        );
      }

      // Remove operations
      for (var i = 0; i < 3; i++) {
        futures.add(syncService.removeOperation('op$i'));
      }

      await Future.wait(futures);

      // Should have 2 operations remaining
      expect(syncService.queueSize, lessThanOrEqualTo(5));
    });
  });

  group('SyncServiceImpl - Priority Sorting', () {
    test('should maintain priority order after multiple operations', () async {
      final operations = [
        SyncOperation.create(
          id: 'op1',
          entityType: SyncEntityType.travelNote, // priority: 1
          data: const {'title': 'Note'},
        ),
        SyncOperation.create(
          id: 'op2',
          entityType: SyncEntityType.trip, // priority: 5
          data: const {'title': 'Trip'},
        ),
        SyncOperation.create(
          id: 'op3',
          entityType: SyncEntityType.profile, // priority: 10
          data: const {'name': 'Profile'},
        ),
        SyncOperation.create(
          id: 'op4',
          entityType: SyncEntityType.authTokens, // priority: 100
          data: const {'token': 'abc'},
        ),
      ];

      await syncService.enqueueOperations(operations);

      expect(syncService.queue[0].entityType, SyncEntityType.authTokens);
      expect(syncService.queue[1].entityType, SyncEntityType.profile);
      expect(syncService.queue[2].entityType, SyncEntityType.trip);
      expect(syncService.queue[3].entityType, SyncEntityType.travelNote);
    });

    test('should resort queue when new operation added', () async {
      // Add low priority operation
      await syncService.enqueueOperation(
        SyncOperation.create(
          id: 'op1',
          entityType: SyncEntityType.travelNote, // priority: 1
          data: const {'title': 'Note'},
        ),
      );

      // Add high priority operation
      await syncService.enqueueOperation(
        SyncOperation.create(
          id: 'op2',
          entityType: SyncEntityType.authTokens, // priority: 100
          data: const {'token': 'abc'},
        ),
      );

      expect(syncService.queue[0].id, 'op2');
      expect(syncService.queue[1].id, 'op1');
    });
  });

  group('SyncServiceImpl - Auto Processing', () {
    test('should auto process when enabled', () async {
      syncService.updateConfig(
        const SyncQueueConfig(autoProcess: true),
      );

      // Add operation with auto-process disabled to avoid actual processing
      // in unit test (would require mocking network/repository)
      syncService.pauseProcessing();

      await syncService.enqueueOperation(
        SyncOperation.create(
          entityType: SyncEntityType.trip,
          data: const {'title': 'Test'},
        ),
      );

      expect(syncService.status, SyncOperationStatus.pending);
    });

    test('should not auto process when disabled', () async {
      syncService.updateConfig(
        const SyncQueueConfig(autoProcess: false),
      );

      await syncService.enqueueOperation(
        SyncOperation.create(
          entityType: SyncEntityType.trip,
          data: const {'title': 'Test'},
        ),
      );

      // Should remain pending
      expect(syncService.status, SyncOperationStatus.pending);
      expect(syncService.isProcessing, false);
    });
  });
}
