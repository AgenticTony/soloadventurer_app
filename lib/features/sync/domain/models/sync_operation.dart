import 'package:equatable/equatable.dart';
import '../entities/sync_entity_type.dart';

/// Represents the type of sync operation
enum SyncOperationType {
  /// Create a new entity
  create,

  /// Update an existing entity
  update,

  /// Delete an entity
  delete,

  /// Batch operation (multiple operations)
  batch,
}

/// Represents a single sync operation in the queue
class SyncOperation extends Equatable {
  /// Unique identifier for this operation
  final String id;

  /// Type of entity to sync
  final SyncEntityType entityType;

  /// Operation type (create, update, delete, batch)
  final SyncOperationType operationType;

  /// Entity ID (for update/delete operations)
  final String? entityId;

  /// Operation payload (data to sync)
  final Map<String, dynamic>? data;

  /// Timestamp when operation was created
  final DateTime createdAt;

  /// Number of retry attempts
  final int retryCount;

  /// Priority for ordering (higher = processed first)
  final int priority;

  /// Whether this operation can be batched with others
  final bool canBatch;

  /// ID of the batch this operation belongs to (if batched)
  final String? batchId;

  /// Version of the entity being synced
  final int? version;

  const SyncOperation({
    required this.id,
    required this.entityType,
    required this.operationType,
    this.entityId,
    this.data,
    required this.createdAt,
    this.retryCount = 0,
    this.priority = 0,
    this.canBatch = false,
    this.batchId,
    this.version,
  });

  /// Creates a copy of this operation with the given fields replaced
  SyncOperation copyWith({
    String? id,
    SyncEntityType? entityType,
    SyncOperationType? operationType,
    String? entityId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    int? retryCount,
    int? priority,
    bool? canBatch,
    String? batchId,
    int? version,
  }) {
    return SyncOperation(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      operationType: operationType ?? this.operationType,
      entityId: entityId ?? this.entityId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      priority: priority ?? this.priority,
      canBatch: canBatch ?? this.canBatch,
      batchId: batchId ?? this.batchId,
      version: version ?? this.version,
    );
  }

  /// Creates a create operation
  factory SyncOperation.create({
    required String id,
    required SyncEntityType entityType,
    required Map<String, dynamic> data,
    int? version,
    int? priority,
  }) {
    return SyncOperation(
      id: id,
      entityType: entityType,
      operationType: SyncOperationType.create,
      data: data,
      createdAt: DateTime.now(),
      priority: priority ?? entityType.syncPriority,
      canBatch: false,
      version: version,
    );
  }

  /// Creates an update operation
  factory SyncOperation.update({
    required String id,
    required SyncEntityType entityType,
    required String entityId,
    required Map<String, dynamic> data,
    int? version,
    int? priority,
  }) {
    return SyncOperation(
      id: id,
      entityType: entityType,
      operationType: SyncOperationType.update,
      entityId: entityId,
      data: data,
      createdAt: DateTime.now(),
      priority: priority ?? entityType.syncPriority,
      canBatch: false,
      version: version,
    );
  }

  /// Creates a delete operation
  factory SyncOperation.delete({
    required String id,
    required SyncEntityType entityType,
    required String entityId,
    int? version,
    int? priority,
  }) {
    return SyncOperation(
      id: id,
      entityType: entityType,
      operationType: SyncOperationType.delete,
      entityId: entityId,
      createdAt: DateTime.now(),
      priority: priority ?? entityType.syncPriority,
      canBatch: false,
      version: version,
    );
  }

  /// Creates a batch operation
  factory SyncOperation.batch({
    required String id,
    required List<SyncOperation> operations,
    int? priority,
  }) {
    final timestamp = DateTime.now();
    final batchId = id;

    return SyncOperation(
      id: id,
      entityType: SyncEntityType.travelNote, // Default, will be overridden
      operationType: SyncOperationType.batch,
      createdAt: timestamp,
      priority: priority ?? 0,
      canBatch: false,
      batchId: batchId,
    );
  }

  /// Whether this operation has exceeded max retry attempts
  bool get shouldRetry => retryCount < 5;

  /// Whether this operation is a batch operation
  bool get isBatch => operationType == SyncOperationType.batch;

  /// Time since this operation was created
  Duration get age => DateTime.now().difference(createdAt);

  @override
  List<Object?> get props => [
        id,
        entityType,
        operationType,
        entityId,
        data,
        createdAt,
        retryCount,
        priority,
        canBatch,
        batchId,
        version,
      ];

  @override
  String toString() =>
      'SyncOperation(id: $id, entityType: $entityType, '
      'operationType: $operationType, entityId: $entityId, '
      'createdAt: $createdAt, retryCount: $retryCount, priority: $priority)';

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType.name,
      'operationType': operationType.name,
      'entityId': entityId,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'priority': priority,
      'canBatch': canBatch,
      'batchId': batchId,
      'version': version,
    };
  }

  /// Create from JSON
  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'] as String,
      entityType: SyncEntityType.values
          .firstWhere((e) => e.name == json['entityType']),
      operationType: SyncOperationType.values
          .firstWhere((e) => e.name == json['operationType']),
      entityId: json['entityId'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      priority: json['priority'] as int? ?? 0,
      canBatch: json['canBatch'] as bool? ?? false,
      batchId: json['batchId'] as String?,
      version: json['version'] as int?,
    );
  }
}

/// Represents a batch of sync operations
class SyncOperationBatch extends Equatable {
  /// Unique identifier for this batch
  final String id;

  /// Operations in this batch
  final List<SyncOperation> operations;

  /// Timestamp when batch was created
  final DateTime createdAt;

  /// Batch priority (highest priority of contained operations)
  final int priority;

  const SyncOperationBatch({
    required this.id,
    required this.operations,
    required this.createdAt,
    required this.priority,
  });

  /// Creates a batch from a list of operations
  factory SyncOperationBatch.fromOperations(List<SyncOperation> ops) {
    final batchId = 'batch_${DateTime.now().millisecondsSinceEpoch}';
    final maxPriority =
        ops.isEmpty ? 0 : ops.map((op) => op.priority).reduce((a, b) => a > b ? a : b);

    return SyncOperationBatch(
      id: batchId,
      operations: ops,
      createdAt: DateTime.now(),
      priority: maxPriority,
    );
  }

  /// Number of operations in this batch
  int get size => operations.length;

  /// Entity types in this batch
  List<SyncEntityType> get entityTypes =>
      operations.map((op) => op.entityType).toSet().toList();

  @override
  List<Object?> get props => [id, operations, createdAt, priority];

  @override
  String toString() =>
      'SyncOperationBatch(id: $id, size: $size, '
      'entityTypes: $entityTypes, priority: $priority)';
}
