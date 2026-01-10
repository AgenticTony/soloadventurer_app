import 'dart:async';
import '../models/sync_history_entry.dart';
import '../models/sync_status.dart';

/// Result of a sync history operation
class SyncHistoryResult {
  /// Whether the operation was successful
  final bool isSuccess;

  /// Error message if operation failed
  final String? error;

  /// Number of entries affected (for operations that return counts)
  final int? affectedCount;

  const SyncHistoryResult({
    required this.isSuccess,
    this.error,
    this.affectedCount,
  });

  /// Creates a successful result
  factory SyncHistoryResult.success({int? affectedCount}) {
    return SyncHistoryResult(
      isSuccess: true,
      affectedCount: affectedCount,
    );
  }

  /// Creates a failed result
  factory SyncHistoryResult.failure(String error) {
    return SyncHistoryResult(
      isSuccess: false,
      error: error,
    );
  }

  @override
  String toString() =>
      'SyncHistoryResult(isSuccess: $isSuccess, error: $error, '
      'affectedCount: $affectedCount)';
}

/// Abstract interface for sync history management
///
/// Manages a log of recent sync operations with timestamps,
/// supporting queries and persistence for debugging and user transparency.
abstract class SyncHistoryService {
  /// Maximum number of history entries to store
  int get maxEntries;

  /// Current number of history entries stored
  int get entryCount;

  /// All history entries in reverse chronological order (newest first)
  List<SyncHistoryEntry> get entries;

  /// Stream that emits when history entries are added
  Stream<List<SyncHistoryEntry>> get entriesStream;

  /// Add a new history entry
  ///
  /// If the history is at maximum capacity, the oldest entry will be removed.
  /// Returns the entry that was added.
  Future<SyncHistoryEntry?> addEntry(SyncHistoryEntry entry);

  /// Update an existing entry by ID
  ///
  /// Returns [true] if the entry was found and updated, [false] otherwise.
  Future<bool> updateEntry(String id, SyncHistoryEntry updatedEntry);

  /// Get a specific entry by ID
  ///
  /// Returns null if entry not found.
  SyncHistoryEntry? getEntryById(String id);

  /// Get the most recent entry
  ///
  /// Returns null if no entries exist.
  SyncHistoryEntry? get latestEntry;

  /// Get entries filtered by status
  List<SyncHistoryEntry> getEntriesByStatus(SyncOperationStatus status);

  /// Get entries filtered by manual sync flag
  List<SyncHistoryEntry> getManualSyncs();

  /// Get entries filtered by automatic sync
  List<SyncHistoryEntry> getAutomaticSyncs();

  /// Get entries from a specific date range
  List<SyncHistoryEntry> getEntriesByDateRange(DateTime start, DateTime end);

  /// Get entries from the last N hours
  List<SyncHistoryEntry> getEntriesFromLastHours(int hours);

  /// Get entries from the last N days
  List<SyncHistoryEntry> getEntriesFromLastDays(int days);

  /// Get the last N entries
  List<SyncHistoryEntry> getLatestEntries(int count);

  /// Get statistics about sync history
  SyncHistoryStats getStats();

  /// Clear all history entries
  Future<SyncHistoryResult> clearHistory();

  /// Delete entries older than a certain date
  ///
  /// Returns the number of entries deleted.
  Future<int> deleteEntriesOlderThan(DateTime date);

  /// Delete entries by status
  ///
  /// Returns the number of entries deleted.
  Future<int> deleteEntriesByStatus(SyncOperationStatus status);

  /// Export history to JSON string
  String exportToJson();

  /// Import history from JSON string
  ///
  /// Returns the number of entries imported.
  Future<int> importFromJson(String jsonString);

  /// Dispose of resources
  void dispose();
}

/// Statistics about sync history
class SyncHistoryStats {
  /// Total number of sync operations
  final int totalSyncs;

  /// Number of successful syncs
  final int successfulSyncs;

  /// Number of failed syncs
  final int failedSyncs;

  /// Number of manual syncs
  final int manualSyncs;

  /// Number of automatic syncs
  final int automaticSyncs;

  /// Success rate (0.0 to 1.0, or null if no syncs)
  final double? successRate;

  /// Average duration of successful syncs (null if none completed)
  final Duration? averageDuration;

  /// Total number of operations synced across all history
  final int totalOperations;

  /// Total number of successful operations
  final int totalSuccessOperations;

  /// Total number of failed operations
  final int totalFailedOperations;

  const SyncHistoryStats({
    required this.totalSyncs,
    required this.successfulSyncs,
    required this.failedSyncs,
    required this.manualSyncs,
    required this.automaticSyncs,
    this.successRate,
    this.averageDuration,
    required this.totalOperations,
    required this.totalSuccessOperations,
    required this.totalFailedOperations,
  });

  @override
  String toString() {
    return 'SyncHistoryStats('
        'totalSyncs: $totalSyncs, '
        'successfulSyncs: $successfulSyncs, '
        'failedSyncs: $failedSyncs, '
        'manualSyncs: $manualSyncs, '
        'automaticSyncs: $automaticSyncs, '
        'successRate: $successRate, '
        'averageDuration: $averageDuration, '
        'totalOperations: $totalOperations, '
        'totalSuccessOperations: $totalSuccessOperations, '
        'totalFailedOperations: $totalFailedOperations)';
  }
}
