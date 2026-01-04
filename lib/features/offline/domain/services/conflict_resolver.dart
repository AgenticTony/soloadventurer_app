import 'package:equatable/equatable.dart';

/// Conflict resolution strategy enum
enum ConflictResolutionStrategy {
  /// Use the most recently modified version (based on updatedAt timestamp)
  lastWriteWins,

  /// Always prefer the server version
  serverWins,

  /// Always prefer the client (local) version
  clientWins,

  /// Require manual user intervention to resolve
  manual,
}

/// Conflict type enum
enum ConflictType {
  /// Both client and server modified the same entity
  concurrentUpdate,

  /// Entity was deleted on one side but modified on the other
  deleteModify,

  /// Entity was created offline but already exists on server
  duplicateCreate,

  /// Version mismatch between client and server
  versionMismatch,
}

/// Conflict severity enum
enum ConflictSeverity {
  /// Low severity - can be auto-resolved
  low,

  /// Medium severity - should be reviewed but can be auto-resolved
  medium,

  /// High severity - requires user attention
  high,
}

/// Entity type enum for conflict tracking
enum EntityType {
  trip,
  journal,
  userProfile,
  travelPreference,
  other,
}

/// Conflict data class representing a sync conflict
///
/// A conflict occurs when the same entity has been modified
/// on both the client and server since the last sync.
class Conflict extends Equatable {
  /// Unique identifier for this conflict
  final String id;

  /// Type of entity that has the conflict
  final EntityType entityType;

  /// ID of the entity that has the conflict
  final String entityId;

  /// Type of conflict
  final ConflictType type;

  /// Severity of the conflict
  final ConflictSeverity severity;

  /// Client (local) version of the entity
  final Map<String, dynamic> clientData;

  /// Server version of the entity
  final Map<String, dynamic> serverData;

  /// Client version timestamp
  final DateTime clientUpdatedAt;

  /// Server version timestamp
  final DateTime serverUpdatedAt;

  /// When this conflict was detected
  final DateTime detectedAt;

  /// Whether this conflict has been resolved
  final bool isResolved;

  /// Resolution strategy that was applied (if resolved)
  final ConflictResolutionStrategy? resolvedWith;

  /// When this conflict was resolved (if resolved)
  final DateTime? resolvedAt;

  /// Additional metadata about the conflict
  final Map<String, dynamic> metadata;

  const Conflict({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.type,
    required this.severity,
    required this.clientData,
    required this.serverData,
    required this.clientUpdatedAt,
    required this.serverUpdatedAt,
    required this.detectedAt,
    this.isResolved = false,
    this.resolvedWith,
    this.resolvedAt,
    this.metadata = const {},
  });

  /// Creates a copy of this conflict with updated fields
  Conflict copyWith({
    String? id,
    EntityType? entityType,
    String? entityId,
    ConflictType? type,
    ConflictSeverity? severity,
    Map<String, dynamic>? clientData,
    Map<String, dynamic>? serverData,
    DateTime? clientUpdatedAt,
    DateTime? serverUpdatedAt,
    DateTime? detectedAt,
    bool? isResolved,
    ConflictResolutionStrategy? resolvedWith,
    DateTime? resolvedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Conflict(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      clientData: clientData ?? this.clientData,
      serverData: serverData ?? this.serverData,
      clientUpdatedAt: clientUpdatedAt ?? this.clientUpdatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      detectedAt: detectedAt ?? this.detectedAt,
      isResolved: isResolved ?? this.isResolved,
      resolvedWith: resolvedWith ?? this.resolvedWith,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Marks this conflict as resolved
  Conflict markAsResolved(ConflictResolutionStrategy strategy) {
    return copyWith(
      isResolved: true,
      resolvedWith: strategy,
      resolvedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        entityType,
        entityId,
        type,
        severity,
        clientUpdatedAt,
        serverUpdatedAt,
        detectedAt,
        isResolved,
        resolvedWith,
        resolvedAt,
      ];
}

/// Result of a conflict resolution operation
class ConflictResolutionResult {
  /// Number of conflicts resolved
  final int resolvedCount;

  /// Number of conflicts requiring manual resolution
  final int manualResolutionRequired;

  /// Number of conflicts that could not be resolved
  final int failedCount;

  /// List of conflicts that require manual resolution
  final List<Conflict> pendingConflicts;

  /// Whether the resolution was successful overall
  bool get isSuccessful => failedCount == 0;

  const ConflictResolutionResult({
    required this.resolvedCount,
    required this.manualResolutionRequired,
    required this.failedCount,
    required this.pendingConflicts,
  });

  @override
  String toString() {
    return 'ConflictResolutionResult(resolved: $resolvedCount, '
        'manual: $manualResolutionRequired, failed: $failedCount)';
  }
}

/// Abstract conflict resolver interface
///
/// The conflict resolver handles situations where the same entity
/// has been modified on both the client and server since the last sync.
/// It provides multiple resolution strategies and tracks conflict history.
///
/// Example usage:
/// ```dart
/// final resolver = ConflictResolverImpl();
///
/// // Resolve all conflicts with default strategies
/// final result = await resolver.resolveAllConflicts();
///
/// // Resolve a specific conflict manually
/// await resolver.resolveConflict(
///   conflictId,
///   strategy: ConflictResolutionStrategy.clientWins,
/// );
/// ```
abstract class ConflictResolver {
  /// Gets all unresolved conflicts
  ///
  /// Returns a list of conflicts that have not been resolved yet.
  Future<List<Conflict>> getUnresolvedConflicts();

  /// Gets conflicts by entity type
  ///
  /// Returns all conflicts for the specified entity type.
  Future<List<Conflict>> getConflictsByType(EntityType entityType);

  /// Resolves a single conflict
  ///
  /// Applies the specified resolution strategy to the conflict.
  /// Returns [true] if the conflict was successfully resolved.
  Future<bool> resolveConflict(
    String conflictId,
    ConflictResolutionStrategy strategy,
  );

  /// Resolves all conflicts automatically
  ///
  /// Attempts to resolve all conflicts using the default strategy
  /// for each conflict type. Returns a [ConflictResolutionResult]
  /// with statistics.
  Future<ConflictResolutionResult> resolveAllConflicts();

  /// Records a new conflict
  ///
  /// Adds a conflict to the conflict log. This is called by the
  /// sync engine when a conflict is detected.
  Future<void> recordConflict(Conflict conflict);

  /// Gets conflict history
  ///
  /// Returns all conflicts (resolved and unresolved) for auditing.
  /// Optionally filtered by date range.
  Future<List<Conflict>> getConflictHistory({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Clears old resolved conflicts
  ///
  /// Removes conflicts that were resolved before the specified date.
  /// This is useful for keeping the conflict log manageable.
  Future<void> clearOldConflicts(DateTime beforeDate);
}
