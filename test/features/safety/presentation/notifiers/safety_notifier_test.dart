import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/safety/data/repositories/safety_providers.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_status.dart';
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';
import 'package:soloadventurer/features/safety/domain/repositories/safety_repository.dart';
import 'package:soloadventurer/features/safety/domain/usecases/get_safety_status.dart';
import 'package:soloadventurer/features/safety/domain/usecases/update_safety_status.dart';
import 'package:soloadventurer/features/safety/domain/usecases/trigger_emergency_sos.dart';
import 'package:soloadventurer/features/safety/presentation/state/safety_state.dart';
import 'package:soloadventurer/features/safety/presentation/providers/safety_provider.dart';
import 'package:soloadventurer/features/safety/presentation/providers/safety_providers.dart';

import '../../../../helpers/safety_test_helpers.dart';

class MockGetSafetyStatusUseCase extends Mock
    implements GetSafetyStatusUseCase {}

class MockUpdateSafetyStatusUseCase extends Mock
    implements UpdateSafetyStatusUseCase {}

class MockTriggerEmergencySOSUseCase extends Mock
    implements TriggerEmergencySOSUseCase {}

class MockSafetyRepository extends Mock implements SafetyRepository {}

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

    registerFallbackValue(testDateTime);
    registerFallbackValue(SafetyStatusType.safe);
    registerFallbackValue(createTestSafetyAlertLocation());
    registerFallbackValue(createTestSafetyStatus());
    registerFallbackValue(createTestSafetyAlert());
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

  group('Safety', () {
    test('initial state has correct defaults', () async {
      final container = createContainer();

      // AsyncNotifier builds asynchronously, so wait for it
      await container.read(safetyProvider.future);
      final asyncState = container.read(safetyProvider);

      expect(asyncState, isA<AsyncData<SafetyState>>());
      final state = asyncState.value!;
      expect(state.currentStatus, isNull);
      expect(state.recentAlerts, isEmpty);
      expect(state.activeAlerts, isEmpty);
      expect(state.trustedContactsCount, equals(0));
      expect(asyncState.isLoading, isFalse);
      expect(state.isProcessing, isFalse);
      expect(asyncState.hasError, isFalse);

      container.dispose();
    });

    group('initialize', () {
      test('loads safety data successfully', () async {
        // Arrange
        final testStatus = createTestSafetyStatus();
        final testAlerts = createTestSafetyAlertsList(count: 2);
        final testContacts = createTestTrustedContactsList(count: 3);

        when(() => mockGetSafetyStatus()).thenAnswer((_) async => testStatus);
        when(() => mockRepository.getRecentSafetyAlerts(limit: any(named: 'limit')))
            .thenAnswer((_) async => testAlerts);
        when(() => mockRepository.getTrustedContacts())
            .thenAnswer((_) async => testContacts);

        final container = createContainer();

        // Act
        await container.read(safetyProvider.notifier).initialize();

        // Assert
        final state = container.read(safetyProvider).value!;
        expect(state.currentStatus?.status, equals(SafetyStatusType.safe));
        expect(state.recentAlerts, hasLength(2));
        expect(state.trustedContactsCount, equals(3));
        expect(container.read(safetyProvider).isLoading, isFalse);

        container.dispose();
      });

      test('handles errors during initialization', () async {
        // Arrange
        when(() => mockGetSafetyStatus())
            .thenThrow(const ServerException(message: 'Network error'));

        final container = createContainer();

        // Act
        await container.read(safetyProvider.notifier).initialize();

        // Assert
        final asyncState = container.read(safetyProvider);
        expect(asyncState, isA<AsyncError>());
        expect(asyncState.isLoading, isFalse);

        container.dispose();
      });
    });

    group('loadSafetyStatus', () {
      test('updates safety status', () async {
        // Arrange
        final testStatus = createTestSafetyStatus(
          status: SafetyStatusType.needHelp,
          message: 'Need assistance',
        );
        when(() => mockGetSafetyStatus()).thenAnswer((_) async => testStatus);

        final container = createContainer();
        // Wait for initial async build to complete
        await container.read(safetyProvider.future);

        // Act
        await container.read(safetyProvider.notifier).loadSafetyStatus();

        // Assert
        final state = container.read(safetyProvider).value!;
        expect(state.currentStatus?.status, equals(SafetyStatusType.needHelp));
        expect(state.currentStatus?.message, equals('Need assistance'));

        container.dispose();
      });

      test('handles errors when loading safety status', () async {
        // Arrange
        when(() => mockGetSafetyStatus())
            .thenThrow(const ServerException(message: 'Failed to load'));

        final container = createContainer();
        // Wait for initial async build to complete
        await container.read(safetyProvider.future);

        // Act
        await container.read(safetyProvider.notifier).loadSafetyStatus();

        // Assert
        final asyncState = container.read(safetyProvider);
        expect(asyncState, isA<AsyncError>());

        container.dispose();
      });
    });

    group('triggerEmergencySOS', () {
      test('triggers emergency SOS and adds alert to state', () async {
        // Arrange
        final testLocation = createTestSafetyAlertLocation();
        final testAlert =
            createTestSafetyAlert(type: SafetyAlertType.emergencySOS);
        final testContacts = createTestTrustedContactsList(count: 2);

        when(() => mockRepository.getTrustedContacts())
            .thenAnswer((_) async => testContacts);
        when(() => mockTriggerEmergencySOS(
              userId: any(named: 'userId'),
              location: any(named: 'location'),
              message: any(named: 'message'),
              notifyContactIds: any(named: 'notifyContactIds'),
              batteryLevel: any(named: 'batteryLevel'),
              tripId: any(named: 'tripId'),
            )).thenAnswer((_) async => testAlert);

        final container = createContainer();
        // Wait for initial async build to complete
        await container.read(safetyProvider.future);

        // Act
        await container.read(safetyProvider.notifier).triggerEmergencySOS(
              userId: testUserId,
              location: testLocation,
              message: testEmergencyMessage,
            );

        // Assert
        final state = container.read(safetyProvider).value!;
        expect(state.recentAlerts, isNotEmpty);
        expect(state.activeAlerts, isNotEmpty);
        expect(state.isProcessing, isFalse);

        container.dispose();
      });

      test('handles errors during SOS trigger', () async {
        // Arrange
        final testLocation = createTestSafetyAlertLocation();

        when(() => mockRepository.getTrustedContacts())
            .thenThrow(const ServerException(message: 'Failed'));

        final container = createContainer();
        // Wait for initial async build to complete
        await container.read(safetyProvider.future);

        // Act
        await container.read(safetyProvider.notifier).triggerEmergencySOS(
              userId: testUserId,
              location: testLocation,
            );

        // Assert
        final asyncState = container.read(safetyProvider);
        expect(asyncState, isA<AsyncError>());

        container.dispose();
      });
    });

    group('updateSafetyStatus', () {
      test('updates status to safe', () async {
        // Arrange
        final testStatus = createTestSafetyStatus(
          status: SafetyStatusType.safe,
        );
        when(() => mockUpdateSafetyStatus(
              status: any(named: 'status'),
            )).thenAnswer((_) async => testStatus);

        final container = createContainer();
        // Wait for initial async build to complete
        await container.read(safetyProvider.future);

        // Act
        await container.read(safetyProvider.notifier).updateSafetyStatus(
              status: SafetyStatusType.safe,
            );

        // Assert
        final state = container.read(safetyProvider).value!;
        expect(state.currentStatus?.status, equals(SafetyStatusType.safe));
        expect(state.isProcessing, isFalse);

        container.dispose();
      });

      test('updates status to needHelp', () async {
        // Arrange
        final testStatus = createTestSafetyStatus(
          status: SafetyStatusType.needHelp,
        );
        when(() => mockUpdateSafetyStatus(
              status: any(named: 'status'),
            )).thenAnswer((_) async => testStatus);

        final container = createContainer();
        // Wait for initial async build to complete
        await container.read(safetyProvider.future);

        // Act
        await container.read(safetyProvider.notifier).updateSafetyStatus(
              status: SafetyStatusType.needHelp,
            );

        // Assert
        final state = container.read(safetyProvider).value!;
        expect(state.currentStatus?.status, equals(SafetyStatusType.needHelp));

        container.dispose();
      });

      test('handles errors during status update', () async {
        // Arrange
        when(() => mockUpdateSafetyStatus(
              status: any(named: 'status'),
            )).thenThrow(const ServerException(message: 'Update failed'));

        final container = createContainer();
        // Wait for initial async build to complete
        await container.read(safetyProvider.future);

        // Act
        await container.read(safetyProvider.notifier).updateSafetyStatus(
              status: SafetyStatusType.emergency,
            );

        // Assert
        final asyncState = container.read(safetyProvider);
        expect(asyncState, isA<AsyncError>());

        container.dispose();
      });
    });

    group('markAsSafe', () {
      test('marks user as safe', () async {
        // Arrange
        final testStatus =
            createTestSafetyStatus(status: SafetyStatusType.safe);
        when(() => mockUpdateSafetyStatus(
              status: any(named: 'status'),
            )).thenAnswer((_) async => testStatus);

        final container = createContainer();
        // Wait for initial async build to complete
        await container.read(safetyProvider.future);

        // Act
        await container.read(safetyProvider.notifier).markAsSafe();

        // Assert
        final state = container.read(safetyProvider).value!;
        expect(state.currentStatus?.status, equals(SafetyStatusType.safe));

        container.dispose();
      });
    });

    group('markAsNeedHelp', () {
      test('marks user as needing help', () async {
        // Arrange
        final testStatus =
            createTestSafetyStatus(status: SafetyStatusType.needHelp);
        when(() => mockUpdateSafetyStatus(
              status: any(named: 'status'),
            )).thenAnswer((_) async => testStatus);

        final container = createContainer();
        // Wait for initial async build to complete
        await container.read(safetyProvider.future);

        // Act
        await container.read(safetyProvider.notifier).markAsNeedHelp();

        // Assert
        final state = container.read(safetyProvider).value!;
        expect(state.currentStatus?.status, equals(SafetyStatusType.needHelp));

        container.dispose();
      });
    });

    group('markAsEmergency', () {
      test('marks user as in emergency', () async {
        // Arrange
        final testStatus =
            createTestSafetyStatus(status: SafetyStatusType.emergency);
        when(() => mockUpdateSafetyStatus(
              status: any(named: 'status'),
            )).thenAnswer((_) async => testStatus);

        final container = createContainer();
        // Wait for initial async build to complete
        await container.read(safetyProvider.future);

        // Act
        await container.read(safetyProvider.notifier).markAsEmergency();

        // Assert
        final state = container.read(safetyProvider).value!;
        expect(state.currentStatus?.status,
            equals(SafetyStatusType.emergency));

        container.dispose();
      });
    });

    group('loadRecentAlerts', () {
      test('loads recent alerts', () async {
        // Arrange
        final testAlerts = createTestSafetyAlertsList(count: 3);
        when(() => mockRepository.getRecentSafetyAlerts(limit: any(named: 'limit')))
            .thenAnswer((_) async => testAlerts);

        final container = createContainer();

        // Act
        await container.read(safetyProvider.notifier).loadRecentAlerts();

        // Assert
        final state = container.read(safetyProvider).value!;
        expect(state.recentAlerts, hasLength(3));
        expect(container.read(safetyProvider).isLoading, isFalse);

        container.dispose();
      });
    });

    group('SafetyState computed values', () {
      test('hasActiveEmergency is true when active alerts exist', () {
        final state = SafetyState(
          activeAlerts: createTestSafetyAlertsList(count: 1),
        );
        expect(state.hasActiveEmergency, isTrue);
      });

      test('hasActiveEmergency is false when no active alerts', () {
        const state = SafetyState();
        expect(state.hasActiveEmergency, isFalse);
      });

      test('isInDanger is true when status is emergency', () {
        final state = SafetyState(
          currentStatus:
              createTestSafetyStatus(status: SafetyStatusType.emergency),
        );
        expect(state.isInDanger, isTrue);
      });

      test('isInDanger is true when status is needHelp', () {
        final state = SafetyState(
          currentStatus:
              createTestSafetyStatus(status: SafetyStatusType.needHelp),
        );
        expect(state.isInDanger, isTrue);
      });

      test('isInDanger is false when status is safe', () {
        final state = SafetyState(
          currentStatus:
              createTestSafetyStatus(status: SafetyStatusType.safe),
        );
        expect(state.isInDanger, isFalse);
      });

      test('isInitialized is true when currentStatus is set', () {
        final state = SafetyState(
          currentStatus: createTestSafetyStatus(),
        );
        expect(state.isInitialized, isTrue);
      });

      test('isInitialized is false when currentStatus is null', () {
        const state = SafetyState();
        expect(state.isInitialized, isFalse);
      });
    });
  });
}
