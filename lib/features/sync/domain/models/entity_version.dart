import 'package:equatable/equatable.dart';

/// Version information for a syncable entity
///
/// Tracks both a monotonic version number and timestamp to support
/// both version vector and last-write-wins conflict detection strategies.
class EntityVersion extends Equatable {
  /// Unique identifier for the entity
  final String entityId;

  /// Type of entity
  final String entityType;

  /// Monotonic version number (increments on each change)
  final int version;

  /// Timestamp of last modification (UTC)
  final DateTime lastModified;

  /// Device/user that made this modification
  final String deviceId;

  /// Optional hash of entity data for content-based comparison
  final String? dataHash;

  const EntityVersion({
    required this.entityId,
    required this.entityType,
    required this.version,
    required this.lastModified,
    required this.deviceId,
    this.dataHash,
  });

  /// Creates a copy with the given fields replaced
  EntityVersion copyWith({
    String? entityId,
    String? entityType,
    int? version,
    DateTime? lastModified,
    String? deviceId,
    String? dataHash,
  }) {
    return EntityVersion(
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      version: version ?? this.version,
      lastModified: lastModified ?? this.lastModified,
      deviceId: deviceId ?? this.deviceId,
      dataHash: dataHash ?? this.dataHash,
    );
  }

  /// Creates an initial version for a new entity
  factory EntityVersion.initial({
    required String entityId,
    required String entityType,
    required String deviceId,
  }) {
    return EntityVersion(
      entityId: entityId,
      entityType: entityType,
      version: 1,
      lastModified: DateTime.now().toUtc(),
      deviceId: deviceId,
    );
  }

  /// Creates the next version (incremented version number, updated timestamp)
  EntityVersion nextVersion({String? deviceId, String? dataHash}) {
    return EntityVersion(
      entityId: entityId,
      entityType: entityType,
      version: version + 1,
      lastModified: DateTime.now().toUtc(),
      deviceId: deviceId ?? this.deviceId,
      dataHash: dataHash,
    );
  }

  /// Whether this version is newer than [other] based on version number
  bool isNewerThan(EntityVersion other) {
    if (entityId != other.entityId || entityType != other.entityType) {
      return false;
    }
    return version > other.version;
  }

  /// Whether this version is older than [other] based on version number
  bool isOlderThan(EntityVersion other) {
    if (entityId != other.entityId || entityType != other.entityType) {
      return false;
    }
    return version < other.version;
  }

  /// Whether this version is the same as [other]
  bool isSameVersion(EntityVersion other) {
    return entityId == other.entityId &&
        entityType == other.entityType &&
        version == other.version;
  }

  /// Whether this version was modified after [other] based on timestamp
  bool isModifiedAfter(EntityVersion other) {
    return lastModified.isAfter(other.lastModified);
  }

  /// Whether this version has different content than [other]
  bool hasDifferentContent(EntityVersion other) {
    if (dataHash == null || other.dataHash == null) {
      return false; // Cannot determine without hash
    }
    return dataHash != other.dataHash;
  }

  @override
  List<Object?> get props => [
        entityId,
        entityType,
        version,
        lastModified,
        deviceId,
        dataHash,
      ];

  @override
  String toString() =>
      'EntityVersion(entityId: $entityId, entityType: $entityType, '
      'version: $version, lastModified: $lastModified, deviceId: $deviceId)';

  /// Convert to JSON for storage/transmission
  Map<String, dynamic> toJson() {
    return {
      'entityId': entityId,
      'entityType': entityType,
      'version': version,
      'lastModified': lastModified.toIso8601String(),
      'deviceId': deviceId,
      'dataHash': dataHash,
    };
  }

  /// Create from JSON
  factory EntityVersion.fromJson(Map<String, dynamic> json) {
    return EntityVersion(
      entityId: json['entityId'] as String,
      entityType: json['entityType'] as String,
      version: json['version'] as int,
      lastModified: DateTime.parse(json['lastModified'] as String),
      deviceId: json['deviceId'] as String,
      dataHash: json['dataHash'] as String?,
    );
  }
}
