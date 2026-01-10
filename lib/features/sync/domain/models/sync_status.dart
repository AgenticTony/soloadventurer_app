/// Sync operation status enumeration representing the current state of synchronization
enum SyncOperationStatus {
  /// Idle - No sync activity, ready to sync
  idle,

  /// Syncing - Currently synchronizing data
  syncing,

  /// Success - Last sync completed successfully
  success,

  /// Failed - Last sync failed and needs retry
  failed,

  /// Pending - Changes waiting to be synced
  pending,
}

/// Extension on SyncOperationStatus for utility methods
extension SyncOperationStatusExtension on SyncOperationStatus {
  /// Whether this status represents an active sync operation
  bool get isActive => this == SyncOperationStatus.syncing;

  /// Whether this status represents a completed sync
  bool get isCompleted =>
      this == SyncOperationStatus.success || this == SyncOperationStatus.failed;

  /// Whether this status represents an error state
  bool get isError => this == SyncOperationStatus.failed;

  /// Whether sync is available (not currently syncing)
  bool get canSync => this != SyncOperationStatus.syncing;

  /// User-friendly display name
  String get displayName {
    switch (this) {
      case SyncOperationStatus.idle:
        return 'Ready';
      case SyncOperationStatus.syncing:
        return 'Syncing...';
      case SyncOperationStatus.success:
        return 'Synced';
      case SyncOperationStatus.failed:
        return 'Sync Failed';
      case SyncOperationStatus.pending:
        return 'Pending';
    }
  }

  /// Icon code point for Material Icons
  int get iconCodePoint {
    switch (this) {
      case SyncOperationStatus.idle:
        return 0xe24e; // sync
      case SyncOperationStatus.syncing:
        return 0xe625; // sync (animated)
      case SyncOperationStatus.success:
        return 0xe876; // check_circle
      case SyncOperationStatus.failed:
        return 0xe000; // error
      case SyncOperationStatus.pending:
        return 0xe923; // schedule
    }
  }
}
