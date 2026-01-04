import 'dart:async';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../domain/models/entity_version.dart';
import '../../domain/models/conflict_info.dart';
import '../../domain/services/conflict_detector.dart';

/// Default implementation of [ConflictDetector]
///
/// Uses hybrid approach combining version numbers and timestamps
/// for robust conflict detection with minimal false positives.
class ConflictDetectorImpl extends ConflictDetector {
  /// Current configuration
  @override
  ConflictDetectionConfig config;

  /// Stream controller for conflict events (optional, for future use)
  StreamController<ConflictInfo>? _conflictStreamController;

  /// Creates a new [ConflictDetectorImpl] with the given configuration
  ConflictDetectorImpl({
    ConflictDetectionConfig? config,
  }) : config = config ?? ConflictDetectionConfig.defaultConfig(
          deviceId: 'default-device',
        ) {
    _conflictStreamController = StreamController<ConflictInfo>.broadcast();
  }

  @override
  void updateConfig(ConflictDetectionConfig config) {
    this.config = config;
  }

  @override
  Future<ConflictInfo?> detectConflict({
    required EntityVersion localVersion,
    required EntityVersion remoteVersion,
    Map<String, dynamic>? localData,
    Map<String, dynamic>? remoteData,
  }) async {
    // Validate entity IDs match
    if (localVersion.entityId != remoteVersion.entityId ||
        localVersion.entityType != remoteVersion.entityType) {
      return null; // Not the same entity, no conflict
    }

    // Check if there's actually a conflict
    if (!isInConflict(
          localVersion: localVersion,
          remoteVersion: remoteVersion,
        )) {
      return null; // No conflict detected
    }

    // Determine conflict type and severity
    final conflictType = determineConflictType(
      localVersion: localVersion,
      remoteVersion: remoteVersion,
    );

    final severity = determineConflictSeverity(
      conflictType: conflictType,
      localVersion: localVersion,
      remoteVersion: remoteVersion,
    );

    // Generate description
    final description = generateConflictDescription(
      conflictType: conflictType,
      localVersion: localVersion,
      remoteVersion: remoteVersion,
    );

    // Create conflict info
    final conflict = ConflictInfo(
      conflictId: _generateConflictId(localVersion, remoteVersion),
      entityId: localVersion.entityId,
      entityType: localVersion.entityType,
      conflictType: conflictType,
      severity: severity,
      localVersion: localVersion,
      remoteVersion: remoteVersion,
      localData: localData,
      remoteData: remoteData,
      description: description,
      detectedAt: DateTime.now().toUtc(),
    );

    // Emit to stream (for future use)
    _conflictStreamController?.add(conflict);

    return conflict;
  }

  @override
  Future<ConflictDetectionResult> detectMultipleConflicts({
    required List<EntityVersion> localVersions,
    required List<EntityVersion> remoteVersions,
    Map<String, Map<String, dynamic>>? localDataMap,
    Map<String, Map<String, dynamic>>? remoteDataMap,
  }) async {
    final conflicts = <ConflictInfo>[];
    var entitiesChecked = 0;

    // Create maps for efficient lookup
    final localMap = {for (var v in localVersions) v.entityId: v};
    final remoteMap = {for (var v in remoteVersions) v.entityId: v};

    // Check all entities that exist in both local and remote
    for (final entityId in {...localMap.keys, ...remoteMap.keys}) {
      entitiesChecked++;

      final local = localMap[entityId];
      final remote = remoteMap[entityId];

      // Only check if entity exists in both
      if (local != null && remote != null) {
        final conflict = await detectConflict(
          localVersion: local,
          remoteVersion: remote,
          localData: localDataMap?[entityId],
          remoteData: remoteDataMap?[entityId],
        );

        if (conflict != null) {
          conflicts.add(conflict);
        }
      }
    }

    if (conflicts.isEmpty) {
      return ConflictDetectionResult.noConflict(entitiesChecked);
    } else {
      return ConflictDetectionResult.withConflicts(
        conflicts: conflicts,
        entitiesChecked: entitiesChecked,
      );
    }
  }

  @override
  bool isInConflict({
    required EntityVersion localVersion,
    required EntityVersion remoteVersion,
  }) {
    // Must be same entity
    if (localVersion.entityId != remoteVersion.entityId ||
        localVersion.entityType != remoteVersion.entityType) {
      return false;
    }

    switch (config.strategy) {
      case ConflictDetectionStrategy.versionBased:
        return _isVersionConflict(localVersion, remoteVersion);

      case ConflictDetectionStrategy.timestampBased:
        return _isTimestampConflict(localVersion, remoteVersion);

      case ConflictDetectionStrategy.hybrid:
        // Use both strategies
        return _isVersionConflict(localVersion, remoteVersion) ||
            _isTimestampConflict(localVersion, remoteVersion);

      case ConflictDetectionStrategy.contentBased:
        return _isContentConflict(localVersion, remoteVersion);
    }
  }

