import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_status.dart';
import 'package:soloadventurer/features/safety/domain/usecases/add_trusted_contact.dart';
import 'package:soloadventurer/features/safety/domain/usecases/create_check_in.dart';
import 'package:soloadventurer/features/safety/domain/usecases/trigger_emergency_sos.dart';
import 'safety_test_helpers.dart';

/// Sets up a test environment for safety feature tests
class SafetyTestSetup {
  late MockSafetyRepository mockRepository;
  late ProviderContainer container;
  late AddTrustedContactUseCase addTrustedContactUseCase;
  late CreateCheckInUseCase createCheckInUseCase;
  late TriggerEmergencySOSUseCase triggerEmergencySOSUseCase;

  /// Initialize test dependencies
  void setUp() {
    // Register fallback values for mocktail
    // Create simple instances directly to avoid circular dependencies
    registerFallbackValue(SafetyAlertLocation(
      latitude: 0.0,
      longitude: 0.0,
      timestamp: DateTime(2024),
    ));
    registerFallbackValue(CheckInLocation(
      latitude: 0.0,
      longitude: 0.0,
      timestamp: DateTime(2024),
    ));
    registerFallbackValue(SafetyStatusLocation(
      latitude: 0.0,
      longitude: 0.0,
      timestamp: DateTime(2024),
    ));
    registerFallbackValue(TrustedContact(
      id: 'fallback',
      userId: 'fallback',
      name: 'fallback',
      phoneNumber: 'fallback',
      source: ContactSource.phone,
      permission: ContactPermission.emergencyOnly,
      addedAt: DateTime(2024),
    ));
    registerFallbackValue(CheckIn(
      id: 'fallback',
      userId: 'fallback',
      triggerType: CheckInTriggerType.manual,
      status: CheckInStatus.scheduled,
      scheduledTime: DateTime(2024),
      notifyContactIds: [],
      createdAt: DateTime(2024),
    ));
    registerFallbackValue(SafetyAlert(
      id: 'fallback',
      userId: 'fallback',
      type: SafetyAlertType.emergencySOS,
      status: SafetyAlertStatus.sent,
      notifiedContactIds: [],
      acknowledgedByContactIds: [],
      triggeredAt: DateTime(2024),
      createdAt: DateTime(2024),
    ));
    registerFallbackValue(DateTime(2024));

    mockRepository = MockSafetyRepository();
    container = ProviderContainer();

    addTrustedContactUseCase = AddTrustedContactUseCase(mockRepository);
    createCheckInUseCase = CreateCheckInUseCase(mockRepository);
    triggerEmergencySOSUseCase = TriggerEmergencySOSUseCase(mockRepository);

    addTearDown(container.dispose);
  }

  /// Clean up test dependencies
  void tearDown() {
    container.dispose();
  }

  /// Creates a test trusted contact
  TrustedContact createTestContact() {
    return createTestTrustedContact();
  }

  /// Creates a test check-in
  CheckIn createTestCheckIn() {
    return createTestCheckIn();
  }

  /// Creates a test safety alert
  SafetyAlert createTestAlert() {
    return createTestSafetyAlert();
  }
}

/// Extension methods for setting up common test scenarios
extension SafetyTestSetupExtensions on SafetyTestSetup {
  /// Sets up successful trusted contact operations
  void setupSuccessfulContactOperations() {
    when(() => mockRepository.addTrustedContact(any()))
        .thenAnswer((invocation) async => invocation.positionalArguments[0] as TrustedContact);
    when(() => mockRepository.getTrustedContacts())
        .thenAnswer((_) async => createTestTrustedContactsList());
    when(() => mockRepository.getTrustedContact(any()))
        .thenAnswer((_) async => createTestContact());
    when(() => mockRepository.updateTrustedContact(any()))
        .thenAnswer((invocation) async => invocation.positionalArguments[0] as TrustedContact);
    when(() => mockRepository.removeTrustedContact(any()))
        .thenAnswer((_) async {});
  }

