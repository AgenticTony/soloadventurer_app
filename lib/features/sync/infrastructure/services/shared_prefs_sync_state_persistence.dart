import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/services/sync_state_persistence.dart';
import '../../presentation/state/sync_state.dart';

/// Implementation of [SyncStatePersistence] using SharedPreferences
///
/// Stores sync state as a JSON string with the key:
/// - 'sync_state': Complete sync state data
class SharedPrefsSyncStatePersistence implements SyncStatePersistence {
  final SharedPreferences _prefs;

  // Storage key
  static const String _stateKey = 'sync_state';

  /// Creates a new [SharedPrefsSyncStatePersistence] instance
  SharedPrefsSyncStatePersistence(this._prefs);

  @override
  Future<SyncStatePersistenceResult> saveState(SyncState state) async {
    try {
      final jsonString = state.toJsonString();

      await _prefs.setString(_stateKey, jsonString);

      developer.log(
        'SyncStatePersistence: Saved state (status: ${state.status}, '
        'queueSize: ${state.queueSize}, hasPending: ${state.hasPendingOperations})',
        name: 'sync.state_persistence',
      );

      return SyncStatePersistenceResult.success();
    } catch (e, stackTrace) {
      developer.log(
        'SyncStatePersistence: Error saving state',
        name: 'sync.state_persistence',
        error: e,
        stackTrace: stackTrace,
      );

      return SyncStatePersistenceResult.failure(
        'Failed to save state: ${e.toString()}',
      );
    }
  }

  @override
  Future<SyncState?> loadState() async {
    try {
      final jsonString = _prefs.getString(_stateKey);
      if (jsonString == null || jsonString.isEmpty) {
        developer.log(
          'SyncStatePersistence: No persisted state found',
          name: 'sync.state_persistence',
        );
        return null;
      }

      final state = SyncState.fromJsonString(jsonString);

      if (state == null) {
        developer.log(
          'SyncStatePersistence: Persisted state is corrupted, clearing',
          name: 'sync.state_persistence',
          level: 900, // WARNING level
        );
        // Clear corrupted data
        await clearState();
        return null;
      }

      developer.log(
        'SyncStatePersistence: Loaded state (status: ${state.status}, '
        'queueSize: ${state.queueSize}, hasPending: ${state.hasPendingOperations})',
        name: 'sync.state_persistence',
      );

      return state;
    } catch (e, stackTrace) {
      developer.log(
        'SyncStatePersistence: Error loading state',
        name: 'sync.state_persistence',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR level
      );

      // On error, attempt to clear corrupted data
      try {
        await clearState();
      } catch (_) {
        // Ignore cleanup errors
      }

      return null;
    }
  }

  @override
  Future<SyncStatePersistenceResult> clearState() async {
    try {
      await _prefs.remove(_stateKey);

      developer.log(
        'SyncStatePersistence: Cleared state',
        name: 'sync.state_persistence',
      );

      return SyncStatePersistenceResult.success();
    } catch (e, stackTrace) {
      developer.log(
        'SyncStatePersistence: Error clearing state',
        name: 'sync.state_persistence',
        error: e,
        stackTrace: stackTrace,
      );

      return SyncStatePersistenceResult.failure(
        'Failed to clear state: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> hasPersistedState() async {
    try {
      final jsonString = _prefs.getString(_stateKey);
      final hasState = jsonString != null && jsonString.isNotEmpty;

      developer.log(
        'SyncStatePersistence: Has persisted state: $hasState',
        name: 'sync.state_persistence',
      );

      return hasState;
    } catch (e, stackTrace) {
      developer.log(
        'SyncStatePersistence: Error checking for persisted state',
        name: 'sync.state_persistence',
        error: e,
        stackTrace: stackTrace,
      );

      return false;
    }
  }
}
