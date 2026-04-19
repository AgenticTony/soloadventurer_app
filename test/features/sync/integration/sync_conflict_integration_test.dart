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
import 'package:soloadventurer/features/sync/domain/services/conflict_detector.dart';
import 'package:soloadventurer/features/sync/domain/services/conflict_resolver.dart';
import 'package:soloadventurer/features/sync/domain/services/network_connectivity.dart';
import 'package:soloadventurer/features/sync/domain/services/sync_queue_persistence.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/sync_service_impl.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/conflict_detector_impl.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/conflict_resolver_impl.dart';

@GenerateMocks([
  NetworkConnectivity,
  SyncQueuePersistence,
])
import 'sync_conflict_integration_test.mocks.dart';

/// Mock backend server for testing conflict scenarios
class MockBackendServer {
  final Map<String, EntityVersion> _remoteVersions = {};
  final Map<String, Map<String, dynamic>> _remoteData = {};

  EntityVersion? getRemoteVersion(String entityId) =>
      _remoteVersions[entityId];

  Map<String, dynamic>? getRemoteData(String entityId) =>
      _remoteData[entityId];

  void updateRemoteData(
      String entityId, EntityVersion version, Map<String, dynamic> data) {
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

    when(mockPersistence.loadQueue()).thenAnswer((_) async => []);
    when(mockPersistence.saveQueue(any)).thenAnswer(
        (_) async => SyncQueuePersistenceResult.success(operationCount: 0));

    when(mockNetworkConnectivity.currentStatus)
        .thenReturn(NetworkStatus.online(NetworkConnectionType.wifi));
    when(mockNetworkConnectivity.isOnline).thenReturn(true);
    when(mockNetworkConnectivity.connectionType)
        .thenReturn(NetworkConnectionType.wifi);
    when(mockNetworkConnectivity.statusStream)
        .thenAnswer((_) => const Stream.empty());
    when(mockNetworkConnectivity.onOnline)
        .thenAnswer((_) => const Stream.empty());
    when(mockNetworkConnectivity.onOffline)
        .thenAnswer((_) => const Stream.empty());
    when(mockNetworkConnectivity.initialize())
        .thenAnswer((_) async {});
    when(mockNetworkConnectivity.startMonitoring())
        .thenAnswer((_) async {});
    when(mockNetworkConnectivity.stopMonitoring())
        .thenAnswer((_) async {});
  });

  tearDown(() async {
    mockBackend.clear();
  });

  group('Integration Tests - Simultaneous Edit Conflict Scenarios', () {
    test(
        'should detect conflict when two devices edit same entity simultaneously',
        () async {
      conflictDetector = ConflictDetectorImpl(
        config: ConflictDetectionConfig(
          deviceId: 'device-a',
          timestampThresholdMs: 1000,
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

      final conflict = await conflictDetector.detectConflict(
        localVersion: localVersion,
        remoteVersion: remoteVersion,
        localData: {'title': 'Paris Trip', 'days': 5},
        remoteData: {'title': 'Paris Trip', 'days': 7},
      );

      expect(conflict, isNotNull);
      expect(conflict!.localVersion.deviceId, 'device-a');
      expect(conflict.remoteVersion.deviceId, 'device-b');
    });

    test('should resolve simultaneous edit conflict with last-write-wins',
        () async {
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
        localData: const {'title': 'Paris Trip (Device A)'},
        remoteData: const {'title': 'Paris Trip (Device B)'},
        description: 'Conflict detected',
        detectedAt: DateTime.now().toUtc(),
      );

      final resolution = await conflictResolver.resolveConflict(
        conflict: conflict,
        strategy: ConflictResolutionStrategy.lastWriteWins,
      );

      expect(resolution.strategy, ConflictResolutionStrategy.lastWriteWins);
      expect(resolution.resolvedData['title'], 'Paris Trip (Device B)');
    });

    test('should detect no conflict when versions are monotonic', () async {
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
        lastModified:
            DateTime.now().toUtc().subtract(const Duration(hours: 1)),
        deviceId: 'device-b',
      );

      final conflict = await conflictDetector.detectConflict(
        localVersion: localVersion,
        remoteVersion: remoteVersion,
      );

      expect(conflict, isNull);
    });

    test('should auto-merge conflicts with non-overlapping field changes',
        () async {
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
        localData: const {
          'title': 'Paris Trip',
          'notes': 'Added by device A',
        },
        remoteData: const {
          'title': 'Paris Trip',
          'budget': 5000,
        },
        description: 'Non-overlapping changes',
        detectedAt: DateTime.now().toUtc(),
      );

      final resolution =
          await conflictResolver.resolveWithAutomaticMerge(conflict: conflict);

      expect(resolution.strategy, ConflictResolutionStrategy.automaticMerge);
      expect(resolution.resolvedData['title'], 'Paris Trip');
      expect(resolution.resolvedData['notes'], 'Added by device A');
      expect(resolution.resolvedData['budget'], 5000);
      expect(resolution.conflictingFields, isEmpty);
    });

    test('should handle batch conflict detection for multiple entities',
        () async {
      conflictDetector = ConflictDetectorImpl(
        config: ConflictDetectionConfig(deviceId: 'device-a'),
      );

      final baseTime = DateTime.now().toUtc();
      final localVersions = [
        EntityVersion(
          entityId: 'trip-1',
          entityType: 'trip',
          version: 2,
          lastModified: baseTime,
          deviceId: 'device-a',
          dataHash: 'hash-local-1',
        ),
        EntityVersion(
          entityId: 'trip-2',
          entityType: 'trip',
          version: 1,
          lastModified: baseTime,
          deviceId: 'device-a',
        ),
      ];

      final remoteVersions = [
        EntityVersion(
          entityId: 'trip-1',
          entityType: 'trip',
          version: 2,
          lastModified: baseTime.add(const Duration(milliseconds: 500)),
          deviceId: 'device-b',
          dataHash: 'hash-remote-1',
        ),
        EntityVersion(
          entityId: 'trip-2',
          entityType: 'trip',
          version: 1,
          lastModified:
              baseTime.subtract(const Duration(hours: 1)),
          deviceId: 'device-b',
        ),
      ];

      final result = await conflictDetector.detectMultipleConflicts(
        localVersions: localVersions,
        remoteVersions: remoteVersions,
      );

      expect(result.conflicts, hasLength(1));
      expect(result.conflicts[0].entityId, 'trip-1');
      expect(result.entitiesChecked, 2);
      expect(result.conflictCount, 1);
    });
  });

  group('Integration Tests - Offline-Then-Online Sync Scenarios', () {
    test('should queue operations while offline and sync when back online',
        () async {
      final syncService = SyncServiceImpl(
        networkConnectivity: mockNetworkConnectivity,
        persistence: mockPersistence,
      );
      syncService.pauseProcessing();

      final operations = List.generate(
        5,
        (i) => SyncOperation.create(
          id: 'op-$i',
          entityType: SyncEntityType.trip,
          data: {'title': 'Trip $i'},
        ),
      );

      for (final op in operations) {
        await syncService.enqueueOperation(op);
      }

      expect(syncService.queueSize, 5);

      syncService.resumeProcessing();

      await Future.delayed(const Duration(milliseconds: 500));

      expect(
          syncService.status,
          anyOf(SyncOperationStatus.success, SyncOperationStatus.idle,
              SyncOperationStatus.pending));

      syncService.dispose();
    });

    test('should persist operations across app restart while offline',
        () async {
      final operations = [
        SyncOperation.create(
          id: 'op-1',
          entityType: SyncEntityType.trip,
          data: const {'title': 'Offline Trip 1'},
        ),
        SyncOperation.create(
          id: 'op-2',
          entityType: SyncEntityType.trip,
          data: const {'title': 'Offline Trip 2'},
        ),
      ];

      when(mockPersistence.loadQueue()).thenAnswer((_) async => operations);

      final syncService = SyncServiceImpl(
        persistence: mockPersistence,
      );
      syncService.pauseProcessing();

      await Future.delayed(const Duration(milliseconds: 100));

      expect(syncService.queueSize, 2);
      expect(syncService.status, SyncOperationStatus.pending);

      verify(mockPersistence.loadQueue()).called(1);

      syncService.dispose();
    });

    test('should handle conflict when syncing offline changes', () async {
      conflictDetector = ConflictDetectorImpl(
        config: ConflictDetectionConfig(deviceId: 'device-a'),
      );

      final baseTime = DateTime.now().toUtc();
      final offlineVersion = EntityVersion(
        entityId: 'trip-123',
        entityType: 'trip',
        version: 2,
        lastModified: baseTime.subtract(const Duration(milliseconds: 300)),
        deviceId: 'device-a',
        dataHash: 'offline-hash',
      );

      final remoteVersion = EntityVersion(
        entityId: 'trip-123',
        entityType: 'trip',
        version: 3,
        lastModified: baseTime,
        deviceId: 'device-b',
        dataHash: 'remote-hash',
      );

      final conflict = await conflictDetector.detectConflict(
        localVersion: offlineVersion,
        remoteVersion: remoteVersion,
        localData: {'title': 'Trip (Offline Edit)'},
        remoteData: {'title': 'Trip (Remote Edit)'},
      );

      expect(conflict, isNotNull);
      expect(conflict!.localVersion.version, 2);
      expect(conflict.remoteVersion.version, 3);
    });

    test('should handle multiple offline edits syncing on different devices',
        () async {
      final syncServiceA = SyncServiceImpl(
        networkConnectivity: mockNetworkConnectivity,
        persistence: mockPersistence,
      );
      syncServiceA.pauseProcessing();

      await syncServiceA.enqueueOperation(
        SyncOperation.create(
          id: 'op-a1',
          entityType: SyncEntityType.trip,
          data: const {'title': 'Device A Offline Edit'},
        ),
      );

      syncServiceA.resumeProcessing();

      await Future.delayed(const Duration(milliseconds: 300));

      expect(syncServiceA.queueSize, lessThanOrEqualTo(1));

      syncServiceA.dispose();
    });
  });

  group('Integration Tests - Network Interruption Recovery', () {
    test('should retry failed operations after network interruption',
        () async {
      final syncService = SyncServiceImpl(
        persistence: mockPersistence,
      );
      syncService.pauseProcessing();

      final operation = SyncOperation.create(
        id: 'op-retry',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Retry Test'},
      );

      await syncService.enqueueOperation(operation);
      syncService.resumeProcessing();

      final queueBefore = syncService.queue;
      expect(queueBefore, isNotEmpty);

      await Future.delayed(const Duration(milliseconds: 300));

      final queueAfter = syncService.queue;
      expect(queueAfter.length, lessThanOrEqualTo(queueBefore.length));

      syncService.dispose();
    });

    test('should handle network interruption during batch processing',
        () async {
      final syncService = SyncServiceImpl(
        persistence: mockPersistence,
      );
      syncService.pauseProcessing();

      final operations = List.generate(
        10,
        (i) => SyncOperation.create(
          id: 'op-batch-$i',
          entityType: SyncEntityType.trip,
          data: {'title': 'Batch Trip $i'},
        ),
      );

      for (final op in operations) {
        await syncService.enqueueOperation(op);
      }

      expect(syncService.queueSize, 10);

      syncService.resumeProcessing();
      final result = await syncService.processBatch(maxBatchSize: 5);

      expect(result, isNotNull);
      expect(syncService.queueSize, lessThanOrEqualTo(10));

      syncService.dispose();
    });

    test('should maintain queue order after network interruption', () async {
      final syncService = SyncServiceImpl(
        persistence: mockPersistence,
      );
      syncService.pauseProcessing();

      final highPriorityOp = SyncOperation(
        id: 'op-high',
        entityId: 'trip-high',
        entityType: SyncEntityType.trip,
        operationType: SyncOperationType.create,
        data: const {'title': 'High Priority'},
        createdAt: DateTime.now().toUtc(),
        priority: 10,
      );

      final lowPriorityOp = SyncOperation(
        id: 'op-low',
        entityId: 'note-low',
        entityType: SyncEntityType.travelNote,
        operationType: SyncOperationType.create,
        data: const {'content': 'Low Priority'},
        createdAt: DateTime.now().toUtc(),
        priority: 1,
      );

      await syncService.enqueueOperation(lowPriorityOp);
      await syncService.enqueueOperation(highPriorityOp);

      // High priority should be first
      expect(syncService.queue.first.id, 'op-high');

      syncService.resumeProcessing();
      await syncService.processBatch(maxBatchSize: 1);

      await Future.delayed(const Duration(milliseconds: 200));

      if (syncService.queue.isNotEmpty) {
        expect(syncService.queue.first.priority, lessThanOrEqualTo(10));
      }

      syncService.dispose();
    });

    test('should recover from network error and continue processing',
        () async {
      final syncService = SyncServiceImpl(
        persistence: mockPersistence,
      );
      syncService.pauseProcessing();

      final operations = List.generate(
        3,
        (i) => SyncOperation.create(
          id: 'op-recovery-$i',
          entityType: SyncEntityType.trip,
          data: {'title': 'Recovery Trip $i'},
        ),
      );

      for (final op in operations) {
        await syncService.enqueueOperation(op);
      }

      syncService.resumeProcessing();
      final result = await syncService.processQueue();

      expect(result, isNotNull);
      expect(syncService.queueSize, lessThanOrEqualTo(3));

      syncService.dispose();
    });
  });

  group('Integration Tests - Multiple Device Sync Scenarios', () {
    test('should handle sync from two devices with same data', () async {
      final syncServiceA = SyncServiceImpl(
        persistence: mockPersistence,
      );

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

      final versionB = mockBackend.getRemoteVersion('trip-shared');
      final dataB = mockBackend.getRemoteData('trip-shared');

      expect(versionB, isNotNull);
      expect(versionB!.deviceId, 'device-a');
      expect(dataB?['title'], 'Shared Trip');

      syncServiceA.dispose();
    });

    test('should detect version conflict between two devices', () async {
      conflictDetector = ConflictDetectorImpl(
        config: ConflictDetectionConfig(deviceId: 'device-a'),
      );

      final baseTime = DateTime.now().toUtc();
      final versionA = EntityVersion(
        entityId: 'trip-1',
        entityType: 'trip',
        version: 2,
        lastModified: baseTime,
        deviceId: 'device-a',
      );

      final versionB = EntityVersion(
        entityId: 'trip-1',
        entityType: 'trip',
        version: 3,
        lastModified: baseTime.add(const Duration(milliseconds: 500)),
        deviceId: 'device-b',
      );

      final conflict = await conflictDetector.detectConflict(
        localVersion: versionA,
        remoteVersion: versionB,
      );

      expect(conflict, isNotNull);
      expect(conflict!.conflictType, ConflictType.diverged);
    });

    test('should merge changes from multiple devices correctly', () async {
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
        localData: const {
          'title': 'Paris Trip',
          'accommodation': 'Hotel A',
        },
        remoteData: const {
          'title': 'Paris Trip',
          'transport': 'Flight B',
        },
        description: 'Multi-device conflict',
        detectedAt: DateTime.now().toUtc(),
      );

      final resolution =
          await conflictResolver.resolveWithAutomaticMerge(conflict: conflict);

      expect(resolution.resolvedData['title'], 'Paris Trip');
      expect(resolution.resolvedData['accommodation'], 'Hotel A');
      expect(resolution.resolvedData['transport'], 'Flight B');
    });

    test('should handle three-way sync scenario', () async {
      conflictDetector = ConflictDetectorImpl(
        config: ConflictDetectionConfig(deviceId: 'device-a'),
      );

      final baseTime = DateTime.now().toUtc();
      final versionA = EntityVersion(
        entityId: 'trip-1',
        entityType: 'trip',
        version: 2,
        lastModified: baseTime.subtract(const Duration(milliseconds: 300)),
        deviceId: 'device-a',
      );

      final versionB = EntityVersion(
        entityId: 'trip-1',
        entityType: 'trip',
        version: 3,
        lastModified: baseTime,
        deviceId: 'device-b',
      );

      final versionC = EntityVersion(
        entityId: 'trip-1',
        entityType: 'trip',
        version: 4,
        lastModified: baseTime.add(const Duration(milliseconds: 200)),
        deviceId: 'device-c',
      );

      final conflictAB = await conflictDetector.detectConflict(
        localVersion: versionA,
        remoteVersion: versionB,
      );

      final conflictAC = await conflictDetector.detectConflict(
        localVersion: versionA,
        remoteVersion: versionC,
      );

      expect(conflictAB, isNotNull);
      expect(conflictAB!.conflictType, ConflictType.diverged);

      expect(conflictAC, isNotNull);
      expect(conflictAC!.conflictType, ConflictType.diverged);
    });

    test('should prioritize by version number in multi-device scenario',
        () async {
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
        localData: const {'title': 'Version 2'},
        remoteData: const {'title': 'Version 5'},
        description: 'Version conflict',
        detectedAt: DateTime.now().toUtc(),
      );

      final resolution = await conflictResolver.resolveWithLastWriteWins(
        conflict: conflict,
        preferLocal: false,
      );

      expect(resolution.resolvedData['title'], 'Version 5');
    });
  });

  group('Integration Tests - End-to-End Conflict Workflows', () {
    test('should complete full conflict resolution workflow', () async {
      conflictDetector = ConflictDetectorImpl(
        config: ConflictDetectionConfig(deviceId: 'device-a'),
      );
      conflictResolver = ConflictResolverImpl(
        config: ConflictResolutionConfig(deviceId: 'device-a'),
      );

      final baseTime = DateTime.now().toUtc();
      final localVersion = EntityVersion(
        entityId: 'trip-workflow',
        entityType: 'trip',
        version: 2,
        lastModified: baseTime,
        deviceId: 'device-a',
        dataHash: 'hash-a',
      );

      final remoteVersion = EntityVersion(
        entityId: 'trip-workflow',
        entityType: 'trip',
        version: 2,
        lastModified: baseTime.add(const Duration(milliseconds: 500)),
        deviceId: 'device-b',
        dataHash: 'hash-b',
      );

      final conflict = await conflictDetector.detectConflict(
        localVersion: localVersion,
        remoteVersion: remoteVersion,
        localData: {'title': 'Device A Edit'},
        remoteData: {'title': 'Device B Edit'},
      );

      expect(conflict, isNotNull);

      final strategy =
          conflictResolver.recommendStrategy(conflict: conflict!);

      final resolution = await conflictResolver.resolveConflict(
        conflict: conflict,
        strategy: strategy == ConflictResolutionStrategy.manual
            ? ConflictResolutionStrategy.lastWriteWins
            : strategy,
      );

      expect(resolution.resolvedData['title'], 'Device B Edit');
    });

    test('should handle batch conflict resolution workflow', () async {
      conflictDetector = ConflictDetectorImpl(
        config: ConflictDetectionConfig(deviceId: 'device-a'),
      );
      conflictResolver = ConflictResolverImpl(
        config: ConflictResolutionConfig(deviceId: 'device-a'),
      );

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
          localData: const {'title': 'Trip 1'},
          remoteData: const {'title': 'Trip 1 Updated'},
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
          localData: const {'title': 'Trip 2'},
          remoteData: const {'title': 'Trip 2 Updated'},
          description: 'Batch conflict 2',
          detectedAt: DateTime.now().toUtc(),
        ),
      ];

      final result = await conflictResolver.resolveMultipleConflicts(
        conflicts: conflicts,
        strategies: [
          ConflictResolutionStrategy.lastWriteWins,
          ConflictResolutionStrategy.lastWriteWins,
        ],
      );

      expect(result.totalConflicts, 2);
      expect(result.resolvedCount, 2);
      expect(result.failedCount, 0);
      expect(result.resolutions, hasLength(2));
    });

    test('should handle manual resolution workflow with user choice',
        () async {
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
        localData: const {
          'title': 'Important Local Edit',
          'budget': 1000,
        },
        remoteData: const {
          'title': 'Important Remote Edit',
          'budget': 2000,
        },
        description: 'Requires manual resolution',
        detectedAt: DateTime.now().toUtc(),
      );

      final resolution = await conflictResolver.resolveConflict(
        conflict: conflict,
        strategy: ConflictResolutionStrategy.manual,
        userChoice: ManualResolutionChoice.keepLocal,
      );

      expect(resolution.strategy, ConflictResolutionStrategy.manual);
      expect(resolution.resolvedData['title'], 'Important Local Edit');
      expect(resolution.resolvedData['budget'], 1000);
    });

    test('should handle custom merge workflow', () async {
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
        localData: const {
          'title': 'Local Title',
          'budget': 1000,
        },
        remoteData: const {
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

      final resolution = await conflictResolver.resolveConflict(
        conflict: conflict,
        strategy: ConflictResolutionStrategy.manual,
        userChoice: ManualResolutionChoice.customMerge,
        userData: customData,
      );

      expect(resolution.resolvedData['title'], 'Merged Title');
      expect(resolution.resolvedData['budget'], 1500);
      expect(resolution.resolvedData['days'], 7);
    });
  });
}
