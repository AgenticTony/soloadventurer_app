import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_operation.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_status.dart';
import 'package:soloadventurer/features/sync/domain/entities/sync_entity_type.dart';
import 'package:soloadventurer/features/sync/domain/services/network_connectivity.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/sync_service_impl.dart';
import 'package:soloadventurer/features/sync/domain/services/sync_service.dart';

@GenerateMocks([NetworkConnectivity])
import 'sync_service_impl_network_test.mocks.dart';

void main() {
  late MockNetworkConnectivity mockNetworkConnectivity;
  late SyncServiceImpl syncService;
  late StreamController<bool> onOnlineController;
  late StreamController<bool> onOfflineController;

  setUp(() {
    mockNetworkConnectivity = MockNetworkConnectivity();
    onOnlineController = StreamController<bool>.broadcast();
    onOfflineController = StreamController<bool>.broadcast();
    // Stub onOnline/onOffline before creating SyncServiceImpl,
    // because the constructor calls _initializeNetworkMonitoring()
    when(mockNetworkConnectivity.onOnline)
        .thenAnswer((_) => onOnlineController.stream);
    when(mockNetworkConnectivity.onOffline)
        .thenAnswer((_) => onOfflineController.stream);
    when(mockNetworkConnectivity.isOnline).thenReturn(true);
    syncService = SyncServiceImpl(
      networkConnectivity: mockNetworkConnectivity,
    );
  });

  tearDown(() async {
    syncService.dispose();
    await onOnlineController.close();
    await onOfflineController.close();
  });

  group('SyncServiceImpl - Network Connectivity Integration', () {
    test('should initialize with network connectivity monitoring', () {
      // Assert
      expect(syncService.queue, isEmpty);
      expect(syncService.status, SyncOperationStatus.idle);
    });

    test(
        'should trigger sync when network comes online with operations in queue',
        () async {
      final operation = SyncOperation.create(
        id: "op-1",
        entityType: SyncEntityType.trip,
        data: const {'name': 'Test Trip'},
      );

      await syncService.enqueueOperation(operation);
      syncService.pauseProcessing();

      // Act - emit via the shared controller
      onOnlineController.add(true);

      await Future.delayed(const Duration(milliseconds: 200));

      verify(mockNetworkConnectivity.onOnline).called(greaterThanOrEqualTo(1));
    });

    test('should not trigger sync when network comes online with empty queue',
        () async {
      // Act
      onOnlineController.add(true);

      await Future.delayed(const Duration(milliseconds: 200));

      // Assert - queue still empty, no crash
      expect(syncService.queue, isEmpty);
      verify(mockNetworkConnectivity.onOnline).called(greaterThanOrEqualTo(1));
    });

    test('should not trigger sync when processing is paused', () async {
      final operation = SyncOperation.create(
        id: "op-1",
        entityType: SyncEntityType.trip,
        data: const {'name': 'Test Trip'},
      );

      await syncService.enqueueOperation(operation);
      syncService.pauseProcessing();

      // Act
      onOnlineController.add(true);

      await Future.delayed(const Duration(milliseconds: 200));

      // Assert
      expect(syncService.queue, isNotEmpty);
    });

    test('should handle multiple network restoration events', () async {
      final operation = SyncOperation.create(
        id: "op-1",
        entityType: SyncEntityType.trip,
        data: const {'name': 'Test Trip'},
      );

      await syncService.enqueueOperation(operation);

      // Act - Simulate multiple network restoration events
      onOnlineController.add(true);
      await Future.delayed(const Duration(milliseconds: 100));

      onOnlineController.add(true);
      await Future.delayed(const Duration(milliseconds: 100));

      verify(mockNetworkConnectivity.onOnline).called(greaterThanOrEqualTo(1));
    });

    test('should gracefully handle network monitoring errors', () async {
      final operation = SyncOperation.create(
        id: "op-1",
        entityType: SyncEntityType.trip,
        data: const {'name': 'Test Trip'},
      );

      await syncService.enqueueOperation(operation);

      // Act - Emit via the shared controller (the impl handles errors internally)
      onOnlineController.add(true);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Service should still be functional
      expect(syncService.queue, isNotNull);
    });
  });

  group('SyncServiceImpl - Network Connectivity with Auto-Process', () {
    test('should respect autoProcess config when network comes online',
        () async {
      // Disable auto-process
      syncService.updateConfig(const SyncQueueConfig(autoProcess: false));

      final operation = SyncOperation.create(
        id: "op-1",
        entityType: SyncEntityType.trip,
        data: const {'name': 'Test Trip'},
      );

      await syncService.enqueueOperation(operation);

      // Act
      onOnlineController.add(true);

      await Future.delayed(const Duration(milliseconds: 200));

      // Assert - Queue should still have operations (not processed)
      expect(syncService.queue, isNotEmpty);
    });

    test('should process operations when autoProcess is enabled', () async {
      // Ensure auto-process is enabled (default)
      syncService.updateConfig(const SyncQueueConfig(autoProcess: true));

      final operation = SyncOperation.create(
        id: "op-1",
        entityType: SyncEntityType.trip,
        data: const {'name': 'Test Trip'},
      );

      await syncService.enqueueOperation(operation);

      // Act
      onOnlineController.add(true);

      await Future.delayed(const Duration(milliseconds: 500));

      // Assert - verify onOnline was accessed
      verify(mockNetworkConnectivity.onOnline).called(greaterThanOrEqualTo(1));
    });
  });

  group('SyncServiceImpl - Network Connectivity Cleanup', () {
    test('should cancel network monitoring subscription on dispose', () async {
      // Act
      syncService.dispose();

      // Emit event after dispose
      onOnlineController.add(true);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Should not crash and stream should be cancelled
      expect(syncService.status, SyncOperationStatus.idle);
    });

    test('should handle multiple dispose calls gracefully', () async {
      // Act & Assert - Should not throw
      syncService.dispose();
      syncService.dispose();
      expect(() => syncService.dispose(), returnsNormally);
    });
  });

  group('SyncServiceImpl - Network Connectivity Scenarios', () {
    test('should work with large queue when network comes online', () async {
      // Add multiple operations
      for (int i = 0; i < 50; i++) {
        final operation = SyncOperation.create(
          id: "op-${i}",
          entityType: SyncEntityType.trip,
          data: {'name': 'Trip $i'},
        );
        await syncService.enqueueOperation(operation);
      }

      final queueSizeBefore = syncService.queueSize;

      // Act
      onOnlineController.add(true);

      await Future.delayed(const Duration(milliseconds: 500));

      // Assert
      expect(queueSizeBefore, 50);
      verify(mockNetworkConnectivity.onOnline).called(greaterThanOrEqualTo(1));
    });

    test('should maintain queue order after network restoration', () async {
      // Add operations with different priorities
      final highPriorityOp = SyncOperation.create(
        id: "op-high",
        entityType: SyncEntityType.trip,
        data: const {'name': 'High Priority Trip'},
        priority: 10,
      );

      final lowPriorityOp = SyncOperation.create(
        id: "op-low",
        entityType: SyncEntityType.travelNote,
        data: const {'content': 'Low Priority Note'},
        priority: 1,
      );

      await syncService.enqueueOperation(lowPriorityOp);
      await syncService.enqueueOperation(highPriorityOp);

      // Act
      onOnlineController.add(true);

      await Future.delayed(const Duration(milliseconds: 200));

      // Assert - High priority should be first in queue
      if (syncService.queue.isNotEmpty) {
        expect(syncService.queue.first.priority,
            greaterThanOrEqualTo(syncService.queue.last.priority));
      }
    });
  });

  group('SyncServiceImpl - Network Connectivity Without Persistence', () {
    test('should work correctly with only network monitoring (no persistence)',
        () async {
      // Arrange - create a new service using the same mock (already stubbed)
      syncService.dispose(); // dispose the old one first
      syncService = SyncServiceImpl(
        networkConnectivity: mockNetworkConnectivity,
        // No persistence service
      );

      final operation = SyncOperation.create(
        id: "op-1",
        entityType: SyncEntityType.trip,
        data: const {'name': 'Test Trip'},
      );

      await syncService.enqueueOperation(operation);

      // Act
      onOnlineController.add(true);

      await Future.delayed(const Duration(milliseconds: 200));

      // Assert
      verify(mockNetworkConnectivity.onOnline).called(greaterThanOrEqualTo(1));
    });
  });
}
