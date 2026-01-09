import '../entities/journal_entry.dart';
import '../entities/media_item.dart';
import '../entities/trip.dart';
import '../entities/tag.dart';

/// Severity level of a conflict
enum ConflictSeverity {
  /// Low severity - can be auto-resolved
  low,

  /// Medium severity - should be reviewed but auto-resolution is acceptable
  medium,

  /// High severity - requires manual resolution
  high,

  /// Critical - data loss possible, must be manually resolved
  critical,
}

/// Type of conflict that occurred
enum ConflictType {
  /// Same field modified with different values
  fieldConflict,

  /// Item deleted locally but modified remotely
  deletedModified,

  /// Item modified locally but deleted remotely
  modifiedDeleted,

  /// Parent-child relationship conflict (e.g., trip deleted but entries exist)
  relationshipConflict,

  /// Media file conflict (different uploads with same ID)
  mediaConflict,

  /// Multiple concurrent modifications
  concurrentModification,

  /// Unknown conflict type
  unknown,
}

/// Status of a conflict resolution
enum ConflictResolutionStatus {
  /// Conflict is pending resolution
  pending,

  /// Conflict is being actively resolved
  inProgress,

  /// Conflict was successfully resolved
  resolved,

  /// Conflict resolution failed
  failed,

  /// Conflict was ignored/skipped
  ignored,
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

  /// Merge both versions (if possible)
  merge,

  /// Keep both versions (create duplicate)
  keepBoth,
}

/// Detailed information about a specific field conflict
class FieldConflict {
  /// Name of the conflicting field
  final String fieldName;

  /// Local value
  final dynamic localValue;

  /// Remote value
  final dynamic remoteValue;

  /// Whether this field can be automatically merged
  final bool canMerge;

  /// Suggested merged value (if available)
  final dynamic? suggestedValue;

  const FieldConflict({
    required this.fieldName,
    required this.localValue,
    required this.remoteValue,
    this.canMerge = false,
    this.suggestedValue,
  });

  @override
  String toString() {
    return 'FieldConflict($fieldName: local=$localValue, remote=$remoteValue)';
  }
}

/// Represents a conflict between local and remote versions of an item
class SyncConflict {
  /// Unique identifier for this conflict
  final String conflictId;

  /// Type of entity that has a conflict
  final String entityType;

  /// ID of the entity
  final String entityId;

  /// Type of conflict
  final ConflictType conflictType;

  /// Severity of the conflict
  final ConflictSeverity severity;

  /// Local version of the entity
  final Map<String, dynamic> localVersion;

  /// Remote version of the entity
  final Map<String, dynamic> remoteVersion;

  /// Timestamp of local version
  final DateTime localUpdatedAt;

  /// Timestamp of remote version
  final DateTime remoteUpdatedAt;

  /// Human-readable reason for the conflict
  final String reason;

  /// List of specific field conflicts (if available)
  final List<FieldConflict> fieldConflicts;

  /// Current resolution status
  final ConflictResolutionStatus status;

  /// Timestamp when conflict was detected
  final DateTime detectedAt;

  /// Timestamp when conflict was resolved (if applicable)
  final DateTime? resolvedAt;

  /// Resolution strategy used (if resolved)
  final ConflictResolutionStrategy? resolutionStrategy;

  /// Error message if resolution failed
  final String? resolutionError;

  /// Number of retry attempts
  final int retryCount;

  const SyncConflict({
    required this.conflictId,
    required this.entityType,
    required this.entityId,
    required this.conflictType,
    required this.severity,
    required this.localVersion,
    required this.remoteVersion,
    required this.localUpdatedAt,
    required this.remoteUpdatedAt,
    required this.reason,
    this.fieldConflicts = const [],
    this.status = ConflictResolutionStatus.pending,
    required this.detectedAt,
    this.resolvedAt,
    this.resolutionStrategy,
    this.resolutionError,
    this.retryCount = 0,
  });

