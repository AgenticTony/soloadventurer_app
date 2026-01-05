import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/app/app.dart';
import 'package:soloadventurer/core/services/location_service.dart';
import 'package:soloadventurer/features/safety/data/datasources/mock_safety_remote_data_source.dart';
import 'package:soloadventurer/features/safety/data/repositories/safety_repository_impl.dart';
import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_status.dart';
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';
import 'package:soloadventurer/features/safety/domain/usecases/add_trusted_contact.dart';
import 'package:soloadventurer/features/safety/domain/usecases/complete_check_in.dart';
import 'package:soloadventurer/features/safety/domain/usecases/create_check_in.dart';
import 'package:soloadventurer/features/safety/domain/usecases/schedule_check_in.dart';
import 'package:soloadventurer/features/safety/domain/usecases/share_location.dart';
import 'package:soloadventurer/features/safety/domain/usecases/stop_location_sharing.dart';
import 'package:soloadventurer/features/safety/domain/usecases/trigger_emergency_sos.dart';
import 'package:soloadventurer/features/safety/domain/usecases/update_safety_status.dart';
import 'package:soloadventurer/features/safety/infrastructure/services/missed_checkin_detector.dart';
import 'package:soloadventurer/features/safety/presentation/notifiers/check_in_notifier.dart';
import 'package:soloadventurer/features/safety/presentation/notifiers/location_sharing_notifier.dart';
import 'package:soloadventurer/features/safety/presentation/notifiers/safety_notifier.dart';
import 'package:soloadventurer/features/safety/presentation/notifiers/trusted_contacts_notifier.dart';
import 'package:soloadventurer/features/safety/presentation/providers/safety_providers.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import '../../test/helpers/safety_test_helpers.dart';

