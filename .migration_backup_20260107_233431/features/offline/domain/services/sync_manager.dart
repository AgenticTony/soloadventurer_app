import 'dart:async';

/// Sync state enum representing the current synchronization status
enum SyncState {
  /// Sync is idle and not actively syncing
  idle,

  /// Sync is currently in progress
  syncing,

  /// Sync encountered an error
  error,

  /// Sync is paused (e.g., due to being offline)
  paused,
}

/// Sync phase enum for tracking which part of sync is active
enum SyncPhase {
  /// Not currently syncing
  none,

  /// Uploading local changes to server
  upload,

  /// Downloading server changes to local
  download,

  /// Resolving conflicts between local and server
  conflictResolution,

  /// Completing sync process
  finalization,
}

/// Sync result data class
class SyncResult {
  /// Whether the sync was successful
  final bool success;

  /// Number of operations uploaded
  final int uploadedCount;

  /// Number of operations downloaded
  final int downloadedCount;

  /// Number of conflicts resolved
  final int conflictsResolved;

  /// Error message if sync failed
  final String? errorMessage;

  /// Duration of the sync operation
  final Duration duration;

  /// Creates a successful sync result
  const SyncResult.success({
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.conflictsResolved = 0,
    required this.duration,
  })  : success = true,
        errorMessage = null;

  /// Creates a failed sync result
  const SyncResult.failure(
    this.errorMessage, {
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.conflictsResolved = 0,
    required this.duration,
  }) : success = false;

  @override
  String toString() {
    if (success) {
      return 'SyncResult.success(uploaded: $uploadedCount, '
          'downloaded: $downloadedCount, conflicts: $conflictsResolved, '
          'duration: ${duration.inSeconds}s)';
    } else {
      return 'SyncResult.failure(errorMessage: $errorMessage, '
          'duration: ${duration.inSeconds}s)';
    }
  }
}

/// Sync status data class for UI consumption
class SyncStatus {
  /// Current sync state
  final SyncState state;

  /// Current sync phase (if syncing)
  final SyncPhase phase;

  /// Sync progress (0.0 to 1.0)
  final double progress;

  /// Number of pending operations
  final int pendingOperations;

  /// Error message if in error state
  final String? errorMessage;

  /// Last sync timestamp (if any)
  final DateTime? lastSyncTime;

  /// Current sync operation being processed (if any)
  final String? currentOperation;

  /// Creates a new [SyncStatus] instance
  const SyncStatus({
    required this.state,
    this.phase = SyncPhase.none,
    this.progress = 0.0,
    this.pendingOperations = 0,
    this.errorMessage,
    this.lastSyncTime,
    this.currentOperation,
  });

  /// Creates an idle sync status
  factory SyncStatus.idle({int pendingOperations = 0}) {
    return SyncStatus(
      state: SyncState.idle,
      pendingOperations: pendingOperations,
    );
  }

  /// Creates a syncing status
  factory SyncStatus.syncing({
    required SyncPhase phase,
    double progress = 0.0,
    String? currentOperation,
    int pendingOperations = 0,
  }) {
    return SyncStatus(
      state: SyncState.syncing,
      phase: phase,
      progress: progress,
      currentOperation: currentOperation,
      pendingOperations: pendingOperations,
    );
  }

  /// Creates an error status
  factory SyncStatus.error(
    String message, {
    int pendingOperations = 0,
    DateTime? lastSyncTime,
  }) {
    return SyncStatus(
      state: SyncState.error,
      errorMessage: message,
      pendingOperations: pendingOperations,
      lastSyncTime: lastSyncTime,
    );
  }

  /// Creates a paused status
  factory SyncStatus.paused({int pendingOperations = 0}) {
    return SyncStatus(
      state: SyncState.paused,
      pendingOperations: pendingOperations,
    );
  }

  /// Whether sync is currently active
  bool get isSyncing => state == SyncState.syncing;

  /// Whether there was an error
  bool get hasError => state == SyncState.error;

  /// Whether sync is idle
  bool get isIdle => state == SyncState.idle;