  @override
  ConflictType determineConflictType({
    required EntityVersion localVersion,
    required EntityVersion remoteVersion,
  }) {
    final local = localVersion;
    final remote = remoteVersion;

    // Check for same version conflicts (concurrent edits)
    if (local.version == remote.version) {
      if (config.useContentHashing &&
          local.dataHash != null &&
          remote.dataHash != null &&
          local.dataHash != remote.dataHash) {
        return ConflictType.versionConflict;
      }
      // If no hash or same hash, no conflict
      if (areTimestampsConcurrent(
            timestamp1: local.lastModified,
            timestamp2: remote.lastModified,
          )) {
        return ConflictType.timestampConflict;
      }
    }

    // Check for diverged versions
    if (local.version != remote.version) {
      // If versions differ but are concurrent, it's a diverged conflict
      if (areTimestampsConcurrent(
            timestamp1: local.lastModified,
            timestamp2: remote.lastModified,
          )) {
        return ConflictType.diverged;
      }

      // One is newer
      if (local.isNewerThan(remote)) {
        // Local is newer, but timestamps might tell a different story
        if (local.isModifiedAfter(remote)) {
          // Both version and timestamp agree: local is newer
          return ConflictType.localNewer;
        } else {
          // Version says local is newer, but timestamp says remote is newer
          return ConflictType.diverged;
        }
      } else if (remote.isNewerThan(local)) {
        // Remote is newer
        if (remote.isModifiedAfter(local)) {
          // Both version and timestamp agree: remote is newer
          return ConflictType.remoteNewer;
        } else {
          // Version says remote is newer, but timestamp says local is newer
          return ConflictType.diverged;
        }
      }
    }

    // Default: timestamp conflict
    return ConflictType.timestampConflict;
  }

  @override
  ConflictSeverity determineConflictSeverity({
    required ConflictType conflictType,
    required EntityVersion localVersion,
    required EntityVersion remoteVersion,
  }) {
    switch (conflictType) {
      case ConflictType.localNewer:
      case ConflictType.remoteNewer:
        // One version is clearly newer - can auto-resolve
        return ConflictSeverity.low;

      case ConflictType.timestampConflict:
        // Timestamp conflict - check if timestamps are very close
        final timeDiff = localVersion.lastModified
            .difference(remoteVersion.lastModified)
            .abs()
            .inMilliseconds;
        if (timeDiff < config.timestampThresholdMs) {
          // Very close timestamps - likely concurrent edits
          return ConflictSeverity.high;
        } else {
          // One is clearly newer by timestamp
          return ConflictSeverity.low;
        }

      case ConflictType.versionConflict:
        // Same version but different content - concurrent edits
        return ConflictSeverity.high;

      case ConflictType.diverged:
        // Versions diverged - manual resolution needed
        return ConflictSeverity.high;
    }
  }

  @override
  String generateConflictDescription({
    required ConflictType conflictType,
    required EntityVersion localVersion,
    required EntityVersion remoteVersion,
  }) {
    final localTime = _formatTimestamp(localVersion.lastModified);
    final remoteTime = _formatTimestamp(remoteVersion.lastModified);

    switch (conflictType) {
      case ConflictType.localNewer:
        return 'Local changes (v${localVersion.version} from $localTime) are newer '
            'than remote (v${remoteVersion.version} from $remoteTime). '
            'Local version will be kept.';

      case ConflictType.remoteNewer:
        return 'Remote changes (v${remoteVersion.version} from $remoteTime) are newer '
            'than local (v${localVersion.version} from $localTime). '
            'Remote version will be kept.';

      case ConflictType.versionConflict:
        return 'Both local and remote have version ${localVersion.version} but '
            'different content. Concurrent edits detected at '
            '$localTime and $remoteTime. Manual resolution required.';

      case ConflictType.diverged:
        return 'Local (v${localVersion.version} from $localTime) and remote '
            '(v${remoteVersion.version} from $remoteTime) have diverged. '
            'Manual resolution required.';

      case ConflictType.timestampConflict:
        return 'Conflict detected between local ($localTime) and '
            'remote ($remoteTime). Timestamps are too close to determine '
            'which version is newer.';
    }
  }

