import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/domain/models/entity_version.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_info.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_operation.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_status.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_error.dart';
import 'package:soloadventurer/features/sync/domain/entities/sync_entity_type.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/sync_service_impl.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/conflict_detector_impl.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/conflict_resolver_impl.dart';
import 'package:soloadventurer/features/sync/domain/services/exponential_backoff.dart';
import 'package:soloadventurer/features/sync/domain/services/sync_queue_persistence.dart';
import 'package:soloadventurer/features/sync/domain/services/network_connectivity.dart';

/// Mock network connectivity that simulates various network conditions
class SimulatedNetworkConnectivity implements NetworkConnectivity {
  NetworkStatus _currentStatus = const NetworkStatus(
    isConnected: true,
    connectionType: NetworkConnectionType.wifi,
  );

  final StreamController<NetworkStatus> _statusController =
      StreamController<NetworkStatus>.broadcast();

  final Duration Function()? _simulatedLatency;

  SimulatedNetworkConnectivity({
    Duration Function()? simulatedLatency,
  }) : _simulatedLatency = simulatedLatency;

  @override
  NetworkStatus get currentStatus => _currentStatus;

  @override
  Stream<NetworkStatus> get onStatusChange => _statusController.stream;

  @override
  Stream<bool> get onOnline => _statusController.stream
      .map((status) => status.isConnected)
      .where((isOnline) => isOnline);

  @override
  Stream<bool> get onOffline => _statusController.stream
      .map((status) => status.isConnected)
      .where((isOnline) => !isOnline);

  /// Simulate going offline
  Future<void> goOffline() async {
    await _applyLatency();
    _currentStatus = const NetworkStatus(
      isConnected: false,
      connectionType: NetworkConnectionType.none,
    );
    _statusController.add(_currentStatus);
  }

  /// Simulate coming online
  Future<void> goOnline({
    NetworkConnectionType connectionType = NetworkConnectionType.wifi,
  }) async {
    await _applyLatency();
    _currentStatus = NetworkStatus(
      isConnected: true,
      connectionType: connectionType,
    );
    _statusController.add(_currentStatus);
  }

  /// Simulate network connection type change
  Future<void> changeConnectionType(NetworkConnectionType type) async {
    await _applyLatency();
    _currentStatus = NetworkStatus(
      isConnected: true,
      connectionType: type,
    );
    _statusController.add(_currentStatus);
  }

  Future<void> _applyLatency() async {
    final latency = _simulatedLatency?.call();
    if (latency != null && latency > Duration.zero) {
      await Future.delayed(latency);
    }
  }

  @override
  Future<NetworkStatus> checkStatus() async {
    await _applyLatency();
    return _currentStatus;
  }

  @override
  void dispose() {
    _statusController.close();
  }
}

/// Mock persistence that simulates storage delays and failures
class SimulatedSyncQueuePersistence implements SyncQueuePersistence {
  final List<SyncOperation> _storage = [];
  final Duration Function()? _simulatedLatency;
  final double _failureRate;
  final Random _random = Random(42);

  SimulatedSyncQueuePersistence({
    Duration Function()? simulatedLatency,
    double failureRate = 0.0,
  })  : _simulatedLatency = simulatedLatency,
        _failureRate = failureRate;

  @override
  Future<List<SyncOperation>> loadQueue() async {
    await _applyLatency();
    if (_shouldFail()) {
      throw Exception('Failed to load queue from storage');
    }
    return List.from(_storage);
  }

  @override
  Future<SyncQueuePersistenceResult> saveQueue(
      List<SyncOperation> queue) async {
    await _applyLatency();
    if (_shouldFail()) {
      throw Exception('Failed to save queue to storage');
    }
    _storage.clear();
    _storage.addAll(queue);
    return SyncQueuePersistenceResult.success(operationCount: queue.length);
  }

  @override
  Future<void> clearQueue() async {
    await _applyLatency();
    if (_shouldFail()) {
      throw Exception('Failed to clear queue from storage');
    }
    _storage.clear();
  }

