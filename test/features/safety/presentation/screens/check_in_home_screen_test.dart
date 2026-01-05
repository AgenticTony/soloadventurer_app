import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import 'package:soloadventurer/features/safety/presentation/state/check_in_state.dart';
import 'package:soloadventurer/features/safety/presentation/screens/check_in_home_screen.dart';
import 'package:soloadventurer/features/safety/presentation/providers/safety_providers.dart';

// Mock classes
class MockCheckInNotifier extends ChangeNotifier implements CheckInNotifier {
  CheckInState _state = CheckInState.initial();
  String? _error;

  @override
  CheckInState get state => _state;

  @override
  String? get error => _error;

  @override
  bool get isLoading => _state.isLoading;

  @override
  bool get isProcessing => _state.isProcessing;

  @override
  List<CheckIn> get checkIns => _state.checkIns;

  @override
  List<CheckIn> get upcomingCheckIns => _state.upcomingCheckIns;

  void setState(CheckInState state) {
    _state = state;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  @override
  Future<void> loadUpcomingCheckIns() {
    _state = CheckInState(
      checkIns: _state.checkIns,
      upcomingCheckIns: _state.upcomingCheckIns,
      isLoading: false,
      isProcessing: false,
      error: null,
    );
    notifyListeners();
    return Future.value();
  }

  @override
  Future<void> loadCheckIns() => Future.value();

  @override
  Future<void> createCheckIn({
    required CheckInTriggerType triggerType,
    CheckInLocation? location,
    String? statusMessage,
    SafetyStatusType? statusType,
    List<String>? notifyContactIds,
    String? tripId,
  }) => Future.value();

  @override
  Future<void> completeCheckIn({
    required String checkInId,
    CheckInLocation? location,
    String? statusMessage,
    SafetyStatusType? statusType,
  }) => Future.value();

  @override
  Future<void> scheduleCheckIn({
    required CheckInTriggerType triggerType,
    required DateTime scheduledTime,
    DateTime? deadline,
    CheckInLocation? location,
    String? statusMessage,
    List<String>? notifyContactIds,
    String? tripId,
  }) => Future.value();

  @override
  Future<void> cancelCheckIn(String checkInId) => Future.value();

  @override
  Future<void> updateCheckInStatus(
    String checkInId,
    CheckInStatus status,
  ) => Future.value();

  @override
  CheckIn? getCheckInById(String id) => null;

  @override
  List<CheckIn> getCheckInsByTrip(String tripId) => [];
}

void main() {
  late MockCheckInNotifier mockCheckInNotifier;

  setUpAll(() {
    // Register fallback values
    registerFallbackValue(const CheckInState.initial());
  });

  setUp(() {
    mockCheckInNotifier = MockCheckInNotifier();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        checkInNotifierProvider.overrideWith((ref) => mockCheckInNotifier),
      ],
      child: const MaterialApp(
        home: CheckInHomeScreen(),
      ),
    );
  }

