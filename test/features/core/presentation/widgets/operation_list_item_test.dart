import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/core/presentation/widgets/operation_list_item.dart';
import 'package:soloadventurer/features/travel/domain/models/trip_planning_operation.dart';
import 'package:soloadventurer/features/travel/domain/models/travel_note_operation.dart';
import 'package:soloadventurer/features/travel/domain/models/location_update_operation.dart';

void main() {
  group('OperationListItem', () {
    late TripPlanningOperation testOperation;

    setUp(() {
      testOperation = TripPlanningOperation(
        id: 'test-operation-id-123',
        tripId: 'trip-id-456',
        planningType: TripPlanningType.update,
        changes: {'name': 'Updated Trip Name'},
        priority: 10,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        attemptCount: 0,
        maxRetries: 3,
      );
    });

    Widget createWidgetUnderTest({
      required QueueableOperation operation,
      bool isFailed = false,
      VoidCallback? onRetry,
      VoidCallback? onRemove,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: OperationListItem(
            operation: operation,
            isFailed: isFailed,
            onRetry: onRetry,
            onRemove: onRemove,
          ),
        ),
      );
    }

    group('Pending Operations', () {
      testWidgets('displays operation type icon correctly for trip planning',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(operation: testOperation));

        expect(find.byIcon(Icons.flight_takeoff), findsOneWidget);
      });

      testWidgets('displays operation type icon correctly for travel note',
          (WidgetTester tester) async {
        final noteOperation = TravelNoteOperation(
          id: 'note-id-123',
          tripId: 'trip-id-456',
          noteId: 'note-id-789',
          content: 'Test note content',
          createdAt: DateTime.now(),
        );

        await tester
            .pumpWidget(createWidgetUnderTest(operation: noteOperation));

        expect(find.byIcon(Icons.note), findsOneWidget);
      });

      testWidgets('displays operation type icon correctly for location update',
          (WidgetTester tester) async {
        final locationOperation = LocationUpdateOperation(
          id: 'location-id-123',
          tripId: 'trip-id-456',
          latitude: 40.7128,
          longitude: -74.0060,
          timestamp: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await tester
            .pumpWidget(createWidgetUnderTest(operation: locationOperation));

        expect(find.byIcon(Icons.location_on), findsOneWidget);
      });

      testWidgets('displays operation title', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(operation: testOperation));

        expect(find.text('Trip Planning'), findsOneWidget);
      });

      testWidgets('displays operation type', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(operation: testOperation));

        expect(find.text('trip_planning'), findsOneWidget);
      });

      testWidgets('displays Pending status chip for new operations',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(operation: testOperation));

        expect(find.text('Pending'), findsOneWidget);
      });

      testWidgets('displays Retrying status chip for operations with attempts',
          (WidgetTester tester) async {
        final retriedOperation = testOperation.copyWith(
          attemptCount: 2,
          lastAttempt: DateTime.now().subtract(const Duration(minutes: 1)),
        );

        await tester
            .pumpWidget(createWidgetUnderTest(operation: retriedOperation));

        expect(find.text('Retrying'), findsOneWidget);
      });

      testWidgets('displays operation details', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(operation: testOperation));

        expect(find.textContaining('ID:'), findsOneWidget);
        expect(find.textContaining('Priority:'), findsOneWidget);
        expect(find.textContaining('Created:'), findsOneWidget);
        expect(find.textContaining('Requires Network:'), findsOneWidget);
      });

      testWidgets('displays correct priority label for Normal priority',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(operation: testOperation));

        expect(find.textContaining('Normal'), findsOneWidget);
      });

      testWidgets('displays correct priority label for High priority',
          (WidgetTester tester) async {
        final highPriorityOp = testOperation.copyWith(priority: 100);

        await tester
            .pumpWidget(createWidgetUnderTest(operation: highPriorityOp));

        expect(find.textContaining('High'), findsOneWidget);
      });

      testWidgets('displays correct priority label for Critical priority',
          (WidgetTester tester) async {
        final criticalOp = testOperation.copyWith(priority: 1000);

        await tester.pumpWidget(createWidgetUnderTest(operation: criticalOp));

        expect(find.textContaining('Critical'), findsOneWidget);
      });

      testWidgets('displays correct priority label for Low priority',
          (WidgetTester tester) async {
        final lowPriorityOp = testOperation.copyWith(priority: 1);

        await tester.pumpWidget(createWidgetUnderTest(operation: lowPriorityOp));

        expect(find.textContaining('Low'), findsOneWidget);
      });

      testWidgets('does not display retry metadata for new operations',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(operation: testOperation));

        expect(find.textContaining('Attempt'), findsNothing);
        expect(find.byIcon(Icons.history), findsNothing);
      });

      testWidgets('displays retry metadata for operations with attempts',
          (WidgetTester tester) async {
        final retriedOperation = testOperation.copyWith(
          attemptCount: 2,
          lastAttempt: DateTime.now().subtract(const Duration(minutes: 1)),
        );

        await tester
            .pumpWidget(createWidgetUnderTest(operation: retriedOperation));

        expect(find.textContaining('Attempt 2 of 3'), findsOneWidget);
        expect(find.byIcon(Icons.history), findsOneWidget);
        expect(find.byIcon(Icons.access_time), findsOneWidget);
      });

      testWidgets('does not display action buttons for pending operations',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(operation: testOperation));

        expect(find.text('Retry'), findsNothing);
        expect(find.text('Remove'), findsNothing);
      });
    });

    group('Failed Operations', () {
      testWidgets('displays Failed status chip', (WidgetTester tester) async {
        final failedOperation = testOperation.copyWith(
          attemptCount: 3,
          lastError: 'Network request failed',
          lastAttempt: DateTime.now().subtract(const Duration(minutes: 1)),
        );

        await tester.pumpWidget(createWidgetUnderTest(
          operation: failedOperation,
          isFailed: true,
        ));

        expect(find.text('Failed'), findsOneWidget);
      });

      testWidgets('displays error message', (WidgetTester tester) async {
        final failedOperation = testOperation.copyWith(
          attemptCount: 3,
          lastError: 'Network request failed',
          lastAttempt: DateTime.now().subtract(const Duration(minutes: 1)),
        );

        await tester.pumpWidget(createWidgetUnderTest(
          operation: failedOperation,
          isFailed: true,
        ));

        expect(find.text('Network request failed'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('displays Retry button when isFailed and onRetry provided',
          (WidgetTester tester) async {
        final failedOperation = testOperation.copyWith(
          attemptCount: 3,
          lastError: 'Network request failed',
        );

        await tester.pumpWidget(createWidgetUnderTest(
          operation: failedOperation,
          isFailed: true,
          onRetry: () {},
        ));

        expect(find.text('Retry'), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });

      testWidgets('calls onRetry when Retry button is tapped',
          (WidgetTester tester) async {
        var retryCalled = false;
        final failedOperation = testOperation.copyWith(
          attemptCount: 3,
          lastError: 'Network request failed',
        );

        await tester.pumpWidget(createWidgetUnderTest(
          operation: failedOperation,
          isFailed: true,
          onRetry: () => retryCalled = true,
        ));

        await tester.tap(find.text('Retry'));
        expect(retryCalled, isTrue);
      });

      testWidgets('displays Remove button when onRemove provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          operation: testOperation,
          isFailed: false,
          onRemove: () {},
        ));

        expect(find.text('Remove'), findsOneWidget);
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      });

      testWidgets('calls onRemove when Remove button is tapped',
          (WidgetTester tester) async {
        var removeCalled = false;

        await tester.pumpWidget(createWidgetUnderTest(
          operation: testOperation,
          isFailed: false,
          onRemove: () => removeCalled = true,
        ));

        await tester.tap(find.text('Remove'));
        expect(removeCalled, isTrue);
      });

      testWidgets('displays both Retry and Remove buttons for failed operations with both callbacks',
          (WidgetTester tester) async {
        final failedOperation = testOperation.copyWith(
          attemptCount: 3,
          lastError: 'Network request failed',
        );

        await tester.pumpWidget(createWidgetUnderTest(
          operation: failedOperation,
          isFailed: true,
          onRetry: () {},
          onRemove: () {},
        ));

        expect(find.text('Retry'), findsOneWidget);
        expect(find.text('Remove'), findsOneWidget);
      });
    });

    group('Trip Planning Specific Details', () {
      testWidgets('displays trip-specific fields for trip planning operations',
          (WidgetTester tester) async {
        final tripOperation = TripPlanningOperation(
          id: 'test-id',
          tripId: 'trip-123',
          planningType: TripPlanningType.addDestination,
          changes: {'destinations': ['Paris', 'London']},
        );

        await tester
            .pumpWidget(createWidgetUnderTest(operation: tripOperation));

        expect(find.textContaining('Type:'), findsOneWidget);
        expect(find.textContaining('Trip ID:'), findsOneWidget);
      });
    });

    group('Relative Time Formatting', () {
      testWidgets('displays "Just now" for recent operations',
          (WidgetTester tester) async {
        final recentOperation = testOperation.copyWith(
          lastAttempt: DateTime.now().subtract(const Duration(seconds: 30)),
          attemptCount: 1,
        );

        await tester
            .pumpWidget(createWidgetUnderTest(operation: recentOperation));

        expect(find.textContaining('Just now'), findsOneWidget);
      });

      testWidgets('displays minutes ago for operations minutes old',
          (WidgetTester tester) async {
        final minutesOldOperation = testOperation.copyWith(
          lastAttempt: DateTime.now().subtract(const Duration(minutes: 5)),
          attemptCount: 1,
        );

        await tester
            .pumpWidget(createWidgetUnderTest(operation: minutesOldOperation));

        expect(find.textContaining('5m ago'), findsOneWidget);
      });

      testWidgets('displays hours ago for operations hours old',
          (WidgetTester tester) async {
        final hoursOldOperation = testOperation.copyWith(
          lastAttempt: DateTime.now().subtract(const Duration(hours: 2)),
          attemptCount: 1,
        );

        await tester
            .pumpWidget(createWidgetUnderTest(operation: hoursOldOperation));

        expect(find.textContaining('2h ago'), findsOneWidget);
      });

      testWidgets('displays days ago for operations days old',
          (WidgetTester tester) async {
        final daysOldOperation = testOperation.copyWith(
          lastAttempt: DateTime.now().subtract(const Duration(days: 3)),
          attemptCount: 1,
        );

        await tester
            .pumpWidget(createWidgetUnderTest(operation: daysOldOperation));

        expect(find.textContaining('3d ago'), findsOneWidget);
      });
    });

    group('Visual Styling', () {
      testWidgets('displays card with correct margins',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(operation: testOperation));

        final card = tester.widget<Card>(find.byType(Card));
        expect(card.margin, const EdgeInsets.symmetric(horizontal: 16, vertical: 8));
      });

      testWidgets('displays operation type icon with background color',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(operation: testOperation));

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(Card),
            matching: find.byType(Container).first,
          ),
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, isNotNull);
        expect(decoration.borderRadius, isNotNull);
      });
    });
  });
}
