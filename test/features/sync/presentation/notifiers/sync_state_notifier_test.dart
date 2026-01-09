import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_status.dart';
import 'package:soloadventurer/features/sync/domain/services/sync_service.dart';
import 'package:soloadventurer/features/sync/presentation/notifiers/sync_state_notifier.dart';
import 'package:soloadventurer/features/sync/presentation/state/sync_state.dart';
import 'package:soloadventurer/core/domain/services/logging_service.dart';

@GenerateMocks([SyncService, LoggingService])
import 'sync_state_notifier_test.mocks.dart';

void main() {
  late MockSyncService mockSyncService;
  late MockLoggingService mockLogger;
  late StreamController<SyncStatus> statusController;
  late StreamController<List<dynamic>> queueController;

  setUp(() {
    mockSyncService = MockSyncService();
    mockLogger = MockLoggingService();
    statusController = StreamController<SyncStatus>.broadcast();
    queueController = StreamController<List<dynamic>>.broadcast();

    // Setup mock service defaults
    when(mockSyncService.status).thenReturn(SyncStatus.idle);
    when(mockSyncService.statusStream).thenAnswer((_) => statusController.stream);
    when(mockSyncService.queueStream).thenAnswer((_) => queueController.stream);
    when(mockSyncService.queueSize).thenReturn(0);
    when(mockSyncService.isProcessing).thenReturn(false);
  });

  tearDown(() {
    statusController.close();
    queueController.close();
  });

  group('SyncStateNotifier', () {
    group('Initialization', () {
      test('creates with initial state', () {
        final notifier = SyncStateNotifier(
          syncService: mockSyncService,
          logger: mockLogger,
        );

        expect(notifier.state.status, SyncStatus.idle);
        expect(notifier.state.queueSize, 0);
        expect(notifier.state.isProcessing, false);

        notifier.dispose();
      });

      test('initializes with current service state', () {
        when(mockSyncService.status).thenReturn(SyncStatus.syncing);
        when(mockSyncService.queueSize).thenReturn(5);
        when(mockSyncService.isProcessing).thenReturn(true);

        final notifier = SyncStateNotifier(
          syncService: mockSyncService,
          logger: mockLogger,
        );

        expect(notifier.state.status, SyncStatus.syncing);
        expect(notifier.state.queueSize, 5);
        expect(notifier.state.isProcessing, true);

        notifier.dispose();
      });

      test('subscribes to status changes on initialization', () {
        final notifier = SyncStateNotifier(
          syncService: mockSyncService,
          logger: mockLogger,
        );

        verify(mockSyncService.statusStream).listen(
          any,
          onError: any,
        );

        notifier.dispose();
      });

      test('subscribes to queue changes on initialization', () {
        final notifier = SyncStateNotifier(
          syncService: mockSyncService,
          logger: mockLogger,
        );

        verify(mockSyncService.queueStream).listen(
          any,
          onError: any,
        );

        notifier.dispose();
      });
    });

    group('Status Change Handling', () {
      test('updates state when status changes to syncing', () async {
        final notifier = SyncStateNotifier(
          syncService: mockSyncService,
          logger: mockLogger,
        );

        statusController.add(SyncStatus.syncing);

        await Future.delayed(const Duration(milliseconds: 10));

        expect(notifier.state.status, SyncStatus.syncing);
        expect(notifier.state.isProcessing, true);
        expect(notifier.state.isSyncing, true);
        expect(notifier.state.lastStatusChangeAt, isNotNull);

        notifier.dispose();
      });

      test('updates state when status changes to success', () async {
        final notifier = SyncStateNotifier(
          syncService: mockSyncService,
          logger: mockLogger,
        );

        statusController.add(SyncStatus.syncing);
        await Future.delayed(const Duration(milliseconds: 10));

        when(mockSyncService.queueSize).thenReturn(0);
        statusController.add(SyncStatus.success);
        await Future.delayed(const Duration(milliseconds: 10));

        expect(notifier.state.status, SyncStatus.success);
        expect(notifier.state.isProcessing, false);
        expect(notifier.state.wasLastSyncSuccessful, true);
        expect(notifier.state.lastSuccessfulSyncAt, isNotNull);
        expect(notifier.state.lastError, isNull);

        notifier.dispose();
      });

      test('updates state when status changes to failed', () async {
        final notifier = SyncStateNotifier(
          syncService: mockSyncService,
          logger: mockLogger,
        );

        statusController.add(SyncStatus.syncing);
        await Future.delayed(const Duration(milliseconds: 10));

        when(mockSyncService.queueSize).thenReturn(3);
        statusController.add(SyncStatus.failed);
        await Future.delayed(const Duration(milliseconds: 10));

        expect(notifier.state.status, SyncStatus.failed);
        expect(notifier.state.isProcessing, false);
        expect(notifier.state.didLastSyncFail, true);
        expect(notifier.state.lastError, isNotNull);
        expect(notifier.state.lastFailureCount, 3);

        notifier.dispose();
      });

      test('updates state when status changes to pending', () async {
        final notifier = SyncStateNotifier(
          syncService: mockSyncService,
          logger: mockLogger,
        );

        statusController.add(SyncStatus.pending);
        await Future.delayed(const Duration(milliseconds: 10));

        expect(notifier.state.status, SyncStatus.pending);
        expect(notifier.state.lastStatusChangeAt, isNotNull);

        notifier.dispose();
      });
    });

    group('Queue Change Handling', () {
      test('updates queue size when queue changes', () async {
        final notifier = SyncStateNotifier(
          syncService: mockSyncService,
          logger: mockLogger,
        );

        queueController.add(List.generate(5, (i) => i));
        await Future.delayed(const Duration(milliseconds: 10));

        expect(notifier.state.queueSize, 5);
        expect(notifier.state.hasPendingOperations, true);
        expect(notifier.state.hasQueue, true);

        notifier.dispose();
      });

      test('clears pending operations when queue empties', () async {
        when(mockSyncService.queueSize).thenReturn(5);
        when(mockSyncService.status).thenReturn(SyncStatus.pending);

        final notifier = SyncStateNotifier(
          syncService: mockSyncService,
          logger: mockLogger,
        );

        // Start with pending status
        expect(notifier.state.status, SyncStatus.pending);

        // Clear queue
        when(mockSyncService.queueSize).thenReturn(0);
        queueController.add([]);
        await Future.delayed(const Duration(milliseconds: 10));

        expect(notifier.state.queueSize, 0);
        expect(notifier.state.hasPendingOperations, false);

        notifier.dispose();
      });

      test('updates to pending status when queue has items and status is idle', () async {
        final notifier = SyncStateNotifier(
          syncService: mockSyncService,
          logger: mockLogger,
        );

        expect(notifier.state.status, SyncStatus.idle);

        queueController.add([1, 2, 3]);
        await Future.delayed(const Duration(milliseconds: 10));

        expect(notifier.state.status, SyncStatus.pending);
        expect(notifier.state.queueSize, 3);

        notifier.dispose();
      });
    });

    group('refresh', () {
      test('refreshes state from current service state', () async {
        when(mockSyncService.status).thenReturn(SyncStatus.syncing);
        when(mockSyncService.queueSize).thenReturn(7);
        when(mockSyncService.isProcessing).thenReturn(true);

        final notifier = SyncStateNotifier(
          syncService: mockSyncService,
          logger: mockLogger,
        );

        // Change service state
        when(mockSyncService.status).thenReturn(SyncStatus.success);
        when(mockSyncService.queueSize).thenReturn(0);
        when(mockSyncService.isProcessing).thenReturn(false);

        // Refresh
        notifier.refresh();
        await Future.delayed(const Duration(milliseconds: 10));

        expect(notifier.state.status, SyncStatus.success);
        expect(notifier.state.queueSize, 0);
        expect(notifier.state.isProcessing, false);

        notifier.dispose();
      });
    });

    group('reset', () {
      test('resets state to initial', () async {
        final notifier = SyncStateNotifier(
          syncService: mockSyncService,
          logger: mockLogger,
        );

        statusController.add(SyncStatus.syncing);
        await Future.delayed(const Duration(milliseconds: 10));

        expect(notifier.state.status, SyncStatus.syncing);

        notifier.reset();

        expect(notifier.state.status, SyncStatus.idle);
        expect(notifier.state.queueSize, 0);
        expect(notifier.state.isProcessing, false);

        notifier.dispose();
      });
    });

    group('Multiple Listeners', () {
      test('multiple listeners receive state updates', () async {
        final notifier = SyncStateNotifier(
          syncService: mockSyncService,
          logger: mockLogger,
        );

        final states1 = <SyncState>[];
        final states2 = <SyncState>[];

        final subscription1 = notifier.stream.listen(states1.add);
        final subscription2 = notifier.stream.listen(states2.add);

        statusController.add(SyncStatus.syncing);
        await Future.delayed(const Duration(milliseconds: 10));

        expect(states1.length, greaterThan(0));
        expect(states2.length, greaterThan(0));
        expect(states1.last.status, SyncStatus.syncing);
        expect(states2.last.status, SyncStatus.syncing);

        await subscription1.cancel();
        await subscription2.cancel();
        notifier.dispose();
      });
    });

    group('Error Handling', () {
      test('handles status stream errors gracefully', () async {
        final notifier = SyncStateNotifier(
          syncService: mockSyncService,
          logger: mockLogger,
        );

        // Simulate error in status stream
        statusController.addError(Exception('Test error'));

        await Future.delayed(const Duration(milliseconds: 100));

        // Notifier should still be functional
        expect(notifier.state, isNotNull);

        notifier.dispose();
      });

      test('handles queue stream errors gracefully', () async {
        final notifier = SyncStateNotifier(
          syncService: mockSyncService,
          logger: mockLogger,
        );

        // Simulate error in queue stream
        queueController.addError(Exception('Queue error'));

        await Future.delayed(const Duration(milliseconds: 100));

        // Notifier should still be functional
        expect(notifier.state, isNotNull);

        notifier.dispose();
      });
    });

    group('Disposal', () {
      test('disposes subscriptions', () {
        final notifier = SyncStateNotifier(
          syncService: mockSyncService,
          logger: mockLogger,
        );

        expect(notifier.state, isNotNull);

        notifier.dispose();

        // Should not throw after disposal
        expect(() => notifier.dispose(), returnsNormally);
      });
    });

    group('Integration Scenarios', () {
      test('handles complete sync cycle', () async {
        final notifier = SyncStateNotifier(
          syncService: mockSyncService,
          logger: mockLogger,
        );

        // Initial state
        expect(notifier.state.status, SyncStatus.idle);

        // Queue changes
        queueController.add([1, 2, 3]);
        await Future.delayed(const Duration(milliseconds: 10));
        expect(notifier.state.queueSize, 3);
        expect(notifier.state.status, SyncStatus.pending);

        // Sync starts
        statusController.add(SyncStatus.syncing);
        await Future.delayed(const Duration(milliseconds: 10));
        expect(notifier.state.status, SyncStatus.syncing);
        expect(notifier.state.isProcessing, true);

        // Sync succeeds
        when(mockSyncService.queueSize).thenReturn(0);
        statusController.add(SyncStatus.success);
        queueController.add([]);
        await Future.delayed(const Duration(milliseconds: 10));
        expect(notifier.state.status, SyncStatus.success);
        expect(notifier.state.queueSize, 0);
        expect(notifier.state.isProcessing, false);

        notifier.dispose();
      });

      test('handles failed sync with retry', () async {
        final notifier = SyncStateNotifier(
          syncService: mockSyncService,
          logger: mockLogger,
        );

        // Sync starts
        statusController.add(SyncStatus.syncing);
        await Future.delayed(const Duration(milliseconds: 10));

        // Sync fails
        when(mockSyncService.queueSize).thenReturn(5);
        statusController.add(SyncStatus.failed);
        await Future.delayed(const Duration(milliseconds: 10));

        expect(notifier.state.status, SyncStatus.failed);
        expect(notifier.state.lastError, isNotNull);
        expect(notifier.state.didLastSyncFail, true);

        // Retry
        statusController.add(SyncStatus.syncing);
        await Future.delayed(const Duration(milliseconds: 10));

        expect(notifier.state.status, SyncStatus.syncing);
        expect(notifier.state.isProcessing, true);

        // Success on retry
        when(mockSyncService.queueSize).thenReturn(0);
        statusController.add(SyncStatus.success);
        await Future.delayed(const Duration(milliseconds: 10));

        expect(notifier.state.status, SyncStatus.success);
        expect(notifier.state.wasLastSyncSuccessful, true);
        expect(notifier.state.lastError, isNull);

        notifier.dispose();
      });
    });
  });
}
