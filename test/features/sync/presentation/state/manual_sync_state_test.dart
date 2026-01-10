import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_status.dart';
import 'package:soloadventurer/features/sync/presentation/state/manual_sync_state.dart';

void main() {
  group('ManualSyncState', () {
    group('Factory Constructors', () {
      test('initial() creates correct initial state', () {
        // Act
        final state = ManualSyncState.initial();

        // Assert
        expect(state.status, SyncOperationStatus.idle);
        expect(state.isSyncing, false);
        expect(state.lastSyncSuccess, isNull);
        expect(state.successCount, 0);
        expect(state.failureCount, 0);
        expect(state.totalProcessed, 0);
      });

      test('syncing() creates correct syncing state', () {
        // Arrange
        final startedAt = DateTime.now();

        // Act
        final state = ManualSyncState.syncing(startedAt: startedAt);

        // Assert
        expect(state.status, SyncOperationStatus.syncing);
        expect(state.isSyncing, true);
        expect(state.startedAt, startedAt);
        expect(state.lastSyncSuccess, isNull);
      });

      test('success() creates correct success state', () {
        // Arrange
        final completedAt = DateTime.now();
        final startedAt = completedAt.subtract(const Duration(seconds: 5));

        // Act
        final state = ManualSyncState.success(
          successCount: 10,
          failureCount: 2,
          completedAt: completedAt,
          startedAt: startedAt,
          totalProcessed: 12,
        );

        // Assert
        expect(state.status, SyncOperationStatus.success);
        expect(state.isSyncing, false);
        expect(state.lastSyncSuccess, true);
        expect(state.successCount, 10);
        expect(state.failureCount, 2);
        expect(state.totalProcessed, 12);
        expect(state.completedAt, completedAt);
        expect(state.startedAt, startedAt);
      });

      test('failure() creates correct failure state', () {
        // Arrange
        final completedAt = DateTime.now();
        final startedAt = completedAt.subtract(const Duration(seconds: 3));

        // Act
        final state = ManualSyncState.failure(
          errorMessage: 'Network error',
          completedAt: completedAt,
          startedAt: startedAt,
          successCount: 5,
          failureCount: 3,
          totalProcessed: 8,
        );

        // Assert
        expect(state.status, SyncOperationStatus.failed);
        expect(state.isSyncing, false);
        expect(state.lastSyncSuccess, false);
        expect(state.errorMessage, 'Network error');
        expect(state.successCount, 5);
        expect(state.failureCount, 3);
        expect(state.totalProcessed, 8);
        expect(state.completedAt, completedAt);
        expect(state.startedAt, startedAt);
      });
    });

    group('Computed Properties', () {
      test('isCompleted returns true only when completedAt is set', () {
        // Arrange
        final completedState = ManualSyncState.success(
          successCount: 1,
          failureCount: 0,
          completedAt: DateTime.now(),
        );
        final incompleteState = ManualSyncState.syncing(
          startedAt: DateTime.now(),
        );

        // Assert
        expect(completedState.isCompleted, true);
        expect(incompleteState.isCompleted, false);
      });

      test('isFailed returns true only when lastSyncSuccess is false', () {
        // Arrange
        final failedState = ManualSyncState.failure(
          errorMessage: 'Error',
          completedAt: DateTime.now(),
        );
        final successState = ManualSyncState.success(
          successCount: 1,
          failureCount: 0,
          completedAt: DateTime.now(),
        );
        final initialState = ManualSyncState.initial();

        // Assert
        expect(failedState.isFailed, true);
        expect(successState.isFailed, false);
        expect(initialState.isFailed, false);
      });

      test('hasResults returns true when there are operations', () {
        // Arrange
        final stateWithResults = ManualSyncState.success(
          successCount: 5,
          failureCount: 0,
          completedAt: DateTime.now(),
        );
        final stateWithFailures = ManualSyncState.failure(
          errorMessage: 'Error',
          completedAt: DateTime.now(),
          failureCount: 2,
        );
        final stateWithNoResults = ManualSyncState.initial();

        // Assert
        expect(stateWithResults.hasResults, true);
        expect(stateWithFailures.hasResults, true);
        expect(stateWithNoResults.hasResults, false);
      });

      test('totalOperations returns sum of success and failure counts', () {
        // Arrange
        final state = ManualSyncState.success(
          successCount: 10,
          failureCount: 3,
          completedAt: DateTime.now(),
        );

        // Assert
        expect(state.totalOperations, 13);
      });

      test('duration returns null when timing incomplete', () {
        // Arrange
        final stateNoStart = ManualSyncState.success(
          successCount: 1,
          failureCount: 0,
          completedAt: DateTime.now(),
        );
        final stateNoEnd = ManualSyncState.syncing(
          startedAt: DateTime.now(),
        );

        // Assert
        expect(stateNoStart.duration, isNull);
        expect(stateNoEnd.duration, isNull);
      });

      test('duration returns correct duration when timing complete', () {
        // Arrange
        final startedAt = DateTime.now();
        final completedAt = startedAt.add(const Duration(seconds: 10));
        final state = ManualSyncState.success(
          successCount: 1,
          failureCount: 0,
          completedAt: completedAt,
          startedAt: startedAt,
        );

        // Assert
        expect(state.duration, const Duration(seconds: 10));
      });

      test('successRate returns null when no operations', () {
        // Arrange
        final state = ManualSyncState.success(
          successCount: 0,
          failureCount: 0,
          completedAt: DateTime.now(),
        );

        // Assert
        expect(state.successRate, isNull);
      });

      test('successRate returns correct rate when operations exist', () {
        // Arrange
        final state = ManualSyncState.success(
          successCount: 8,
          failureCount: 2,
          completedAt: DateTime.now(),
        );

        // Assert
        expect(state.successRate, 0.8);
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        // Arrange
        final original = ManualSyncState.initial();

        // Act
        final copy = original.copyWith(
          isSyncing: true,
          startedAt: DateTime.now(),
        );

        // Assert
        expect(copy.isSyncing, true);
        expect(copy.startedAt, isNotNull);
        expect(copy.status, original.status); // Unchanged
      });

      test('preserves unchanged fields', () {
        // Arrange
        final original = ManualSyncState.success(
          successCount: 10,
          failureCount: 2,
          completedAt: DateTime.now(),
        );

        // Act
        final copy = original.copyWith(isSyncing: true);

        // Assert
        expect(copy.successCount, 10);
        expect(copy.failureCount, 2);
        expect(copy.completedAt, original.completedAt);
        expect(copy.isSyncing, true);
      });
    });

    group('Equatable', () {
      test('states with same values are equal', () {
        // Arrange
        final completedAt = DateTime.now();
        final state1 = ManualSyncState.success(
          successCount: 5,
          failureCount: 0,
          completedAt: completedAt,
        );
        final state2 = ManualSyncState.success(
          successCount: 5,
          failureCount: 0,
          completedAt: completedAt,
        );

        // Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('states with different values are not equal', () {
        // Arrange
        final state1 = ManualSyncState.initial();
        final state2 = ManualSyncState.syncing(startedAt: DateTime.now());

        // Assert
        expect(state1, isNot(equals(state2)));
      });
    });

    group('toString', () {
      test('includes all relevant fields', () {
        // Arrange
        final state = ManualSyncState.success(
          successCount: 5,
          failureCount: 1,
          completedAt: DateTime(2024, 1, 1, 12, 0, 0),
        );

        // Act
        final str = state.toString();

        // Assert
        expect(str, contains('success'));
        expect(str, contains('5'));
        expect(str, contains('1'));
        expect(str, contains('true'));
      });
    });
  });
}
