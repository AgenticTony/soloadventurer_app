import 'package:flutter_test/flutter_test.dart';
import 'package:solo_adventurer_app/features/sync/domain/models/conflict_resolution.dart';
import 'package:solo_adventurer_app/features/sync/domain/models/conflict_info.dart';
import 'package:solo_adventurer_app/features/sync/domain/models/entity_version.dart';

void main() {
  group('ConflictResolution', () {
    late ConflictInfo baseConflict;
    late EntityVersion localVersion;
    late EntityVersion remoteVersion;

    setUp(() {
      final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
      localVersion = EntityVersion(
        entityId: 'entity-1',
        entityType: 'trip',
        version: 2,
        deviceId: 'device-local',
        updatedAt: now,
        createdAt: now.subtract(const Duration(minutes: 5)),
        contentHash: 'hash-local',
      );
      remoteVersion = EntityVersion(
        entityId: 'entity-1',
        entityType: 'trip',
        version: 2,
        deviceId: 'device-remote',
        updatedAt: now.add(const Duration(seconds: 30)),
        createdAt: now.subtract(const Duration(minutes: 5)),
        contentHash: 'hash-remote',
      );

      baseConflict = ConflictInfo(
        conflictId: 'conflict-1',
        entityId: 'entity-1',
        entityType: 'trip',
        conflictType: ConflictType.versionConflict,
        severity: ConflictSeverity.medium,
        localVersion: localVersion,
        remoteVersion: remoteVersion,
        localData: {'name': 'Local Trip', 'duration': 5},
        remoteData: {'name': 'Remote Trip', 'duration': 7},
        description: 'Versions conflict',
        detectedAt: now,
      );
    });

    test('should create conflict resolution correctly', () {
      final resolvedVersion = EntityVersion(
        entityId: 'entity-1',
        entityType: 'trip',
        version: 3,
        deviceId: 'device-resolver',
        updatedAt: DateTime.utc(2024, 1, 1, 12, 0, 30),
        createdAt: localVersion.createdAt,
      );

      final resolution = ConflictResolution(
        conflictId: 'conflict-1',
        entityId: 'entity-1',
        entityType: 'trip',
        strategy: ConflictResolutionStrategy.lastWriteWins,
        resolvedData: {'name': 'Resolved Trip', 'duration': 7},
        resolvedVersion: resolvedVersion,
        choseRemote: true,
        resolvedAt: DateTime.utc(2024, 1, 1, 12, 0, 30),
      );

      expect(resolution.conflictId, 'conflict-1');
      expect(resolution.strategy, ConflictResolutionStrategy.lastWriteWins);
      expect(resolution.choseRemote, true);
      expect(resolution.choseLocal, false);
      expect(resolution.isMerged, false);
    });

    test('should copy with new values', () {
      final resolution = ConflictResolution(
        conflictId: 'conflict-1',
        entityId: 'entity-1',
        entityType: 'trip',
        strategy: ConflictResolutionStrategy.manual,
        resolvedData: {'name': 'Test'},
        resolvedVersion: localVersion,
        resolvedAt: DateTime.utc(2024, 1, 1, 12, 0, 0),
      );

      final updated = resolution.copyWith(
        strategy: ConflictResolutionStrategy.automaticMerge,
        isMerged: true,
      );

      expect(updated.strategy, ConflictResolutionStrategy.automaticMerge);
      expect(updated.isMerged, true);
      expect(updated.conflictId, resolution.conflictId);
    });

    test('should serialize to JSON', () {
      final resolution = ConflictResolution(
        conflictId: 'conflict-1',
        entityId: 'entity-1',
        entityType: 'trip',
        strategy: ConflictResolutionStrategy.lastWriteWins,
        resolvedData: {'name': 'Test', 'duration': 5},
        resolvedVersion: localVersion,
        choseLocal: true,
        localFieldsUsed: ['name'],
        remoteFieldsUsed: ['duration'],
        resolvedAt: DateTime.utc(2024, 1, 1, 12, 0, 0),
        metadata: {'source': 'auto'},
      );

      final json = resolution.toJson();

      expect(json['conflictId'], 'conflict-1');
      expect(json['strategy'], 'lastWriteWins');
      expect(json['choseLocal'], true);
      expect(json['localFieldsUsed'], ['name']);
      expect(json['remoteFieldsUsed'], ['duration']);
      expect(json['metadata'], {'source': 'auto'});
    });

    test('should deserialize from JSON', () {
      final json = {
        'conflictId': 'conflict-1',
        'entityId': 'entity-1',
        'entityType': 'trip',
        'strategy': 'automaticMerge',
        'resolvedData': {'name': 'Test'},
        'resolvedVersion': localVersion.toJson(),
        'choseLocal': false,
        'choseRemote': false,
        'isMerged': true,
        'localFieldsUsed': ['field1'],
        'remoteFieldsUsed': ['field2'],
        'conflictingFields': ['field3'],
        'userProvidedData': {'custom': 'value'},
        'resolvedAt': '2024-01-01T12:00:00.000Z',
        'metadata': {'test': 'data'},
      };

      final resolution = ConflictResolution.fromJson(json);

      expect(resolution.conflictId, 'conflict-1');
      expect(resolution.strategy, ConflictResolutionStrategy.automaticMerge);
      expect(resolution.isMerged, true);
      expect(resolution.localFieldsUsed, ['field1']);
      expect(resolution.remoteFieldsUsed, ['field2']);
      expect(resolution.conflictingFields, ['field3']);
      expect(resolution.userProvidedData, {'custom': 'value'});
    });
  });

  group('MergeResult', () {
    test('should create successful merge result', () {
      final result = MergeResult.success(
        mergedData: {'name': 'Merged', 'duration': 5},
        localFieldsUsed: ['name'],
        remoteFieldsUsed: ['duration'],
      );

      expect(result.success, true);
      expect(result.mergedData, {'name': 'Merged', 'duration': 5});
      expect(result.localFieldsUsed, ['name']);
      expect(result.remoteFieldsUsed, ['duration']);
      expect(result.hasConflicts, false);
    });

    test('should create merge result with conflicts', () {
      final result = MergeResult.success(
        mergedData: {'name': 'Local', 'duration': 5},
        localFieldsUsed: ['name', 'duration'],
        remoteFieldsUsed: ['location'],
        conflictingFields: ['duration'],
      );

      expect(result.success, true);
      expect(result.hasConflicts, true);
      expect(result.conflictingFields, ['duration']);
    });

    test('should create failed merge result', () {
      final result = MergeResult.failure('All fields conflict');

      expect(result.success, false);
      expect(result.errorMessage, 'All fields conflict');
      expect(result.mergedData, isNull);
    });

    test('should calculate field counts correctly', () {
      final result = MergeResult.success(
        mergedData: {'a': 1, 'b': 2, 'c': 3},
        localFieldsUsed: ['a', 'b'],
        remoteFieldsUsed: ['c'],
        conflictingFields: ['b'],
      );

      expect(result.localFieldCount, 2);
      expect(result.remoteFieldCount, 1);
      expect(result.totalFieldCount, 3);
    });
  });

  group('BatchResolutionResult', () {
    test('should create all resolved result', () {
      final resolution1 = ConflictResolution(
        conflictId: 'conflict-1',
        entityId: 'entity-1',
        entityType: 'trip',
        strategy: ConflictResolutionStrategy.lastWriteWins,
        resolvedData: {'name': 'Test1'},
        resolvedVersion: EntityVersion.initial(
          entityId: 'entity-1',
          entityType: 'trip',
          deviceId: 'device-1',
        ),
        resolvedAt: DateTime.now(),
      );

      final resolution2 = ConflictResolution(
        conflictId: 'conflict-2',
        entityId: 'entity-2',
        entityType: 'trip',
        strategy: ConflictResolutionStrategy.manual,
        resolvedData: {'name': 'Test2'},
        resolvedVersion: EntityVersion.initial(
          entityId: 'entity-2',
          entityType: 'trip',
          deviceId: 'device-1',
        ),
        resolvedAt: DateTime.now(),
      );

      final result = BatchResolutionResult.allResolved(
        resolutions: [resolution1, resolution2],
      );

      expect(result.totalConflicts, 2);
      expect(result.resolvedCount, 2);
      expect(result.failedCount, 0);
      expect(result.isComplete, true);
    });

    test('should create result with failures', () {
      final resolution = ConflictResolution(
        conflictId: 'conflict-1',
        entityId: 'entity-1',
        entityType: 'trip',
        strategy: ConflictResolutionStrategy.lastWriteWins,
        resolvedData: {'name': 'Test'},
        resolvedVersion: EntityVersion.initial(
          entityId: 'entity-1',
          entityType: 'trip',
          deviceId: 'device-1',
        ),
        resolvedAt: DateTime.now(),
      );

      final conflict = ConflictInfo(
        conflictId: 'conflict-2',
        entityId: 'entity-2',
        entityType: 'trip',
        conflictType: ConflictType.diverged,
        severity: ConflictSeverity.high,
        localVersion: EntityVersion.initial(
          entityId: 'entity-2',
          entityType: 'trip',
          deviceId: 'device-1',
        ),
        remoteVersion: EntityVersion.initial(
          entityId: 'entity-2',
          entityType: 'trip',
          deviceId: 'device-2',
        ),
        description: 'Failed conflict',
        detectedAt: DateTime.now(),
      );

      final result = BatchResolutionResult(
        totalConflicts: 2,
        resolvedCount: 1,
        failedCount: 1,
        resolutions: [resolution],
        failedConflicts: [conflict],
        errors: {'conflict-2': 'Merge failed'},
      );

      expect(result.totalConflicts, 2);
      expect(result.resolvedCount, 1);
      expect(result.failedCount, 1);
      expect(result.isComplete, false);
      expect(result.errors['conflict-2'], 'Merge failed');
    });
  });

  group('ConflictResolutionStrategy', () {
    test('should have all required strategies', () {
      final strategies = ConflictResolutionStrategy.values;

      expect(strategies.length, 3);
      expect(strategies, contains(ConflictResolutionStrategy.lastWriteWins));
      expect(strategies, contains(ConflictResolutionStrategy.manual));
      expect(strategies, contains(ConflictResolutionStrategy.automaticMerge));
    });
  });

  group('ManualResolutionChoice', () {
    test('should have all required choices', () {
      final choices = ManualResolutionChoice.values;

      expect(choices.length, 3);
      expect(choices, contains(ManualResolutionChoice.keepLocal));
      expect(choices, contains(ManualResolutionChoice.keepRemote));
      expect(choices, contains(ManualResolutionChoice.customMerge));
    });
  });
}
