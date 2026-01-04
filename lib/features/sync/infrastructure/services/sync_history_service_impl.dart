import 'dart:async';
import 'dart:developer' as developer;
import 'package:collection/collection.dart';
import '../../domain/models/sync_history_entry.dart';
import '../../domain/models/sync_status.dart';
import '../../domain/services/sync_history_service.dart';
import '../../domain/services/sync_history_persistence.dart';

/// Implementation of [SyncHistoryService] with in-memory circular buffer
///
/// Uses a circular buffer to maintain a fixed-size history log.
/// Automatically removes oldest entries when capacity is reached.
/// Optionally persists history to storage.
class SyncHistoryServiceImpl implements SyncHistoryService {
  /// Maximum number of entries to store (default: 50)
  @override
  final int maxEntries;

  /// Optional persistence layer for saving history across app restarts
  final SyncHistoryPersistence? _persistence;

  /// Internal storage for history entries (in reverse chronological order)
  final List<SyncHistoryEntry> _entries = [];

  /// Stream controller for entry changes
  StreamController<List<SyncHistoryEntry>>? _entriesController;

  /// Whether this service has been disposed
  bool _isDisposed = false;

  /// Whether initialization has been completed
  bool _isInitialized = false;

  /// Creates a new [SyncHistoryServiceImpl] instance
  ///
  /// [maxEntries] is the maximum number of entries to store (default: 50).
  /// When the limit is reached, oldest entries are automatically removed.
  ///
  /// [persistence] is an optional persistence layer for saving history
  /// across app restarts. If null, history is kept in memory only.
  SyncHistoryServiceImpl({
    this.maxEntries = 50,
    SyncHistoryPersistence? persistence,
  }) : _persistence = persistence {
    _initialize();
  }

  /// Initialize the service by loading persisted history
  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      await _loadPersistedHistory();
      _isInitialized = true;

