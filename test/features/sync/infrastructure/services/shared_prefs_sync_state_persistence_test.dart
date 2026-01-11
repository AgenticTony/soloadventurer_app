import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_status.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/shared_prefs_sync_state_persistence.dart';
import 'package:soloadventurer/features/sync/presentation/state/sync_state.dart';

@GenerateMocks([SharedPreferences])
import 'shared_prefs_sync_state_persistence_test.mocks.dart';

void main() {
  late MockSharedPreferences mockPrefs;
  late SharedPrefsSyncStatePersistence persistence;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    persistence = SharedPrefsSyncStatePersistence(mockPrefs);
  });

  group('SharedPrefsSyncStatePersistence', () {
    const stateKey = 'sync_state';

    group('saveState', () {
      test('saves valid state to SharedPreferences', () async {
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

        when(mockPrefs.setString(stateKey, any)).thenAnswer((_) async => true);

        final result = await persistence.saveState(state);

        expect(result.success, true);
        expect(result.error, isNull);
        verify(mockPrefs.setString(stateKey, argThat(isNotEmpty))).called(1);
      });

      test('returns failure result when save fails', () async {
        const state = SyncState(status: SyncOperationStatus.idle);

        when(mockPrefs.setString(stateKey, any))
            .thenThrow(Exception('Save failed'));

        final result = await persistence.saveState(state);

        expect(result.success, false);
        expect(result.error, isNotNull);
        expect(result.error, contains('Failed to save state'));
      });

      test('serializes state with all fields', () async {
        final now = DateTime.now();
        final state = SyncState(
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

        String? capturedJson;
        when(mockPrefs.setString(stateKey, any)).thenAnswer((realInvocation) {
          capturedJson = realInvocation.positionalArguments[1] as String;
          return Future.value(true);
        });

        await persistence.saveState(state);

        expect(capturedJson, isNotNull);
        expect(capturedJson, contains('"status":"failed"'));
        expect(capturedJson, contains('"queueSize":3'));
        expect(capturedJson, contains('"hasPendingOperations":true'));
      });
    });

    group('loadState', () {
      test('loads valid state from SharedPreferences', () async {
        final now = DateTime.now();
        final originalState = SyncState(
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

        when(mockPrefs.getString(stateKey))
            .thenReturn(originalState.toJsonString());

        final loadedState = await persistence.loadState();

        expect(loadedState, isNotNull);
        expect(loadedState!.status, SyncOperationStatus.failed);
        expect(loadedState.queueSize, 3);
        expect(loadedState.hasPendingOperations, true);
        expect(loadedState.lastError, 'Network timeout');
        expect(loadedState.lastSuccessCount, 7);
        expect(loadedState.lastFailureCount, 3);
      });

      test('returns null when no persisted state exists', () async {
        when(mockPrefs.getString(stateKey)).thenReturn(null);

        final loadedState = await persistence.loadState();

        expect(loadedState, isNull);
      });

      test('returns null and clears corrupted state', () async {
        when(mockPrefs.getString(stateKey)).thenReturn('invalid json');
        when(mockPrefs.remove(stateKey)).thenAnswer((_) async => true);

        final loadedState = await persistence.loadState();

        expect(loadedState, isNull);
        verify(mockPrefs.remove(stateKey)).called(1);
      });

      test('handles exception during load', () async {
        when(mockPrefs.getString(stateKey)).thenThrow(Exception('Load failed'));

        final loadedState = await persistence.loadState();

        expect(loadedState, isNull);
      });

      test('clears persisted data on load error', () async {
        when(mockPrefs.getString(stateKey)).thenThrow(Exception('Load failed'));
        when(mockPrefs.remove(stateKey)).thenAnswer((_) async => true);

        await persistence.loadState();

        verify(mockPrefs.remove(stateKey)).called(1);
      });
    });

    group('clearState', () {
      test('removes persisted state from SharedPreferences', () async {
        when(mockPrefs.remove(stateKey)).thenAnswer((_) async => true);

        final result = await persistence.clearState();

        expect(result.success, true);
        expect(result.error, isNull);
        verify(mockPrefs.remove(stateKey)).called(1);
      });

      test('returns failure result when clear fails', () async {
        when(mockPrefs.remove(stateKey)).thenThrow(Exception('Clear failed'));

        final result = await persistence.clearState();

        expect(result.success, false);
        expect(result.error, isNotNull);
        expect(result.error, contains('Failed to clear state'));
      });
    });

    group('hasPersistedState', () {
      test('returns true when state exists', () async {
        when(mockPrefs.getString(stateKey))
            .thenReturn('{"status":"idle","queueSize":0}');

        final hasState = await persistence.hasPersistedState();

        expect(hasState, true);
      });

      test('returns false when state does not exist', () async {
        when(mockPrefs.getString(stateKey)).thenReturn(null);

        final hasState = await persistence.hasPersistedState();

        expect(hasState, false);
      });

      test('returns false when state string is empty', () async {
        when(mockPrefs.getString(stateKey)).thenReturn('');

        final hasState = await persistence.hasPersistedState();

        expect(hasState, false);
      });

      test('handles exception during check', () async {
        when(mockPrefs.getString(stateKey))
            .thenThrow(Exception('Check failed'));

        final hasState = await persistence.hasPersistedState();

        expect(hasState, false);
      });
    });

    group('Round-trip persistence', () {
      test('state persists and restores correctly', () async {
        final now = DateTime.now();
        final original = SyncState(
          status: SyncOperationStatus.syncing,
          queueSize: 10,
          isProcessing: true,
          lastStatusChangeAt: now,
          lastSuccessfulSyncAt: now.subtract(const Duration(hours: 1)),
          lastSuccessCount: 15,
          lastFailureCount: 5,
          lastError: null,
          hasPendingOperations: true,
        );

        // Setup save
        when(mockPrefs.setString(stateKey, any)).thenAnswer((_) async => true);

        // Setup load
        when(mockPrefs.getString(stateKey)).thenAnswer((_) {
          return original.toJsonString();
        });

        // Save
        final saveResult = await persistence.saveState(original);
        expect(saveResult.success, true);

        // Load
        final restored = await persistence.loadState();

        expect(restored, isNotNull);
        expect(restored!.status, original.status);
        expect(restored.queueSize, original.queueSize);
        expect(restored.isProcessing, original.isProcessing);
        expect(restored.lastSuccessCount, original.lastSuccessCount);
        expect(restored.lastFailureCount, original.lastFailureCount);
        expect(restored.hasPendingOperations, original.hasPendingOperations);
      });

      test('all status values persist correctly', () async {
        final statuses = [
          SyncOperationStatus.idle,
          SyncOperationStatus.syncing,
          SyncOperationStatus.success,
          SyncOperationStatus.failed,
          SyncOperationStatus.pending,
        ];

        for (final status in statuses) {
          final state = SyncState(status: status);

          when(mockPrefs.setString(stateKey, any))
              .thenAnswer((_) async => true);
          when(mockPrefs.getString(stateKey))
              .thenAnswer((_) => state.toJsonString());

          await persistence.saveState(state);
          final loaded = await persistence.loadState();

          expect(loaded, isNotNull);
          expect(loaded!.status, status);
        }
      });
    });
  });
}
