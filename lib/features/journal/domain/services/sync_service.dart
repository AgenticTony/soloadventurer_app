/// Status of a sync operation
enum SyncOperationType {
  /// Syncing journal entries
  entries,

  /// Syncing media items
  media,

  /// Syncing trips
  trips,

  /// Syncing tags
  tags,

  /// Full sync of all data
  full,
}

/// Direction of data flow during sync
enum SyncDirection {
  /// Upload local changes to remote
  upload,

  /// Download remote changes to local
  download,

  /// Bidirectional sync (both directions)
  bidirectional,
}

/// Result of a sync operation
class SyncResult {
  /// The type of sync operation
  final SyncOperationType operationType;

  /// Direction of the sync
  final SyncDirection direction;

  /// Whether the sync was successful
  final bool success;

  /// Number of items uploaded
  final int uploadedCount;

  /// Number of items downloaded
  final int downloadedCount;

  /// Number of items that had conflicts
  final int conflictCount;

  /// Number of items that failed to sync
  final int failedCount;

  /// Error messages for failed items
  final List<String> errors;

  /// Timestamp when sync started
  final DateTime startedAt;

  /// Timestamp when sync completed
  final DateTime completedAt;

  /// Total duration of the sync
  Duration get duration => completedAt.difference(startedAt);

  const SyncResult({
    required this.operationType,
    required this.direction,
    required this.success,
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.conflictCount = 0,
    this.failedCount = 0,
    this.errors = const [],
    required this.startedAt,
    required this.completedAt,
  });

  /// Creates a successful sync result
  factory SyncResult.success({
    required SyncOperationType operationType,
    required SyncDirection direction,
    int uploadedCount = 0,
    int downloadedCount = 0,
    int conflictCount = 0,
    required DateTime startedAt,
  }) {
    return SyncResult(
      operationType: operationType,
      direction: direction,
      success: true,
      uploadedCount: uploadedCount,
      downloadedCount: downloadedCount,
      conflictCount: conflictCount,
      startedAt: startedAt,
      completedAt: DateTime.now(),
    );
  }

  /// Creates a failed sync result
  factory SyncResult.failure({
    required SyncOperationType operationType,
    required SyncDirection direction,
    required List<String> errors,
    required DateTime startedAt,
  }) {
    return SyncResult(
      operationType: operationType,
      direction: direction,
      success: false,
      failedCount: errors.length,
      errors: errors,
      startedAt: startedAt,
      completedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'SyncResult('
        'type: $operationType, '
        'direction: $direction, '
        'success: $success, '
        'uploaded: $uploadedCount, '
        'downloaded: $downloadedCount, '
        'conflicts: $conflictCount, '
        'failed: $failedCount, '
        'duration: ${duration.inSeconds}s'
        ')';
  }
}

/// Status of an individual item during sync
enum ItemSyncStatus {
  /// Item is pending sync
  pending,

  /// Item is currently syncing
  syncing,

  /// Item successfully synced
  synced,

  /// Item failed to sync
  failed,

  /// Item has a conflict
  conflict,
}

/// Information about an item being synced
class SyncItem {
  /// Type of entity being synced
  final String entityType;

  /// ID of the entity
  final String entityId;

  /// Current sync status
  final ItemSyncStatus status;

  /// Sync direction for this item
  final SyncDirection direction;

  /// Timestamp of last sync attempt
  final DateTime? lastSyncAttempt;

  /// Error message if sync failed
  final String? error;

  const SyncItem({
    required this.entityType,
    required this.entityId,
    required this.status,
    required this.direction,
    this.lastSyncAttempt,
    this.error,
  });

  @override
  String toString() {
    return 'SyncItem($entityType:$entityId, $status, $direction)';
  }
}

/// Configuration for sync operations
class SyncConfig {
  /// Maximum number of items to sync in a single batch
  final int batchSize;

  /// Delay between sync batches (milliseconds)
  final int batchDelay;

  /// Maximum number of retry attempts for failed items
  final int maxRetries;

  /// Timeout for individual sync operations
  final Duration operationTimeout;

  /// Whether to sync media files (can be bandwidth intensive)
  final bool syncMedia;

  /// Whether to resolve conflicts automatically
  final bool autoResolveConflicts;

  /// Conflict resolution strategy
  final ConflictResolutionStrategy conflictStrategy;

  /// Whether to sync only pending items or do a full sync
  final bool syncPendingOnly;

  /// Default configuration
  static const defaultConfig = SyncConfig(
    batchSize: 50,
    batchDelay: 100,
    maxRetries: 3,
    operationTimeout: Duration(seconds: 30),
    syncMedia: true,
    autoResolveConflicts: false,
    conflictResolutionStrategy: ConflictResolutionStrategy.mostRecent,
    syncPendingOnly: false,
  );

