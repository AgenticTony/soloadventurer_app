import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/safety/data/repositories/safety_providers.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_status.dart';
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';
import 'package:soloadventurer/features/safety/domain/providers/safety_usecase_providers.dart';
import 'package:soloadventurer/features/safety/domain/repositories/safety_repository.dart';
import 'package:soloadventurer/features/safety/domain/usecases/get_safety_status.dart';
import 'package:soloadventurer/features/safety/domain/usecases/update_safety_status.dart';
import 'package:soloadventurer/features/safety/domain/usecases/trigger_emergency_sos.dart';
import 'package:soloadventurer/features/safety/presentation/state/safety_data.dart';
import 'package:soloadventurer/features/safety/presentation/providers/safety_providers.dart'
    as safety_providers
    show safetyNotifierProvider, safetyRepositoryOverrideProvider;

import '../../../../helpers/safety_test_helpers.dart';

class MockGetSafetyStatusUseCase extends Mock
    implements GetSafetyStatusUseCase {}

class MockUpdateSafetyStatusUseCase extends Mock
    implements UpdateSafetyStatusUseCase {}

class MockTriggerEmergencySOSUseCase extends Mock
    implements TriggerEmergencySOSUseCase {}

class MockSafetyRepository extends Mock implements SafetyRepository {
  @override
  Future<List<SafetyAlert>> getRecentSafetyAlerts(
      {int limit = 20, SafetyAlertType? type}) async {
    return createTestSafetyAlertsList(count: 2);
  }

  @override
  Future<List<TrustedContact>> getTrustedContacts() async {
    return createTestTrustedContactsList(count: 2);
  }
}

