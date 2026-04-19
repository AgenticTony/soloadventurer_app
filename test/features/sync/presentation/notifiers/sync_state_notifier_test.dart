import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_operation.dart';
import 'package:soloadventurer/features/sync/domain/entities/sync_entity_type.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_status.dart';
import 'package:soloadventurer/features/sync/domain/services/sync_service.dart';
import 'package:soloadventurer/features/sync/presentation/notifiers/sync_state_notifier.dart';
import 'package:soloadventurer/features/sync/presentation/providers/service_providers.dart';
import 'package:soloadventurer/features/sync/presentation/state/sync_state.dart';
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';

import 'sync_state_notifier_test.mocks.dart';

@GenerateMocks([SyncService, LoggingService])
void main() {
  late MockSyncService mockSyncService;
  late MockLoggingService mockLogger;
  late StreamController<SyncOperationStatus> statusController;
  late StreamController<List<SyncOperation>> queueController;
  late ProviderContainer container;
  ProviderSubscription<AsyncValue<SyncState>>? subscription;

  setUp(() {
    mockSyncService = MockSyncService();
    mockLogger = MockLoggingService();
    statusController = StreamController<SyncOperationStatus>.broadcast();
    queueController = StreamController<List<SyncOperation>>.broadcast();

    // Setup mock service defaults
    when(mockSyncService.status).thenReturn(SyncOperationStatus.idle);
    when(mockSyncService.statusStream)
        .thenAnswer((_) => statusController.stream);
    when(mockSyncService.queueStream)
        .thenAnswer((_) => queueController.stream);
    when(mockSyncService.queueSize).thenReturn(0);
    when(mockSyncService.isProcessing).thenReturn(false);

    container = ProviderContainer.test(
      retry: (_, __) => null,
      overrides: [
        syncServiceProvider.overrideWithValue(mockSyncService),
        loggingServiceProvider.overrideWithValue(mockLogger),
      ],
    );
  });

  tearDown(() {
    subscription?.close();
    subscription = null;
    statusController.close();
    queueController.close();
    container.dispose();
  });

  /// Helper to get the notifier from the container.
  /// Uses listen to ensure the provider is not paused.
  SyncStateNotifier getNotifier() {
    subscription ??= container.listen<AsyncValue<SyncState>>(
      syncStateProvider,
      (_, __) {},
      fireImmediately: true,
    );
    return container.read(syncStateProvider.notifier);
  }

  /// Helper to get the current state (unwrapped from AsyncValue).
  /// Ensures provider is active before reading.
  SyncState getState() {
    // Ensure provider is active before reading
    getNotifier();
    return container.read(syncStateProvider).value ??
        SyncState.initial();
  }

  group('SyncStateNotifier', () {
    group('Initialization', () {
      test('creates with initial state', () async {
        // Allow async build to complete
        await container.pump();
        final state = getState();

        expect(state.status, SyncOperationStatus.idle);
        expect(state.queueSize, 0);
      });

      test('initializes with current service state', () async {
        when(mockSyncService.status).thenReturn(SyncOperationStatus.syncing);
        when(mockSyncService.queueSize).thenReturn(5);
        when(mockSyncService.isProcessing).thenReturn(true);

        // Create a new container to pick up the new mock values
        final newContainer = ProviderContainer.test(
          retry: (_, __) => null,
          overrides: [
            syncServiceProvider.overrideWithValue(mockSyncService),
            loggingServiceProvider.overrideWithValue(mockLogger),
          ],
        );
        addTearDown(newContainer.dispose);

        // Listen to keep provider active
        final sub = newContainer.listen<AsyncValue<SyncState>>(
          syncStateProvider,
          (_, __) {},
          fireImmediately: true,
        );
        addTearDown(sub.close);

        // Allow async build to complete
        await newContainer.pump();

        final asyncState = newContainer.read(syncStateProvider);
        final state = asyncState.value!;
        expect(state.status, SyncOperationStatus.syncing);
        expect(state.queueSize, 5);
        expect(state.isSyncing, true);
      });

      test('subscribes to status changes on initialization', () async {
        // Access the notifier to trigger build
        await container.pump();
        getNotifier();

        verify(mockSyncService.statusStream);
      });

      test('subscribes to queue changes on initialization', () async {
        // Access the notifier to trigger build
        await container.pump();
        getNotifier();

        verify(mockSyncService.queueStream);
      });
    });

    group('Status Change Handling', () {
      test('updates state when status changes to syncing', () async {
        // Activate the notifier before emitting events
        await container.pump();
        getNotifier();

        statusController.add(SyncOperationStatus.syncing);
        await Future.delayed(const Duration(milliseconds: 10));

        final state = getState();
        expect(state.status, SyncOperationStatus.syncing);
        expect(state.isSyncing, true);
        expect(state.lastStatusChangeAt, isNotNull);
      });

      test('updates state when status changes to success', () async {
        // Activate the notifier before emitting events
        await container.pump();
        getNotifier();

        statusController.add(SyncOperationStatus.syncing);
        await Future.delayed(const Duration(milliseconds: 10));

        when(mockSyncService.queueSize).thenReturn(0);
        statusController.add(SyncOperationStatus.success);
        await Future.delayed(const Duration(milliseconds: 10));

        final state = getState();
        expect(state.status, SyncOperationStatus.success);
        expect(state.wasLastSyncSuccessful, true);
        expect(state.lastSuccessfulSyncAt, isNotNull);
      });

      test('updates state when status changes to failed', () async {
        // Activate the notifier before emitting events
        await container.pump();
        getNotifier();

        // First set queue size so we have a non-zero failure count
        queueController.add([SyncOperation(
          id: 'op-1',
          entityId: 'e1',
          entityType: SyncEntityType.trip,
          operationType: SyncOperationType.create,
          data: const {},
          createdAt: DateTime.now(),
        )]);
        await Future.delayed(const Duration(milliseconds: 10));

        statusController.add(SyncOperationStatus.syncing);
        await Future.delayed(const Duration(milliseconds: 10));

        when(mockSyncService.queueSize).thenReturn(3);
        statusController.add(SyncOperationStatus.failed);
        await Future.delayed(const Duration(milliseconds: 10));

        final state = getState();
        expect(state.status, SyncOperationStatus.failed);
        expect(state.didLastSyncFail, true);
      });

      test('updates state when status changes to pending', () async {
        // Activate the notifier before emitting events
        await container.pump();
        getNotifier();

        statusController.add(SyncOperationStatus.pending);
        await Future.delayed(const Duration(milliseconds: 10));

        final state = getState();
        expect(state.status, SyncOperationStatus.pending);
        expect(state.lastStatusChangeAt, isNotNull);
      });
    });

    group('Queue Change Handling', () {
      test('updates queue size when queue changes', () async {
        // Activate the notifier before emitting events
        await container.pump();
        getNotifier();

        queueController.add(List.generate(
          5,
          (i) => SyncOperation(
            id: 'op-$i',
            entityId: 'e$i',
            entityType: SyncEntityType.trip,
            operationType: SyncOperationType.create,
            data: const {},
            createdAt: DateTime.now(),
          ),
        ));
        await Future.delayed(const Duration(milliseconds: 10));

        final state = getState();
        expect(state.queueSize, 5);
        expect(state.hasPendingOperations, true);
        expect(state.hasQueue, true);
      });

      test('clears pending operations when queue empties', () async {
        when(mockSyncService.queueSize).thenReturn(5);
        when(mockSyncService.status).thenReturn(SyncOperationStatus.pending);

        final newContainer = ProviderContainer.test(
          retry: (_, __) => null,
          overrides: [
            syncServiceProvider.overrideWithValue(mockSyncService),
            loggingServiceProvider.overrideWithValue(mockLogger),
          ],
        );
        addTearDown(newContainer.dispose);

        // Listen to keep provider active
        final sub2 = newContainer.listen<AsyncValue<SyncState>>(
          syncStateProvider,
          (_, __) {},
          fireImmediately: true,
        );
        addTearDown(sub2.close);

        // Allow async build
        await newContainer.pump();

        // Clear queue
        when(mockSyncService.queueSize).thenReturn(0);
        queueController.add([]);
        await Future.delayed(const Duration(milliseconds: 10));

        final asyncState = newContainer.read(syncStateProvider);
        final state = asyncState.value!;
        expect(state.queueSize, 0);
        expect(state.hasPendingOperations, false);
      });

      test('updates to pending status when queue has items and status is idle',
          () async {
        await container.pump();
        final state = getState();
        expect(state.status, SyncOperationStatus.idle);

        queueController.add([SyncOperation(
          id: 'op-1',
          entityId: 'e1',
          entityType: SyncEntityType.trip,
          operationType: SyncOperationType.create,
          data: const {},
          createdAt: DateTime.now(),
        )]);
        await Future.delayed(const Duration(milliseconds: 10));

        final updatedState = getState();
        expect(updatedState.status, SyncOperationStatus.pending);
        expect(updatedState.queueSize, 1);
      });
    });

    group('refresh', () {
      test('refreshes state from current service state', () async {
        when(mockSyncService.status).thenReturn(SyncOperationStatus.syncing);
        when(mockSyncService.queueSize).thenReturn(7);
        when(mockSyncService.isProcessing).thenReturn(true);

        // Create new container with updated mocks
        final newContainer = ProviderContainer.test(
          retry: (_, __) => null,
          overrides: [
            syncServiceProvider.overrideWithValue(mockSyncService),
            loggingServiceProvider.overrideWithValue(mockLogger),
          ],
        );
        addTearDown(newContainer.dispose);

        // Listen to keep provider active
        final sub3 = newContainer.listen<AsyncValue<SyncState>>(
          syncStateProvider,
          (_, __) {},
          fireImmediately: true,
        );
        addTearDown(sub3.close);

        // Allow async build
        await newContainer.pump();

        // Change service state
        when(mockSyncService.status).thenReturn(SyncOperationStatus.success);
        when(mockSyncService.queueSize).thenReturn(0);
        when(mockSyncService.isProcessing).thenReturn(false);

        // Refresh
        newContainer.read(syncStateProvider.notifier).refresh();
        await Future.delayed(const Duration(milliseconds: 10));

        final asyncState = newContainer.read(syncStateProvider);
        final state = asyncState.value!;
        expect(state.status, SyncOperationStatus.success);
        expect(state.queueSize, 0);
      });
    });

    group('reset', () {
      test('resets state to initial', () async {
        // Activate the notifier before emitting events
        await container.pump();
        getNotifier();

        statusController.add(SyncOperationStatus.syncing);
        await Future.delayed(const Duration(milliseconds: 10));

        var state = getState();
        expect(state.status, SyncOperationStatus.syncing);

        getNotifier().reset();
        await Future.delayed(const Duration(milliseconds: 10));

        state = getState();
        expect(state.status, SyncOperationStatus.idle);
        expect(state.queueSize, 0);
      });
    });

    group('Multiple Listeners', () {
      test('multiple listeners receive state updates', () async {
        await container.pump();

        final states1 = <AsyncValue<SyncState>>[];
        final states2 = <AsyncValue<SyncState>>[];

        final subscription1 = container.listen<AsyncValue<SyncState>>(
          syncStateProvider,
          (_, next) => states1.add(next),
          fireImmediately: true,
        );
        final subscription2 = container.listen<AsyncValue<SyncState>>(
          syncStateProvider,
          (_, next) => states2.add(next),
          fireImmediately: true,
        );

        statusController.add(SyncOperationStatus.syncing);
        await Future.delayed(const Duration(milliseconds: 10));

        expect(states1.length, greaterThan(0));
        expect(states2.length, greaterThan(0));
        expect(states1.last.value?.status, SyncOperationStatus.syncing);
        expect(states2.last.value?.status, SyncOperationStatus.syncing);

        subscription1.close();
        subscription2.close();
      });
    });

    group('Error Handling', () {
      test('handles status stream errors gracefully', () async {
        // Access notifier to ensure it's built
        await container.pump();
        getNotifier();

        // Simulate error in status stream
        statusController.addError(Exception('Test error'));

        await Future.delayed(const Duration(milliseconds: 100));

        // Notifier should still be functional
        expect(getState(), isNotNull);
      });

      test('handles queue stream errors gracefully', () async {
        // Access notifier to ensure it's built
        await container.pump();
        getNotifier();

        // Simulate error in queue stream
        queueController.addError(Exception('Queue error'));

        await Future.delayed(const Duration(milliseconds: 100));

        // Notifier should still be functional
        expect(getState(), isNotNull);
      });
    });

    group('Integration Scenarios', () {
      test('handles complete sync cycle', () async {
        await container.pump();

        // Initial state
        expect(getState().status, SyncOperationStatus.idle);

        // Queue changes
        queueController.add([SyncOperation(
          id: 'op-1',
          entityId: 'e1',
          entityType: SyncEntityType.trip,
          operationType: SyncOperationType.create,
          data: const {},
          createdAt: DateTime.now(),
        )]);
        await Future.delayed(const Duration(milliseconds: 10));
        expect(getState().queueSize, 1);
        expect(getState().status, SyncOperationStatus.pending);

        // Sync starts
        statusController.add(SyncOperationStatus.syncing);
        await Future.delayed(const Duration(milliseconds: 10));
        expect(getState().status, SyncOperationStatus.syncing);
        expect(getState().isSyncing, true);

        // Sync succeeds
        when(mockSyncService.queueSize).thenReturn(0);
        statusController.add(SyncOperationStatus.success);
        queueController.add([]);
        await Future.delayed(const Duration(milliseconds: 10));
        expect(getState().status, SyncOperationStatus.success);
        expect(getState().queueSize, 0);
      });

      test('handles failed sync with retry', () async {
        // Activate the notifier before emitting events
        await container.pump();
        getNotifier();

        // Sync starts
        statusController.add(SyncOperationStatus.syncing);
        await Future.delayed(const Duration(milliseconds: 10));

        // Sync fails
        when(mockSyncService.queueSize).thenReturn(5);
        statusController.add(SyncOperationStatus.failed);
        await Future.delayed(const Duration(milliseconds: 10));

        expect(getState().status, SyncOperationStatus.failed);
        expect(getState().didLastSyncFail, true);

        // Retry
        statusController.add(SyncOperationStatus.syncing);
        await Future.delayed(const Duration(milliseconds: 10));

        expect(getState().status, SyncOperationStatus.syncing);
        expect(getState().isSyncing, true);

        // Success on retry
        when(mockSyncService.queueSize).thenReturn(0);
        statusController.add(SyncOperationStatus.success);
        await Future.delayed(const Duration(milliseconds: 10));

        expect(getState().status, SyncOperationStatus.success);
        expect(getState().wasLastSyncSuccessful, true);
      });
    });
  });
}
