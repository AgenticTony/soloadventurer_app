import 'package:equatable/equatable.dart';
import 'entity_version.dart';
import 'conflict_info.dart';

/// Strategy for resolving conflicts
enum ConflictResolutionStrategy {
  /// Use last-write-wins based on timestamps
  lastWriteWins,

  /// Require manual user intervention
  manual,

  /// Automatically merge non-overlapping fields
  automaticMerge,
}

/// Result of a conflict resolution operation
class ConflictResolution extends Equatable {
  /// ID of the conflict that was resolved
  final String conflictId;

  /// Entity ID that was in conflict
  final String entityId;

  /// Entity type that was in conflict
  final String entityType;

  /// Strategy used for resolution
  final ConflictResolutionStrategy strategy;

  /// Resolved entity data
  final Map<String, dynamic> resolvedData;

  /// Resolved entity version (incremented from inputs)
  final EntityVersion resolvedVersion;

  /// Whether resolution chose local version
  final bool choseLocal;

  /// Whether resolution chose remote version
  final bool choseRemote;

  /// Whether this was a merged result
  final bool isMerged;

  /// Fields from local version that were included
  final List<String> localFieldsUsed;

  /// Fields from remote version that were included
  final List<String> remoteFieldsUsed;

  /// Fields that could not be automatically merged (for merge strategy)
  final List<String> conflictingFields;

  /// User-provided data for manual resolution (if applicable)
  final Map<String, dynamic>? userProvidedData;

  /// When the resolution was created
  final DateTime resolvedAt;

  /// Any notes or metadata about the resolution
  final Map<String, dynamic>? metadata;

  const ConflictResolution({
    required this.conflictId,
    required this.entityId,
    required this.entityType,
    required this.strategy,
    required this.resolvedData,
    required this.resolvedVersion,
    this.choseLocal = false,
    this.choseRemote = false,
    this.isMerged = false,
    this.localFieldsUsed = const [],
    this.remoteFieldsUsed = const [],
    this.conflictingFields = const [],
    this.userProvidedData,
    required this.resolvedAt,
    this.metadata,
  });

