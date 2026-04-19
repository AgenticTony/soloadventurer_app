import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/domain/models/entity_version.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_operation.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_status.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/sync_service_impl.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/conflict_resolver_impl.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/conflict_detector_impl.dart';
import 'package:soloadventurer/features/sync/domain/services/conflict_detector.dart';
import 'package:soloadventurer/features/sync/domain/services/conflict_resolver.dart';
import 'package:soloadventurer/features/sync/domain/services/network_connectivity.dart';
import 'package:soloadventurer/features/sync/domain/services/sync_queue_persistence.dart';
import 'package:soloadventurer/features/sync/domain/services/sync_service.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_info.dart';
import 'package:soloadventurer/features/sync/domain/entities/sync_entity_type.dart';

/// Manual mock implementation of NetworkConnectivity for testing
class MockNetworkConnectivity implements NetworkConnectivity {
  final StreamController<bool> _onlineController =
      StreamController<bool>.broadcast();
  final StreamController<NetworkStatus> _statusController =
      StreamController<NetworkStatus>.broadcast();

  NetworkStatus _currentStatus = NetworkStatus.offline();

  void setOnline(bool isOnline) {
    _onlineController.add(isOnline);
  }

  void setStatus(NetworkStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  @override
  NetworkStatus get currentStatus => _currentStatus;

  @override
  bool get isOnline => _currentStatus.isOnline;

  @override
  NetworkConnectionType get connectionType =>
      _currentStatus.connectionType;

  @override
  Stream<bool> get onOnline => _onlineController.stream;

  @override
  Stream<bool> get onOffline =>
      _onlineController.stream.map((isOnline) => !isOnline);

  @override
  Stream<NetworkStatus> get statusStream => _statusController.stream;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> startMonitoring() async {}

  @override
  Future<void> stopMonitoring() async {}

  @override
  void dispose() {
    _onlineController.close();
    _statusController.close();
  }
}

/// Manual mock implementation of SyncQueuePersistence for testing
class MockSyncQueuePersistence implements SyncQueuePersistence {
  final List<SyncOperation> _storedQueue = [];
  bool _shouldFailOnLoad = false;
  bool _shouldFailOnSave = false;
  String _failureMessage = 'Mock failure';

  void setFailOnLoad(bool shouldFail, {String message = 'Mock failure'}) {
    _shouldFailOnLoad = shouldFail;
    _failureMessage = message;
  }

  void setFailOnSave(bool shouldFail, {String message = 'Mock failure'}) {
    _shouldFailOnSave = shouldFail;
    _failureMessage = message;
  }

  @override
  Future<SyncQueuePersistenceResult> saveQueue(
      List<SyncOperation> queue) async {
    if (_shouldFailOnSave) {
      return SyncQueuePersistenceResult.failure(_failureMessage);
    }
    _storedQueue.clear();
    _storedQueue.addAll(queue);
    return SyncQueuePersistenceResult.success(operationCount: queue.length);
  }

  @override
  Future<List<SyncOperation>> loadQueue() async {
    if (_shouldFailOnLoad) {
      throw Exception(_failureMessage);
    }
    return List.from(_storedQueue);
  }

  @override
  Future<SyncQueuePersistenceResult> clearQueue() async {
    _storedQueue.clear();
    return SyncQueuePersistenceResult.success();
  }

  @override
  Future<bool> removeOperation(String operationId) async {
    final initialLength = _storedQueue.length;
    _storedQueue.removeWhere((op) => op.id == operationId);
    return _storedQueue.length < initialLength;
  }

  @override
  Future<bool> hasPersistedOperations() async {
    return _storedQueue.isNotEmpty;
  }

  @override
  Future<int> getOperationCount() async {
    return _storedQueue.length;
  }

