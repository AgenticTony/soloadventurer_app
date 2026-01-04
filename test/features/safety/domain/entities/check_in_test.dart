import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import '../../../../helpers/safety_test_helpers.dart';

void main() {
  group('CheckIn Entity', () {
    test('should create a valid CheckIn instance', () {
      // Arrange & Act
      final checkIn = createTestCheckIn();

      // Assert
      expect(checkIn.id, equals(testCheckInId));
      expect(checkIn.userId, equals(testUserId));
      expect(checkIn.triggerType, equals(CheckInTriggerType.manual));
      expect(checkIn.status, equals(CheckInStatus.scheduled));
      expect(checkIn.notifyContactIds, equals([testContactId]));
    });

    test('should create a CheckIn with default alertSent value', () {
      // Arrange & Act
      final checkIn = CheckIn(
        id: testCheckInId,
        userId: testUserId,
        triggerType: CheckInTriggerType.manual,
        status: CheckInStatus.scheduled,
        notifyContactIds: [testContactId],
        createdAt: testDateTime,
      );

      // Assert
      expect(checkIn.alertSent, isFalse);
    });

    test('should create a CheckIn with optional fields as null', () {
      // Arrange & Act
      final checkIn = CheckIn(
        id: testCheckInId,
        userId: testUserId,
        triggerType: CheckInTriggerType.manual,
        status: CheckInStatus.completed,
        notifyContactIds: [],
        createdAt: testDateTime,
      );

      // Assert
      expect(checkIn.scheduledTime, isNull);
      expect(checkIn.deadline, isNull);
      expect(checkIn.completedAt, isNull);
      expect(checkIn.location, isNull);
      expect(checkIn.statusMessage, isNull);
      expect(checkIn.tripId, isNull);
      expect(checkIn.alertSentAt, isNull);
      expect(checkIn.updatedAt, isNull);
      expect(checkIn.metadata, isNull);
    });

    test('should compare equal when all properties match', () {
      // Arrange
      final checkIn1 = createTestCheckIn();
      final checkIn2 = createTestCheckIn();

      // Assert
      expect(checkIn1, equals(checkIn2));
    });

    test('should not compare equal when any property differs', () {
      // Arrange
      final checkIn1 = createTestCheckIn();
      final checkIn2 = createTestCheckIn(status: CheckInStatus.completed);

      // Assert
      expect(checkIn1, isNot(equals(checkIn2)));
    });

    test('should handle CheckInStatus enum values correctly', () {
      // Assert
      expect(CheckInStatus.scheduled, equals(CheckInStatus.scheduled));
      expect(CheckInStatus.active, equals(CheckInStatus.active));
      expect(CheckInStatus.completed, equals(CheckInStatus.completed));
      expect(CheckInStatus.missed, equals(CheckInStatus.missed));
      expect(CheckInStatus.cancelled, equals(CheckInStatus.cancelled));
      expect(CheckInStatus.scheduled, isNot(equals(CheckInStatus.completed)));
    });

    test('should handle CheckInTriggerType enum values correctly', () {
      // Assert
      expect(CheckInTriggerType.manual, equals(CheckInTriggerType.manual));
      expect(CheckInTriggerType.scheduledTime, equals(CheckInTriggerType.scheduledTime));
      expect(CheckInTriggerType.locationArrival, equals(CheckInTriggerType.locationArrival));
      expect(CheckInTriggerType.locationDeparture, equals(CheckInTriggerType.locationDeparture));
      expect(CheckInTriggerType.manual, isNot(equals(CheckInTriggerType.scheduledTime)));
    });

    test('should handle multiple notify contact IDs', () {
      // Arrange & Act
      final contactIds = ['contact-1', 'contact-2', 'contact-3'];
      final checkIn = createTestCheckIn(notifyContactIds: contactIds);

      // Assert
      expect(checkIn.notifyContactIds, equals(contactIds));
      expect(checkIn.notifyContactIds.length, equals(3));
    });

    test('should handle empty notify contact IDs list', () {
      // Arrange & Act
      final checkIn = createTestCheckIn(notifyContactIds: []);

      // Assert
      expect(checkIn.notifyContactIds, isEmpty);
    });
  });

  group('CheckInLocation Entity', () {
    test('should create a valid CheckInLocation instance', () {
      // Arrange & Act
      final location = createTestCheckInLocation();

      // Assert
      expect(location.latitude, equals(testLatitude));
      expect(location.longitude, equals(testLongitude));
      expect(location.accuracy, equals(testAccuracy));
      expect(location.altitude, equals(testAltitude));
      expect(location.timestamp, equals(testDateTime));
    });

    test('should create a CheckInLocation with optional fields as null', () {
      // Arrange & Act
      final location = CheckInLocation(
        latitude: testLatitude,
        longitude: testLongitude,
        timestamp: testDateTime,
      );

      // Assert
      expect(location.accuracy, isNull);
      expect(location.altitude, isNull);
      expect(location.address, isNull);
      expect(location.placeName, isNull);
    });

    test('should create a CheckInLocation with all fields', () {
      // Arrange & Act
      final location = CheckInLocation(
        latitude: testLatitude,
        longitude: testLongitude,
        accuracy: testAccuracy,
        altitude: testAltitude,
        address: '123 Main St',
        placeName: 'Central Park',
        timestamp: testDateTime,
      );

      // Assert
      expect(location.address, equals('123 Main St'));
      expect(location.placeName, equals('Central Park'));
    });

    test('should compare equal when all properties match', () {
      // Arrange
      final location1 = createTestCheckInLocation();
      final location2 = createTestCheckInLocation();

      // Assert
      expect(location1, equals(location2));
    });

    test('should not compare equal when any property differs', () {
      // Arrange
      final location1 = createTestCheckInLocation();
      final location2 = createTestCheckInLocation(latitude: 41.0);

      // Assert
      expect(location1, isNot(equals(location2)));
    });
  });

  group('CheckIn with various trigger types', () {
    test('should create manual check-in', () {
      // Arrange & Act
      final checkIn = createTestCheckIn(
        triggerType: CheckInTriggerType.manual,
      );

      // Assert
      expect(checkIn.triggerType, equals(CheckInTriggerType.manual));
    });

    test('should create scheduled time check-in', () {
      // Arrange & Act
      final scheduledTime = DateTime(2024, 1, 1, 15, 0);
      final checkIn = createTestCheckIn(
        triggerType: CheckInTriggerType.scheduledTime,
        scheduledTime: scheduledTime,
      );

      // Assert
      expect(checkIn.triggerType, equals(CheckInTriggerType.scheduledTime));
      expect(checkIn.scheduledTime, equals(scheduledTime));
    });

    test('should create location arrival check-in', () {
      // Arrange & Act
      final checkIn = createTestCheckIn(
        triggerType: CheckInTriggerType.locationArrival,
      );

      // Assert
      expect(checkIn.triggerType, equals(CheckInTriggerType.locationArrival));
    });

    test('should create location departure check-in', () {
      // Arrange & Act
      final checkIn = createTestCheckIn(
        triggerType: CheckInTriggerType.locationDeparture,
      );

      // Assert
      expect(checkIn.triggerType, equals(CheckInTriggerType.locationDeparture));
    });
  });

  group('CheckIn with various statuses', () {
    test('should create scheduled check-in', () {
      // Arrange & Act
      final checkIn = createTestCheckIn(status: CheckInStatus.scheduled);

      // Assert
      expect(checkIn.status, equals(CheckInStatus.scheduled));
    });

    test('should create active check-in', () {
      // Arrange & Act
      final checkIn = createTestCheckIn(status: CheckInStatus.active);

      // Assert
      expect(checkIn.status, equals(CheckInStatus.active));
    });

    test('should create completed check-in', () {
      // Arrange & Act
      final completedAt = DateTime(2024, 1, 1, 13, 0);
      final checkIn = createTestCheckIn(
        status: CheckInStatus.completed,
        completedAt: completedAt,
      );

      // Assert
      expect(checkIn.status, equals(CheckInStatus.completed));
      expect(checkIn.completedAt, equals(completedAt));
    });

    test('should create missed check-in', () {
      // Arrange & Act
      final checkIn = createTestCheckIn(status: CheckInStatus.missed);

      // Assert
      expect(checkIn.status, equals(CheckInStatus.missed));
    });

    test('should create cancelled check-in', () {
      // Arrange & Act
      final checkIn = createTestCheckIn(status: CheckInStatus.cancelled);

      // Assert
      expect(checkIn.status, equals(CheckInStatus.cancelled));
    });
  });
}