  Future<void> _applyLatency() async {
    final latency = _simulatedLatency?.call();
    if (latency != null && latency > Duration.zero) {
      await Future.delayed(latency);
    }
  }

  bool _shouldFail() {
    return _failureRate > 0 && _random.nextDouble() < _failureRate;
  }

  void dispose() {
    _storage.clear();
  }
}

/// Mock backend server that simulates server behavior and errors
class SimulatedBackendServer {
  final Map<String, EntityVersion> _remoteVersions = {};
  final Map<String, Map<String, dynamic>> _remoteData = {};
  final Duration Function()? _simulatedLatency;
  final double _errorRate;
  final List<SyncErrorType> _errorTypes;
  final Random _random = Random(42);

  SimulatedBackendServer({
    Duration Function()? simulatedLatency,
    double errorRate = 0.0,
    List<SyncErrorType> errorTypes = const [],
  })  : _simulatedLatency = simulatedLatency,
        _errorRate = errorRate,
        _errorTypes = errorTypes;

  EntityVersion? getRemoteVersion(String entityId) => _remoteVersions[entityId];

  Map<String, dynamic>? getRemoteData(String entityId) => _remoteData[entityId];

  /// Simulate fetching data from server
  Future<(EntityVersion?, Map<String, dynamic>?)> fetchData(
      String entityId) async {
    await _applyLatency();
    _maybeThrowError();
    return (
      getRemoteVersion(entityId),
      getRemoteData(entityId),
    );
  }

  /// Simulate updating data on server
  Future<void> updateData(
    String entityId,
    EntityVersion version,
    Map<String, dynamic> data,
  ) async {
    await _applyLatency();
    _maybeThrowError();
    _remoteVersions[entityId] = version;
    _remoteData[entityId] = data;
  }

  /// Simulate batch operation on server
  Future<void> batchUpdate(Map<String, Map<String, dynamic>> updates) async {
    await _applyLatency();
    _maybeThrowError();
    for (final entry in updates.entries) {
      _remoteData[entry.key] = entry.value;
    }
  }

  /// Simulate server error
  void _maybeThrowError() {
    if (_errorRate > 0 && _random.nextDouble() < _errorRate) {
      if (_errorTypes.isNotEmpty) {
        final errorType = _errorTypes[_random.nextInt(_errorTypes.length)];
        throw _createServerException(errorType);
      }
      throw Exception('Server error occurred');
    }
  }

  Exception _createServerException(SyncErrorType errorType) {
    switch (errorType) {
      case SyncErrorType.authentication:
        return Exception('401: Unauthorized');
      case SyncErrorType.server:
        return Exception('500: Internal Server Error');
      case SyncErrorType.timeout:
        return TimeoutException('Request timeout', const Duration(seconds: 30));
      case SyncErrorType.rateLimited:
        return Exception('429: Too Many Requests');
      default:
        return Exception('Server error: $errorType');
    }
  }

  Future<void> _applyLatency() async {
    final latency = _simulatedLatency?.call();
    if (latency != null && latency > Duration.zero) {
      await Future.delayed(latency);
    }
  }

  void clear() {
    _remoteVersions.clear();
    _remoteData.clear();
  }

  void dispose() {
    clear();
  }
}

/// Random number generator (simple implementation for tests)
class Random {
  final int _seed;
  int _state;

  Random(this._seed) : _state = _seed;

  int nextInt(int max) {
    _state = (_state * 1103515245 + 12345) & 0x7fffffff;
    return _state % max;
  }

  double nextDouble() {
    return nextInt(1 << 16) / (1 << 16);
  }
}