  /// Copy with method for immutable updates
  SyncStatus copyWith({
    SyncState? state,
    SyncPhase? phase,
    double? progress,
    int? pendingOperations,
    String? errorMessage,
    DateTime? lastSyncTime,
    String? currentOperation,
  }) {
    return SyncStatus(
      state: state ?? this.state,
      phase: phase ?? this.phase,
      progress: progress ?? this.progress,
      pendingOperations: pendingOperations ?? this.pendingOperations,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      currentOperation: currentOperation ?? this.currentOperation,
    );
  }

  @override
  String toString() {
    return 'SyncStatus{state: $state, phase: $phase, progress: $progress, '
        'pending: $pendingOperations, error: $errorMessage}';
  }
}

/// Abstract sync manager interface
///
/// The sync manager orchestrates all synchronization operations between
/// the local database and remote server. It coordinates upload and download
/// sync processes, handles conflicts, and provides status updates.
///
/// The manager ensures:
/// - Only one sync cycle runs at a time
/// - Sync is triggered automatically when connectivity is restored
/// - Sync status is exposed via a stream for UI updates
/// - Errors are handled gracefully with proper status reporting
///
/// Example usage:
/// ```dart
/// final syncManager = SyncManagerImpl(
///   connectivityService: connectivityService,
///   syncQueueService: syncQueueService,
/// );
///
/// // Initialize the manager
/// await syncManager.initialize();
///
/// // Listen to sync status
/// syncManager.syncStatusStream.listen((status) {
///   print('Sync state: ${status.state}');
///   if (status.isSyncing) {
///     print('Progress: ${(status.progress * 100).toInt()}%');
///   }
/// });
///
/// // Trigger manual sync
/// final result = await syncManager.startSync();
///
/// // Dispose when done
/// syncManager.dispose();
/// ```
abstract class SyncManager {
  /// Stream of sync status updates
  ///
  /// Emits a new [SyncStatus] whenever the sync state changes.
  /// This is useful for UI components that need to display sync progress.
  Stream<SyncStatus> get syncStatusStream;

  /// Gets the current sync status
  ///
  /// Returns the current [SyncStatus] without waiting for stream updates.
  SyncStatus get currentStatus;

  /// Initializes the sync manager
  ///
  /// This method:
  /// 1. Starts listening to connectivity changes
  /// 2. Recovers sync state if app was closed during sync
  /// 3. Emits initial sync status
  ///
  /// Returns [true] if initialization was successful.
  Future<bool> initialize();

  /// Starts a manual sync cycle
  ///
  /// This method initiates a full sync cycle including:
  /// 1. Upload phase: Sync queued local changes to server
  /// 2. Download phase: Pull server changes to local database
  /// 3. Conflict resolution: Resolve any conflicts
  /// 4. Finalization: Complete sync and update metadata
  ///
  /// If a sync cycle is already in progress, this method will return
  /// [false] and the existing sync will continue.
  ///
  /// The [force] parameter allows bypassing certain checks (e.g., syncing
  /// even when queue is empty for a full refresh).
  ///
  /// Returns a [SyncResult] indicating success or failure.
  Future<SyncResult> startSync({bool force = false});

  /// Stops the current sync cycle
  ///
  /// This method gracefully stops the current sync cycle.
  /// Operations that have already started will complete,
  /// but no new operations will begin.
  ///
  /// Returns [true] if sync was stopped, [false] if no sync was in progress.
  Future<bool> stopSync();

  /// Pauses automatic sync triggers
  ///
  /// When paused, the sync manager will not automatically trigger sync
  /// when connectivity changes. Manual sync can still be triggered via
  /// [startSync].
  ///
  /// Use this to temporarily disable auto-sync (e.g., during data imports).
  void pauseAutoSync();

  /// Resumes automatic sync triggers
  ///
  /// Re-enables automatic sync when connectivity changes.
  void resumeAutoSync();

  /// Disposes of resources
  ///
  /// Call this when the sync manager is no longer needed to prevent
  /// memory leaks. This will cancel all streams and subscriptions.
  void dispose();
}
