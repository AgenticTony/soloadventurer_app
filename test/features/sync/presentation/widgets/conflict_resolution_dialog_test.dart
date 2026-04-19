import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_info.dart';
import 'package:soloadventurer/features/sync/domain/models/entity_version.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_info.dart'
    show ConflictType, ConflictSeverity;
import 'package:soloadventurer/features/sync/domain/models/conflict_resolution.dart';
import 'package:soloadventurer/features/sync/presentation/widgets/conflict_resolution_dialog.dart';

void main() {
  group('ConflictResolutionDialog', () {
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
          dataHash: 'abc123',
        ),
        remoteVersion: EntityVersion(
          entityId: 'entity_123',
          entityType: 'travelPlan',
          version: 6,
          lastModified: now.subtract(const Duration(minutes: 15)),
          deviceId: 'device_002',
          dataHash: 'xyz789',
        ),
        localData: const {
          'destination': 'Paris',
          'startDate': '2025-06-15',
        },
        remoteData: const {
          'destination': 'Paris',
          'startDate': '2025-06-20',
        },
        description: 'Test conflict',
        detectedAt: now,
      );
    });

    testWidgets('should display conflict information', (tester) async {
      bool keepLocalCalled = false;
      bool keepRemoteCalled = false;
      bool mergeCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConflictResolutionDialog(
              conflict: testConflict,
              onKeepLocal: () => keepLocalCalled = true,
              onKeepRemote: () => keepRemoteCalled = true,
              onMerge: () => mergeCalled = true,
              canMerge: true,
            ),
          ),
        ),
      );

      // Verify title
      expect(find.text('Sync Conflict Detected'), findsOneWidget);

      // Verify entity type is displayed
      expect(find.text('Travel Plan'), findsOneWidget);

      // Verify action buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Keep Local'), findsOneWidget);
      expect(find.text('Keep Remote'), findsOneWidget);
      expect(find.text('Merge'), findsOneWidget);
    });

    testWidgets('should call onKeepLocal when Keep Local is pressed',
        (tester) async {
      bool keepLocalCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConflictResolutionDialog(
              conflict: testConflict,
              onKeepLocal: () => keepLocalCalled = true,
              onKeepRemote: () {},
              onMerge: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Keep Local'));
      await tester.pump();

      expect(keepLocalCalled, true);
    });

    testWidgets('should call onKeepRemote when Keep Remote is pressed',
        (tester) async {
      bool keepRemoteCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConflictResolutionDialog(
              conflict: testConflict,
              onKeepLocal: () {},
              onKeepRemote: () => keepRemoteCalled = true,
              onMerge: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Keep Remote'));
      await tester.pump();

      expect(keepRemoteCalled, true);
    });

    testWidgets('should not show merge button when canMerge is false',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConflictResolutionDialog(
              conflict: testConflict,
              onKeepLocal: () {},
              onKeepRemote: () {},
              onMerge: () {},
              canMerge: false,
            ),
          ),
        ),
      );

      expect(find.text('Merge'), findsNothing);
    });

    testWidgets('should show correct severity indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConflictResolutionDialog(
              conflict: testConflict,
              onKeepLocal: () {},
              onKeepRemote: () {},
              onMerge: () {},
            ),
          ),
        ),
      );

      expect(find.text('Severity: Medium'), findsOneWidget);
    });

    testWidgets('should display version comparison view', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConflictResolutionDialog(
              conflict: testConflict,
              onKeepLocal: () {},
              onKeepRemote: () {},
              onMerge: () {},
            ),
          ),
        ),
      );

      expect(find.text('Version Comparison'), findsOneWidget);
      expect(find.text('Local Version'), findsOneWidget);
      expect(find.text('Remote Version'), findsOneWidget);
    });
  });

  group('ConflictResolutionDialog.show', () {
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
        ),
        remoteVersion: EntityVersion(
          entityId: 'entity_123',
          entityType: 'travelPlan',
          version: 6,
          lastModified: now.subtract(const Duration(minutes: 15)),
          deviceId: 'device_002',
        ),
        description: 'Test conflict',
        detectedAt: now,
      );
    });

    testWidgets('should return keepLocal when Keep Local is pressed',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                final result = await ConflictResolutionDialog.show(
                  context: context,
                  conflict: testConflict,
                );

                expect(result, ManualResolutionChoice.keepLocal);
              },
              child: const Text('Show Dialog'),
            );
          },
        ),
      ));

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Keep Local'));
      await tester.pumpAndSettle();
    });

    testWidgets('should return null when dialog is dismissed', (tester) async {
      ManualResolutionChoice? result;

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await ConflictResolutionDialog.show(
                  context: context,
                  conflict: testConflict,
                );
              },
              child: const Text('Show Dialog'),
            );
          },
        ),
      ));

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, null);
    });
  });
}
