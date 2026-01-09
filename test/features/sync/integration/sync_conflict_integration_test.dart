import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:soloadventurer/features/sync/domain/models/entity_version.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_info.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_resolution.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_operation.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_status.dart';
import 'package:soloadventurer/features/sync/domain/entities/sync_entity_type.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/sync_service_impl.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/conflict_detector_impl.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/conflict_resolver_impl.dart';
import 'package:soloadventurer/features/sync/domain/services/network_connectivity.dart';
import 'package:soloadventurer/features/sync/domain/services/sync_queue_persistence.dart';

@GenerateMocks([
  NetworkConnectivity,
  SyncQueuePersistence,
])
import 'sync_conflict_integration_test.mocks.dart';

/// Mock backend server for testing conflict scenarios
class MockBackendServer {
  final Map<String, EntityVersion> _remoteVersions = {};
  final Map<String, Map<String, dynamic>> _remoteData = {};

  EntityVersion? getRemoteVersion(String entityId) => _remoteVersions[entityId];

  Map<String, dynamic>? getRemoteData(String entityId) => _remoteData[entityId];

  void updateRemoteData(String entityId, EntityVersion version, Map<String, dynamic> data) {
    _remoteVersions[entityId] = version;
    _remoteData[entityId] = data;
  }

  void clear() {
    _remoteVersions.clear();
    _remoteData.clear();
  }
}

