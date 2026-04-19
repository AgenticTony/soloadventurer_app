/// Types of operations that can be synced
enum SyncOperationType {
  createTrip,
  updateTrip,
  deleteTrip,
  hideConnection,
  setUserActivities,
  addUserActivity,
  removeUserActivity,
  sendMessage,
}

/// Represents a pending sync operation
class SyncOperation {
  /// Unique identifier for this operation
  final String id;

  /// Type of operation
  final SyncOperationType type;

  /// Operation data payload (varies by type)
  final Map<String, dynamic> data;

  /// When the operation was created
  final DateTime createdAt;

  /// Number of retry attempts
  final int retryCount;

  /// Creates a new [SyncOperation]
  const SyncOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  /// Creates a copy with updated retry count
  SyncOperation withRetryCount(int newRetryCount) {
    return SyncOperation(
      id: id,
      type: type,
      data: data,
      createdAt: createdAt,
      retryCount: newRetryCount,
    );
  }

  /// Converts to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'retry_count': retryCount,
    };
  }

  /// Creates from JSON
  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'] as String,
      type: SyncOperationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => SyncOperationType.createTrip,
      ),
      data: json['data'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at'] as String),
      retryCount: json['retry_count'] as int? ?? 0,
    );
  }
}

/// Result of processing a sync operation
enum SyncOperationResult {
  success,
  failure,
  conflict,
}

/// Conflict resolution strategy
enum ConflictResolutionStrategy {
  serverWins,
  clientWins,
  merge,
}
