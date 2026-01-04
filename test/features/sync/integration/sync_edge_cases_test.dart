import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/domain/models/entity_version.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_operation.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_status.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_error.dart';
import 'package:soloadventurer/features/sync/domain/entities/sync_entity_type.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/sync_service_impl.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/conflict_detector_impl.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/conflict_resolver_impl.dart';
import 'package:soloadventurer/features/sync/domain/services/network_connectivity.dart';
import 'package:soloadventurer/features/sync/domain/services/sync_queue_persistence.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_queue_config.dart';
import 'package:soloadventurer/features/sync/domain/models/network_status.dart';

/// Manual mock implementation of NetworkConnectivity for testing
class MockNetworkConnectivity implements NetworkConnectivity {
  final StreamController<bool> _onlineController = StreamController<bool>.broadcast();
  final StreamController<NetworkStatus> _statusController = StreamController<NetworkStatus>.broadcast();

  NetworkStatus? _currentStatus;

  void setOnline(bool isOnline) {
    _onlineController.add(isOnline);
  }

  void setStatus(NetworkStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  @override
  Stream<bool> get onOnline => _onlineController.stream;

  @override
  Stream<bool> get onOffline => _onlineController.stream.map((isOnline) => !isOnline);

  @override
  Stream<NetworkStatus> get onStatusChange => _statusController.stream;

  @override
  Future<NetworkStatus?> get currentStatus async => _currentStatus;

  @override
  Future<bool> get isConnected async => _currentStatus?.isConnected ?? false;

  @override
  Stream<NetworkStatus> get statusStream => _statusController.stream;

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
  Future<SyncQueuePersistenceResult> saveQueue(List<SyncOperation> queue) async {
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
    _storedQueue.removeWhere((op) => op.operationId == operationId);
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

/// Mock backend server for testing edge case scenarios
class EdgeCaseBackendServer {
  final Map<String, EntityVersion> _remoteVersions = {};
  final Map<String, Map<String, dynamic>> _remoteData = {};
  final Map<String, int> _requestCounts = {};

  EntityVersion? getRemoteVersion(String entityId) => _remoteVersions[entityId];
  Map<String, dynamic>? getRemoteData(String entityId) => _remoteData[entityId];
  int getRequestCount(String entityId) => _requestCounts[entityId] ?? 0;

  void updateRemoteData(String entityId, EntityVersion version, Map<String, dynamic> data) {
    _remoteVersions[entityId] = version;
    _remoteData[entityId] = data;
    _requestCounts[entityId] = (_requestCounts[entityId] ?? 0) + 1;
  }

  void clear() {
    _remoteVersions.clear();
    _remoteData.clear();
    _requestCounts.clear();
  }
}

void main() {
  late EdgeCaseBackendServer mockBackend;
  late MockNetworkConnectivity mockNetworkConnectivity;
  late MockSyncQueuePersistence mockPersistence;
  late ConflictDetectorImpl conflictDetector;
  late ConflictResolverImpl conflictResolver;
  late SyncServiceImpl syncService;

  setUp(() {
    mockBackend = EdgeCaseBackendServer();
    mockNetworkConnectivity = MockNetworkConnectivity();
    mockPersistence = MockSyncQueuePersistence();

    // Create conflict detector with test configuration
    conflictDetector = ConflictDetectorImpl(
      config: ConflictDetectionConfig(
        deviceId: 'test-device',
        concurrentThresholdMs: 1000,
      ),
    );

    // Create conflict resolver with test configuration
    conflictResolver = ConflictResolverImpl(
      config: ConflictResolutionConfig(
        deviceId: 'test-device',
        preferLocalOnEqualTimestamps: false,
      ),
    );

    // Create sync service
    syncService = SyncServiceImpl(
      persistence: mockPersistence,
      networkConnectivity: mockNetworkConnectivity,
    );
  });

  tearDown(() async {
    mockNetworkConnectivity.dispose();
    await syncService.dispose();
    mockBackend.clear();
  });

  group('Edge Case - Stale Data Rejection Tests', () {
    test('should reject stale local data when remote version is newer', () async {
      // Arrange
      final baseTime = DateTime.now().toUtc();
      final staleLocalVersion = EntityVersion(
        entityId: 'trip-123',
        entityType: 'trip',
        version: 1,
        lastModified: baseTime.subtract(const Duration(hours: 2)),
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

      // Act
      final conflict = await conflictDetector.detectConflict(
        localVersion: staleLocalVersion,
        remoteVersion: newerRemoteVersion,
        localData: staleLocalData,
        remoteData: newerRemoteData,
      );

      // Assert
      expect(conflict, isNotNull);
      expect(conflict!.conflictType, ConflictType.remoteNewer);
      expect(conflict.severity, ConflictSeverity.low);
      expect(conflict.shouldAutoResolve, isTrue);
    });

    test('should reject stale remote data when local version is newer', () async {
      // Arrange
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
        lastModified: baseTime.subtract(const Duration(hours: 1)),
        deviceId: 'remote-device',
        dataHash: 'old-hash',
      );

      final newerLocalData = {'title': 'Updated Title', 'days': 7};
      final staleRemoteData = {'title': 'Old Title', 'days': 3};

      // Act
      final conflict = await conflictDetector.detectConflict(
        localVersion: newerLocalVersion,
        remoteVersion: staleRemoteVersion,
        localData: newerLocalData,
        remoteData: staleRemoteData,
      );

      // Assert
      expect(conflict, isNotNull);
      expect(conflict!.conflictType, ConflictType.localNewer);
      expect(conflict.severity, ConflictSeverity.low);
      expect(conflict.shouldAutoResolve, isTrue);
    });

    test('should handle multiple stale operations in queue', () async {
      // Arrange
      final baseTime = DateTime.now().toUtc();
      final staleOp1 = SyncOperation.create(
        entityId: 'trip-1',
        entityType: SyncEntityType.trip,
        data: {'title': 'Old 1'},
        version: 1,
        lastModified: baseTime.subtract(const Duration(days: 3)),
      );
      final staleOp2 = SyncOperation.create(
        entityId: 'trip-2',
        entityType: SyncEntityType.trip,
        data: {'title': 'Old 2'},
        version: 1,
        lastModified: baseTime.subtract(const Duration(days: 2)),
      );
      final staleOp3 = SyncOperation.create(
        entityId: 'trip-3',
        entityType: SyncEntityType.trip,
        data: {'title': 'Old 3'},
        version: 1,
        lastModified: baseTime.subtract(const Duration(days: 1)),
      );

      // Manually store the operations in the mock persistence
      for (final op in [staleOp1, staleOp2, staleOp3]) {
        await mockPersistence.saveQueue([op]);
      }

      // Create a fresh service that will load the persisted queue
      final freshSyncService = SyncServiceImpl(
        persistence: mockPersistence,
        networkConnectivity: mockNetworkConnectivity,
      );

      // Act
      await freshSyncService.initialize();
      final loadedQueue = freshSyncService.queue;

      // Assert
      expect(loadedQueue.length, 3);
      expect(loadedQueue[0].entityId, 'trip-1');
      expect(loadedQueue[1].entityId, 'trip-2');
      expect(loadedQueue[2].entityId, 'trip-3');

      await freshSyncService.dispose();
    });

    test('should reject operation with stale version number', () async {
      // Arrange
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
        lastModified: baseTime.subtract(const Duration(minutes: 5)),
        deviceId: 'remote-device',
        dataHash: 'hash-2',
      );

      // Act
      final conflict = await conflictDetector.detectConflict(
        localVersion: localVersion,
        remoteVersion: remoteVersion,
        localData: {'title': 'Local'},
        remoteData: {'title': 'Remote'},
      );

      // Assert
      expect(conflict, isNotNull);
      expect(conflict!.conflictType, ConflictType.versionConflict);
      expect(conflict.severity, ConflictSeverity.medium);
    });
  });

  group('Edge Case - Partial Sync Recovery Tests', () {
    test('should recover from partial sync when only some operations succeed', () async {
      // Arrange
      final baseTime = DateTime.now().toUtc();
      final op1 = SyncOperation.create(
        entityId: 'trip-1',
        entityType: SyncEntityType.trip,
        data: {'title': 'Trip 1'},
        version: 1,
        lastModified: baseTime,
      );
      final op2 = SyncOperation.create(
        entityId: 'trip-2',
        entityType: SyncEntityType.trip,
        data: {'title': 'Trip 2'},
        version: 1,
        lastModified: baseTime,
      );
      final op3 = SyncOperation.create(
        entityId: 'trip-3',
        entityType: SyncEntityType.trip,
        data: {'title': 'Trip 3'},
        version: 1,
        lastModified: baseTime,
      );

      await syncService.enqueue(op1);
      await syncService.enqueue(op2);
      await syncService.enqueue(op3);

      // Simulate partial failure: op2 fails
      final processedOps = <SyncOperation>[];
      final remainingOps = <SyncOperation>[];

      // Act - Process queue with simulated partial failure
      await syncService.processQueue((op) async {
        processedOps.add(op);
        if (op.entityId == 'trip-2') {
          throw Exception('Simulated network error for trip-2');
        }
        return SyncErrorResult.success();
      });

      // Get remaining queue
      remainingOps.addAll(syncService.queue);

      // Assert
      expect(processedOps.length, greaterThan(0));
      expect(remainingOps.length, greaterThan(0));
      expect(mockPersistence.storedQueue.length, greaterThan(0));
    });

    test('should resume partial sync after app restart', () async {
      // Arrange
      final baseTime = DateTime.now().toUtc();
      final op1 = SyncOperation.create(
        entityId: 'trip-1',
        entityType: SyncEntityType.trip,
        data: {'title': 'Trip 1'},
        version: 1,
        lastModified: baseTime,
      );
      final op2 = SyncOperation(
        operationId: 'op-2',
        entityId: 'trip-2',
        entityType: SyncEntityType.trip,
        operationType: SyncOperationType.create,
        data: {'title': 'Trip 2'},
        version: 1,
        lastModified: baseTime,
        retryCount: 2,
        nextRetryAt: baseTime.add(const Duration(minutes: 5)),
      );

      // Save operations to mock persistence
      await mockPersistence.saveQueue([op1, op2]);

      // Create a fresh service that will load the persisted queue
      final freshSyncService = SyncServiceImpl(
        persistence: mockPersistence,
        networkConnectivity: mockNetworkConnectivity,
      );

      // Act
      await freshSyncService.initialize();

      // Assert
      expect(freshSyncService.queueSize, 2);
      expect(freshSyncService.queue[0].entityId, 'trip-1');
      expect(freshSyncService.queue[1].entityId, 'trip-2');
      expect(freshSyncService.queue[1].retryCount, 2);

      await freshSyncService.dispose();
    });

    test('should handle partial sync with batch operations', () async {
      // Arrange
      final baseTime = DateTime.now().toUtc();
      final ops = List.generate(
        100,
        (i) => SyncOperation.create(
          entityId: 'trip-$i',
          entityType: SyncEntityType.trip,
          data: {'title': 'Trip $i'},
          version: 1,
          lastModified: baseTime,
        ),
      );

      for (final op in ops) {
        await syncService.enqueue(op);
      }

      int processedCount = 0;
      final failedEntities = <String>[];

      // Act - Process with some failures
      await syncService.processBatch((op) async {
        processedCount++;
        if (processedCount % 10 == 0) {
          failedEntities.add(op.entityId);
          throw Exception('Simulated failure for ${op.entityId}');
        }
        return SyncErrorResult.success();
      });

      // Assert
      expect(processedCount, greaterThan(0));
      expect(failedEntities.length, greaterThan(0));
      expect(syncService.queueSize, greaterThan(0));
    });

    test('should track partial sync progress correctly', () async {
      // Arrange
      final baseTime = DateTime.now().toUtc();
      final ops = List.generate(
        20,
        (i) => SyncOperation.create(
          entityId: 'trip-$i',
          entityType: SyncEntityType.trip,
          data: {'title': 'Trip $i'},
          version: 1,
          lastModified: baseTime,
        ),
      );

      for (final op in ops) {
        await syncService.enqueue(op);
      }

      final progressUpdates = <int>[];
      final subscription = syncService.queueStream.listen((queue) {
        progressUpdates.add(queue.length);
      });

      // Act
      await syncService.processQueue((op) async {
        if (op.entityId == 'trip-5' || op.entityId == 'trip-15') {
          throw Exception('Simulated failure');
        }
        return SyncErrorResult.success();
      });

      await subscription.cancel();

      // Assert
      expect(progressUpdates, isNotEmpty);
      expect(progressUpdates.last, lessThan(20)); // Some operations should fail
      expect(syncService.queueSize, greaterThan(0)); // Failed ops remain in queue
    });
  });

  group('Edge Case - Corrupted Data Handling Tests', () {
    test('should handle corrupted queue data during load', () async {
      // Arrange - Create a fresh service with failing persistence
      mockPersistence.setFailOnLoad(true, message: 'Invalid JSON format');

      final freshSyncService = SyncServiceImpl(
        persistence: mockPersistence,
        networkConnectivity: mockNetworkConnectivity,
      );

      // Act
      await freshSyncService.initialize();

      // Assert
      expect(freshSyncService.queueSize, 0);
      expect(freshSyncService.status, SyncStatus.idle);

      await freshSyncService.dispose();
    });

    test('should handle operation with invalid data structure', () async {
      // Arrange
      final baseTime = DateTime.now().toUtc();
      final corruptedOp = SyncOperation.create(
        entityId: 'trip-corrupted',
        entityType: SyncEntityType.trip,
        data: {
          'title': null,
          'days': 'invalid',
          'nested': {'invalid': [null, 'data']},
        },
        version: 1,
        lastModified: baseTime,
      );

      await syncService.enqueue(corruptedOp);

      // Act & Assert - Should enqueue without throwing
      expect(syncService.queueSize, 1);
      expect(syncService.queue[0].entityId, 'trip-corrupted');
    });

    test('should handle corrupted version data gracefully', () async {
      // Arrange
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
        dataHash: '', // Empty hash (corrupted)
      );

      // Act
      final conflict = await conflictDetector.detectConflict(
        localVersion: localVersion,
        remoteVersion: remoteVersion,
        localData: {'title': 'Valid'},
        remoteData: {'invalid': 'data'},
      );

      // Assert
      expect(conflict, isNotNull);
      expect(conflict!.conflictType, ConflictType.diverged);
    });

    test('should recover from persistence save failure', () async {
      // Arrange
      final baseTime = DateTime.now().toUtc();
      final op = SyncOperation.create(
        entityId: 'trip-1',
        entityType: SyncEntityType.trip,
        data: {'title': 'Trip 1'},
        version: 1,
        lastModified: baseTime,
      );

      mockPersistence.setFailOnSave(true, message: 'Storage error');

      // Act & Assert - Should not throw
      await expectLater(() async => await syncService.enqueue(op), returnsNormally);
      expect(syncService.queueSize, 1);

      // Reset for other tests
      mockPersistence.setFailOnSave(false);
    });

    test('should handle partially corrupted batch operations', () async {
      // Arrange
      final baseTime = DateTime.now().toUtc();
      final validOps = [
        SyncOperation.create(
          entityId: 'trip-1',
          entityType: SyncEntityType.trip,
          data: {'title': 'Valid 1'},
          version: 1,
          lastModified: baseTime,
        ),
        SyncOperation.create(
          entityId: 'trip-2',
          entityType: SyncEntityType.trip,
          data: {'title': 'Valid 2'},
          version: 1,
          lastModified: baseTime,
        ),
      ];

      final corruptedOps = [
        SyncOperation.create(
          entityId: '',
          entityType: SyncEntityType.trip,
          data: <String, dynamic>{},
          version: -1,
          lastModified: baseTime,
        ),
      ];

      // Act & Assert - Should handle gracefully
      for (final op in [...validOps, ...corruptedOps]) {
        await expectLater(() async => await syncService.enqueue(op), returnsNormally);
      }

      expect(syncService.queueSize, 3);
    });
  });

  group('Edge Case - Large Batch Performance Tests', () {
    test('should handle large batch of operations efficiently', () async {
      // Arrange - Create large batch
      final baseTime = DateTime.now().toUtc();
      final largeBatch = List.generate(
        1000,
        (i) => SyncOperation.create(
          entityId: 'trip-$i',
          entityType: SyncEntityType.trip,
          data: {
            'title': 'Trip $i',
            'description': 'Description for trip $i',
            'days': i % 10 + 1,
          },
          version: 1,
          lastModified: baseTime.add(Duration(milliseconds: i)),
        ),
      );

      final stopwatch = Stopwatch()..start();

      // Act
      for (final op in largeBatch) {
        await syncService.enqueue(op);
      }

      stopwatch.stop();

      // Assert
      expect(syncService.queueSize, 1000);
      expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // Should complete in < 5 seconds
    });

    test('should process large batch with reasonable performance', () async {
      // Arrange
      final baseTime = DateTime.now().toUtc();
      final largeBatch = List.generate(
        500,
        (i) => SyncOperation.create(
          entityId: 'trip-$i',
          entityType: SyncEntityType.trip,
          data: {'title': 'Trip $i'},
          version: 1,
          lastModified: baseTime,
        ),
      );

      for (final op in largeBatch) {
        await syncService.enqueue(op);
      }

      final stopwatch = Stopwatch()..start();
      var processedCount = 0;

      // Act
      await syncService.processBatch((op) async {
        processedCount++;
        return SyncErrorResult.success();
      });

      stopwatch.stop();

      // Assert
      expect(processedCount, 500);
      expect(syncService.queueSize, 0);
      expect(stopwatch.elapsedMilliseconds, lessThan(10000)); // Should complete in < 10 seconds
    });

    test('should handle memory efficiently with large queue', () async {
      // Arrange
      final baseTime = DateTime.now().toUtc();
      final largeBatch = List.generate(
        2000,
        (i) => SyncOperation.create(
          entityId: 'trip-$i',
          entityType: SyncEntityType.trip,
          data: {
            'title': 'Trip $i' * 10, // Larger data
            'nested': {'data': i.toString() * 5},
          },
          version: 1,
          lastModified: baseTime,
        ),
      );

      // Act
      for (final op in largeBatch) {
        await syncService.enqueue(op);
      }

      // Assert - Queue should handle large operations
      expect(syncService.queueSize, 2000);
      expect(syncService.queue, isNotEmpty);
      expect(syncService.queue.last.entityId, 'trip-1999');
    });

    test('should maintain performance with frequent queue operations', () async {
      // Arrange
      final baseTime = DateTime.now().toUtc();
      final stopwatch = Stopwatch()..start();
      var operationCount = 0;

      // Act - Perform many enqueue/dequeue operations
      for (var i = 0; i < 100; i++) {
        // Enqueue 10 operations
        for (var j = 0; j < 10; j++) {
          final op = SyncOperation.create(
            entityId: 'trip-$i-$j',
            entityType: SyncEntityType.trip,
            data: {'title': 'Trip $i-$j'},
            version: 1,
            lastModified: baseTime,
          );
          await syncService.enqueue(op);
          operationCount++;
        }

        // Process batch
        await syncService.processBatch((op) async {
          return SyncErrorResult.success();
        });
      }

      stopwatch.stop();

      // Assert
      expect(operationCount, 1000);
      expect(syncService.queueSize, 0);
      expect(stopwatch.elapsedMilliseconds, lessThan(15000)); // Should complete in < 15 seconds
    });

    test('should handle large batch with mixed operation types', () async {
      // Arrange
      final baseTime = DateTime.now().toUtc();
      final mixedOps = <SyncOperation>[];

      for (var i = 0; i < 300; i++) {
        final opType = i % 3;
        final op = opType == 0
            ? SyncOperation.create(
                entityId: 'trip-$i',
                entityType: SyncEntityType.trip,
                data: {'title': 'Trip $i'},
                version: 1,
                lastModified: baseTime,
              )
            : opType == 1
                ? SyncOperation.update(
                    entityId: 'trip-$i',
                    entityType: SyncEntityType.trip,
                    data: {'title': 'Updated $i'},
                    version: 2,
                    lastModified: baseTime,
                  )
                : SyncOperation.delete(
                    entityId: 'trip-$i',
                    entityType: SyncEntityType.trip,
                    version: 2,
                    lastModified: baseTime,
                  );
        mixedOps.add(op);
      }

      // Act
      for (final op in mixedOps) {
        await syncService.enqueue(op);
      }

      var processedCount = 0;
      await syncService.processBatch((op) async {
        processedCount++;
        return SyncErrorResult.success();
      });

      // Assert
      expect(processedCount, 300);
      expect(syncService.queueSize, 0);
    });

    test('should handle priority sorting in large batch', () async {
      // Arrange
      final baseTime = DateTime.now().toUtc();
      final ops = List.generate(
        100,
        (i) => SyncOperation.create(
          entityId: 'trip-$i',
          entityType: i % 2 == 0 ? SyncEntityType.authTokens : SyncEntityType.trip,
          data: {'title': 'Trip $i'},
          version: 1,
          lastModified: baseTime,
        ),
      );

      // Act
      for (final op in ops) {
        await syncService.enqueue(op);
      }

      // Assert - Auth tokens should come first (higher priority)
      expect(syncService.queue[0].entityType, SyncEntityType.authTokens);
    });
  });

  group('Edge Case - Concurrent Operations Tests', () {
    test('should handle concurrent enqueue operations', () async {
      // Arrange
      final baseTime = DateTime.now().toUtc();

      // Act - Enqueue operations concurrently
      final futures = List.generate(
        50,
        (i) => syncService.enqueue(
          SyncOperation.create(
            entityId: 'trip-$i',
            entityType: SyncEntityType.trip,
            data: {'title': 'Trip $i'},
            version: 1,
            lastModified: baseTime,
          ),
        ),
      );

      await Future.wait(futures);

      // Assert
      expect(syncService.queueSize, 50);
    });

    test('should handle pause/resume during large batch processing', () async {
      // Arrange
      final baseTime = DateTime.now().toUtc();
      final ops = List.generate(
        100,
        (i) => SyncOperation.create(
          entityId: 'trip-$i',
          entityType: SyncEntityType.trip,
          data: {'title': 'Trip $i'},
          version: 1,
          lastModified: baseTime,
        ),
      );

      for (final op in ops) {
        await syncService.enqueue(op);
      }

      var processedCount = 0;

      // Act - Start processing, pause, then resume
      final processingFuture = syncService.processQueue((op) async {
        processedCount++;
        await Future.delayed(const Duration(milliseconds: 10));
        return SyncErrorResult.success();
      });

      // Pause after a short delay
      await Future.delayed(const Duration(milliseconds: 100));
      syncService.pause();
      await Future.delayed(const Duration(milliseconds: 50));
      syncService.resume();

      await processingFuture;

      // Assert
      expect(processedCount, 100);
      expect(syncService.queueSize, 0);
    });

    test('should handle clear queue during processing', () async {
      // Arrange
      final baseTime = DateTime.now().toUtc();
      final ops = List.generate(
        50,
        (i) => SyncOperation.create(
          entityId: 'trip-$i',
          entityType: SyncEntityType.trip,
          data: {'title': 'Trip $i'},
          version: 1,
          lastModified: baseTime,
        ),
      );

      for (final op in ops) {
        await syncService.enqueue(op);
      }

      var processedCount = 0;

      // Act - Start processing and clear queue
      final processingFuture = syncService.processQueue((op) async {
        processedCount++;
        if (processedCount == 10) {
          syncService.clearQueue();
        }
        await Future.delayed(const Duration(milliseconds: 10));
        return SyncErrorResult.success();
      });

      await processingFuture;

      // Assert
      expect(syncService.queueSize, 0);
    });
  });

  group('Edge Case - Resource Management Tests', () {
    test('should dispose resources properly', () async {
      // Arrange
      final baseTime = DateTime.now().toUtc();
      final op = SyncOperation.create(
        entityId: 'trip-1',
        entityType: SyncEntityType.trip,
        data: {'title': 'Trip 1'},
        version: 1,
        lastModified: baseTime,
      );

      await syncService.enqueue(op);

      // Act
      await syncService.dispose();

      // Assert - Operations after dispose should be handled gracefully
      expect(() => syncService.queue, returnsNormally);
    });

    test('should handle rapid status transitions', () async {
      // Arrange
      final statusTransitions = <SyncStatus>[];
      final subscription = syncService.statusStream.listen(statusTransitions.add);

      // Act - Rapidly change status
      await syncService.enqueue(
        SyncOperation.create(
          entityId: 'trip-1',
          entityType: SyncEntityType.trip,
          data: {'title': 'Trip 1'},
          version: 1,
          lastModified: DateTime.now().toUtc(),
        ),
      );

      syncService.pause();
      syncService.resume();
      syncService.pause();
      syncService.resume();

      await subscription.cancel();

      // Assert
      expect(statusTransitions, isNotEmpty);
    });

    test('should handle configuration changes during operation', () async {
      // Arrange
      final baseTime = DateTime.now().toUtc();
      final ops = List.generate(
        10,
        (i) => SyncOperation.create(
          entityId: 'trip-$i',
          entityType: SyncEntityType.trip,
          data: {'title': 'Trip $i'},
          version: 1,
          lastModified: baseTime,
        ),
      );

      for (final op in ops) {
        await syncService.enqueue(op);
      }

      // Act - Change configuration
      syncService.updateConfig(
        const SyncQueueConfig(
          maxRetries: 10,
          batchSize: 25,
          processDelay: Duration(milliseconds: 100),
        ),
      );

      await syncService.processQueue((op) async {
        return SyncErrorResult.success();
      });

      // Assert
      expect(syncService.config.maxRetries, 10);
      expect(syncService.config.batchSize, 25);
      expect(syncService.queueSize, 0);
    });
  });
}
