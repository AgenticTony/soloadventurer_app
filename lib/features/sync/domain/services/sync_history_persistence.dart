import '../models/sync_history_entry.dart';

/// Abstract interface for sync history persistence
///
/// Provides methods to save and load sync history entries
/// to persistent storage across app restarts.
abstract class SyncHistoryPersistence {
  /// Save history entries to persistent storage
  ///
  /// Returns a result indicating success or failure with error details.
  Future<SyncHistoryPersistenceResult> saveHistory(
      List<SyncHistoryEntry> entries);

  /// Load history entries from persistent storage
  ///
  /// Returns null if no history exists or if loading fails.
  Future<List<SyncHistoryEntry>?> loadHistory();

  /// Clear all persisted history entries
  ///
  /// Returns a result indicating success or failure with error details.
  Future<SyncHistoryPersistenceResult> clearHistory();

  /// Check if there is any persisted history
  ///
  /// Returns true if history exists in storage, false otherwise.
  Future<bool> hasPersistedHistory();
}

/// Result of a history persistence operation
class SyncHistoryPersistenceResult {
  /// Whether the operation was successful
  final bool isSuccess;

  /// Error message if operation failed
  final String? error;

  /// Number of entries affected (0 for clear operation)
  final int? entryCount;

  const SyncHistoryPersistenceResult({
    required this.isSuccess,
    this.error,
    this.entryCount,
  });

  /// Creates a successful result
  factory SyncHistoryPersistenceResult.success({int? entryCount}) {
    return SyncHistoryPersistenceResult(
      isSuccess: true,
      entryCount: entryCount,
    );
  }

  /// Creates a failed result
  factory SyncHistoryPersistenceResult.failure(String error) {
    return SyncHistoryPersistenceResult(
      isSuccess: false,
      error: error,
    );
  }

  @override
  String toString() => 'SyncHistoryPersistenceResult(isSuccess: $isSuccess, '
      'error: $error, entryCount: $entryCount)';
}
