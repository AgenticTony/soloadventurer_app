import 'package:equatable/equatable.dart';
import '../../domain/models/sync_status.dart';

/// Comprehensive state for sync operations
///
/// Tracks all sync-related state including current status,
/// queue information, and last sync results for real-time UI updates.
class SyncState with EquatableMixin {
  /// Current sync status
  final SyncStatus status;

  /// Number of operations in the sync queue
  final int queueSize;

  /// Whether sync is currently processing
  final bool isProcessing;

  /// Timestamp of last status change
  final DateTime? lastStatusChangeAt;

  /// Timestamp of last successful sync
  final DateTime? lastSuccessfulSyncAt;

  /// Number of operations successfully synced in last sync
  final int lastSuccessCount;

  /// Number of operations that failed in last sync
  final int lastFailureCount;

  /// Error message from last failed sync (if any)
  final String? lastError;

  /// Whether there are pending operations
  final bool hasPendingOperations;

  const SyncState({
    required this.status,
    this.queueSize = 0,
    this.isProcessing = false,
    this.lastStatusChangeAt,
    this.lastSuccessfulSyncAt,
    this.lastSuccessCount = 0,
    this.lastFailureCount = 0,
    this.lastError,
    this.hasPendingOperations = false,
  });

  /// Factory constructor for initial state
  factory SyncState.initial() {
    return const SyncState(
      status: SyncStatus.idle,
      queueSize: 0,
      isProcessing: false,
    );
  }

  /// Whether the current state represents an active sync
  bool get isSyncing => status == SyncStatus.syncing;

  /// Whether the last sync was successful
  bool get wasLastSyncSuccessful => status == SyncStatus.success;

  /// Whether the last sync failed
  bool get didLastSyncFail => status == SyncStatus.failed;

  /// Whether there are operations waiting to sync
  bool get hasQueue => queueSize > 0;

  /// Total operations from last sync
  int get lastTotalOperations => lastSuccessCount + lastFailureCount;

  /// Success rate of last sync (0.0 to 1.0, or null if no operations)
  double? get lastSuccessRate {
    if (lastTotalOperations == 0) return null;
    return lastSuccessCount / lastTotalOperations;
  }

  /// Create a copy with updated fields
  SyncState copyWith({
    SyncStatus? status,
    int? queueSize,
    bool? isProcessing,
    DateTime? lastStatusChangeAt,
    DateTime? lastSuccessfulSyncAt,
    int? lastSuccessCount,
    int? lastFailureCount,
    String? lastError,
    bool? hasPendingOperations,
    bool clearLastError = false,
  }) {
    return SyncState(
      status: status ?? this.status,
      queueSize: queueSize ?? this.queueSize,
      isProcessing: isProcessing ?? this.isProcessing,
      lastStatusChangeAt: lastStatusChangeAt ?? this.lastStatusChangeAt,
      lastSuccessfulSyncAt: lastSuccessfulSyncAt ?? this.lastSuccessfulSyncAt,
      lastSuccessCount: lastSuccessCount ?? this.lastSuccessCount,
      lastFailureCount: lastFailureCount ?? this.lastFailureCount,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
      hasPendingOperations: hasPendingOperations ?? this.hasPendingOperations,
    );
  }

  @override
  List<Object?> get props => [
        status,
        queueSize,
        isProcessing,
        lastStatusChangeAt,
        lastSuccessfulSyncAt,
        lastSuccessCount,
        lastFailureCount,
        lastError,
        hasPendingOperations,
      ];

  @override
  String toString() {
    return 'SyncState('
        'status: $status, '
        'queueSize: $queueSize, '
        'isProcessing: $isProcessing, '
        'hasPendingOperations: $hasPendingOperations, '
        'lastSuccessCount: $lastSuccessCount, '
        'lastFailureCount: $lastFailureCount, '
        'lastError: $lastError)';
  }
}
