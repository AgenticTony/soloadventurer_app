import 'package:soloadventurer/features/safety/data/models/check_in_model.dart';
import 'package:soloadventurer/features/safety/data/models/location_update_model.dart';
import 'package:soloadventurer/features/safety/data/models/safety_alert_model.dart';
import 'package:soloadventurer/features/safety/data/models/safety_status_model.dart';
import 'package:soloadventurer/features/safety/data/models/trusted_contact_model.dart';

/// Interface for local safety data operations
abstract class SafetyLocalDataSource {
  // ==================== Trusted Contacts Operations ====================

  /// Cache trusted contacts list
  Future<void> cacheTrustedContacts(List<TrustedContactModel> contacts);

  /// Get cached trusted contacts
  Future<List<TrustedContactModel>> getCachedTrustedContacts();

  /// Cache a single trusted contact
  Future<void> cacheTrustedContact(TrustedContactModel contact);

  /// Get cached trusted contact by ID
  Future<TrustedContactModel?> getCachedTrustedContact(String contactId);

  /// Remove cached trusted contact
  Future<void> removeCachedTrustedContact(String contactId);

  // ==================== Check-ins Operations ====================

  /// Cache check-ins list
  Future<void> cacheCheckIns(List<CheckInModel> checkIns);

  /// Get cached check-ins
  Future<List<CheckInModel>> getCachedCheckIns();

  /// Get upcoming check-ins from cache
  Future<List<CheckInModel>> getCachedUpcomingCheckIns();

  /// Cache a single check-in
  Future<void> cacheCheckIn(CheckInModel checkIn);

  /// Get cached check-in by ID
  Future<CheckInModel?> getCachedCheckIn(String checkInId);

  /// Remove cached check-in
  Future<void> removeCachedCheckIn(String checkInId);

  // ==================== Location Updates Operations ====================

  /// Cache location updates list
  Future<void> cacheLocationUpdates(List<LocationUpdateModel> updates);

  /// Get cached location updates
  Future<List<LocationUpdateModel>> getCachedLocationUpdates();

  /// Get active location shares from cache
  Future<List<LocationUpdateModel>> getCachedActiveLocationShares();

  /// Cache a single location update
  Future<void> cacheLocationUpdate(LocationUpdateModel update);

  /// Get cached location update by ID
  Future<LocationUpdateModel?> getCachedLocationUpdate(String updateId);

  // ==================== Safety Alerts Operations ====================

  /// Cache safety alerts list
  Future<void> cacheSafetyAlerts(List<SafetyAlertModel> alerts);

  /// Get cached safety alerts
  Future<List<SafetyAlertModel>> getCachedSafetyAlerts();

  /// Get recent safety alerts from cache
  Future<List<SafetyAlertModel>> getCachedRecentSafetyAlerts({int limit = 20});

  /// Cache a single safety alert
  Future<void> cacheSafetyAlert(SafetyAlertModel alert);

  /// Get cached safety alert by ID
  Future<SafetyAlertModel?> getCachedSafetyAlert(String alertId);

  /// Get missed check-in alerts from cache
  Future<List<SafetyAlertModel>> getCachedMissedCheckInAlerts();

  // ==================== Safety Status Operations ====================

  /// Cache current safety status
  Future<void> cacheSafetyStatus(SafetyStatusModel status);

  /// Get cached safety status
  Future<SafetyStatusModel?> getCachedSafetyStatus();

  // ==================== Battery & Settings Operations ====================

  /// Cache battery level
  Future<void> cacheBatteryLevel(int level);

  /// Get cached battery level
  Future<int?> getCachedBatteryLevel();

  /// Cache safety settings
  Future<void> cacheSafetySettings(Map<String, dynamic> settings);

  /// Get cached safety settings
  Future<Map<String, dynamic>?> getCachedSafetySettings();

  // ==================== Cache Management ====================

  /// Clear all cached safety data
  Future<void> clearAllCache();

  /// Check if cache is expired
  Future<bool> isCacheExpired();

  /// Get last cache update timestamp
  Future<DateTime?> getLastCacheUpdate();
}
