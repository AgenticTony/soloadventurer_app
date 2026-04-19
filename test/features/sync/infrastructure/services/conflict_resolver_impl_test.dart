import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_info.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_resolution.dart';
import 'package:soloadventurer/features/sync/domain/models/entity_version.dart';
import 'package:soloadventurer/features/sync/domain/services/conflict_resolver.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/conflict_resolver_impl.dart';

void main() {
  group('ConflictResolverImpl', () {
    late ConflictResolverImpl resolver;
    late String deviceId;

    setUp(() {
      deviceId = 'test-device';
      resolver = ConflictResolverImpl(
        config: ConflictResolutionConfig(
          deviceId: deviceId,
          preferLocalOnEqualTimestamps: true,
        ),
      );
    });

    tearDown(() {
      resolver.dispose();
    });

    group('Last-Write-Wins Resolution', () {
      test('should choose local when local is newer', () async {
        final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
        final localVersion = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          deviceId: 'device-local',
          lastModified: now.add(const Duration(minutes: 5)),
        );
        final remoteVersion = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          deviceId: 'device-remote',
          lastModified: now,
        );

        final conflict = ConflictInfo(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          conflictType: ConflictType.versionConflict,
          severity: ConflictSeverity.medium,
          localVersion: localVersion,
          remoteVersion: remoteVersion,
          localData: const {'name': 'Local Trip', 'duration': 5},
          remoteData: const {'name': 'Remote Trip', 'duration': 7},
          description: 'Local is newer',
          detectedAt: now,
        );

        final resolution = await resolver.resolveWithLastWriteWins(
          conflict: conflict,
        );

        expect(resolution.strategy, ConflictResolutionStrategy.lastWriteWins);
        expect(resolution.choseLocal, true);
        expect(resolution.choseRemote, false);
        expect(resolution.resolvedData, {'name': 'Local Trip', 'duration': 5});
        expect(resolution.resolvedVersion.version, 3);
      });

      test('should choose remote when remote is newer', () async {
        final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
        final localVersion = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          deviceId: 'device-local',
          lastModified: now,
        );
        final remoteVersion = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          deviceId: 'device-remote',
          lastModified: now.add(const Duration(minutes: 5)),
        );

        final conflict = ConflictInfo(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          conflictType: ConflictType.versionConflict,
          severity: ConflictSeverity.medium,
          localVersion: localVersion,
          remoteVersion: remoteVersion,
          localData: const {'name': 'Local Trip', 'duration': 5},
          remoteData: const {'name': 'Remote Trip', 'duration': 7},
          description: 'Remote is newer',
          detectedAt: now,
        );

        final resolution = await resolver.resolveWithLastWriteWins(
          conflict: conflict,
        );

        expect(resolution.strategy, ConflictResolutionStrategy.lastWriteWins);
        expect(resolution.choseLocal, false);
        expect(resolution.choseRemote, true);
        expect(resolution.resolvedData, {'name': 'Remote Trip', 'duration': 7});
      });

      test('should prefer local when timestamps are equal', () async {
        final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
        final localVersion = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          deviceId: 'device-local',
          lastModified: now,
        );
        final remoteVersion = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          deviceId: 'device-remote',
          lastModified: now,
        );

        final conflict = ConflictInfo(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          conflictType: ConflictType.timestampConflict,
          severity: ConflictSeverity.medium,
          localVersion: localVersion,
          remoteVersion: remoteVersion,
          localData: const {'name': 'Local Trip'},
          remoteData: const {'name': 'Remote Trip'},
          description: 'Same timestamp',
          detectedAt: now,
        );

        final resolution = await resolver.resolveWithLastWriteWins(
          conflict: conflict,
          preferLocal: true,
        );

        expect(resolution.choseLocal, true);
        expect(resolution.choseRemote, false);
      });

      test('should throw when data is missing', () async {
        final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
        final localVersion = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          deviceId: 'device-local',
          lastModified: now,
        );
        final remoteVersion = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          deviceId: 'device-remote',
          lastModified: now,
        );

        final conflict = ConflictInfo(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          conflictType: ConflictType.versionConflict,
          severity: ConflictSeverity.medium,
          localVersion: localVersion,
          remoteVersion: remoteVersion,
          description: 'Missing data',
          detectedAt: now,
        );

        expect(
          () => resolver.resolveWithLastWriteWins(conflict: conflict),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Manual Resolution', () {
      test('should keep local version', () async {
        final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
        final conflict = ConflictInfo(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          conflictType: ConflictType.versionConflict,
          severity: ConflictSeverity.high,
          localVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-local',
            lastModified: now,
          ),
          remoteVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-remote',
            lastModified: now,
          ),
          localData: const {'name': 'Local Trip', 'duration': 5},
          remoteData: const {'name': 'Remote Trip', 'duration': 7},
          description: 'Manual choice',
          detectedAt: now,
        );

        final resolution = await resolver.resolveManually(
          conflict: conflict,
          userChoice: ManualResolutionChoice.keepLocal,
        );

        expect(resolution.strategy, ConflictResolutionStrategy.manual);
        expect(resolution.choseLocal, true);
        expect(resolution.choseRemote, false);
        expect(resolution.resolvedData, {'name': 'Local Trip', 'duration': 5});
        expect(resolution.localFieldsUsed, ['name', 'duration']);
      });

      test('should keep remote version', () async {
        final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
        final conflict = ConflictInfo(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          conflictType: ConflictType.versionConflict,
          severity: ConflictSeverity.high,
          localVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-local',
            lastModified: now,
          ),
          remoteVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-remote',
            lastModified: now,
          ),
          localData: const {'name': 'Local Trip', 'duration': 5},
          remoteData: const {'name': 'Remote Trip', 'duration': 7},
          description: 'Manual choice',
          detectedAt: now,
        );

        final resolution = await resolver.resolveManually(
          conflict: conflict,
          userChoice: ManualResolutionChoice.keepRemote,
        );

        expect(resolution.strategy, ConflictResolutionStrategy.manual);
        expect(resolution.choseLocal, false);
        expect(resolution.choseRemote, true);
        expect(resolution.resolvedData, {'name': 'Remote Trip', 'duration': 7});
        expect(resolution.remoteFieldsUsed, ['name', 'duration']);
      });

      test('should use custom merge data', () async {
        final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
        final conflict = ConflictInfo(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          conflictType: ConflictType.versionConflict,
          severity: ConflictSeverity.high,
          localVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-local',
            lastModified: now,
          ),
          remoteVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-remote',
            lastModified: now,
          ),
          localData: const {'name': 'Local Trip', 'duration': 5},
          remoteData: const {'name': 'Remote Trip', 'duration': 7},
          description: 'Manual merge',
          detectedAt: now,
        );

        final customData = {
          'name': 'Custom Name',
          'duration': 10,
          'location': 'Custom Location',
        };

        final resolution = await resolver.resolveManually(
          conflict: conflict,
          userChoice: ManualResolutionChoice.customMerge,
          customData: customData,
        );

        expect(resolution.strategy, ConflictResolutionStrategy.manual);
        expect(resolution.isMerged, true);
        expect(resolution.resolvedData, customData);
        expect(resolution.userProvidedData, customData);
      });

      test('should throw when custom data is missing', () async {
        final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
        final conflict = ConflictInfo(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          conflictType: ConflictType.versionConflict,
          severity: ConflictSeverity.high,
          localVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-local',
            lastModified: now,
          ),
          remoteVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-remote',
            lastModified: now,
          ),
          localData: const {'name': 'Local Trip'},
          remoteData: const {'name': 'Remote Trip'},
          description: 'Manual merge',
          detectedAt: now,
        );

        expect(
          () => resolver.resolveManually(
            conflict: conflict,
            userChoice: ManualResolutionChoice.customMerge,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Automatic Merge Resolution', () {
      test('should merge non-overlapping fields', () async {
        final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
        final conflict = ConflictInfo(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          conflictType: ConflictType.versionConflict,
          severity: ConflictSeverity.medium,
          localVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-local',
            lastModified: now,
          ),
          remoteVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-remote',
            lastModified: now,
          ),
          localData: const {'name': 'Local Trip', 'duration': 5},
          remoteData: const {'location': 'Paris', 'budget': 1000},
          description: 'Non-overlapping data',
          detectedAt: now,
        );

        final resolution = await resolver.resolveWithAutomaticMerge(
          conflict: conflict,
        );

        expect(resolution.strategy, ConflictResolutionStrategy.automaticMerge);
        expect(resolution.isMerged, true);
        expect(resolution.resolvedData, {
          'name': 'Local Trip',
          'duration': 5,
          'location': 'Paris',
          'budget': 1000,
        });
        expect(resolution.localFieldsUsed, ['name', 'duration']);
        expect(resolution.remoteFieldsUsed, ['location', 'budget']);
        expect(resolution.conflictingFields, isEmpty);
      });

      test('should merge overlapping fields with same values', () async {
        final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
        final conflict = ConflictInfo(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          conflictType: ConflictType.versionConflict,
          severity: ConflictSeverity.medium,
          localVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-local',
            lastModified: now,
          ),
          remoteVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-remote',
            lastModified: now,
          ),
          localData: const {'name': 'Same Name', 'duration': 5},
          remoteData: const {'name': 'Same Name', 'location': 'Paris'},
          description: 'Same values',
          detectedAt: now,
        );

        final resolution = await resolver.resolveWithAutomaticMerge(
          conflict: conflict,
        );

        expect(resolution.resolvedData['name'], 'Same Name');
        expect(resolution.localFieldsUsed, contains('name'));
        expect(resolution.remoteFieldsUsed, contains('name'));
        expect(resolution.conflictingFields, isEmpty);
      });

      test('should handle overlapping fields with different values', () async {
        final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
        final conflict = ConflictInfo(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          conflictType: ConflictType.versionConflict,
          severity: ConflictSeverity.high,
          localVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-local',
            lastModified: now,
          ),
          remoteVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-remote',
            lastModified: now,
          ),
          localData: const {'name': 'Local Name', 'duration': 5},
          remoteData: const {'name': 'Remote Name', 'location': 'Paris'},
          description: 'Conflicting values',
          detectedAt: now,
        );

        final resolution = await resolver.resolveWithAutomaticMerge(
          conflict: conflict,
        );

        // Should use local value for conflict
        expect(resolution.resolvedData['name'], 'Local Name');
        expect(resolution.conflictingFields, ['name']);
        expect(resolution.metadata?['mergeType'], 'partial');
      });

      test('should fail when protected fields conflict', () async {
        final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
        final conflict = ConflictInfo(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          conflictType: ConflictType.versionConflict,
          severity: ConflictSeverity.high,
          localVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-local',
            lastModified: now,
          ),
          remoteVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-remote',
            lastModified: now,
          ),
          localData: const {'budget': 500, 'duration': 5},
          remoteData: const {'budget': 1000, 'location': 'Paris'},
          description: 'Protected field conflict',
          detectedAt: now,
        );

        resolver.updateConfig(
          ConflictResolutionConfig(
            deviceId: deviceId,
            protectedFields: ['budget'],
          ),
        );

        expect(
          () => resolver.resolveWithAutomaticMerge(conflict: conflict),
          throwsA(isA<StateError>()),
        );
      });

      test('should throw when data is missing', () async {
        final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
        final conflict = ConflictInfo(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          conflictType: ConflictType.versionConflict,
          severity: ConflictSeverity.medium,
          localVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-local',
            lastModified: now,
          ),
          remoteVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-remote',
            lastModified: now,
          ),
          localData: const {'name': 'Local Trip'},
          description: 'Missing remote data',
          detectedAt: now,
        );

        expect(
          () => resolver.resolveWithAutomaticMerge(conflict: conflict),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Strategy Recommendation', () {
      test('should recommend last-write-wins for auto-resolvable conflicts',
          () {
        final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
        final conflict = ConflictInfo(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          conflictType: ConflictType.localNewer,
          severity: ConflictSeverity.low,
          localVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 3,
            deviceId: 'device-local',
            lastModified: now,
          ),
          remoteVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-remote',
            lastModified: now.subtract(const Duration(minutes: 5)),
          ),
          description: 'Local is newer',
          detectedAt: now,
        );

        final strategy = resolver.recommendStrategy(conflict: conflict);

        expect(
          strategy,
          ConflictResolutionStrategy.lastWriteWins,
        );
      });

      test('should recommend automatic merge when possible', () {
        final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
        final conflict = ConflictInfo(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          conflictType: ConflictType.versionConflict,
          severity: ConflictSeverity.medium,
          localVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-local',
            lastModified: now,
          ),
          remoteVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-remote',
            lastModified: now,
          ),
          localData: const {'name': 'Local Trip'},
          remoteData: const {'location': 'Paris'},
          description: 'Can merge',
          detectedAt: now,
        );

        final strategy = resolver.recommendStrategy(conflict: conflict);

        expect(
          strategy,
          ConflictResolutionStrategy.automaticMerge,
        );
      });

      test('should recommend manual for complex conflicts', () {
        final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
        final conflict = ConflictInfo(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          conflictType: ConflictType.versionConflict,
          severity: ConflictSeverity.high,
          localVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-local',
            lastModified: now,
          ),
          remoteVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-remote',
            lastModified: now,
          ),
          localData: const {'name': 'Local', 'duration': 5},
          remoteData: const {'name': 'Remote', 'duration': 7},
          description: 'Complex conflict',
          detectedAt: now,
        );

        final strategy = resolver.recommendStrategy(conflict: conflict);

        expect(strategy, ConflictResolutionStrategy.manual);
      });
    });

    group('Merge Attempt', () {
      test('should merge completely non-overlapping data', () {
        final localData = {'name': 'Trip', 'duration': 5};
        final remoteData = {'location': 'Paris', 'budget': 1000};

        final result = resolver.attemptMerge(
          localData: localData,
          remoteData: remoteData,
        );

        expect(result.success, true);
        expect(result.hasConflicts, false);
        expect(result.localFieldsUsed, ['name', 'duration']);
        expect(result.remoteFieldsUsed, ['location', 'budget']);
        expect(result.mergedData, {
          'name': 'Trip',
          'duration': 5,
          'location': 'Paris',
          'budget': 1000,
        });
      });

      test('should merge data with same values', () {
        final localData = {'name': 'Same Name', 'duration': 5};
        final remoteData = {'name': 'Same Name', 'location': 'Paris'};

        final result = resolver.attemptMerge(
          localData: localData,
          remoteData: remoteData,
        );

        expect(result.success, true);
        expect(result.hasConflicts, false);
        expect(result.mergedData!['name'], 'Same Name');
      });

      test('should track conflicting fields', () {
        final localData = {'name': 'Local', 'duration': 5};
        final remoteData = {'name': 'Remote', 'budget': 1000};

        final result = resolver.attemptMerge(
          localData: localData,
          remoteData: remoteData,
        );

        expect(result.success, true);
        expect(result.hasConflicts, true);
        expect(result.conflictingFields, ['name']);
        expect(result.mergedData!['name'], 'Local'); // Uses local as default
      });

      test('should fail on protected field conflicts', () {
        final localData = {'budget': 500, 'duration': 5};
        final remoteData = {'budget': 1000, 'location': 'Paris'};

        final result = resolver.attemptMerge(
          localData: localData,
          remoteData: remoteData,
          protectedFields: ['budget'],
        );

        expect(result.success, false);
        expect(result.errorMessage, contains('budget'));
      });

      test('should fail when all fields conflict', () {
        final localData = {'name': 'Local', 'duration': 5};
        final remoteData = {'name': 'Remote', 'duration': 7};

        final result = resolver.attemptMerge(
          localData: localData,
          remoteData: remoteData,
        );

        expect(result.success, false);
        expect(result.errorMessage, contains('All fields'));
      });
    });

    group('Can Merge Automatically', () {
      test('should return true for non-overlapping data', () {
        final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
        final conflict = ConflictInfo(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          conflictType: ConflictType.versionConflict,
          severity: ConflictSeverity.medium,
          localVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-local',
            lastModified: now,
          ),
          remoteVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-remote',
            lastModified: now,
          ),
          localData: const {'name': 'Local'},
          remoteData: const {'location': 'Paris'},
          description: 'Non-overlapping',
          detectedAt: now,
        );

        expect(resolver.canMergeAutomatically(conflict: conflict), true);
      });

      test('should return false for conflicting protected fields', () {
        final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
        final conflict = ConflictInfo(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          conflictType: ConflictType.versionConflict,
          severity: ConflictSeverity.high,
          localVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-local',
            lastModified: now,
          ),
          remoteVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-remote',
            lastModified: now,
          ),
          localData: const {'budget': 500},
          remoteData: const {'budget': 1000},
          description: 'Protected conflict',
          detectedAt: now,
        );

        resolver.updateConfig(
          ConflictResolutionConfig(
            deviceId: deviceId,
            protectedFields: ['budget'],
          ),
        );

        expect(resolver.canMergeAutomatically(conflict: conflict), false);
      });

      test('should return false when data is missing', () {
        final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
        final conflict = ConflictInfo(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          conflictType: ConflictType.versionConflict,
          severity: ConflictSeverity.medium,
          localVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-local',
            lastModified: now,
          ),
          remoteVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-remote',
            lastModified: now,
          ),
          localData: const {'name': 'Local'},
          description: 'Missing remote data',
          detectedAt: now,
        );

        expect(resolver.canMergeAutomatically(conflict: conflict), false);
      });
    });

    group('Batch Resolution', () {
      test('should resolve multiple conflicts successfully', () async {
        final now = DateTime.utc(2024, 1, 1, 12, 0, 0);

        final conflict1 = ConflictInfo(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          conflictType: ConflictType.localNewer,
          severity: ConflictSeverity.low,
          localVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-local',
            lastModified: now.add(const Duration(minutes: 5)),
          ),
          remoteVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-remote',
            lastModified: now,
          ),
          localData: const {'name': 'Local 1'},
          remoteData: const {'name': 'Remote 1'},
          description: 'Conflict 1',
          detectedAt: now,
        );

        final conflict2 = ConflictInfo(
          conflictId: 'conflict-2',
          entityId: 'entity-2',
          entityType: 'trip',
          conflictType: ConflictType.remoteNewer,
          severity: ConflictSeverity.low,
          localVersion: EntityVersion(
            entityId: 'entity-2',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-local',
            lastModified: now,
          ),
          remoteVersion: EntityVersion(
            entityId: 'entity-2',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-remote',
            lastModified: now.add(const Duration(minutes: 5)),
          ),
          localData: const {'name': 'Local 2'},
          remoteData: const {'name': 'Remote 2'},
          description: 'Conflict 2',
          detectedAt: now,
        );

        final result = await resolver.resolveMultipleConflicts(
          conflicts: [conflict1, conflict2],
        );

        expect(result.totalConflicts, 2);
        expect(result.resolvedCount, 2);
        expect(result.failedCount, 0);
        expect(result.isComplete, true);
        expect(result.resolutions.length, 2);
      });

      test('should handle partial failures', () async {
        final now = DateTime.utc(2024, 1, 1, 12, 0, 0);

        final validConflict = ConflictInfo(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          conflictType: ConflictType.localNewer,
          severity: ConflictSeverity.low,
          localVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-local',
            lastModified: now.add(const Duration(minutes: 5)),
          ),
          remoteVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-remote',
            lastModified: now,
          ),
          localData: const {'name': 'Local'},
          remoteData: const {'name': 'Remote'},
          description: 'Valid',
          detectedAt: now,
        );

        final invalidConflict = ConflictInfo(
          conflictId: 'conflict-2',
          entityId: 'entity-2',
          entityType: 'trip',
          conflictType: ConflictType.versionConflict,
          severity: ConflictSeverity.high,
          localVersion: EntityVersion(
            entityId: 'entity-2',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-local',
            lastModified: now,
          ),
          remoteVersion: EntityVersion(
            entityId: 'entity-2',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-remote',
            lastModified: now,
          ),
          // Missing data - will fail
          description: 'Invalid',
          detectedAt: now,
        );

        final result = await resolver.resolveMultipleConflicts(
          conflicts: [validConflict, invalidConflict],
        );

        expect(result.totalConflicts, 2);
        expect(result.resolvedCount, 1);
        expect(result.failedCount, 1);
        expect(result.isComplete, false);
        expect(result.failedConflicts.length, 1);
        expect(result.errors.containsKey('conflict-2'), true);
      });
    });

    group('Version Creation', () {
      test('should create resolved version with incremented number', () {
        final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
        final conflict = ConflictInfo(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          conflictType: ConflictType.versionConflict,
          severity: ConflictSeverity.medium,
          localVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 3,
            deviceId: 'device-local',
            lastModified: now,
          ),
          remoteVersion: EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            deviceId: 'device-remote',
            lastModified: now,
          ),
          description: 'Version test',
          detectedAt: now,
        );

        final resolvedVersion = resolver.createResolvedVersion(
          conflict: conflict,
          strategy: ConflictResolutionStrategy.manual,
        );

        expect(resolvedVersion.version, 4); // max(3, 2) + 1
        expect(resolvedVersion.deviceId, deviceId);
        expect(resolvedVersion.entityId, 'entity-1');
        expect(resolvedVersion.entityType, 'trip');
      });
    });

    group('Resolution Description Generation', () {
      test('should generate description for last-write-wins (local)', () {
        final resolution = ConflictResolution(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          strategy: ConflictResolutionStrategy.lastWriteWins,
          resolvedData: const {},
          resolvedVersion: EntityVersion.initial(
            entityId: 'entity-1',
            entityType: 'trip',
            deviceId: 'device-1',
          ),
          choseLocal: true,
          resolvedAt: DateTime.now(),
        );

        final description = resolver.generateResolutionDescription(
          resolution: resolution,
        );

        expect(description, contains('local version'));
      });

      test('should generate description for automatic merge', () {
        final resolution = ConflictResolution(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          strategy: ConflictResolutionStrategy.automaticMerge,
          resolvedData: const {'a': 1, 'b': 2, 'c': 3},
          resolvedVersion: EntityVersion.initial(
            entityId: 'entity-1',
            entityType: 'trip',
            deviceId: 'device-1',
          ),
          isMerged: true,
          localFieldsUsed: const ['a', 'b'],
          remoteFieldsUsed: const ['c'],
          resolvedAt: DateTime.now(),
        );

        final description = resolver.generateResolutionDescription(
          resolution: resolution,
        );

        expect(description, contains('Auto-merged'));
      });

      test('should generate description for manual with custom merge', () {
        final resolution = ConflictResolution(
          conflictId: 'conflict-1',
          entityId: 'entity-1',
          entityType: 'trip',
          strategy: ConflictResolutionStrategy.manual,
          resolvedData: const {'custom': 'data'},
          resolvedVersion: EntityVersion.initial(
            entityId: 'entity-1',
            entityType: 'trip',
            deviceId: 'device-1',
          ),
          isMerged: true,
          userProvidedData: const {'custom': 'data'},
          resolvedAt: DateTime.now(),
        );

        final description = resolver.generateResolutionDescription(
          resolution: resolution,
        );

        expect(description, contains('manually'));
      });
    });
  });
}
