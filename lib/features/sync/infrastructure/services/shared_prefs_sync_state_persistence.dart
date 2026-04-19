import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/services/sync_state_persistence.dart';
import '../../domain/state/sync_state.dart';
import '../../domain/models/sync_status.dart';

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
      final jsonString = jsonEncode({
        'status': state.status.name,
        'pendingCount': state.pendingCount,
        'failedCount': state.failedCount,
        'lastSyncTime': state.lastSyncTime?.toIso8601String(),
        'error': state.error,
      });

      await _prefs.setString(_stateKey, jsonString);

      developer.log(
        'SyncStatePersistence: Saved state (status: ${state.status}, '
        'pendingCount: ${state.pendingCount}, hasPending: ${state.pendingCount > 0})',
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

      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

      final statusName = decoded['status'] as String? ?? 'idle';
      final lastSyncTimeStr = decoded['lastSyncTime'] as String?;
      final state = SyncState(
        status: SyncOperationStatus.values.firstWhere(
          (s) => s.name == statusName,
          orElse: () => SyncOperationStatus.idle,
        ),
        pendingCount: decoded['pendingCount'] as int? ?? 0,
        failedCount: decoded['failedCount'] as int? ?? 0,
        lastSyncTime: lastSyncTimeStr != null
            ? DateTime.tryParse(lastSyncTimeStr)
            : null,
        error: decoded['error'] as String?,
      );

      developer.log(
        'SyncStatePersistence: Loaded state (status: ${state.status}, '
        'pendingCount: ${state.pendingCount})',
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
