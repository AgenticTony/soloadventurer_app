import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import 'package:soloadventurer/features/safety/domain/entities/location_update.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_status.dart';
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';

/// Interface for local safety data operations
abstract class SafetyLocalDataSource {
  // ==================== Trusted Contacts Operations ====================

  /// Cache trusted contacts list
  Future<void> cacheTrustedContacts(List<TrustedContact> contacts);

  /// Get cached trusted contacts
  Future<List<TrustedContact>> getCachedTrustedContacts();

  /// Cache a single trusted contact
  Future<void> cacheTrustedContact(TrustedContact contact);

  /// Get cached trusted contact by ID
  Future<TrustedContact?> getCachedTrustedContact(String contactId);

  /// Remove cached trusted contact
  Future<void> removeCachedTrustedContact(String contactId);

  // ==================== Check-ins Operations ====================

  /// Cache check-ins list
  Future<void> cacheCheckIns(List<CheckIn> checkIns);

  /// Get cached check-ins
  Future<List<CheckIn>> getCachedCheckIns();

  /// Get upcoming check-ins from cache
  Future<List<CheckIn>> getCachedUpcomingCheckIns();

  /// Cache a single check-in
  Future<void> cacheCheckIn(CheckIn checkIn);

  /// Get cached check-in by ID
  Future<CheckIn?> getCachedCheckIn(String checkInId);

  /// Remove cached check-in
  Future<void> removeCachedCheckIn(String checkInId);

  // ==================== Location Updates Operations ====================

  /// Cache location updates list
  Future<void> cacheLocationUpdates(List<LocationUpdate> updates);

  /// Get cached location updates
  Future<List<LocationUpdate>> getCachedLocationUpdates();

  /// Get active location shares from cache
  Future<List<LocationUpdate>> getCachedActiveLocationShares();

  /// Cache a single location update
  Future<void> cacheLocationUpdate(LocationUpdate update);

  /// Get cached location update by ID
  Future<LocationUpdate?> getCachedLocationUpdate(String updateId);

  // ==================== Safety Alerts Operations ====================

  /// Cache safety alerts list
  Future<void> cacheSafetyAlerts(List<SafetyAlert> alerts);

  /// Get cached safety alerts
  Future<List<SafetyAlert>> getCachedSafetyAlerts();

  /// Get recent safety alerts from cache
  Future<List<SafetyAlert>> getCachedRecentSafetyAlerts({int limit = 20});

  /// Cache a single safety alert
  Future<void> cacheSafetyAlert(SafetyAlert alert);

  /// Get cached safety alert by ID
  Future<SafetyAlert?> getCachedSafetyAlert(String alertId);

  /// Get missed check-in alerts from cache
  Future<List<SafetyAlert>> getCachedMissedCheckInAlerts();

  // ==================== Safety Status Operations ====================

  /// Cache current safety status
  Future<void> cacheSafetyStatus(SafetyStatus status);

  /// Get cached safety status
  Future<SafetyStatus?> getCachedSafetyStatus();

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