  @override
  int compareVersions({
    required EntityVersion localVersion,
    required EntityVersion remoteVersion,
  }) {
    switch (config.strategy) {
      case ConflictDetectionStrategy.versionBased:
        return localVersion.version.compareTo(remoteVersion.version);

      case ConflictDetectionStrategy.timestampBased:
        return localVersion.lastModified.compareTo(remoteVersion.lastModified);

      case ConflictDetectionStrategy.hybrid:
        // Try version first, then timestamp
        if (localVersion.version != remoteVersion.version) {
          return localVersion.version.compareTo(remoteVersion.version);
        }
        return localVersion.lastModified.compareTo(remoteVersion.lastModified);

      case ConflictDetectionStrategy.contentBased:
        // Use hash for comparison if available
        if (localVersion.dataHash != null && remoteVersion.dataHash != null) {
          if (localVersion.dataHash != remoteVersion.dataHash) {
            // Different content - use timestamp to determine newer
            return localVersion.lastModified.compareTo(remoteVersion.lastModified);
          }
          return 0; // Same content
        }
        // Fall back to timestamp
        return localVersion.lastModified.compareTo(remoteVersion.lastModified);
    }
  }

  @override
  bool areTimestampsConcurrent({
    required DateTime timestamp1,
    required DateTime timestamp2,
  }) {
    final diff = timestamp1.difference(timestamp2).abs().inMilliseconds;
    return diff <= config.timestampThresholdMs;
  }

  /// Check for version-based conflict
  bool _isVersionConflict(
    EntityVersion local,
    EntityVersion remote,
  ) {
    // Same version with different content hashes = conflict
    if (config.detectSameVersionConflicts &&
        local.version == remote.version &&
        config.useContentHashing &&
        local.dataHash != null &&
        remote.dataHash != null &&
        local.dataHash != remote.dataHash) {
      return true;
    }

    // Different versions = potential conflict
    if (local.version != remote.version) {
      // If timestamps are concurrent, it's definitely a conflict
      if (areTimestampsConcurrent(
            timestamp1: local.lastModified,
            timestamp2: remote.lastModified,
          )) {
        return true;
      }
    }

    return false;
  }

  /// Check for timestamp-based conflict
  bool _isTimestampConflict(
    EntityVersion local,
    EntityVersion remote,
  ) {
    // If timestamps are concurrent, check content
    if (areTimestampsConcurrent(
          timestamp1: local.lastModified,
          timestamp2: remote.lastModified,
        )) {
      // If content hashing is enabled and hashes differ, conflict
      if (config.useContentHashing &&
          local.dataHash != null &&
          remote.dataHash != null &&
          local.dataHash != remote.dataHash) {
        return true;
      }
    }

    return false;
  }

  /// Check for content-based conflict
  bool _isContentConflict(
    EntityVersion local,
    EntityVersion remote,
  ) {
    if (!config.useContentHashing) {
      return false; // Can't detect content conflicts without hashing
    }

    // If hashes are different, there's a content conflict
    if (local.dataHash != null &&
        remote.dataHash != null &&
        local.dataHash != remote.dataHash) {
      // But only if timestamps are concurrent (otherwise it's just an update)
      return areTimestampsConcurrent(
        timestamp1: local.lastModified,
        timestamp2: remote.lastModified,
      );
    }

    return false;
  }

  /// Generate unique conflict ID
  String _generateConflictId(
    EntityVersion local,
    EntityVersion remote,
  ) {
    final data = '${local.entityId}_${local.version}_${remote.version}_'
        '${DateTime.now().millisecondsSinceEpoch}';
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes);
    return hash.toString().substring(0, 16);
  }

  /// Format timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now().toUtc();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  void dispose() {
    _conflictStreamController?.close();
  }
}

/// Utility for generating content hashes
class ContentHasher {
  /// Generate SHA256 hash of JSON data
  static String? hashData(Map<String, dynamic>? data) {
    if (data == null) return null;

    try {
      final jsonString = jsonEncode(data);
      final bytes = utf8.encode(jsonString);
      final hash = sha256.convert(bytes);
      return hash.toString();
    } catch (e) {
      // If encoding fails, return null
      return null;
    }
  }

  /// Compare two data maps for equality
  static bool areDataEqual(
    Map<String, dynamic>? data1,
    Map<String, dynamic>? data2,
  ) {
    if (data1 == null && data2 == null) return true;
    if (data1 == null || data2 == null) return false;

    return jsonEncode(data1) == jsonEncode(data2);
  }
}
