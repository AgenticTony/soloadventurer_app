import 'package:equatable/equatable.dart';
import '../../domain/models/sync_status.dart';

/// State for manual sync operations
///
/// Tracks the status of manually triggered sync operations,
/// including progress, results, and error information.
class ManualSyncState with EquatableMixin {
  /// Current sync status
  final SyncStatus status;

  /// Whether a manual sync is currently in progress
  final bool isSyncing;

  /// Whether the last manual sync was successful
  final bool? lastSyncSuccess;

  /// Number of operations successfully synced in last manual sync
  final int successCount;

  /// Number of operations that failed in last manual sync
  final int failureCount;

  /// Error message if the last manual sync failed
  final String? errorMessage;

  /// Timestamp when the last manual sync completed
  final DateTime? completedAt;

  /// Timestamp when the current manual sync started
  final DateTime? startedAt;

  /// Total number of operations processed
  final int totalProcessed;

  const ManualSyncState({
    required this.status,
    this.isSyncing = false,
    this.lastSyncSuccess,
    this.successCount = 0,
    this.failureCount = 0,
    this.errorMessage,
    this.completedAt,
    this.startedAt,
    this.totalProcessed = 0,
  });

  /// Factory constructor for initial state
  factory ManualSyncState.initial() {
    return ManualSyncState(
      status: SyncStatus.idle,
      isSyncing: false,
    );
  }

  /// Factory constructor for syncing state
  factory ManualSyncState.syncing({
    required DateTime startedAt,
    SyncStatus status = SyncStatus.syncing,
  }) {
    return ManualSyncState(
      status: status,
      isSyncing: true,
      startedAt: startedAt,
    );
  }

  /// Factory constructor for success state
  factory ManualSyncState.success({
    required int successCount,
    required int failureCount,
    required DateTime completedAt,
    DateTime? startedAt,
    int totalProcessed = 0,
    SyncStatus status = SyncStatus.success,
  }) {
    return ManualSyncState(
      status: status,
      isSyncing: false,
      lastSyncSuccess: true,
      successCount: successCount,
      failureCount: failureCount,
      completedAt: completedAt,
      startedAt: startedAt,
      totalProcessed: totalProcessed,
    );
  }

  /// Factory constructor for failure state
  factory ManualSyncState.failure({
    required String errorMessage,
    required DateTime completedAt,
    DateTime? startedAt,
    int successCount = 0,
    int failureCount = 0,
    int totalProcessed = 0,
    SyncStatus status = SyncStatus.failed,
  }) {
    return ManualSyncState(
      status: status,
      isSyncing: false,
      lastSyncSuccess: false,
      successCount: successCount,
      failureCount: failureCount,
      errorMessage: errorMessage,
      completedAt: completedAt,
      startedAt: startedAt,
      totalProcessed: totalProcessed,
    );
  }

  /// Whether the state represents a completed sync
  bool get isCompleted => completedAt != null;

  /// Whether the state represents a failed sync
  bool get isFailed => lastSyncSuccess == false;

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

  /// Create a copy with updated fields
  ManualSyncState copyWith({
    SyncStatus? status,
    bool? isSyncing,
    bool? lastSyncSuccess,
    int? successCount,
    int? failureCount,
    String? errorMessage,
    DateTime? completedAt,
    DateTime? startedAt,
    int? totalProcessed,
  }) {
    return ManualSyncState(
      status: status ?? this.status,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncSuccess: lastSyncSuccess ?? this.lastSyncSuccess,
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
      errorMessage: errorMessage ?? this.errorMessage,
      completedAt: completedAt ?? this.completedAt,
      startedAt: startedAt ?? this.startedAt,
      totalProcessed: totalProcessed ?? this.totalProcessed,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isSyncing,
        lastSyncSuccess,
        successCount,
        failureCount,
        errorMessage,
        completedAt,
        startedAt,
        totalProcessed,
      ];

  @override
  String toString() {
    return 'ManualSyncState('
        'status: $status, '
        'isSyncing: $isSyncing, '
        'lastSyncSuccess: $lastSyncSuccess, '
        'successCount: $successCount, '
        'failureCount: $failureCount, '
        'errorMessage: $errorMessage, '
        'completedAt: $completedAt, '
        'startedAt: $startedAt, '
        'totalProcessed: $totalProcessed)';
  }
}