  /// Configuration for quick sync (pending items only)
  static const quickConfig = SyncConfig(
    batchSize: 20,
    batchDelay: 50,
    maxRetries: 2,
    operationTimeout: Duration(seconds: 15),
    syncMedia: false,
    autoResolveConflicts: true,
    conflictResolutionStrategy: ConflictResolutionStrategy.mostRecent,
    syncPendingOnly: true,
  );

  /// Configuration for full sync
  static const fullConfig = SyncConfig(
    batchSize: 100,
    batchDelay: 200,
    maxRetries: 5,
    operationTimeout: Duration(minutes: 1),
    syncMedia: true,
    autoResolveConflicts: false,
    conflictResolutionStrategy: ConflictResolutionStrategy.manual,
    syncPendingOnly: false,
  );

  const SyncConfig({
    this.batchSize = 50,
    this.batchDelay = 100,
    this.maxRetries = 3,
    this.operationTimeout = const Duration(seconds: 30),
    this.syncMedia = true,
    this.autoResolveConflicts = false,
    this.conflictResolutionStrategy = ConflictResolutionStrategy.mostRecent,
    this.syncPendingOnly = false,
  });
}

/// Strategy for resolving sync conflicts
enum ConflictResolutionStrategy {
  /// Use the most recently updated version
  mostRecent,

  /// Always prefer local changes
  localWins,

  /// Always prefer remote changes
  remoteWins,

  /// Manual resolution required
  manual,
}

/// Represents a conflict between local and remote versions of an item
class SyncConflict {
  /// Type of entity that has a conflict
  final String entityType;

  /// ID of the entity
  final String entityId;

  /// Local version of the entity
  final Map<String, dynamic> localVersion;

  /// Remote version of the entity
  final Map<String, dynamic> remoteVersion;

  /// Timestamp of local version
  final DateTime localUpdatedAt;

  /// Timestamp of remote version
  final DateTime remoteUpdatedAt;

  /// Reason for the conflict
  final String reason;

  const SyncConflict({
    required this.entityType,
    required this.entityId,
    required this.localVersion,
    required this.remoteVersion,
    required this.localUpdatedAt,
    required this.remoteUpdatedAt,
    required this.reason,
  });

  @override
  String toString() {
    return 'SyncConflict($entityType:$entityId, '
        'local: ${localUpdatedAt.toIso8601String()}, '
        'remote: ${remoteUpdatedAt.toIso8601String()})';
  }
}

/// Progress information for sync operations
class SyncProgress {
  /// Total number of items to sync
  final int totalItems;

  /// Number of items successfully synced
  final int syncedItems;

  /// Number of items currently syncing
  final int syncingItems;

  /// Number of items with conflicts
  final int conflictItems;

  /// Number of items that failed
  final int failedItems;

  /// Current operation type
  final SyncOperationType? currentOperation;

  /// Overall progress (0.0 to 1.0)
  double get progress {
    if (totalItems == 0) return 0.0;
    return syncedItems / totalItems;
  }

  /// Whether sync is complete
  bool get isComplete => syncedItems >= totalItems;

  /// Whether sync has errors
  bool get hasErrors => failedItems > 0;

  /// Whether sync has conflicts
  bool get hasConflicts => conflictItems > 0;

  const SyncProgress({
    required this.totalItems,
    this.syncedItems = 0,
    this.syncingItems = 0,
    this.conflictItems = 0,
    this.failedItems = 0,
    this.currentOperation,
  });

  @override
  String toString() {
    return 'SyncProgress('
        'synced: $syncedItems/$totalItems, '
        'syncing: $syncingItems, '
        'conflicts: $conflictItems, '
        'failed: $failedItems, '
        'progress: ${(progress * 100).toStringAsFixed(1)}%'
        ')';
  }
}

/// Callback for sync progress updates
typedef SyncProgressCallback = void Function(SyncProgress progress);

/// Callback for sync conflict detection
typedef SyncConflictCallback = void Function(SyncConflict conflict);

/// Service responsible for bidirectional synchronization between local and remote databases
///
/// This service handles:
/// - Syncing journal entries, media, trips, and tags
/// - Detecting and resolving conflicts
/// - Tracking sync progress
/// - Handling network failures and retries
/// - Batch operations for efficiency
/// - Offline-first with sync when connected
abstract class SyncService {
  /// Current sync progress
  SyncProgress get currentProgress;

  /// Stream of sync progress updates
  Stream<SyncProgress> get progressStream;

