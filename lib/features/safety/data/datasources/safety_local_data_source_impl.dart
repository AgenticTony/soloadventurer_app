import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/features/safety/domain/exceptions/safety_exceptions.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_local_data_source.dart';
import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import 'package:soloadventurer/features/safety/domain/entities/location_update.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_status.dart';
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';

/// Implementation of [SafetyLocalDataSource] using SharedPreferences
class SafetyLocalDataSourceImpl implements SafetyLocalDataSource {
  final SharedPreferences _sharedPreferences;

  // Cache keys
  static const String _trustedContactsKey = 'cached_trusted_contacts';
  static const String _checkInsKey = 'cached_check_ins';
  static const String _locationUpdatesKey = 'cached_location_updates';
  static const String _safetyAlertsKey = 'cached_safety_alerts';
  static const String _safetyStatusKey = 'cached_safety_status';
  static const String _batteryLevelKey = 'cached_battery_level';
  static const String _safetySettingsKey = 'cached_safety_settings';
  static const String _lastUpdateKey = 'safety_last_cache_update';

  /// Cache expiration duration (1 hour for safety-critical data)
  static const Duration cacheExpiration = Duration(hours: 1);

  /// Creates a new [SafetyLocalDataSourceImpl]
  SafetyLocalDataSourceImpl(this._sharedPreferences);

  // ==================== Trusted Contacts Operations ====================

  @override
  Future<void> cacheTrustedContacts(List<TrustedContact> contacts) async {
    try {
      final List<Map<String, dynamic>> jsonList =
          contacts.map((contact) => contact.toJson()).toList();
      await _sharedPreferences.setString(
        _trustedContactsKey,
        jsonEncode(jsonList),
      );
      await _updateLastCacheTime();
    } catch (e) {
      throw const SafetyCacheException('Failed to cache trusted contacts');
    }
  }

  @override
  Future<List<TrustedContact>> getCachedTrustedContacts() async {
    if (await isCacheExpired()) {
      return [];
    }

    try {
      final jsonString = _sharedPreferences.getString(_trustedContactsKey);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => TrustedContact.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw const SafetyCacheRetrievalException(
          'Failed to retrieve cached trusted contacts');
    }
  }

  @override
  Future<void> cacheTrustedContact(TrustedContact contact) async {
    try {
      final contacts = await getCachedTrustedContacts();
      final index = contacts.indexWhere((c) => c.id == contact.id);

      if (index >= 0) {
        contacts[index] = contact;
      } else {
        contacts.add(contact);
      }

      await cacheTrustedContacts(contacts);
    } catch (e) {
      throw const SafetyCacheException('Failed to cache trusted contact');
    }
  }

  @override
  Future<TrustedContact?> getCachedTrustedContact(String contactId) async {
    try {
      final contacts = await getCachedTrustedContacts();
      return contacts.cast<TrustedContact?>().firstWhere(
            (contact) => contact?.id == contactId,
            orElse: () => null,
          );
    } catch (e) {
      throw const SafetyCacheRetrievalException(
          'Failed to retrieve cached trusted contact');
    }
  }

  @override
  Future<void> removeCachedTrustedContact(String contactId) async {
    try {
      final contacts = await getCachedTrustedContacts();
      final updatedContacts =
          contacts.where((contact) => contact.id != contactId).toList();
      await cacheTrustedContacts(updatedContacts);
    } catch (e) {
      throw const SafetyCacheException('Failed to remove cached contact');
    }
  }

  // ==================== Check-ins Operations ====================

  @override
  Future<void> cacheCheckIns(List<CheckIn> checkIns) async {
    try {
      final List<Map<String, dynamic>> jsonList =
          checkIns.map((checkIn) => checkIn.toJson()).toList();
      await _sharedPreferences.setString(
        _checkInsKey,
        jsonEncode(jsonList),
      );
      await _updateLastCacheTime();
    } catch (e) {
      throw const SafetyCacheException('Failed to cache check-ins');
    }
  }

  @override
  Future<List<CheckIn>> getCachedCheckIns() async {
    if (await isCacheExpired()) {
      return [];
    }

    try {
      final jsonString = _sharedPreferences.getString(_checkInsKey);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => CheckIn.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw const SafetyCacheRetrievalException(
          'Failed to retrieve cached check-ins');
    }
  }

  @override
  Future<List<CheckIn>> getCachedUpcomingCheckIns() async {
    try {
      final allCheckIns = await getCachedCheckIns();
      final now = DateTime.now();

      return allCheckIns
          .where((checkIn) =>
              checkIn.scheduledTime != null &&
              checkIn.scheduledTime!.isAfter(now) &&
              (checkIn.status == CheckInStatus.scheduled ||
                  checkIn.status == CheckInStatus.active))
          .toList()
        ..sort((a, b) => a.scheduledTime!.compareTo(b.scheduledTime!));
    } catch (e) {
      throw const SafetyCacheRetrievalException(
          'Failed to retrieve upcoming check-ins');
    }
  }

