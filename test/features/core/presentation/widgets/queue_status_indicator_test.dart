import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/core/presentation/widgets/queue_status_indicator.dart';
import 'package:soloadventurer/features/core/providers/operation_queue_provider.dart';
import 'package:soloadventurer/features/core/services/operation_queue.dart';
import 'package:soloadventurer/features/travel/domain/models/trip_planning_operation.dart';

class MockOperationQueueNotifier extends OperationQueueNotifier
    with Mock {
  MockOperationQueueNotifier() : super();

  @override
  OperationQueueState build() {
    return const OperationQueueState(
      pendingOperations: [],
      failedOperations: [],
      isProcessing: false,
      pendingCount: 0,
      failedCount: 0,
    );
  }
}

void main() {
  group('QueueStatusIndicator', () {
    late MockOperationQueueNotifier mockNotifier;

    setUp(() {
      mockNotifier = MockOperationQueueNotifier();
    });

    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          operationQueueNotifierProvider
              .overrideWith((ref) => mockNotifier),
        ],
        child: const MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                QueueStatusIndicator(),
              ],
            ),
          ),
        ),
      );
    }

    group('Visibility', () {
      testWidgets('hides indicator when pendingCount is 0',
          (WidgetTester tester) async {
        when(() => mockNotifier.state).thenReturn(
          const OperationQueueState(
            pendingOperations: [],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 0,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byType(IconButton), findsNothing);
        expect(find.byType(SizedBox), findsOneWidget);
      });

      testWidgets('shows indicator when pendingCount is greater than 0',
          (WidgetTester tester) async {
        final operation = TripPlanningOperation(
          id: 'test-id',
          tripId: 'trip-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
        );

        when(() => mockNotifier.state).thenReturn(
          OperationQueueState(
            pendingOperations: [operation],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 1,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byType(IconButton), findsOneWidget);
        expect(find.byIcon(Icons.cloud_sync), findsOneWidget);
      });

      testWidgets('shows indicator when pendingCount is 1',
          (WidgetTester tester) async {
        final operation = TripPlanningOperation(
          id: 'test-id',
          tripId: 'trip-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
        );

        when(() => mockNotifier.state).thenReturn(
          OperationQueueState(
            pendingOperations: [operation],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 1,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byType(IconButton), findsOneWidget);
      });

      testWidgets('shows indicator when pendingCount is 99',
          (WidgetTester tester) async {
        final operations = List.generate(
          99,
          (i) => TripPlanningOperation(
            id: 'test-$i',
            tripId: 'trip-$i',
            planningType: TripPlanningType.update,
            changes: {'name': 'Test $i'},
          ),
        );

        when(() => mockNotifier.state).thenReturn(
          OperationQueueState(
            pendingOperations: operations,
            failedOperations: [],
            isProcessing: false,
            pendingCount: 99,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byType(IconButton), findsOneWidget);
      });

      testWidgets('shows indicator when pendingCount is 100 or more',
          (WidgetTester tester) async {
        final operations = List.generate(
          100,
          (i) => TripPlanningOperation(
            id: 'test-$i',
            tripId: 'trip-$i',
            planningType: TripPlanningType.update,
            changes: {'name': 'Test $i'},
          ),
        );

        when(() => mockNotifier.state).thenReturn(
          OperationQueueState(
            pendingOperations: operations,
            failedOperations: [],
            isProcessing: false,
            pendingCount: 100,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byType(IconButton), findsOneWidget);
      });
    });

    group('Badge Display', () {
      testWidgets('displays correct count for 1 pending operation',
          (WidgetTester tester) async {
        final operation = TripPlanningOperation(
          id: 'test-id',
          tripId: 'trip-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
        );

        when(() => mockNotifier.state).thenReturn(
          OperationQueueState(
            pendingOperations: [operation],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 1,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('1'), findsOneWidget);
      });

      testWidgets('displays correct count for 10 pending operations',
          (WidgetTester tester) async {
        final operations = List.generate(
          10,
          (i) => TripPlanningOperation(
            id: 'test-$i',
            tripId: 'trip-$i',
            planningType: TripPlanningType.update,
            changes: {'name': 'Test $i'},
          ),
        );

        when(() => mockNotifier.state).thenReturn(
          OperationQueueState(
            pendingOperations: operations,
            failedOperations: [],
            isProcessing: false,
            pendingCount: 10,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('10'), findsOneWidget);
      });

      testWidgets('displays "99+" for counts over 99',
          (WidgetTester tester) async {
        final operations = List.generate(
          150,
          (i) => TripPlanningOperation(
            id: 'test-$i',
            tripId: 'trip-$i',
            planningType: TripPlanningType.update,
            changes: {'name': 'Test $i'},
          ),
        );

        when(() => mockNotifier.state).thenReturn(
          OperationQueueState(
            pendingOperations: operations,
            failedOperations: [],
            isProcessing: false,
            pendingCount: 150,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('99+'), findsOneWidget);
      });

      testWidgets('uses smaller font size for 99+ badge',
          (WidgetTester tester) async {
        final operations = List.generate(
          100,
          (i) => TripPlanningOperation(
            id: 'test-$i',
            tripId: 'trip-$i',
            planningType: TripPlanningType.update,
            changes: {'name': 'Test $i'},
          ),
        );

        when(() => mockNotifier.state).thenReturn(
          OperationQueueState(
            pendingOperations: operations,
            failedOperations: [],
            isProcessing: false,
            pendingCount: 100,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        final textWidget = tester.widget<Text>(find.text('99+'));
        expect(textWidget.style?.fontSize, 10);
      });

      testWidgets('uses normal font size for counts under 99',
          (WidgetTester tester) async {
        final operation = TripPlanningOperation(
          id: 'test-id',
          tripId: 'trip-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
        );

        when(() => mockNotifier.state).thenReturn(
          OperationQueueState(
            pendingOperations: [operation],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 1,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        final textWidget = tester.widget<Text>(find.text('1'));
        expect(textWidget.style?.fontSize, 12);
      });
    });

    group('Icon Display', () {
      testWidgets('displays cloud_sync icon', (WidgetTester tester) async {
        final operation = TripPlanningOperation(
          id: 'test-id',
          tripId: 'trip-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
        );

        when(() => mockNotifier.state).thenReturn(
          OperationQueueState(
            pendingOperations: [operation],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 1,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byIcon(Icons.cloud_sync), findsOneWidget);
      });
    });

    group('Tooltip', () {
      testWidgets('displays tooltip with count information',
          (WidgetTester tester) async {
        final operation = TripPlanningOperation(
          id: 'test-id',
          tripId: 'trip-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
        );

        when(() => mockNotifier.state).thenReturn(
          OperationQueueState(
            pendingOperations: [operation],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 5,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        final iconButton = tester.widget<IconButton>(find.byType(IconButton));
        expect(iconButton.tooltip, 'View operation queue (5 pending)');
      });

      testWidgets('updates tooltip when count changes',
          (WidgetTester tester) async {
        final operation = TripPlanningOperation(
          id: 'test-id',
          tripId: 'trip-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
        );

        when(() => mockNotifier.state).thenReturn(
          OperationQueueState(
            pendingOperations: [operation],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 1,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byType(IconButton), findsOneWidget);

        // Update state
        when(() => mockNotifier.state).thenReturn(
          OperationQueueState(
            pendingOperations: [operation],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 10,
            failedCount: 0,
          ),
        );

        await tester.pump();

        final iconButton = tester.widget<IconButton>(find.byType(IconButton));
        expect(iconButton.tooltip, 'View operation queue (10 pending)');
      });
    });

    group('Navigation', () {
      testWidgets('navigates to operation queue screen when tapped',
          (WidgetTester tester) async {
        final operation = TripPlanningOperation(
          id: 'test-id',
          tripId: 'trip-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
        );

        when(() => mockNotifier.state).thenReturn(
          OperationQueueState(
            pendingOperations: [operation],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 1,
            failedCount: 0,
          ),
        );

        final navigatorObserver = MockNavigatorObserver();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              operationQueueNotifierProvider
                  .overrideWith((ref) => mockNotifier),
            ],
            child: MaterialApp(
              home: const Scaffold(
                appBar: AppBar(
                  actions: [
                    QueueStatusIndicator(),
                  ],
                ),
              ),
              navigatorObservers: [navigatorObserver],
            ),
          ),
        );

        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        verify(() => navigatorObserver.didPush(any(), any())).called(1);
      });
    });

    group('State Reactivity', () {
      testWidgets('updates when pendingCount changes from 0 to 1',
          (WidgetTester tester) async {
        when(() => mockNotifier.state).thenReturn(
          const OperationQueueState(
            pendingOperations: [],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 0,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byType(IconButton), findsNothing);

        final operation = TripPlanningOperation(
          id: 'test-id',
          tripId: 'trip-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
        );

        when(() => mockNotifier.state).thenReturn(
          OperationQueueState(
            pendingOperations: [operation],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 1,
            failedCount: 0,
          ),
        );

        await tester.pump();

        expect(find.byType(IconButton), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
      });

      testWidgets('hides when pendingCount changes from 1 to 0',
          (WidgetTester tester) async {
        final operation = TripPlanningOperation(
          id: 'test-id',
          tripId: 'trip-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
        );

        when(() => mockNotifier.state).thenReturn(
          OperationQueueState(
            pendingOperations: [operation],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 1,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byType(IconButton), findsOneWidget);

        when(() => mockNotifier.state).thenReturn(
          const OperationQueueState(
            pendingOperations: [],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 0,
            failedCount: 0,
          ),
        );

        await tester.pump();

        expect(find.byType(IconButton), findsNothing);
      });

      testWidgets('updates badge when count changes',
          (WidgetTester tester) async {
        final operation1 = TripPlanningOperation(
          id: 'test-id-1',
          tripId: 'trip-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
        );

        when(() => mockNotifier.state).thenReturn(
          OperationQueueState(
            pendingOperations: [operation1],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 1,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('1'), findsOneWidget);

        final operation2 = TripPlanningOperation(
          id: 'test-id-2',
          tripId: 'trip-456',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test 2'},
        );

        when(() => mockNotifier.state).thenReturn(
          OperationQueueState(
            pendingOperations: [operation1, operation2],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 2,
            failedCount: 0,
          ),
        );

        await tester.pump();

        expect(find.text('1'), findsNothing);
        expect(find.text('2'), findsOneWidget);
      });
    });
  });
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}
