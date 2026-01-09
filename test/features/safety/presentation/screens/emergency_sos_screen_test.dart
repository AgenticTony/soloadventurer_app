import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_status.dart';
import 'package:soloadventurer/features/safety/presentation/state/safety_state.dart';
import 'package:soloadventurer/features/safety/presentation/state/trusted_contacts_state.dart';
import 'package:soloadventurer/features/safety/presentation/state/check_in_state.dart';
import 'package:soloadventurer/features/safety/presentation/state/location_sharing_state.dart';
import 'package:soloadventurer/features/safety/presentation/screens/emergency_sos_screen.dart';
import 'package:soloadventurer/features/safety/presentation/providers/safety_providers.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier_provider.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/core/services/location_service.dart';

// Mock classes
class MockSafetyNotifier extends ChangeNotifier implements SafetyNotifier {
  SafetyState _state = SafetyState.initial();
  String? _error;

  @override
  SafetyState get state => _state;

  @override
  String? get error => _error;

  @override
  bool get isLoading => false;

  @override
  bool get isProcessing => _state.isProcessing;

  void setState(SafetyState state) {
    _state = state;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  @override
  Future<void> triggerEmergencySOS({
    required String userId,
    required SafetyAlertLocation location,
    String? message,
    List<String>? notifyContactIds,
    int? batteryLevel,
    String? tripId,
  }) {
    _state = SafetyState(
      currentStatus: _state.currentStatus,
      recentAlerts: _state.recentAlerts,
      activeAlerts: [
        SafetyAlert(
          id: 'alert-1',
          type: SafetyAlertType.emergency,
          status: SafetyAlertStatus.active,
          userId: userId,
          location: location,
          message: message,
          notifiedContactIds: notifyContactIds ?? ['contact-1'],
          triggeredAt: DateTime.now(),
          batteryLevel: batteryLevel,
        )
      ],
      isLoading: false,
      isProcessing: false,
      error: null,
    );
    notifyListeners();
    return Future.value();
  }

  @override
  Future<void> updateSafetyStatus({
    required String userId,
    required SafetyStatusType statusType,
    String? message,
    SafetyStatusLocation? location,
    int? batteryLevel,
    String? linkedAlertId,
    String? linkedCheckInId,
  }) {
    return Future.value();
  }

  @override
  Future<int> getBatteryLevel() async => 85;

  @override
  Future<void> acknowledgeAlert(String alertId) => Future.value();

  @override
  Future<void> resolveAlert(String alertId) => Future.value();

  @override
  Future<void> cancelAlert(String alertId) {
    final updatedAlerts =
        _state.activeAlerts.where((alert) => alert.id != alertId).toList();
    _state = SafetyState(
      currentStatus: _state.currentStatus,
      recentAlerts: _state.recentAlerts,
      activeAlerts: updatedAlerts,
      isLoading: false,
      isProcessing: false,
      error: null,
    );
    notifyListeners();
    return Future.value();
  }

  @override
  Future<void> markAsSafe({
    String? message,
    SafetyStatusLocation? location,
    int? batteryLevel,
  }) {
    return Future.value();
  }

  @override
  Future<void> markAsNeedHelp({
    String? message,
    SafetyStatusLocation? location,
    int? batteryLevel,
  }) {
    return Future.value();
  }

  @override
  Future<void> markAsEmergency({
    String? message,
    SafetyStatusLocation? location,
    int? batteryLevel,
  }) {
    return Future.value();
  }

  @override
  // noop: silence the abstract method implementation warning
  Future<void> loadSafetyStatus() => Future.value();
}

class MockTrustedContactsNotifier extends ChangeNotifier
    implements TrustedContactsNotifier {
  TrustedContactsState _state = TrustedContactsState.initial();

  @override
  TrustedContactsState get state => _state;

  void setState(TrustedContactsState state) {
    _state = state;
    notifyListeners();
  }

  @override
  List<TrustedContact> get contacts => _state.contacts;

  @override
  bool get isLoading => _state.isLoading;

  @override
  String? get error => _state.error;

  @override
  Future<void> loadContacts() => Future.value();

  @override
  Future<void> addContact(TrustedContact contact) => Future.value();

  @override
  Future<void> updateContact(TrustedContact contact) => Future.value();

  @override
  Future<void> removeContact(String contactId) => Future.value();
}

class MockLocationService extends Mock implements LocationService {}

class MockUser extends Mock implements User {}

void main() {
  late MockSafetyNotifier mockSafetyNotifier;
  late MockTrustedContactsNotifier mockTrustedContactsNotifier;
  late MockLocationService mockLocationService;
  late MockUser mockUser;

  setUpAll(() {
    // Register fallback values
    registerFallbackValue(SafetyState.initial());
    registerFallbackValue(TrustedContactsState.initial());
  });

  setUp(() {
    mockSafetyNotifier = MockSafetyNotifier();
    mockTrustedContactsNotifier = MockTrustedContactsNotifier();
    mockLocationService = MockLocationService();
    mockUser = MockUser();

    // Setup default mock behavior
    when(() => mockUser.id).thenReturn('user-123');
    when(() => mockLocationService.getCurrentLocation(
          accuracy: any(named: 'accuracy'),
        )).thenAnswer((_) async => LocationData(
          latitude: 37.7749,
          longitude: -122.4194,
          accuracy: 10.0,
          altitude: 0.0,
          timestamp: DateTime.now(),
        ));
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        safetyNotifierProvider.overrideWith((ref) => mockSafetyNotifier),
        trustedContactsNotifierProvider.overrideWith(
          (ref) => mockTrustedContactsNotifier,
        ),
        locationServiceProvider.overrideWith((ref) => mockLocationService),
        currentUserProvider.overrideWith((ref) => mockUser),
      ],
      child: const MaterialApp(
        home: EmergencySOSScreen(),
      ),
    );
  }

