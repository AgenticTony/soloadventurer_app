import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/app/app.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_local_data_source.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_local_data_source_impl.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_remote_data_source.dart';
import 'package:soloadventurer/features/safety/data/repositories/safety_repository_impl.dart';
import 'package:soloadventurer/features/safety/data/repositories/safety_providers.dart';
import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import 'package:soloadventurer/features/safety/domain/entities/location_update.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_status.dart';
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';
import 'package:soloadventurer/features/safety/presentation/providers/safety_providers.dart';
import 'package:soloadventurer/app/providers/core_service_providers.dart';
import '../../../test/helpers/safety_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late SafetyRepositoryImpl repository;
  late SafetyLocalDataSource localDataSource;

  // Test data
  const testUserId = 'test-user-123';

  setUp(() async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Initialize local data source
    localDataSource = SafetyLocalDataSourceImpl(prefs);

    // Create a mock safety remote data source that doesn't require ApiClient
    // Using an in-memory implementation for testing
    final mockRemoteDataSource = _TestSafetyRemoteDataSource();

    // Initialize repository
    repository = SafetyRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: mockRemoteDataSource,
    );

    // Create container with provider overrides
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        safetyRepositoryOverrideProvider.overrideWithValue(repository),
      ],
    );
  });

  tearDown(() async {
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
      final contactsNotifier = container.read(trustedContactsProvider.notifier);

      // Test 1: Add a trusted contact
      final newContact = createTestTrustedContact(
        name: 'Jane Doe',
        phoneNumber: '+1555012345',
        email: 'jane@example.com',
        permission: ContactPermission.fullAccess,
      );

      await contactsNotifier.addContact(newContact);

      await tester.pumpAndSettle();

      // Verify contact was added - access state directly
      final state = container.read(trustedContactsProvider);
      expect(
          state.value?.contacts,
          contains(predicate((TrustedContact c) => c.name == 'Jane Doe')));
      expect(
          state.value?.contacts.length,
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

      final checkInNotifier = container.read(checkInProvider.notifier);

      // Test: Create manual check-in with location
      await checkInNotifier.createManualCheckIn(
        statusMessage: 'I arrived safely!',
        latitude: 40.7128,
        longitude: -74.0060,
      );

      await tester.pumpAndSettle();

      // Verify check-in was created
      final checkInState = container.read(checkInProvider);
      expect(checkInState.value?.checkIns, isNotEmpty);
      expect(
          checkInState.value?.checkIns.any((c) => c.statusMessage == 'I arrived safely!'), true);
    });

    testWidgets('Complete scheduled check-in flow', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      final checkInNotifier = container.read(checkInProvider.notifier);

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
      final checkInState = container.read(checkInProvider);
      expect(checkInState.value?.upcomingCheckIns, isNotEmpty);
      expect(
          checkInState.value?.upcomingCheckIns.any((c) => c.status == CheckInStatus.scheduled),
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

      final safetyNotifier = container.read(safetyProvider.notifier);

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
        userId: testUserId,
        message: 'Need help immediately!',
        location: emergencyLocation,
        batteryLevel: 75,
        notifyContactIds: [testContactId],
      );

      await tester.pumpAndSettle();

      // Verify emergency was triggered
      final safetyState = container.read(safetyProvider);
      expect(safetyState.value?.activeAlerts, isNotEmpty);
      expect(
          safetyState.value?.activeAlerts.any((a) => a.type == SafetyAlertType.emergencySOS),
          true);
      expect(
          safetyState.value?.activeAlerts.any((a) => a.message == 'Need help immediately!'),
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

      final safetyNotifier = container.read(safetyProvider.notifier);

      // Test: Update safety status to "Need Help"
      final statusLocation = SafetyStatusLocation(
        latitude: 40.7128,
        longitude: -74.0060,
        accuracy: 10.0,
        timestamp: DateTime.now(),
      );

      await safetyNotifier.updateSafetyStatus(
        status: SafetyStatusType.needHelp,
        message: 'I need some assistance',
        location: statusLocation,
        batteryLevel: 60,
      );

      await tester.pumpAndSettle();

      // Verify safety status was updated
      final safetyState = container.read(safetyProvider);
      final currentStatus = safetyState.value?.currentStatus;
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
          container.read(locationSharingProvider.notifier);

      // Test: Start location sharing with contacts
      await locationSharingNotifier.shareLocation(
        shareWithContactIds: [testContactId],
        latitude: 40.7128,
        longitude: -74.0060,
        address: 'Empire State Building, New York, NY',
        placeName: 'Empire State Building',
        batteryLevel: 80,
      );

      await tester.pumpAndSettle();

      // Verify location sharing started
      final locationSharingState = container.read(locationSharingProvider);
      expect(locationSharingState.value?.activeShares, isNotEmpty);

      // Test: Stop location sharing
      await locationSharingNotifier.stopSharing(
        [testContactId],
      );

      await tester.pumpAndSettle();

      // Verify location sharing stopped
      expect(
          container.read(locationSharingProvider).value?.activeShares,
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

      final contactsNotifier = container.read(trustedContactsProvider.notifier);
      final checkInNotifier = container.read(checkInProvider.notifier);
      final locationSharingNotifier =
          container.read(locationSharingProvider.notifier);

      // Step 1: Add trusted contacts
      final contact1 = createTestTrustedContact(
        id: 'contact-1',
        name: 'Alice Johnson',
        phoneNumber: '+1555011111',
      );

      await contactsNotifier.addContact(contact1);
      await tester.pumpAndSettle();

      // Step 2: Share location with contacts
      await locationSharingNotifier.shareLocation(
        shareWithContactIds: [contact1.id],
        latitude: 40.7128,
        longitude: -74.0060,
      );
      await tester.pumpAndSettle();

      // Step 3: Schedule a check-in
      await checkInNotifier.scheduleCheckIn(
        scheduledTime: DateTime.now().add(const Duration(hours: 3)),
        deadline: DateTime.now().add(const Duration(hours: 4)),
        statusMessage: 'Check-in during trip',
        notifyContactIds: [contact1.id],
      );
      await tester.pumpAndSettle();

      // Step 4: Complete the check-in
      final checkInState = container.read(checkInProvider);
      final upcomingCheckIns = checkInState.value?.upcomingCheckIns;
      if (upcomingCheckIns != null && upcomingCheckIns.isNotEmpty) {
        await checkInNotifier.completeCheckIn(
          checkInId: upcomingCheckIns.first.id,
          latitude: 40.7128,
          longitude: -74.0060,
          statusMessage: 'Safe and sound!',
        );
        await tester.pumpAndSettle();
      }

      // Verify workflow
      final contactsState = container.read(trustedContactsProvider);
      expect(contactsState.value?.contacts.length, greaterThanOrEqualTo(1));

      final locationSharingState = container.read(locationSharingProvider);
      expect(locationSharingState.value?.activeShares.isNotEmpty, true);

      // Step 5: Stop location sharing
      await locationSharingNotifier.stopSharing(
        [contact1.id],
      );
      await tester.pumpAndSettle();

      expect(
          container.read(locationSharingProvider).value?.activeShares,
          isEmpty);
    });
  });
}

