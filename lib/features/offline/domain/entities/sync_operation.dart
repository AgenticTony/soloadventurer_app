import 'package:equatable/equatable.dart';

/// Types of sync operations that can be performed on entities
enum SyncOperationType {
  /// Create a new entity on the server
  create,

  /// Update an existing entity on the server
  update,

  /// Delete an entity from the server
  delete;

  /// String value of the operation type
  String get value {
    switch (this) {
      case SyncOperationType.create:
        return 'create';
      case SyncOperationType.update:
        return 'update';
      case SyncOperationType.delete:
        return 'delete';
    }
  }

  /// Creates a SyncOperationType from a string value
  static SyncOperationType fromString(String value) {
    return SyncOperationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid sync operation type: $value'),
    );
  }
}

/// Priority levels for sync operations
enum SyncPriority {
  /// High priority operations (e.g., user-initiated actions)
  high,

  /// Normal priority operations (default)
  normal,

  /// Low priority operations (e.g., background sync)
  low;

  /// String value of the priority
  String get value {
    switch (this) {
      case SyncPriority.high:
        return 'high';
      case SyncPriority.normal:
        return 'normal';
      case SyncPriority.low:
        return 'low';
    }
  }

  /// Creates a SyncPriority from a string value
  static SyncPriority fromString(String value) {
    return SyncPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => throw ArgumentError('Invalid sync priority: $value'),
    );
  }
}

/// Status of a sync operation
enum SyncOperationStatus {
  /// Operation is waiting to be processed
  pending,

  /// Operation is currently being processed
  processing,

  /// Operation completed successfully
  completed,

  /// Operation failed (may be retried)
  failed;

  /// String value of the status
  String get value {
    switch (this) {
      case SyncOperationStatus.pending:
        return 'pending';
      case SyncOperationStatus.processing:
        return 'processing';
      case SyncOperationStatus.completed:
        return 'completed';
      case SyncOperationStatus.failed:
        return 'failed';
    }
  }

  /// Creates a SyncOperationStatus from a string value
  static SyncOperationStatus fromString(String value) {
    return SyncOperationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Invalid sync status: $value'),
    );
  }
}

/// Domain entity representing a sync operation in the queue
///
/// This entity represents an operation that needs to be synchronized with the server.
/// It contains all the metadata needed to track, prioritize, and retry the operation.
class SyncOperationEntity extends Equatable {
  /// Unique identifier for this sync operation
  final int id;

  /// Type of entity being synchronized (e.g., 'trip', 'journal', 'user')
  final String entityType;

  /// ID of the entity being synchronized (local ID if not yet synced)
  final String entityId;

  /// The type of operation to perform
  final SyncOperationType operation;

  /// Data payload for the operation (serialized entity data)
  final Map<String, dynamic> data;

  /// Priority of this operation (higher priority operations are processed first)
  final SyncPriority priority;

  /// Number of times this operation has been attempted
  final int retryCount;

  /// Maximum number of retry attempts allowed
  final int maxRetries;

  /// Current status of the operation
  final SyncOperationStatus status;

  /// Error message from the last failed attempt (if any)
  final String? errorMessage;

  /// When this operation was created
  final DateTime createdAt;

  /// When this operation was last attempted (if any)
  final DateTime? lastAttemptedAt;

  /// When this operation was completed (if successful)
  final DateTime? completedAt;

  /// Version of the entity at the time of operation (for conflict resolution)
  final int? version;

  /// Creates a new [SyncOperationEntity]
  const SyncOperationEntity({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.data,
    this.priority = SyncPriority.normal,
    this.retryCount = 0,
    this.maxRetries = 3,
    this.status = SyncOperationStatus.pending,
    this.errorMessage,
    required this.createdAt,
    this.lastAttemptedAt,
    this.completedAt,
    this.version,
  });

  // ==============================================================================
  // STATE CHECK GETTERS
  // ==============================================================================

  /// Returns true if this operation can be retried
  bool get canRetry => retryCount < maxRetries;

