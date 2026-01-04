import 'dart:convert';
import 'package:soloadventurer/features/offline/infrastructure/database/schema.dart';

/// Sync operation types
enum SyncOperationType {
  create('create'),
  update('update'),
  delete('delete');

  final String value;
  const SyncOperationType(this.value);

  static SyncOperationType fromString(String value) {
    return SyncOperationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid sync operation type: $value'),
    );
  }
}

/// Sync priority levels
enum SyncPriority {
  high('high'),
  normal('normal'),
  low('low');

  final String value;
  const SyncPriority(this.value);

  static SyncPriority fromString(String value) {
    return SyncPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => throw ArgumentError('Invalid sync priority: $value'),
    );
  }
}

/// Sync operation status
enum SyncOperationStatus {
  pending('pending'),
  processing('processing'),
  completed('completed'),
  failed('failed');

  final String value;
  const SyncOperationStatus(this.value);

  static SyncOperationStatus fromString(String value) {
    return SyncOperationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Invalid sync status: $value'),
    );
  }
}

/// Local data model for SyncOperation that represents a queued sync operation
///
/// This model wraps the [SyncQueueItem] database class with additional functionality
/// for JSON serialization and operation management.
class SyncOperationModel {
  final int id;
  final String entityType;
  final String entityId;
  final SyncOperationType operation;
  final Map<String, dynamic> data;
  final SyncPriority priority;
  final int retryCount;
  final int maxRetries;
  final SyncOperationStatus status;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? lastAttemptedAt;
  final DateTime? completedAt;
  final int? version;

  const SyncOperationModel({
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

  /// Creates a [SyncOperationModel] from a [SyncQueueItem] database entity
  factory SyncOperationModel.fromDatabase(SyncQueueItem item) {
    return SyncOperationModel(
      id: item.id,
      entityType: item.entityType,
      entityId: item.entityId,
      operation: SyncOperationType.fromString(item.operation),
      data: jsonDecode(item.data) as Map<String, dynamic>,
      priority: SyncPriority.fromString(item.priority),
      retryCount: item.retryCount,
      maxRetries: item.maxRetries,
      status: SyncOperationStatus.fromString(item.status),
      errorMessage: item.errorMessage,
      createdAt: item.createdAt,
      lastAttemptedAt: item.lastAttemptedAt,
      completedAt: item.completedAt,
      version: item.version,
    );
  }

  /// Creates a [SyncOperationModel] from JSON map
  factory SyncOperationModel.fromJson(Map<String, dynamic> json) {
    return SyncOperationModel(
      id: json['id'] as int,
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      operation: SyncOperationType.fromString(json['operation'] as String),
      data: json['data'] as Map<String, dynamic>,
      priority: json['priority'] != null
          ? SyncPriority.fromString(json['priority'] as String)
          : SyncPriority.normal,
      retryCount: json['retryCount'] as int? ?? 0,
      maxRetries: json['maxRetries'] as int? ?? 3,
      status: json['status'] != null
          ? SyncOperationStatus.fromString(json['status'] as String)
          : SyncOperationStatus.pending,
      errorMessage: json['errorMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAttemptedAt: json['lastAttemptedAt'] != null
          ? DateTime.parse(json['lastAttemptedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      version: json['version'] as int?,
    );
  }

  /// Converts this [SyncOperationModel] to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      'operation': operation.value,
      'data': data,
      'priority': priority.value,
      'retryCount': retryCount,
      'maxRetries': maxRetries,
      'status': status.value,
      'errorMessage': errorMessage,
      'createdAt': createdAt.toIso8601String(),
      'lastAttemptedAt': lastAttemptedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'version': version,
    };
  }

  /// Creates a copy of this SyncOperationModel with the given fields replaced
  SyncOperationModel copyWith({
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
    return SyncOperationModel(
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

  // ==============================================================================
  // STATE CHECK METHODS
  // ==============================================================================

  /// Returns true if this operation can be retried
  bool get canRetry => retryCount < maxRetries;

  /// Returns true if this operation has failed permanently
  bool get permanentlyFailed => retryCount >= maxRetries && status == SyncOperationStatus.failed;

  /// Returns true if this operation is currently being processed
  bool get isProcessing => status == SyncOperationStatus.processing;

  /// Returns true if this operation is pending execution
  bool get isPending => status == SyncOperationStatus.pending;

  /// Returns true if this operation has completed (successfully or permanently failed)
  bool get isCompleted => status == SyncOperationStatus.completed || permanentlyFailed;

  /// Returns true if this operation has completed successfully
  bool get isSuccessful => status == SyncOperationStatus.completed;

  /// Returns true if this operation has failed (either temporarily or permanently)
  bool get isFailed => status == SyncOperationStatus.failed;

  // ==============================================================================
  // ACTION METHODS
  // ==============================================================================

  /// Marks this operation as processing
  SyncOperationModel markAsProcessing() {
    return copyWith(
      status: SyncOperationStatus.processing,
      lastAttemptedAt: DateTime.now(),
    );
  }

  /// Marks this operation as completed successfully
  SyncOperationModel markAsCompleted() {
    return copyWith(
      status: SyncOperationStatus.completed,
      completedAt: DateTime.now(),
    );
  }

  /// Marks this operation as failed with the given error message
  SyncOperationModel markAsFailed(String error) {
    return copyWith(
      status: SyncOperationStatus.failed,
      errorMessage: error,
      retryCount: retryCount + 1,
    );
  }

  /// Resets this operation to pending status (for retry)
  SyncOperationModel resetForRetry() {
    return copyWith(
      status: SyncOperationStatus.pending,
      errorMessage: null,
    );
  }

  /// Returns the data as a JSON string for database storage
  String get dataAsJson => jsonEncode(data);

  // ==============================================================================
  // UTILITY METHODS
  /// ==============================================================================

  /// Returns a human-readable description of this operation
  String get description {
    return '${operation.value.capitalize()} $entityType ($entityId)';
  }

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
    final backoffSeconds = [1 << retryCount, 60].reduce((a, b) => a < b ? a : b);
    final timeSinceFailure = timeSinceLastAttempt ?? Duration.zero;

    return timeSinceFailure >= Duration(seconds: backoffSeconds);
  }

  @override
  String toString() {
    return 'SyncOperationModel(id: $id, operation: ${operation.value}, '
        'entityType: $entityType, entityId: $entityId, status: ${status.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SyncOperationModel &&
        other.id == id &&
        other.entityType == entityType &&
        other.entityId == entityId &&
        other.operation == operation &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        entityType.hashCode ^
        entityId.hashCode ^
        operation.hashCode ^
        status.hashCode;
  }
}

/// Extension on String to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