  @override
  Future<void> cacheCheckIn(CheckIn checkIn) async {
    try {
      final checkIns = await getCachedCheckIns();
      final index = checkIns.indexWhere((c) => c.id == checkIn.id);

      if (index >= 0) {
        checkIns[index] = checkIn;
      } else {
        checkIns.add(checkIn);
      }

      await cacheCheckIns(checkIns);
    } catch (e) {
      throw const SafetyCacheException('Failed to cache check-in');
    }
  }

  @override
  Future<CheckIn?> getCachedCheckIn(String checkInId) async {
    try {
      final checkIns = await getCachedCheckIns();
      return checkIns.cast<CheckIn?>().firstWhere(
            (checkIn) => checkIn?.id == checkInId,
            orElse: () => null,
          );
    } catch (e) {
      throw const SafetyCacheRetrievalException(
          'Failed to retrieve cached check-in');
    }
  }

  @override
  Future<void> removeCachedCheckIn(String checkInId) async {
    try {
      final checkIns = await getCachedCheckIns();
      final updatedCheckIns =
          checkIns.where((checkIn) => checkIn.id != checkInId).toList();
      await cacheCheckIns(updatedCheckIns);
    } catch (e) {
      throw const SafetyCacheException('Failed to remove cached check-in');
    }
  }

  // ==================== Location Updates Operations ====================

  @override
  Future<void> cacheLocationUpdates(List<LocationUpdate> updates) async {
    try {
      final List<Map<String, dynamic>> jsonList =
          updates.map((update) => update.toJson()).toList();
      await _sharedPreferences.setString(
        _locationUpdatesKey,
        jsonEncode(jsonList),
      );
      await _updateLastCacheTime();
    } catch (e) {
      throw const SafetyCacheException('Failed to cache location updates');
    }
  }

  @override
  Future<List<LocationUpdate>> getCachedLocationUpdates() async {
    if (await isCacheExpired()) {
      return [];
    }

    try {
      final jsonString = _sharedPreferences.getString(_locationUpdatesKey);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => LocationUpdate.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw const SafetyCacheRetrievalException(
          'Failed to retrieve cached location updates');
    }
  }

  @override
  Future<List<LocationUpdate>> getCachedActiveLocationShares() async {
    try {
      final allUpdates = await getCachedLocationUpdates();
      return allUpdates
          .where(
              (update) => update.sharingStatus == LocationSharingStatus.active)
          .toList();
    } catch (e) {
      throw const SafetyCacheRetrievalException(
          'Failed to retrieve active location shares');
    }
  }

  @override
  Future<void> cacheLocationUpdate(LocationUpdate update) async {
    try {
      final updates = await getCachedLocationUpdates();
      final index = updates.indexWhere((u) => u.id == update.id);

      if (index >= 0) {
        updates[index] = update;
      } else {
        updates.add(update);
      }

      await cacheLocationUpdates(updates);
    } catch (e) {
      throw const SafetyCacheException('Failed to cache location update');
    }
  }

  @override
  Future<LocationUpdate?> getCachedLocationUpdate(String updateId) async {
    try {
      final updates = await getCachedLocationUpdates();
      return updates.cast<LocationUpdate?>().firstWhere(
            (update) => update?.id == updateId,
            orElse: () => null,
          );
    } catch (e) {
      throw const SafetyCacheRetrievalException(
          'Failed to retrieve cached location update');
    }
  }

  // ==================== Safety Alerts Operations ====================

  @override
  Future<void> cacheSafetyAlerts(List<SafetyAlert> alerts) async {
    try {
      final List<Map<String, dynamic>> jsonList =
          alerts.map((alert) => alert.toJson()).toList();
      await _sharedPreferences.setString(
        _safetyAlertsKey,
        jsonEncode(jsonList),
      );
      await _updateLastCacheTime();
    } catch (e) {
      throw const SafetyCacheException('Failed to cache safety alerts');
    }
  }

  @override
  Future<List<SafetyAlert>> getCachedSafetyAlerts() async {
    if (await isCacheExpired()) {
      return [];
    }

    try {
      final jsonString = _sharedPreferences.getString(_safetyAlertsKey);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => SafetyAlert.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw const SafetyCacheRetrievalException(
          'Failed to retrieve cached safety alerts');
    }
  }

  @override
  Future<List<SafetyAlert>> getCachedRecentSafetyAlerts(
      {int limit = 20}) async {
    try {
      final allAlerts = await getCachedSafetyAlerts();

      allAlerts.sort((a, b) => b.triggeredAt.compareTo(a.triggeredAt));

      return allAlerts.take(limit).toList();
    } catch (e) {
      throw const SafetyCacheRetrievalException(
          'Failed to retrieve recent safety alerts');
    }
  }

