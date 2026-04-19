import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/core/presentation/screens/operation_queue_screen.dart';
import 'package:soloadventurer/features/core/providers/operation_queue_provider.dart';
import 'package:soloadventurer/features/travel/domain/models/trip_planning_operation.dart';
import 'package:soloadventurer/features/travel/domain/models/travel_note_operation.dart';

class MockOperationQueueNotifier extends OperationQueueNotifier {
  OperationQueueState _initialState = const OperationQueueState(
    pendingOperations: [],
    failedOperations: [],
    isProcessing: false,
    pendingCount: 0,
    failedCount: 0,
  );

  final List<String> methodCalls = [];
  bool shouldThrowOnRetry = false;

  @override
  OperationQueueState build() => _initialState;

  void setInitialState(OperationQueueState state) {
    _initialState = state;
  }

  @override
  void refreshState() {
    methodCalls.add('refreshState');
  }

  @override
  Future<void> retryOperation(String id) async {
    methodCalls.add('retryOperation:$id');
    if (shouldThrowOnRetry) {
      throw Exception('Retry failed');
    }
  }

  @override
  Future<void> removeFailedOperation(String id) async {
    methodCalls.add('removeFailedOperation:$id');
  }

  @override
  Future<void> clearFailedOperations() async {
    methodCalls.add('clearFailedOperations');
  }

  @override
  Future<void> processQueue() async {
    methodCalls.add('processQueue');
  }
}