void main() {
  late MockGetSafetyStatusUseCase mockGetSafetyStatus;
  late MockUpdateSafetyStatusUseCase mockUpdateSafetyStatus;
  late MockTriggerEmergencySOSUseCase mockTriggerEmergencySOS;
  late MockSafetyRepository mockRepository;

  setUp(() {
    mockGetSafetyStatus = MockGetSafetyStatusUseCase();
    mockUpdateSafetyStatus = MockUpdateSafetyStatusUseCase();
    mockTriggerEmergencySOS = MockTriggerEmergencySOSUseCase();
    mockRepository = MockSafetyRepository();

    // Setup default mock behaviors
    registerFallbackValue(testDateTime);
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        getSafetyStatusUseCaseProvider.overrideWithValue(mockGetSafetyStatus),
        updateSafetyStatusUseCaseProvider
            .overrideWithValue(mockUpdateSafetyStatus),
        triggerEmergencySOSUseCaseProvider
            .overrideWithValue(mockTriggerEmergencySOS),
        safetyRepositoryOverrideProvider.overrideWithValue(mockRepository),
      ],
    );
  }

  group('SafetyNotifier', () {
    test('initial state is empty SafetyState', () {
      final container = createContainer();

      final state =
          container.read(safety_providers.safetyNotifierProvider).state;

      expect(state, isA<SafetyState>());
      expect(state.currentStatus, isNull);
      expect(state.recentAlerts, isEmpty);
      expect(state.activeAlerts, isEmpty);
      expect(state.trustedContactsCount, equals(0));

      container.dispose();
    });

    group('initialize', () {
      test('sets loading state while initializing', () async {
        // Arrange
        when(() => mockGetSafetyStatus())
            .thenAnswer((_) async => createTestSafetyStatus());

        final container = createContainer();

        // Act
        final future = container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .initialize();

        // Assert
        expect(
          container.read(safety_providers.safetyNotifierProvider).state,
          isA<SafetyState>().having((s) => s.isLoading, 'isLoading', true),
        );

        await future;
        container.dispose();
      });

      test('loads safety data successfully', () async {
        // Arrange
        final testStatus = createTestSafetyStatus();
        final testAlerts = createTestSafetyAlertsList(count: 2);
        final testContacts = createTestTrustedContactsList(count: 3);

        when(() => mockGetSafetyStatus()).thenAnswer((_) async => testStatus);
        when(() => mockRepository.getRecentSafetyAlerts(limit: 10))
            .thenAnswer((_) async => testAlerts);
        when(() => mockRepository.getTrustedContacts())
            .thenAnswer((_) async => testContacts);

        final container = createContainer();

        // Act
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .initialize();

        // Assert
        final state =
            container.read(safety_providers.safetyNotifierProvider).state;
        expect(state.currentStatus?.status, equals(SafetyStatusType.safe));
        expect(state.recentAlerts, hasLength(2));
        expect(state.trustedContactsCount, equals(3));

        verify(() => mockGetSafetyStatus()).called(1);
        verify(() => mockRepository.getRecentSafetyAlerts(limit: 10)).called(1);
        verify(() => mockRepository.getTrustedContacts()).called(1);

        container.dispose();
      });

      test('handles errors during initialization', () async {
        // Arrange
        when(() => mockGetSafetyStatus())
            .thenThrow(const ServerException(message: 'Network error'));

        final container = createContainer();

        // Act
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .initialize();

        // Assert
        final state =
            container.read(safety_providers.safetyNotifierProvider).state;
        expect(state.hasError, isTrue);

        container.dispose();
      });
    });

    group('loadSafetyStatus', () {
      test('updates safety status in current data', () async {
        // Arrange
        final testStatus = createTestSafetyStatus(
          statusType: SafetyStatusType.needHelp,
          message: 'Need assistance',
        );
        when(() => mockGetSafetyStatus()).thenAnswer((_) async => testStatus);

        final container = createContainer();

        // Initialize first
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .initialize();

        // Act
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .loadSafetyStatus();

        // Assert
        final state =
            container.read(safety_providers.safetyNotifierProvider).state;
        expect(state.currentStatus?.status, equals(SafetyStatusType.needHelp));
        expect(state.currentStatus?.message, equals('Need assistance'));

        container.dispose();
      });

      test('handles errors when loading safety status', () async {
        // Arrange
        when(() => mockGetSafetyStatus())
            .thenThrow(const ServerException(message: 'Failed to load'));

        final container = createContainer();

        // Initialize first
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .initialize();

        // Act
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .loadSafetyStatus();

        // Assert
        final state =
            container.read(safety_providers.safetyNotifierProvider).state;
        expect(state.hasError, isTrue);

        container.dispose();
      });
    });

    group('triggerEmergencySOS', () {
      test('triggers emergency SOS with progress reporting', () async {
        // Arrange
        final testLocation = createTestSafetyAlertLocation();
        final testAlert =
            createTestSafetyAlert(type: SafetyAlertType.emergencySOS);
        final testContacts = createTestTrustedContactsList(count: 2)
            .where((c) => c.receivesEmergencyAlerts)
            .toList();

        when(() => mockRepository.getTrustedContacts())
            .thenAnswer((_) async => testContacts);
        when(() => mockTriggerEmergencySOS(
              userId: any(),
              location: any(),
              message: any(named: 'message'),
              notifyContactIds: any(),
              batteryLevel: any(named: 'batteryLevel'),
              tripId: any(named: 'tripId'),
            )).thenAnswer((_) async => testAlert);

        final container = createContainer();

        // Act
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .triggerEmergencySOS(
              userId: testUserId,
              location: testLocation,
              message: testEmergencyMessage,
              batteryLevel: 85,
            );

        // Assert
        final state =
            container.read(safety_providers.safetyNotifierProvider).state;
        expect(state.recentAlerts.first.type,
            equals(SafetyAlertType.emergencySOS));
        expect(state.activeAlerts, contains(testAlert));

        verify(() => mockRepository.getTrustedContacts()).called(1);
        verify(() => mockTriggerEmergencySOS(
              userId: testUserId,
              location: testLocation,
              message: testEmergencyMessage,
              notifyContactIds: testContacts.map((c) => c.id).toList(),
              batteryLevel: 85,
            )).called(1);

        container.dispose();
      });

      test('uses provided contact IDs when specified', () async {
        // Arrange
        final testLocation = createTestSafetyAlertLocation();
        final testAlert = createTestSafetyAlert();
        final contactIds = [testContactId, 'contact-2'];

        when(() => mockTriggerEmergencySOS(
              userId: any(),
              location: any(),
              notifyContactIds: contactIds,
            )).thenAnswer((_) async => testAlert);

        final container = createContainer();

        // Act
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .triggerEmergencySOS(
              userId: testUserId,
              location: testLocation,
              notifyContactIds: contactIds,
            );

        // Assert
        verify(() => mockTriggerEmergencySOS(
              userId: testUserId,
              location: testLocation,
              notifyContactIds: contactIds,
            )).called(1);
        verifyNever(() => mockRepository.getTrustedContacts());

        container.dispose();
      });

      test('handles errors during emergency SOS', () async {
        // Arrange
        final testLocation = createTestSafetyAlertLocation();
        final testContacts = createTestTrustedContactsList(count: 2);

        when(() => mockRepository.getTrustedContacts())
            .thenAnswer((_) async => testContacts);
        when(() => mockTriggerEmergencySOS(any(), location: any()))
            .thenThrow(const ServerException(message: 'Network failed'));

        final container = createContainer();

        // Act
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .triggerEmergencySOS(
              userId: testUserId,
              location: testLocation,
            );

        // Assert
        final state =
            container.read(safety_providers.safetyNotifierProvider).state;
        expect(state.hasError, isTrue);

        container.dispose();
      });
    });

    group('updateSafetyStatus', () {
      test('updates safety status to safe', () async {
        // Arrange
        final updatedStatus = createTestSafetyStatus(
          statusType: SafetyStatusType.safe,
          message: 'I am safe now',
        );

        when(() => mockUpdateSafetyStatus(
              status: SafetyStatusType.safe,
              message: 'I am safe now',
            )).thenAnswer((_) async => updatedStatus);

        final container = createContainer();

        // Act
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .updateSafetyStatus(
              status: SafetyStatusType.safe,
              message: 'I am safe now',
            );

        // Assert
        final state =
            container.read(safety_providers.safetyNotifierProvider).state;
        expect(state.currentStatus?.status, equals(SafetyStatusType.safe));
        expect(state.currentStatus?.message, equals('I am safe now'));

        verify(() => mockUpdateSafetyStatus(
              status: SafetyStatusType.safe,
              message: 'I am safe now',
            )).called(1);

        container.dispose();
      });

      test('handles errors when updating safety status', () async {
        // Arrange
        when(() => mockUpdateSafetyStatus(any()))
            .thenThrow(const ServerException(message: 'Update failed'));

        final container = createContainer();

        // Act
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .updateSafetyStatus(
              status: SafetyStatusType.emergency,
            );

        // Assert
        final state =
            container.read(safety_providers.safetyNotifierProvider).state;
        expect(state.hasError, isTrue);

        container.dispose();
      });
    });

    group('markAsSafe', () {
      test('updates status to safe', () async {
        // Arrange
        final updatedStatus = createTestSafetyStatus(
          statusType: SafetyStatusType.safe,
          message: 'Safe',
        );

        when(() => mockUpdateSafetyStatus(
              status: SafetyStatusType.safe,
              message: 'Safe',
            )).thenAnswer((_) async => updatedStatus);

        final container = createContainer();

        // Act
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .markAsSafe(
              message: 'Safe',
            );

        // Assert
        final state =
            container.read(safety_providers.safetyNotifierProvider).state;
        expect(state.currentStatus?.status, equals(SafetyStatusType.safe));

        container.dispose();
      });
    });

    group('markAsNeedHelp', () {
      test('updates status to needHelp', () async {
        // Arrange
        final updatedStatus = createTestSafetyStatus(
          statusType: SafetyStatusType.needHelp,
          message: 'Need help',
        );

        when(() => mockUpdateSafetyStatus(
              status: SafetyStatusType.needHelp,
              message: 'Need help',
            )).thenAnswer((_) async => updatedStatus);

        final container = createContainer();

        // Act
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .markAsNeedHelp(
              message: 'Need help',
            );

        // Assert
        final state =
            container.read(safety_providers.safetyNotifierProvider).state;
        expect(state.currentStatus?.status, equals(SafetyStatusType.needHelp));

        container.dispose();
      });
    });

    group('markAsEmergency', () {
      test('updates status to emergency', () async {
        // Arrange
        final updatedStatus = createTestSafetyStatus(
          statusType: SafetyStatusType.emergency,
          message: 'Emergency',
        );

        when(() => mockUpdateSafetyStatus(
              status: SafetyStatusType.emergency,
              message: 'Emergency',
            )).thenAnswer((_) async => updatedStatus);

        final container = createContainer();

        // Act
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .markAsEmergency(
              message: 'Emergency',
            );

        // Assert
        final state =
            container.read(safety_providers.safetyNotifierProvider).state;
        expect(state.currentStatus?.status, equals(SafetyStatusType.emergency));

        container.dispose();
      });
    });

    group('loadRecentAlerts', () {
      test('loads recent alerts and updates active alerts', () async {
        // Arrange
        final sentAlert = createTestSafetyAlert(
          id: 'alert-1',
          status: SafetyAlertStatus.sent,
        );
        final acknowledgedAlert = createTestSafetyAlert(
          id: 'alert-2',
          status: SafetyAlertStatus.acknowledged,
        );
        final resolvedAlert = createTestSafetyAlert(
          id: 'alert-3',
          status: SafetyAlertStatus.resolved,
        );

        when(() => mockRepository.getRecentSafetyAlerts(limit: 20)).thenAnswer(
            (_) async => [sentAlert, acknowledgedAlert, resolvedAlert]);

        final container = createContainer();

        // Act
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .loadRecentAlerts();

        // Assert
        final state =
            container.read(safety_providers.safetyNotifierProvider).state;
        expect(state.recentAlerts, hasLength(3));
        expect(state.activeAlerts, hasLength(2)); // Only sent and acknowledged

        verify(() => mockRepository.getRecentSafetyAlerts(limit: 20)).called(1);

        container.dispose();
      });

      test('respects limit parameter', () async {
        // Arrange
        when(() => mockRepository.getRecentSafetyAlerts(limit: 10))
            .thenAnswer((_) async => createTestSafetyAlertsList(count: 5));

        final container = createContainer();

        // Act
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .loadRecentAlerts(limit: 10);

        // Assert
        verify(() => mockRepository.getRecentSafetyAlerts(limit: 10)).called(1);

        container.dispose();
      });
    });

    group('acknowledgeAlert', () {
      test('acknowledges an alert and updates state', () async {
        // Arrange
        final testAlert = createTestSafetyAlert(
          id: 'alert-1',
          acknowledgedByContactIds: [],
        );

        when(() =>
                mockRepository.acknowledgeSafetyAlert('alert-1', 'contact-ack'))
            .thenAnswer((_) async {});

        final container = createContainer();

        // Initialize with data
        container.read(safety_providers.safetyNotifierProvider.notifier).state =
            AsyncValue.data(SafetyData(recentAlerts: [testAlert]));

        // Act
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .acknowledgeAlert('alert-1', 'contact-ack');

        // Assert
        final state =
            container.read(safety_providers.safetyNotifierProvider).state;
        final updatedAlert =
            state.recentAlerts.firstWhere((a) => a.id == 'alert-1');
        expect(updatedAlert.acknowledgedByContactIds, contains('contact-ack'));

        verify(() =>
                mockRepository.acknowledgeSafetyAlert('alert-1', 'contact-ack'))
            .called(1);

        container.dispose();
      });
    });

    group('resolveAlert', () {
      test('resolves an alert and removes from active', () async {
        // Arrange
        final testAlert = createTestSafetyAlert(
          id: 'alert-1',
          status: SafetyAlertStatus.sent,
        );

        when(() => mockRepository.resolveSafetyAlert('alert-1'))
            .thenAnswer((_) async {});

        final container = createContainer();

        // Initialize with data
        container.read(safety_providers.safetyNotifierProvider.notifier).state =
            AsyncValue.data(SafetyData(
          recentAlerts: [testAlert],
          activeAlerts: [testAlert],
        ));

        // Act
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .resolveAlert('alert-1');

        // Assert
        final state =
            container.read(safety_providers.safetyNotifierProvider).state;
        final resolvedAlert =
            state.recentAlerts.firstWhere((a) => a.id == 'alert-1');
        expect(resolvedAlert.status, equals(SafetyAlertStatus.resolved));
        expect(state.activeAlerts, isEmpty);

        verify(() => mockRepository.resolveSafetyAlert('alert-1')).called(1);

        container.dispose();
      });
    });

    group('cancelAlert', () {
      test('cancels an alert and removes from active', () async {
        // Arrange
        final testAlert = createTestSafetyAlert(
          id: 'alert-1',
          status: SafetyAlertStatus.sent,
        );

        when(() => mockRepository.cancelSafetyAlert('alert-1'))
            .thenAnswer((_) async {});

        final container = createContainer();

        // Initialize with data
        container.read(safety_providers.safetyNotifierProvider.notifier).state =
            AsyncValue.data(SafetyData(
          recentAlerts: [testAlert],
          activeAlerts: [testAlert],
        ));

        // Act
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .cancelAlert('alert-1');

        // Assert
        final state =
            container.read(safety_providers.safetyNotifierProvider).state;
        final cancelledAlert =
            state.recentAlerts.firstWhere((a) => a.id == 'alert-1');
        expect(cancelledAlert.status, equals(SafetyAlertStatus.cancelled));
        expect(state.activeAlerts, isEmpty);

        verify(() => mockRepository.cancelSafetyAlert('alert-1')).called(1);

        container.dispose();
      });
    });

    group('loadMissedCheckInAlerts', () {
      test('loads missed check-in alerts', () async {
        // Arrange
        final missedAlerts = [
          createTestSafetyAlert(
            id: 'alert-1',
            type: SafetyAlertType.missedCheckIn,
          ),
          createTestSafetyAlert(
            id: 'alert-2',
            type: SafetyAlertType.missedCheckIn,
          ),
        ];

        when(() => mockRepository.getMissedCheckInAlerts())
            .thenAnswer((_) async => missedAlerts);

        final container = createContainer();

        // Act
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .loadMissedCheckInAlerts();

        // Assert
        final state =
            container.read(safety_providers.safetyNotifierProvider).state;
        expect(state.recentAlerts, hasLength(2));
        expect(state.recentAlerts.first.type,
            equals(SafetyAlertType.missedCheckIn));

        verify(() => mockRepository.getMissedCheckInAlerts()).called(1);

        container.dispose();
      });
    });

    group('updateBatteryLevel', () {
      test('updates battery level', () async {
        // Arrange
        when(() => mockRepository.updateBatteryLevel(75))
            .thenAnswer((_) async {});

        final container = createContainer();

        // Act
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .updateBatteryLevel(75);

        // Assert
        verify(() => mockRepository.updateBatteryLevel(75)).called(1);

        container.dispose();
      });
    });

    group('getBatteryLevel', () {
      test('returns battery level', () async {
        // Arrange
        when(() => mockRepository.getBatteryLevel())
            .thenAnswer((_) async => 85);

        final container = createContainer();

        // Act
        final result = await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .getBatteryLevel();

        // Assert
        expect(result, equals(85));

        container.dispose();
      });

      test('returns null on error', () async {
        // Arrange
        when(() => mockRepository.getBatteryLevel())
            .thenThrow(const ServerException(message: 'Failed'));

        final container = createContainer();

        // Act
        final result = await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .getBatteryLevel();

        // Assert
        expect(result, isNull);

        container.dispose();
      });
    });

    group('updateContactsCount', () {
      test('updates trusted contacts count', () async {
        // Arrange
        final contacts = createTestTrustedContactsList(count: 5);
        when(() => mockRepository.getTrustedContacts())
            .thenAnswer((_) async => contacts);

        final container = createContainer();
        container.read(safety_providers.safetyNotifierProvider.notifier).state =
            const AsyncValue.data(SafetyData());

        // Act
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .updateContactsCount();

        // Assert
        final state =
            container.read(safety_providers.safetyNotifierProvider).state;
        expect(state.trustedContactsCount, equals(5));

        container.dispose();
      });

      test('does not update state when no current data', () async {
        // Arrange
        when(() => mockRepository.getTrustedContacts())
            .thenAnswer((_) async => createTestTrustedContactsList(count: 3));

        final container = createContainer();
        container.read(safety_providers.safetyNotifierProvider.notifier).state =
            const AsyncValue.data(SafetyData());

        // Act
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .updateContactsCount();

        // Assert
        // State should remain empty since there was no data to update
        final state =
            container.read(safety_providers.safetyNotifierProvider).state;
        expect(state.trustedContactsCount, equals(0));

        container.dispose();
      });
    });

    group('refresh', () {
      test('calls initialize to reload all data', () async {
        // Arrange
        final testStatus = createTestSafetyStatus();
        when(() => mockGetSafetyStatus()).thenAnswer((_) async => testStatus);

        final container = createContainer();

        // Act
        await container
            .read(safety_providers.safetyNotifierProvider.notifier)
            .refresh();

        // Assert
        verify(() => mockGetSafetyStatus()).called(1);

        container.dispose();
      });
    });

    group('SafetyData getters', () {
      test('hasActiveEmergency returns true when active alerts exist', () {
        final data = SafetyData(
          activeAlerts: [createTestSafetyAlert()],
        );

        expect(data.hasActiveEmergency, isTrue);
      });

      test('hasActiveEmergency returns false when no active alerts', () {
        const data = SafetyData();

        expect(data.hasActiveEmergency, isFalse);
      });

      test('isInDanger returns true when status is emergency', () {
        final status =
            createTestSafetyStatus(statusType: SafetyStatusType.emergency);
        final data = SafetyData(currentStatus: status);

        expect(data.isInDanger, isTrue);
      });

      test('isInDanger returns true when status is needHelp', () {
        final status =
            createTestSafetyStatus(statusType: SafetyStatusType.needHelp);
        final data = SafetyData(currentStatus: status);

        expect(data.isInDanger, isTrue);
      });

      test('isInDanger returns false when status is safe', () {
        final status =
            createTestSafetyStatus(statusType: SafetyStatusType.safe);
        final data = SafetyData(currentStatus: status);

        expect(data.isInDanger, isFalse);
      });

      test('isInitialized returns true when currentStatus exists', () {
        final status = createTestSafetyStatus();
        final data = SafetyData(currentStatus: status);

        expect(data.isInitialized, isTrue);
      });

      test('isInitialized returns false when currentStatus is null', () {
        const data = SafetyData();

        expect(data.isInitialized, isFalse);
      });
    });
  });
}
