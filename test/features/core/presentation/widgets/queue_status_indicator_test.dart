import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/core/presentation/widgets/queue_status_indicator.dart';
import 'package:soloadventurer/features/core/providers/operation_queue_provider.dart';
import 'package:soloadventurer/features/travel/domain/models/trip_planning_operation.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  setUpAll(() {
    registerFallbackValue(MaterialPageRoute(builder: (_) => const SizedBox()));
  });
  group('QueueStatusIndicator', () {
    Widget createWidgetUnderTest(OperationQueueState state) {
      return ProviderScope(
        overrides: [
          operationQueueProvider.overrideWithValue(state),
        ],
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: const [
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
        await tester.pumpWidget(createWidgetUnderTest(
          const OperationQueueState(
            pendingOperations: [],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 0,
            failedCount: 0,
          ),
        ));

        expect(find.byType(IconButton), findsNothing);
        expect(find.byType(SizedBox), findsOneWidget);
      });

      testWidgets('shows indicator when pendingCount is greater than 0',
          (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id',
          tripId: 'trip-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          priority: 10,
        );

        await tester.pumpWidget(createWidgetUnderTest(
          const OperationQueueState(
            pendingOperations: [operation],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 1,
            failedCount: 0,
          ),
        ));

        expect(find.byType(IconButton), findsOneWidget);
        expect(find.byIcon(Icons.cloud_sync), findsOneWidget);
      });

      testWidgets('shows indicator when pendingCount is 1',
          (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id',
          tripId: 'trip-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          priority: 10,
        );

        await tester.pumpWidget(createWidgetUnderTest(
          const OperationQueueState(
            pendingOperations: [operation],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 1,
            failedCount: 0,
          ),
        ));

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
            priority: 10,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest(
          OperationQueueState(
            pendingOperations: operations,
            failedOperations: [],
            isProcessing: false,
            pendingCount: 99,
            failedCount: 0,
          ),
        ));

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
            priority: 10,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest(
          OperationQueueState(
            pendingOperations: operations,
            failedOperations: [],
            isProcessing: false,
            pendingCount: 100,
            failedCount: 0,
          ),
        ));

        expect(find.byType(IconButton), findsOneWidget);
      });
    });

    group('Badge Display', () {
      testWidgets('displays correct count for 1 pending operation',
          (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id',
          tripId: 'trip-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          priority: 10,
        );

        await tester.pumpWidget(createWidgetUnderTest(
          const OperationQueueState(
            pendingOperations: [operation],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 1,
            failedCount: 0,
          ),
        ));

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
            priority: 10,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest(
          OperationQueueState(
            pendingOperations: operations,
            failedOperations: [],
            isProcessing: false,
            pendingCount: 10,
            failedCount: 0,
          ),
        ));

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
            priority: 10,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest(
          OperationQueueState(
            pendingOperations: operations,
            failedOperations: [],
            isProcessing: false,
            pendingCount: 150,
            failedCount: 0,
          ),
        ));

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
            priority: 10,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest(
          OperationQueueState(
            pendingOperations: operations,
            failedOperations: [],
            isProcessing: false,
            pendingCount: 100,
            failedCount: 0,
          ),
        ));

        final textWidget = tester.widget<Text>(find.text('99+'));
        expect(textWidget.style?.fontSize, 10);
      });

      testWidgets('uses normal font size for counts under 99',
          (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id',
          tripId: 'trip-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          priority: 10,
        );

        await tester.pumpWidget(createWidgetUnderTest(
          const OperationQueueState(
            pendingOperations: [operation],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 1,
            failedCount: 0,
          ),
        ));

        final textWidget = tester.widget<Text>(find.text('1'));
        expect(textWidget.style?.fontSize, 12);
      });
    });

    group('Icon Display', () {
      testWidgets('displays cloud_sync icon', (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id',
          tripId: 'trip-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          priority: 10,
        );

        await tester.pumpWidget(createWidgetUnderTest(
          const OperationQueueState(
            pendingOperations: [operation],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 1,
            failedCount: 0,
          ),
        ));

        expect(find.byIcon(Icons.cloud_sync), findsOneWidget);
      });
    });

    group('Tooltip', () {
      testWidgets('displays tooltip with count information',
          (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id',
          tripId: 'trip-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          priority: 10,
        );

        await tester.pumpWidget(createWidgetUnderTest(
          const OperationQueueState(
            pendingOperations: [operation],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 5,
            failedCount: 0,
          ),
        ));

        final iconButton = tester.widget<IconButton>(find.byType(IconButton));
        expect(iconButton.tooltip, 'View operation queue (5 pending)');
      });
    });

    group('Navigation', () {
      testWidgets('navigates to operation queue screen when tapped',
          (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id',
          tripId: 'trip-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          priority: 10,
        );

        final goRouter = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(
                appBar: AppBar(
                  actions: const [
                    QueueStatusIndicator(),
                  ],
                ),
              ),
            ),
            GoRoute(
              path: '/operation-queue',
              builder: (context, state) => const Scaffold(
                body: Text('Operation Queue Screen'),
              ),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              operationQueueProvider.overrideWithValue(
                const OperationQueueState(
                  pendingOperations: [operation],
                  failedOperations: [],
                  isProcessing: false,
                  pendingCount: 1,
                  failedCount: 0,
                ),
              ),
            ],
            child: MaterialApp.router(
              routerConfig: goRouter,
            ),
          ),
        );

        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        expect(find.text('Operation Queue Screen'), findsOneWidget);
      });
    });

    group('State Reactivity', () {
      testWidgets('updates when pendingCount changes from 0 to 1',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              operationQueueProvider.overrideWithValue(
                const OperationQueueState(
                  pendingOperations: [],
                  failedOperations: [],
                  isProcessing: false,
                  pendingCount: 0,
                  failedCount: 0,
                ),
              ),
            ],
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  actions: const [
                    QueueStatusIndicator(),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.byType(IconButton), findsNothing);

        const operation = TripPlanningOperation(
          id: 'test-id',
          tripId: 'trip-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          priority: 10,
        );

        // Rebuild with new state
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              operationQueueProvider.overrideWithValue(
                const OperationQueueState(
                  pendingOperations: [operation],
                  failedOperations: [],
                  isProcessing: false,
                  pendingCount: 1,
                  failedCount: 0,
                ),
              ),
            ],
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  actions: const [
                    QueueStatusIndicator(),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.byType(IconButton), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
      });

      testWidgets('hides when pendingCount changes from 1 to 0',
          (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id',
          tripId: 'trip-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          priority: 10,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              operationQueueProvider.overrideWithValue(
                const OperationQueueState(
                  pendingOperations: [operation],
                  failedOperations: [],
                  isProcessing: false,
                  pendingCount: 1,
                  failedCount: 0,
                ),
              ),
            ],
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  actions: const [
                    QueueStatusIndicator(),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.byType(IconButton), findsOneWidget);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              operationQueueProvider.overrideWithValue(
                const OperationQueueState(
                  pendingOperations: [],
                  failedOperations: [],
                  isProcessing: false,
                  pendingCount: 0,
                  failedCount: 0,
                ),
              ),
            ],
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  actions: const [
                    QueueStatusIndicator(),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.byType(IconButton), findsNothing);
      });

      testWidgets('updates badge when count changes',
          (WidgetTester tester) async {
        const operation1 = TripPlanningOperation(
          id: 'test-id-1',
          tripId: 'trip-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          priority: 10,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              operationQueueProvider.overrideWithValue(
                const OperationQueueState(
                  pendingOperations: [operation1],
                  failedOperations: [],
                  isProcessing: false,
                  pendingCount: 1,
                  failedCount: 0,
                ),
              ),
            ],
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  actions: const [
                    QueueStatusIndicator(),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('1'), findsOneWidget);

        const operation2 = TripPlanningOperation(
          id: 'test-id-2',
          tripId: 'trip-456',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test 2'},
          priority: 10,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              operationQueueProvider.overrideWithValue(
                const OperationQueueState(
                  pendingOperations: [operation1, operation2],
                  failedOperations: [],
                  isProcessing: false,
                  pendingCount: 2,
                  failedCount: 0,
                ),
              ),
            ],
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  actions: const [
                    QueueStatusIndicator(),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('1'), findsNothing);
        expect(find.text('2'), findsOneWidget);
      });
    });
  });
}
