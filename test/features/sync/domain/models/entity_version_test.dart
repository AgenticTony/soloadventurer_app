import 'package:flutter_test/flutter_test.dart';
import 'package:solo_adventurer_app/features/sync/domain/models/entity_version.dart';

void main() {
  group('EntityVersion', () {
    late DateTime baseTime;
    late String deviceId;

    setUp(() {
      baseTime = DateTime.utc(2024, 1, 1, 12, 0, 0);
      deviceId = 'device-123';
    });

    test('should create initial version correctly', () {
      final version = EntityVersion.initial(
        entityId: 'entity-1',
        entityType: 'trip',
        deviceId: deviceId,
      );

      expect(version.entityId, 'entity-1');
      expect(version.entityType, 'trip');
      expect(version.version, 1);
      expect(version.deviceId, deviceId);
      expect(version.dataHash, isNull);
    });

    test('should increment version correctly', () {
      final v1 = EntityVersion(
        entityId: 'entity-1',
        entityType: 'trip',
        version: 1,
        lastModified: baseTime,
        deviceId: deviceId,
      );

      final v2 = v1.nextVersion(deviceId: 'device-456', dataHash: 'hash123');

      expect(v2.version, 2);
      expect(v2.deviceId, 'device-456');
      expect(v2.dataHash, 'hash123');
      expect(v2.entityId, v1.entityId);
      expect(v2.entityType, v1.entityType);
    });

    test('should compare versions correctly', () {
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
        lastModified: baseTime.add(Duration(seconds: 1)),
        deviceId: deviceId,
      );

      expect(v1.isNewerThan(v2), false);
      expect(v1.isOlderThan(v2), true);
      expect(v2.isNewerThan(v1), true);
      expect(v2.isOlderThan(v1), false);
      expect(v1.isSameVersion(v2), false);
    });

    test('should not compare different entities', () {
      final v1 = EntityVersion(
        entityId: 'entity-1',
        entityType: 'trip',
        version: 2,
        lastModified: baseTime,
        deviceId: deviceId,
      );

      final v2 = EntityVersion(
        entityId: 'entity-2',
        entityType: 'trip',
        version: 1,
        lastModified: baseTime,
        deviceId: deviceId,
      );

      expect(v1.isNewerThan(v2), false);
      expect(v1.isOlderThan(v2), false);
    });

    test('should compare timestamps correctly', () {
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
        lastModified: baseTime.add(Duration(seconds: 5)),
        deviceId: deviceId,
      );

      expect(v2.isModifiedAfter(v1), true);
      expect(v1.isModifiedAfter(v2), false);
    });

    test('should compare content hashes correctly', () {
      final v1 = EntityVersion(
        entityId: 'entity-1',
        entityType: 'trip',
        version: 1,
        lastModified: baseTime,
        deviceId: deviceId,
        dataHash: 'hash1',
      );

      final v2 = EntityVersion(
        entityId: 'entity-1',
        entityType: 'trip',
        version: 1,
        lastModified: baseTime,
        deviceId: deviceId,
        dataHash: 'hash2',
      );

      expect(v1.hasDifferentContent(v2), true);

      final v3 = EntityVersion(
        entityId: 'entity-1',
        entityType: 'trip',
        version: 1,
        lastModified: baseTime,
        deviceId: deviceId,
        dataHash: 'hash1',
      );

      expect(v1.hasDifferentContent(v3), false);
    });

    test('should serialize and deserialize correctly', () {
      final version = EntityVersion(
        entityId: 'entity-1',
        entityType: 'trip',
        version: 5,
        lastModified: baseTime,
        deviceId: deviceId,
        dataHash: 'test-hash',
      );

      final json = version.toJson();
      final restored = EntityVersion.fromJson(json);

      expect(restored.entityId, version.entityId);
      expect(restored.entityType, version.entityType);
      expect(restored.version, version.version);
      expect(restored.lastModified, version.lastModified);
      expect(restored.deviceId, version.deviceId);
      expect(restored.dataHash, version.dataHash);
    });

    test('copyWith should create correct copy', () {
      final v1 = EntityVersion(
        entityId: 'entity-1',
        entityType: 'trip',
        version: 1,
        lastModified: baseTime,
        deviceId: deviceId,
      );

      final v2 = v1.copyWith(version: 2);

      expect(v2.entityId, v1.entityId);
      expect(v2.version, 2);
      expect(v2.deviceId, v1.deviceId);
    });
  });
}
