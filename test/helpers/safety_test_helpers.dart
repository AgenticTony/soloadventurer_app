import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_local_data_source.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_remote_data_source.dart';
import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import 'package:soloadventurer/features/safety/domain/entities/location_update.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_status.dart';
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';
import 'package:soloadventurer/features/safety/domain/repositories/safety_repository.dart';

// Mock classes
class MockSafetyRepository extends Mock implements SafetyRepository {}

class MockSafetyRemoteDataSource extends Mock
    implements SafetyRemoteDataSource {}

class MockSafetyLocalDataSource extends Mock implements SafetyLocalDataSource {}

// Test data - User
const testUserId = 'user-123';
const testContactId = 'contact-123';
const testCheckInId = 'checkin-123';
const testAlertId = 'alert-123';
const testTripId = 'trip-123';

// Test data - Contact
const testContactName = 'John Doe';
const testContactPhone = '+1234567890';
const testContactEmail = 'john@example.com';

// Test data - Location
const testLatitude = 40.7128;
const testLongitude = -74.0060;
const testAccuracy = 10.0;
const testAltitude = 100.0;

// Test data - Messages
const testStatusMessage = 'I am safe';
const testEmergencyMessage = 'Need help immediately';

// Helper functions
DateTime get testDateTime => DateTime(2024, 1, 1, 12, 0);
DateTime get testFutureDateTime => DateTime(2024, 1, 1, 14, 0);

/// Creates a test trusted contact
TrustedContact createTestTrustedContact({
  String id = testContactId,
  String userId = testUserId,
  String name = testContactName,
  String phoneNumber = testContactPhone,
  String? email = testContactEmail,
  ContactSource source = ContactSource.phone,
  String? communityUserId,
  ContactPermission permission = ContactPermission.fullAccess,
  bool locationSharingEnabled = false,
  bool receivesCheckIns = true,
  bool receivesEmergencyAlerts = true,
  DateTime? addedAt,
  DateTime? updatedAt,
  DateTime? revokedAt,
  String? notes,
}) {
  return TrustedContact(
    id: id,
    userId: userId,
    name: name,
    phoneNumber: phoneNumber,
    email: email,
    source: source,
    communityUserId: communityUserId,
    permission: permission,
    locationSharingEnabled: locationSharingEnabled,
    receivesCheckIns: receivesCheckIns,
    receivesEmergencyAlerts: receivesEmergencyAlerts,
    addedAt: addedAt ?? testDateTime,
    updatedAt: updatedAt,
    revokedAt: revokedAt,
    notes: notes,
  );
}

/// Creates a test check-in location
CheckInLocation createTestCheckInLocation({
  double latitude = testLatitude,
  double longitude = testLongitude,
  double? accuracy = testAccuracy,
  double? altitude = testAltitude,
  String? address,
  String? placeName,
  DateTime? timestamp,
}) {
  return CheckInLocation(
    latitude: latitude,
    longitude: longitude,
    accuracy: accuracy,
    altitude: altitude,
    address: address,
    placeName: placeName,
    timestamp: timestamp ?? testDateTime,
  );
}

