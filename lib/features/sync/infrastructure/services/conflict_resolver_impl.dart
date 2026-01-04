import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/models/conflict_info.dart';
import '../../domain/models/conflict_resolution.dart';
import '../../domain/models/entity_version.dart';
import '../../domain/services/conflict_resolver.dart';

/// Default implementation of [ConflictResolver]
///
/// Provides multiple conflict resolution strategies:
/// - Last-write-wins: Selects version based on timestamp
/// - Manual: Allows user to choose or provide custom data
/// - Automatic merge: Merges non-overlapping fields
class ConflictResolverImpl extends ConflictResolver {
  /// Current configuration
  @override
  ConflictResolutionConfig config;

  /// Stream controller for resolution events (optional, for future use)
  StreamController<ConflictResolution>? _resolutionStreamController;

  /// Creates a new [ConflictResolverImpl] with the given configuration
  ConflictResolverImpl({
    ConflictResolutionConfig? config,
  }) : config = config ?? ConflictResolutionConfig.defaultConfig(
          deviceId: 'default-device',
        ) {
    _resolutionStreamController =
        StreamController<ConflictResolution>.broadcast();
  }

  @override
  void updateConfig(ConflictResolutionConfig config) {
    this.config = config;
  }

  @override
  Future<ConflictResolution> resolveConflict({
    required ConflictInfo conflict,
    ConflictResolutionStrategy? strategy,
    ManualResolutionChoice? userChoice,
    Map<String, dynamic>? userData,
  }) async {
    // Determine strategy if not provided
    final resolvedStrategy = strategy ?? recommendStrategy(conflict: conflict);

    // Dispatch based on strategy
    switch (resolvedStrategy) {
      case ConflictResolutionStrategy.lastWriteWins:
        return await resolveWithLastWriteWins(
          conflict: conflict,
          preferLocal: config.preferLocalOnEqualTimestamps,
        );

      case ConflictResolutionStrategy.manual:
        if (userChoice == null) {
          throw ArgumentError(
            'Manual resolution requires userChoice parameter',
          );
        }
        return await resolveManually(
          conflict: conflict,
          userChoice: userChoice,
          customData: userData,
        );

      case ConflictResolutionStrategy.automaticMerge:
        return await resolveWithAutomaticMerge(conflict: conflict);
    }
  }

  @override
  Future<BatchResolutionResult> resolveMultipleConflicts({
    required List<ConflictInfo> conflicts,
    List<ConflictResolutionStrategy>? strategies,
    List<ManualResolutionChoice>? userChoices,
    List<Map<String, dynamic>? > userDataList,
  }) async {
    final resolutions = <ConflictResolution>[];
    final failedConflicts = <ConflictInfo>[];
    final errors = <String, String>{};

    for (int i = 0; i < conflicts.length; i++) {
      final conflict = conflicts[i];
      final strategy = strategies?.elementAt(i);
      final userChoice = userChoices?.elementAt(i);
      final userData = userDataList?.elementAt(i);

      try {
        final resolution = await resolveConflict(
          conflict: conflict,
          strategy: strategy,
          userChoice: userChoice,
          userData: userData,
        );
        resolutions.add(resolution);
      } catch (e) {
        failedConflicts.add(conflict);
        errors[conflict.conflictId] = e.toString();
      }
    }

    return BatchResolutionResult(
      totalConflicts: conflicts.length,
      resolvedCount: resolutions.length,
      failedCount: failedConflicts.length,
      resolutions: resolutions,
      failedConflicts: failedConflicts,
      errors: errors,
    );
  }

  @override
  Future<ConflictResolution> resolveWithLastWriteWins({
    required ConflictInfo conflict,
    bool preferLocal = true,
  }) async {
    // Ensure we have data to compare
    if (conflict.localData == null || conflict.remoteData == null) {
      throw ArgumentError(
        'Last-write-wins requires both localData and remoteData',
      );
    }

    // Compare timestamps
    final localTimestamp = conflict.localVersion.updatedAt;
    final remoteTimestamp = conflict.remoteVersion.updatedAt;

    Map<String, dynamic> resolvedData;
    bool choseLocal = false;
    bool choseRemote = false;

    if (localTimestamp.isAfter(remoteTimestamp)) {
      // Local is newer
      resolvedData = conflict.localData!;
      choseLocal = true;
    } else if (remoteTimestamp.isAfter(localTimestamp)) {
      // Remote is newer
      resolvedData = conflict.remoteData!;
      choseRemote = true;
    } else {
      // Timestamps are equal, use preference
      if (preferLocal) {
        resolvedData = conflict.localData!;
        choseLocal = true;
      } else {
        resolvedData = conflict.remoteData!;
        choseRemote = true;
      }
    }

    // Create resolved version
    final resolvedVersion = createResolvedVersion(
      conflict: conflict,
      strategy: ConflictResolutionStrategy.lastWriteWins,
    );

    final resolution = ConflictResolution(
      conflictId: conflict.conflictId,
      entityId: conflict.entityId,
      entityType: conflict.entityType,
      strategy: ConflictResolutionStrategy.lastWriteWins,
      resolvedData: resolvedData,
      resolvedVersion: resolvedVersion,
      choseLocal: choseLocal,
      choseRemote: choseRemote,
      resolvedAt: DateTime.now().toUtc(),
    );

    // Emit to stream
    _resolutionStreamController?.add(resolution);

    return resolution;
  }

