import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_info.dart';
import 'package:soloadventurer/features/sync/domain/models/entity_version.dart';
import 'package:soloadventurer/features/sync/presentation/widgets/conflict_comparison_view.dart';

void main() {
  group('ConflictComparisonView', () {
    late ConflictInfo testConflict;

    setUp(() {
      final now = DateTime.now();
      testConflict = ConflictInfo(
        conflictId: 'test_conflict_1',
        entityId: 'entity_123',
        entityType: 'travelPlan',
        conflictType: ConflictType.diverged,
        severity: ConflictSeverity.medium,
        localVersion: EntityVersion(
          entityId: 'entity_123',
          entityType: 'travelPlan',
          version: 5,
          lastModified: now.subtract(const Duration(minutes: 30)),
          deviceId: 'device_001',
          dataHash: 'abc123def456',
        ),
        remoteVersion: EntityVersion(
          entityId: 'entity_123',
          entityType: 'travelPlan',
          version: 6,
          lastModified: now.subtract(const Duration(minutes: 15)),
          deviceId: 'device_002',
          dataHash: 'xyz789uvw012',
        ),
        localData: const {
          'destination': 'Paris',
          'startDate': '2025-06-15',
          'endDate': '2025-06-22',
          'budget': 5000,
        },
        remoteData: const {
          'destination': 'Paris',
          'startDate': '2025-06-15',
          'endDate': '2025-06-25',
          'budget': 6000,
        },
        description: 'Test conflict',
        detectedAt: now,
      );
    });

    testWidgets('should display version comparison title', (tester) async {
      final conflict = ConflictInfo(
        conflictId: 'test-conflict',
        entityId: 'entity-1',
        entityType: 'trip',
        conflictType: ConflictType.versionConflict,
        severity: ConflictSeverity.medium,
        localVersion: EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 1,
          deviceId: 'device-a',
          lastModified: DateTime.now(),
        ),
        remoteVersion: EntityVersion(
          entityId: 'entity-1',
          entityType: 'trip',
          version: 2,
          deviceId: 'device-b',
          lastModified: DateTime.now(),
        ),
        description: 'Test conflict',
        detectedAt: DateTime.now(),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConflictComparisonView(
              conflict: conflict,
            ),
          ),
        ),
      );
    });

    testWidgets('should display local and remote version cards',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConflictComparisonView(conflict: testConflict),
          ),
        ),
      );

      expect(find.text('Version Comparison'), findsOneWidget);
      expect(find.text('Local Version'), findsOneWidget);
      expect(find.text('Remote Version'), findsOneWidget);
    });

    testWidgets('should display version metadata', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConflictComparisonView(conflict: testConflict),
          ),
        ),
      );

      // Check version numbers are displayed
      expect(find.textContaining('5'), findsWidgets);
      expect(find.textContaining('6'), findsWidgets);
    });

    testWidgets('should display data fields', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConflictComparisonView(conflict: testConflict),
          ),
        ),
      );

      expect(find.text('destination'), findsWidgets);
      expect(find.text('Paris'), findsWidgets);
      expect(find.text('startDate'), findsWidgets);
    });

    testWidgets('should show no data message when data is null',
        (tester) async {
      final noDataConflict = ConflictInfo(
        conflictId: 'test_conflict_2',
        entityId: 'entity_456',
        entityType: 'note',
        conflictType: ConflictType.timestampConflict,
        severity: ConflictSeverity.low,
        localVersion: testConflict.localVersion,
        remoteVersion: testConflict.remoteVersion,
        description: 'Test with no data',
        detectedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConflictComparisonView(conflict: noDataConflict),
          ),
        ),
      );

      expect(find.text('No data available'), findsWidgets);
    });

    testWidgets('should display device IDs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConflictComparisonView(conflict: testConflict),
          ),
        ),
      );

      expect(find.textContaining('device_001'), findsOneWidget);
      expect(find.textContaining('device_002'), findsOneWidget);
    });

    testWidgets('should display data hashes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConflictComparisonView(conflict: testConflict),
          ),
        ),
      );

      // Hashes should be truncated (12 chars max with ...)
      expect(
        find.textContaining('abc123'),
        findsOneWidget,
      );
      expect(
        find.textContaining('xyz789'),
        findsOneWidget,
      );
    });
  });
}