  @override
  Future<void> cacheSafetyAlert(SafetyAlert alert) async {
    try {
      final alerts = await getCachedSafetyAlerts();
      final index = alerts.indexWhere((a) => a.id == alert.id);

      if (index >= 0) {
        alerts[index] = alert;
      } else {
        alerts.add(alert);
      }

      await cacheSafetyAlerts(alerts);
    } catch (e) {
      throw const SafetyCacheException('Failed to cache safety alert');
    }
  }

  @override
  Future<SafetyAlert?> getCachedSafetyAlert(String alertId) async {
    try {
      final alerts = await getCachedSafetyAlerts();
      return alerts.cast<SafetyAlert?>().firstWhere(
            (alert) => alert?.id == alertId,
            orElse: () => null,
          );
    } catch (e) {
      throw const SafetyCacheRetrievalException(
          'Failed to retrieve cached safety alert');
    }
  }

  @override
  Future<List<SafetyAlert>> getCachedMissedCheckInAlerts() async {
    try {
      final allAlerts = await getCachedSafetyAlerts();
      return allAlerts
          .where((alert) => alert.type == SafetyAlertType.missedCheckIn)
          .toList();
    } catch (e) {
      throw const SafetyCacheRetrievalException(
          'Failed to retrieve missed check-in alerts');
    }
  }

  // ==================== Safety Status Operations ====================

  @override
  Future<void> cacheSafetyStatus(SafetyStatus status) async {
    try {
      await _sharedPreferences.setString(
        _safetyStatusKey,
        jsonEncode(status.toJson()),
      );
      await _updateLastCacheTime();
    } catch (e) {
      throw const SafetyCacheException('Failed to cache safety status');
    }
  }

  @override
  Future<SafetyStatus?> getCachedSafetyStatus() async {
    if (await isCacheExpired()) {
      return null;
    }

    try {
      final jsonString = _sharedPreferences.getString(_safetyStatusKey);
      if (jsonString == null) return null;

      return SafetyStatus.fromJson(jsonDecode(jsonString));
    } catch (e) {
      throw const SafetyCacheRetrievalException(
          'Failed to retrieve cached safety status');
    }
  }

  // ==================== Battery & Settings Operations ====================

  @override
  Future<void> cacheBatteryLevel(int level) async {
    try {
      await _sharedPreferences.setInt(_batteryLevelKey, level);
    } catch (e) {
      throw const SafetyCacheException('Failed to cache battery level');
    }
  }

  @override
  Future<int?> getCachedBatteryLevel() async {
    try {
      return _sharedPreferences.getInt(_batteryLevelKey);
    } catch (e) {
      throw const SafetyCacheRetrievalException(
          'Failed to retrieve cached battery level');
    }
  }

  @override
  Future<void> cacheSafetySettings(Map<String, dynamic> settings) async {
    try {
      await _sharedPreferences.setString(
        _safetySettingsKey,
        jsonEncode(settings),
      );
    } catch (e) {
      throw const SafetyCacheException('Failed to cache safety settings');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedSafetySettings() async {
    try {
      final jsonString = _sharedPreferences.getString(_safetySettingsKey);
      if (jsonString == null) return null;

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw const SafetyCacheRetrievalException(
          'Failed to retrieve cached safety settings');
    }
  }

  // ==================== Cache Management ====================

  @override
  Future<void> clearAllCache() async {
    try {
      await Future.wait([
        _sharedPreferences.remove(_trustedContactsKey),
        _sharedPreferences.remove(_checkInsKey),
        _sharedPreferences.remove(_locationUpdatesKey),
        _sharedPreferences.remove(_safetyAlertsKey),
        _sharedPreferences.remove(_safetyStatusKey),
        _sharedPreferences.remove(_batteryLevelKey),
        _sharedPreferences.remove(_safetySettingsKey),
        _sharedPreferences.remove(_lastUpdateKey),
      ]);
    } catch (e) {
      throw const SafetyCacheException('Failed to clear safety cache');
    }
  }

  @override
  Future<bool> isCacheExpired() async {
    final lastUpdate = await getLastCacheUpdate();
    if (lastUpdate == null) return true;

    final now = DateTime.now();
    return now.difference(lastUpdate) > cacheExpiration;
  }

  @override
  Future<DateTime?> getLastCacheUpdate() async {
    try {
      final timestamp = _sharedPreferences.getInt(_lastUpdateKey);
      if (timestamp == null) return null;

      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      return null;
    }
  }

  /// Helper method to update the last cache update timestamp
  Future<void> _updateLastCacheTime() async {
    await _sharedPreferences.setInt(
      _lastUpdateKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