/// Creates a test check-in
CheckIn createTestCheckIn({
  String id = testCheckInId,
  String userId = testUserId,
  CheckInTriggerType triggerType = CheckInTriggerType.manual,
  CheckInStatus status = CheckInStatus.scheduled,
  DateTime? scheduledTime,
  DateTime? deadline,
  DateTime? completedAt,
  CheckInLocation? location,
  String? statusMessage,
  String? tripId,
  List<String>? notifyContactIds,
  bool alertSent = false,
  DateTime? alertSentAt,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return CheckIn(
    id: id,
    userId: userId,
    triggerType: triggerType,
    status: status,
    scheduledTime: scheduledTime ?? testFutureDateTime,
    deadline: deadline,
    completedAt: completedAt,
    location: location ?? createTestCheckInLocation(),
    statusMessage: statusMessage,
    tripId: tripId,
    notifyContactIds: notifyContactIds ?? [testContactId],
    alertSent: alertSent,
    alertSentAt: alertSentAt,
    createdAt: createdAt ?? testDateTime,
    updatedAt: updatedAt,
  );
}

/// Creates a test safety alert location
SafetyAlertLocation createTestSafetyAlertLocation({
  double latitude = testLatitude,
  double longitude = testLongitude,
  double? accuracy = testAccuracy,
  double? altitude = testAltitude,
  String? address,
  String? placeName,
  DateTime? timestamp,
  String? mapsUrl,
}) {
  return SafetyAlertLocation(
    latitude: latitude,
    longitude: longitude,
    accuracy: accuracy,
    altitude: altitude,
    address: address,
    placeName: placeName,
    timestamp: timestamp ?? testDateTime,
    mapsUrl: mapsUrl,
  );
}

/// Creates a test safety alert
SafetyAlert createTestSafetyAlert({
  String id = testAlertId,
  String userId = testUserId,
  SafetyAlertType type = SafetyAlertType.emergencySOS,
  SafetyAlertStatus status = SafetyAlertStatus.sent,
  String? message,
  SafetyAlertLocation? location,
  List<String>? notifiedContactIds,
  List<String>? acknowledgedByContactIds,
  DateTime? triggeredAt,
  DateTime? firstAcknowledgedAt,
  DateTime? resolvedAt,
  DateTime? cancelledAt,
  int? batteryLevel,
  String? checkInId,
  String? tripId,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return SafetyAlert(
    id: id,
    userId: userId,
    type: type,
    status: status,
    message: message,
    location: location ?? createTestSafetyAlertLocation(),
    notifiedContactIds: notifiedContactIds ?? [testContactId],
    acknowledgedByContactIds: acknowledgedByContactIds ?? [],
    triggeredAt: triggeredAt ?? testDateTime,
    firstAcknowledgedAt: firstAcknowledgedAt,
    resolvedAt: resolvedAt,
    cancelledAt: cancelledAt,
    batteryLevel: batteryLevel ?? 85,
    checkInId: checkInId,
    tripId: tripId,
    createdAt: createdAt ?? testDateTime,
    updatedAt: updatedAt,
  );
}

/// Creates a list of test trusted contacts
List<TrustedContact> createTestTrustedContactsList({int count = 3}) {
  return List.generate(
    count,
    (index) => createTestTrustedContact(
      id: 'contact-$index',
      name: 'Contact $index',
      phoneNumber: '+123456789$index',
    ),
  );
}

/// Creates a list of test check-ins
List<CheckIn> createTestCheckInsList({int count = 3}) {
  return List.generate(
    count,
    (index) => createTestCheckIn(
      id: 'checkin-$index',
      scheduledTime: testDateTime.add(Duration(hours: index)),
    ),
  );
}

/// Creates a list of test safety alerts
List<SafetyAlert> createTestSafetyAlertsList({int count = 3}) {
  return List.generate(
    count,
    (index) => createTestSafetyAlert(
      id: 'alert-$index',
      triggeredAt: testDateTime.add(Duration(hours: index)),
    ),
  );
}

/// Creates a test safety status
SafetyStatus createTestSafetyStatus({
  String id = 'status-123',
  String userId = testUserId,
  SafetyStatusType status = SafetyStatusType.safe,
  String? message,
  SafetyStatusLocation? location,
  int? batteryLevel,
  String? safetyAlertId,
  String? checkInId,
  DateTime? timestamp,
  DateTime? updatedAt,
  Map<String, dynamic>? metadata,
}) {
  return SafetyStatus(
    id: id,
    userId: userId,
    status: status,
    message: message,
    location: location ??
        SafetyStatusLocation(
          latitude: testLatitude,
          longitude: testLongitude,
          accuracy: testAccuracy,
          timestamp: testDateTime,
        ),
    batteryLevel: batteryLevel ?? 85,
    safetyAlertId: safetyAlertId,
    checkInId: checkInId,
    timestamp: timestamp ?? testDateTime,
    updatedAt: updatedAt,
    metadata: metadata,
  );
}

/// Creates a test location update
LocationUpdate createTestLocationUpdate({
  String id = 'location-update-123',
  String userId = testUserId,
  double latitude = testLatitude,
  double longitude = testLongitude,
  double? accuracy = testAccuracy,
  double? altitude = testAltitude,
  String? address,
  String? placeName,
  int? batteryLevel,
  LocationSharingStatus sharingStatus = LocationSharingStatus.active,
  List<String>? sharedWithContactIds,
  bool isEmergency = false,
  String? checkInId,
  String? emergencyAlertId,
  Map<String, dynamic>? metadata,
  DateTime? createdAt,
}) {
  return LocationUpdate(
    id: id,
    userId: userId,
    latitude: latitude,
    longitude: longitude,
    accuracy: accuracy,
    altitude: altitude,
    address: address,
    placeName: placeName,
    batteryLevel: batteryLevel ?? 85,
    sharingStatus: sharingStatus,
    sharedWithContactIds: sharedWithContactIds ?? [testContactId],
    isEmergency: isEmergency,
    checkInId: checkInId,
    emergencyAlertId: emergencyAlertId,
    metadata: metadata,
    createdAt: createdAt ?? testDateTime,
  );
}

/// Creates a list of test safety statuses
List<SafetyStatus> createTestSafetyStatusesList({int count = 3}) {
  return List.generate(
    count,
    (index) => createTestSafetyStatus(
      id: 'status-$index',
      timestamp: testDateTime.add(Duration(hours: index)),
    ),
  );
}

/// Creates a list of test location updates
List<LocationUpdate> createTestLocationUpdatesList({int count = 3}) {
  return List.generate(
    count,
    (index) => createTestLocationUpdate(
      id: 'location-update-$index',
      createdAt: testDateTime.add(Duration(hours: index)),
    ),
  );
}
