import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/services/sync_history_persistence.dart';
import '../../domain/models/sync_history_entry.dart';

/// Implementation of [SyncHistoryPersistence] using SharedPreferences
///
/// Stores sync history as a JSON string with the key:
/// - 'sync_history': Complete history data (up to max entries)
class SharedPrefsSyncHistoryPersistence implements SyncHistoryPersistence {
  final SharedPreferences _prefs;

  /// Maximum number of entries to persist
  final int maxEntries;

  // Storage key
  static const String _historyKey = 'sync_history';

  /// Creates a new [SharedPrefsSyncHistoryPersistence] instance
  SharedPrefsSyncHistoryPersistence(
    this._prefs, {
    this.maxEntries = 50,
  });

  @override
  Future<SyncHistoryPersistenceResult> saveHistory(
    List<SyncHistoryEntry> entries,
  ) async {
    try {
      // Limit entries to maxEntries (take newest)
      final limitedEntries = entries.take(maxEntries).toList();

      final jsonString = SyncHistoryEntry.toJsonString(limitedEntries);

      await _prefs.setString(_historyKey, jsonString);

      developer.log(
        'SyncHistoryPersistence: Saved ${limitedEntries.length} entries '
        '(limited from ${entries.length})',
        name: 'sync.history_persistence',
      );

      return SyncHistoryPersistenceResult.success(
        entryCount: limitedEntries.length,
      );
    } catch (e, stackTrace) {
      developer.log(
        'SyncHistoryPersistence: Error saving history',
        name: 'sync.history_persistence',
        error: e,
        stackTrace: stackTrace,
      );

      return SyncHistoryPersistenceResult.failure(
        'Failed to save history: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<SyncHistoryEntry>?> loadHistory() async {
    try {
      final jsonString = _prefs.getString(_historyKey);
      if (jsonString == null || jsonString.isEmpty) {
        developer.log(
          'SyncHistoryPersistence: No persisted history found',
          name: 'sync.history_persistence',
        );
        return null;
      }

      final entries = SyncHistoryEntry.fromJsonString(jsonString);

      developer.log(
        'SyncHistoryPersistence: Loaded ${entries.length} entries',
        name: 'sync.history_persistence',
      );

      return entries;
    } catch (e, stackTrace) {
      developer.log(
        'SyncHistoryPersistence: Error loading history',
        name: 'sync.history_persistence',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR level
      );

      // On error, attempt to clear corrupted data
      try {
        await clearHistory();
      } catch (_) {
        // Ignore cleanup errors
      }

      return null;
    }
  }

  @override
  Future<SyncHistoryPersistenceResult> clearHistory() async {
    try {
      await _prefs.remove(_historyKey);

      developer.log(
        'SyncHistoryPersistence: Cleared persisted history',
        name: 'sync.history_persistence',
      );

      return SyncHistoryPersistenceResult.success();
    } catch (e, stackTrace) {
      developer.log(
        'SyncHistoryPersistence: Error clearing history',
        name: 'sync.history_persistence',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR level
      );

      return SyncHistoryPersistenceResult.failure(
        'Failed to clear history: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> hasPersistedHistory() async {
    try {
      final jsonString = _prefs.getString(_historyKey);
      final hasHistory = jsonString != null && jsonString.isNotEmpty;

      developer.log(
        'SyncHistoryPersistence: Has persisted history: $hasHistory',
        name: 'sync.history_persistence',
      );

      return hasHistory;
    } catch (e, stackTrace) {
      developer.log(
        'SyncHistoryPersistence: Error checking for persisted history',
        name: 'sync.history_persistence',
        error: e,
        stackTrace: stackTrace,
      );

      return false;
    }
  }
}
