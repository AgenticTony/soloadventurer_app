import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import 'package:soloadventurer/features/safety/domain/entities/location_update.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_status.dart';
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';

/// Repository interface for safety-related operations
abstract class SafetyRepository {
  // ==================== Trusted Contacts Operations ====================

  /// Add a new trusted contact for the user
  Future<TrustedContact> addTrustedContact(TrustedContact contact);

  /// Remove a trusted contact
  Future<void> removeTrustedContact(String contactId);

  /// Update an existing trusted contact
  Future<TrustedContact> updateTrustedContact(TrustedContact contact);

  /// Get all trusted contacts for the current user
  Future<List<TrustedContact>> getTrustedContacts();

  /// Get a specific trusted contact by ID
  Future<TrustedContact> getTrustedContact(String contactId);

  // ==================== Check-in Operations ====================

  /// Create a new check-in (manual or scheduled)
  Future<CheckIn> createCheckIn(CheckIn checkIn);

  /// Complete a check-in manually
  Future<CheckIn> completeCheckIn({
    required String checkInId,
    required CheckInLocation location,
    String? statusMessage,
  });

  /// Schedule a check-in for a specific time or location
  Future<CheckIn> scheduleCheckIn({
    required String userId,
    required DateTime scheduledTime,
    DateTime? deadline,
    CheckInLocation? location,
    String? statusMessage,
    List<String>? notifyContactIds,
    String? tripId,
    CheckInTriggerType? triggerType,
  });

  /// Cancel a scheduled check-in
  Future<void> cancelCheckIn(String checkInId);

  /// Get upcoming scheduled check-ins
  Future<List<CheckIn>> getUpcomingCheckIns();

  /// Get all check-ins (completed, missed, scheduled)
  Future<List<CheckIn>> getAllCheckIns();

  /// Get a specific check-in by ID
  Future<CheckIn> getCheckIn(String checkInId);

  /// Get check-ins for a specific trip
  Future<List<CheckIn>> getCheckInsByTrip(String tripId);

  /// Update check-in status (e.g., mark as missed)
  Future<CheckIn> updateCheckInStatus({
    required String checkInId,
    required CheckInStatus status,
  });

  // ==================== Location Sharing Operations ====================

  /// Share current location with trusted contacts
  Future<LocationUpdate> shareLocation({
    required double latitude,
    required double longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    String? address,
    String? placeName,
    required List<String> shareWithContactIds,
    int? batteryLevel,
    bool isEmergency = false,
    String? emergencyAlertId,
    String? checkInId,
  });

  /// Stop sharing location with specific contacts
  Future<void> stopLocationSharing(List<String> contactIds);

  /// Stop all location sharing
  Future<void> stopAllLocationSharing();

  /// Get currently active location shares
  Future<List<LocationUpdate>> getActiveLocationShares();

  /// Get recent location updates
  Future<List<LocationUpdate>> getLocationUpdates({
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Update location sharing status for a contact
  Future<void> updateLocationSharingPermission({
    required String contactId,
    required bool enabled,
  });

  // ==================== Emergency SOS Operations ====================

  /// Trigger an emergency SOS alert
  Future<SafetyAlert> triggerEmergencySOS({
    required String userId,
    String? message,
    required SafetyAlertLocation location,
    required List<String> notifyContactIds,
    int? batteryLevel,
    String? tripId,
  });

  /// Update the user's safety status
  Future<SafetyStatus> updateSafetyStatus({
    required SafetyStatusType status,
    String? message,
    SafetyStatusLocation? location,
    int? batteryLevel,
    String? safetyAlertId,
    String? checkInId,
  });

  /// Get the current safety status
  Future<SafetyStatus> getSafetyStatus();

  /// Get the latest safety status for a user
  Future<SafetyStatus> getSafetyStatusForUser(String userId);

  // ==================== Safety Alerts Operations ====================

  /// Get all safety alerts for the current user
  Future<List<SafetyAlert>> getSafetyAlerts();

  /// Get a specific safety alert by ID
  Future<SafetyAlert> getSafetyAlert(String alertId);

  /// Get recent safety alerts
  Future<List<SafetyAlert>> getRecentSafetyAlerts({
    int limit = 20,
    SafetyAlertType? type,
  });

  /// Acknowledge a safety alert (as a trusted contact)
  Future<void> acknowledgeSafetyAlert(String alertId, String contactId);

  /// Resolve a safety alert (user is safe)
  Future<void> resolveSafetyAlert(String alertId);

  /// Cancel a safety alert (false alarm)
  Future<void> cancelSafetyAlert(String alertId);

  /// Get alerts triggered by missed check-ins
  Future<List<SafetyAlert>> getMissedCheckInAlerts();

  // ==================== Battery & Location Services ====================

  /// Update battery level for monitoring
  Future<void> updateBatteryLevel(int level);

  /// Get current battery level
  Future<int?> getBatteryLevel();

  // ==================== Settings & Preferences ====================

  /// Update check-in notification preferences for a contact
  Future<void> updateContactNotificationPreferences({
    required String contactId,
    required bool receivesCheckIns,
    required bool receivesEmergencyAlerts,
  });

  /// Get safety settings and preferences
  Future<Map<String, dynamic>> getSafetySettings();

  /// Update safety settings
  Future<void> updateSafetySettings(Map<String, dynamic> settings);
}
