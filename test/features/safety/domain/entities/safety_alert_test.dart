import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import '../../../../helpers/safety_test_helpers.dart';

void main() {
  group('SafetyAlert Entity', () {
    test('should create a valid SafetyAlert instance', () {
      // Arrange & Act
      final alert = createTestSafetyAlert();

      // Assert
      expect(alert.id, equals(testAlertId));
      expect(alert.userId, equals(testUserId));
      expect(alert.type, equals(SafetyAlertType.emergencySOS));
      expect(alert.status, equals(SafetyAlertStatus.sent));
      expect(alert.notifiedContactIds, equals([testContactId]));
      expect(alert.acknowledgedByContactIds, isEmpty);
      expect(alert.batteryLevel, equals(85));
    });

    test('should create a SafetyAlert with optional fields as null', () {
      // Arrange & Act
      final alert = SafetyAlert(
        id: testAlertId,
        userId: testUserId,
        type: SafetyAlertType.emergencySOS,
        status: SafetyAlertStatus.sent,
        notifiedContactIds: [testContactId],
        acknowledgedByContactIds: [],
        triggeredAt: testDateTime,
        createdAt: testDateTime,
      );

      // Assert
      expect(alert.message, isNull);
      expect(alert.location, isNull);
      expect(alert.firstAcknowledgedAt, isNull);
      expect(alert.resolvedAt, isNull);
      expect(alert.cancelledAt, isNull);
      expect(alert.batteryLevel, isNull);
      expect(alert.checkInId, isNull);
      expect(alert.tripId, isNull);
      expect(alert.updatedAt, isNull);
      expect(alert.metadata, isNull);
    });

    test('should compare equal when all properties match', () {
      // Arrange
      final alert1 = createTestSafetyAlert();
      final alert2 = createTestSafetyAlert();

      // Assert
      expect(alert1, equals(alert2));
    });

    test('should not compare equal when any property differs', () {
      // Arrange
      final alert1 = createTestSafetyAlert();
      final alert2 =
          createTestSafetyAlert(status: SafetyAlertStatus.acknowledged);

      // Assert
      expect(alert1, isNot(equals(alert2)));
    });

    test('should handle SafetyAlertType enum values correctly', () {
      // Assert
      expect(
          SafetyAlertType.emergencySOS, equals(SafetyAlertType.emergencySOS));
      expect(SafetyAlertType.needHelp, equals(SafetyAlertType.needHelp));
      expect(SafetyAlertType.emergency, equals(SafetyAlertType.emergency));
      expect(
          SafetyAlertType.missedCheckIn, equals(SafetyAlertType.missedCheckIn));
      expect(SafetyAlertType.locationUpdate,
          equals(SafetyAlertType.locationUpdate));
      expect(SafetyAlertType.safe, equals(SafetyAlertType.safe));
      expect(SafetyAlertType.emergencySOS,
          isNot(equals(SafetyAlertType.needHelp)));
    });

    test('should handle SafetyAlertStatus enum values correctly', () {
      // Assert
      expect(SafetyAlertStatus.sent, equals(SafetyAlertStatus.sent));
      expect(SafetyAlertStatus.acknowledged,
          equals(SafetyAlertStatus.acknowledged));
      expect(SafetyAlertStatus.resolved, equals(SafetyAlertStatus.resolved));
      expect(SafetyAlertStatus.cancelled, equals(SafetyAlertStatus.cancelled));
      expect(SafetyAlertStatus.sent,
          isNot(equals(SafetyAlertStatus.acknowledged)));
    });

    test('should handle multiple notified contact IDs', () {
      // Arrange & Act
      final contactIds = ['contact-1', 'contact-2', 'contact-3'];
      final alert = createTestSafetyAlert(notifiedContactIds: contactIds);

      // Assert
      expect(alert.notifiedContactIds, equals(contactIds));
      expect(alert.notifiedContactIds.length, equals(3));
    });

    test('should handle multiple acknowledged by contact IDs', () {
      // Arrange & Act
      final acknowledgedIds = ['contact-1', 'contact-2'];
      final alert = createTestSafetyAlert(
        acknowledgedByContactIds: acknowledgedIds,
      );

      // Assert
      expect(alert.acknowledgedByContactIds, equals(acknowledgedIds));
      expect(alert.acknowledgedByContactIds.length, equals(2));
    });

    test('should handle all timestamp fields', () {
      // Arrange & Act
      final triggeredAt = DateTime(2024, 1, 1, 10, 0);
      final firstAcknowledgedAt = DateTime(2024, 1, 1, 10, 30);
      final resolvedAt = DateTime(2024, 1, 1, 11, 0);

      final alert = createTestSafetyAlert(
        triggeredAt: triggeredAt,
        firstAcknowledgedAt: firstAcknowledgedAt,
        resolvedAt: resolvedAt,
      );

      // Assert
      expect(alert.triggeredAt, equals(triggeredAt));
      expect(alert.firstAcknowledgedAt, equals(firstAcknowledgedAt));
      expect(alert.resolvedAt, equals(resolvedAt));
    });
  });

  group('SafetyAlertLocation Entity', () {
    test('should create a valid SafetyAlertLocation instance', () {
      // Arrange & Act
      final location = createTestSafetyAlertLocation();

      // Assert
      expect(location.latitude, equals(testLatitude));
      expect(location.longitude, equals(testLongitude));
      expect(location.accuracy, equals(testAccuracy));
      expect(location.altitude, equals(testAltitude));
      expect(location.timestamp, equals(testDateTime));
    });

    test('should create a SafetyAlertLocation with optional fields as null',
        () {
      // Arrange & Act
      final location = SafetyAlertLocation(
        latitude: testLatitude,
        longitude: testLongitude,
        timestamp: testDateTime,
      );

      // Assert
      expect(location.accuracy, isNull);
      expect(location.altitude, isNull);
      expect(location.address, isNull);
      expect(location.placeName, isNull);
      expect(location.mapsUrl, isNull);
    });

    test('should create a SafetyAlertLocation with all fields', () {
      // Arrange & Act
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

      // Assert
      expect(location.address, equals('123 Main St'));
      expect(location.placeName, equals('Central Park'));
      expect(location.mapsUrl, isNotNull);
    });

    test('should compare equal when all properties match', () {
      // Arrange
      final location1 = createTestSafetyAlertLocation();
      final location2 = createTestSafetyAlertLocation();

      // Assert
      expect(location1, equals(location2));
    });

    test('should not compare equal when any property differs', () {
      // Arrange
      final location1 = createTestSafetyAlertLocation();
      final location2 = createTestSafetyAlertLocation(latitude: 41.0);

      // Assert
      expect(location1, isNot(equals(location2)));
    });
  });

  group('SafetyAlert with various types', () {
    test('should create emergency SOS alert', () {
      // Arrange & Act
      final alert = createTestSafetyAlert(
        type: SafetyAlertType.emergencySOS,
        message: testEmergencyMessage,
      );

      // Assert
      expect(alert.type, equals(SafetyAlertType.emergencySOS));
      expect(alert.message, equals(testEmergencyMessage));
    });

    test('should create need help alert', () {
      // Arrange & Act
      final alert = createTestSafetyAlert(
        type: SafetyAlertType.needHelp,
        message: 'I need some help',
      );

      // Assert
      expect(alert.type, equals(SafetyAlertType.needHelp));
      expect(alert.message, equals('I need some help'));
    });

    test('should create emergency status alert', () {
      // Arrange & Act
      final alert = createTestSafetyAlert(
        type: SafetyAlertType.emergency,
      );

      // Assert
      expect(alert.type, equals(SafetyAlertType.emergency));
    });

    test('should create missed check-in alert', () {
      // Arrange & Act
      final alert = createTestSafetyAlert(
        type: SafetyAlertType.missedCheckIn,
        checkInId: testCheckInId,
      );

      // Assert
      expect(alert.type, equals(SafetyAlertType.missedCheckIn));
      expect(alert.checkInId, equals(testCheckInId));
    });

    test('should create location update alert', () {
      // Arrange & Act
      final alert = createTestSafetyAlert(
        type: SafetyAlertType.locationUpdate,
      );

      // Assert
      expect(alert.type, equals(SafetyAlertType.locationUpdate));
    });

    test('should create safe status alert', () {
      // Arrange & Act
      final alert = createTestSafetyAlert(
        type: SafetyAlertType.safe,
        message: testStatusMessage,
      );

      // Assert
      expect(alert.type, equals(SafetyAlertType.safe));
      expect(alert.message, equals(testStatusMessage));
    });
  });

  group('SafetyAlert with various statuses', () {
    test('should create sent alert', () {
      // Arrange & Act
      final alert = createTestSafetyAlert(status: SafetyAlertStatus.sent);

      // Assert
      expect(alert.status, equals(SafetyAlertStatus.sent));
      expect(alert.acknowledgedByContactIds, isEmpty);
    });

    test('should create acknowledged alert', () {
      // Arrange & Act
      final firstAcknowledgedAt = DateTime(2024, 1, 1, 10, 30);
      final acknowledgedIds = ['contact-1'];
      final alert = createTestSafetyAlert(
        status: SafetyAlertStatus.acknowledged,
        firstAcknowledgedAt: firstAcknowledgedAt,
        acknowledgedByContactIds: acknowledgedIds,
      );

      // Assert
      expect(alert.status, equals(SafetyAlertStatus.acknowledged));
      expect(alert.firstAcknowledgedAt, equals(firstAcknowledgedAt));
      expect(alert.acknowledgedByContactIds, equals(acknowledgedIds));
    });

    test('should create resolved alert', () {
      // Arrange & Act
      final resolvedAt = DateTime(2024, 1, 1, 11, 0);
      final alert = createTestSafetyAlert(
        status: SafetyAlertStatus.resolved,
        resolvedAt: resolvedAt,
      );

      // Assert
      expect(alert.status, equals(SafetyAlertStatus.resolved));
      expect(alert.resolvedAt, equals(resolvedAt));
    });

    test('should create cancelled alert', () {
      // Arrange & Act
      final cancelledAt = DateTime(2024, 1, 1, 10, 15);
      final alert = createTestSafetyAlert(
        status: SafetyAlertStatus.cancelled,
        cancelledAt: cancelledAt,
      );

      // Assert
      expect(alert.status, equals(SafetyAlertStatus.cancelled));
      expect(alert.cancelledAt, equals(cancelledAt));
    });
  });

  group('SafetyAlert with battery level', () {
    test('should create alert with battery level', () {
      // Arrange & Act
      final alert = createTestSafetyAlert(batteryLevel: 50);

      // Assert
      expect(alert.batteryLevel, equals(50));
    });

    test('should create alert with critical battery level', () {
      // Arrange & Act
      final alert = createTestSafetyAlert(batteryLevel: 5);

      // Assert
      expect(alert.batteryLevel, equals(5));
    });

    test('should create alert with full battery level', () {
      // Arrange & Act
      final alert = createTestSafetyAlert(batteryLevel: 100);

      // Assert
      expect(alert.batteryLevel, equals(100));
    });
  });

  group('SafetyAlert with associations', () {
    test('should create alert associated with check-in', () {
      // Arrange & Act
      final alert = createTestSafetyAlert(
        type: SafetyAlertType.missedCheckIn,
        checkInId: testCheckInId,
      );

      // Assert
      expect(alert.checkInId, equals(testCheckInId));
      expect(alert.tripId, isNull);
    });

    test('should create alert associated with trip', () {
      // Arrange & Act
      final alert = createTestSafetyAlert(
        type: SafetyAlertType.emergencySOS,
        tripId: testTripId,
      );

      // Assert
      expect(alert.tripId, equals(testTripId));
      expect(alert.checkInId, isNull);
    });

    test('should create alert with both check-in and trip', () {
      // Arrange & Act
      final alert = createTestSafetyAlert(
        type: SafetyAlertType.missedCheckIn,
        checkInId: testCheckInId,
        tripId: testTripId,
      );

      // Assert
      expect(alert.checkInId, equals(testCheckInId));
      expect(alert.tripId, equals(testTripId));
    });
  });
}
