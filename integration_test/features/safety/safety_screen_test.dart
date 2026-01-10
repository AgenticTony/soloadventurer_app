import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/core/providers/core_providers.dart' show sharedPreferencesProvider;
import 'package:soloadventurer/features/safety/data/datasources/safety_local_data_source.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_local_data_source_impl.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_remote_data_source.dart';
import 'package:soloadventurer/features/safety/data/repositories/safety_repository_impl.dart';
import 'package:soloadventurer/features/safety/data/repositories/safety_providers.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_status.dart';
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';
import 'package:soloadventurer/features/safety/presentation/providers/safety_providers.dart';
import 'package:soloadventurer/features/safety/presentation/screens/safety_hub_screen.dart';
import 'package:soloadventurer/features/safety/presentation/screens/trusted_contacts_screen.dart';
import 'package:soloadventurer/features/safety/presentation/screens/emergency_sos_screen.dart';
import 'package:soloadventurer/app/di/service_locator.dart';

// Test constants
const testUserId = 'test-user-123';

/// UI Screen Integration Tests for Safety Feature
///
/// Tests actual user interactions with UI elements:
/// - Tapping buttons and navigating between screens
/// - Entering text in text fields
/// - Verifying widget presence and state
/// - Testing dialogs and bottom sheets
///
/// Separate from safety_flow_test.dart which tests provider/state integration
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late SafetyRepositoryImpl repository;
  late SafetyLocalDataSource localDataSource;

  setUp(() async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Initialize service locator in test mode
    await setupServiceLocator(isTest: true);

    // Initialize local data source
    localDataSource = SafetyLocalDataSourceImpl(prefs);

    // Create a mock safety remote data source that doesn't require ApiClient
    final mockRemoteDataSource = _TestSafetyRemoteDataSource();

    // Initialize repository
    repository = SafetyRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: localDataSource,
    );

    // Create container with provider overrides
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        safetyRepositoryOverrideProvider.overrideWithValue(repository),
      ],
    );

    // Pre-populate with test data
    await container.read(trustedContactsProvider.notifier).addContact(
          TrustedContact(
            id: 'contact-1',
            userId: testUserId,
            name: 'Alice Johnson',
            phoneNumber: '+1555011111',
            email: 'alice@example.com',
            source: ContactSource.phone,
            permission: ContactPermission.fullAccess,
            locationSharingEnabled: true,
            receivesCheckIns: true,
            receivesEmergencyAlerts: true,
            addedAt: DateTime.now(),
          ),
        );

    await container.read(trustedContactsProvider.notifier).addContact(
          TrustedContact(
            id: 'contact-2',
            userId: testUserId,
            name: 'Bob Smith',
            phoneNumber: '+1555022222',
            email: 'bob@example.com',
            source: ContactSource.community,
            permission: ContactPermission.emergencyOnly,
            locationSharingEnabled: false,
            receivesCheckIns: false,
            receivesEmergencyAlerts: true,
            addedAt: DateTime.now(),
          ),
        );
  });

  tearDown(() async {
    await resetServiceLocator();
    container.dispose();
  });

  group('Safety Hub Screen UI Tests', () {
    testWidgets('Should display all safety feature cards', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SafetyHubScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title
      expect(find.text('Safety Hub'), findsOneWidget);

      // Verify quick stats section
      expect(find.text('Contacts'), findsOneWidget);
      expect(find.text('Check-ins'), findsOneWidget);
      expect(find.text('Sharing'), findsOneWidget);

      // Verify feature cards
      expect(find.text('Trusted Contacts'), findsOneWidget);
      expect(find.text('Manage your trusted contacts'), findsOneWidget);
      expect(find.text('Check-ins'), findsOneWidget);
      expect(find.text('Manual and scheduled check-ins'), findsOneWidget);
      expect(find.text('Location Sharing'), findsOneWidget);
      expect(find.text('Share your location with contacts'), findsOneWidget);
      expect(find.text('Emergency SOS'), findsOneWidget);
      expect(find.text('Quick emergency alert'), findsOneWidget);
    });

    testWidgets('Should navigate to Trusted Contacts screen', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SafetyHubScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the Trusted Contacts card
      final trustedContactsCard = find.ancestor(
        of: find.text('Manage your trusted contacts'),
        matching: find.byType(InkWell),
      );
      expect(trustedContactsCard, findsOneWidget);

      await tester.tap(trustedContactsCard);
      await tester.pumpAndSettle();

      // Verify navigation to Trusted Contacts screen
      expect(find.text('Trusted Contacts'), findsWidgets);
    });

    testWidgets('Should navigate to Emergency SOS screen', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SafetyHubScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the Emergency SOS card
      final emergencySOSCard = find.ancestor(
        of: find.text('Quick emergency alert'),
        matching: find.byType(InkWell),
      );
      expect(emergencySOSCard, findsOneWidget);

      await tester.tap(emergencySOSCard);
      await tester.pumpAndSettle();

      // Verify navigation to Emergency SOS screen
      expect(find.text('Emergency SOS'), findsOneWidget);
      expect(find.text('SOS'), findsOneWidget);
      expect(find.text('Emergency'), findsOneWidget);
    });

    testWidgets('Should display quick action buttons', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SafetyHubScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Check In'), findsOneWidget);
      expect(find.text('Update Status'), findsOneWidget);
      expect(find.text('Emergency'), findsOneWidget);
    });

    testWidgets('Should navigate via quick action buttons', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SafetyHubScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Emergency quick action button
      final emergencyButton = find.ancestor(
        of: find.text('Emergency').last,
        matching: find.byType(InkWell),
      );
      await tester.tap(emergencyButton);
      await tester.pumpAndSettle();

      // Verify navigation to Emergency SOS screen
      expect(find.text('Emergency SOS'), findsOneWidget);
    });
  });

  group('Trusted Contacts Screen UI Tests', () {
    testWidgets('Should display list of trusted contacts', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: TrustedContactsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify contacts are displayed
      expect(find.text('Alice Johnson'), findsOneWidget);
      expect(find.text('Bob Smith'), findsOneWidget);
      expect(find.text('+1555011111'), findsOneWidget);
      expect(find.text('+1555022222'), findsOneWidget);

      // Verify permission chips
      expect(find.text('Full Access'), findsOneWidget);
      expect(find.text('Emergency Only'), findsOneWidget);

      // Verify source chips
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('Community'), findsOneWidget);
    });

    testWidgets('Should show info dialog when tapping info button',
        (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: TrustedContactsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the info button
      final infoButton = find.byType(IconButton);
      await tester.tap(infoButton);
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('About Trusted Contacts'), findsOneWidget);
      expect(find.text('Permission Levels:'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();
    });

    testWidgets('Should show contact details on tap', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: TrustedContactsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Alice's contact tile
      await tester.tap(find.text('Alice Johnson'));
      await tester.pumpAndSettle();

      // Verify bottom sheet is shown with contact details
      expect(find.text('alice@example.com'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Source'), findsOneWidget);
      expect(find.text('Permission'), findsOneWidget);
      expect(find.text('Location Sharing'), findsOneWidget);
      expect(find.text('Emergency Alerts'), findsOneWidget);
      expect(find.text('Check-in Notifications'), findsOneWidget);
    });
  });

  group('Emergency SOS Screen UI Tests', () {
    testWidgets('Should display SOS button', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: EmergencySOSScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SOS'), findsOneWidget);
      expect(find.text('Emergency'), findsOneWidget);
      expect(find.text('Press to send emergency alert'), findsOneWidget);
    });

    testWidgets('Should display location card', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: EmergencySOSScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Location to Share'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsWidgets);
    });

    testWidgets('Should display contacts who will be notified', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: EmergencySOSScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Will Notify'), findsOneWidget);

      // Both contacts have emergency alerts enabled
      expect(find.text('Alice Johnson'), findsOneWidget);
      expect(find.text('Bob Smith'), findsOneWidget);
    });

    testWidgets('Should display optional message section', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: EmergencySOSScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Message (Optional)'), findsOneWidget);
      expect(
        find.text("Let your contacts know what's happening"),
        findsOneWidget,
      );

      // Find the text field
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Enter text in the message field
      await tester.enterText(
        textField,
        'I need help immediately!',
      );
      await tester.pumpAndSettle();

      // Verify text was entered
      expect(find.text('I need help immediately!'), findsOneWidget);
    });

    testWidgets('Should show confirmation when tapping SOS button',
        (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: EmergencySOSScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the SOS button
      final sosButton = find.ancestor(
        of: find.text('SOS'),
        matching: find.byType(InkWell),
      ).first;

      await tester.tap(sosButton);
      await tester.pumpAndSettle();

      // Verify confirmation dialog is shown
      expect(find.text('Confirm Emergency SOS'), findsOneWidget);
      expect(
        find.text(
          'This will send an emergency alert with your location to all trusted contacts who receive emergency alerts.',
        ),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('YES, SEND SOS'), findsOneWidget);

      // Cancel the dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets('Should show active emergency banner when alert is active',
        (tester) async {
      // Set up an active emergency
      final testLocation = SafetyAlertLocation(
        latitude: 40.7128,
        longitude: -74.0060,
        accuracy: 10.0,
        timestamp: DateTime.now(),
      );

      await container
          .read(safetyProvider.notifier)
          .triggerEmergencySOS(
            userId: testUserId,
            location: testLocation,
            message: 'Test emergency',
            notifyContactIds: null,
            batteryLevel: 75,
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: EmergencySOSScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify active emergency banner is shown
      expect(find.text('Emergency Alert Active'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
    });
  });

  group('Safety Widget Tests', () {
    testWidgets('SafetyHubScreen should display stat cards with correct counts',
        (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SafetyHubScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // We have 2 contacts
      expect(find.text('2'), findsAtLeastNWidgets(1));

      // Verify the stat cards exist (Card widgets)
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('TrustedContactsScreen should show FAB for adding contacts',
        (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: TrustedContactsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify FAB exists
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Add Contact'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}

/// Test implementation of SafetyRemoteDataSource for UI testing
class _TestSafetyRemoteDataSource implements SafetyRemoteDataSource {
  final Map<String, TrustedContact> _contacts = {};
  final Map<String, SafetyAlert> _safetyAlerts = {};

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
    return SafetyStatus(
      id: _generateId(),
      userId: testUserId,
      status: status,
      message: message,
      location: location,
      batteryLevel: batteryLevel,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<SafetyStatus> getSafetyStatus() async {
    return SafetyStatus(
      id: _generateId(),
      userId: testUserId,
      status: SafetyStatusType.unknown,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<List<SafetyAlert>> getRecentSafetyAlerts({
    int limit = 20,
    SafetyAlertType? type,
  }) async {
    return _safetyAlerts.values.toList();
  }

  // Stub implementations for unused methods
  @override
  Future noSuchMethod(Invocation invocation) async {
    throw UnimplementedError();
  }
}