  group('EmergencySOSScreen', () {
    group('Rendering', () {
      testWidgets('shows SOS button when no active emergency', (tester) async {
        mockSafetyNotifier.setState(SafetyState.initial());
        mockTrustedContactsNotifier.setState(
          const TrustedContactsState(
            contacts: [],
            isLoading: false,
            isAdding: false,
            isUpdating: false,
            isRemoving: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('SOS'), findsOneWidget);
        expect(find.text('Press to send emergency alert'), findsOneWidget);
      });

      testWidgets('shows active emergency banner when alert is active',
          (tester) async {
        final activeAlert = SafetyAlert(
          id: 'alert-1',
          type: SafetyAlertType.emergency,
          status: SafetyAlertStatus.active,
          userId: 'user-123',
          location: SafetyAlertLocation(
            latitude: 37.7749,
            longitude: -122.4194,
            timestamp: DateTime.now(),
          ),
          triggeredAt: DateTime.now().subtract(const Duration(minutes: 5)),
        );

        mockSafetyNotifier.setState(
          SafetyState(
            currentStatus: null,
            recentAlerts: const [],
            activeAlerts: [activeAlert],
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        mockTrustedContactsNotifier.setState(
          const TrustedContactsState(
            contacts: [],
            isLoading: false,
            isAdding: false,
            isUpdating: false,
            isRemoving: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('ACTIVE'), findsOneWidget);
        expect(find.text('Emergency Alert Active'), findsOneWidget);
      });

      testWidgets('shows location card with coordinates', (tester) async {
        mockSafetyNotifier.setState(SafetyState.initial());
        mockTrustedContactsNotifier.setState(
          const TrustedContactsState(
            contacts: [],
            isLoading: false,
            isAdding: false,
            isUpdating: false,
            isRemoving: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Location to Share'), findsOneWidget);
        expect(find.text('Lat'), findsOneWidget);
        expect(find.text('Lng'), findsOneWidget);
      });

      testWidgets('shows emergency contacts when available', (tester) async {
        final contacts = [
          const TrustedContact(
            id: 'contact-1',
            name: 'John Doe',
            phone: '+1234567890',
            receivesEmergencyAlerts: true,
          ),
          const TrustedContact(
            id: 'contact-2',
            name: 'Jane Smith',
            phone: '+0987654321',
            receivesEmergencyAlerts: true,
          ),
        ];

        mockSafetyNotifier.setState(SafetyState.initial());
        mockTrustedContactsNotifier.setState(
          TrustedContactsState(
            contacts: contacts,
            isLoading: false,
            isAdding: false,
            isUpdating: false,
            isRemoving: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Will Notify'), findsOneWidget);
        expect(find.text('2 Contacts'), findsOneWidget);
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('Jane Smith'), findsOneWidget);
      });

      testWidgets('shows warning when no emergency contacts configured',
          (tester) async {
        mockSafetyNotifier.setState(SafetyState.initial());
        mockTrustedContactsNotifier.setState(
          const TrustedContactsState(
            contacts: [],
            isLoading: false,
            isAdding: false,
            isUpdating: false,
            isRemoving: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.warning_amber), findsOneWidget);
        expect(
          find.text(
            'No contacts will be notified. Add trusted contacts with emergency alerts enabled.',
          ),
          findsOneWidget,
        );
      });

      testWidgets('shows message input field', (tester) async {
        mockSafetyNotifier.setState(SafetyState.initial());
        mockTrustedContactsNotifier.setState(
          const TrustedContactsState(
            contacts: [],
            isLoading: false,
            isAdding: false,
            isUpdating: false,
            isRemoving: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Message (Optional)'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      });
    });

    group('SOS Triggering', () {
      testWidgets('shows confirmation dialog when SOS button is tapped',
          (tester) async {
        mockSafetyNotifier.setState(SafetyState.initial());
        mockTrustedContactsNotifier.setState(
          const TrustedContactsState(
            contacts: [],
            isLoading: false,
            isAdding: false,
            isUpdating: false,
            isRemoving: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Tap SOS button
        await tester.tap(find.text('SOS'));
        await tester.pumpAndSettle();

        expect(find.text('Confirm Emergency SOS'), findsOneWidget);
      });

      testWidgets('triggers SOS after confirmation', (tester) async {
        mockSafetyNotifier.setState(SafetyState.initial());
        mockTrustedContactsNotifier.setState(
          const TrustedContactsState(
            contacts: [],
            isLoading: false,
            isAdding: false,
            isUpdating: false,
            isRemoving: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Tap SOS button
        await tester.tap(find.text('SOS'));
        await tester.pumpAndSettle();

        // Confirm SOS
        await tester.tap(find.text('YES, SEND SOS'));
        await tester.pumpAndSettle();

        // Verify state updated with active alert
        expect(mockSafetyNotifier.state.activeAlerts, isNotEmpty);
      });

      testWidgets('cancels SOS when dialog is dismissed', (tester) async {
        mockSafetyNotifier.setState(SafetyState.initial());
        mockTrustedContactsNotifier.setState(
          const TrustedContactsState(
            contacts: [],
            isLoading: false,
            isAdding: false,
            isUpdating: false,
            isRemoving: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Tap SOS button
        await tester.tap(find.text('SOS'));
        await tester.pumpAndSettle();

        // Cancel SOS
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Verify no alert was created
        expect(mockSafetyNotifier.state.activeAlerts, isEmpty);
      });

      testWidgets('shows success dialog after SOS is sent', (tester) async {
        mockSafetyNotifier.setState(SafetyState.initial());
        mockTrustedContactsNotifier.setState(
          const TrustedContactsState(
            contacts: [],
            isLoading: false,
            isAdding: false,
            isUpdating: false,
            isRemoving: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Tap SOS button
        await tester.tap(find.text('SOS'));
        await tester.pumpAndSettle();

        // Confirm SOS
        await tester.tap(find.text('YES, SEND SOS'));
        await tester.pumpAndSettle();

        expect(find.text('SOS Sent!'), findsOneWidget);
        expect(
          find.text(
            'Your emergency alert has been sent to your trusted contacts with your current location.',
          ),
          findsOneWidget,
        );
      });
    });

    group('Active Emergency Actions', () {
      testWidgets('shows cancel alert button when emergency is active',
          (tester) async {
        final activeAlert = SafetyAlert(
          id: 'alert-1',
          type: SafetyAlertType.emergency,
          status: SafetyAlertStatus.active,
          userId: 'user-123',
          location: SafetyAlertLocation(
            latitude: 37.7749,
            longitude: -122.4194,
            timestamp: DateTime.now(),
          ),
          triggeredAt: DateTime.now(),
        );

        mockSafetyNotifier.setState(
          SafetyState(
            currentStatus: null,
            recentAlerts: const [],
            activeAlerts: [activeAlert],
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        mockTrustedContactsNotifier.setState(
          const TrustedContactsState(
            contacts: [],
            isLoading: false,
            isAdding: false,
            isUpdating: false,
            isRemoving: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Cancel Emergency Alert'), findsOneWidget);
      });

      testWidgets('cancels alert when button is pressed', (tester) async {
        final activeAlert = SafetyAlert(
          id: 'alert-1',
          type: SafetyAlertType.emergency,
          status: SafetyAlertStatus.active,
          userId: 'user-123',
          location: SafetyAlertLocation(
            latitude: 37.7749,
            longitude: -122.4194,
            timestamp: DateTime.now(),
          ),
          triggeredAt: DateTime.now(),
        );

        mockSafetyNotifier.setState(
          SafetyState(
            currentStatus: null,
            recentAlerts: const [],
            activeAlerts: [activeAlert],
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        mockTrustedContactsNotifier.setState(
          const TrustedContactsState(
            contacts: [],
            isLoading: false,
            isAdding: false,
            isUpdating: false,
            isRemoving: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Tap cancel button
        await tester.tap(find.text('Cancel Emergency Alert'));
        await tester.pumpAndSettle();

        // Confirm cancel
        await tester.tap(find.text('Yes, Cancel Alert'));
        await tester.pumpAndSettle();

        // Verify alert was removed
        expect(mockSafetyNotifier.state.activeAlerts, isEmpty);
      });
    });

    group('Location Handling', () {
      testWidgets('shows loading indicator while fetching location',
          (tester) async {
        when(() => mockLocationService.getCurrentLocation(
              accuracy: any(named: 'accuracy'),
            )).thenAnswer((_) => Future.delayed(
              const Duration(seconds: 1),
              () => LocationData(
                latitude: 37.7749,
                longitude: -122.4194,
                accuracy: 10.0,
                altitude: 0.0,
                timestamp: DateTime.now(),
              ),
            ));

        mockSafetyNotifier.setState(SafetyState.initial());
        mockTrustedContactsNotifier.setState(
          const TrustedContactsState(
            contacts: [],
            isLoading: false,
            isAdding: false,
            isUpdating: false,
            isRemoving: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        expect(find.text('Getting your location...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('shows error when location fetch fails', (tester) async {
        when(() => mockLocationService.getCurrentLocation(
              accuracy: any(named: 'accuracy'),
            )).thenThrow(Exception('Location permission denied'));

        mockSafetyNotifier.setState(SafetyState.initial());
        mockTrustedContactsNotifier.setState(
          const TrustedContactsState(
            contacts: [],
            isLoading: false,
            isAdding: false,
            isUpdating: false,
            isRemoving: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Location Unavailable'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('refreshes location when retry is tapped', (tester) async {
        when(() => mockLocationService.getCurrentLocation(
              accuracy: any(named: 'accuracy'),
            )).thenThrow(Exception('Location permission denied'));

        mockSafetyNotifier.setState(SafetyState.initial());
        mockTrustedContactsNotifier.setState(
          const TrustedContactsState(
            contacts: [],
            isLoading: false,
            isAdding: false,
            isUpdating: false,
            isRemoving: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Tap retry
        await tester.tap(find.text('Retry'));
        await tester.pump();

        // Verify location service was called again
        verify(() => mockLocationService.getCurrentLocation(
              accuracy: any(named: 'accuracy'),
            )).called(2);
      });
    });

    group('Message Input', () {
      testWidgets('allows entering optional message', (tester) async {
        mockSafetyNotifier.setState(SafetyState.initial());
        mockTrustedContactsNotifier.setState(
          const TrustedContactsState(
            contacts: [],
            isLoading: false,
            isAdding: false,
            isUpdating: false,
            isRemoving: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField),
          'I need help!',
        );

        expect(find.text('I need help!'), findsOneWidget);
      });
    });

    group('App Bar', () {
      testWidgets('shows info button when emergency is active', (tester) async {
        final activeAlert = SafetyAlert(
          id: 'alert-1',
          type: SafetyAlertType.emergency,
          status: SafetyAlertStatus.active,
          userId: 'user-123',
          location: SafetyAlertLocation(
            latitude: 37.7749,
            longitude: -122.4194,
            timestamp: DateTime.now(),
          ),
          triggeredAt: DateTime.now(),
        );

        mockSafetyNotifier.setState(
          SafetyState(
            currentStatus: null,
            recentAlerts: const [],
            activeAlerts: [activeAlert],
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        mockTrustedContactsNotifier.setState(
          const TrustedContactsState(
            contacts: [],
            isLoading: false,
            isAdding: false,
            isUpdating: false,
            isRemoving: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.info_outline), findsOneWidget);
      });

      testWidgets('shows alert details when info button is tapped',
          (tester) async {
        final activeAlert = SafetyAlert(
          id: 'alert-1',
          type: SafetyAlertType.emergency,
          status: SafetyAlertStatus.active,
          userId: 'user-123',
          location: SafetyAlertLocation(
            latitude: 37.7749,
            longitude: -122.4194,
            accuracy: 10.0,
            timestamp: DateTime.now(),
          ),
          triggeredAt: DateTime.now().subtract(const Duration(minutes: 5)),
          batteryLevel: 85,
        );

        mockSafetyNotifier.setState(
          SafetyState(
            currentStatus: null,
            recentAlerts: const [],
            activeAlerts: [activeAlert],
            isLoading: false,
            isProcessing: false,
            error: null,
          ),
        );

        mockTrustedContactsNotifier.setState(
          const TrustedContactsState(
            contacts: [],
            isLoading: false,
            isAdding: false,
            isUpdating: false,
            isRemoving: false,
            error: null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Tap info button
        await tester.tap(find.byIcon(Icons.info_outline));
        await tester.pumpAndSettle();

        expect(find.text('Alert Details'), findsOneWidget);
      });
    });
  });
}
