import '../models/entity_version.dart';
import '../models/conflict_info.dart';

/// Strategy for detecting conflicts
enum ConflictDetectionStrategy {
  /// Use version numbers for conflict detection
  versionBased,

  /// Use timestamps (last-write-wins) for conflict detection
  timestampBased,

  /// Use both version numbers and timestamps for robust detection
  hybrid,

  /// Use content hashes to detect actual data changes
  contentBased,
}

/// Configuration for conflict detection
class ConflictDetectionConfig {
  /// Primary strategy to use for conflict detection
  final ConflictDetectionStrategy strategy;

  /// Time threshold for considering timestamps as concurrent (in milliseconds)
  /// If two timestamps are within this threshold, they're considered concurrent
  final int timestampThresholdMs;

  /// Whether to use content hashing to detect actual changes
  final bool useContentHashing;

  /// Whether to consider same-version numbers with different hashes as conflicts
  final bool detectSameVersionConflicts;

  /// Device ID for version tracking
  final String deviceId;

  const ConflictDetectionConfig({
    this.strategy = ConflictDetectionStrategy.hybrid,
    this.timestampThresholdMs = 1000, // 1 second default
    this.useContentHashing = true,
    this.detectSameVersionConflicts = true,
    required this.deviceId,
  });

  /// Default configuration
  factory ConflictDetectionConfig.defaultConfig({required String deviceId}) {
    return ConflictDetectionConfig(deviceId: deviceId);
  }

  /// Copy with method
  ConflictDetectionConfig copyWith({
    ConflictDetectionStrategy? strategy,
    int? timestampThresholdMs,
    bool? useContentHashing,
    bool? detectSameVersionConflicts,
    String? deviceId,
  }) {
    return ConflictDetectionConfig(
      strategy: strategy ?? this.strategy,
      timestampThresholdMs: timestampThresholdMs ?? this.timestampThresholdMs,
      useContentHashing: useContentHashing ?? this.useContentHashing,
      detectSameVersionConflicts:
          detectSameVersionConflicts ?? this.detectSameVersionConflicts,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}

/// Abstract interface for conflict detection service
///
/// Detects conflicts when the same entity was modified on multiple devices.
/// Uses version vectors or timestamps to identify divergent changes.
abstract class ConflictDetector {
  /// Current configuration
  ConflictDetectionConfig get config;

  /// Update configuration
  void updateConfig(ConflictDetectionConfig config);

  /// Detect conflicts between local and remote versions of an entity
  ///
  /// Compares [localVersion] with [remoteVersion] to determine if there's a conflict.
  /// Returns [ConflictInfo] if a conflict is detected, null otherwise.
  ///
  /// Parameters:
  /// - [localVersion]: Version information from local storage
  /// - [remoteVersion]: Version information from remote server
  /// - [localData]: Optional local entity data for content comparison
  /// - [remoteData]: Optional remote entity data for content comparison
  Future<ConflictInfo?> detectConflict({
    required EntityVersion localVersion,
    required EntityVersion remoteVersion,
    Map<String, dynamic>? localData,
    Map<String, dynamic>? remoteData,
  });

  /// Detect conflicts for multiple entities
  ///
  /// Takes lists of local and remote versions and detects conflicts for matching entities.
  /// Returns a [ConflictDetectionResult] with all detected conflicts.
  Future<ConflictDetectionResult> detectMultipleConflicts({
    required List<EntityVersion> localVersions,
    required List<EntityVersion> remoteVersions,
    Map<String, Map<String, dynamic>>? localDataMap,
    Map<String, Map<String, dynamic>>? remoteDataMap,
  });

  /// Check if two versions are in conflict
  ///
  /// Returns true if the versions represent conflicting changes.
  bool isInConflict({
    required EntityVersion localVersion,
    required EntityVersion remoteVersion,
  });

  /// Determine conflict type
  ///
  /// Analyzes the two versions and determines what type of conflict occurred.
  ConflictType determineConflictType({
    required EntityVersion localVersion,
    required EntityVersion remoteVersion,
  });

  /// Determine conflict severity
  ///
  /// Analyzes the conflict and determines its severity level.
  ConflictSeverity determineConflictSeverity({
    required ConflictType conflictType,
    required EntityVersion localVersion,
    required EntityVersion remoteVersion,
  });

  /// Generate human-readable conflict description
  ///
  /// Creates a user-friendly description of what happened.
  String generateConflictDescription({
    required ConflictType conflictType,
    required EntityVersion localVersion,
    required EntityVersion remoteVersion,
  });

  /// Compare two versions based on the configured strategy
  ///
  /// Returns:
  /// - positive if localVersion is newer
  /// - negative if remoteVersion is newer
  /// - zero if they are equivalent
  int compareVersions({
    required EntityVersion localVersion,
    required EntityVersion remoteVersion,
  });

  /// Check if two timestamps are within the concurrent threshold
  ///
  /// Returns true if the timestamps are close enough to be considered concurrent.
  bool areTimestampsConcurrent({
    required DateTime timestamp1,
    required DateTime timestamp2,
  });

  /// Dispose of resources
  void dispose();
}

/// Provider signature for dependency injection
typedef ConflictDetectorProvider = ConflictDetector Function();
