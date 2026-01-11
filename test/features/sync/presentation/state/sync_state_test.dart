import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_status.dart';
import 'package:soloadventurer/features/sync/presentation/state/sync_state.dart';

void main() {
  group('SyncState', () {
    group('Factory Constructors', () {
      test('initial() creates correct initial state', () {
        final state = SyncState.initial();

        expect(state.status, SyncOperationStatus.idle);
        expect(state.queueSize, 0);
        expect(state.isProcessing, false);
        expect(state.lastStatusChangeAt, isNull);
        expect(state.lastSuccessfulSyncAt, isNull);
        expect(state.lastSuccessCount, 0);
        expect(state.lastFailureCount, 0);
        expect(state.lastError, isNull);
        expect(state.hasPendingOperations, false);
      });

      test('initial() has correct computed properties', () {
        final state = SyncState.initial();

        expect(state.isSyncing, false);
        expect(state.wasLastSyncSuccessful, false);
        expect(state.didLastSyncFail, false);
        expect(state.hasQueue, false);
        expect(state.lastTotalOperations, 0);
        expect(state.lastSuccessRate, isNull);
      });
    });

    group('Computed Properties', () {
      test('isSyncing is true only when status is syncing', () {
        const idleState = SyncState(status: SyncOperationStatus.idle);
        const syncingState = SyncState(status: SyncOperationStatus.syncing);
        const successState = SyncState(status: SyncOperationStatus.success);
        const failedState = SyncState(status: SyncOperationStatus.failed);
        const pendingState = SyncState(status: SyncOperationStatus.pending);

        expect(idleState.isSyncing, false);
        expect(syncingState.isSyncing, true);
        expect(successState.isSyncing, false);
        expect(failedState.isSyncing, false);
        expect(pendingState.isSyncing, false);
      });

      test('wasLastSyncSuccessful is true only when status is success', () {
        const successState = SyncState(status: SyncOperationStatus.success);
        const failedState = SyncState(status: SyncOperationStatus.failed);
        const idleState = SyncState(status: SyncOperationStatus.idle);

        expect(successState.wasLastSyncSuccessful, true);
        expect(failedState.wasLastSyncSuccessful, false);
        expect(idleState.wasLastSyncSuccessful, false);
      });

      test('didLastSyncFail is true only when status is failed', () {
        const failedState = SyncState(status: SyncOperationStatus.failed);
        const successState = SyncState(status: SyncOperationStatus.success);
        const idleState = SyncState(status: SyncOperationStatus.idle);

        expect(failedState.didLastSyncFail, true);
        expect(successState.didLastSyncFail, false);
        expect(idleState.didLastSyncFail, false);
      });

      test('hasQueue is true only when queueSize > 0', () {
        const emptyState =
            SyncState(status: SyncOperationStatus.idle, queueSize: 0);
        const queueState =
            SyncState(status: SyncOperationStatus.idle, queueSize: 5);

        expect(emptyState.hasQueue, false);
        expect(queueState.hasQueue, true);
      });

      test('lastTotalOperations is sum of success and failure counts', () {
        const state = SyncState(
          status: SyncOperationStatus.success,
          lastSuccessCount: 8,
          lastFailureCount: 2,
        );

        expect(state.lastTotalOperations, 10);
      });

      test('lastSuccessRate is correctly calculated', () {
        const allSuccessState = SyncState(
          status: SyncOperationStatus.success,
          lastSuccessCount: 10,
          lastFailureCount: 0,
        );
        const partialSuccessState = SyncState(
          status: SyncOperationStatus.success,
          lastSuccessCount: 7,
          lastFailureCount: 3,
        );
        const allFailureState = SyncState(
          status: SyncOperationStatus.failed,
          lastSuccessCount: 0,
          lastFailureCount: 5,
        );
        const noOperationsState = SyncState(status: SyncOperationStatus.idle);

        expect(allSuccessState.lastSuccessRate, 1.0);
        expect(partialSuccessState.lastSuccessRate, 0.7);
        expect(allFailureState.lastSuccessRate, 0.0);
        expect(noOperationsState.lastSuccessRate, isNull);
      });
    });

    group('copyWith', () {
      test('copyWith updates specified fields', () {
        final initial = SyncState.initial();
        final updated = initial.copyWith(
          status: SyncOperationStatus.syncing,
          queueSize: 5,
          isProcessing: true,
        );

        expect(updated.status, SyncOperationStatus.syncing);
        expect(updated.queueSize, 5);
        expect(updated.isProcessing, true);
        expect(updated.lastStatusChangeAt, isNull); // Unchanged
      });

      test('copyWith preserves unspecified fields', () {
        final original = SyncState(
          status: SyncOperationStatus.syncing,
          queueSize: 5,
          isProcessing: true,
          lastStatusChangeAt: DateTime(2026, 1, 1),
          lastError: 'Test error',
        );
        final copied = original.copyWith(status: SyncOperationStatus.success);

        expect(copied.status, SyncOperationStatus.success);
        expect(copied.queueSize, 5);
        expect(copied.isProcessing, true);
        expect(copied.lastStatusChangeAt, DateTime(2026, 1, 1));
        expect(copied.lastError, 'Test error');
      });

      test('copyWith clearLastError removes error', () {
        const withError = SyncState(
          status: SyncOperationStatus.failed,
          lastError: 'Test error',
        );
        final withoutError = withError.copyWith(clearLastError: true);

        expect(withoutError.lastError, isNull);
      });

      test('copyWith can update lastError with new value', () {
        const state = SyncState(
            status: SyncOperationStatus.failed, lastError: 'Old error');
        final updated = state.copyWith(lastError: 'New error');

        expect(updated.lastError, 'New error');
      });

      test('copyWith with clearLastError=true overrides lastError parameter',
          () {
        const state = SyncState(
            status: SyncOperationStatus.failed, lastError: 'Old error');
        final updated = state.copyWith(
          lastError: 'New error',
          clearLastError: true,
        );

        expect(updated.lastError, isNull);
      });
    });

    group('Equatable', () {
      test('two states with same values are equal', () {
        const state1 = SyncState(
          status: SyncOperationStatus.syncing,
          queueSize: 5,
          isProcessing: true,
        );
        const state2 = SyncState(
          status: SyncOperationStatus.syncing,
          queueSize: 5,
          isProcessing: true,
        );

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('two states with different values are not equal', () {
        const state1 =
            SyncState(status: SyncOperationStatus.idle, queueSize: 0);
        const state2 =
            SyncState(status: SyncOperationStatus.syncing, queueSize: 5);

        expect(state1, isNot(equals(state2)));
      });

      test('props includes all fields', () {
        final state = SyncState(
          status: SyncOperationStatus.syncing,
          queueSize: 5,
          isProcessing: true,
          lastStatusChangeAt: DateTime(2026, 1, 1),
          lastSuccessfulSyncAt: DateTime(2026, 1, 2),
          lastSuccessCount: 10,
          lastFailureCount: 2,
          lastError: 'Test',
          hasPendingOperations: true,
        );

        expect(state.props.length, 9);
        expect(state.props, contains(state.status));
        expect(state.props, contains(state.queueSize));
        expect(state.props, contains(state.isProcessing));
        expect(state.props, contains(state.lastStatusChangeAt));
        expect(state.props, contains(state.lastSuccessfulSyncAt));
        expect(state.props, contains(state.lastSuccessCount));
        expect(state.props, contains(state.lastFailureCount));
        expect(state.props, contains(state.lastError));
        expect(state.props, contains(state.hasPendingOperations));
      });
    });

    group('toString', () {
      test('toString includes important fields', () {
        const state = SyncState(
          status: SyncOperationStatus.syncing,
          queueSize: 5,
          isProcessing: true,
          lastSuccessCount: 10,
          lastFailureCount: 2,
        );

        final str = state.toString();

        expect(str, contains('syncing'));
        expect(str, contains('queueSize: 5'));
        expect(str, contains('isProcessing: true'));
        expect(str, contains('lastSuccessCount: 10'));
        expect(str, contains('lastFailureCount: 2'));
      });
    });

    group('State Transitions', () {
      test('idle to syncing transition', () {
        final idle = SyncState.initial();
        final syncing = idle.copyWith(
          status: SyncOperationStatus.syncing,
          isProcessing: true,
          lastStatusChangeAt: DateTime.now(),
        );

        expect(syncing.status, SyncOperationStatus.syncing);
        expect(syncing.isProcessing, true);
        expect(syncing.isSyncing, true);
      });

      test('syncing to success transition', () {
        const syncing = SyncState(
          status: SyncOperationStatus.syncing,
          isProcessing: true,
          queueSize: 10,
        );
        final success = syncing.copyWith(
          status: SyncOperationStatus.success,
          isProcessing: false,
          lastSuccessCount: 10,
          lastFailureCount: 0,
          lastSuccessfulSyncAt: DateTime.now(),
          lastStatusChangeAt: DateTime.now(),
          clearLastError: true,
        );

        expect(success.status, SyncOperationStatus.success);
        expect(success.isProcessing, false);
        expect(success.isSyncing, false);
        expect(success.wasLastSyncSuccessful, true);
        expect(success.lastSuccessCount, 10);
        expect(success.lastFailureCount, 0);
      });

      test('syncing to failure transition', () {
        const syncing = SyncState(
          status: SyncOperationStatus.syncing,
          isProcessing: true,
          queueSize: 5,
        );
        final failed = syncing.copyWith(
          status: SyncOperationStatus.failed,
          isProcessing: false,
          lastFailureCount: 5,
          lastError: 'Network error',
          lastStatusChangeAt: DateTime.now(),
        );

        expect(failed.status, SyncOperationStatus.failed);
        expect(failed.isProcessing, false);
        expect(failed.isSyncing, false);
        expect(failed.didLastSyncFail, true);
        expect(failed.lastError, 'Network error');
      });

      test('queue change updates hasPendingOperations', () {
        const empty = SyncState(status: SyncOperationStatus.idle, queueSize: 0);
        final withQueue = empty.copyWith(
          queueSize: 5,
          hasPendingOperations: true,
        );

        expect(withQueue.hasQueue, true);
        expect(withQueue.hasPendingOperations, true);
        expect(withQueue.queueSize, 5);
      });
    });

    group('JSON Serialization', () {
      test('toJson serializes all fields', () {
        final now = DateTime.now();
        final state = SyncState(
          status: SyncOperationStatus.syncing,
          queueSize: 5,
          isProcessing: true,
          lastStatusChangeAt: now,
          lastSuccessfulSyncAt: now,
          lastSuccessCount: 10,
          lastFailureCount: 2,
          lastError: 'Test error',
          hasPendingOperations: true,
        );

        final json = state.toJson();

        expect(json['status'], 'syncing');
        expect(json['queueSize'], 5);
        expect(json['isProcessing'], true);
        expect(json['lastStatusChangeAt'], now.toIso8601String());
        expect(json['lastSuccessfulSyncAt'], now.toIso8601String());
        expect(json['lastSuccessCount'], 10);
        expect(json['lastFailureCount'], 2);
        expect(json['lastError'], 'Test error');
        expect(json['hasPendingOperations'], true);
      });

      test('fromJson creates correct state from valid JSON', () {
        final now = DateTime.now();
        final json = {
          'status': 'syncing',
          'queueSize': 5,
          'isProcessing': true,
          'lastStatusChangeAt': now.toIso8601String(),
          'lastSuccessfulSyncAt': now.toIso8601String(),
          'lastSuccessCount': 10,
          'lastFailureCount': 2,
          'lastError': 'Test error',
          'hasPendingOperations': true,
        };

        final state = SyncState.fromJson(json);

        expect(state, isNotNull);
        expect(state!.status, SyncOperationStatus.syncing);
        expect(state.queueSize, 5);
        expect(state.isProcessing, true);
        expect(state.lastStatusChangeAt, now);
        expect(state.lastSuccessfulSyncAt, now);
        expect(state.lastSuccessCount, 10);
        expect(state.lastFailureCount, 2);
        expect(state.lastError, 'Test error');
        expect(state.hasPendingOperations, true);
      });

      test('fromJson returns null for invalid JSON', () {
        expect(SyncState.fromJson({}), isNull);
        expect(SyncState.fromJson({'status': 'invalid'}), isNull);
        expect(SyncState.fromJson(null), isNull);
      });

      test('fromJson handles missing optional fields', () {
        final json = {'status': 'idle'};

        final state = SyncState.fromJson(json);

        expect(state, isNotNull);
        expect(state!.status, SyncOperationStatus.idle);
        expect(state.queueSize, 0);
        expect(state.isProcessing, false);
        expect(state.lastStatusChangeAt, isNull);
        expect(state.lastSuccessfulSyncAt, isNull);
        expect(state.lastSuccessCount, 0);
        expect(state.lastFailureCount, 0);
        expect(state.lastError, isNull);
        expect(state.hasPendingOperations, false);
      });

      test('fromJson handles null DateTime strings', () {
        final json = {
          'status': 'idle',
          'lastStatusChangeAt': null,
          'lastSuccessfulSyncAt': null,
        };

        final state = SyncState.fromJson(json);

        expect(state, isNotNull);
        expect(state!.lastStatusChangeAt, isNull);
        expect(state.lastSuccessfulSyncAt, isNull);
      });

      test('fromJson handles invalid DateTime strings', () {
        final json = {
          'status': 'idle',
          'lastStatusChangeAt': 'invalid-date',
          'lastSuccessfulSyncAt': 'also-invalid',
        };

        final state = SyncState.fromJson(json);

        expect(state, isNotNull);
        expect(state!.lastStatusChangeAt, isNull);
        expect(state.lastSuccessfulSyncAt, isNull);
      });

      test('toJsonString and fromJsonString round-trip correctly', () {
        final now = DateTime.now();
        final original = SyncState(
          status: SyncOperationStatus.failed,
          queueSize: 3,
          isProcessing: false,
          lastStatusChangeAt: now,
          lastSuccessfulSyncAt: now.subtract(const Duration(days: 1)),
          lastSuccessCount: 7,
          lastFailureCount: 3,
          lastError: 'Network timeout',
          hasPendingOperations: true,
        );

        final jsonString = original.toJsonString();
        final restored = SyncState.fromJsonString(jsonString);

        expect(restored, isNotNull);
        expect(restored!.status, original.status);
        expect(restored.queueSize, original.queueSize);
        expect(restored.isProcessing, original.isProcessing);
        expect(restored.lastStatusChangeAt, original.lastStatusChangeAt);
        expect(restored.lastSuccessfulSyncAt, original.lastSuccessfulSyncAt);
        expect(restored.lastSuccessCount, original.lastSuccessCount);
        expect(restored.lastFailureCount, original.lastFailureCount);
        expect(restored.lastError, original.lastError);
        expect(restored.hasPendingOperations, original.hasPendingOperations);
      });

      test('fromJsonString returns null for invalid JSON', () {
        expect(SyncState.fromJsonString(''), isNull);
        expect(SyncState.fromJsonString('not json'), isNull);
        expect(SyncState.fromJsonString('{invalid}'), isNull);
      });

      test('all status values serialize and deserialize correctly', () {
        final statuses = [
          SyncOperationStatus.idle,
          SyncOperationStatus.syncing,
          SyncOperationStatus.success,
          SyncOperationStatus.failed,
          SyncOperationStatus.pending,
        ];

        for (final status in statuses) {
          final state = SyncState(status: status);
          final json = state.toJson();
          final restored = SyncState.fromJson(json);

          expect(restored, isNotNull);
          expect(restored!.status, status);
        }
      });
    });
  });
}
