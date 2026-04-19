import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/sync_status.dart';

part 'manual_sync_state.freezed.dart';

/// State for manual sync operations
///
/// Tracks the status of manually triggered sync operations,
/// including progress and results.
///
/// Riverpod 3.0 Migration:
/// - Removed isSyncing (handled by AsyncValue loading state)
/// - Removed errorMessage (handled by AsyncValue error state)
/// - Removed lastSyncSuccess (derived from status)
/// - Uses @freezed for immutability and copyWith
@freezed
sealed class ManualSyncState with _$ManualSyncState {
  const ManualSyncState._();

  /// Default constructor
  const factory ManualSyncState({
    /// Current sync status
    required SyncOperationStatus status,

    /// Number of operations successfully synced in last manual sync
    @Default(0) int successCount,

    /// Number of operations that failed in last manual sync
    @Default(0) int failureCount,

    /// Timestamp when the last manual sync completed
    DateTime? completedAt,

    /// Timestamp when the current manual sync started
    DateTime? startedAt,

    /// Total number of operations processed
    @Default(0) int totalProcessed,
  }) = _ManualSyncState;

  /// Factory constructor for initial state
  factory ManualSyncState.initial() => const ManualSyncState(
        status: SyncOperationStatus.idle,
      );

  /// Factory constructor for syncing state
  factory ManualSyncState.syncing({
    required DateTime startedAt,
    SyncOperationStatus status = SyncOperationStatus.syncing,
  }) =>
      ManualSyncState(
        status: status,
        startedAt: startedAt,
      );

  /// Factory constructor for success state
  factory ManualSyncState.success({
    required int successCount,
    required int failureCount,
    required DateTime completedAt,
    DateTime? startedAt,
    int totalProcessed = 0,
    SyncOperationStatus status = SyncOperationStatus.success,
  }) =>
      ManualSyncState(
        status: status,
        successCount: successCount,
        failureCount: failureCount,
        completedAt: completedAt,
        startedAt: startedAt,
        totalProcessed: totalProcessed,
      );

  /// Factory constructor for failure state
  factory ManualSyncState.failure({
    required DateTime completedAt,
    DateTime? startedAt,
    int successCount = 0,
    int failureCount = 0,
    int totalProcessed = 0,
    SyncOperationStatus status = SyncOperationStatus.failed,
  }) =>
      ManualSyncState(
        status: status,
        successCount: successCount,
        failureCount: failureCount,
        completedAt: completedAt,
        startedAt: startedAt,
        totalProcessed: totalProcessed,
      );

  /// Whether the current state represents an active sync
  bool get isSyncing => status == SyncOperationStatus.syncing;

  /// Whether the last manual sync was successful
  bool? get lastSyncSuccess {
    if (completedAt == null) return null;
    return status == SyncOperationStatus.success;
  }

  /// Whether the state represents a completed sync
  bool get isCompleted => completedAt != null;

  /// Whether the state represents a failed sync
  bool get isFailed => status == SyncOperationStatus.failed;

  /// Whether there are any results from a sync
  bool get hasResults => successCount > 0 || failureCount > 0;

  /// Total count of operations (success + failure)
  int get totalOperations => successCount + failureCount;

  /// Calculate sync duration
  ///
  /// Returns null if sync hasn't completed or doesn't have start time
  Duration? get duration {
    if (startedAt == null || completedAt == null) {
      return null;
    }
    return completedAt!.difference(startedAt!);
  }

  /// Calculate sync success rate
  ///
  /// Returns null if no operations were processed
  double? get successRate {
    if (totalOperations == 0) {
      return null;
    }
    return successCount / totalOperations;
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() => {
        'status': status.name,
        'successCount': successCount,
        'failureCount': failureCount,
        'completedAt': completedAt?.toIso8601String(),
        'startedAt': startedAt?.toIso8601String(),
        'totalProcessed': totalProcessed,
      };
}