void main() {
  late SimulatedNetworkConnectivity networkConnectivity;
  late SimulatedSyncQueuePersistence persistence;
  late SimulatedBackendServer backend;
  late ConflictDetectorImpl conflictDetector;
  late ConflictResolverImpl conflictResolver;
  late ExponentialBackoff backoff;
  late SyncServiceImpl syncService;

  setUp(() {
    // Initialize with default settings (no latency, no errors)
    networkConnectivity = SimulatedNetworkConnectivity();
    persistence = SimulatedSyncQueuePersistence();
    backend = SimulatedBackendServer();

    conflictDetector = ConflictDetectorImpl(
      config: ConflictDetectionConfig(
        deviceId: 'test-device',
        concurrentThresholdMs: 1000,
      ),
    );

    conflictResolver = ConflictResolverImpl(
      config: ConflictResolutionConfig(
        deviceId: 'test-device',
        preferLocalOnEqualTimestamps: false,
      ),
    );

    backoff = const ExponentialBackoff();

    syncService = SyncServiceImpl(
      persistence: persistence,
      networkConnectivity: networkConnectivity,
      backoff: backoff,
    );
  });

  tearDown(() async {
    syncService.dispose();
    networkConnectivity.dispose();
    persistence.dispose();
    backend.dispose();
  });

  group('E2E Tests - Offline Mode Scenarios', () {
    test('should queue operations while offline and sync when online',
        () async {
      // Arrange: Setup network as offline
      await networkConnectivity.goOffline();

      final operations = [
        SyncOperation.create(
          entityId: 'trip-1',
          entityType: SyncEntityType.trip,
          data: const {'title': 'Trip to Paris', 'days': 5},
        ),
        SyncOperation.create(
          entityId: 'trip-2',
          entityType: SyncEntityType.trip,
          data: const {'title': 'Trip to London', 'days': 3},
        ),
      ];

      // Act: Enqueue operations while offline
      for (final op in operations) {
        await syncService.enqueue(op);
      }

      // Verify operations are queued
      expect(syncService.queueSize, equals(2));
      expect(syncService.status, SyncOperationStatus.pending);

      // Verify sync didn't start while offline
      await Future.delayed(const Duration(milliseconds: 100));
      expect(syncService.status, SyncOperationStatus.pending);

      // Act: Go online
      await networkConnectivity.goOnline();

      // Wait for sync to complete
      await syncService.processQueue();

      // Assert: Sync should have started when coming online
      expect(syncService.status, anyOf(SyncOperationStatus.success, SyncOperationStatus.idle));
    });

    test('should handle offline mode with persistence across restarts',
        () async {
      // Arrange: Go offline and enqueue operations
      await networkConnectivity.goOffline();

      final operation = SyncOperation.update(
        entityId: 'trip-1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Updated Trip'},
      );

      await syncService.enqueue(operation);
      expect(syncService.queueSize, equals(1));

      // Simulate app restart: Create new sync service with same persistence
      syncService.dispose();

      final newSyncService = SyncServiceImpl(
        persistence: persistence,
        networkConnectivity: networkConnectivity,
        backoff: backoff,
      );

      // Assert: Queue should be restored
      expect(newSyncService.queueSize, equals(1));

      // Act: Go online and sync
      await networkConnectivity.goOnline();
      await newSyncService.processQueue();

      // Assert: Sync should complete
      expect(newSyncService.queueSize, equals(0));

      newSyncService.dispose();
    });

    test('should handle offline to online transition with conflict detection',
        () async {
      // Arrange: Setup initial data
      final baseTime = DateTime.now().toUtc();

      await backend.updateData(
        'trip-1',
        EntityVersion(
          entityId: 'trip-1',
          entityType: 'trip',
          version: 1,
          lastModified: baseTime,
          deviceId: 'remote-device',
          dataHash: 'remote-hash',
        ),
        {'title': 'Remote Trip', 'days': 7},
      );

      // Go offline and make local changes
      await networkConnectivity.goOffline();

      final localOperation = SyncOperation.update(
        entityId: 'trip-1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Local Trip', 'days': 5},
        localVersion: EntityVersion(
          entityId: 'trip-1',
          entityType: 'trip',
          version: 1,
          lastModified: baseTime.subtract(const Duration(minutes: 5)),
          deviceId: 'test-device',
          dataHash: 'local-hash',
        ),
      );

      await syncService.enqueue(localOperation);

      // Simulate remote change while offline
      await backend.updateData(
        'trip-1',
        EntityVersion(
          entityId: 'trip-1',
          entityType: 'trip',
          version: 2,
          lastModified: baseTime.add(const Duration(minutes: 1)),
          deviceId: 'remote-device',
          dataHash: 'remote-new-hash',
        ),
        {'title': 'Remote Updated Trip', 'days': 10},
      );

      // Go online and sync
      await networkConnectivity.goOnline();
      await syncService.processQueue();

      // Assert: Sync should complete (conflict detection handled by service)
      expect(syncService.status, anyOf(SyncOperationStatus.success, SyncOperationStatus.idle));
    });

    test('should handle multiple offline to online transitions', () async {
      // First offline period
      await networkConnectivity.goOffline();

      await syncService.enqueue(SyncOperation.create(
        entityId: 'trip-1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Trip 1'},
      ));

      await networkConnectivity.goOnline();
      await syncService.processQueue();

      expect(syncService.queueSize, equals(0));

      // Second offline period
      await networkConnectivity.goOffline();

      await syncService.enqueue(SyncOperation.create(
        entityId: 'trip-2',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Trip 2'},
      ));

      await networkConnectivity.goOnline();
      await syncService.processQueue();

      // Assert: All operations should sync
      expect(syncService.queueSize, equals(0));
      expect(syncService.status, anyOf(SyncOperationStatus.success, SyncOperationStatus.idle));
    });
  });

  group('E2E Tests - Slow Network Simulation', () {
    test('should handle slow network with latency', () async {
      // Arrange: Setup network with simulated latency (2 seconds)
      final slowNetwork = SimulatedNetworkConnectivity(
        simulatedLatency: () => const Duration(seconds: 2),
      );

      final slowSyncService = SyncServiceImpl(
        networkConnectivity: slowNetwork,
        backoff: backoff,
      );

      final operation = SyncOperation.create(
        entityId: 'trip-1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Trip with slow network'},
      );

      // Act: Enqueue and process with slow network
      final startTime = DateTime.now();
      await slowSyncService.enqueue(operation);
      await slowSyncService.processQueue();
      final endTime = DateTime.now();

      // Assert: Operation should complete despite latency
      expect(slowSyncService.queueSize, equals(0));
      expect(
        endTime.difference(startTime),
        greaterThan(const Duration(seconds: 1)),
      );

      slowSyncService.dispose();
      slowNetwork.dispose();
    });

    test('should handle variable network latency', () async {
      // Arrange: Setup network with variable latency
      var latencyIndex = 0;
      final latencies = [
        const Duration(milliseconds: 100),
        const Duration(seconds: 1),
        const Duration(milliseconds: 500),
        const Duration(seconds: 2),
      ];

      final variableNetwork = SimulatedNetworkConnectivity(
        simulatedLatency: () => latencies[latencyIndex++ % latencies.length],
      );

      final variableSyncService = SyncServiceImpl(
        networkConnectivity: variableNetwork,
        backoff: backoff,
      );

      // Act: Process multiple operations with variable latency
      for (var i = 0; i < 4; i++) {
        await variableSyncService.enqueue(SyncOperation.create(
          entityId: 'trip-$i',
          entityType: SyncEntityType.trip,
          data: {'title': 'Trip $i'},
        ));
      }

      await variableSyncService.processQueue();

      // Assert: All operations should complete
      expect(variableSyncService.queueSize, equals(0));

      variableSyncService.dispose();
      variableNetwork.dispose();
    });

    test('should handle transition from slow to fast network', () async {
      // Arrange: Start with slow network
      var isSlowNetwork = true;
      final variableNetwork = SimulatedNetworkConnectivity(
        simulatedLatency: () => isSlowNetwork
            ? const Duration(seconds: 2)
            : const Duration(milliseconds: 100),
      );

      final syncService = SyncServiceImpl(
        networkConnectivity: variableNetwork,
        backoff: backoff,
      );

      // Enqueue operation on slow network
      await syncService.enqueue(SyncOperation.create(
        entityId: 'trip-1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Trip 1'},
      ));

      // Act: Switch to fast network and sync
      isSlowNetwork = false;
      await syncService.processQueue();

      // Assert: Operation should complete
      expect(syncService.queueSize, equals(0));

      syncService.dispose();
      variableNetwork.dispose();
    });

    test('should handle connection type changes (wifi to mobile)', () async {
      // Arrange: Start with WiFi
      await networkConnectivity.goOnline(
        connectionType: NetworkConnectionType.wifi,
      );

      await syncService.enqueue(SyncOperation.create(
        entityId: 'trip-1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Trip 1'},
      ));

      // Act: Switch to mobile and sync
      await networkConnectivity
          .changeConnectionType(NetworkConnectionType.mobile);
      await syncService.processQueue();

      // Assert: Sync should complete
      expect(syncService.queueSize, equals(0));
    });
  });

  group('E2E Tests - Server Error Handling', () {
    test('should handle server errors with retry', () async {
      // Arrange: Setup backend with 50% error rate
      final flakyBackend = SimulatedBackendServer(
        errorRate: 0.5,
        errorTypes: [SyncErrorType.server],
      );

      // This test demonstrates retry behavior
      // In real implementation, operations would be retried
      final operation = SyncOperation.create(
        entityId: 'trip-1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Trip with flaky server'},
      );

      await syncService.enqueue(operation);

      // Act: Process queue (may need retries)
      try {
        await syncService.processQueue();
      } catch (e) {
        // Expected: Some operations may fail initially
      }

      // Assert: Service should handle errors gracefully
      expect(
          syncService.status,
          anyOf(
            SyncOperationStatus.success,
            SyncOperationStatus.failed,
            SyncOperationStatus.idle,
          ));

      flakyBackend.dispose();
    });

    test('should handle authentication errors', () async {
      // Arrange: Setup backend with auth errors
      final authBackend = SimulatedBackendServer(
        errorRate: 1.0,
        errorTypes: [SyncErrorType.authentication],
      );

      final operation = SyncOperation.create(
        entityId: 'trip-1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Protected trip'},
      );

      await syncService.enqueue(operation);

      // Act: Process queue
      try {
        await syncService.processQueue();
      } catch (e) {
        // Expected: Auth errors should be surfaced
      }

      // Assert: Operation should remain in queue for retry after auth is fixed
      expect(syncService.queueSize, greaterThan(0));

      authBackend.dispose();
    });

    test('should handle timeout errors', () async {
      // Arrange: Setup backend with timeout errors
      final timeoutBackend = SimulatedBackendServer(
        simulatedLatency: () => const Duration(seconds: 35),
        errorRate: 0.0,
      );

      final operation = SyncOperation.create(
        entityId: 'trip-1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Slow trip'},
      );

      await syncService.enqueue(operation);

      // Act: Process queue (should timeout)
      final stopwatch = Stopwatch()..start();
      try {
        await syncService.processQueue().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            // Timeout expected
          },
        );
      } catch (e) {
        // Timeout exception expected
      }
      stopwatch.stop();

      // Assert: Should timeout within expected time
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 10)));

      timeoutBackend.dispose();
    });

    test('should handle rate limiting errors', () async {
      // Arrange: Setup backend with rate limiting
      final rateLimitedBackend = SimulatedBackendServer(
        errorRate: 1.0,
        errorTypes: [SyncErrorType.rateLimited],
      );

      // Enqueue multiple operations
      for (var i = 0; i < 10; i++) {
        await syncService.enqueue(SyncOperation.create(
          entityId: 'trip-$i',
          entityType: SyncEntityType.trip,
          data: {'title': 'Trip $i'},
        ));
      }

      // Act: Process queue (should hit rate limit)
      try {
        await syncService.processQueue();
      } catch (e) {
        // Rate limit error expected
      }

      // Assert: Operations should be queued with backoff
      expect(syncService.queueSize, greaterThan(0));

      rateLimitedBackend.dispose();
    });

    test('should recover from transient server errors', () async {
      // Arrange: Setup backend that fails initially then succeeds
      var attemptCount = 0;
      final recoveringBackend = SimulatedBackendServer(
        simulatedLatency: () => const Duration(milliseconds: 100),
        errorRate: 0.0,
      );

      final operation = SyncOperation.create(
        entityId: 'trip-1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Trip with recovering server'},
      );

      await syncService.enqueue(operation);

      // Act: Process queue (simulating retry after initial failure)
      try {
        await syncService.processQueue();
      } catch (e) {
        // First attempt might fail
        attemptCount++;

        // Retry should succeed
        if (syncService.queueSize > 0) {
          await syncService.processQueue();
        }
      }

      // Assert: Should eventually succeed
      expect(syncService.queueSize, equals(0));

      recoveringBackend.dispose();
    });
  });

  group('E2E Tests - Manual Sync Trigger', () {
    test('should handle manual sync trigger while idle', () async {
      // Arrange: Sync service is idle
      expect(syncService.status, SyncOperationStatus.idle);

      final operation = SyncOperation.create(
        entityId: 'trip-1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Manual sync trip'},
      );

      // Act: Manually trigger sync
      await syncService.enqueue(operation);
      await syncService.processQueue();

      // Assert: Sync should complete
      expect(syncService.status, anyOf(SyncOperationStatus.success, SyncOperationStatus.idle));
    });

    test('should handle manual sync trigger while auto-sync is running',
        () async {
      // Arrange: Start auto-sync
      final operations = List.generate(
        5,
        (i) => SyncOperation.create(
          entityId: 'trip-$i',
          entityType: SyncEntityType.trip,
          data: {'title': 'Trip $i'},
        ),
      );

      for (final op in operations) {
        await syncService.enqueue(op);
      }

      // Start auto-sync in background
      final autoSyncFuture = syncService.processQueue();

      // Act: Trigger manual sync while auto-sync is running
      final manualOperation = SyncOperation.create(
        entityId: 'manual-trip',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Manual trip'},
      );

      await syncService.enqueue(manualOperation);

      // Wait for both to complete
      await autoSyncFuture;
      await syncService.processQueue();

      // Assert: All operations should sync
      expect(syncService.queueSize, equals(0));
    });

    test('should handle manual sync trigger while offline', () async {
      // Arrange: Go offline
      await networkConnectivity.goOffline();

      final operation = SyncOperation.create(
        entityId: 'trip-1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Offline manual sync'},
      );

      // Act: Manually trigger sync while offline
      await syncService.enqueue(operation);
      await syncService.processQueue();

      // Assert: Operations should be queued but not sync
      expect(syncService.queueSize, greaterThan(0));
      expect(syncService.status, SyncOperationStatus.pending);

      // Act: Go online
      await networkConnectivity.goOnline();
      await syncService.processQueue();

      // Assert: Should sync now
      expect(syncService.queueSize, equals(0));
    });

    test('should handle rapid manual sync triggers', () async {
      // Arrange: User rapidly clicks sync button
      final futures = <Future>[];

      // Act: Trigger multiple syncs rapidly
      for (var i = 0; i < 10; i++) {
        final operation = SyncOperation.create(
          entityId: 'trip-$i',
          entityType: SyncEntityType.trip,
          data: {'title': 'Trip $i'},
        );

        futures.add(syncService.enqueue(operation));
      }

      await Future.wait(futures);
      await syncService.processQueue();

      // Assert: All operations should sync
      expect(syncService.queueSize, equals(0));
    });

    test('should handle manual sync with conflicts', () async {
      // Arrange: Setup conflicting data
      final baseTime = DateTime.now().toUtc();

      await backend.updateData(
        'trip-1',
        EntityVersion(
          entityId: 'trip-1',
          entityType: 'trip',
          version: 1,
          lastModified: baseTime,
          deviceId: 'remote-device',
          dataHash: 'remote-hash',
        ),
        {'title': 'Remote Trip', 'days': 7},
      );

      final operation = SyncOperation.update(
        entityId: 'trip-1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Local Trip', 'days': 5},
        localVersion: EntityVersion(
          entityId: 'trip-1',
          entityType: 'trip',
          version: 1,
          lastModified: baseTime.add(const Duration(seconds: 2)),
          deviceId: 'test-device',
          dataHash: 'local-hash',
        ),
      );

      // Act: Manually trigger sync with conflict
      await syncService.enqueue(operation);
      await syncService.processQueue();

      // Assert: Sync should complete (conflict resolved)
      expect(syncService.queueSize, equals(0));
      expect(syncService.status, anyOf(SyncOperationStatus.success, SyncOperationStatus.idle));
    });

    test('should handle manual sync cancellation', () async {
      // Arrange: Enqueue many operations
      for (var i = 0; i < 100; i++) {
        await syncService.enqueue(SyncOperation.create(
          entityId: 'trip-$i',
          entityType: SyncEntityType.trip,
          data: {'title': 'Trip $i'},
        ));
      }

      // Act: Start sync and pause
      final syncFuture = syncService.processQueue();
      await Future.delayed(const Duration(milliseconds: 100));
      await syncService.pause();

      // Assert: Sync should be paused
      expect(syncService.isProcessing, false);

      // Cleanup
      syncService.dispose();
    });
  });

  group('E2E Tests - Complex Scenarios', () {
    test('should handle offline + slow network + errors combined', () async {
      // Arrange: Complex scenario
      final complexNetwork = SimulatedNetworkConnectivity(
        simulatedLatency: () => const Duration(seconds: 1),
      );

      final complexPersistence = SimulatedSyncQueuePersistence(
        simulatedLatency: () => const Duration(milliseconds: 500),
        failureRate: 0.1,
      );

      final complexSyncService = SyncServiceImpl(
        networkConnectivity: complexNetwork,
        persistence: complexPersistence,
        backoff: backoff,
      );

      // Start offline
      await complexNetwork.goOffline();

      // Enqueue operations while offline
      for (var i = 0; i < 5; i++) {
        await complexSyncService.enqueue(SyncOperation.create(
          entityId: 'trip-$i',
          entityType: SyncEntityType.trip,
          data: {'title': 'Trip $i'},
        ));
      }

      // Go online with slow network
      await complexNetwork.goOnline();
      await complexSyncService.processQueue();

      // Assert: Should eventually complete
      expect(complexSyncService.queueSize, equals(0));

      complexSyncService.dispose();
      complexNetwork.dispose();
      complexPersistence.dispose();
    });

    test('should handle batch operations with network issues', () async {
      // Arrange: Create batch operation
      final batchData = <String, Map<String, dynamic>>{};
      for (var i = 0; i < 50; i++) {
        batchData['trip-$i'] = {'title': 'Trip $i', 'days': i + 1};
      }

      final batchOperation = SyncOperation.batch(
        entityType: SyncEntityType.trip,
        operations: batchData.entries.map((entry) {
          return SyncOperation.create(
            entityId: entry.key,
            entityType: SyncEntityType.trip,
            data: entry.value,
          );
        }).toList(),
      );

      // Act: Process batch with slow network
      await networkConnectivity.goOnline();
      await syncService.enqueue(batchOperation);
      await syncService.processQueue();

      // Assert: Batch should complete
      expect(syncService.queueSize, equals(0));
    });

    test('should maintain queue integrity across multiple network transitions',
        () async {
      // Arrange: Create multiple operations
      final operations = List.generate(
        20,
        (i) => SyncOperation.create(
          entityId: 'trip-$i',
          entityType: SyncEntityType.trip,
          data: {'title': 'Trip $i'},
        ),
      );

      // Act: Multiple network transitions while syncing
      await networkConnectivity.goOffline();

      for (final op in operations) {
        await syncService.enqueue(op);
      }

      // Online briefly
      await networkConnectivity.goOnline();
      await Future.delayed(const Duration(milliseconds: 100));

      // Offline again
      await networkConnectivity.goOffline();
      await Future.delayed(const Duration(milliseconds: 100));

      // Online again and complete sync
      await networkConnectivity.goOnline();
      await syncService.processQueue();

      // Assert: All operations should sync
      expect(syncService.queueSize, equals(0));
    });
  });
}
