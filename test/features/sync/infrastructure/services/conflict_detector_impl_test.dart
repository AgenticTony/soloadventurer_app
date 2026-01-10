import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/domain/models/entity_version.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_info.dart';
import 'package:soloadventurer/features/sync/domain/services/conflict_detector.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/conflict_detector_impl.dart';

void main() {
  group('ConflictDetectorImpl', () {
    late ConflictDetectorImpl detector;
    late String deviceId;
    late DateTime baseTime;

    setUp(() {
      deviceId = 'test-device';
      detector = ConflictDetectorImpl(
        config: ConflictDetectionConfig(
          strategy: ConflictDetectionStrategy.hybrid,
          timestampThresholdMs: 1000,
          useContentHashing: true,
          detectSameVersionConflicts: true,
          deviceId: deviceId,
        ),
      );
      baseTime = DateTime.utc(2024, 1, 1, 12, 0, 0);
    });

    group('Conflict Detection - Version Based', () {
      test('should detect no conflict when local is newer', () async {
        final local = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          lastModified: baseTime.add(const Duration(seconds: 5)),
          deviceId: 'device-A',
          dataHash: 'hash-new',
        );

        final remote = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 1,
          lastModified: baseTime,
          deviceId: 'device-B',
          dataHash: 'hash-old',
        );

        final conflict = await detector.detectConflict(
          localVersion: local,
          remoteVersion: remote,
        );

        expect(conflict, isNotNull);
        expect(conflict!.conflictType, ConflictType.localNewer);
        expect(conflict.severity, ConflictSeverity.low);
        expect(conflict.canAutoResolve, true);
      });

      test('should detect no conflict when remote is newer', () async {
        final local = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 1,
          lastModified: baseTime,
          deviceId: 'device-A',
          dataHash: 'hash-old',
        );

        final remote = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          lastModified: baseTime.add(const Duration(seconds: 5)),
          deviceId: 'device-B',
          dataHash: 'hash-new',
        );

        final conflict = await detector.detectConflict(
          localVersion: local,
          remoteVersion: remote,
        );

        expect(conflict, isNotNull);
        expect(conflict!.conflictType, ConflictType.remoteNewer);
        expect(conflict.severity, ConflictSeverity.low);
        expect(conflict.canAutoResolve, true);
      });

      test('should detect conflict when same version has different content',
          () async {
        final local = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          lastModified: baseTime,
          deviceId: 'device-A',
          dataHash: 'hash-A',
        );

        final remote = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          lastModified: baseTime.add(const Duration(milliseconds: 500)),
          deviceId: 'device-B',
          dataHash: 'hash-B',
        );

        final conflict = await detector.detectConflict(
          localVersion: local,
          remoteVersion: remote,
        );

        expect(conflict, isNotNull);
        expect(conflict!.conflictType, ConflictType.versionConflict);
        expect(conflict.severity, ConflictSeverity.high);
        expect(conflict.canAutoResolve, false);
      });

      test('should detect diverged conflict', () async {
        final local = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          lastModified: baseTime.add(const Duration(seconds: 10)),
          deviceId: 'device-A',
          dataHash: 'hash-A',
        );

        final remote = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 3,
          lastModified: baseTime.add(const Duration(seconds: 5)),
          deviceId: 'device-B',
          dataHash: 'hash-B',
        );

        final conflict = await detector.detectConflict(
          localVersion: local,
          remoteVersion: remote,
        );

        expect(conflict, isNotNull);
        expect(conflict!.conflictType, ConflictType.diverged);
        expect(conflict.severity, ConflictSeverity.high);
        expect(conflict.canAutoResolve, false);
      });
    });

    group('Conflict Detection - Timestamp Based', () {
      test('should detect concurrent timestamps', () async {
        final local = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          lastModified: baseTime,
          deviceId: 'device-A',
          dataHash: 'hash-A',
        );

        final remote = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          lastModified: baseTime.add(const Duration(milliseconds: 500)),
          deviceId: 'device-B',
          dataHash: 'hash-B',
        );

        final areConcurrent = detector.areTimestampsConcurrent(
          timestamp1: local.lastModified,
          timestamp2: remote.lastModified,
        );

        expect(areConcurrent, true);
      });

      test('should not detect concurrent timestamps with large gap', () async {
        final local = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          lastModified: baseTime,
          deviceId: 'device-A',
        );

        final remote = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 3,
          lastModified: baseTime.add(const Duration(seconds: 10)),
          deviceId: 'device-B',
        );

        final areConcurrent = detector.areTimestampsConcurrent(
          timestamp1: local.lastModified,
          timestamp2: remote.lastModified,
        );

        expect(areConcurrent, false);
      });
    });

    group('Conflict Detection - Multiple Entities', () {
      test('should detect conflicts in multiple entities', () async {
        final locals = [
          EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            lastModified: baseTime,
            deviceId: 'device-A',
            dataHash: 'hash-A1',
          ),
          EntityVersion(
            entityId: 'entity-2',
            entityType: 'trip',
            version: 1,
            lastModified: baseTime,
            deviceId: 'device-A',
          ),
          EntityVersion(
            entityId: 'entity-3',
            entityType: 'trip',
            version: 3,
            lastModified: baseTime,
            deviceId: 'device-A',
          ),
        ];

        final remotes = [
          EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            lastModified: baseTime.add(const Duration(milliseconds: 500)),
            deviceId: 'device-B',
            dataHash: 'hash-A2',
          ),
          EntityVersion(
            entityId: 'entity-2',
            entityType: 'trip',
            version: 2,
            lastModified: baseTime.add(const Duration(seconds: 5)),
            deviceId: 'device-B',
          ),
          EntityVersion(
            entityId: 'entity-3',
            entityType: 'trip',
            version: 3,
            lastModified: baseTime,
            deviceId: 'device-B',
          ),
        ];

        final result = await detector.detectMultipleConflicts(
          localVersions: locals,
          remoteVersions: remotes,
        );

        expect(result.hasConflicts, true);
        expect(result.conflictCount, 1);
        expect(result.conflicts.first.entityId, 'entity-1');
      });

      test('should return no conflict result when no conflicts', () async {
        final locals = [
          EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 2,
            lastModified: baseTime.add(const Duration(seconds: 5)),
            deviceId: 'device-A',
          ),
        ];

        final remotes = [
          EntityVersion(
            entityId: 'entity-1',
            entityType: 'trip',
            version: 1,
            lastModified: baseTime,
            deviceId: 'device-B',
          ),
        ];

        final result = await detector.detectMultipleConflicts(
          localVersions: locals,
          remoteVersions: remotes,
        );

        expect(result.hasConflicts, false);
        expect(result.conflictCount, 0);
        expect(result.entitiesChecked, 1);
      });
    });

    group('Conflict Severity', () {
      test('should assign low severity to clear winner', () async {
        final local = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 5,
          lastModified: baseTime.add(const Duration(minutes: 5)),
          deviceId: 'device-A',
        );

        final remote = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 3,
          lastModified: baseTime,
          deviceId: 'device-B',
        );

        final conflict = await detector.detectConflict(
          localVersion: local,
          remoteVersion: remote,
        );

        expect(conflict!.severity, ConflictSeverity.low);
      });

      test('should assign high severity to concurrent edits', () async {
        final local = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          lastModified: baseTime,
          deviceId: 'device-A',
          dataHash: 'hash-A',
        );

        final remote = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          lastModified: baseTime.add(const Duration(milliseconds: 100)),
          deviceId: 'device-B',
          dataHash: 'hash-B',
        );

        final conflict = await detector.detectConflict(
          localVersion: local,
          remoteVersion: remote,
        );

        expect(conflict!.severity, ConflictSeverity.high);
      });
    });

    group('Conflict Descriptions', () {
      test('should generate appropriate description for local newer', () async {
        final local = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 5,
          lastModified: baseTime.add(const Duration(minutes: 5)),
          deviceId: 'device-A',
        );

        final remote = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 3,
          lastModified: baseTime,
          deviceId: 'device-B',
        );

        final conflict = await detector.detectConflict(
          localVersion: local,
          remoteVersion: remote,
        );

        expect(conflict!.description, contains('Local changes'));
        expect(conflict.description, contains('are newer'));
      });

      test('should generate appropriate description for concurrent edits',
          () async {
        final local = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          lastModified: baseTime,
          deviceId: 'device-A',
          dataHash: 'hash-A',
        );

        final remote = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          lastModified: baseTime.add(const Duration(milliseconds: 500)),
          deviceId: 'device-B',
          dataHash: 'hash-B',
        );

        final conflict = await detector.detectConflict(
          localVersion: local,
          remoteVersion: remote,
        );

        expect(conflict!.description, contains('concurrent edits'));
        expect(conflict.description, contains('Manual resolution'));
      });
    });

    group('Version Comparison', () {
      test('should compare by version number', () {
        final v1 = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 1,
          lastModified: baseTime,
          deviceId: deviceId,
        );

        final v2 = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          lastModified: baseTime,
          deviceId: deviceId,
        );

        detector.config = ConflictDetectionConfig(
          strategy: ConflictDetectionStrategy.versionBased,
          deviceId: deviceId,
        );

        final result = detector.compareVersions(
          localVersion: v1,
          remoteVersion: v2,
        );

        expect(result, lessThan(0)); // v1 < v2
      });

      test('should compare by timestamp', () {
        final v1 = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 1,
          lastModified: baseTime,
          deviceId: deviceId,
        );

        final v2 = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 1,
          lastModified: baseTime.add(const Duration(seconds: 5)),
          deviceId: deviceId,
        );

        detector.config = ConflictDetectionConfig(
          strategy: ConflictDetectionStrategy.timestampBased,
          deviceId: deviceId,
        );

        final result = detector.compareVersions(
          localVersion: v1,
          remoteVersion: v2,
        );

        expect(result, lessThan(0)); // v1 < v2
      });
    });

    group('Edge Cases', () {
      test('should not detect conflict for different entities', () async {
        final local = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 1,
          lastModified: baseTime,
          deviceId: deviceId,
        );

        final remote = EntityVersion(
          entityId: 'entity-2',
          entityType: 'trip',
          version: 2,
          lastModified: baseTime,
          deviceId: deviceId,
        );

        final conflict = await detector.detectConflict(
          localVersion: local,
          remoteVersion: remote,
        );

        expect(conflict, isNull);
      });

      test('should not detect conflict when same version and content',
          () async {
        final local = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          lastModified: baseTime,
          deviceId: deviceId,
          dataHash: 'same-hash',
        );

        final remote = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          lastModified: baseTime.add(const Duration(milliseconds: 500)),
          deviceId: 'other-device',
          dataHash: 'same-hash',
        );

        final conflict = await detector.detectConflict(
          localVersion: local,
          remoteVersion: remote,
        );

        expect(conflict, isNull);
      });

      test('should handle missing content hashes gracefully', () async {
        final local = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          lastModified: baseTime,
          deviceId: deviceId,
        );

        final remote = EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          lastModified: baseTime,
          deviceId: deviceId,
        );

        final conflict = await detector.detectConflict(
          localVersion: local,
          remoteVersion: remote,
        );

        expect(conflict, isNull); // No hash, can't detect conflict
      });
    });

    group('ContentHasher', () {
      test('should generate consistent hashes', () {
        final data1 = {'key': 'value', 'number': 42};
        final data2 = {'key': 'value', 'number': 42};

        final hash1 = ContentHasher.hashData(data1);
        final hash2 = ContentHasher.hashData(data2);

        expect(hash1, equals(hash2));
      });

      test('should generate different hashes for different data', () {
        final data1 = {'key': 'value1'};
        final data2 = {'key': 'value2'};

        final hash1 = ContentHasher.hashData(data1);
        final hash2 = ContentHasher.hashData(data2);

        expect(hash1, isNot(equals(hash2)));
      });

      test('should compare data equality correctly', () {
        final data1 = {
          'key': 'value',
          'nested': {'a': 1}
        };
        final data2 = {
          'key': 'value',
          'nested': {'a': 1}
        };
        final data3 = {
          'key': 'value',
          'nested': {'a': 2}
        };

        expect(ContentHasher.areDataEqual(data1, data2), true);
        expect(ContentHasher.areDataEqual(data1, data3), false);
      });

      test('should handle null data gracefully', () {
        expect(ContentHasher.hashData(null), isNull);
        expect(ContentHasher.areDataEqual(null, null), true);
        expect(ContentHasher.areDataEqual({'key': 'value'}, null), false);
      });
    });

    group('ConflictDetectionResult', () {
      test('should categorize conflicts by severity', () async {
        final conflicts = [
          ConflictInfo(
            conflictId: '1',
            entityId: 'e1',
            entityType: 'trip',
            conflictType: ConflictType.localNewer,
            severity: ConflictSeverity.low,
            localVersion: EntityVersion.initial(
              entityId: 'e1',
              entityType: 'trip',
              deviceId: 'd1',
            ),
            remoteVersion: EntityVersion.initial(
              entityId: 'e1',
              entityType: 'trip',
              deviceId: 'd2',
            ),
            description: 'test',
            detectedAt: DateTime.now(),
          ),
          ConflictInfo(
            conflictId: '2',
            entityId: 'e2',
            entityType: 'trip',
            conflictType: ConflictType.versionConflict,
            severity: ConflictSeverity.high,
            localVersion: EntityVersion.initial(
              entityId: 'e2',
              entityType: 'trip',
              deviceId: 'd1',
            ),
            remoteVersion: EntityVersion.initial(
              entityId: 'e2',
              entityType: 'trip',
              deviceId: 'd2',
            ),
            description: 'test',
            detectedAt: DateTime.now(),
          ),
        ];

        final result = ConflictDetectionResult.withConflicts(
          conflicts: conflicts,
          entitiesChecked: 2,
        );

        expect(result.highSeverityConflicts.length, 1);
        expect(result.lowSeverityConflicts.length, 1);
        expect(result.conflictCount, 2);
      });
    });
  });
}
