/// Sync status enumeration representing the current state of synchronization
enum SyncStatus {
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

/// Extension on SyncStatus for utility methods
extension SyncStatusExtension on SyncStatus {
  /// Whether this status represents an active sync operation
  bool get isActive => this == SyncStatus.syncing;

  /// Whether this status represents a completed sync
  bool get isCompleted =>
      this == SyncStatus.success || this == SyncStatus.failed;

  /// Whether this status represents an error state
  bool get isError => this == SyncStatus.failed;

  /// Whether sync is available (not currently syncing)
  bool get canSync => this != SyncStatus.syncing;

  /// User-friendly display name
  String get displayName {
    switch (this) {
      case SyncStatus.idle:
        return 'Ready';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.success:
        return 'Synced';
      case SyncStatus.failed:
        return 'Sync Failed';
      case SyncStatus.pending:
        return 'Pending';
    }
  }

  /// Icon code point for Material Icons
  int get iconCodePoint {
    switch (this) {
      case SyncStatus.idle:
        return 0xe24e; // sync
      case SyncStatus.syncing:
        return 0xe625; // sync (animated)
      case SyncStatus.success:
        return 0xe876; // check_circle
      case SyncStatus.failed:
        return 0xe000; // error
      case SyncStatus.pending:
        return 0xe923; // schedule
    }
  }
}