/// Test implementation of SafetyRemoteDataSource that doesn't require ApiClient
/// This is a simplified in-memory implementation for integration testing
class _TestSafetyRemoteDataSource implements SafetyRemoteDataSource {
  final Map<String, TrustedContact> _contacts = {};
  final Map<String, CheckIn> _checkIns = {};
  final Map<String, LocationUpdate> _locationUpdates = {};
  final Map<String, SafetyAlert> _safetyAlerts = {};
  SafetyStatus? _currentSafetyStatus;

  String _generateId() {
    return 'test_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<TrustedContact> addTrustedContact(TrustedContact contact) async {
    final newContact = contact.copyWith(
      id: _generateId(),
      addedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _contacts[newContact.id] = newContact;
    return newContact;
  }

  @override
  Future<void> removeTrustedContact(String contactId) async {
    _contacts.remove(contactId);
  }

  @override
  Future<TrustedContact> updateTrustedContact(TrustedContact contact) async {
    _contacts[contact.id] = contact;
    return contact;
  }

  @override
  Future<List<TrustedContact>> getTrustedContacts() async {
    return _contacts.values.toList();
  }

  @override
  Future<TrustedContact> getTrustedContact(String contactId) async {
    final contact = _contacts[contactId];
    if (contact == null) throw Exception('Contact not found');
    return contact;
  }

  @override
  Future<CheckIn> createCheckIn(CheckIn checkIn) async {
    final newCheckIn = checkIn.copyWith(
      id: _generateId(),
      createdAt: DateTime.now(),
    );
    _checkIns[newCheckIn.id] = newCheckIn;
    return newCheckIn;
  }

  @override
  Future<CheckIn> completeCheckIn({
    required String checkInId,
    required CheckInLocation location,
    String? statusMessage,
  }) async {
    final checkIn = _checkIns[checkInId];
    if (checkIn == null) throw Exception('Check-in not found');
    final updated = checkIn.copyWith(
      status: CheckInStatus.completed,
      completedAt: DateTime.now(),
      location: location,
      statusMessage: statusMessage,
    );
    _checkIns[checkInId] = updated;
    return updated;
  }

  @override
  Future<CheckIn> scheduleCheckIn({
    required String userId,
    required DateTime scheduledTime,
    DateTime? deadline,
    CheckInLocation? location,
    String? statusMessage,
    List<String>? notifyContactIds,
    String? tripId,
    CheckInTriggerType? triggerType,
  }) async {
    final checkIn = CheckIn(
      id: _generateId(),
      userId: userId,
      triggerType: triggerType ?? CheckInTriggerType.scheduledTime,
      status: CheckInStatus.scheduled,
      scheduledTime: scheduledTime,
      deadline: deadline,
      location: location,
      statusMessage: statusMessage,
      notifyContactIds: notifyContactIds ?? [],
      tripId: tripId,
      createdAt: DateTime.now(),
    );
    _checkIns[checkIn.id] = checkIn;
    return checkIn;
  }

  @override
  Future<void> cancelCheckIn(String checkInId) async {
    final checkIn = _checkIns[checkInId];
    if (checkIn != null) {
      _checkIns[checkInId] = checkIn.copyWith(status: CheckInStatus.cancelled);
    }
  }

  @override
  Future<List<CheckIn>> getUpcomingCheckIns() async {
    return _checkIns.values.where((c) => c.status == CheckInStatus.scheduled).toList();
  }

  @override
  Future<List<CheckIn>> getAllCheckIns() async {
    return _checkIns.values.toList();
  }

  @override
  Future<CheckIn> getCheckIn(String checkInId) async {
    final checkIn = _checkIns[checkInId];
    if (checkIn == null) throw Exception('Check-in not found');
    return checkIn;
  }

  @override
  Future<List<CheckIn>> getCheckInsByTrip(String tripId) async {
    return _checkIns.values.where((c) => c.tripId == tripId).toList();
  }

  @override
  Future<CheckIn> updateCheckInStatus({
    required String checkInId,
    required CheckInStatus status,
  }) async {
    final checkIn = _checkIns[checkInId];
    if (checkIn == null) throw Exception('Check-in not found');
    final updated = checkIn.copyWith(status: status);
    _checkIns[checkInId] = updated;
    return updated;
  }

  @override
  Future<LocationUpdate> shareLocation({
    required double latitude,
    required double longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    String? address,
    String? placeName,
    required List<String> shareWithContactIds,
    int? batteryLevel,
    bool isEmergency = false,
    String? emergencyAlertId,
    String? checkInId,
  }) async {
    final locationUpdate = LocationUpdate(
      id: _generateId(),
      userId: testUserId,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      altitude: altitude,
      speed: speed,
      heading: heading,
      address: address,
      placeName: placeName,
      batteryLevel: batteryLevel ?? 85,
      sharingStatus: LocationSharingStatus.active,
      sharedWithContactIds: shareWithContactIds,
      isEmergency: isEmergency,
      checkInId: checkInId,
      emergencyAlertId: emergencyAlertId,
      createdAt: DateTime.now(),
    );
    _locationUpdates[locationUpdate.id] = locationUpdate;
    return locationUpdate;
  }

  @override
  Future<void> stopLocationSharing(List<String> contactIds) async {
    _locationUpdates.removeWhere((key, value) =>
      value.sharedWithContactIds.any((id) => contactIds.contains(id)));
  }

  @override
  Future<void> stopAllLocationSharing() async {
    _locationUpdates.clear();
  }

  @override
  Future<List<LocationUpdate>> getActiveLocationShares() async {
    return _locationUpdates.values.toList();
  }

  @override
  Future<List<LocationUpdate>> getLocationUpdates({
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _locationUpdates.values.toList();
  }

  @override
  Future<void> updateLocationSharingPermission({
    required String contactId,
    required bool enabled,
  }) async {
    // No-op for test
  }

  @override
  Future<SafetyAlert> triggerEmergencySOS({
    required String userId,
    String? message,
    required SafetyAlertLocation location,
    required List<String> notifyContactIds,
    int? batteryLevel,
    String? tripId,
  }) async {
    final alert = SafetyAlert(
      id: _generateId(),
      userId: userId,
      type: SafetyAlertType.emergencySOS,
      status: SafetyAlertStatus.sent,
      message: message,
      location: location,
      notifiedContactIds: notifyContactIds,
      acknowledgedByContactIds: [],
      triggeredAt: DateTime.now(),
      batteryLevel: batteryLevel,
      tripId: tripId,
      createdAt: DateTime.now(),
    );
    _safetyAlerts[alert.id] = alert;
    return alert;
  }

  @override
  Future<SafetyStatus> updateSafetyStatus({
    required SafetyStatusType status,
    String? message,
    SafetyStatusLocation? location,
    int? batteryLevel,
    String? safetyAlertId,
    String? checkInId,
  }) async {
    final safetyStatus = SafetyStatus(
      id: _generateId(),
      userId: testUserId,
      status: status,
      message: message,
      location: location,
      batteryLevel: batteryLevel,
      timestamp: DateTime.now(),
      safetyAlertId: safetyAlertId,
      checkInId: checkInId,
    );
    _currentSafetyStatus = safetyStatus;
    return safetyStatus;
  }

  @override
  Future<SafetyStatus> getSafetyStatus() async {
    return _currentSafetyStatus ?? SafetyStatus(
      id: _generateId(),
      userId: testUserId,
      status: SafetyStatusType.unknown,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<SafetyStatus> getSafetyStatusForUser(String userId) async {
    return _currentSafetyStatus ?? SafetyStatus(
      id: _generateId(),
      userId: userId,
      status: SafetyStatusType.unknown,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<List<SafetyAlert>> getSafetyAlerts() async {
    return _safetyAlerts.values.toList();
  }

  @override
  Future<SafetyAlert> getSafetyAlert(String alertId) async {
    final alert = _safetyAlerts[alertId];
    if (alert == null) throw Exception('Alert not found');
    return alert;
  }

  @override
  Future<List<SafetyAlert>> getRecentSafetyAlerts({
    int limit = 20,
    SafetyAlertType? type,
  }) async {
    var alerts = _safetyAlerts.values.toList();
    if (type != null) {
      alerts = alerts.where((a) => a.type == type).toList();
    }
    return alerts.take(limit).toList();
  }

  @override
  Future<void> acknowledgeSafetyAlert(String alertId, String contactId) async {
    final alert = _safetyAlerts[alertId];
    if (alert != null) {
      _safetyAlerts[alertId] = alert.copyWith(
        acknowledgedByContactIds: [...alert.acknowledgedByContactIds, contactId],
        firstAcknowledgedAt: alert.firstAcknowledgedAt ?? DateTime.now(),
      );
    }
  }

  @override
  Future<void> resolveSafetyAlert(String alertId) async {
    final alert = _safetyAlerts[alertId];
    if (alert != null) {
      _safetyAlerts[alertId] = alert.copyWith(status: SafetyAlertStatus.resolved);
    }
  }

  @override
  Future<void> cancelSafetyAlert(String alertId) async {
    final alert = _safetyAlerts[alertId];
    if (alert != null) {
      _safetyAlerts[alertId] = alert.copyWith(status: SafetyAlertStatus.cancelled);
    }
  }

  @override
  Future<List<SafetyAlert>> getMissedCheckInAlerts() async {
    return _safetyAlerts.values
        .where((a) => a.type == SafetyAlertType.missedCheckIn)
        .toList();
  }

  @override
  Future<void> updateBatteryLevel(int level) async {
    // No-op for test
  }

  @override
  Future<int?> getBatteryLevel() async {
    return 85;
  }

  @override
  Future<void> updateContactNotificationPreferences({
    required String contactId,
    required bool receivesCheckIns,
    required bool receivesEmergencyAlerts,
  }) async {
    // No-op for test
  }

  @override
  Future<Map<String, dynamic>> getSafetySettings() async {
    return {};
  }

  @override
  Future<void> updateSafetySettings(Map<String, dynamic> settings) async {
    // No-op for test
  }
}
