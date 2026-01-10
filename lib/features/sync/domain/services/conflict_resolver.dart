import '../models/conflict_info.dart';
import '../models/conflict_resolution.dart';
import '../models/entity_version.dart';

/// Configuration for conflict resolution
class ConflictResolutionConfig {
  /// Default strategy to use when conflict type doesn't mandate one
  final ConflictResolutionStrategy defaultStrategy;

  /// Whether to attempt automatic merge for compatible conflicts
  final bool attemptAutomaticMerge;

  /// Whether to prefer local version in last-write-wins for equal timestamps
  final bool preferLocalOnEqualTimestamps;

  /// Device ID for version tracking
  final String deviceId;

  /// Fields that should never be automatically merged (require manual resolution)
  final List<String> protectedFields;

  const ConflictResolutionConfig({
    this.defaultStrategy = ConflictResolutionStrategy.lastWriteWins,
    this.attemptAutomaticMerge = true,
    this.preferLocalOnEqualTimestamps = true,
    required this.deviceId,
    this.protectedFields = const [],
  });

  /// Default configuration
  factory ConflictResolutionConfig.defaultConfig({required String deviceId}) {
    return ConflictResolutionConfig(deviceId: deviceId);
  }

  /// Copy with method
  ConflictResolutionConfig copyWith({
    ConflictResolutionStrategy? defaultStrategy,
    bool? attemptAutomaticMerge,
    bool? preferLocalOnEqualTimestamps,
    String? deviceId,
    List<String>? protectedFields,
  }) {
    return ConflictResolutionConfig(
      defaultStrategy: defaultStrategy ?? this.defaultStrategy,
      attemptAutomaticMerge:
          attemptAutomaticMerge ?? this.attemptAutomaticMerge,
      preferLocalOnEqualTimestamps:
          preferLocalOnEqualTimestamps ?? this.preferLocalOnEqualTimestamps,
      deviceId: deviceId ?? this.deviceId,
      protectedFields: protectedFields ?? this.protectedFields,
    );
  }
}

/// Abstract interface for conflict resolution service
///
/// Resolves conflicts detected during sync using various strategies:
/// - Last-write-wins: Uses timestamps to determine which version to keep
/// - Manual: Requires user intervention to choose or merge
/// - Automatic merge: Merges non-overlapping fields automatically
abstract class ConflictResolver {
  /// Current configuration
  ConflictResolutionConfig get config;

  /// Update configuration
  void updateConfig(ConflictResolutionConfig config);

  /// Resolve a single conflict using the specified strategy
  ///
  /// Takes [conflict] information and applies the given [strategy].
  /// For manual resolution, [userChoice] and [userData] can be provided.
  /// Returns a [ConflictResolution] with the resolved data and version.
  ///
  /// Throws [ArgumentError] if the strategy is not supported or if required
  /// data (localData, remoteData) is missing.
  Future<ConflictResolution> resolveConflict({
    required ConflictInfo conflict,
    ConflictResolutionStrategy? strategy,
    ManualResolutionChoice? userChoice,
    Map<String, dynamic>? userData,
  });

  /// Resolve multiple conflicts in batch
  ///
  /// Takes a list of [conflicts] and optional [strategies] for each.
  /// If strategies are not provided, uses default strategy selection logic.
  /// Returns a [BatchResolutionResult] with successful and failed resolutions.
  Future<BatchResolutionResult> resolveMultipleConflicts({
    required List<ConflictInfo> conflicts,
    List<ConflictResolutionStrategy>? strategies,
    List<ManualResolutionChoice>? userChoices,
    List<Map<String, dynamic>?> userDataList,
  });

  /// Apply last-write-wins strategy
  ///
  /// Compares timestamps of local and remote versions and selects the newer one.
  /// If timestamps are equal, uses [preferLocal] preference.
  Future<ConflictResolution> resolveWithLastWriteWins({
    required ConflictInfo conflict,
    bool preferLocal = true,
  });

  /// Apply manual resolution strategy
  ///
  /// Uses [userChoice] to determine resolution:
  /// - [ManualResolutionChoice.keepLocal]: Keeps local version
  /// - [ManualResolutionChoice.keepRemote]: Keeps remote version
  /// - [ManualResolutionChoice.customMerge]: Uses [customData] as merged result
  Future<ConflictResolution> resolveManually({
    required ConflictInfo conflict,
    required ManualResolutionChoice userChoice,
    Map<String, dynamic>? customData,
  });

  /// Apply automatic merge strategy
  ///
  /// Merges local and remote data by combining non-overlapping fields.
  /// Returns a [ConflictResolution] with merged data, or throws if merge fails.
  Future<ConflictResolution> resolveWithAutomaticMerge({
    required ConflictInfo conflict,
  });

  /// Determine the best strategy for a given conflict
  ///
  /// Analyzes the conflict type, severity, and data to recommend a strategy.
  /// Returns the recommended [ConflictResolutionStrategy].
  ConflictResolutionStrategy recommendStrategy({
    required ConflictInfo conflict,
  });

  /// Check if automatic merge is possible for a conflict
  ///
  /// Returns true if local and remote data have no overlapping conflicts.
  bool canMergeAutomatically({
    required ConflictInfo conflict,
  });

  /// Attempt to merge local and remote data
  ///
  /// Tries to merge [localData] and [remoteData] by combining non-overlapping fields.
  /// Returns a [MergeResult] with merged data and information about conflicts.
  MergeResult attemptMerge({
    required Map<String, dynamic>? localData,
    required Map<String, dynamic>? remoteData,
    List<String> protectedFields = const [],
  });

  /// Create resolved version
  ///
  /// Creates a new [EntityVersion] for the resolved entity by incrementing
  /// the max version number from local and remote.
  EntityVersion createResolvedVersion({
    required ConflictInfo conflict,
    required ConflictResolutionStrategy strategy,
    EntityVersion? baseVersion,
  });

  /// Validate resolution data
  ///
  /// Validates that [data] contains all required fields for the entity type.
  /// Returns true if valid, false otherwise.
  bool validateResolutionData({
    required String entityType,
    required Map<String, dynamic> data,
  });

  /// Generate resolution description
  ///
  /// Creates a human-readable description of how the conflict was resolved.
  String generateResolutionDescription({
    required ConflictResolution resolution,
  });

  /// Dispose of resources
  void dispose();
}

/// Provider signature for dependency injection
typedef ConflictResolverProvider = ConflictResolver Function();