void main() {
  group('OperationQueueScreen', () {
    late MockOperationQueueNotifier mockNotifier;

    setUp(() {
      mockNotifier = MockOperationQueueNotifier();

      // Default behavior for mocks
      
      
      
      
      
    });

    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          operationQueueProvider.overrideWith(() => mockNotifier),
        ],
        child: const MaterialApp(
          home: OperationQueueScreen(),
        ),
      );
    }

    group('Empty State', () {
      testWidgets('displays empty state when queue is empty',
          (WidgetTester tester) async {
        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 0,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('All Clear!'), findsOneWidget);
        expect(
          find.text('No operations are currently pending or failed.'),
          findsOneWidget,
        );
        expect(
          find.text('Your changes have been synced successfully.'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      });

      testWidgets('shows check_circle_outline icon in empty state',
          (WidgetTester tester) async {
        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 0,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      });

      testWidgets('does not show floating action button when queue is empty',
          (WidgetTester tester) async {
        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [],
            failedOperations: [],
            isProcessing: true, // Processing state hides FAB
            pendingCount: 0,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byType(FloatingActionButton), findsNothing);
      });
    });

    group('Pending Operations Section', () {
      testWidgets('displays pending operations section title',
          (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id-01',
          tripId: 'trip-id-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          priority: 10,
        );

        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [operation],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 1,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Pending Operations (1)'), findsOneWidget);
        expect(find.byIcon(Icons.pending), findsOneWidget);
      });

      testWidgets('displays pending operation count in app bar',
          (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id-01',
          tripId: 'trip-id-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          priority: 10,
        );

        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [operation],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 3,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('3 pending'), findsOneWidget);
      });

      testWidgets('displays list of pending operations',
          (WidgetTester tester) async {
        final operations = List.generate(
          2,
          (i) => TripPlanningOperation(
            id: 'test-id-0$i',
            tripId: 'trip-id-00$i',
            planningType: TripPlanningType.update,
            changes: {'name': 'Test $i'},
            priority: 10,
          ),
        );

        mockNotifier.setInitialState(OperationQueueState(
            pendingOperations: operations,
            failedOperations: [],
            isProcessing: false,
            pendingCount: 2,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Pending Operations (2)'), findsOneWidget);
        expect(find.byType(Card), findsNWidgets(2));
      });
    });

    group('Failed Operations Section', () {
      testWidgets('displays failed operations section title',
          (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id-01',
          tripId: 'trip-id-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          attemptCount: 3,
          lastError: 'Network error',
        priority: 10,
        );

        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [],
            failedOperations: [operation],
            isProcessing: false,
            pendingCount: 0,
            failedCount: 1,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Failed Operations (1)'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsAtLeast(1));
      });

      testWidgets('displays failed operation count in app bar',
          (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id-01',
          tripId: 'trip-id-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          attemptCount: 3,
          lastError: 'Network error',
        priority: 10,
        );

        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [],
            failedOperations: [operation],
            isProcessing: false,
            pendingCount: 0,
            failedCount: 2,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('2 failed'), findsOneWidget);
      });

      testWidgets(
          'displays Clear All button when there are multiple failed operations',
          (WidgetTester tester) async {
        final operations = List.generate(
          2,
          (i) => TripPlanningOperation(
            id: 'test-id-0$i',
            tripId: 'trip-id-00$i',
            planningType: TripPlanningType.update,
            changes: {'name': 'Test $i'},
            attemptCount: 3,
            lastError: 'Network error',
          priority: 10,
          ),
        );

        mockNotifier.setInitialState(OperationQueueState(
            pendingOperations: [],
            failedOperations: operations,
            isProcessing: false,
            pendingCount: 0,
            failedCount: 2,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Clear All'), findsOneWidget);
      });

      testWidgets(
          'does not display Clear All button when there is only one failed operation',
          (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id-01',
          tripId: 'trip-id-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          attemptCount: 3,
          lastError: 'Network error',
        priority: 10,
        );

        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [],
            failedOperations: [operation],
            isProcessing: false,
            pendingCount: 0,
            failedCount: 1,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Clear All'), findsNothing);
      });

      testWidgets('displays list of failed operations with retry buttons',
          (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id-01',
          tripId: 'trip-id-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          attemptCount: 3,
          lastError: 'Network error',
        priority: 10,
        );

        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [],
            failedOperations: [operation],
            isProcessing: false,
            pendingCount: 0,
            failedCount: 1,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Retry'), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });
    });

    group('Processing Status', () {
      testWidgets('displays processing banner when isProcessing is true',
          (WidgetTester tester) async {
        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [],
            failedOperations: [],
            isProcessing: true,
            pendingCount: 1,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Processing operations...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('does not show floating action button when processing',
          (WidgetTester tester) async {
        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [],
            failedOperations: [],
            isProcessing: true,
            pendingCount: 0,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byType(FloatingActionButton), findsNothing);
      });

      testWidgets(
          'shows floating action button when not processing and has operations',
          (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id-01',
          tripId: 'trip-id-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          priority: 10,
        );

        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [operation],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 1,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.text('Process Queue'), findsOneWidget);
      });
    });

    group('Pull to Refresh', () {
      testWidgets('calls refreshState when pulled to refresh',
          (WidgetTester tester) async {
        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 0,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        await tester.drag(
          find.byType(RefreshIndicator),
          const Offset(0, 300),
        );
        await tester.pump();

        expect(mockNotifier.methodCalls, contains('refreshState'));
      });
    });

    group('Floating Action Button', () {
      testWidgets('calls processQueue when FAB is tapped',
          (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id-01',
          tripId: 'trip-id-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          priority: 10,
        );

        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [operation],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 1,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        expect(mockNotifier.methodCalls, contains('processQueue'));
      });

      testWidgets('displays play_arrow icon on FAB',
          (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id-01',
          tripId: 'trip-id-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          priority: 10,
        );

        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [operation],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 1,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      });
    });

    group('Retry Operation', () {
      testWidgets(
          'shows confirmation dialog and calls retryOperation when retry is tapped',
          (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id-01',
          tripId: 'trip-id-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          attemptCount: 3,
          lastError: 'Network error',
        priority: 10,
        );

        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [],
            failedOperations: [operation],
            isProcessing: false,
            pendingCount: 0,
            failedCount: 1,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        expect(mockNotifier.methodCalls, contains('retryOperation:test-id-01'));
      });

      testWidgets('shows success SnackBar when retry succeeds',
          (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id-01',
          tripId: 'trip-id-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          attemptCount: 3,
          lastError: 'Network error',
        priority: 10,
        );

        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [],
            failedOperations: [operation],
            isProcessing: false,
            pendingCount: 0,
            failedCount: 1,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        expect(find.text('Operation queued for retry'), findsOneWidget);
      });

      testWidgets('shows error SnackBar when retry fails',
          (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id-01',
          tripId: 'trip-id-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          attemptCount: 3,
          lastError: 'Network error',
        priority: 10,
        );

        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [],
            failedOperations: [operation],
            isProcessing: false,
            pendingCount: 0,
            failedCount: 1,
          ),
        );

        mockNotifier.shouldThrowOnRetry = true;

        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        expect(
            find.textContaining('Failed to retry operation'), findsOneWidget);
      });
    });

    group('Remove Operation', () {
      testWidgets('shows confirmation dialog when remove is tapped',
          (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id-01',
          tripId: 'trip-id-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          attemptCount: 3,
          lastError: 'Network error',
        priority: 10,
        );

        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [],
            failedOperations: [operation],
            isProcessing: false,
            pendingCount: 0,
            failedCount: 1,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.text('Remove'));
        await tester.pumpAndSettle();

        expect(find.text('Remove Operation'), findsOneWidget);
        expect(
          find.text('Are you sure you want to remove this operation? This action cannot be undone.'),
          findsOneWidget,
        );
      });

      testWidgets('calls removeFailedOperation when dialog is confirmed',
          (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id-01',
          tripId: 'trip-id-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          attemptCount: 3,
          lastError: 'Network error',
        priority: 10,
        );

        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [],
            failedOperations: [operation],
            isProcessing: false,
            pendingCount: 0,
            failedCount: 1,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.text('Remove'));
        await tester.pumpAndSettle();

        // Tap the dialog's Remove button (in AlertDialog actions)
        await tester.tap(find.widgetWithText(TextButton, 'Remove').last);
        await tester.pumpAndSettle();

        expect(mockNotifier.methodCalls, contains('removeFailedOperation:test-id-01'));
      });

      testWidgets(
          'does not call removeFailedOperation when dialog is cancelled',
          (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id-01',
          tripId: 'trip-id-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          attemptCount: 3,
          lastError: 'Network error',
        priority: 10,
        );

        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [],
            failedOperations: [operation],
            isProcessing: false,
            pendingCount: 0,
            failedCount: 1,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.text('Remove'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(mockNotifier.methodCalls.where((c) => c.startsWith('removeFailedOperation')).isEmpty, isTrue);
      });

      testWidgets('shows success SnackBar when remove succeeds',
          (WidgetTester tester) async {
        const operation = TripPlanningOperation(
          id: 'test-id-01',
          tripId: 'trip-id-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Test'},
          attemptCount: 3,
          lastError: 'Network error',
        priority: 10,
        );

        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [],
            failedOperations: [operation],
            isProcessing: false,
            pendingCount: 0,
            failedCount: 1,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.text('Remove'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, 'Remove').last);
        await tester.pumpAndSettle();

        expect(find.text('Operation removed'), findsOneWidget);
      });
    });

    group('Clear All Failed Operations', () {
      testWidgets('shows confirmation dialog when Clear All is tapped',
          (WidgetTester tester) async {
        final operations = List.generate(
          2,
          (i) => TripPlanningOperation(
            id: 'test-id-0$i',
            tripId: 'trip-id-00$i',
            planningType: TripPlanningType.update,
            changes: {'name': 'Test $i'},
            attemptCount: 3,
            lastError: 'Network error',
          priority: 10,
          ),
        );

        mockNotifier.setInitialState(OperationQueueState(
            pendingOperations: [],
            failedOperations: operations,
            isProcessing: false,
            pendingCount: 0,
            failedCount: 2,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.text('Clear All'));
        await tester.pumpAndSettle();

        expect(find.text('Clear All Failed Operations'), findsOneWidget);
        expect(
          find.textContaining(
              'Are you sure you want to clear all 2 failed operations?'),
          findsOneWidget,
        );
      });

      testWidgets('calls clearFailedOperations when dialog is confirmed',
          (WidgetTester tester) async {
        final operations = List.generate(
          2,
          (i) => TripPlanningOperation(
            id: 'test-id-0$i',
            tripId: 'trip-id-00$i',
            planningType: TripPlanningType.update,
            changes: {'name': 'Test $i'},
            attemptCount: 3,
            lastError: 'Network error',
          priority: 10,
          ),
        );

        mockNotifier.setInitialState(OperationQueueState(
            pendingOperations: [],
            failedOperations: operations,
            isProcessing: false,
            pendingCount: 0,
            failedCount: 2,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.text('Clear All'));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(TextButton, 'Clear All').last);
        await tester.pumpAndSettle();

        expect(mockNotifier.methodCalls, contains('clearFailedOperations'));
      });

      testWidgets(
          'does not call clearFailedOperations when dialog is cancelled',
          (WidgetTester tester) async {
        final operations = List.generate(
          2,
          (i) => TripPlanningOperation(
            id: 'test-id-0$i',
            tripId: 'trip-id-00$i',
            planningType: TripPlanningType.update,
            changes: {'name': 'Test $i'},
            attemptCount: 3,
            lastError: 'Network error',
          priority: 10,
          ),
        );

        mockNotifier.setInitialState(OperationQueueState(
            pendingOperations: [],
            failedOperations: operations,
            isProcessing: false,
            pendingCount: 0,
            failedCount: 2,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.text('Clear All'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(mockNotifier.methodCalls.contains('clearFailedOperations'), isFalse);
      });

      testWidgets('shows success SnackBar when clear all succeeds',
          (WidgetTester tester) async {
        final operations = List.generate(
          2,
          (i) => TripPlanningOperation(
            id: 'test-id-0$i',
            tripId: 'trip-id-00$i',
            planningType: TripPlanningType.update,
            changes: {'name': 'Test $i'},
            attemptCount: 3,
            lastError: 'Network error',
          priority: 10,
          ),
        );

        mockNotifier.setInitialState(OperationQueueState(
            pendingOperations: [],
            failedOperations: operations,
            isProcessing: false,
            pendingCount: 0,
            failedCount: 2,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.text('Clear All'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, 'Clear All').last);
        await tester.pumpAndSettle();

        expect(find.text('All failed operations cleared'), findsOneWidget);
      });
    });

    group('State Refresh', () {
      testWidgets('calls refreshState on init', (WidgetTester tester) async {
        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [],
            failedOperations: [],
            isProcessing: false,
            pendingCount: 0,
            failedCount: 0,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        expect(mockNotifier.methodCalls, contains('refreshState'));
      });
    });

    group('Mixed Operations', () {
      testWidgets('displays both pending and failed operations',
          (WidgetTester tester) async {
        const pendingOp = TripPlanningOperation(
          id: 'pending-id',
          tripId: 'trip-id-123',
          planningType: TripPlanningType.update,
          changes: {'name': 'Pending Test'},
          priority: 10,
        );

        const failedOp = TravelNoteOperation(
          id: 'failed-id',
          tripId: 'trip-id-456',
          noteType: NoteType.text,
          content: {'text': 'Failed note'},
          priority: 10,
          attemptCount: 3,
          lastError: 'Network error',
        );

        mockNotifier.setInitialState(const OperationQueueState(
            pendingOperations: [pendingOp],
            failedOperations: [failedOp],
            isProcessing: false,
            pendingCount: 1,
            failedCount: 1,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Pending Operations (1)'), findsOneWidget);
        expect(find.text('Failed Operations (1)'), findsOneWidget);
        expect(find.text('1 pending'), findsOneWidget);
        expect(find.text('1 failed'), findsOneWidget);
      });
    });
  });
}