  /// Creates a copy of this conflict with updated fields
  SyncConflict copyWith({
    String? conflictId,
    String? entityType,
    String? entityId,
    ConflictType? conflictType,
    ConflictSeverity? severity,
    Map<String, dynamic>? localVersion,
    Map<String, dynamic>? remoteVersion,
    DateTime? localUpdatedAt,
    DateTime? remoteUpdatedAt,
    String? reason,
    List<FieldConflict>? fieldConflicts,
    ConflictResolutionStatus? status,
    DateTime? detectedAt,
    DateTime? resolvedAt,
    ConflictResolutionStrategy? resolutionStrategy,
    String? resolutionError,
    int? retryCount,
  }) {
    return SyncConflict(
      conflictId: conflictId ?? this.conflictId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      conflictType: conflictType ?? this.conflictType,
      severity: severity ?? this.severity,
      localVersion: localVersion ?? this.localVersion,
      remoteVersion: remoteVersion ?? this.remoteVersion,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      remoteUpdatedAt: remoteUpdatedAt ?? this.remoteUpdatedAt,
      reason: reason ?? this.reason,
      fieldConflicts: fieldConflicts ?? this.fieldConflicts,
      status: status ?? this.status,
      detectedAt: detectedAt ?? this.detectedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionStrategy: resolutionStrategy ?? this.resolutionStrategy,
      resolutionError: resolutionError ?? this.resolutionError,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  /// Whether this conflict can be auto-resolved
  bool get canAutoResolve =>
      severity != ConflictSeverity.critical &&
      severity != ConflictSeverity.high;

  /// Whether this conflict is resolved
  bool get isResolved =>
      status == ConflictResolutionStatus.resolved ||
      status == ConflictResolutionStatus.ignored;

  /// Whether this conflict failed to resolve
  bool get failed => status == ConflictResolutionStatus.failed;

  /// How long this conflict has been pending
  Duration get pendingDuration =>
      DateTime.now().difference(detectedAt);

  @override
  String toString() {
    return 'SyncConflict('
        'id: $conflictId, '
        'type: $entityType:$entityId, '
        'conflictType: $conflictType, '
        'severity: $severity, '
        'status: $status, '
        'local: ${localUpdatedAt.toIso8601String()}, '
        'remote: ${remoteUpdatedAt.toIso8601String()})';
  }
}

/// Result of a conflict resolution operation
class ConflictResolutionResult {
  /// Whether the resolution was successful
  final bool success;

  /// The conflict that was resolved
  final SyncConflict conflict;

  /// Strategy used for resolution
  final ConflictResolutionStrategy strategy;

  /// The final resolved version
  final Map<String, dynamic>? resolvedVersion;

  /// Error message if resolution failed
  final String? error;

  /// Timestamp when resolution was completed
  final DateTime completedAt;

  const ConflictResolutionResult({
    required this.success,
    required this.conflict,
    required this.strategy,
    this.resolvedVersion,
    this.error,
    required this.completedAt,
  });

  /// Creates a successful resolution result
  factory ConflictResolutionResult.success({
    required SyncConflict conflict,
    required ConflictResolutionStrategy strategy,
    Map<String, dynamic>? resolvedVersion,
  }) {
    return ConflictResolutionResult(
      success: true,
      conflict: conflict,
      strategy: strategy,
      resolvedVersion: resolvedVersion,
      completedAt: DateTime.now(),
    );
  }

  /// Creates a failed resolution result
  factory ConflictResolutionResult.failure({
    required SyncConflict conflict,
    required ConflictResolutionStrategy strategy,
    required String error,
  }) {
    return ConflictResolutionResult(
      success: false,
      conflict: conflict,
      strategy: strategy,
      error: error,
      completedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ConflictResolutionResult('
        'success: $success, '
        'strategy: $strategy, '
        'conflictId: ${conflict.conflictId}'
        '${error != null ? ', error: $error' : ''})';
  }
}

/// Statistics about conflict resolution
class ConflictResolutionStatistics {
  /// Total number of conflicts detected
  final int totalConflicts;

  /// Number of conflicts resolved
  final int resolvedConflicts;

  /// Number of conflicts failed
  final int failedConflicts;

  /// Number of conflicts ignored
  final int ignoredConflicts;

  /// Number of conflicts currently pending
  final int pendingConflicts;

  /// Most common conflict type
  final ConflictType? mostCommonType;

  /// Average resolution time
  final Duration averageResolutionTime;

  const ConflictResolutionStatistics({
    required this.totalConflicts,
    this.resolvedConflicts = 0,
    this.failedConflicts = 0,
    this.ignoredConflicts = 0,
    this.pendingConflicts = 0,
    this.mostCommonType,
    this.averageResolutionTime = Duration.zero,
  });

  /// Resolution success rate (0.0 to 1.0)
  double get successRate {
    if (resolvedConflicts + failedConflicts == 0) return 1.0;
    return resolvedConflicts / (resolvedConflicts + failedConflicts);
  }

  @override
  String toString() {
    return 'ConflictResolutionStatistics('
        'total: $totalConflicts, '
        'resolved: $resolvedConflicts, '
        'failed: $failedConflicts, '
        'pending: $pendingConflicts, '
        'successRate: ${(successRate * 100).toStringAsFixed(1)}%)';
  }
}

/// Callback for conflict detection
typedef ConflictDetectedCallback = void Function(SyncConflict conflict);

/// Callback for conflict resolution
typedef ConflictResolvedCallback = void Function(
  SyncConflict conflict,
  ConflictResolutionResult result,
);

/// Service responsible for detecting, storing, and resolving sync conflicts
///
/// This service handles:
/// - Detecting conflicts between local and remote data
/// - Storing conflicts for later resolution
/// - Providing multiple resolution strategies
/// - Tracking conflict resolution history
/// - Analyzing field-level conflicts
/// - Suggesting resolutions based on conflict type
abstract class ConflictResolutionService {
  /// Stream of newly detected conflicts
  Stream<SyncConflict> get conflictStream;

  /// Stream of resolved conflicts
  Stream<ConflictResolutionResult> get resolutionStream;

  /// Whether there are any pending conflicts
  Future<bool> get hasPendingConflicts;

  /// Get all pending conflicts
  Future<List<SyncConflict>> getPendingConflicts();

  /// Get all conflicts (including resolved)
  Future<List<SyncConflict>> getAllConflicts();

  /// Get conflicts by entity type
  Future<List<SyncConflict>> getConflictsByType(String entityType);

  /// Get conflicts by severity
  Future<List<SyncConflict>> getConflictsBySeverity(ConflictSeverity severity);

  /// Get a specific conflict by ID
  Future<SyncConflict?> getConflict(String conflictId);

  /// Detect conflicts between local and remote versions
  ///
  /// [entityType] - Type of entity to check
  /// [localVersion] - Local version of the entity
  /// [remoteVersion] - Remote version of the entity
  ///
  /// Returns detected conflict or null if no conflict
  Future<SyncConflict?> detectConflict({
    required String entityType,
    required Map<String, dynamic> localVersion,
    required Map<String, dynamic> remoteVersion,
  });

  /// Detect and analyze field-level conflicts
  ///
  /// [localVersion] - Local version of the entity
  /// [remoteVersion] - Remote version of the entity
  /// [fields] - List of field names to check
  ///
  /// Returns list of field conflicts
  List<FieldConflict> detectFieldConflicts({
    required Map<String, dynamic> localVersion,
    required Map<String, dynamic> remoteVersion,
    required List<String> fields,
  });

  /// Resolve a conflict using the specified strategy
  ///
  /// [conflict] - The conflict to resolve
  /// [strategy] - Resolution strategy to use
  /// [resolvedVersion] - Custom resolved version (for manual strategy)
  ///
  /// Returns resolution result
  Future<ConflictResolutionResult> resolveConflict(
    SyncConflict conflict,
    ConflictResolutionStrategy strategy, {
    Map<String, dynamic>? resolvedVersion,
  });

  /// Auto-resolve multiple conflicts using specified strategy
  ///
  /// [conflicts] - List of conflicts to resolve
  /// [strategy] - Resolution strategy to use
  ///
  /// Returns list of resolution results
  Future<List<ConflictResolutionResult>> resolveMultipleConflicts(
    List<SyncConflict> conflicts,
    ConflictResolutionStrategy strategy,
  );

  /// Resolve all pending conflicts using specified strategy
  ///
  /// [strategy] - Resolution strategy to use
  /// [severity] - Only resolve conflicts up to this severity
  ///
  /// Returns list of resolution results
  Future<List<ConflictResolutionResult>> resolveAllPending(
    ConflictResolutionStrategy strategy, {
    ConflictSeverity? maxSeverity,
  });

  /// Ignore a conflict (mark as ignored without resolving)
  Future<void> ignoreConflict(String conflictId);

  /// Retry a failed conflict resolution
  Future<ConflictResolutionResult?> retryConflict(String conflictId);

  /// Get conflict resolution statistics
  Future<ConflictResolutionStatistics> getStatistics();

  /// Get resolution history for an entity
  Future<List<SyncConflict>> getResolutionHistory(String entityId);

  /// Clear all resolved conflicts (cleanup)
  Future<void> clearResolvedConflicts();

  /// Clear all conflicts (for testing/debugging)
  Future<void> clearAllConflicts();

  /// Register callback for conflict detection
  void onConflictDetected(ConflictDetectedCallback callback);

  /// Register callback for conflict resolution
  void onConflictResolved(ConflictResolvedCallback callback);

  /// Unregister conflict detection callback
  void removeConflictDetectedCallback(ConflictDetectedCallback callback);

  /// Unregister conflict resolution callback
  void removeConflictResolvedCallback(ConflictResolvedCallback callback);

  /// Initialize the conflict resolution service
  Future<void> initialize();

  /// Dispose the conflict resolution service
  Future<void> dispose();
}
