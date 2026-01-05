import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';
import 'package:soloadventurer/features/safety/domain/repositories/safety_repository.dart';
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
        .thenAnswer((_) async => createTestContact());
    when(() => mockRepository.getTrustedContacts())
        .thenAnswer((_) async => createTestTrustedContactsList());
    when(() => mockRepository.getTrustedContact(any()))
        .thenAnswer((_) async => createTestContact());
    when(() => mockRepository.updateTrustedContact(any()))
        .thenAnswer((_) async => createTestContact());
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
        .thenAnswer((_) async => createTestCheckIn());
    when(() => mockRepository.getAllCheckIns())
        .thenAnswer((_) async => createTestCheckInsList());
    when(() => mockRepository.getUpcomingCheckIns())
        .thenAnswer((_) async => createTestCheckInsList());
    when(() => mockRepository.getCheckIn(any()))
        .thenAnswer((_) async => createTestCheckIn());
    when(() => mockRepository.scheduleCheckIn(
          userId: any(),
          scheduledTime: any(),
          deadline: any(),
          location: any(),
          statusMessage: any(),
          notifyContactIds: any(),
          tripId: any(),
          triggerType: any(),
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
          userId: any(),
          message: any(),
          location: any(),
          notifyContactIds: any(),
          batteryLevel: any(),
          tripId: any(),
        )).thenAnswer((_) async => createTestAlert());
  }

  /// Sets up failed emergency SOS operations
  void setupFailedEmergencySOSOperations(String errorMessage) {
    when(() => mockRepository.triggerEmergencySOS(
          userId: any(),
          message: any(),
          location: any(),
          notifyContactIds: any(),
          batteryLevel: any(),
          tripId: any(),
        )).thenThrow(Exception(errorMessage));
  }
}