  /// Stream of detected conflicts
  Stream<SyncConflict> get conflictStream;

  /// Whether a sync is currently in progress
  bool get isSyncing;

  /// Last successful sync timestamp
  DateTime? get lastSyncTime;

  /// Perform a full sync of all data
  ///
  /// [config] - Optional sync configuration
  ///
  /// Returns the sync result
  Future<SyncResult> syncAll([SyncConfig? config]);

  /// Sync only journal entries
  ///
  /// [direction] - Direction of sync (default: bidirectional)
  /// [config] - Optional sync configuration
  Future<SyncResult> syncEntries([
    SyncDirection direction = SyncDirection.bidirectional,
    SyncConfig? config,
  ]);

  /// Sync only media items
  ///
  /// [direction] - Direction of sync (default: bidirectional)
  /// [config] - Optional sync configuration
  Future<SyncResult> syncMedia([
    SyncDirection direction = SyncDirection.bidirectional,
    SyncConfig? config,
  ]);

  /// Sync only trips
  ///
  /// [direction] - Direction of sync (default: bidirectional)
  /// [config] - Optional sync configuration
  Future<SyncResult> syncTrips([
    SyncDirection direction = SyncDirection.bidirectional,
    SyncConfig? config,
  ]);

  /// Sync only tags
  ///
  /// [direction] - Direction of sync (default: bidirectional)
  /// [config] - Optional sync configuration
  Future<SyncResult> syncTags([
    SyncDirection direction = SyncDirection.bidirectional,
    SyncConfig? config,
  ]);

  /// Sync pending items only (faster than full sync)
  ///
  /// Items with sync status 'pending' or 'conflict' will be synced
  Future<SyncResult> syncPending();

  /// Upload local changes to remote
  Future<SyncResult> uploadChanges();

  /// Download remote changes to local
  Future<SyncResult> downloadChanges();

  /// Resolve a specific conflict
  ///
  /// [conflict] - The conflict to resolve
  /// [strategy] - Resolution strategy to apply
  /// [resolvedVersion] - The resolved version (for manual resolution)
  Future<void> resolveConflict(
    SyncConflict conflict,
    ConflictResolutionStrategy strategy, {
    Map<String, dynamic>? resolvedVersion,
  });

  /// Get all pending conflicts
  Future<List<SyncConflict>> getPendingConflicts();

  /// Cancel the current sync operation
  Future<void> cancelSync();

  /// Register a callback for progress updates
  void onProgressUpdate(SyncProgressCallback callback);

  /// Register a callback for conflict detection
  void onConflictDetected(SyncConflictCallback callback);

  /// Unregister progress callback
  void removeProgressCallback(SyncProgressCallback callback);

  /// Unregister conflict callback
  void removeConflictCallback(SyncConflictCallback callback);

  /// Get sync statistics
  SyncStatistics getStatistics();

  /// Clear all sync state (for testing/debugging)
  Future<void> clearSyncState();

  /// Initialize the sync service
  Future<void> initialize();

  /// Dispose the sync service
  Future<void> dispose();
}

/// Statistics about sync operations
class SyncStatistics {
  /// Total number of sync operations performed
  final int totalSyncs;

  /// Number of successful syncs
  final int successfulSyncs;

  /// Number of failed syncs
  final int failedSyncs;

  /// Total items uploaded
  final int totalUploaded;

  /// Total items downloaded
  final int totalDownloaded;

  /// Total conflicts resolved
  final int totalConflictsResolved;

  /// Average sync duration
  final Duration averageDuration;

  /// Last sync timestamp
  final DateTime? lastSyncTime;

  /// Total data transferred (bytes)
  final int totalDataTransferred;

  const SyncStatistics({
    required this.totalSyncs,
    required this.successfulSyncs,
    required this.failedSyncs,
    this.totalUploaded = 0,
    this.totalDownloaded = 0,
    this.totalConflictsResolved = 0,
    this.averageDuration = Duration.zero,
    this.lastSyncTime,
    this.totalDataTransferred = 0,
  });

  /// Calculate success rate (0.0 to 1.0)
  double get successRate {
    if (totalSyncs == 0) return 0.0;
    return successfulSyncs / totalSyncs;
  }

  @override
  String toString() {
    return 'SyncStatistics('
        'total: $totalSyncs, '
        'successful: $successfulSyncs, '
        'failed: $failedSyncs, '
        'uploaded: $totalUploaded, '
        'downloaded: $totalDownloaded, '
        'conflicts: $totalConflictsResolved, '
        'successRate: ${(successRate * 100).toStringAsFixed(1)}%'
        ')';
  }
}