      developer.log(
        'SyncHistoryService: Initialized with ${_entries.length} entries',
        name: 'sync.history',
      );
    } catch (e, stackTrace) {
      developer.log(
        'SyncHistoryService: Error during initialization',
        name: 'sync.history',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR
      );
      // Continue without persisted history
      _isInitialized = true;
    }
  }

  /// Load persisted history from storage
  Future<void> _loadPersistedHistory() async {
    if (_persistence == null) return;

    try {
      final persistedHistory = await _persistence!.loadHistory();
      if (persistedHistory == null || persistedHistory.isEmpty) {
        developer.log(
          'SyncHistoryService: No persisted history to load',
          name: 'sync.history',
        );
        return;
      }

      // Add persisted entries
      _entries.clear();
      _entries.addAll(persistedHistory);

      developer.log(
        'SyncHistoryService: Loaded ${_entries.length} entries from persistence',
        name: 'sync.history',
      );
    } catch (e, stackTrace) {
      developer.log(
        'SyncHistoryService: Error loading persisted history',
        name: 'sync.history',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR
      );
      // Continue with empty history
    }
  }

  /// Save current history to persistent storage
  Future<void> _saveHistory() async {
    if (_persistence == null) return;

    try {
      final result = await _persistence!.saveHistory(_entries);

      if (result.isSuccess) {
        developer.log(
          'SyncHistoryService: Saved ${result.entryCount} entries to persistence',
          name: 'sync.history',
        );
      } else {
        developer.log(
          'SyncHistoryService: Failed to save history: ${result.error}',
          name: 'sync.history',
          level: 900, // WARNING
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'SyncHistoryService: Error saving history',
        name: 'sync.history',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR
      );
    }
  }

  @override
  int get entryCount => _entries.length;

  @override
  List<SyncHistoryEntry> get entries => List.unmodifiable(_entries);

  @override
  Stream<List<SyncHistoryEntry>> get entriesStream {
    if (_isDisposed) {
      throw StateError('SyncHistoryService has been disposed');
    }

    _entriesController ??= StreamController<List<SyncHistoryEntry>>.broadcast(
      onListen: () {
        // Emit current entries when someone starts listening
        if (!_entriesController!.isClosed) {
          _entriesController!.add(List.unmodifiable(_entries));
        }
      },
    );

    return _entriesController!.stream;
  }

  @override
  Future<SyncHistoryEntry?> addEntry(SyncHistoryEntry entry) async {
    if (_isDisposed) {
      developer.log(
        'SyncHistoryService: Cannot add entry - service disposed',
        name: 'sync.history',
        level: 900, // WARNING
      );
      return null;
    }

    try {
      // Remove oldest entry if at capacity
      if (_entries.length >= maxEntries) {
        _entries.removeLast();
        developer.log(
          'SyncHistoryService: Removed oldest entry (at max capacity: $maxEntries)',
          name: 'sync.history',
        );
      }

      // Add new entry at the beginning (newest first)
      _entries.insert(0, entry);

      developer.log(
        'SyncHistoryService: Added entry ${entry.id} '
        '(status: ${entry.status.name}, total: ${entry.totalCount}, '
        'success: ${entry.successCount}, failure: ${entry.failureCount})',
        name: 'sync.history',
      );

      // Auto-save to persistence
      await _saveHistory();

      // Notify listeners
      _notifyListeners();

      return entry;
    } catch (e, stackTrace) {
      developer.log(
        'SyncHistoryService: Error adding entry',
        name: 'sync.history',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR
      );
      return null;
    }
  }

  @override
  Future<bool> updateEntry(String id, SyncHistoryEntry updatedEntry) async {
    if (_isDisposed) {
      return false;
    }

    try {
      final index = _entries.indexWhere((e) => e.id == id);
      if (index == -1) {
        developer.log(
          'SyncHistoryService: Entry $id not found for update',
          name: 'sync.history',
          level: 900, // WARNING
        );
        return false;
      }

      _entries[index] = updatedEntry;

      developer.log(
        'SyncHistoryService: Updated entry $id '
        '(new status: ${updatedEntry.status.name})',
        name: 'sync.history',
      );

      // Auto-save to persistence
      await _saveHistory();

      // Notify listeners
      _notifyListeners();

      return true;
    } catch (e, stackTrace) {
      developer.log(
        'SyncHistoryService: Error updating entry $id',
        name: 'sync.history',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR
      );
      return false;
    }
  }

  @override
  SyncHistoryEntry? getEntryById(String id) {
    return _entries.firstWhereOrNull((e) => e.id == id);
  }

  @override
  SyncHistoryEntry? get latestEntry {
    return _entries.isNotEmpty ? _entries.first : null;
  }

  @override
  List<SyncHistoryEntry> getEntriesByStatus(SyncStatus status) {
    return _entries.where((e) => e.status == status).toList();
  }

  @override
  List<SyncHistoryEntry> getManualSyncs() {
    return _entries.where((e) => e.isManual).toList();
  }

  @override
  List<SyncHistoryEntry> getAutomaticSyncs() {
    return _entries.where((e) => !e.isManual).toList();
  }

  @override
  List<SyncHistoryEntry> getEntriesByDateRange(DateTime start, DateTime end) {
    return _entries.where((e) {
      return e.startedAt.isAfter(start) && e.startedAt.isBefore(end);
    }).toList();
  }

  @override
  List<SyncHistoryEntry> getEntriesFromLastHours(int hours) {
    final cutoff = DateTime.now().subtract(Duration(hours: hours));
    return _entries.where((e) => e.startedAt.isAfter(cutoff)).toList();
  }

  @override
  List<SyncHistoryEntry> getEntriesFromLastDays(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _entries.where((e) => e.startedAt.isAfter(cutoff)).toList();
  }

  @override
  List<SyncHistoryEntry> getLatestEntries(int count) {
    final safeCount = count > _entries.length ? _entries.length : count;
    return _entries.take(safeCount).toList();
  }

  @override
  SyncHistoryStats getStats() {
    final totalSyncs = _entries.length;
    final successfulSyncs = _entries.where((e) => e.isSuccessful).length;
    final failedSyncs = _entries.where((e) => e.isFailed).length;
    final manualSyncs = _entries.where((e) => e.isManual).length;
    final automaticSyncs = _entries.where((e) => !e.isManual).length;

    final successRate = totalSyncs > 0 ? successfulSyncs / totalSyncs : null;

    // Calculate average duration for completed syncs
    final completedSyncs = _entries.where((e) => e.duration != null).toList();
    final averageDuration = completedSyncs.isNotEmpty
        ? Duration(
            microseconds: completedSyncs
                    .map((e) => e.duration!.inMicroseconds)
                    .reduce((a, b) => a + b) ~/
                completedSyncs.length,
          )
        : null;

    // Calculate total operations
    final totalOperations = _entries.fold<int>(
      0,
      (sum, e) => sum + e.totalCount,
    );
    final totalSuccessOperations = _entries.fold<int>(
      0,
      (sum, e) => sum + e.successCount,
    );
    final totalFailedOperations = _entries.fold<int>(
      0,
      (sum, e) => sum + e.failureCount,
    );

    return SyncHistoryStats(
      totalSyncs: totalSyncs,
      successfulSyncs: successfulSyncs,
      failedSyncs: failedSyncs,
      manualSyncs: manualSyncs,
      automaticSyncs: automaticSyncs,
      successRate: successRate,
      averageDuration: averageDuration,
      totalOperations: totalOperations,
      totalSuccessOperations: totalSuccessOperations,
      totalFailedOperations: totalFailedOperations,
    );
  }

  @override
  Future<SyncHistoryResult> clearHistory() async {
    if (_isDisposed) {
      return SyncHistoryResult.failure('Service has been disposed');
    }

    try {
      final count = _entries.length;
      _entries.clear();

      developer.log(
        'SyncHistoryService: Cleared all history ($count entries)',
        name: 'sync.history',
      );

      // Clear persistence
      if (_persistence != null) {
        await _persistence!.clearHistory();
      }

      // Notify listeners
      _notifyListeners();

      return SyncHistoryResult.success(affectedCount: count);
    } catch (e, stackTrace) {
      developer.log(
        'SyncHistoryService: Error clearing history',
        name: 'sync.history',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR
      );
      return SyncHistoryResult.failure('Failed to clear history: ${e.toString()}');
    }
  }

  @override
  Future<int> deleteEntriesOlderThan(DateTime date) async {
    if (_isDisposed) {
      return 0;
    }

    try {
      final initialCount = _entries.length;
      _entries.removeWhere((e) => e.startedAt.isBefore(date));
      final deletedCount = initialCount - _entries.length;

      if (deletedCount > 0) {
        developer.log(
          'SyncHistoryService: Deleted $deletedCount entries older than $date',
          name: 'sync.history',
        );

        // Auto-save to persistence
        await _saveHistory();

        // Notify listeners
        _notifyListeners();
      }

      return deletedCount;
    } catch (e, stackTrace) {
      developer.log(
        'SyncHistoryService: Error deleting entries older than $date',
        name: 'sync.history',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR
      );
      return 0;
    }
  }

  @override
  Future<int> deleteEntriesByStatus(SyncStatus status) async {
    if (_isDisposed) {
      return 0;
    }

    try {
      final initialCount = _entries.length;
      _entries.removeWhere((e) => e.status == status);
      final deletedCount = initialCount - _entries.length;

      if (deletedCount > 0) {
        developer.log(
          'SyncHistoryService: Deleted $deletedCount entries with status $status',
          name: 'sync.history',
        );

        // Auto-save to persistence
        await _saveHistory();

        // Notify listeners
        _notifyListeners();
      }

      return deletedCount;
    } catch (e, stackTrace) {
      developer.log(
        'SyncHistoryService: Error deleting entries with status $status',
        name: 'sync.history',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR
      );
      return 0;
    }
  }

  @override
  String exportToJson() {
    return SyncHistoryEntry.toJsonString(_entries);
  }

  @override
  Future<int> importFromJson(String jsonString) async {
    if (_isDisposed) {
      return 0;
    }

    try {
      final importedEntries = SyncHistoryEntry.fromJsonString(jsonString);

      if (importedEntries.isEmpty) {
        return 0;
      }

      // Merge with existing entries, removing duplicates by ID
      final existingIds = _entries.map((e) => e.id).toSet();
      var addedCount = 0;

      // Add entries in reverse chronological order (newest first)
      for (final entry in importedEntries.reversed) {
        if (!existingIds.contains(entry.id)) {
          // Add at beginning
          _entries.insert(0, entry);
          existingIds.add(entry.id);
          addedCount++;

          // Remove oldest if at capacity
          if (_entries.length > maxEntries) {
            _entries.removeLast();
          }
        }
      }

      // Sort by startedAt descending (newest first)
      _entries.sort((a, b) => b.startedAt.compareTo(a.startedAt));

      developer.log(
        'SyncHistoryService: Imported $addedCount entries from JSON',
        name: 'sync.history',
      );

      // Auto-save to persistence
      await _saveHistory();

      // Notify listeners
      _notifyListeners();

      return addedCount;
    } catch (e, stackTrace) {
      developer.log(
        'SyncHistoryService: Error importing from JSON',
        name: 'sync.history',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR
      );
      return 0;
    }
  }

  /// Notify listeners of entry changes
  void _notifyListeners() {
    if (_isDisposed || _entriesController == null) return;
    if (_entriesController!.isClosed) return;

    _entriesController!.add(List.unmodifiable(_entries));
  }

  @override
  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;
    _entriesController?.close();
    _entriesController = null;

    developer.log(
      'SyncHistoryService: Disposed',
      name: 'sync.history',
    );
  }
}
