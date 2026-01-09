import 'package:flutter/foundation.dart';
import '../models/sync_status.dart';
import '../entities/sync_entity_type.dart';

/// Represents the current synchronization state of the application
@immutable
class SyncState {
  /// Current sync status
  final SyncStatus status;

  /// Number of pending operations waiting to sync
  final int pendingCount;

  /// Number of operations that failed during last sync
  final int failedCount;

  /// Last successful sync timestamp
  final DateTime? lastSyncTime;

  /// Current error message, if any
  final String? error;

  /// Error code for specific error handling
  final String? errorCode;

  /// Sync progress for current operation (0.0 to 1.0)
  final double syncProgress;

  /// Entity types that have pending changes
  final List<SyncEntityType> pendingEntityTypes;

  /// Whether sync is currently in progress
  bool get isSyncing => status == SyncStatus.syncing;

  /// Whether there are pending changes
  bool get hasPending => pendingCount > 0;

  /// Whether the last sync was successful
  bool get isSuccessful => status == SyncStatus.success;

  /// Whether there are errors
  bool get hasError => status == SyncStatus.failed;

  /// Creates a new [SyncState]
  const SyncState({
    this.status = SyncStatus.idle,
    this.pendingCount = 0,
    this.failedCount = 0,
    this.lastSyncTime,
    this.error,
    this.errorCode,
    this.syncProgress = 0.0,
    this.pendingEntityTypes = const [],
  });

  /// Creates a copy of this state with the given fields replaced
  SyncState copyWith({
    SyncStatus? status,
    int? pendingCount,
    int? failedCount,
    DateTime? lastSyncTime,
    String? error,
    String? errorCode,
    double? syncProgress,
    List<SyncEntityType>? pendingEntityTypes,
  }) {
    return SyncState(
      status: status ?? this.status,
      pendingCount: pendingCount ?? this.pendingCount,
      failedCount: failedCount ?? this.failedCount,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      error: error, // Intentionally not using ?? to allow clearing errors
      errorCode: errorCode, // Intentionally not using ?? to allow clearing codes
      syncProgress: syncProgress ?? this.syncProgress,
      pendingEntityTypes:
          pendingEntityTypes ?? this.pendingEntityTypes,
    );
  }

  /// Creates an initial state
  factory SyncState.initial() => const SyncState();

  /// Creates an idle state
  factory SyncState.idle() => const SyncState(status: SyncStatus.idle);

  /// Creates a syncing state
  factory SyncState.syncing({
    double progress = 0.0,
    List<SyncEntityType> pendingEntityTypes = const [],
  }) => SyncState(
        status: SyncStatus.syncing,
        syncProgress: progress,
        pendingEntityTypes: pendingEntityTypes,
      );

  /// Creates a success state
  factory SyncState.success({
    DateTime? syncTime,
    int? pendingCount,
    List<SyncEntityType> pendingEntityTypes = const [],
  }) => SyncState(
        status: SyncStatus.success,
        lastSyncTime: syncTime ?? DateTime.now(),
        pendingCount: pendingCount ?? 0,
        pendingEntityTypes: pendingEntityTypes,
      );

  /// Creates a failed state
  factory SyncState.failed(
    String message, {
    String? code,
    int? failedCount,
    List<SyncEntityType> pendingEntityTypes = const [],
  }) => SyncState(
        status: SyncStatus.failed,
        error: message,
        errorCode: code,
        failedCount: failedCount ?? 0,
        pendingEntityTypes: pendingEntityTypes,
      );

  /// Creates a pending state
  factory SyncState.pending({
    required int count,
    List<SyncEntityType> pendingEntityTypes = const [],
  }) => SyncState(
        status: SyncStatus.pending,
        pendingCount: count,
        pendingEntityTypes: pendingEntityTypes,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          pendingCount == other.pendingCount &&
          failedCount == other.failedCount &&
          lastSyncTime == other.lastSyncTime &&
          error == other.error &&
          errorCode == other.errorCode &&
          syncProgress == other.syncProgress &&
          listEquals(pendingEntityTypes, other.pendingEntityTypes);

  @override
  int get hashCode =>
      status.hashCode ^
      pendingCount.hashCode ^
      failedCount.hashCode ^
      lastSyncTime.hashCode ^
      error.hashCode ^
      errorCode.hashCode ^
      syncProgress.hashCode ^
      pendingEntityTypes.hashCode;

  @override
  String toString() =>
      'SyncState(status: $status, pendingCount: $pendingCount, '
      'failedCount: $failedCount, lastSyncTime: $lastSyncTime, '
      'error: $error, errorCode: $errorCode, syncProgress: $syncProgress, '
      'pendingEntityTypes: $pendingEntityTypes)';
}