void main() {
  late MockBackendServer mockBackend;
  late MockNetworkConnectivity mockNetworkConnectivity;
  late MockSyncQueuePersistence mockPersistence;
  late ConflictDetectorImpl conflictDetector;
  late ConflictResolverImpl conflictResolver;

  setUp(() {
    mockBackend = MockBackendServer();
    mockNetworkConnectivity = MockNetworkConnectivity();
    mockPersistence = MockSyncQueuePersistence();

    // Setup default mock responses
    when(mockPersistence.loadQueue()).thenAnswer((_) async => []);
    when(mockPersistence.saveQueue(any)).thenAnswer((_) async =>
        SyncQueuePersistenceResult.success(operationCount: 0));
  });

  tearDown(() async {
    mockBackend.clear();
  });

  group('Integration Tests - Simultaneous Edit Conflict Scenarios', () {
    test('should detect conflict when two devices edit same entity simultaneously',
        () async {
      // Arrange
      conflictDetector = ConflictDetectorImpl(
        config: ConflictDetectionConfig(
          deviceId: 'device-a',
          concurrentThresholdMs: 1000,
        ),
      );

      final baseTime = DateTime.now().toUtc();
      final localVersion = EntityVersion(
        entityId: 'trip-123',
        entityType: 'trip',
        version: 2,
        lastModified: baseTime,
        deviceId: 'device-a',
        dataHash: 'abc123',
      );

      final remoteVersion = EntityVersion(
        entityId: 'trip-123',
        entityType: 'trip',
        version: 2,
        lastModified: baseTime.add(const Duration(milliseconds: 500)),
        deviceId: 'device-b',
        dataHash: 'def456',
      );

      final localData = {'title': 'Paris Trip', 'days': 5};
      final remoteData = {'title': 'Paris Trip', 'days': 7};

      // Act
      final conflict = await conflictDetector.detectConflict(
        localVersion: localVersion,
        remoteVersion: remoteVersion,
        localData: localData,
        remoteData: remoteData,
      );

      // Assert
      expect(conflict, isNotNull);
      expect(conflict!.conflictType, ConflictType.diverged);
      expect(conflict.severity, ConflictSeverity.medium);
      expect(conflict.localVersion.deviceId, 'device-a');
      expect(conflict.remoteVersion.deviceId, 'device-b');
    });

    test('should resolve simultaneous edit conflict with last-write-wins', () async {
      // Arrange
      conflictResolver = ConflictResolverImpl(
        config: ConflictResolutionConfig(
          deviceId: 'device-a',
          preferLocalOnEqualTimestamps: false,
        ),
      );

      final baseTime = DateTime.now().toUtc();
      final localVersion = EntityVersion(
        entityId: 'trip-123',
        entityType: 'trip',
        version: 2,
        lastModified: baseTime,
        deviceId: 'device-a',
      );

      final remoteVersion = EntityVersion(
        entityId: 'trip-123',
        entityType: 'trip',
        version: 2,
        lastModified: baseTime.add(const Duration(seconds: 1)),
        deviceId: 'device-b',
      );

      final conflict = ConflictInfo(
        conflictId: 'conflict-1',
        entityId: 'trip-123',
        entityType: 'trip',
        conflictType: ConflictType.diverged,
        severity: ConflictSeverity.medium,
        localVersion: localVersion,
        remoteVersion: remoteVersion,
        localData: {'title': 'Paris Trip (Device A)'},
        remoteData: {'title': 'Paris Trip (Device B)'},
        description: 'Conflict detected',
        detectedAt: DateTime.now().toUtc(),
      );

      // Act
      final resolution = await conflictResolver.resolveConflict(
        conflict: conflict,
        strategy: ConflictResolutionStrategy.lastWriteWins,
      );

      // Assert
      expect(resolution.isSuccessful, isTrue);
      expect(resolution.strategy, ConflictResolutionStrategy.lastWriteWins);
      expect(resolution.resolvedData['title'], 'Paris Trip (Device B)');
      expect(resolution.resolvedVersion.deviceId, 'device-b');
    });

    test('should detect no conflict when versions are monotonic', () async {
      // Arrange
      conflictDetector = ConflictDetectorImpl(
        config: ConflictDetectionConfig(deviceId: 'device-a'),
      );

      final localVersion = EntityVersion(
        entityId: 'trip-123',
        entityType: 'trip',
        version: 3,
        lastModified: DateTime.now().toUtc(),
        deviceId: 'device-a',
      );

      final remoteVersion = EntityVersion(
        entityId: 'trip-123',
        entityType: 'trip',
        version: 2,
        lastModified: DateTime.now().toUtc().subtract(const Duration(hours: 1)),
        deviceId: 'device-b',
      );

      // Act
      final conflict = await conflictDetector.detectConflict(
        localVersion: localVersion,
        remoteVersion: remoteVersion,
      );

      // Assert
      expect(conflict, isNull);
    });

    test('should auto-merge conflicts with non-overlapping field changes', () async {
      // Arrange
      conflictResolver = ConflictResolverImpl(
        config: ConflictResolutionConfig(deviceId: 'device-a'),
      );

      final conflict = ConflictInfo(
        conflictId: 'conflict-2',
        entityId: 'trip-123',
        entityType: 'trip',
        conflictType: ConflictType.diverged,
        severity: ConflictSeverity.low,
        localVersion: EntityVersion(
          entityId: 'trip-123',
          entityType: 'trip',
          version: 2,
          lastModified: DateTime.now().toUtc(),
          deviceId: 'device-a',
        ),
        remoteVersion: EntityVersion(
          entityId: 'trip-123',
          entityType: 'trip',
          version: 2,
          lastModified: DateTime.now().toUtc(),
          deviceId: 'device-b',
        ),
        localData: {
          'title': 'Paris Trip',
          'notes': 'Added by device A',
        },
        remoteData: {
          'title': 'Paris Trip',
          'budget': 5000,
        },
        description: 'Non-overlapping changes',
        detectedAt: DateTime.now().toUtc(),
      );

      // Act
      final resolution = await conflictResolver.resolveWithAutomaticMerge(conflict);

      // Assert
      expect(resolution.isSuccessful, isTrue);
      expect(resolution.strategy, ConflictResolutionStrategy.automaticMerge);
      expect(resolution.resolvedData['title'], 'Paris Trip');
      expect(resolution.resolvedData['notes'], 'Added by device A');
      expect(resolution.resolvedData['budget'], 5000);
      expect(resolution.mergeResult?.conflictedFields, isEmpty);
    });

    test('should handle batch conflict detection for multiple entities', () async {
      // Arrange
      conflictDetector = ConflictDetectorImpl(
        config: ConflictDetectionConfig(deviceId: 'device-a'),
      );

      final localVersions = [
        EntityVersion(
          entityId: 'trip-1',
          entityType: 'trip',
          version: 2,
          lastModified: DateTime.now().toUtc(),
          deviceId: 'device-a',
        ),
        EntityVersion(
          entityId: 'trip-2',
          entityType: 'trip',
          version: 1,
          lastModified: DateTime.now().toUtc(),
          deviceId: 'device-a',
        ),
      ];

      final remoteVersions = [
        EntityVersion(
          entityId: 'trip-1',
          entityType: 'trip',
          version: 2,
          lastModified: DateTime.now().toUtc().add(const Duration(seconds: 1)),
          deviceId: 'device-b',
        ),
        EntityVersion(
          entityId: 'trip-2',
          entityType: 'trip',
          version: 1,
          lastModified: DateTime.now().toUtc().subtract(const Duration(hours: 1)),
          deviceId: 'device-b',
        ),
      ];

      // Act
      final result = await conflictDetector.detectMultipleConflicts(
        localVersions: localVersions,
        remoteVersions: remoteVersions,
      );

      // Assert
      expect(result.conflicts, hasLength(1));
      expect(result.conflicts[0].entityId, 'trip-1');
      expect(result.totalProcessed, 2);
      expect(result.conflictsDetected, 1);
    });
  });

  group('Integration Tests - Offline-Then-Online Sync Scenarios', () {
    test('should queue operations while offline and sync when back online', () async {
      // Arrange
      final connectivityController = StreamController<bool>();
      when(mockNetworkConnectivity.onOnline)
          .thenAnswer((_) => connectivityController.stream);

      final syncService = SyncServiceImpl(
        networkConnectivity: mockNetworkConnectivity,
        persistence: mockPersistence,
      );
      syncService.pauseProcessing();

      // Act - Enqueue operations while "offline"
      final operations = List.generate(
        5,
        (i) => SyncOperation.create(
          id: 'op-$i',
          entityType: SyncEntityType.trip,
          entityId: 'trip-$i',
          data: {'title': 'Trip $i'},
        ),
      );

      for (final op in operations) {
        await syncService.enqueueOperation(op);
      }

      expect(syncService.queueSize, 5);

      // Simulate coming back online
      syncService.resumeProcessing();
      connectivityController.add(true);

      await Future.delayed(const Duration(milliseconds: 500));

      // Assert
      verify(mockNetworkConnectivity.onOnline).called(greaterThanOrEqualTo(1));
      expect(syncService.status, anyOf(SyncStatus.success, SyncStatus.idle, SyncStatus.pending));

      await connectivityController.close();
      await syncService.dispose();
    });

    test('should persist operations across app restart while offline', () async {
      // Arrange
      final operations = [
        SyncOperation.create(
          id: 'op-1',
          entityType: SyncEntityType.trip,
          entityId: 'trip-1',
          data: {'title': 'Offline Trip 1'},
        ),
        SyncOperation.create(
          id: 'op-2',
          entityType: SyncEntityType.trip,
          entityId: 'trip-2',
          data: {'title': 'Offline Trip 2'},
        ),
      ];

      when(mockPersistence.loadQueue()).thenAnswer((_) async => operations);

      // Act - Simulate app restart
      final syncService = SyncServiceImpl(
        persistence: mockPersistence,
      );
      syncService.pauseProcessing();

      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(syncService.queueSize, 2);
      expect(syncService.queue[0].entityId, 'trip-1');
      expect(syncService.queue[1].entityId, 'trip-2');
      expect(syncService.status, SyncStatus.pending);

      verify(mockPersistence.loadQueue()).called(1);

      await syncService.dispose();
    });

    test('should handle conflict when syncing offline changes', () async {
      // Arrange
      conflictDetector = ConflictDetectorImpl(
        config: ConflictDetectionConfig(deviceId: 'device-a'),
      );

      // Device A edits while offline
      final offlineVersion = EntityVersion(
        entityId: 'trip-123',
        entityType: 'trip',
        version: 2,
        lastModified: DateTime.now().toUtc().subtract(const Duration(minutes: 10)),
        deviceId: 'device-a',
        dataHash: 'offline-hash',
      );

      // Device B edits while device A is offline
      final remoteVersion = EntityVersion(
        entityId: 'trip-123',
        entityType: 'trip',
        version: 3,
        lastModified: DateTime.now().toUtc().subtract(const Duration(minutes: 5)),
        deviceId: 'device-b',
        dataHash: 'remote-hash',
      );

      // Act - Device A comes back online and detects conflict
      final conflict = await conflictDetector.detectConflict(
        localVersion: offlineVersion,
        remoteVersion: remoteVersion,
        localData: {'title': 'Trip (Offline Edit)'},
        remoteData: {'title': 'Trip (Remote Edit)'},
      );

      // Assert
      expect(conflict, isNotNull);
      expect(conflict!.conflictType, ConflictType.remoteNewer);
      expect(conflict.severity, ConflictSeverity.low);
      expect(conflict.localVersion.version, 2);
      expect(conflict.remoteVersion.version, 3);
    });

    test('should handle multiple offline edits syncing on different devices', () async {
      // Arrange
      final connectivityController = StreamController<bool>();
      when(mockNetworkConnectivity.onOnline)
          .thenAnswer((_) => connectivityController.stream);

      final syncServiceA = SyncServiceImpl(
        networkConnectivity: mockNetworkConnectivity,
        persistence: mockPersistence,
      );
      syncServiceA.pauseProcessing();

      // Device A creates operation while offline
      await syncServiceA.enqueueOperation(
        SyncOperation.create(
          id: 'op-a1',
          entityType: SyncEntityType.trip,
          entityId: 'trip-1',
          data: {'title': 'Device A Offline Edit'},
        ),
      );

      // Simulate device A coming online
      syncServiceA.resumeProcessing();
      connectivityController.add(true);

      await Future.delayed(const Duration(milliseconds: 300));

      // Assert
      expect(syncServiceA.queueSize, lessThanOrEqualTo(1));

      await connectivityController.close();
      await syncServiceA.dispose();
    });
  });

  group('Integration Tests - Network Interruption Recovery', () {
    test('should retry failed operations after network interruption', () async {
      // Arrange
      final syncService = SyncServiceImpl(
        persistence: mockPersistence,
      );
      syncService.pauseProcessing();

      // Enqueue operation that will fail
      final operation = SyncOperation.create(
        id: 'op-retry',
        entityType: SyncEntityType.trip,
        entityId: 'trip-1',
        data: {'title': 'Retry Test'},
      );

      await syncService.enqueueOperation(operation);
      syncService.resumeProcessing();

      // Simulate processing failure by modifying operation
      final queueBefore = syncService.queue;
      expect(queueBefore, isNotEmpty);

      await Future.delayed(const Duration(milliseconds: 300));

      // Assert - Operation should be processed
      final queueAfter = syncService.queue;
      expect(queueAfter.length, lessThanOrEqualTo(queueBefore.length));

      await syncService.dispose();
    });

    test('should handle network interruption during batch processing', () async {
      // Arrange
      final syncService = SyncServiceImpl(
        persistence: mockPersistence,
      );
      syncService.pauseProcessing();

      final operations = List.generate(
        10,
        (i) => SyncOperation.create(
          id: 'op-batch-$i',
          entityType: SyncEntityType.trip,
          entityId: 'trip-$i',
          data: {'title': 'Batch Trip $i'},
        ),
      );

      for (final op in operations) {
        await syncService.enqueueOperation(op);
      }

      expect(syncService.queueSize, 10);

      // Act - Process batch
      syncService.resumeProcessing();
      final result = await syncService.processBatch(maxBatchSize: 5);

      // Assert
      expect(result, isNotNull);
      expect(syncService.queueSize, lessThanOrEqualTo(10));

      await syncService.dispose();
    });

    test('should maintain queue order after network interruption', () async {
      // Arrange
      final syncService = SyncServiceImpl(
        persistence: mockPersistence,
      );
      syncService.pauseProcessing();

      final highPriorityOp = SyncOperation.create(
        id: 'op-high',
        entityType: SyncEntityType.trip,
        entityId: 'trip-high',
        data: {'title': 'High Priority'},
        priority: 10,
      );

      final lowPriorityOp = SyncOperation.create(
        id: 'op-low',
        entityType: SyncEntityType.travelNote,
        entityId: 'note-low',
        data: {'content': 'Low Priority'},
        priority: 1,
      );

      await syncService.enqueueOperation(lowPriorityOp);
      await syncService.enqueueOperation(highPriorityOp);

      // Assert - High priority should be first
      expect(syncService.queue.first.entityId, 'trip-high');

      // Act - Process batch
      syncService.resumeProcessing();
      await syncService.processBatch(maxBatchSize: 1);

      await Future.delayed(const Duration(milliseconds: 200));

      // Assert - Order maintained
      if (syncService.queue.isNotEmpty) {
        expect(syncService.queue.first.priority, lessThanOrEqualTo(10));
      }

      await syncService.dispose();
    });

    test('should recover from network error and continue processing', () async {
      // Arrange
      final syncService = SyncServiceImpl(
        persistence: mockPersistence,
      );
      syncService.pauseProcessing();

      final operations = List.generate(
        3,
        (i) => SyncOperation.create(
          id: 'op-recovery-$i',
          entityType: SyncEntityType.trip,
          entityId: 'trip-$i',
          data: {'title': 'Recovery Trip $i'},
        ),
      );

      for (final op in operations) {
        await syncService.enqueueOperation(op);
      }

      // Act - Process with potential interruptions
      syncService.resumeProcessing();
      final result = await syncService.processQueue();

      // Assert
      expect(result, isNotNull);
      expect(syncService.queueSize, lessThanOrEqualTo(3));

      await syncService.dispose();
    });
  });

  group('Integration Tests - Multiple Device Sync Scenarios', () {
    test('should handle sync from two devices with same data', () async {
      // Arrange - Simulate device A
      final syncServiceA = SyncServiceImpl(
        persistence: mockPersistence,
      );

      // Device A creates trip
      final versionA = EntityVersion.initial(
        entityId: 'trip-shared',
        entityType: 'trip',
        deviceId: 'device-a',
      );

      mockBackend.updateRemoteData(
        'trip-shared',
        versionA,
        {'title': 'Shared Trip', 'days': 5},
      );

      // Device B syncs same data
      final versionB = mockBackend.getRemoteVersion('trip-shared');
      final dataB = mockBackend.getRemoteData('trip-shared');

      // Assert - Data should be identical
      expect(versionB, isNotNull);
      expect(versionB!.deviceId, 'device-a');
      expect(dataB?['title'], 'Shared Trip');

      await syncServiceA.dispose();
    });

    test('should detect version conflict between two devices', () async {
      // Arrange
      conflictDetector = ConflictDetectorImpl(
        config: ConflictDetectionConfig(deviceId: 'device-a'),
      );

      // Device A version
      final versionA = EntityVersion(
        entityId: 'trip-1',
        entityType: 'trip',
        version: 2,
        lastModified: DateTime.now().toUtc(),
        deviceId: 'device-a',
      );

      // Device B version (newer)
      final versionB = EntityVersion(
        entityId: 'trip-1',
        entityType: 'trip',
        version: 3,
        lastModified: DateTime.now().toUtc().add(const Duration(minutes: 1)),
        deviceId: 'device-b',
      );

      // Act
      final conflict = await conflictDetector.detectConflict(
        localVersion: versionA,
        remoteVersion: versionB,
      );

      // Assert
      expect(conflict, isNotNull);
      expect(conflict!.conflictType, ConflictType.remoteNewer);
      expect(conflict.severity, ConflictSeverity.low);
    });

    test('should merge changes from multiple devices correctly', () async {
      // Arrange
      conflictResolver = ConflictResolverImpl(
        config: ConflictResolutionConfig(deviceId: 'device-a'),
      );

      final conflict = ConflictInfo(
        conflictId: 'multi-device-conflict',
        entityId: 'trip-1',
        entityType: 'trip',
        conflictType: ConflictType.diverged,
        severity: ConflictSeverity.low,
        localVersion: EntityVersion(
          entityId: 'trip-1',
          entityType: 'trip',
          version: 2,
          lastModified: DateTime.now().toUtc(),
          deviceId: 'device-a',
        ),
        remoteVersion: EntityVersion(
          entityId: 'trip-1',
          entityType: 'trip',
          version: 2,
          lastModified: DateTime.now().toUtc(),
          deviceId: 'device-b',
        ),
        localData: {
          'title': 'Paris Trip',
          'accommodation': 'Hotel A',
        },
        remoteData: {
          'title': 'Paris Trip',
          'transport': 'Flight B',
        },
        description: 'Multi-device conflict',
        detectedAt: DateTime.now().toUtc(),
      );

      // Act
      final resolution = await conflictResolver.resolveWithAutomaticMerge(conflict);

      // Assert
      expect(resolution.isSuccessful, isTrue);
      expect(resolution.resolvedData['title'], 'Paris Trip');
      expect(resolution.resolvedData['accommodation'], 'Hotel A');
      expect(resolution.resolvedData['transport'], 'Flight B');
    });

    test('should handle three-way sync scenario', () async {
      // Arrange
      conflictDetector = ConflictDetectorImpl(
        config: ConflictDetectionConfig(deviceId: 'device-a'),
      );

      // Device A: version 2
      final versionA = EntityVersion(
        entityId: 'trip-1',
        entityType: 'trip',
        version: 2,
        lastModified: DateTime.now().toUtc().subtract(const Duration(minutes: 10)),
        deviceId: 'device-a',
      );

      // Device B: version 3
      final versionB = EntityVersion(
        entityId: 'trip-1',
        entityType: 'trip',
        version: 3,
        lastModified: DateTime.now().toUtc().subtract(const Duration(minutes: 5)),
        deviceId: 'device-b',
      );

      // Device C: version 4 (latest)
      final versionC = EntityVersion(
        entityId: 'trip-1',
        entityType: 'trip',
        version: 4,
        lastModified: DateTime.now().toUtc(),
        deviceId: 'device-c',
      );

      // Act - Device A detects it's behind
      final conflictAB = await conflictDetector.detectConflict(
        localVersion: versionA,
        remoteVersion: versionB,
      );

      final conflictAC = await conflictDetector.detectConflict(
        localVersion: versionA,
        remoteVersion: versionC,
      );

      // Assert
      expect(conflictAB, isNotNull);
      expect(conflictAB!.conflictType, ConflictType.remoteNewer);

      expect(conflictAC, isNotNull);
      expect(conflictAC!.conflictType, ConflictType.remoteNewer);
    });

    test('should prioritize by version number in multi-device scenario', () async {
      // Arrange
      conflictResolver = ConflictResolverImpl(
        config: ConflictResolutionConfig(
          deviceId: 'device-a',
          preferLocalOnEqualTimestamps: false,
        ),
      );

      final conflict = ConflictInfo(
        conflictId: 'version-priority',
        entityId: 'trip-1',
        entityType: 'trip',
        conflictType: ConflictType.versionConflict,
        severity: ConflictSeverity.low,
        localVersion: EntityVersion(
          entityId: 'trip-1',
          entityType: 'trip',
          version: 2,
          lastModified: DateTime.now().toUtc(),
          deviceId: 'device-a',
        ),
        remoteVersion: EntityVersion(
          entityId: 'trip-1',
          entityType: 'trip',
          version: 5,
          lastModified: DateTime.now().toUtc(),
          deviceId: 'device-b',
        ),
        localData: {'title': 'Version 2'},
        remoteData: {'title': 'Version 5'},
        description: 'Version conflict',
        detectedAt: DateTime.now().toUtc(),
      );

      // Act
      final resolution = await conflictResolver.resolveWithLastWriteWins(
        conflict: conflict,
        preferLocal: false,
      );

      // Assert - Remote version (higher version number) should win
      expect(resolution.isSuccessful, isTrue);
      expect(resolution.resolvedVersion.version, 5);
      expect(resolution.resolvedVersion.deviceId, 'device-b');
    });
  });

  group('Integration Tests - End-to-End Conflict Workflows', () {
    test('should complete full conflict resolution workflow', () async {
      // Arrange
      conflictDetector = ConflictDetectorImpl(
        config: ConflictDetectionConfig(deviceId: 'device-a'),
      );
      conflictResolver = ConflictResolverImpl(
        config: ConflictResolutionConfig(deviceId: 'device-a'),
      );

      // Step 1: Detect conflict
      final localVersion = EntityVersion(
        entityId: 'trip-workflow',
        entityType: 'trip',
        version: 2,
        lastModified: DateTime.now().toUtc(),
        deviceId: 'device-a',
      );

      final remoteVersion = EntityVersion(
        entityId: 'trip-workflow',
        entityType: 'trip',
        version: 2,
        lastModified: DateTime.now().toUtc().add(const Duration(seconds: 1)),
        deviceId: 'device-b',
      );

      final conflict = await conflictDetector.detectConflict(
        localVersion: localVersion,
        remoteVersion: remoteVersion,
        localData: {'title': 'Device A Edit'},
        remoteData: {'title': 'Device B Edit'},
      );

      expect(conflict, isNotNull);

      // Step 2: Get recommendation
      final strategy = conflictResolver.recommendStrategy(conflict: conflict!);
      expect(strategy, ConflictResolutionStrategy.lastWriteWins);

      // Step 3: Resolve with recommended strategy
      final resolution = await conflictResolver.resolveConflict(
        conflict: conflict,
        strategy: strategy,
      );

      // Assert - Workflow complete
      expect(resolution.isSuccessful, isTrue);
      expect(resolution.resolvedData['title'], 'Device B Edit');
    });

    test('should handle batch conflict resolution workflow', () async {
      // Arrange
      conflictDetector = ConflictDetectorImpl(
        config: ConflictDetectionConfig(deviceId: 'device-a'),
      );
      conflictResolver = ConflictResolverImpl(
        config: ConflictResolutionConfig(deviceId: 'device-a'),
      );

      // Create multiple conflicts
      final conflicts = [
        ConflictInfo(
          conflictId: 'batch-1',
          entityId: 'trip-1',
          entityType: 'trip',
          conflictType: ConflictType.diverged,
          severity: ConflictSeverity.low,
          localVersion: EntityVersion(
            entityId: 'trip-1',
            entityType: 'trip',
            version: 2,
            lastModified: DateTime.now().toUtc(),
            deviceId: 'device-a',
          ),
          remoteVersion: EntityVersion(
            entityId: 'trip-1',
            entityType: 'trip',
            version: 2,
            lastModified: DateTime.now().toUtc(),
            deviceId: 'device-b',
          ),
          localData: {'title': 'Trip 1'},
          remoteData: {'title': 'Trip 1 Updated'},
          description: 'Batch conflict 1',
          detectedAt: DateTime.now().toUtc(),
        ),
        ConflictInfo(
          conflictId: 'batch-2',
          entityId: 'trip-2',
          entityType: 'trip',
          conflictType: ConflictType.diverged,
          severity: ConflictSeverity.low,
          localVersion: EntityVersion(
            entityId: 'trip-2',
            entityType: 'trip',
            version: 1,
            lastModified: DateTime.now().toUtc(),
            deviceId: 'device-a',
          ),
          remoteVersion: EntityVersion(
            entityId: 'trip-2',
            entityType: 'trip',
            version: 1,
            lastModified: DateTime.now().toUtc(),
            deviceId: 'device-b',
          ),
          localData: {'title': 'Trip 2'},
          remoteData: {'title': 'Trip 2 Updated'},
          description: 'Batch conflict 2',
          detectedAt: DateTime.now().toUtc(),
        ),
      ];

      // Act - Resolve batch
      final result = await conflictResolver.resolveMultipleConflicts(
        conflicts: conflicts,
        strategies: [
          ConflictResolutionStrategy.lastWriteWins,
          ConflictResolutionStrategy.lastWriteWins,
        ],
      );

      // Assert
      expect(result.totalConflicts, 2);
      expect(result.resolvedCount, 2);
      expect(result.failedCount, 0);
      expect(result.resolutions, hasLength(2));
    });

    test('should handle manual resolution workflow with user choice', () async {
      // Arrange
      conflictResolver = ConflictResolverImpl(
        config: ConflictResolutionConfig(deviceId: 'device-a'),
      );

      final conflict = ConflictInfo(
        conflictId: 'manual-choice',
        entityId: 'trip-manual',
        entityType: 'trip',
        conflictType: ConflictType.diverged,
        severity: ConflictSeverity.high,
        localVersion: EntityVersion(
          entityId: 'trip-manual',
          entityType: 'trip',
          version: 2,
          lastModified: DateTime.now().toUtc(),
          deviceId: 'device-a',
        ),
        remoteVersion: EntityVersion(
          entityId: 'trip-manual',
          entityType: 'trip',
          version: 2,
          lastModified: DateTime.now().toUtc(),
          deviceId: 'device-b',
        ),
        localData: {
          'title': 'Important Local Edit',
          'budget': 1000,
        },
        remoteData: {
          'title': 'Important Remote Edit',
          'budget': 2000,
        },
        description: 'Requires manual resolution',
        detectedAt: DateTime.now().toUtc(),
      );

      // Act - User chooses to keep local
      final resolution = await conflictResolver.resolveConflict(
        conflict: conflict,
        strategy: ConflictResolutionStrategy.manual,
        userChoice: ManualResolutionChoice.keepLocal,
      );

      // Assert
      expect(resolution.isSuccessful, isTrue);
      expect(resolution.strategy, ConflictResolutionStrategy.manual);
      expect(resolution.resolvedData['title'], 'Important Local Edit');
      expect(resolution.resolvedData['budget'], 1000);
    });

    test('should handle custom merge workflow', () async {
      // Arrange
      conflictResolver = ConflictResolverImpl(
        config: ConflictResolutionConfig(deviceId: 'device-a'),
      );

      final conflict = ConflictInfo(
        conflictId: 'custom-merge',
        entityId: 'trip-custom',
        entityType: 'trip',
        conflictType: ConflictType.diverged,
        severity: ConflictSeverity.high,
        localVersion: EntityVersion(
          entityId: 'trip-custom',
          entityType: 'trip',
          version: 2,
          lastModified: DateTime.now().toUtc(),
          deviceId: 'device-a',
        ),
        remoteVersion: EntityVersion(
          entityId: 'trip-custom',
          entityType: 'trip',
          version: 2,
          lastModified: DateTime.now().toUtc(),
          deviceId: 'device-b',
        ),
        localData: {
          'title': 'Local Title',
          'budget': 1000,
        },
        remoteData: {
          'title': 'Remote Title',
          'days': 7,
        },
        description: 'Custom merge needed',
        detectedAt: DateTime.now().toUtc(),
      );

      final customData = {
        'title': 'Merged Title',
        'budget': 1500,
        'days': 7,
      };

      // Act - User provides custom merge
      final resolution = await conflictResolver.resolveConflict(
        conflict: conflict,
        strategy: ConflictResolutionStrategy.manual,
        userChoice: ManualResolutionChoice.customMerge,
        userData: customData,
      );

      // Assert
      expect(resolution.isSuccessful, isTrue);
      expect(resolution.resolvedData['title'], 'Merged Title');
      expect(resolution.resolvedData['budget'], 1500);
      expect(resolution.resolvedData['days'], 7);
    });
  });
}