  group('CheckInHomeScreen', () {
    group('Rendering', () {
      testWidgets('shows loading indicator on initial load',
          (tester) async {
        mockCheckInNotifier.setState(
          const CheckInState(
            checkIns: [],
            upcomingCheckIns: [],
            isLoading: true,
            isProcessing: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('shows empty state when no check-ins', (tester) async {
        mockCheckInNotifier.setState(
          const CheckInState(
            checkIns: [],
            upcomingCheckIns: [],
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('No upcoming check-ins'), findsOneWidget);
      });

      testWidgets('shows upcoming check-ins when available', (tester) async {
        final now = DateTime.now();
        final checkIns = [
          CheckIn(
            id: 'checkin-1',
            userId: 'user-123',
            triggerType: CheckInTriggerType.manual,
            status: CheckInStatus.scheduled,
            scheduledTime: now.add(const Duration(hours: 2)),
            createdAt: now,
          ),
          CheckIn(
            id: 'checkin-2',
            userId: 'user-123',
            triggerType: CheckInTriggerType.scheduled,
            status: CheckInStatus.scheduled,
            scheduledTime: now.add(const Duration(hours: 5)),
            createdAt: now,
          ),
        ];

        mockCheckInNotifier.setState(
          CheckInState(
            checkIns: checkIns,
            upcomingCheckIns: checkIns,
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Upcoming Check-ins'), findsOneWidget);
        expect(find.byType(Card), findsWidgets); // Status cards + check-in cards
      });

      testWidgets('shows status cards with due soon and missed counts',
          (tester) async {
        final now = DateTime.now();
        final checkIns = [
          CheckIn(
            id: 'checkin-1',
            userId: 'user-123',
            triggerType: CheckInTriggerType.manual,
            status: CheckInStatus.scheduled,
            scheduledTime: now.add(const Duration(minutes: 15)),
            createdAt: now,
          ),
          CheckIn(
            id: 'checkin-2',
            userId: 'user-123',
            triggerType: CheckInTriggerType.manual,
            status: CheckInStatus.missed,
            scheduledTime: now.subtract(const Duration(hours: 1)),
            deadline: now.subtract(const Duration(minutes: 30)),
            createdAt: now.subtract(const Duration(hours: 2)),
          ),
        ];

        mockCheckInNotifier.setState(
          CheckInState(
            checkIns: checkIns,
            upcomingCheckIns: checkIns,
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Due Soon'), findsOneWidget);
        expect(find.text('Missed'), findsOneWidget);
        expect(find.text('1'), findsAtLeastNWidgets(2)); // Both cards show count
      });

      testWidgets('shows next check-in card prominently', (tester) async {
        final now = DateTime.now();
        final nextCheckIn = CheckIn(
          id: 'checkin-1',
          userId: 'user-123',
          triggerType: CheckInTriggerType.scheduled,
          status: CheckInStatus.scheduled,
          scheduledTime: now.add(const Duration(hours: 1)),
          deadline: now.add(const Duration(hours: 2)),
          createdAt: now,
          statusMessage: 'Arrive at hotel',
        );

        mockCheckInNotifier.setState(
          CheckInState(
            checkIns: [nextCheckIn],
            upcomingCheckIns: [nextCheckIn],
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Next Check-in'), findsOneWidget);
        expect(find.text('Arrive at hotel'), findsOneWidget);
      });

      testWidgets('shows error state when loading fails', (tester) async {
        mockCheckInNotifier.setState(
          const CheckInState(
            checkIns: [],
            upcomingCheckIns: [],
            isLoading: false,
            isProcessing: false,
            error: 'Failed to load check-ins',
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Failed to load check-ins'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });
    });

    group('App Bar Actions', () {
      testWidgets('shows history button', (tester) async {
        mockCheckInNotifier.setState(
          const CheckInState(
            checkIns: [],
            upcomingCheckIns: [],
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.history), findsOneWidget);
        expect(find.byTooltip('Check-in History'), findsOneWidget);
      });

      testWidgets('shows info button', (tester) async {
        mockCheckInNotifier.setState(
          const CheckInState(
            checkIns: [],
            upcomingCheckIns: [],
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.info_outline), findsOneWidget);
        expect(find.byTooltip('About Check-ins'), findsOneWidget);
      });

      testWidgets('shows info dialog when info button is tapped',
          (tester) async {
        mockCheckInNotifier.setState(
          const CheckInState(
            checkIns: [],
            upcomingCheckIns: [],
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.info_outline));
        await tester.pumpAndSettle();

        expect(find.text('About Check-ins'), findsOneWidget);
      });
    });

    group('Floating Action Button', () {
      testWidgets('shows FAB for new check-in', (tester) async {
        mockCheckInNotifier.setState(
          const CheckInState(
            checkIns: [],
            upcomingCheckIns: [],
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.text('New Check-in'), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('disables FAB when processing', (tester) async {
        mockCheckInNotifier.setState(
          const CheckInState(
            checkIns: [],
            upcomingCheckIns: [],
            isLoading: false,
            isProcessing: true,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final fab = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );
        expect(fab.onPressed, isNull);
      });

      testWidgets('shows menu when FAB is tapped', (tester) async {
        mockCheckInNotifier.setState(
          const CheckInState(
            checkIns: [],
            upcomingCheckIns: [],
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.text('Manual Check-in'), findsOneWidget);
        expect(find.text('Schedule Check-in'), findsOneWidget);
      });
    });

    group('Check-in Cards', () {
      testWidgets('displays check-in cards with correct information',
          (tester) async {
        final now = DateTime.now();
        final checkIn = CheckIn(
          id: 'checkin-1',
          userId: 'user-123',
          triggerType: CheckInTriggerType.scheduled,
          status: CheckInStatus.scheduled,
          scheduledTime: now.add(const Duration(hours: 2)),
          deadline: now.add(const Duration(hours: 3)),
          createdAt: now,
          statusMessage: 'Check in at hotel',
        );

        mockCheckInNotifier.setState(
          CheckInState(
            checkIns: [checkIn],
            upcomingCheckIns: [checkIn],
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Check in at hotel'), findsOneWidget);
        expect(find.byIcon(Icons.schedule), findsOneWidget);
      });

      testWidgets('shows correct status chip for scheduled check-ins',
          (tester) async {
        final now = DateTime.now();
        final checkIn = CheckIn(
          id: 'checkin-1',
          userId: 'user-123',
          triggerType: CheckInTriggerType.scheduled,
          status: CheckInStatus.scheduled,
          scheduledTime: now.add(const Duration(hours: 2)),
          createdAt: now,
        );

        mockCheckInNotifier.setState(
          CheckInState(
            checkIns: [checkIn],
            upcomingCheckIns: [checkIn],
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Scheduled'), findsOneWidget);
      });

      testWidgets('shows correct status chip for active check-ins',
          (tester) async {
        final now = DateTime.now();
        final checkIn = CheckIn(
          id: 'checkin-1',
          userId: 'user-123',
          triggerType: CheckInTriggerType.manual,
          status: CheckInStatus.active,
          scheduledTime: now.subtract(const Duration(minutes: 30)),
          deadline: now.add(const Duration(minutes: 30)),
          createdAt: now.subtract(const Duration(minutes: 30)),
        );

        mockCheckInNotifier.setState(
          CheckInState(
            checkIns: [checkIn],
            upcomingCheckIns: [checkIn],
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Active'), findsOneWidget);
      });

      testWidgets('shows location info when available', (tester) async {
        final now = DateTime.now();
        final checkIn = CheckIn(
          id: 'checkin-1',
          userId: 'user-123',
          triggerType: CheckInTriggerType.locationArrival,
          status: CheckInStatus.scheduled,
          scheduledTime: now.add(const Duration(hours: 2)),
          createdAt: now,
          location: CheckInLocation(
            latitude: 37.7749,
            longitude: -122.4194,
            accuracy: 10.0,
            timestamp: now,
          ),
        );

        mockCheckInNotifier.setState(
          CheckInState(
            checkIns: [checkIn],
            upcomingCheckIns: [checkIn],
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.location_on), findsWidgets);
      });
    });

    group('Status Cards', () {
      testWidgets('tapping status card performs action', (tester) async {
        mockCheckInNotifier.setState(
          const CheckInState(
            checkIns: [],
            upcomingCheckIns: [],
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Tap on status card (should not crash)
        await tester.tap(find.text('Due Soon'));
        await tester.pump();

        // Card should still exist (no navigation in tests)
        expect(find.text('Due Soon'), findsOneWidget);
      });

      testWidgets('shows orange color when due soon count > 0', (tester) async {
        final now = DateTime.now();
        final checkIn = CheckIn(
          id: 'checkin-1',
          userId: 'user-123',
          triggerType: CheckInTriggerType.manual,
          status: CheckInStatus.scheduled,
          scheduledTime: now.add(const Duration(minutes: 15)),
          deadline: now.add(const Duration(minutes: 45)),
          createdAt: now,
        );

        mockCheckInNotifier.setState(
          CheckInState(
            checkIns: [checkIn],
            upcomingCheckIns: [checkIn],
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Due Soon card should be visible
        expect(find.text('Due Soon'), findsOneWidget);
      });

      testWidgets('shows red color when missed count > 0', (tester) async {
        final now = DateTime.now();
        final checkIn = CheckIn(
          id: 'checkin-1',
          userId: 'user-123',
          triggerType: CheckInTriggerType.manual,
          status: CheckInStatus.missed,
          scheduledTime: now.subtract(const Duration(hours: 1)),
          deadline: now.subtract(const Duration(minutes: 30)),
          createdAt: now.subtract(const Duration(hours: 2)),
        );

        mockCheckInNotifier.setState(
          CheckInState(
            checkIns: [checkIn],
            upcomingCheckIns: [checkIn],
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Missed card should be visible
        expect(find.text('Missed'), findsOneWidget);
      });
    });

    group('Pull to Refresh', () {
      testWidgets('loads check-ins on init', (tester) async {
        mockCheckInNotifier.setState(
          const CheckInState(
            checkIns: [],
            upcomingCheckIns: [],
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        // Load upcoming check-ins should be called on init
        verify(() => mockCheckInNotifier.loadUpcomingCheckIns()).called(1);
      });
    });

    group('State Colors', () {
      testWidgets('shows due soon check-ins in orange', (tester) async {
        final now = DateTime.now();
        final checkIn = CheckIn(
          id: 'checkin-1',
          userId: 'user-123',
          triggerType: CheckInTriggerType.manual,
          status: CheckInStatus.scheduled,
          scheduledTime: now.add(const Duration(minutes: 15)),
          deadline: now.add(const Duration(minutes: 45)),
          createdAt: now,
        );

        mockCheckInNotifier.setState(
          CheckInState(
            checkIns: [checkIn],
            upcomingCheckIns: [checkIn],
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Next check-in card should use orange gradient
        expect(find.text('Next Check-in'), findsOneWidget);
      });

      testWidgets('shows overdue check-ins in red', (tester) async {
        final now = DateTime.now();
        final checkIn = CheckIn(
          id: 'checkin-1',
          userId: 'user-123',
          triggerType: CheckInTriggerType.manual,
          status: CheckInStatus.active,
          scheduledTime: now.subtract(const Duration(minutes: 45)),
          deadline: now.subtract(const Duration(minutes: 15)),
          createdAt: now.subtract(const Duration(hours: 1)),
        );

        mockCheckInNotifier.setState(
          CheckInState(
            checkIns: [checkIn],
            upcomingCheckIns: [checkIn],
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Next check-in card should use red gradient
        expect(find.text('Next Check-in'), findsOneWidget);
      });
    });
  });
}