  /// Returns true if this operation has failed permanently
  bool get permanentlyFailed =>
      retryCount >= maxRetries && status == SyncOperationStatus.failed;

  /// Returns true if this operation is currently being processed
  bool get isProcessing => status == SyncOperationStatus.processing;

  /// Returns true if this operation is pending execution
  bool get isPending => status == SyncOperationStatus.pending;

  /// Returns true if this operation has completed (successfully or permanently failed)
  bool get isCompleted =>
      status == SyncOperationStatus.completed || permanentlyFailed;

  /// Returns true if this operation has completed successfully
  bool get isSuccessful => status == SyncOperationStatus.completed;

  /// Returns true if this operation has failed (either temporarily or permanently)
  bool get isFailed => status == SyncOperationStatus.failed;

  /// Returns the duration since this operation was created
  Duration get age => DateTime.now().difference(createdAt);

  /// Returns the duration since the last attempt (if any)
  Duration? get timeSinceLastAttempt {
    if (lastAttemptedAt == null) return null;
    return DateTime.now().difference(lastAttemptedAt!);
  }

  /// Returns true if this operation should be retried now
  /// based on exponential backoff
  bool get shouldRetryNow {
    if (!canRetry || !isFailed) return false;

    // Exponential backoff: 2^retryCount seconds, max 60 seconds
    final backoffSeconds =
        [1 << retryCount, 60].reduce((a, b) => a < b ? a : b);
    final timeSinceFailure = timeSinceLastAttempt ?? Duration.zero;

    return timeSinceFailure >= Duration(seconds: backoffSeconds);
  }

  // ==============================================================================
  // ACTION METHODS
  // ==============================================================================

  /// Returns a copy with this operation marked as processing
  SyncOperationEntity markAsProcessing() {
    return copyWith(
      status: SyncOperationStatus.processing,
      lastAttemptedAt: DateTime.now(),
    );
  }

  /// Returns a copy with this operation marked as completed successfully
  SyncOperationEntity markAsCompleted() {
    return copyWith(
      status: SyncOperationStatus.completed,
      completedAt: DateTime.now(),
    );
  }

  /// Returns a copy with this operation marked as failed with the given error message
  SyncOperationEntity markAsFailed(String error) {
    return copyWith(
      status: SyncOperationStatus.failed,
      errorMessage: error,
      lastAttemptedAt: DateTime.now(),
      retryCount: retryCount + 1,
    );
  }

  /// Returns a copy with this operation reset to pending status (for retry)
  SyncOperationEntity resetForRetry() {
    return copyWith(
      status: SyncOperationStatus.pending,
      errorMessage: null,
    );
  }

  // ==============================================================================
  // UTILITY METHODS
  // ==============================================================================

  /// Returns a human-readable description of this operation
  String get description {
    final operationName = operation.value.replaceFirst(
      operation.value[0],
      operation.value[0].toUpperCase(),
    );
    return '$operationName $entityType ($entityId)';
  }

  /// Creates a copy of this SyncOperationEntity with the given fields replaced
  SyncOperationEntity copyWith({
    int? id,
    String? entityType,
    String? entityId,
    SyncOperationType? operation,
    Map<String, dynamic>? data,
    SyncPriority? priority,
    int? retryCount,
    int? maxRetries,
    SyncOperationStatus? status,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? lastAttemptedAt,
    DateTime? completedAt,
    int? version,
  }) {
    return SyncOperationEntity(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      data: data ?? this.data,
      priority: priority ?? this.priority,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptedAt: lastAttemptedAt ?? this.lastAttemptedAt,
      completedAt: completedAt ?? this.completedAt,
      version: version ?? this.version,
    );
  }

  @override
  List<Object?> get props => [
        id,
        entityType,
        entityId,
        operation,
        data,
        priority,
        retryCount,
        maxRetries,
        status,
        errorMessage,
        createdAt,
        lastAttemptedAt,
        completedAt,
        version,
      ];

  @override
  String toString() {
    return 'SyncOperationEntity(id: $id, operation: ${operation.value}, '
        'entityType: $entityType, entityId: $entityId, status: ${status.value})';
  }
}
