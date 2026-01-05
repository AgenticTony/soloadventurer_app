import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/usecases/trigger_emergency_sos.dart';
import '../../../../helpers/safety_test_helpers.dart';
import '../../../../helpers/safety_test_setup.dart';

void main() {
  late SafetyTestSetup testSetup;
  late TriggerEmergencySOSUseCase triggerEmergencySOSUseCase;

  setUp(() {
    testSetup = SafetyTestSetup()..setUp();
    triggerEmergencySOSUseCase = testSetup.triggerEmergencySOSUseCase;
  });

  tearDown(() {
    testSetup.tearDown();
  });

  group('TriggerEmergencySOSUseCase', () {
    test('should return SafetyAlert when trigger is successful', () async {
      // Arrange
      testSetup.setupSuccessfulEmergencySOSOperations();

      // Act
      final result = await triggerEmergencySOSUseCase(
        userId: testUserId,
        location: createTestSafetyAlertLocation(),
        notifyContactIds: [testContactId],
      );

      // Assert
      expect(result, isA<SafetyAlert>());
      expect(result.userId, equals(testUserId));
      expect(result.type, equals(SafetyAlertType.emergencySOS));
      expect(result.status, equals(SafetyAlertStatus.sent));
    });

    test('should call repository with correct parameters', () async {
      // Arrange
      final location = createTestSafetyAlertLocation();
      final contactIds = [testContactId];
      testSetup.setupSuccessfulEmergencySOSOperations();

      // Act
      await triggerEmergencySOSUseCase(
        userId: testUserId,
        location: location,
        notifyContactIds: contactIds,
      );

      // Assert
      verify(() => testSetup.mockRepository.triggerEmergencySOS(
            userId: testUserId,
            location: location,
            notifyContactIds: contactIds,
          )).called(1);
    });

    test('should call repository with message parameter', () async {
      // Arrange
      final location = createTestSafetyAlertLocation();
      const message = testEmergencyMessage;
      testSetup.setupSuccessfulEmergencySOSOperations();

      // Act
      await triggerEmergencySOSUseCase(
        userId: testUserId,
        message: message,
        location: location,
        notifyContactIds: [testContactId],
      );

      // Assert
      verify(() => testSetup.mockRepository.triggerEmergencySOS(
            userId: testUserId,
            message: message,
            location: location,
            notifyContactIds: [testContactId],
          )).called(1);
    });

    test('should call repository with battery level parameter', () async {
      // Arrange
      final location = createTestSafetyAlertLocation();
      const batteryLevel = 75;
      testSetup.setupSuccessfulEmergencySOSOperations();

      // Act
      await triggerEmergencySOSUseCase(
        userId: testUserId,
        location: location,
        notifyContactIds: [testContactId],
        batteryLevel: batteryLevel,
      );

      // Assert
      verify(() => testSetup.mockRepository.triggerEmergencySOS(
            userId: testUserId,
            location: location,
            notifyContactIds: [testContactId],
            batteryLevel: batteryLevel,
          )).called(1);
    });

    test('should call repository with trip ID parameter', () async {
      // Arrange
      final location = createTestSafetyAlertLocation();
      final tripId = testTripId;
      testSetup.setupSuccessfulEmergencySOSOperations();

      // Act
      await triggerEmergencySOSUseCase(
        userId: testUserId,
        location: location,
        notifyContactIds: [testContactId],
        tripId: tripId,
      );

      // Assert
      verify(() => testSetup.mockRepository.triggerEmergencySOS(
            userId: testUserId,
            location: location,
            notifyContactIds: [testContactId],
            tripId: tripId,
          )).called(1);
    });

    test('should call repository with all parameters', () async {
      // Arrange
      final location = createTestSafetyAlertLocation();
      const message = testEmergencyMessage;
      const batteryLevel = 60;
      final tripId = testTripId;
      testSetup.setupSuccessfulEmergencySOSOperations();

      // Act
      await triggerEmergencySOSUseCase(
        userId: testUserId,
        message: message,
        location: location,
        notifyContactIds: [testContactId],
        batteryLevel: batteryLevel,
        tripId: tripId,
      );

      // Assert
      verify(() => testSetup.mockRepository.triggerEmergencySOS(
            userId: testUserId,
            message: message,
            location: location,
            notifyContactIds: [testContactId],
            batteryLevel: batteryLevel,
            tripId: tripId,
          )).called(1);
    });

    test('should throw when repository throws', () async {
      // Arrange
      const errorMessage = 'Failed to trigger SOS';
      testSetup.setupFailedEmergencySOSOperations(errorMessage);

      // Act & Assert
      expect(
        () => triggerEmergencySOSUseCase(
          userId: testUserId,
          location: createTestSafetyAlertLocation(),
          notifyContactIds: [testContactId],
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle multiple contact IDs', () async {
      // Arrange
      final location = createTestSafetyAlertLocation();
      final contactIds = ['contact-1', 'contact-2', 'contact-3'];
      testSetup.setupSuccessfulEmergencySOSOperations();

      // Act
      final result = await triggerEmergencySOSUseCase(
        userId: testUserId,
        location: location,
        notifyContactIds: contactIds,
      );

      // Assert
      expect(result.notifiedContactIds, equals(contactIds));
      expect(result.notifiedContactIds.length, equals(3));
      verify(() => testSetup.mockRepository.triggerEmergencySOS(
            userId: testUserId,
            location: location,
            notifyContactIds: contactIds,
          )).called(1);
    });

    test('should create alert with location details', () async {
      // Arrange
      final location = SafetyAlertLocation(
        latitude: testLatitude,
        longitude: testLongitude,
        accuracy: testAccuracy,
        altitude: testAltitude,
        address: '123 Main St',
        placeName: 'Central Park',
        timestamp: testDateTime,
        mapsUrl: 'https://maps.google.com/?q=40.7128,-74.0060',
      );
      testSetup.setupSuccessfulEmergencySOSOperations();

      // Act
      final result = await triggerEmergencySOSUseCase(
        userId: testUserId,
        location: location,
        notifyContactIds: [testContactId],
      );

      // Assert
      expect(result.location, isNotNull);
      expect(result.location!.latitude, equals(testLatitude));
      expect(result.location!.longitude, equals(testLongitude));
      expect(result.location!.address, equals('123 Main St'));
      expect(result.location!.placeName, equals('Central Park'));
    });

    test('should include message in returned alert', () async {
      // Arrange
      const message = 'Need help at the airport!';
      testSetup.setupSuccessfulEmergencySOSOperations();

      // Act
      final result = await triggerEmergencySOSUseCase(
        userId: testUserId,
        message: message,
        location: createTestSafetyAlertLocation(),
        notifyContactIds: [testContactId],
      );

      // Assert
      expect(result.message, equals(message));
    });

    test('should include battery level in returned alert', () async {
      // Arrange
      const batteryLevel = 45;
      testSetup.setupSuccessfulEmergencySOSOperations();

      // Act
      final result = await triggerEmergencySOSUseCase(
        userId: testUserId,
        location: createTestSafetyAlertLocation(),
        notifyContactIds: [testContactId],
        batteryLevel: batteryLevel,
      );

      // Assert
      expect(result.batteryLevel, equals(batteryLevel));
    });

    test('should include trip ID in returned alert', () async {
      // Arrange
      final tripId = testTripId;
      testSetup.setupSuccessfulEmergencySOSOperations();

      // Act
      final result = await triggerEmergencySOSUseCase(
        userId: testUserId,
        location: createTestSafetyAlertLocation(),
        notifyContactIds: [testContactId],
        tripId: tripId,
      );

      // Assert
      expect(result.tripId, equals(tripId));
    });

    test('should set alert type to emergency SOS', () async {
      // Arrange
      testSetup.setupSuccessfulEmergencySOSOperations();

      // Act
      final result = await triggerEmergencySOSUseCase(
        userId: testUserId,
        location: createTestSafetyAlertLocation(),
        notifyContactIds: [testContactId],
      );

      // Assert
      expect(result.type, equals(SafetyAlertType.emergencySOS));
    });

    test('should set alert status to sent', () async {
      // Arrange
      testSetup.setupSuccessfulEmergencySOSOperations();

      // Act
      final result = await triggerEmergencySOSUseCase(
        userId: testUserId,
        location: createTestSafetyAlertLocation(),
        notifyContactIds: [testContactId],
      );

      // Assert
      expect(result.status, equals(SafetyAlertStatus.sent));
    });
  });
}