  @override
  Future<ConflictResolution> resolveManually({
    required ConflictInfo conflict,
    required ManualResolutionChoice userChoice,
    Map<String, dynamic>? customData,
  }) async {
    Map<String, dynamic> resolvedData;
    bool choseLocal = false;
    bool choseRemote = false;
    List<String> localFieldsUsed = const [];
    List<String> remoteFieldsUsed = const [];

    switch (userChoice) {
      case ManualResolutionChoice.keepLocal:
        if (conflict.localData == null) {
          throw ArgumentError('Local data is required to keep local version');
        }
        resolvedData = conflict.localData!;
        choseLocal = true;
        localFieldsUsed = conflict.localData!.keys.toList();
        break;

      case ManualResolutionChoice.keepRemote:
        if (conflict.remoteData == null) {
          throw ArgumentError('Remote data is required to keep remote version');
        }
        resolvedData = conflict.remoteData!;
        choseRemote = true;
        remoteFieldsUsed = conflict.remoteData!.keys.toList();
        break;

      case ManualResolutionChoice.customMerge:
        if (customData == null) {
          throw ArgumentError(
            'Custom data is required for custom merge resolution',
          );
        }
        resolvedData = customData;
        // Determine which fields came from where
        if (conflict.localData != null) {
          for (final key in conflict.localData!.keys) {
            if (customData.containsKey(key)) {
              localFieldsUsed.add(key);
            }
          }
        }
        if (conflict.remoteData != null) {
          for (final key in conflict.remoteData!.keys) {
            if (customData.containsKey(key)) {
              remoteFieldsUsed.add(key);
            }
          }
        }
        break;
    }

    // Create resolved version
    final resolvedVersion = createResolvedVersion(
      conflict: conflict,
      strategy: ConflictResolutionStrategy.manual,
    );

    final resolution = ConflictResolution(
      conflictId: conflict.conflictId,
      entityId: conflict.entityId,
      entityType: conflict.entityType,
      strategy: ConflictResolutionStrategy.manual,
      resolvedData: resolvedData,
      resolvedVersion: resolvedVersion,
      choseLocal: choseLocal,
      choseRemote: choseRemote,
      isMerged: userChoice == ManualResolutionChoice.customMerge,
      localFieldsUsed: localFieldsUsed,
      remoteFieldsUsed: remoteFieldsUsed,
      userProvidedData: customData,
      resolvedAt: DateTime.now().toUtc(),
    );

    // Emit to stream
    _resolutionStreamController?.add(resolution);

    return resolution;
  }

  @override
  Future<ConflictResolution> resolveWithAutomaticMerge({
    required ConflictInfo conflict,
  }) async {
    if (conflict.localData == null || conflict.remoteData == null) {
      throw ArgumentError(
        'Automatic merge requires both localData and remoteData',
      );
    }

    // Attempt merge
    final mergeResult = attemptMerge(
      localData: conflict.localData,
      remoteData: conflict.remoteData,
      protectedFields: config.protectedFields,
    );

    if (!mergeResult.success) {
      throw StateError(
        'Automatic merge failed: ${mergeResult.errorMessage}',
      );
    }

    // Create resolved version
    final resolvedVersion = createResolvedVersion(
      conflict: conflict,
      strategy: ConflictResolutionStrategy.automaticMerge,
    );

    final resolution = ConflictResolution(
      conflictId: conflict.conflictId,
      entityId: conflict.entityId,
      entityType: conflict.entityType,
      strategy: ConflictResolutionStrategy.automaticMerge,
      resolvedData: mergeResult.mergedData!,
      resolvedVersion: resolvedVersion,
      isMerged: true,
      localFieldsUsed: mergeResult.localFieldsUsed,
      remoteFieldsUsed: mergeResult.remoteFieldsUsed,
      conflictingFields: mergeResult.conflictingFields,
      resolvedAt: DateTime.now().toUtc(),
      metadata: {
        'mergeType': mergeResult.hasConflicts ? 'partial' : 'full',
        'totalFields': mergeResult.totalFieldCount,
        'conflictCount': mergeResult.conflictingFields.length,
      },
    );

    // Emit to stream
    _resolutionStreamController?.add(resolution);

    return resolution;
  }

  @override
  ConflictResolutionStrategy recommendStrategy({
    required ConflictInfo conflict,
  }) {
    // If conflict can be auto-resolved, use last-write-wins
    if (conflict.canAutoResolve) {
      return ConflictResolutionStrategy.lastWriteWins;
    }

    // Check if automatic merge is possible
    if (canMergeAutomatically(conflict: conflict)) {
      return ConflictResolutionStrategy.automaticMerge;
    }

    // Default to manual resolution for complex conflicts
    return ConflictResolutionStrategy.manual;
  }