  List<SyncOperation> get storedQueue => List.unmodifiable(_storedQueue);
}

void main() {
  late MockNetworkConnectivity mockNetworkConnectivity;
  late MockSyncQueuePersistence mockPersistence;
  late ConflictDetectorImpl conflictDetector;
  late ConflictResolverImpl conflictResolver;
  late SyncServiceImpl syncService;

  setUp(() {
    mockNetworkConnectivity = MockNetworkConnectivity();
    mockPersistence = MockSyncQueuePersistence();

    conflictDetector = ConflictDetectorImpl(
      config: ConflictDetectionConfig(
        deviceId: 'test-device',
        timestampThresholdMs: 1000,
      ),
    );

    conflictResolver = ConflictResolverImpl(
      config: ConflictResolutionConfig(
        deviceId: 'test-device',
        preferLocalOnEqualTimestamps: false,
      ),
    );

    syncService = SyncServiceImpl(
      persistence: mockPersistence,
      networkConnectivity: mockNetworkConnectivity,
    );
  });

  tearDown(() async {
    mockNetworkConnectivity.dispose();
    syncService.dispose();
    conflictDetector.dispose();
    conflictResolver.dispose();
  });

  /// Helper to create a SyncOperation for testing
  SyncOperation makeOp({
    required String id,
    String? entityId,
    SyncEntityType entityType = SyncEntityType.trip,
    SyncOperationType operationType = SyncOperationType.create,
    Map<String, dynamic>? data,
    int? version,
    int? priority,
  }) {
    return SyncOperation(
      id: id,
      entityId: entityId ?? id,
      entityType: entityType,
      operationType: operationType,
      data: data ?? const {},
      createdAt: DateTime.now().toUtc(),
      version: version,
      priority: priority ?? SyncEntityType.trip.syncPriority,
    );
  }

  group('Edge Case - Stale Data Rejection Tests', () {
    test('should reject stale local data when remote version is newer',
        () async {
      final baseTime = DateTime.now().toUtc();
      final staleLocalVersion = EntityVersion(
        entityId: 'trip-123',
        entityType: 'trip',
        version: 1,
        lastModified: baseTime.subtract(const Duration(milliseconds: 500)),
        deviceId: 'test-device',
        dataHash: 'old-hash',
      );

      final newerRemoteVersion = EntityVersion(
        entityId: 'trip-123',
        entityType: 'trip',
        version: 3,
        lastModified: baseTime,
        deviceId: 'remote-device',
        dataHash: 'new-hash',
      );

      final staleLocalData = {'title': 'Old Title', 'days': 3};
      final newerRemoteData = {'title': 'New Title', 'days': 5};

      final conflict = await conflictDetector.detectConflict(
        localVersion: staleLocalVersion,
        remoteVersion: newerRemoteVersion,
        localData: staleLocalData,
        remoteData: newerRemoteData,
      );

      expect(conflict, isNotNull);
      expect(conflict!.conflictType, ConflictType.diverged);
      expect(conflict.severity, ConflictSeverity.high);
    });

    test('should reject stale remote data when local version is newer',
        () async {
      final baseTime = DateTime.now().toUtc();
      final newerLocalVersion = EntityVersion(
        entityId: 'trip-456',
        entityType: 'trip',
        version: 5,
        lastModified: baseTime,
        deviceId: 'test-device',
        dataHash: 'new-hash',
      );

      final staleRemoteVersion = EntityVersion(
        entityId: 'trip-456',
        entityType: 'trip',
        version: 2,
        lastModified: baseTime.subtract(const Duration(milliseconds: 500)),
        deviceId: 'remote-device',
        dataHash: 'old-hash',
      );

      final newerLocalData = {'title': 'Updated Title', 'days': 7};
      final staleRemoteData = {'title': 'Old Title', 'days': 3};

      final conflict = await conflictDetector.detectConflict(
        localVersion: newerLocalVersion,
        remoteVersion: staleRemoteVersion,
        localData: newerLocalData,
        remoteData: staleRemoteData,
      );

      expect(conflict, isNotNull);
      expect(conflict!.conflictType, ConflictType.diverged);
      expect(conflict.severity, ConflictSeverity.high);
    });

    test('should handle multiple operations in queue', () async {
      final baseTime = DateTime.now().toUtc();
      final ops = [
        makeOp(id: 'trip-1', data: const {'title': 'Op 1'}, version: 1),
        makeOp(id: 'trip-2', data: const {'title': 'Op 2'}, version: 1),
        makeOp(id: 'trip-3', data: const {'title': 'Op 3'}, version: 1),
      ];

      for (final op in ops) {
        await syncService.enqueueOperation(op);
      }

      expect(syncService.queueSize, 3);
      expect(syncService.queue[0].id, isNotNull);
      expect(syncService.queue[1].id, isNotNull);
      expect(syncService.queue[2].id, isNotNull);
    });

    test('should detect version number conflict', () async {
      final baseTime = DateTime.now().toUtc();
      final localVersion = EntityVersion(
        entityId: 'trip-789',
        entityType: 'trip',
        version: 2,
        lastModified: baseTime,
        deviceId: 'test-device',
        dataHash: 'hash-1',
      );

      final remoteVersion = EntityVersion(
        entityId: 'trip-789',
        entityType: 'trip',
        version: 5,
        lastModified: baseTime.subtract(const Duration(milliseconds: 200)),
        deviceId: 'remote-device',
        dataHash: 'hash-2',
      );

      final conflict = await conflictDetector.detectConflict(
        localVersion: localVersion,
        remoteVersion: remoteVersion,
        localData: {'title': 'Local'},
        remoteData: {'title': 'Remote'},
      );

      expect(conflict, isNotNull);
      expect(conflict!.conflictType, ConflictType.diverged);
      expect(conflict.severity, ConflictSeverity.high);
    });
  });

  group('Edge Case - Queue Recovery Tests', () {
    test('should restore persisted queue on construction', () async {
      final op1 = makeOp(id: 'op-1', entityId: 'trip-1');
      final op2 = makeOp(id: 'op-2', entityId: 'trip-2');

      await mockPersistence.saveQueue([op1, op2]);

      final freshService = SyncServiceImpl(
        persistence: mockPersistence,
        networkConnectivity: mockNetworkConnectivity,
      );

      // Allow async initialization
      await Future.delayed(const Duration(milliseconds: 100));

      expect(freshService.queueSize, 2);
      expect(freshService.queue[0].id, 'op-1');
      expect(freshService.queue[1].id, 'op-2');

      freshService.dispose();
    });

    test('should restore retry count from persisted operations', () async {
      final op = SyncOperation(
        id: 'op-2',
        entityId: 'trip-2',
        entityType: SyncEntityType.trip,
        operationType: SyncOperationType.create,
        data: const {'title': 'Trip 2'},
        createdAt: DateTime.now().toUtc(),
        version: 1,
        retryCount: 2,
        nextRetryAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
      );

      await mockPersistence.saveQueue([op]);

      final freshService = SyncServiceImpl(
        persistence: mockPersistence,
        networkConnectivity: mockNetworkConnectivity,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      expect(freshService.queueSize, 1);
      expect(freshService.queue[0].retryCount, 2);

      freshService.dispose();
    });

    test('should handle corrupted queue data during load gracefully', () async {
      mockPersistence.setFailOnLoad(true, message: 'Invalid JSON format');

      final freshService = SyncServiceImpl(
        persistence: mockPersistence,
        networkConnectivity: mockNetworkConnectivity,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      expect(freshService.queueSize, 0);
      expect(freshService.status, SyncOperationStatus.idle);

      freshService.dispose();
    });

    test('should handle operation with complex data structure', () async {
      final op = makeOp(
        id: 'trip-complex',
        data: {
          'title': null,
          'days': 'invalid',
          'nested': {
            'invalid': [null, 'data']
          },
        },
      );

      final result = await syncService.enqueueOperation(op);

      expect(result, true);
      expect(syncService.queueSize, 1);
      expect(syncService.queue[0].id, 'trip-complex');
    });

    test('should handle corrupted version data gracefully', () async {
      final baseTime = DateTime.now().toUtc();
      final localVersion = EntityVersion(
        entityId: 'trip-corrupt',
        entityType: 'trip',
        version: 1,
        lastModified: baseTime,
        deviceId: 'test-device',
        dataHash: 'valid-hash',
      );

      final remoteVersion = EntityVersion(
        entityId: 'trip-corrupt',
        entityType: 'trip',
        version: 1,
        lastModified: baseTime,
        deviceId: 'remote-device',
        dataHash: '',
      );

      final conflict = await conflictDetector.detectConflict(
        localVersion: localVersion,
        remoteVersion: remoteVersion,
        localData: {'title': 'Valid'},
        remoteData: {'invalid': 'data'},
      );

      expect(conflict, isNotNull);
    });

    test('should recover from persistence save failure', () async {
      final op = makeOp(id: 'trip-1');
      mockPersistence.setFailOnSave(true, message: 'Storage error');

      // Should not throw
      await syncService.enqueueOperation(op);
      expect(syncService.queueSize, 1);

      mockPersistence.setFailOnSave(false);
    });

    test('should handle batch enqueue', () async {
      final ops = [
        makeOp(id: 'trip-1', data: const {'title': 'Valid 1'}),
        makeOp(id: 'trip-2', data: const {'title': 'Valid 2'}),
        makeOp(id: 'trip-3', data: const {}),
      ];

      final added = await syncService.enqueueOperations(ops);

      expect(added, 3);
      expect(syncService.queueSize, 3);
    });
  });

  group('Edge Case - Large Batch Performance Tests', () {
    test('should handle large batch of operations efficiently', () async {
      final largeBatch = List.generate(
        1000,
        (i) => makeOp(
          id: 'trip-$i',
          data: {
            'title': 'Trip $i',
            'description': 'Description for trip $i',
            'days': i % 10 + 1,
          },
          version: 1,
        ),
      );

      final stopwatch = Stopwatch()..start();

      for (final op in largeBatch) {
        await syncService.enqueueOperation(op);
      }

      stopwatch.stop();

      expect(syncService.queueSize, 1000);
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('should process large batch with reasonable performance', () async {
      syncService.updateConfig(const SyncQueueConfig(
        maxBatchSize: 200,
        maxQueueSize: 500,
      ));
      syncService.pauseProcessing();

      final ops = List.generate(
        200,
        (i) => makeOp(
          id: 'trip-$i',
          data: {'title': 'Trip $i'},
          version: 1,
        ),
      );

      for (final op in ops) {
        await syncService.enqueueOperation(op);
      }

      syncService.resumeProcessing();
      final stopwatch = Stopwatch()..start();

      final result = await syncService.processBatch();

      stopwatch.stop();

      expect(result.success, true);
      expect(result.successCount, 200);
      expect(syncService.queueSize, 0);
      expect(stopwatch.elapsedMilliseconds, lessThan(30000));
    });

    test('should handle memory efficiently with large queue', () async {
      syncService.updateConfig(const SyncQueueConfig(
        maxQueueSize: 5000,
      ));
      syncService.pauseProcessing();

      final ops = List.generate(
        2000,
        (i) => makeOp(
          id: 'trip-$i',
          data: {
            'title': 'Trip $i' * 10,
            'nested': {'data': i.toString() * 5},
          },
          version: 1,
        ),
      );

      for (final op in ops) {
        await syncService.enqueueOperation(op);
      }

      expect(syncService.queueSize, 2000);
      expect(syncService.queue, isNotEmpty);
      expect(syncService.queue.last.id, isNotNull);
    });

    test('should maintain performance with frequent queue operations',
        () async {
      syncService.pauseProcessing();
      final stopwatch = Stopwatch()..start();
      var operationCount = 0;

      for (var i = 0; i < 10; i++) {
        for (var j = 0; j < 10; j++) {
          final op = makeOp(
            id: 'trip-$i-$j',
            data: {'title': 'Trip $i-$j'},
            version: 1,
          );
          await syncService.enqueueOperation(op);
          operationCount++;
        }

        syncService.resumeProcessing();
        await syncService.processBatch();
        syncService.pauseProcessing();
      }

      stopwatch.stop();

      expect(operationCount, 100);
      expect(syncService.queueSize, 0);
      expect(stopwatch.elapsedMilliseconds, lessThan(60000));
    });

    test('should handle large batch with mixed operation types', () async {
      syncService.updateConfig(const SyncQueueConfig(
        maxBatchSize: 200,
        maxQueueSize: 500,
      ));
      syncService.pauseProcessing();
      final mixedOps = <SyncOperation>[];

      for (var i = 0; i < 150; i++) {
        final opType = i % 3;
        final op = opType == 0
            ? makeOp(
                id: 'create-$i',
                entityId: 'trip-$i',
                operationType: SyncOperationType.create,
                data: {'title': 'Trip $i'},
                version: 1,
              )
            : opType == 1
                ? makeOp(
                    id: 'update-$i',
                    entityId: 'trip-$i',
                    operationType: SyncOperationType.update,
                    data: {'title': 'Updated $i'},
                    version: 2,
                  )
                : makeOp(
                    id: 'delete-$i',
                    entityId: 'trip-$i',
                    operationType: SyncOperationType.delete,
                    version: 2,
                  );
        mixedOps.add(op);
      }

      for (final op in mixedOps) {
        await syncService.enqueueOperation(op);
      }

      syncService.resumeProcessing();
      final result = await syncService.processBatch();

      expect(result.success, true);
      expect(result.successCount, 150);
      expect(syncService.queueSize, 0);
    });

    test('should handle priority sorting in large batch', () async {
      for (var i = 0; i < 100; i++) {
        final op = makeOp(
          id: 'trip-$i',
          entityType: i % 2 == 0
              ? SyncEntityType.authTokens
              : SyncEntityType.trip,
        );
        await syncService.enqueueOperation(op);
      }

      // Auth tokens should come first (higher priority)
      expect(syncService.queue[0].entityType, SyncEntityType.authTokens);
    });

    test('should sort by priority when enqueuing', () async {
      final tripOp = makeOp(
        id: 'trip-op',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Trip'},
        priority: SyncEntityType.trip.syncPriority,
      );
      final authOp = makeOp(
        id: 'auth-op',
        entityType: SyncEntityType.authTokens,
        data: const {'token': 'abc'},
        priority: SyncEntityType.authTokens.syncPriority,
      );

      await syncService.enqueueOperation(tripOp);
      await syncService.enqueueOperation(authOp);

      // Auth tokens should come first (higher priority)
      expect(syncService.queue[0].entityType, SyncEntityType.authTokens);
    });
  });

  group('Edge Case - Concurrent Operations Tests', () {
    test('should handle concurrent enqueue operations', () async {
      final futures = List.generate(
        50,
        (i) => syncService.enqueueOperation(
          makeOp(
            id: 'trip-$i',
            data: {'title': 'Trip $i'},
            version: 1,
          ),
        ),
      );

      await Future.wait(futures);

      expect(syncService.queueSize, 50);
    });

    test('should handle pause/resume during processing', () async {
      final ops = List.generate(
        100,
        (i) => makeOp(
          id: 'trip-$i',
          data: {'title': 'Trip $i'},
          version: 1,
        ),
      );

      for (final op in ops) {
        await syncService.enqueueOperation(op);
      }

      // Pause and resume
      syncService.pauseProcessing();
      syncService.resumeProcessing();

      // Process remaining
      final result = await syncService.processQueue();

      expect(result.successCount, greaterThan(0));
    });

    test('should handle clear queue during processing', () async {
      final ops = List.generate(
        50,
        (i) => makeOp(
          id: 'trip-$i',
          data: {'title': 'Trip $i'},
          version: 1,
        ),
      );

      for (final op in ops) {
        await syncService.enqueueOperation(op);
      }

      // Clear queue
      await syncService.clearQueue();

      expect(syncService.queueSize, 0);
    });
  });

  group('Edge Case - Resource Management Tests', () {
    test('should dispose resources properly', () async {
      final op = makeOp(id: 'trip-1');
      await syncService.enqueueOperation(op);

      syncService.dispose();

      // Queue should still be accessible
      expect(() => syncService.queue, returnsNormally);
    });

    test('should handle rapid status transitions', () async {
      final statusTransitions = <SyncOperationStatus>[];
      final subscription =
          syncService.statusStream.listen(statusTransitions.add);

      await syncService.enqueueOperation(
        makeOp(id: 'trip-1'),
      );

      // Allow stream events to propagate
      await Future.delayed(const Duration(milliseconds: 50));

      syncService.pauseProcessing();
      syncService.resumeProcessing();
      syncService.pauseProcessing();
      syncService.resumeProcessing();

      await subscription.cancel();

      expect(statusTransitions, isNotEmpty);
    });

    test('should handle configuration changes during operation', () async {
      final ops = List.generate(
        10,
        (i) => makeOp(
          id: 'trip-$i',
          data: {'title': 'Trip $i'},
          version: 1,
        ),
      );

      for (final op in ops) {
        await syncService.enqueueOperation(op);
      }

      syncService.updateConfig(
        const SyncQueueConfig(
          maxRetryAttempts: 10,
          maxBatchSize: 25,
          retryDelayMs: 100,
        ),
      );

      final result = await syncService.processQueue();

      expect(syncService.config.maxRetryAttempts, 10);
      expect(syncService.config.maxBatchSize, 25);
      expect(result.success, true);
    });

    test('should report queue size correctly', () async {
      expect(syncService.queueSize, 0);

      await syncService.enqueueOperation(makeOp(id: 'trip-1'));
      expect(syncService.queueSize, 1);

      await syncService.enqueueOperation(makeOp(id: 'trip-2'));
      expect(syncService.queueSize, 2);

      await syncService.clearQueue();
      expect(syncService.queueSize, 0);
    });

    test('should filter operations by entity type', () async {
      final tripOp = makeOp(
        id: 'trip-op',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Trip'},
      );
      final noteOp = makeOp(
        id: 'note-op',
        entityType: SyncEntityType.travelNote,
        data: const {'note': 'Note'},
      );

      await syncService.enqueueOperation(tripOp);
      await syncService.enqueueOperation(noteOp);

      final tripOps = syncService.getOperationsByType(SyncEntityType.trip);
      final noteOps =
          syncService.getOperationsByType(SyncEntityType.travelNote);

      expect(tripOps.length, 1);
      expect(noteOps.length, 1);
      expect(tripOps[0].id, 'trip-op');
      expect(noteOps[0].id, 'note-op');
    });
  });
}
