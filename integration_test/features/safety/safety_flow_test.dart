import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/app/app.dart';
import 'package:soloadventurer/core/providers/core_providers.dart' show sharedPreferencesProvider;
import 'package:soloadventurer/core/api/client/api_client.dart';
import 'package:soloadventurer/features/safety/data/datasources/mock_safety_remote_data_source.dart';
import 'package:soloadventurer/features/safety/data/repositories/safety_repository_impl.dart';
import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_status.dart';
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';
import 'package:soloadventurer/features/safety/presentation/providers/safety_providers.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import '../../test_helpers.dart';
import '../../../test/helpers/safety_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockSafetyRemoteDataSource mockRemoteDataSource;
  late SafetyRepositoryImpl repository;

  // Test data
  const testUserId = 'test-user-123';
  final testLocation = CheckInLocation(
    latitude: 40.7128,
    longitude: -74.0060,
    accuracy: 10.0,
    altitude: 100.0,
    timestamp: DateTime.now(),
  );

  setUp(() async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Initialize service locator in test mode
    await setupServiceLocator(isTest: true);

    // Initialize mock data source with API client
    final apiClient = ApiClient(
      baseUrl: 'https://api.test.com',
    );
    mockRemoteDataSource = MockSafetyRemoteDataSource(apiClient);

    // Initialize repository
    repository = SafetyRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: getIt(),
    );

    // Create container with provider overrides
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        safetyRepositoryProvider.overrideWithValue(repository),
      ],
    );
  });

  tearDown(() async {
    await resetServiceLocator();
    container.dispose();
  });

  group('Safety Flow Integration Tests', () {
    testWidgets('Complete trusted contacts CRUD flow', (tester) async {
      // Build app
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Read notifiers
      final contactsNotifier = container.read(trustedContactsNotifierProvider);

      // Test 1: Add a trusted contact
      final newContact = createTestTrustedContact(
        name: 'Jane Doe',
        phoneNumber: '+1555012345',
        email: 'jane@example.com',
        permission: ContactPermission.fullAccess,
      );

      await contactsNotifier.addContact(
        name: newContact.name,
        phoneNumber: newContact.phoneNumber,
        email: newContact.email,
        source: newContact.source,
        permission: newContact.permission,
        locationSharingEnabled: newContact.locationSharingEnabled,
        receivesCheckIns: newContact.receivesCheckIns,
        receivesEmergencyAlerts: newContact.receivesEmergencyAlerts,
        notes: newContact.notes,
      );

      await tester.pumpAndSettle();

      // Verify contact was added
      expect(
          container.read(trustedContactsNotifierProvider).state.contacts,
          contains(predicate((TrustedContact c) => c.name == 'Jane Doe')));
      expect(
          container.read(trustedContactsNotifierProvider).state.contacts.length,
          greaterThanOrEqualTo(1));
    });

    testWidgets('Complete manual check-in flow', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      final checkInNotifier = container.read(checkInNotifierProvider);

      // Test: Create manual check-in with location
      final checkInLocation = CheckInLocation(
        latitude: 40.7128,
        longitude: -74.0060,
        accuracy: 10.0,
        altitude: 100.0,
        address: 'New York, NY',
        placeName: 'Times Square',
        timestamp: DateTime.now(),
      );

      await checkInNotifier.createManualCheckIn(
        location: checkInLocation,
        statusMessage: 'I arrived safely!',
        notifyContactIds: [testContactId],
      );

      await tester.pumpAndSettle();

      // Verify check-in was created
      final checkIns = container.read(checkInNotifierProvider).state.checkIns;
      expect(checkIns, isNotEmpty);
      expect(
          checkIns.any((c) => c.statusMessage == 'I arrived safely!'), true);
    });

    testWidgets('Complete scheduled check-in flow', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      final checkInNotifier = container.read(checkInNotifierProvider);

      // Test: Schedule a check-in for later
      final scheduledTime = DateTime.now().add(const Duration(hours: 2));
      final deadline = scheduledTime.add(const Duration(minutes: 30));

      await checkInNotifier.scheduleCheckIn(
        scheduledTime: scheduledTime,
        deadline: deadline,
        statusMessage: 'Check-in during my hike',
        notifyContactIds: [testContactId],
      );

      await tester.pumpAndSettle();

      // Verify check-in was scheduled
      final upcomingCheckIns =
          container.read(checkInNotifierProvider).state.upcomingCheckIns;
      expect(upcomingCheckIns, isNotEmpty);
      expect(
          upcomingCheckIns.any((c) => c.status == CheckInStatus.scheduled),
          true);
    });

    testWidgets('Complete emergency SOS flow', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      final safetyNotifier = container.read(safetyNotifierProvider);

      // Test: Trigger emergency SOS with location and message
      final emergencyLocation = SafetyAlertLocation(
        latitude: 40.7128,
        longitude: -74.0060,
        accuracy: 10.0,
        altitude: 100.0,
        address: 'Central Park, New York, NY',
        timestamp: DateTime.now(),
      );

      await safetyNotifier.triggerEmergencySOS(
        message: 'Need help immediately!',
        location: emergencyLocation,
        batteryLevel: 75,
        notifyContactIds: [testContactId],
      );

      await tester.pumpAndSettle();

      // Verify emergency was triggered
      final safetyState = container.read(safetyStateProvider);
      expect(safetyState.activeAlerts, isNotEmpty);
      expect(
          safetyState.activeAlerts.any((a) => a.type == SafetyAlertType.emergencySOS),
          true);
      expect(
          safetyState.activeAlerts.any((a) => a.message == 'Need help immediately!'),
          true);
    });

    testWidgets('Complete safety status update flow', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      final safetyNotifier = container.read(safetyNotifierProvider);

      // Test: Update safety status to "Need Help"
      final statusLocation = SafetyStatusLocation(
        latitude: 40.7128,
        longitude: -74.0060,
        accuracy: 10.0,
        timestamp: DateTime.now(),
      );

      await safetyNotifier.updateSafetyStatus(
        statusType: SafetyStatusType.needHelp,
        message: 'I need some assistance',
        location: statusLocation,
        batteryLevel: 60,
      );

      await tester.pumpAndSettle();

      // Verify safety status was updated
      final currentStatus = container.read(safetyStateProvider).currentStatus;
      expect(currentStatus, isNotNull);
      expect(currentStatus!.status, SafetyStatusType.needHelp);
      expect(currentStatus.message, 'I need some assistance');
    });

    testWidgets('Complete location sharing flow', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      final locationSharingNotifier =
          container.read(locationSharingNotifierProvider);

      // Test: Start location sharing with contacts
      await locationSharingNotifier.shareLocation(
        contactIds: [testContactId],
        latitude: 40.7128,
        longitude: -74.0060,
        address: 'Empire State Building, New York, NY',
        placeName: 'Empire State Building',
        batteryLevel: 80,
      );

      await tester.pumpAndSettle();

      // Verify location sharing started
      final activeShares =
          container.read(locationSharingNotifierProvider).state.activeShares;
      expect(activeShares, isNotEmpty);

      // Test: Stop location sharing
      await locationSharingNotifier.stopLocationSharing(
        contactIds: [testContactId],
      );

      await tester.pumpAndSettle();

      // Verify location sharing stopped
      expect(
          container.read(locationSharingNotifierProvider).state.activeShares,
          isEmpty);
    });

    testWidgets('Complete multi-step safety workflow', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      final contactsNotifier = container.read(trustedContactsNotifierProvider);
      final checkInNotifier = container.read(checkInNotifierProvider);
      final safetyNotifier = container.read(safetyNotifierProvider);
      final locationSharingNotifier =
          container.read(locationSharingNotifierProvider);

      // Step 1: Add trusted contacts
      final contact1 = createTestTrustedContact(
        id: 'contact-1',
        name: 'Alice Johnson',
        phoneNumber: '+1555011111',
      );

      await contactsNotifier.addContact(
        name: contact1.name,
        phoneNumber: contact1.phoneNumber,
      );
      await tester.pumpAndSettle();

      // Step 2: Share location with contacts
      await locationSharingNotifier.shareLocation(
        contactIds: [contact1.id],
        latitude: 40.7128,
        longitude: -74.0060,
      );
      await tester.pumpAndSettle();

      // Step 3: Schedule a check-in
      await checkInNotifier.scheduleCheckIn(
        scheduledTime: DateTime.now().add(const Duration(hours: 3)),
        deadline: DateTime.now().add(const Duration(hours: 4)),
        notifyContactIds: [contact1.id],
      );
      await tester.pumpAndSettle();

      // Step 4: Complete the check-in
      final scheduledCheckIns =
          container.read(checkInNotifierProvider).state.upcomingCheckIds;
      if (scheduledCheckIns.isNotEmpty) {
        await checkInNotifier.completeCheckIn(
          id: scheduledCheckIns.first,
          statusMessage: 'Safe and sound!',
        );
        await tester.pumpAndSettle();
      }

      // Verify workflow
      expect(
          container.read(trustedContactsNotifierProvider).state.contacts.length,
          greaterThanOrEqualTo(1));
      expect(
          container
              .read(locationSharingNotifierProvider)
              .state
              .activeShares
              .isNotEmpty,
          true);

      // Step 5: Stop location sharing
      await locationSharingNotifier.stopLocationSharing(
        contactIds: [contact1.id],
      );
      await tester.pumpAndSettle();

      expect(
          container.read(locationSharingNotifierProvider).state.activeShares,
          isEmpty);
    });
  });
}