  /// Creates a copy with the given fields replaced
  ConflictResolution copyWith({
    String? conflictId,
    String? entityId,
    String? entityType,
    ConflictResolutionStrategy? strategy,
    Map<String, dynamic>? resolvedData,
    EntityVersion? resolvedVersion,
    bool? choseLocal,
    bool? choseRemote,
    bool? isMerged,
    List<String>? localFieldsUsed,
    List<String>? remoteFieldsUsed,
    List<String>? conflictingFields,
    Map<String, dynamic>? userProvidedData,
    DateTime? resolvedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ConflictResolution(
      conflictId: conflictId ?? this.conflictId,
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      strategy: strategy ?? this.strategy,
      resolvedData: resolvedData ?? this.resolvedData,
      resolvedVersion: resolvedVersion ?? this.resolvedVersion,
      choseLocal: choseLocal ?? this.choseLocal,
      choseRemote: choseRemote ?? this.choseRemote,
      isMerged: isMerged ?? this.isMerged,
      localFieldsUsed: localFieldsUsed ?? this.localFieldsUsed,
      remoteFieldsUsed: remoteFieldsUsed ?? this.remoteFieldsUsed,
      conflictingFields: conflictingFields ?? this.conflictingFields,
      userProvidedData: userProvidedData ?? this.userProvidedData,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Time since resolution
  Duration get age => DateTime.now().toUtc().difference(resolvedAt);

  @override
  List<Object?> get props => [
        conflictId,
        entityId,
        entityType,
        strategy,
        resolvedData,
        resolvedVersion,
        choseLocal,
        choseRemote,
        isMerged,
        localFieldsUsed,
        remoteFieldsUsed,
        conflictingFields,
        userProvidedData,
        resolvedAt,
        metadata,
      ];

  @override
  String toString() =>
      'ConflictResolution(conflictId: $conflictId, entityId: $entityId, '
      'entityType: $entityType, strategy: $strategy, resolvedAt: $resolvedAt)';

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'conflictId': conflictId,
      'entityId': entityId,
      'entityType': entityType,
      'strategy': strategy.name,
      'resolvedData': resolvedData,
      'resolvedVersion': resolvedVersion.toJson(),
      'choseLocal': choseLocal,
      'choseRemote': choseRemote,
      'isMerged': isMerged,
      'localFieldsUsed': localFieldsUsed,
      'remoteFieldsUsed': remoteFieldsUsed,
      'conflictingFields': conflictingFields,
      'userProvidedData': userProvidedData,
      'resolvedAt': resolvedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory ConflictResolution.fromJson(Map<String, dynamic> json) {
    return ConflictResolution(
      conflictId: json['conflictId'] as String,
      entityId: json['entityId'] as String,
      entityType: json['entityType'] as String,
      strategy: ConflictResolutionStrategy.values
          .firstWhere((e) => e.name == json['strategy']),
      resolvedData: json['resolvedData'] as Map<String, dynamic>,
      resolvedVersion: EntityVersion.fromJson(json['resolvedVersion']),
      choseLocal: json['choseLocal'] as bool? ?? false,
      choseRemote: json['choseRemote'] as bool? ?? false,
      isMerged: json['isMerged'] as bool? ?? false,
      localFieldsUsed: json['localFieldsUsed'] as List<String>? ?? const [],
      remoteFieldsUsed: json['remoteFieldsUsed'] as List<String>? ?? const [],
      conflictingFields: json['conflictingFields'] as List<String>? ?? const [],
      userProvidedData: json['userProvidedData'] as Map<String, dynamic>?,
      resolvedAt: DateTime.parse(json['resolvedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Result of a merge operation
class MergeResult extends Equatable {
  /// Whether the merge was successful
  final bool success;

  /// Merged data (if successful)
  final Map<String, dynamic>? mergedData;

  /// Fields that were successfully merged from local
  final List<String> localFieldsUsed;

  /// Fields that were successfully merged from remote
  final List<String> remoteFieldsUsed;

  /// Fields that had conflicts and could not be merged
  final List<String> conflictingFields;

  /// Error message if merge failed
  final String? errorMessage;

  const MergeResult({
    required this.success,
    this.mergedData,
    this.localFieldsUsed = const [],
    this.remoteFieldsUsed = const [],
    this.conflictingFields = const [],
    this.errorMessage,
  });

  /// Creates a successful merge result
  factory MergeResult.success({
    required Map<String, dynamic> mergedData,
    required List<String> localFieldsUsed,
    required List<String> remoteFieldsUsed,
    List<String> conflictingFields = const [],
  }) {
    return MergeResult(
      success: true,
      mergedData: mergedData,
      localFieldsUsed: localFieldsUsed,
      remoteFieldsUsed: remoteFieldsUsed,
      conflictingFields: conflictingFields,
    );
  }

  /// Creates a failed merge result
  factory MergeResult.failure(String errorMessage) {
    return MergeResult(
      success: false,
      errorMessage: errorMessage,
    );
  }

  /// Whether there were any conflicting fields
  bool get hasConflicts => conflictingFields.isNotEmpty;

  /// Number of fields from local version
  int get localFieldCount => localFieldsUsed.length;

  /// Number of fields from remote version
  int get remoteFieldCount => remoteFieldsUsed.length;

  /// Total number of fields in merged result
  int get totalFieldCount => localFieldCount + remoteFieldCount;

  @override
  List<Object?> get props => [
        success,
        mergedData,
        localFieldsUsed,
        remoteFieldsUsed,
        conflictingFields,
        errorMessage,
      ];

  @override
  String toString() =>
      'MergeResult(success: $success, localFields: $localFieldCount, '
      'remoteFields: $remoteFieldCount, conflicts: ${conflictingFields.length})';
}

/// User's choice for manual conflict resolution
enum ManualResolutionChoice {
  /// Keep the local version
  keepLocal,

  /// Keep the remote version
  keepRemote,

  /// Custom merge provided by user
  customMerge,
}

/// Result of batch conflict resolution
class BatchResolutionResult extends Equatable {
  /// Total number of conflicts to resolve
  final int totalConflicts;

  /// Number of successfully resolved conflicts
  final int resolvedCount;

  /// Number of conflicts that failed to resolve
  final int failedCount;

  /// List of successful resolutions
  final List<ConflictResolution> resolutions;

  /// List of conflicts that could not be resolved
  final List<ConflictInfo> failedConflicts;

  /// Error messages for failed resolutions
  final Map<String, String> errors;

  const BatchResolutionResult({
    required this.totalConflicts,
    required this.resolvedCount,
    required this.failedCount,
    required this.resolutions,
    required this.failedConflicts,
    required this.errors,
  });

  /// Whether all conflicts were resolved
  bool get isComplete => failedCount == 0;

  /// Creates a result with all successes
  factory BatchResolutionResult.allResolved({
    required List<ConflictResolution> resolutions,
  }) {
    return BatchResolutionResult(
      totalConflicts: resolutions.length,
      resolvedCount: resolutions.length,
      failedCount: 0,
      resolutions: resolutions,
      failedConflicts: const [],
      errors: const {},
    );
  }

  @override
  List<Object?> get props => [
        totalConflicts,
        resolvedCount,
        failedCount,
        resolutions,
        failedConflicts,
        errors,
      ];

  @override
  String toString() =>
      'BatchResolutionResult(total: $totalConflicts, resolved: $resolvedCount, '
      'failed: $failedCount)';
}
