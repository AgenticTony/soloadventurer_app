import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import 'package:soloadventurer/features/safety/domain/usecases/create_check_in.dart';
import '../../../../helpers/safety_test_helpers.dart';
import '../../../../helpers/safety_test_setup.dart';

void main() {
  late SafetyTestSetup testSetup;
  late CreateCheckInUseCase createCheckInUseCase;

  setUp(() {
    testSetup = SafetyTestSetup()..setUp();
    createCheckInUseCase = testSetup.createCheckInUseCase;
  });

  tearDown(() {
    testSetup.tearDown();
  });

  group('CreateCheckInUseCase', () {
    test('should return CheckIn when creation is successful', () async {
      // Arrange
      final testCheckIn = createTestCheckIn();
      testSetup.setupSuccessfulCheckInOperations();

      // Act
      final result = await createCheckInUseCase(testCheckIn);

      // Assert
      expect(result, isA<CheckIn>());
      expect(result.id, equals(testCheckIn.id));
      expect(result.userId, equals(testCheckIn.userId));
      expect(result.triggerType, equals(testCheckIn.triggerType));
    });

    test('should call repository with correct parameters', () async {
      // Arrange
      final testCheckIn = createTestCheckIn();
      testSetup.setupSuccessfulCheckInOperations();

      // Act
      await createCheckInUseCase(testCheckIn);

      // Assert
      verify(() => testSetup.mockRepository.createCheckIn(testCheckIn))
          .called(1);
    });

    test('should throw when repository throws', () async {
      // Arrange
      final testCheckIn = createTestCheckIn();
      const errorMessage = 'Failed to create check-in';
      testSetup.setupFailedCheckInOperations(errorMessage);

      // Act & Assert
      expect(
        () => createCheckInUseCase(testCheckIn),
        throwsA(isA<Exception>()),
      );
    });

    test('should create manual check-in', () async {
      // Arrange
      final manualCheckIn = createTestCheckIn(
        triggerType: CheckInTriggerType.manual,
        status: CheckInStatus.completed,
      );
      testSetup.setupSuccessfulCheckInOperations();

      // Act
      final result = await createCheckInUseCase(manualCheckIn);

      // Assert
      expect(result.triggerType, equals(CheckInTriggerType.manual));
      expect(result.status, equals(CheckInStatus.completed));
      verify(() => testSetup.mockRepository.createCheckIn(manualCheckIn))
          .called(1);
    });

    test('should create scheduled time check-in', () async {
      // Arrange
      final scheduledTime = DateTime(2024, 1, 1, 15, 0);
      final scheduledCheckIn = createTestCheckIn(
        triggerType: CheckInTriggerType.scheduledTime,
        status: CheckInStatus.scheduled,
        scheduledTime: scheduledTime,
      );
      testSetup.setupSuccessfulCheckInOperations();

      // Act
      final result = await createCheckInUseCase(scheduledCheckIn);

      // Assert
      expect(result.triggerType, equals(CheckInTriggerType.scheduledTime));
      expect(result.status, equals(CheckInStatus.scheduled));
      expect(result.scheduledTime, equals(scheduledTime));
      verify(() => testSetup.mockRepository.createCheckIn(scheduledCheckIn))
          .called(1);
    });

    test('should create location arrival check-in', () async {
      // Arrange
      final location = createTestCheckInLocation();
      final locationArrivalCheckIn = createTestCheckIn(
        triggerType: CheckInTriggerType.locationArrival,
        status: CheckInStatus.scheduled,
        location: location,
      );
      testSetup.setupSuccessfulCheckInOperations();

      // Act
      final result = await createCheckInUseCase(locationArrivalCheckIn);

      // Assert
      expect(result.triggerType, equals(CheckInTriggerType.locationArrival));
      expect(result.location, isNotNull);
      expect(result.location!.latitude, equals(location.latitude));
      expect(result.location!.longitude, equals(location.longitude));
      verify(() =>
              testSetup.mockRepository.createCheckIn(locationArrivalCheckIn))
          .called(1);
    });

    test('should create location departure check-in', () async {
      // Arrange
      final locationDepartureCheckIn = createTestCheckIn(
        triggerType: CheckInTriggerType.locationDeparture,
        status: CheckInStatus.scheduled,
      );
      testSetup.setupSuccessfulCheckInOperations();

      // Act
      final result = await createCheckInUseCase(locationDepartureCheckIn);

      // Assert
      expect(result.triggerType,
          equals(CheckInTriggerType.locationDeparture));
      verify(() =>
              testSetup.mockRepository.createCheckIn(locationDepartureCheckIn))
          .called(1);
    });

    test('should create check-in with location details', () async {
      // Arrange
      final location = CheckInLocation(
        latitude: testLatitude,
        longitude: testLongitude,
        accuracy: testAccuracy,
        altitude: testAltitude,
        address: '123 Main St',
        placeName: 'Central Park',
        timestamp: testDateTime,
      );
      final checkInWithLocation = createTestCheckIn(location: location);
      testSetup.setupSuccessfulCheckInOperations();

      // Act
      final result = await createCheckInUseCase(checkInWithLocation);

      // Assert
      expect(result.location, isNotNull);
      expect(result.location!.latitude, equals(testLatitude));
      expect(result.location!.longitude, equals(testLongitude));
      expect(result.location!.address, equals('123 Main St'));
      expect(result.location!.placeName, equals('Central Park'));
      expect(result.location!.accuracy, equals(testAccuracy));
      expect(result.location!.altitude, equals(testAltitude));
    });

    test('should create check-in with status message', () async {
      // Arrange
      const message = testStatusMessage;
      final checkInWithMessage = createTestCheckIn(statusMessage: message);
      testSetup.setupSuccessfulCheckInOperations();

      // Act
      final result = await createCheckInUseCase(checkInWithMessage);

      // Assert
      expect(result.statusMessage, equals(message));
    });

    test('should create check-in with deadline', () async {
      // Arrange
      final deadline = DateTime(2024, 1, 1, 16, 0);
      final checkInWithDeadline = createTestCheckIn(deadline: deadline);
      testSetup.setupSuccessfulCheckInOperations();

      // Act
      final result = await createCheckInUseCase(checkInWithDeadline);

      // Assert
      expect(result.deadline, equals(deadline));
    });

    test('should create check-in with trip ID', () async {
      // Arrange
      final tripId = testTripId;
      final checkInWithTrip = createTestCheckIn(tripId: tripId);
      testSetup.setupSuccessfulCheckInOperations();

      // Act
      final result = await createCheckInUseCase(checkInWithTrip);

      // Assert
      expect(result.tripId, equals(tripId));
    });

    test('should create check-in with multiple notify contact IDs', () async {
      // Arrange
      final contactIds = ['contact-1', 'contact-2', 'contact-3'];
      final checkInWithMultipleContacts =
          createTestCheckIn(notifyContactIds: contactIds);
      testSetup.setupSuccessfulCheckInOperations();

      // Act
      final result = await createCheckInUseCase(checkInWithMultipleContacts);

      // Assert
      expect(result.notifyContactIds, equals(contactIds));
      expect(result.notifyContactIds.length, equals(3));
    });

    test('should create check-in with empty notify contact IDs', () async {
      // Arrange
      final checkInWithNoContacts =
          createTestCheckIn(notifyContactIds: []);
      testSetup.setupSuccessfulCheckInOperations();

      // Act
      final result = await createCheckInUseCase(checkInWithNoContacts);

      // Assert
      expect(result.notifyContactIds, isEmpty);
    });

    test('should create check-in with alert sent flag', () async {
      // Arrange
      final checkInWithAlert = createTestCheckIn(
        alertSent: true,
        alertSentAt: testDateTime,
      );
      testSetup.setupSuccessfulCheckInOperations();

      // Act
      final result = await createCheckInUseCase(checkInWithAlert);

      // Assert
      expect(result.alertSent, isTrue);
      expect(result.alertSentAt, equals(testDateTime));
    });

    test('should create check-in with completed timestamp', () async {
      // Arrange
      final completedAt = DateTime(2024, 1, 1, 14, 30);
      final completedCheckIn = createTestCheckIn(
        status: CheckInStatus.completed,
        completedAt: completedAt,
      );
      testSetup.setupSuccessfulCheckInOperations();

      // Act
      final result = await createCheckInUseCase(completedCheckIn);

      // Assert
      expect(result.status, equals(CheckInStatus.completed));
      expect(result.completedAt, equals(completedAt));
    });

    test('should create check-in with metadata', () async {
      // Arrange
      final metadata = {
        'weather': 'sunny',
        'temperature': '72°F',
      };
      final checkInWithMetadata = createTestCheckIn(
        status: CheckInStatus.completed,
      ).copyWith(metadata: metadata);

      // Mock setup that returns the check-in with metadata
      when(() => testSetup.mockRepository.createCheckIn(any()))
          .thenAnswer((_) async => checkInWithMetadata);

      // Act
      final result = await createCheckInUseCase(checkInWithMetadata);

      // Assert
      expect(result.metadata, equals(metadata));
      expect(result.metadata!['weather'], equals('sunny'));
      expect(result.metadata!['temperature'], equals('72°F'));
    });

    test('should create check-in with all scheduled statuses', () async {
      // Arrange
      testSetup.setupSuccessfulCheckInOperations();

      // Act & Assert - Scheduled
      final scheduledCheckIn =
          createTestCheckIn(status: CheckInStatus.scheduled);
      var result = await createCheckInUseCase(scheduledCheckIn);
      expect(result.status, equals(CheckInStatus.scheduled));

      // Act & Assert - Active
      final activeCheckIn = createTestCheckIn(status: CheckInStatus.active);
      result = await createCheckInUseCase(activeCheckIn);
      expect(result.status, equals(CheckInStatus.active));
    });

    test('should create check-in with all completion statuses', () async {
      // Arrange
      testSetup.setupSuccessfulCheckInOperations();

      // Act & Assert - Completed
      final completedCheckIn =
          createTestCheckIn(status: CheckInStatus.completed);
      var result = await createCheckInUseCase(completedCheckIn);
      expect(result.status, equals(CheckInStatus.completed));

      // Act & Assert - Missed
      final missedCheckIn = createTestCheckIn(status: CheckInStatus.missed);
      result = await createCheckInUseCase(missedCheckIn);
      expect(result.status, equals(CheckInStatus.missed));

      // Act & Assert - Cancelled
      final cancelledCheckIn =
          createTestCheckIn(status: CheckInStatus.cancelled);
      result = await createCheckInUseCase(cancelledCheckIn);
      expect(result.status, equals(CheckInStatus.cancelled));
    });
  });
}