  @override
  bool canMergeAutomatically({
    required ConflictInfo conflict,
  }) {
    // Need data to merge
    if (conflict.localData == null || conflict.remoteData == null) {
      return false;
    }

    // Check for protected fields that are in conflict
    for (final field in config.protectedFields) {
      final localValue = conflict.localData![field];
      final remoteValue = conflict.remoteData![field];

      if (localValue != null && remoteValue != null && localValue != remoteValue) {
        // Protected field has different values, cannot auto-merge
        return false;
      }
    }

    // Attempt merge and check if it succeeds without conflicts
    final mergeResult = attemptMerge(
      localData: conflict.localData,
      remoteData: conflict.remoteData,
      protectedFields: config.protectedFields,
    );

    return mergeResult.success && !mergeResult.hasConflicts;
  }

  @override
  MergeResult attemptMerge({
    required Map<String, dynamic>? localData,
    required Map<String, dynamic>? remoteData,
    List<String> protectedFields = const [],
  }) {
    if (localData == null || remoteData == null) {
      return MergeResult.failure('Both local and remote data are required');
    }

    final mergedData = <String, dynamic>{};
    final localFieldsUsed = <String>[];
    final remoteFieldsUsed = <String>[];
    final conflictingFields = <String>[];

    // Get all unique keys from both datasets
    final allKeys = {...localData.keys, ...remoteData.keys};

    for (final key in allKeys) {
      final localValue = localData[key];
      final remoteValue = remoteData[key];

      if (!localData.containsKey(key)) {
        // Key only in remote
        mergedData[key] = remoteValue;
        remoteFieldsUsed.add(key);
      } else if (!remoteData.containsKey(key)) {
        // Key only in local
        mergedData[key] = localValue;
        localFieldsUsed.add(key);
      } else {
        // Key in both - check if values are the same
        if (localValue == remoteValue) {
          // Same value, use it
          mergedData[key] = localValue;
          localFieldsUsed.add(key);
          remoteFieldsUsed.add(key);
        } else {
          // Different values - conflict
          if (protectedFields.contains(key)) {
            // Protected field with conflict - fail merge
            return MergeResult.failure(
              'Protected field "$key" has conflicting values',
            );
          } else {
            // Non-protected field - record conflict but continue
            conflictingFields.add(key);
            // Use local value as default for conflicting field
            mergedData[key] = localValue;
            localFieldsUsed.add(key);
          }
        }
      }
    }

    // If all fields conflict, merge failed
    if (allKeys.isNotEmpty && conflictingFields.length == allKeys.length) {
      return MergeResult.failure('All fields have conflicting values');
    }

    return MergeResult.success(
      mergedData: mergedData,
      localFieldsUsed: localFieldsUsed,
      remoteFieldsUsed: remoteFieldsUsed,
      conflictingFields: conflictingFields,
    );
  }

  @override
  EntityVersion createResolvedVersion({
    required ConflictInfo conflict,
    required ConflictResolutionStrategy strategy,
    EntityVersion? baseVersion,
  }) {
    // Increment version number from max of local and remote
    final maxVersion = [conflict.localVersion.version, conflict.remoteVersion.version]
        .reduce((a, b) => a > b ? a : b);

    // Use most recent timestamp
    final latestTimestamp = [
      conflict.localVersion.updatedAt,
      conflict.remoteVersion.updatedAt,
    ].reduce((a, b) => a.isAfter(b) ? a : b);

    return EntityVersion(
      entityId: conflict.entityId,
      entityType: conflict.entityType,
      version: maxVersion + 1,
      deviceId: config.deviceId,
      updatedAt: DateTime.now().toUtc(),
      createdAt: baseVersion?.createdAt ?? latestTimestamp,
      contentHash: null, // Will be computed when data is saved
    );
  }

  @override
  bool validateResolutionData({
    required String entityType,
    required Map<String, dynamic> data,
  }) {
    // Basic validation - data should not be empty
    if (data.isEmpty) {
      return false;
    }

    // Entity-type specific validation can be added here
    // For now, just check that data has some content
    return true;
  }

  @override
  String generateResolutionDescription({
    required ConflictResolution resolution,
  }) {
    switch (resolution.strategy) {
      case ConflictResolutionStrategy.lastWriteWins:
        if (resolution.choseLocal) {
          return 'Kept local version (last write wins)';
        } else {
          return 'Kept remote version (last write wins)';
        }

      case ConflictResolutionStrategy.manual:
        if (resolution.userProvidedData != null) {
          return 'Merged manually with custom changes';
        } else if (resolution.choseLocal) {
          return 'Chose to keep local version';
        } else {
          return 'Chose to keep remote version';
        }

      case ConflictResolutionStrategy.automaticMerge:
        final fieldCount = resolution.localFieldsUsed.length +
            resolution.remoteFieldsUsed.length;
        if (resolution.conflictingFields.isEmpty) {
          return 'Auto-merged $fieldCount fields';
        } else {
          return 'Auto-merged $fieldCount fields (${resolution.conflictingFields.length} conflicts)';
        }
    }
  }

  @override
  void dispose() {
    _resolutionStreamController?.close();
  }
}
