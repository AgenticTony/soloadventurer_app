import 'package:equatable/equatable.dart';
import 'entity_version.dart';

/// Type of conflict detected during sync
enum ConflictType {
  /// Both local and remote versions have the same version number
  /// but different content (concurrent modification)
  versionConflict,

  /// Local version is newer than remote, but content differs
  /// (remote has stale data)
  localNewer,

  /// Remote version is newer than local, but content differs
  /// (local has stale data)
  remoteNewer,

  /// Versions are based on different ancestors (diverged history)
  diverged,

  /// Conflict detected via timestamp comparison
  timestampConflict,
}

/// Severity level of a conflict
enum ConflictSeverity {
  /// Low severity - can be auto-resolved
  low,

  /// Medium severity - may require user input
  medium,

  /// High severity - requires manual resolution
  high,
}

/// Detailed information about a detected conflict
class ConflictInfo extends Equatable {
  /// Unique identifier for this conflict
  final String conflictId;

  /// ID of the entity in conflict
  final String entityId;

  /// Type of entity
  final String entityType;

  /// Type of conflict detected
  final ConflictType conflictType;

  /// Severity of the conflict
  final ConflictSeverity severity;

  /// Local entity version
  final EntityVersion localVersion;

  /// Remote entity version
  final EntityVersion remoteVersion;

  /// Local entity data (if available)
  final Map<String, dynamic>? localData;

  /// Remote entity data (if available)
  final Map<String, dynamic>? remoteData;

  /// Human-readable description of the conflict
  final String description;

  /// When the conflict was detected
  final DateTime detectedAt;

  const ConflictInfo({
    required this.conflictId,
    required this.entityId,
    required this.entityType,
    required this.conflictType,
    required this.severity,
    required this.localVersion,
    required this.remoteVersion,
    this.localData,
    this.remoteData,
    required this.description,
    required this.detectedAt,
  });

  /// Creates a copy with the given fields replaced
  ConflictInfo copyWith({
    String? conflictId,
    String? entityId,
    String? entityType,
    ConflictType? conflictType,
    ConflictSeverity? severity,
    EntityVersion? localVersion,
    EntityVersion? remoteVersion,
    Map<String, dynamic>? localData,
    Map<String, dynamic>? remoteData,
    String? description,
    DateTime? detectedAt,
  }) {
    return ConflictInfo(
      conflictId: conflictId ?? this.conflictId,
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      conflictType: conflictType ?? this.conflictType,
      severity: severity ?? this.severity,
      localVersion: localVersion ?? this.localVersion,
      remoteVersion: remoteVersion ?? this.remoteVersion,
      localData: localData ?? this.localData,
      remoteData: remoteData ?? this.remoteData,
      description: description ?? this.description,
      detectedAt: detectedAt ?? this.detectedAt,
    );
  }

  /// Whether this conflict can be automatically resolved
  bool get canAutoResolve {
    return severity == ConflictSeverity.low ||
        conflictType == ConflictType.localNewer ||
        conflictType == ConflictType.remoteNewer;
  }

  /// Time since conflict was detected
  Duration get age => DateTime.now().toUtc().difference(detectedAt);

  @override
  List<Object?> get props => [
        conflictId,
        entityId,
        entityType,
        conflictType,
        severity,
        localVersion,
        remoteVersion,
        localData,
        remoteData,
        description,
        detectedAt,
      ];

  @override
  String toString() =>
      'ConflictInfo(conflictId: $conflictId, entityId: $entityId, '
      'entityType: $entityType, conflictType: $conflictType, '
      'severity: $severity, detectedAt: $detectedAt)';

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'conflictId': conflictId,
      'entityId': entityId,
      'entityType': entityType,
      'conflictType': conflictType.name,
      'severity': severity.name,
      'localVersion': localVersion.toJson(),
      'remoteVersion': remoteVersion.toJson(),
      'localData': localData,
      'remoteData': remoteData,
      'description': description,
      'detectedAt': detectedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ConflictInfo.fromJson(Map<String, dynamic> json) {
    return ConflictInfo(
      conflictId: json['conflictId'] as String,
      entityId: json['entityId'] as String,
      entityType: json['entityType'] as String,
      conflictType:
          ConflictType.values.firstWhere((e) => e.name == json['conflictType']),
      severity:
          ConflictSeverity.values.firstWhere((e) => e.name == json['severity']),
      localVersion: EntityVersion.fromJson(json['localVersion']),
      remoteVersion: EntityVersion.fromJson(json['remoteVersion']),
      localData: json['localData'] as Map<String, dynamic>?,
      remoteData: json['remoteData'] as Map<String, dynamic>?,
      description: json['description'] as String,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
    );
  }
}

/// Result of a conflict detection operation
class ConflictDetectionResult extends Equatable {
  /// Whether any conflicts were detected
  final bool hasConflicts;

  /// List of detected conflicts
  final List<ConflictInfo> conflicts;

  /// Total number of entities checked
  final int entitiesChecked;

  /// Number of entities without conflicts
  final int noConflictCount;

  const ConflictDetectionResult({
    required this.hasConflicts,
    required this.conflicts,
    required this.entitiesChecked,
    required this.noConflictCount,
  });

  /// Creates a result with no conflicts
  factory ConflictDetectionResult.noConflict(int entitiesChecked) {
    return ConflictDetectionResult(
      hasConflicts: false,
      conflicts: const [],
      entitiesChecked: entitiesChecked,
      noConflictCount: entitiesChecked,
    );
  }

  /// Creates a result with conflicts
  factory ConflictDetectionResult.withConflicts({
    required List<ConflictInfo> conflicts,
    required int entitiesChecked,
  }) {
    return ConflictDetectionResult(
      hasConflicts: true,
      conflicts: conflicts,
      entitiesChecked: entitiesChecked,
      noConflictCount: entitiesChecked - conflicts.length,
    );
  }

  /// Number of conflicts detected
  int get conflictCount => conflicts.length;

  /// Conflicts by severity
  Map<ConflictSeverity, List<ConflictInfo>> get conflictsBySeverity {
    final map = <ConflictSeverity, List<ConflictInfo>>{};
    for (final conflict in conflicts) {
      map.putIfAbsent(conflict.severity, () => []).add(conflict);
    }
    return map;
  }

  /// High severity conflicts
  List<ConflictInfo> get highSeverityConflicts =>
      conflicts.where((c) => c.severity == ConflictSeverity.high).toList();

  /// Medium severity conflicts
  List<ConflictInfo> get mediumSeverityConflicts =>
      conflicts.where((c) => c.severity == ConflictSeverity.medium).toList();

  /// Low severity conflicts (auto-resolvable)
  List<ConflictInfo> get lowSeverityConflicts =>
      conflicts.where((c) => c.severity == ConflictSeverity.low).toList();

  @override
  List<Object?> get props =>
      [hasConflicts, conflicts, entitiesChecked, noConflictCount];

  @override
  String toString() => 'ConflictDetectionResult(hasConflicts: $hasConflicts, '
      'conflictCount: $conflictCount, entitiesChecked: $entitiesChecked)';
}