  /// Sets up failed trusted contact operations
  void setupFailedContactOperations(String errorMessage) {
    when(() => mockRepository.addTrustedContact(any()))
        .thenThrow(Exception(errorMessage));
    when(() => mockRepository.getTrustedContacts())
        .thenThrow(Exception(errorMessage));
    when(() => mockRepository.getTrustedContact(any()))
        .thenThrow(Exception(errorMessage));
    when(() => mockRepository.updateTrustedContact(any()))
        .thenThrow(Exception(errorMessage));
    when(() => mockRepository.removeTrustedContact(any()))
        .thenThrow(Exception(errorMessage));
  }

  /// Sets up successful check-in operations
  void setupSuccessfulCheckInOperations() {
    when(() => mockRepository.createCheckIn(any()))
        .thenAnswer((invocation) async => invocation.positionalArguments[0] as CheckIn);
    when(() => mockRepository.getAllCheckIns())
        .thenAnswer((_) async => createTestCheckInsList());
    when(() => mockRepository.getUpcomingCheckIns())
        .thenAnswer((_) async => createTestCheckInsList());
    when(() => mockRepository.getCheckIn(any()))
        .thenAnswer((_) async => createTestCheckIn());
    when(() => mockRepository.scheduleCheckIn(
          userId: any(named: 'userId'),
          scheduledTime: any(named: 'scheduledTime'),
          deadline: any(named: 'deadline'),
          location: any(named: 'location'),
          statusMessage: any(named: 'statusMessage'),
          notifyContactIds: any(named: 'notifyContactIds'),
          tripId: any(named: 'tripId'),
          triggerType: any(named: 'triggerType'),
        )).thenAnswer((_) async => createTestCheckIn());
  }

  /// Sets up failed check-in operations
  void setupFailedCheckInOperations(String errorMessage) {
    when(() => mockRepository.createCheckIn(any()))
        .thenThrow(Exception(errorMessage));
    when(() => mockRepository.getAllCheckIns())
        .thenThrow(Exception(errorMessage));
    when(() => mockRepository.getUpcomingCheckIns())
        .thenThrow(Exception(errorMessage));
    when(() => mockRepository.getCheckIn(any()))
        .thenThrow(Exception(errorMessage));
  }

  /// Sets up successful emergency SOS operations
  void setupSuccessfulEmergencySOSOperations() {
    when(() => mockRepository.triggerEmergencySOS(
          userId: any(named: 'userId'),
          message: any(named: 'message'),
          location: any(named: 'location'),
          notifyContactIds: any(named: 'notifyContactIds'),
          batteryLevel: any(named: 'batteryLevel'),
          tripId: any(named: 'tripId'),
        )).thenAnswer((invocation) async {
          // Extract named parameters
          final userId = invocation.namedArguments[#userId] as String;
          final message = invocation.namedArguments[#message] as String?;
          final location = invocation.namedArguments[#location] as SafetyAlertLocation?;
          final notifyContactIds = invocation.namedArguments[#notifyContactIds] as List<String>?;
          final batteryLevel = invocation.namedArguments[#batteryLevel] as int?;
          final tripId = invocation.namedArguments[#tripId] as String?;
          
          // Return alert with the passed parameters
          return SafetyAlert(
            id: testAlertId,
            userId: userId,
            type: SafetyAlertType.emergencySOS,
            status: SafetyAlertStatus.sent,
            message: message,
            location: location ?? createTestSafetyAlertLocation(),
            notifiedContactIds: notifyContactIds ?? [testContactId],
            acknowledgedByContactIds: [],
            triggeredAt: testDateTime,
            batteryLevel: batteryLevel ?? 85,
            tripId: tripId,
            createdAt: testDateTime,
          );
        });
  }

  /// Sets up failed emergency SOS operations
  void setupFailedEmergencySOSOperations(String errorMessage) {
    when(() => mockRepository.triggerEmergencySOS(
          userId: any(named: 'userId'),
          message: any(named: 'message'),
          location: any(named: 'location'),
          notifyContactIds: any(named: 'notifyContactIds'),
          batteryLevel: any(named: 'batteryLevel'),
          tripId: any(named: 'tripId'),
        )).thenThrow(Exception(errorMessage));
  }
}
