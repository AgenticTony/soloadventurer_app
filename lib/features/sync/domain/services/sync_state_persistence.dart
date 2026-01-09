import '../state/sync_state.dart';

/// Result of a state persistence operation
class SyncStatePersistenceResult {
  /// Whether the operation was successful
  final bool success;

  /// Error message if operation failed
  final String? error;

  const SyncStatePersistenceResult({
    required this.success,
    this.error,
  });

  /// Creates a successful result
  factory SyncStatePersistenceResult.success() {
    return const SyncStatePersistenceResult(
      success: true,
    );
  }

  /// Creates a failed result
  factory SyncStatePersistenceResult.failure(String error) {
    return SyncStatePersistenceResult(
      success: false,
      error: error,
    );
  }

  @override
  String toString() =>
      'SyncStatePersistenceResult(success: $success, error: $error)';
}

/// Abstract interface for persisting sync state
///
/// Implementations should handle:
/// - Saving sync state to persistent storage
/// - Loading sync state from persistent storage
/// - Clearing persisted state
/// - Handling corrupted data gracefully
abstract class SyncStatePersistence {
  /// Save the current state to persistent storage
  ///
  /// Returns [SyncStatePersistenceResult] indicating success or failure
  Future<SyncStatePersistenceResult> saveState(SyncState state);

  /// Load the state from persistent storage
  ///
  /// Returns [SyncState] if found, or null if none exist or on error
  Future<SyncState?> loadState();

  /// Clear all persisted state data
  ///
  /// Returns [SyncStatePersistenceResult] indicating success or failure
  Future<SyncStatePersistenceResult> clearState();

  /// Check if there is any persisted state
  ///
  /// Returns [true] if state exists in storage
  Future<bool> hasPersistedState();
}
