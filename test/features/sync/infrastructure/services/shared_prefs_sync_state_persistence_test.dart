import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_status.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/shared_prefs_sync_state_persistence.dart';
import 'package:soloadventurer/features/sync/domain/state/sync_state.dart';

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
        const state = SyncState(
          status: SyncOperationStatus.syncing,
          pendingCount: 5,
          failedCount: 2,
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
          pendingCount: 3,
          failedCount: 3,
          lastSyncTime: now.subtract(const Duration(days: 1)),
          error: 'Network timeout',
        );

        String? capturedJson;
        when(mockPrefs.setString(stateKey, any)).thenAnswer((realInvocation) {
          capturedJson = realInvocation.positionalArguments[1] as String;
          return Future.value(true);
        });

        await persistence.saveState(state);

        expect(capturedJson, isNotNull);
        expect(capturedJson, contains('"status":"failed"'));
        expect(capturedJson, contains('"pendingCount":3'));
        expect(capturedJson, contains('"error":"Network timeout"'));
      });
    });

    group('loadState', () {
      test('loads valid state from SharedPreferences', () async {
        final now = DateTime.now();
        final json = jsonEncode({
          'status': 'failed',
          'pendingCount': 3,
          'failedCount': 3,
          'lastSyncTime': now.toIso8601String(),
          'error': 'Network timeout',
        });

        when(mockPrefs.getString(stateKey)).thenReturn(json);

        final loadedState = await persistence.loadState();

        expect(loadedState, isNotNull);
        expect(loadedState!.status, SyncOperationStatus.failed);
        expect(loadedState.pendingCount, 3);
        expect(loadedState.failedCount, 3);
        expect(loadedState.error, 'Network timeout');
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
            .thenReturn('{"status":"idle","pendingCount":0}');

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
          pendingCount: 10,
          failedCount: 5,
          lastSyncTime: now.subtract(const Duration(hours: 1)),
          error: null,
        );

        // Capture the JSON saved
        String? savedJson;
        when(mockPrefs.setString(stateKey, any)).thenAnswer((inv) {
          savedJson = inv.positionalArguments[1] as String;
          return Future.value(true);
        });
        when(mockPrefs.getString(stateKey)).thenAnswer((_) => savedJson);

        // Save
        final saveResult = await persistence.saveState(original);
        expect(saveResult.success, true);

        // Load
        final restored = await persistence.loadState();

        expect(restored, isNotNull);
        expect(restored!.status, original.status);
        expect(restored.pendingCount, original.pendingCount);
        expect(restored.failedCount, original.failedCount);
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

          String? savedJson;
          when(mockPrefs.setString(stateKey, any)).thenAnswer((inv) {
            savedJson = inv.positionalArguments[1] as String;
            return Future.value(true);
          });
          when(mockPrefs.getString(stateKey)).thenAnswer((_) => savedJson);

          await persistence.saveState(state);
          final loaded = await persistence.loadState();

          expect(loaded, isNotNull);
          expect(loaded!.status, status);
        }
      });
    });
  });
}
