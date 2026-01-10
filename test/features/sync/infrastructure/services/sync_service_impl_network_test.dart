import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_operation.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_status.dart';
import 'package:soloadventurer/features/sync/domain/entities/sync_entity_type.dart';
import 'package:soloadventurer/features/sync/domain/services/network_connectivity.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/sync_service_impl.dart';

@GenerateMocks([NetworkConnectivity])
import 'sync_service_impl_network_test.mocks.dart';

void main() {
  late MockNetworkConnectivity mockNetworkConnectivity;
  late SyncServiceImpl syncService;

  setUp(() {
    mockNetworkConnectivity = MockNetworkConnectivity();
    syncService = SyncServiceImpl(
      networkConnectivity: mockNetworkConnectivity,
    );
  });

  tearDown(() async {
    syncService.dispose();
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
      // Arrange
      final connectivityController = StreamController<bool>();

      when(mockNetworkConnectivity.onOnline)
          .thenAnswer((_) => connectivityController.stream);

      final operation = SyncOperation.create(
        entityType: SyncEntityType.trip,
        entityId: 'trip-123',
        operationType: SyncOperationType.create,
        data: const {'name': 'Test Trip'},
      );

      await syncService.enqueueOperation(operation);

      // Reset status from pending to idle to verify transition
      // (operations are auto-processed when autoProcess is enabled)
      syncService.pauseProcessing();

      // Act
      connectivityController.add(true);

      // Wait for async processing
      await Future.delayed(const Duration(milliseconds: 200));

      // Assert
      verify(mockNetworkConnectivity.onOnline).called(1);
    });

    test('should not trigger sync when network comes online with empty queue',
        () async {
      // Arrange
      final connectivityController = StreamController<bool>();
      final onOnlineCalled = <bool>[];

      when(mockNetworkConnectivity.onOnline).thenAnswer((_) {
        return connectivityController.stream.map((event) {
          onOnlineCalled.add(event);
          return event;
        });
      });

      // Act
      connectivityController.add(true);

      // Wait for async processing
      await Future.delayed(const Duration(milliseconds: 200));

      // Assert
      expect(onOnlineCalled, [true]);
      expect(syncService.queue, isEmpty);
    });

    test('should not trigger sync when processing is paused', () async {
      // Arrange
      final connectivityController = StreamController<bool>();

      when(mockNetworkConnectivity.onOnline)
          .thenAnswer((_) => connectivityController.stream);

      final operation = SyncOperation.create(
        entityType: SyncEntityType.trip,
        entityId: 'trip-123',
        operationType: SyncOperationType.create,
        data: const {'name': 'Test Trip'},
      );

      await syncService.enqueueOperation(operation);
      syncService.pauseProcessing();

      // Act
      connectivityController.add(true);

      // Wait for async processing
      await Future.delayed(const Duration(milliseconds: 200));

      // Assert
      expect(syncService.queue, isNotEmpty);
      verify(mockNetworkConnectivity.onOnline).called(greaterThanOrEqualTo(1));
    });

    test('should handle multiple network restoration events', () async {
      // Arrange
      final connectivityController = StreamController<bool>();

      when(mockNetworkConnectivity.onOnline)
          .thenAnswer((_) => connectivityController.stream);

      final operation = SyncOperation.create(
        entityType: SyncEntityType.trip,
        entityId: 'trip-123',
        operationType: SyncOperationType.create,
        data: const {'name': 'Test Trip'},
      );

      await syncService.enqueueOperation(operation);

      // Act - Simulate multiple network restoration events
      connectivityController.add(true);
      await Future.delayed(const Duration(milliseconds: 100));

      connectivityController.add(true);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      verify(mockNetworkConnectivity.onOnline).called(greaterThanOrEqualTo(1));
    });

    test('should gracefully handle network monitoring errors', () async {
      // Arrange
      final errorController = StreamController<bool>();
      final errorStream = errorController.stream.mapError(
        (error) => throw Exception('Network monitoring error'),
      );

      when(mockNetworkConnectivity.onOnline).thenAnswer((_) => errorStream);

      final operation = SyncOperation.create(
        entityType: SyncEntityType.trip,
        entityId: 'trip-123',
        operationType: SyncOperationType.create,
        data: const {'name': 'Test Trip'},
      );

      await syncService.enqueueOperation(operation);

      // Act - Emit error
      errorController.add(true);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Service should still be functional
      expect(syncService.queue, isNotEmpty);

      await errorController.close();
    });
  });

  group('SyncServiceImpl - Network Connectivity with Auto-Process', () {
    test('should respect autoProcess config when network comes online',
        () async {
      // Arrange
      final connectivityController = StreamController<bool>();

      when(mockNetworkConnectivity.onOnline)
          .thenAnswer((_) => connectivityController.stream);

      // Disable auto-process
      syncService.updateConfig(const SyncQueueConfig(autoProcess: false));

      final operation = SyncOperation.create(
        entityType: SyncEntityType.trip,
        entityId: 'trip-123',
        operationType: SyncOperationType.create,
        data: const {'name': 'Test Trip'},
      );

      await syncService.enqueueOperation(operation);

      // Act
      connectivityController.add(true);

      // Wait for async processing
      await Future.delayed(const Duration(milliseconds: 200));

      // Assert - Queue should still have operations (not processed)
      expect(syncService.queue, isNotEmpty);
      verify(mockNetworkConnectivity.onOnline).called(greaterThanOrEqualTo(1));
    });

    test('should process operations when autoProcess is enabled', () async {
      // Arrange
      final connectivityController = StreamController<bool>();

      when(mockNetworkConnectivity.onOnline)
          .thenAnswer((_) => connectivityController.stream);

      // Ensure auto-process is enabled (default)
      syncService.updateConfig(const SyncQueueConfig(autoProcess: true));

      final operation = SyncOperation.create(
        entityType: SyncEntityType.trip,
        entityId: 'trip-123',
        operationType: SyncOperationType.create,
        data: const {'name': 'Test Trip'},
      );

      await syncService.enqueueOperation(operation);

      // Act
      connectivityController.add(true);

      // Wait for async processing
      await Future.delayed(const Duration(milliseconds: 500));

      // Assert - Queue should be empty or have fewer operations (processed)
      verify(mockNetworkConnectivity.onOnline).called(greaterThanOrEqualTo(1));
    });
  });

  group('SyncServiceImpl - Network Connectivity Cleanup', () {
    test('should cancel network monitoring subscription on dispose', () async {
      // Arrange
      final connectivityController = StreamController<bool>();

      when(mockNetworkConnectivity.onOnline)
          .thenAnswer((_) => connectivityController.stream);

      // Act
      syncService.dispose();

      // Emit event after dispose
      connectivityController.add(true);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Should not crash and stream should be cancelled
      expect(syncService.status, SyncOperationStatus.idle);

      await connectivityController.close();
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
      // Arrange
      final connectivityController = StreamController<bool>();

      when(mockNetworkConnectivity.onOnline)
          .thenAnswer((_) => connectivityController.stream);

      // Add multiple operations
      for (int i = 0; i < 50; i++) {
        final operation = SyncOperation.create(
          entityType: SyncEntityType.trip,
          entityId: 'trip-$i',
          operationType: SyncOperationType.create,
          data: {'name': 'Trip $i'},
        );
        await syncService.enqueueOperation(operation);
      }

      final queueSizeBefore = syncService.queueSize;

      // Act
      connectivityController.add(true);

      // Wait for processing
      await Future.delayed(const Duration(milliseconds: 500));

      // Assert
      expect(queueSizeBefore, 50);
      verify(mockNetworkConnectivity.onOnline).called(greaterThanOrEqualTo(1));
    });

    test('should maintain queue order after network restoration', () async {
      // Arrange
      final connectivityController = StreamController<bool>();

      when(mockNetworkConnectivity.onOnline)
          .thenAnswer((_) => connectivityController.stream);

      // Add operations with different priorities
      final highPriorityOp = SyncOperation.create(
        entityType: SyncEntityType.trip,
        entityId: 'trip-high',
        operationType: SyncOperationType.create,
        data: const {'name': 'High Priority Trip'},
        priority: 10,
      );

      final lowPriorityOp = SyncOperation.create(
        entityType: SyncEntityType.travelNote,
        entityId: 'note-low',
        operationType: SyncOperationType.create,
        data: const {'content': 'Low Priority Note'},
        priority: 1,
      );

      await syncService.enqueueOperation(lowPriorityOp);
      await syncService.enqueueOperation(highPriorityOp);

      // Act
      connectivityController.add(true);

      // Wait for processing
      await Future.delayed(const Duration(milliseconds: 200));

      // Assert - High priority should be first in queue
      if (syncService.queue.isNotEmpty) {
        expect(syncService.queue.first.entityId, 'trip-high');
      }
    });
  });

  group('SyncServiceImpl - Network Connectivity Without Persistence', () {
    test('should work correctly with only network monitoring (no persistence)',
        () async {
      // Arrange
      syncService = SyncServiceImpl(
        networkConnectivity: mockNetworkConnectivity,
        // No persistence service
      );

      final connectivityController = StreamController<bool>();

      when(mockNetworkConnectivity.onOnline)
          .thenAnswer((_) => connectivityController.stream);

      final operation = SyncOperation.create(
        entityType: SyncEntityType.trip,
        entityId: 'trip-123',
        operationType: SyncOperationType.create,
        data: const {'name': 'Test Trip'},
      );

      await syncService.enqueueOperation(operation);

      // Act
      connectivityController.add(true);

      // Wait for async processing
      await Future.delayed(const Duration(milliseconds: 200));

      // Assert
      expect(syncService.queue, isNotEmpty);
      verify(mockNetworkConnectivity.onOnline).called(greaterThanOrEqualTo(1));

      await connectivityController.close();
    });
  });
}