// Mock classes
class MockLocationService extends Mock implements LocationService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockSafetyRemoteDataSource mockRemoteDataSource;
  late MockLocationService mockLocationService;
  late SafetyRepositoryImpl repository;
  late MissedCheckInDetectorImpl missedCheckInDetector;

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

    // Initialize mock services
    mockRemoteDataSource = MockSafetyRemoteDataSource();
    mockLocationService = MockLocationService();

    // Register fallback values for mocktail
    registerFallbackValue(const Duration(minutes: 5));
    registerFallbackValue(testLocation);

    // Setup location service mock defaults
    when(() => mockLocationService.getCurrentLocation(accuracyLevel: any(named: 'accuracyLevel')))
        .thenAnswer((_) async => testLocation);
    when(() => mockLocationService.checkPermission())
        .thenAnswer((_) async => true);
    when(() => mockLocationService.isLocationServiceEnabled())
        .thenAnswer((_) async => true);

    // Setup remote data source mock defaults
    when(() => mockRemoteDataSource.getTrustedContacts(userId: any(named: 'userId')))
        .thenAnswer((_) async => []);
    when(() => mockRemoteDataSource.addTrustedContact(
      userId: any(named: 'userId'),
      name: any(named: 'name'),
      phoneNumber: any(named: 'phoneNumber'),
      email: any(named: 'email'),
      source: any(named: 'source'),
      permission: any(named: 'permission'),
      locationSharingEnabled: any(named: 'locationSharingEnabled'),
      receivesCheckIns: any(named: 'receivesCheckIns'),
      receivesEmergencyAlerts: any(named: 'receivesEmergencyAlerts'),
      notes: any(named: 'notes'),
    )).thenAnswer((_) async => createTestTrustedContact());

    when(() => mockRemoteDataSource.createCheckIn(
      userId: any(named: 'userId'),
      triggerType: any(named: 'triggerType'),
      scheduledTime: any(named: 'scheduledTime'),
      location: any(named: 'location'),
      statusMessage: any(named: 'statusMessage'),
      notifyContactIds: any(named: 'notifyContactIds'),
      tripId: any(named: 'tripId'),
    )).thenAnswer((_) async => createTestCheckIn());

    when(() => mockRemoteDataSource.triggerEmergencySOS(
      userId: any(named: 'userId'),
      message: any(named: 'message'),
      location: any(named: 'location'),
      notifyContactIds: any(named: 'notifyContactIds'),
      batteryLevel: any(named: 'batteryLevel'),
      tripId: any(named: 'tripId'),
    )).thenAnswer((_) async => createTestSafetyAlert());

    when(() => mockRemoteDataSource.updateSafetyStatus(
      userId: any(named: 'userId'),
      statusType: any(named: 'statusType'),
      message: any(named: 'message'),
      location: any(named: 'location'),
      batteryLevel: any(named: 'batteryLevel'),
      alertId: any(named: 'alertId'),
      checkInId: any(named: 'checkInId'),
    )).thenAnswer((_) async => createTestSafetyStatus());

    when(() => mockRemoteDataSource.shareLocation(
      userId: any(named: 'userId'),
      contactIds: any(named: 'contactIds'),
      latitude: any(named: 'latitude'),
      longitude: any(named: 'longitude'),
      accuracy: any(named: 'accuracy'),
      altitude: any(named: 'altitude'),
      address: any(named: 'address'),
      placeName: any(named: 'placeName'),
      batteryLevel: any(named: 'batteryLevel'),
      emergency: any(named: 'emergency'),
      checkInId: any(named: 'checkInId'),
      alertId: any(named: 'alertId'),
    )).thenAnswer((_) async => createTestLocationUpdate());

    // Initialize repository and detector
    repository = SafetyRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: getIt(),
    );

    missedCheckInDetector = MissedCheckInDetectorImpl(
      repository: repository,
      notificationService: getIt(),
    );

    // Create container with provider overrides
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        locationServiceOverrideProvider.overrideWithValue(mockLocationService),
        safetyRepositoryProvider.overrideWithValue(repository),
        missedCheckInDetectorProvider.overrideWithValue(missedCheckInDetector),
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
      final contactsNotifier = container.read(trustedContactsNotifierProvider.notifier);

      // Test 1: Add a trusted contact
      final newContact = createTestTrustedContact(
        name: 'Jane Doe',
        phoneNumber: '+1555012345',
        email: 'jane@example.com',
        permission: ContactPermission.fullAccess,
      );

      when(() => mockRemoteDataSource.addTrustedContact(
        userId: any(named: 'userId'),
        name: any(named: 'name'),
        phoneNumber: any(named: 'phoneNumber'),
        email: any(named: 'email'),
        source: any(named: 'source'),
        permission: any(named: 'permission'),
        locationSharingEnabled: any(named: 'locationSharingEnabled'),
        receivesCheckIns: any(named: 'receivesCheckIns'),
        receivesEmergencyAlerts: any(named: 'receivesEmergencyAlerts'),
        notes: any(named: 'notes'),
      )).thenAnswer((_) async => newContact);

      when(() => mockRemoteDataSource.getTrustedContacts(userId: any(named: 'userId')))
          .thenAnswer((_) async => [newContact]);

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
      expect(container.read(trustedContactsNotifierProvider).contacts, contains(newContact));
      expect(container.read(trustedContactsNotifierProvider).contacts.length, 1);

      // Test 2: Update trusted contact preferences
      final updatedContact = newContact.copyWith(
        locationSharingEnabled: true,
        receivesEmergencyAlerts: false,
      );

      when(() => mockRemoteDataSource.updateTrustedContact(
        id: any(named: 'id'),
        name: any(named: 'name'),
        phoneNumber: any(named: 'phoneNumber'),
        email: any(named: 'email'),
        source: any(named: 'source'),
        permission: any(named: 'permission'),
        locationSharingEnabled: any(named: 'locationSharingEnabled'),
        receivesCheckIns: any(named: 'receivesCheckIns'),
        receivesEmergencyAlerts: any(named: 'receivesEmergencyAlerts'),
        notes: any(named: 'notes'),
      )).thenAnswer((_) async => updatedContact);

      when(() => mockRemoteDataSource.getTrustedContacts(userId: any(named: 'userId')))
          .thenAnswer((_) async => [updatedContact]);

      await contactsNotifier.updateContact(
        id: updatedContact.id,
        locationSharingEnabled: true,
        receivesEmergencyAlerts: false,
      );

      await tester.pumpAndSettle();

      // Verify contact was updated
      final state = container.read(trustedContactsNotifierProvider);
      expect(state.contacts.first.locationSharingEnabled, true);
      expect(state.contacts.first.receivesEmergencyAlerts, false);

      // Test 3: Remove trusted contact
      when(() => mockRemoteDataSource.removeTrustedContact(id: any(named: 'id')))
          .thenAnswer((_) async {});
      when(() => mockRemoteDataSource.getTrustedContacts(userId: any(named: 'userId')))
          .thenAnswer((_) async => []);

      await contactsNotifier.removeContact(updatedContact.id);
      await tester.pumpAndSettle();

      // Verify contact was removed
      expect(container.read(trustedContactsNotifierProvider).contacts, isEmpty);
    });

    testWidgets('Complete manual check-in flow', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      final checkInNotifier = container.read(checkInNotifierProvider.notifier);

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

      final newCheckIn = createTestCheckIn(
        triggerType: CheckInTriggerType.manual,
        status: CheckInStatus.completed,
        location: checkInLocation,
        statusMessage: 'I arrived safely!',
        completedAt: DateTime.now(),
      );

      when(() => mockRemoteDataSource.createCheckIn(
        userId: any(named: 'userId'),
        triggerType: any(named: 'triggerType'),
        scheduledTime: any(named: 'scheduledTime'),
        location: any(named: 'location'),
        statusMessage: any(named: 'statusMessage'),
        notifyContactIds: any(named: 'notifyContactIds'),
        tripId: any(named: 'tripId'),
      )).thenAnswer((_) async => newCheckIn);

      when(() => mockRemoteDataSource.completeCheckIn(
        id: any(named: 'id'),
        location: any(named: 'location'),
        statusMessage: any(named: 'statusMessage'),
        batteryLevel: any(named: 'batteryLevel'),
      )).thenAnswer((_) async => newCheckIn);

      when(() => mockRemoteDataSource.getAllCheckIns(userId: any(named: 'userId')))
          .thenAnswer((_) async => [newCheckIn]);

      await checkInNotifier.createManualCheckIn(
        location: checkInLocation,
        statusMessage: 'I arrived safely!',
        notifyContactIds: [testContactId],
      );

      await tester.pumpAndSettle();

      // Verify check-in was created
      final checkIns = container.read(checkInNotifierProvider).checkIns;
      expect(checkIns, isNotEmpty);
      expect(checkIns.first.status, CheckInStatus.completed);
      expect(checkIns.first.statusMessage, 'I arrived safely!');
      expect(checkIns.first.location?.placeName, 'Times Square');
    });

    testWidgets('Complete scheduled check-in flow', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      final checkInNotifier = container.read(checkInNotifierProvider.notifier);

      // Test: Schedule a check-in for later
      final scheduledTime = DateTime.now().add(const Duration(hours: 2));
      final deadline = scheduledTime.add(const Duration(minutes: 30));

      final scheduledCheckIn = createTestCheckIn(
        triggerType: CheckInTriggerType.scheduled,
        status: CheckInStatus.scheduled,
        scheduledTime: scheduledTime,
        deadline: deadline,
        statusMessage: 'Check-in during my hike',
      );

      when(() => mockRemoteDataSource.scheduleCheckIn(
        userId: any(named: 'userId'),
        scheduledTime: any(named: 'scheduledTime'),
        deadline: any(named: 'deadline'),
        location: any(named: 'location'),
        statusMessage: any(named: 'statusMessage'),
        notifyContactIds: any(named: 'notifyContactIds'),
        tripId: any(named: 'tripId'),
        triggerType: any(named: 'triggerType'),
      )).thenAnswer((_) async => scheduledCheckIn);

      when(() => mockRemoteDataSource.getUpcomingCheckIns(userId: any(named: 'userId')))
          .thenAnswer((_) async => [scheduledCheckIn]);

      await checkInNotifier.scheduleCheckIn(
        scheduledTime: scheduledTime,
        deadline: deadline,
        statusMessage: 'Check-in during my hike',
        notifyContactIds: [testContactId],
      );

      await tester.pumpAndSettle();

      // Verify check-in was scheduled
      final upcomingCheckIns = container.read(checkInNotifierProvider).upcomingCheckIns;
      expect(upcomingCheckIns, isNotEmpty);
      expect(upcomingCheckIns.first.status, CheckInStatus.scheduled);
      expect(upcomingCheckIns.first.scheduledTime, scheduledTime);
      expect(upcomingCheckIns.first.deadline, deadline);
    });

    testWidgets('Complete emergency SOS flow', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      final safetyNotifier = container.read(safetyNotifierProvider.notifier);

      // Test: Trigger emergency SOS with location and message
      final emergencyLocation = SafetyAlertLocation(
        latitude: 40.7128,
        longitude: -74.0060,
        accuracy: 10.0,
        altitude: 100.0,
        address: 'Central Park, New York, NY',
        timestamp: DateTime.now(),
      );

      final emergencyAlert = createTestSafetyAlert(
        type: SafetyAlertType.emergencySOS,
        status: SafetyAlertStatus.sent,
        message: 'Need help immediately!',
        location: emergencyLocation,
        batteryLevel: 75,
      );

      when(() => mockRemoteDataSource.triggerEmergencySOS(
        userId: any(named: 'userId'),
        message: any(named: 'message'),
        location: any(named: 'location'),
        notifyContactIds: any(named: 'notifyContactIds'),
        batteryLevel: any(named: 'batteryLevel'),
        tripId: any(named: 'tripId'),
      )).thenAnswer((_) async => emergencyAlert);

      when(() => mockRemoteDataSource.getSafetyAlerts(userId: any(named: 'userId')))
          .thenAnswer((_) async => [emergencyAlert]);

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
      expect(safetyState.activeAlerts.first.type, SafetyAlertType.emergencySOS);
      expect(safetyState.activeAlerts.first.status, SafetyAlertStatus.sent);
      expect(safetyState.activeAlerts.first.message, 'Need help immediately!');
    });

    testWidgets('Complete safety status update flow', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      final safetyNotifier = container.read(safetyNotifierProvider.notifier);

      // Test: Update safety status to "Need Help"
      final statusLocation = SafetyStatusLocation(
        latitude: 40.7128,
        longitude: -74.0060,
        accuracy: 10.0,
        timestamp: DateTime.now(),
      );

      final safetyStatus = SafetyStatus(
        id: 'status-123',
        userId: testUserId,
        statusType: SafetyStatusType.needHelp,
        message: 'I need some assistance',
        location: statusLocation,
        batteryLevel: 60,
        createdAt: DateTime.now(),
      );

      when(() => mockRemoteDataSource.updateSafetyStatus(
        userId: any(named: 'userId'),
        statusType: any(named: 'statusType'),
        message: any(named: 'message'),
        location: any(named: 'location'),
        batteryLevel: any(named: 'batteryLevel'),
        alertId: any(named: 'alertId'),
        checkInId: any(named: 'checkInId'),
      )).thenAnswer((_) async => safetyStatus);

      when(() => mockRemoteDataSource.getCurrentSafetyStatus(userId: any(named: 'userId')))
          .thenAnswer((_) async => safetyStatus);

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
      expect(currentStatus!.statusType, SafetyStatusType.needHelp);
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

      final locationSharingNotifier = container.read(locationSharingNotifierProvider.notifier);

      // Test: Start location sharing with contacts
      final locationUpdate = createTestLocationUpdate(
        latitude: 40.7128,
        longitude: -74.0060,
        address: 'Empire State Building, New York, NY',
        placeName: 'Empire State Building',
        batteryLevel: 80,
      );

      when(() => mockRemoteDataSource.shareLocation(
        userId: any(named: 'userId'),
        contactIds: any(named: 'contactIds'),
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        accuracy: any(named: 'accuracy'),
        altitude: any(named: 'altitude'),
        address: any(named: 'address'),
        placeName: any(named: 'placeName'),
        batteryLevel: any(named: 'batteryLevel'),
        emergency: any(named: 'emergency'),
        checkInId: any(named: 'checkInId'),
        alertId: any(named: 'alertId'),
      )).thenAnswer((_) async => locationUpdate);

      when(() => mockRemoteDataSource.getActiveLocationShares(userId: any(named: 'userId')))
          .thenAnswer((_) async => [locationUpdate]);

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
      final activeShares = container.read(locationSharingNotifierProvider).activeShares;
      expect(activeShares, isNotEmpty);
      expect(activeShares.first.address, 'Empire State Building, New York, NY');

      // Test: Stop location sharing
      when(() => mockRemoteDataSource.stopLocationSharing(
        userId: any(named: 'userId'),
        contactIds: any(named: 'contactIds'),
      )).thenAnswer((_) async {});

      when(() => mockRemoteDataSource.getActiveLocationShares(userId: any(named: 'userId')))
          .thenAnswer((_) async => []);

      await locationSharingNotifier.stopLocationSharing(
        contactIds: [testContactId],
      );

      await tester.pumpAndSettle();

      // Verify location sharing stopped
      expect(container.read(locationSharingNotifierProvider).activeShares, isEmpty);
    });

    testWidgets('Missed check-in detection and alert flow', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Test: Create a scheduled check-in that will be missed
      final pastTime = DateTime.now().subtract(const Duration(hours: 2));
      final pastDeadline = DateTime.now().subtract(const Duration(hours: 1));

      final missedCheckIn = createTestCheckIn(
        id: 'missed-checkin-123',
        status: CheckInStatus.scheduled,
        scheduledTime: pastTime,
        deadline: pastDeadline,
        statusMessage: 'Check-in during hike',
      );

      // Setup mocks for missed check-in detection
      when(() => mockRemoteDataSource.getUpcomingCheckIns(userId: any(named: 'userId')))
          .thenAnswer((_) async => [missedCheckIn]);

      when(() => mockRemoteDataSource.getSafetyAlerts(userId: any(named: 'userId')))
          .thenAnswer((_) async => []);

      when(() => mockRemoteDataSource.triggerEmergencySOS(
        userId: any(named: 'userId'),
        message: any(named: 'message'),
        location: any(named: 'location'),
        notifyContactIds: any(named: 'notifyContactIds'),
        batteryLevel: any(named: 'batteryLevel'),
        tripId: any(named: 'tripId'),
        checkInId: any(named: 'checkInId'),
      )).thenAnswer((_) async => createTestSafetyAlert(
        id: 'missed-alert-123',
        type: SafetyAlertType.missedCheckIn,
        status: SafetyAlertStatus.sent,
        checkInId: missedCheckIn.id,
        message: 'Missed check-in alert',
      ));

      when(() => mockRemoteDataSource.updateCheckInStatus(
        id: any(named: 'id'),
        status: any(named: 'status'),
      )).thenAnswer((_) async => missedCheckIn.copyWith(
        status: CheckInStatus.missed,
        alertSent: true,
        alertSentAt: DateTime.now(),
      ));

      // Run missed check-in detection
      final detector = container.read(missedCheckInDetectorProvider);
      final result = await detector.detectAndAlertMissedCheckIns(testUserId);

      await tester.pumpAndSettle();

      // Verify missed check-in was detected and alert was triggered
      expect(result.detectedCount, 1);
      expect(result.alertsTriggered, 1);
      expect(result.success, true);
    });

    testWidgets('Complete multi-step safety workflow', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      final contactsNotifier = container.read(trustedContactsNotifierProvider.notifier);
      final checkInNotifier = container.read(checkInNotifierProvider.notifier);
      final safetyNotifier = container.read(safetyNotifierProvider.notifier);
      final locationSharingNotifier = container.read(locationSharingNotifierProvider.notifier);

      // Step 1: Add trusted contacts
      final contact1 = createTestTrustedContact(
        id: 'contact-1',
        name: 'Alice Johnson',
        phoneNumber: '+1555011111',
      );
      final contact2 = createTestTrustedContact(
        id: 'contact-2',
        name: 'Bob Smith',
        phoneNumber: '+1555022222',
      );

      when(() => mockRemoteDataSource.addTrustedContact(
        userId: any(named: 'userId'),
        name: any(named: 'name'),
        phoneNumber: any(named: 'phoneNumber'),
        email: any(named: 'email'),
        source: any(named: 'source'),
        permission: any(named: 'permission'),
        locationSharingEnabled: any(named: 'locationSharingEnabled'),
        receivesCheckIns: any(named: 'receivesCheckIns'),
        receivesEmergencyAlerts: any(named: 'receivesEmergencyAlerts'),
        notes: any(named: 'notes'),
      )).thenAnswer((_) async => contact1);

      when(() => mockRemoteDataSource.getTrustedContacts(userId: any(named: 'userId')))
          .thenAnswer((_) async => [contact1, contact2]);

      await contactsNotifier.addContact(
        name: contact1.name,
        phoneNumber: contact1.phoneNumber,
      );
      await contactsNotifier.addContact(
        name: contact2.name,
        phoneNumber: contact2.phoneNumber,
      );
      await tester.pumpAndSettle();

      // Step 2: Share location with contacts
      final locationUpdate = createTestLocationUpdate();

      when(() => mockRemoteDataSource.shareLocation(
        userId: any(named: 'userId'),
        contactIds: any(named: 'contactIds'),
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        accuracy: any(named: 'accuracy'),
        altitude: any(named: 'altitude'),
        address: any(named: 'address'),
        placeName: any(named: 'placeName'),
        batteryLevel: any(named: 'batteryLevel'),
        emergency: any(named: 'emergency'),
        checkInId: any(named: 'checkInId'),
        alertId: any(named: 'alertId'),
      )).thenAnswer((_) async => locationUpdate);

      when(() => mockRemoteDataSource.getActiveLocationShares(userId: any(named: 'userId')))
          .thenAnswer((_) async => [locationUpdate]);

      await locationSharingNotifier.shareLocation(
        contactIds: [contact1.id, contact2.id],
        latitude: 40.7128,
        longitude: -74.0060,
      );
      await tester.pumpAndSettle();

      // Step 3: Schedule a check-in
      final scheduledCheckIn = createTestCheckIn(
        status: CheckInStatus.scheduled,
        scheduledTime: DateTime.now().add(const Duration(hours: 3)),
      );

      when(() => mockRemoteDataSource.scheduleCheckIn(
        userId: any(named: 'userId'),
        scheduledTime: any(named: 'scheduledTime'),
        deadline: any(named: 'deadline'),
        location: any(named: 'location'),
        statusMessage: any(named: 'statusMessage'),
        notifyContactIds: any(named: 'notifyContactIds'),
        tripId: any(named: 'tripId'),
        triggerType: any(named: 'triggerType'),
      )).thenAnswer((_) async => scheduledCheckIn);

      when(() => mockRemoteDataSource.getUpcomingCheckIns(userId: any(named: 'userId')))
          .thenAnswer((_) async => [scheduledCheckIn]);

      await checkInNotifier.scheduleCheckIn(
        scheduledTime: DateTime.now().add(const Duration(hours: 3)),
        deadline: DateTime.now().add(const Duration(hours: 4)),
        notifyContactIds: [contact1.id, contact2.id],
      );
      await tester.pumpAndSettle();

      // Step 4: Complete the check-in
      final completedCheckIn = scheduledCheckIn.copyWith(
        status: CheckInStatus.completed,
        completedAt: DateTime.now(),
        statusMessage: 'Safe and sound!',
      );

      when(() => mockRemoteDataSource.completeCheckIn(
        id: any(named: 'id'),
        location: any(named: 'location'),
        statusMessage: any(named: 'statusMessage'),
        batteryLevel: any(named: 'batteryLevel'),
      )).thenAnswer((_) async => completedCheckIn);

      when(() => mockRemoteDataSource.getAllCheckIns(userId: any(named: 'userId')))
          .thenAnswer((_) async => [completedCheckIn]);

      await checkInNotifier.completeCheckIn(
        id: scheduledCheckIn.id,
        statusMessage: 'Safe and sound!',
      );
      await tester.pumpAndSettle();

      // Verify complete workflow
      expect(container.read(trustedContactsNotifierProvider).contacts.length, 2);
      expect(container.read(locationSharingNotifierProvider).activeShares, isNotEmpty);
      expect(container.read(checkInNotifierProvider).checkIns.first.status, CheckInStatus.completed);

      // Step 5: Stop location sharing
      when(() => mockRemoteDataSource.stopLocationSharing(
        userId: any(named: 'userId'),
        contactIds: any(named: 'contactIds'),
      )).thenAnswer((_) async {});

      when(() => mockRemoteDataSource.getActiveLocationShares(userId: any(named: 'userId')))
          .thenAnswer((_) async => []);

      await locationSharingNotifier.stopLocationSharing(
        contactIds: [contact1.id, contact2.id],
      );
      await tester.pumpAndSettle();

      expect(container.read(locationSharingNotifierProvider).activeShares, isEmpty);
    });
  });
}
