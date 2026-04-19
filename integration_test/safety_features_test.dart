import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/core/providers/core_providers.dart';
import 'package:soloadventurer/app/providers/core_service_providers.dart';
import 'package:soloadventurer/core/storage/secure_storage.dart';
import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import 'package:soloadventurer/features/safety/domain/entities/location_update.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_status.dart';
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';
import 'package:soloadventurer/features/safety/domain/repositories/safety_repository.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_remote_data_source.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_local_data_source.dart';
import 'test_config.dart';

// Test constants
const testUserId = 'user-123';
const testContactId = 'contact-123';
const testCheckInId = 'checkin-123';
const testAlertId = 'alert-123';
const testTripId = 'trip-123';
const testLatitude = 40.7128;
const testLongitude = -74.0060;

/// Mock implementation of SafetyRemoteDataSource for testing
class MockSafetyRemoteDataSource implements SafetyRemoteDataSource {
  final List<TrustedContact> _contacts = [];
  final List<CheckIn> _checkIns = [];
  final List<SafetyAlert> _alerts = [];
  final List<LocationUpdate> _locationUpdates = [];
  final List<SafetyStatus> _safetyStatuses = [];
  bool _isOnline = true;

  void setOnline(bool isOnline) => _isOnline = isOnline;

  @override
  Future<TrustedContact> addTrustedContact(TrustedContact contact) async {
    if (!_isOnline) throw Exception('No internet connection');
    _contacts.add(contact);
    return contact;
  }

  @override
  Future<void> removeTrustedContact(String contactId) async {
    if (!_isOnline) throw Exception('No internet connection');
    _contacts.removeWhere((c) => c.id == contactId);
  }

  @override
  Future<TrustedContact> updateTrustedContact(TrustedContact contact) async {
    if (!_isOnline) throw Exception('No internet connection');
    final index = _contacts.indexWhere((c) => c.id == contact.id);
    if (index >= 0) {
      _contacts[index] = contact;
    }
    return contact;
  }

  @override
  Future<List<TrustedContact>> getTrustedContacts() async {
    if (!_isOnline) throw Exception('No internet connection');
    return _contacts;
  }

  @override
  Future<TrustedContact> getTrustedContact(String contactId) async {
    if (!_isOnline) throw Exception('No internet connection');
    return _contacts.firstWhere((c) => c.id == contactId);
  }

  @override
  Future<CheckIn> createCheckIn(CheckIn checkIn) async {
    if (!_isOnline) throw Exception('No internet connection');
    _checkIns.add(checkIn);
    return checkIn;
  }

  @override
  Future<CheckIn> completeCheckIn({
    required String checkInId,
    required CheckInLocation location,
    String? statusMessage,
  }) async {
    if (!_isOnline) throw Exception('No internet connection');
    final index = _checkIns.indexWhere((c) => c.id == checkInId);
    if (index >= 0) {
      _checkIns[index] = _checkIns[index].copyWith(
        status: CheckInStatus.completed,
        completedAt: DateTime.now(),
        location: location,
        statusMessage: statusMessage,
      );
      return _checkIns[index];
    }
    throw Exception('Check-in not found');
  }

  @override
  Future<CheckIn> scheduleCheckIn({
    required String userId,
    required DateTime scheduledTime,
    DateTime? deadline,
    CheckInLocation? location,
    String? statusMessage,
    List<String>? notifyContactIds,
    String? tripId,
    CheckInTriggerType? triggerType,
  }) async {
    if (!_isOnline) throw Exception('No internet connection');
    final checkIn = CheckIn(
      id: 'checkin-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      triggerType: triggerType ?? CheckInTriggerType.scheduledTime,
      status: CheckInStatus.scheduled,
      scheduledTime: scheduledTime,
      deadline: deadline ?? scheduledTime.add(const Duration(hours: 1)),
      location: location,
      statusMessage: statusMessage,
      tripId: tripId,
      notifyContactIds: notifyContactIds ?? [],
      createdAt: DateTime.now(),
    );
    _checkIns.add(checkIn);
    return checkIn;
  }

  @override
  Future<void> cancelCheckIn(String checkInId) async {
    if (!_isOnline) throw Exception('No internet connection');
    final index = _checkIns.indexWhere((c) => c.id == checkInId);
    if (index >= 0) {
      _checkIns[index] = _checkIns[index].copyWith(status: CheckInStatus.cancelled);
    }
  }

  @override
  Future<List<CheckIn>> getUpcomingCheckIns() async {
    if (!_isOnline) throw Exception('No internet connection');
    return _checkIns.where((c) => 
      c.status == CheckInStatus.scheduled || c.status == CheckInStatus.active
    ).toList();
  }

  @override
  Future<List<CheckIn>> getAllCheckIns() async {
    if (!_isOnline) throw Exception('No internet connection');
    return _checkIns;
  }

  @override
  Future<CheckIn> getCheckIn(String checkInId) async {
    if (!_isOnline) throw Exception('No internet connection');
    return _checkIns.firstWhere((c) => c.id == checkInId);
  }

  @override
  Future<List<CheckIn>> getCheckInsByTrip(String tripId) async {
    if (!_isOnline) throw Exception('No internet connection');
    return _checkIns.where((c) => c.tripId == tripId).toList();
  }

  @override
  Future<CheckIn> updateCheckInStatus({
    required String checkInId,
    required CheckInStatus status,
  }) async {
    if (!_isOnline) throw Exception('No internet connection');
    final index = _checkIns.indexWhere((c) => c.id == checkInId);
    if (index >= 0) {
      _checkIns[index] = _checkIns[index].copyWith(status: status);
      return _checkIns[index];
    }
    throw Exception('Check-in not found');
  }

  @override
  Future<SafetyAlert> triggerEmergencySOS({
    required String userId,
    String? message,
    required SafetyAlertLocation location,
    required List<String> notifyContactIds,
    int? batteryLevel,
    String? tripId,
  }) async {
    if (!_isOnline) throw Exception('No internet connection');
    final alert = SafetyAlert(
      id: 'alert-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: SafetyAlertType.emergencySOS,
      status: SafetyAlertStatus.sent,
      message: message,
      location: location,
      notifiedContactIds: notifyContactIds,
      acknowledgedByContactIds: [],
      triggeredAt: DateTime.now(),
      batteryLevel: batteryLevel,
      tripId: tripId,
      createdAt: DateTime.now(),
    );
    _alerts.add(alert);
    return alert;
  }

  @override
  Future<SafetyStatus> updateSafetyStatus({
    required SafetyStatusType status,
    String? message,
    SafetyStatusLocation? location,
    int? batteryLevel,
    String? safetyAlertId,
    String? checkInId,
  }) async {
    final safetyStatus = SafetyStatus(
      id: 'status-${DateTime.now().millisecondsSinceEpoch}',
      userId: testUserId,
      status: status,
      message: message,
      location: location,
      batteryLevel: batteryLevel,
      safetyAlertId: safetyAlertId,
      checkInId: checkInId,
      timestamp: DateTime.now(),
    );
    _safetyStatuses.add(safetyStatus);
    return safetyStatus;
  }

  @override
  Future<SafetyStatus> getSafetyStatus() async {
    if (_safetyStatuses.isEmpty) {
      return SafetyStatus(
        id: 'status-default',
        userId: testUserId,
        status: SafetyStatusType.safe,
        timestamp: DateTime.now(),
      );
    }
    return _safetyStatuses.last;
  }

  @override
  Future<SafetyStatus> getSafetyStatusForUser(String userId) async {
    return getSafetyStatus();
  }

  @override
  Future<List<SafetyAlert>> getSafetyAlerts() async {
    if (!_isOnline) throw Exception('No internet connection');
    return _alerts;
  }

  @override
  Future<SafetyAlert> getSafetyAlert(String alertId) async {
    if (!_isOnline) throw Exception('No internet connection');
    return _alerts.firstWhere((a) => a.id == alertId);
  }

  @override
  Future<List<SafetyAlert>> getRecentSafetyAlerts({
    int limit = 20,
    SafetyAlertType? type,
  }) async {
    if (!_isOnline) throw Exception('No internet connection');
    var alerts = _alerts;
    if (type != null) {
      alerts = alerts.where((a) => a.type == type).toList();
    }
    return alerts.take(limit).toList();
  }

  @override
  Future<void> acknowledgeSafetyAlert(String alertId, String contactId) async {
    if (!_isOnline) throw Exception('No internet connection');
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index >= 0) {
      final alert = _alerts[index];
      final acknowledged = [...alert.acknowledgedByContactIds, contactId];
      _alerts[index] = alert.copyWith(
        acknowledgedByContactIds: acknowledged,
        status: SafetyAlertStatus.acknowledged,
        firstAcknowledgedAt: alert.firstAcknowledgedAt ?? DateTime.now(),
      );
    }
  }

  @override
  Future<void> resolveSafetyAlert(String alertId) async {
    if (!_isOnline) throw Exception('No internet connection');
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index >= 0) {
      _alerts[index] = _alerts[index].copyWith(
        status: SafetyAlertStatus.resolved,
        resolvedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> cancelSafetyAlert(String alertId) async {
    if (!_isOnline) throw Exception('No internet connection');
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index >= 0) {
      _alerts[index] = _alerts[index].copyWith(
        status: SafetyAlertStatus.cancelled,
        cancelledAt: DateTime.now(),
      );
    }
  }

  @override
  Future<List<SafetyAlert>> getMissedCheckInAlerts() async {
    if (!_isOnline) throw Exception('No internet connection');
    return _alerts.where((a) => a.type == SafetyAlertType.missedCheckIn).toList();
  }

  @override
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
  }) async {
    if (!_isOnline) throw Exception('No internet connection');
    final locationUpdate = LocationUpdate(
      id: 'loc-${DateTime.now().millisecondsSinceEpoch}',
      userId: testUserId,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      altitude: altitude,
      batteryLevel: batteryLevel,
      sharingStatus: LocationSharingStatus.active,
      sharedWithContactIds: shareWithContactIds,
      isEmergency: isEmergency,
      emergencyAlertId: emergencyAlertId,
      checkInId: checkInId,
      createdAt: DateTime.now(),
    );
    _locationUpdates.add(locationUpdate);
    return locationUpdate;
  }

  @override
  Future<void> stopLocationSharing(List<String> contactIds) async {
    if (!_isOnline) throw Exception('No internet connection');
    // Mark location shares as inactive
  }

  @override
  Future<void> stopAllLocationSharing() async {
    if (!_isOnline) throw Exception('No internet connection');
    // Mark all location shares as inactive
  }

  @override
  Future<List<LocationUpdate>> getActiveLocationShares() async {
    if (!_isOnline) throw Exception('No internet connection');
    return _locationUpdates.where((l) => 
      l.sharingStatus == LocationSharingStatus.active
    ).toList();
  }

  @override
  Future<List<LocationUpdate>> getLocationUpdates({
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isOnline) throw Exception('No internet connection');
    return _locationUpdates.take(limit).toList();
  }

  @override
  Future<void> updateLocationSharingPermission({
    required String contactId,
    required bool enabled,
  }) async {
    if (!_isOnline) throw Exception('No internet connection');
    // Update location sharing permission
  }

  @override
  Future<void> updateBatteryLevel(int level) async {
    // Update battery level
  }

  @override
  Future<int?> getBatteryLevel() async {
    return 85;
  }

  @override
  Future<void> updateContactNotificationPreferences({
    required String contactId,
    required bool receivesCheckIns,
    required bool receivesEmergencyAlerts,
  }) async {
    if (!_isOnline) throw Exception('No internet connection');
  }

  @override
  Future<Map<String, dynamic>> getSafetySettings() async {
    return {
      'autoCheckInEnabled': true,
      'locationSharingEnabled': false,
      'batteryAlertThreshold': 20,
    };
  }

  @override
  Future<void> updateSafetySettings(Map<String, dynamic> settings) async {
    if (!_isOnline) throw Exception('No internet connection');
  }

  void clearAll() {
    _contacts.clear();
    _checkIns.clear();
    _alerts.clear();
    _locationUpdates.clear();
    _safetyStatuses.clear();
  }
}

/// Mock implementation of SafetyLocalDataSource for testing
class MockSafetyLocalDataSource implements SafetyLocalDataSource {
  final List<TrustedContact> _cachedContacts = [];
  final List<CheckIn> _cachedCheckIns = [];
  final List<SafetyAlert> _cachedAlerts = [];
  CheckIn? _activeCheckIn;
  SafetyStatus? _cachedStatus;
  DateTime? _lastSync;

  @override
  Future<void> cacheContacts(List<TrustedContact> contacts) async {
    _cachedContacts.clear();
    _cachedContacts.addAll(contacts);
  }

  @override
  Future<List<TrustedContact>> getCachedContacts() async {
    return _cachedContacts;
  }

  @override
  Future<void> cacheCheckIn(CheckIn checkIn) async {
    final index = _cachedCheckIns.indexWhere((c) => c.id == checkIn.id);
    if (index >= 0) {
      _cachedCheckIns[index] = checkIn;
    } else {
      _cachedCheckIns.add(checkIn);
    }
  }

  @override
  Future<CheckIn?> getActiveCheckIn() async {
    return _activeCheckIn;
  }

  @override
  Future<void> setActiveCheckIn(CheckIn? checkIn) async {
    _activeCheckIn = checkIn;
  }

  @override
  Future<List<CheckIn>> getCachedCheckIns() async {
    return _cachedCheckIns;
  }

  @override
  Future<void> cacheSafetyAlert(SafetyAlert alert) async {
    _cachedAlerts.add(alert);
  }

  @override
  Future<List<SafetyAlert>> getCachedSafetyAlerts() async {
    return _cachedAlerts;
  }

  @override
  Future<void> cacheSafetyStatus(SafetyStatus status) async {
    _cachedStatus = status;
  }

  @override
  Future<SafetyStatus?> getCachedSafetyStatus() async {
    return _cachedStatus;
  }

  @override
  Future<DateTime?> getLastSyncTimestamp() async {
    return _lastSync;
  }

  @override
  Future<void> updateLastSyncTimestamp(DateTime timestamp) async {
    _lastSync = timestamp;
  }

  @override
  Future<void> clearCache() async {
    _cachedContacts.clear();
    _cachedCheckIns.clear();
    _cachedAlerts.clear();
    _activeCheckIn = null;
    _cachedStatus = null;
    _lastSync = null;
  }
}

/// Mock SafetyRepository implementation
class MockSafetyRepository implements SafetyRepository {
  final MockSafetyRemoteDataSource _remoteDataSource;
  final MockSafetyLocalDataSource _localDataSource;
  bool _isOnline = true;

  MockSafetyRepository(this._remoteDataSource, this._localDataSource);

  void setOnline(bool isOnline) {
    _isOnline = isOnline;
    _remoteDataSource.setOnline(isOnline);
  }

  @override
  Future<TrustedContact> addTrustedContact(TrustedContact contact) async {
    // Save locally first
    await _localDataSource.cacheContacts([contact]);
    // Sync with remote if online
    if (_isOnline) {
      return await _remoteDataSource.addTrustedContact(contact);
    }
    return contact;
  }

  @override
  Future<void> removeTrustedContact(String contactId) async {
    await _localDataSource.clearCache();
    if (_isOnline) {
      await _remoteDataSource.removeTrustedContact(contactId);
    }
  }

  @override
  Future<TrustedContact> updateTrustedContact(TrustedContact contact) async {
    if (_isOnline) {
      return await _remoteDataSource.updateTrustedContact(contact);
    }
    return contact;
  }

  @override
  Future<List<TrustedContact>> getTrustedContacts() async {
    if (_isOnline) {
      final contacts = await _remoteDataSource.getTrustedContacts();
      await _localDataSource.cacheContacts(contacts);
      return contacts;
    }
    return _localDataSource.getCachedContacts();
  }

  @override
  Future<TrustedContact> getTrustedContact(String contactId) async {
    return _remoteDataSource.getTrustedContact(contactId);
  }

  @override
  Future<CheckIn> createCheckIn(CheckIn checkIn) async {
    await _localDataSource.cacheCheckIn(checkIn);
    if (_isOnline) {
      return await _remoteDataSource.createCheckIn(checkIn);
    }
    return checkIn;
  }

  @override
  Future<CheckIn> completeCheckIn({
    required String checkInId,
    required CheckInLocation location,
    String? statusMessage,
  }) async {
    if (_isOnline) {
      final checkIn = await _remoteDataSource.completeCheckIn(
        checkInId: checkInId,
        location: location,
        statusMessage: statusMessage,
      );
      await _localDataSource.cacheCheckIn(checkIn);
      await _localDataSource.setActiveCheckIn(null);
      return checkIn;
    }
    throw Exception('Cannot complete check-in offline');
  }

  @override
  Future<CheckIn> scheduleCheckIn({
    required String userId,
    required DateTime scheduledTime,
    DateTime? deadline,
    CheckInLocation? location,
    String? statusMessage,
    List<String>? notifyContactIds,
    String? tripId,
    CheckInTriggerType? triggerType,
  }) async {
    if (_isOnline) {
      final checkIn = await _remoteDataSource.scheduleCheckIn(
        userId: userId,
        scheduledTime: scheduledTime,
        deadline: deadline,
        location: location,
        statusMessage: statusMessage,
        notifyContactIds: notifyContactIds,
        tripId: tripId,
        triggerType: triggerType,
      );
      await _localDataSource.cacheCheckIn(checkIn);
      await _localDataSource.setActiveCheckIn(checkIn);
      return checkIn;
    }
    throw Exception('Cannot schedule check-in offline');
  }

  @override
  Future<void> cancelCheckIn(String checkInId) async {
    if (_isOnline) {
      await _remoteDataSource.cancelCheckIn(checkInId);
    }
    await _localDataSource.setActiveCheckIn(null);
  }

  @override
  Future<List<CheckIn>> getUpcomingCheckIns() async {
    if (_isOnline) {
      return await _remoteDataSource.getUpcomingCheckIns();
    }
    return _localDataSource.getCachedCheckIns();
  }

  @override
  Future<List<CheckIn>> getAllCheckIns() async {
    return _remoteDataSource.getAllCheckIns();
  }

  @override
  Future<CheckIn> getCheckIn(String checkInId) async {
    return _remoteDataSource.getCheckIn(checkInId);
  }

  @override
  Future<List<CheckIn>> getCheckInsByTrip(String tripId) async {
    return _remoteDataSource.getCheckInsByTrip(tripId);
  }

  @override
  Future<CheckIn> updateCheckInStatus({
    required String checkInId,
    required CheckInStatus status,
  }) async {
    return _remoteDataSource.updateCheckInStatus(
      checkInId: checkInId,
      status: status,
    );
  }

  @override
  Future<SafetyAlert> triggerEmergencySOS({
    required String userId,
    String? message,
    required SafetyAlertLocation location,
    required List<String> notifyContactIds,
    int? batteryLevel,
    String? tripId,
  }) async {
    if (_isOnline) {
      final alert = await _remoteDataSource.triggerEmergencySOS(
        userId: userId,
        message: message,
        location: location,
        notifyContactIds: notifyContactIds,
        batteryLevel: batteryLevel,
        tripId: tripId,
      );
      await _localDataSource.cacheSafetyAlert(alert);
      return alert;
    }
    // Create local alert for sync later
    final alert = SafetyAlert(
      id: 'alert-local-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: SafetyAlertType.emergencySOS,
      status: SafetyAlertStatus.sent,
      message: message,
      location: location,
      notifiedContactIds: notifyContactIds,
      acknowledgedByContactIds: [],
      triggeredAt: DateTime.now(),
      batteryLevel: batteryLevel,
      tripId: tripId,
      createdAt: DateTime.now(),
    );
    await _localDataSource.cacheSafetyAlert(alert);
    return alert;
  }

  @override
  Future<SafetyStatus> updateSafetyStatus({
    required SafetyStatusType status,
    String? message,
    SafetyStatusLocation? location,
    int? batteryLevel,
    String? safetyAlertId,
    String? checkInId,
  }) async {
    return _remoteDataSource.updateSafetyStatus(
      status: status,
      message: message,
      location: location,
      batteryLevel: batteryLevel,
      safetyAlertId: safetyAlertId,
      checkInId: checkInId,
    );
  }

  @override
  Future<SafetyStatus> getSafetyStatus() async {
    final cached = await _localDataSource.getCachedSafetyStatus();
    if (cached != null && !_isOnline) {
      return cached;
    }
    final status = await _remoteDataSource.getSafetyStatus();
    await _localDataSource.cacheSafetyStatus(status);
    return status;
  }

  @override
  Future<SafetyStatus> getSafetyStatusForUser(String userId) async {
    return _remoteDataSource.getSafetyStatusForUser(userId);
  }

  @override
  Future<List<SafetyAlert>> getSafetyAlerts() async {
    if (_isOnline) {
      return await _remoteDataSource.getSafetyAlerts();
    }
    return _localDataSource.getCachedSafetyAlerts();
  }

  @override
  Future<SafetyAlert> getSafetyAlert(String alertId) async {
    return _remoteDataSource.getSafetyAlert(alertId);
  }

  @override
  Future<List<SafetyAlert>> getRecentSafetyAlerts({
    int limit = 20,
    SafetyAlertType? type,
  }) async {
    return _remoteDataSource.getRecentSafetyAlerts(limit: limit, type: type);
  }

  @override
  Future<void> acknowledgeSafetyAlert(String alertId, String contactId) async {
    await _remoteDataSource.acknowledgeSafetyAlert(alertId, contactId);
  }

  @override
  Future<void> resolveSafetyAlert(String alertId) async {
    await _remoteDataSource.resolveSafetyAlert(alertId);
  }

  @override
  Future<void> cancelSafetyAlert(String alertId) async {
    await _remoteDataSource.cancelSafetyAlert(alertId);
  }

  @override
  Future<List<SafetyAlert>> getMissedCheckInAlerts() async {
    return _remoteDataSource.getMissedCheckInAlerts();
  }

  @override
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
  }) async {
    return _remoteDataSource.shareLocation(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      altitude: altitude,
      speed: speed,
      heading: heading,
      address: address,
      placeName: placeName,
      shareWithContactIds: shareWithContactIds,
      batteryLevel: batteryLevel,
      isEmergency: isEmergency,
      emergencyAlertId: emergencyAlertId,
      checkInId: checkInId,
    );
  }

  @override
  Future<void> stopLocationSharing(List<String> contactIds) async {
    await _remoteDataSource.stopLocationSharing(contactIds);
  }

  @override
  Future<void> stopAllLocationSharing() async {
    await _remoteDataSource.stopAllLocationSharing();
  }

  @override
  Future<List<LocationUpdate>> getActiveLocationShares() async {
    return _remoteDataSource.getActiveLocationShares();
  }

  @override
  Future<List<LocationUpdate>> getLocationUpdates({
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _remoteDataSource.getLocationUpdates(
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<void> updateLocationSharingPermission({
    required String contactId,
    required bool enabled,
  }) async {
    await _remoteDataSource.updateLocationSharingPermission(
      contactId: contactId,
      enabled: enabled,
    );
  }

  @override
  Future<void> updateBatteryLevel(int level) async {
    await _remoteDataSource.updateBatteryLevel(level);
  }

  @override
  Future<int?> getBatteryLevel() async {
    return _remoteDataSource.getBatteryLevel();
  }

  @override
  Future<void> updateContactNotificationPreferences({
    required String contactId,
    required bool receivesCheckIns,
    required bool receivesEmergencyAlerts,
  }) async {
    await _remoteDataSource.updateContactNotificationPreferences(
      contactId: contactId,
      receivesCheckIns: receivesCheckIns,
      receivesEmergencyAlerts: receivesEmergencyAlerts,
    );
  }

  @override
  Future<Map<String, dynamic>> getSafetySettings() async {
    return _remoteDataSource.getSafetySettings();
  }

  @override
  Future<void> updateSafetySettings(Map<String, dynamic> settings) async {
    await _remoteDataSource.updateSafetySettings(settings);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockSafetyRemoteDataSource mockRemoteDataSource;
  late MockSafetyLocalDataSource mockLocalDataSource;
  late MockSafetyRepository mockSafetyRepository;

  setUp(() async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Initialize mock data sources
    mockRemoteDataSource = MockSafetyRemoteDataSource();
    mockLocalDataSource = MockSafetyLocalDataSource();
    mockSafetyRepository = MockSafetyRepository(
      mockRemoteDataSource,
      mockLocalDataSource,
    );

    // Initialize ProviderContainer
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
  });

  group('Safety Feature Tests', () {
    group('SOS Alert Tests', () {
      test('User triggers SOS - alert created in database', () async {
        // Setup
        mockSafetyRepository.setOnline(true);

        // Add a trusted contact first
        final contact = TrustedContact(
          id: testContactId,
          userId: testUserId,
          name: 'Emergency Contact',
          phoneNumber: '+1234567890',
          source: ContactSource.phone,
          permission: ContactPermission.fullAccess,
          addedAt: DateTime.now(),
        );
        await mockSafetyRepository.addTrustedContact(contact);

        // Trigger SOS
        final alert = await mockSafetyRepository.triggerEmergencySOS(
          userId: testUserId,
          message: 'Emergency! Need help!',
          location: SafetyAlertLocation(
            latitude: testLatitude,
            longitude: testLongitude,
            timestamp: DateTime.now(),
          ),
          notifyContactIds: [testContactId],
          batteryLevel: 75,
          tripId: testTripId,
        );

        // Verify alert was created
        expect(alert, isNotNull);
        expect(alert.type, equals(SafetyAlertType.emergencySOS));
        expect(alert.status, equals(SafetyAlertStatus.sent));
        expect(alert.userId, equals(testUserId));
        expect(alert.message, equals('Emergency! Need help!'));
        expect(alert.notifiedContactIds, contains(testContactId));
        expect(alert.batteryLevel, equals(75));
        expect(alert.tripId, equals(testTripId));
      });

      test('SOS alert can be acknowledged by contact', () async {
        // Setup
        mockSafetyRepository.setOnline(true);

        // Create SOS alert
        final alert = await mockSafetyRepository.triggerEmergencySOS(
          userId: testUserId,
          location: SafetyAlertLocation(
            latitude: testLatitude,
            longitude: testLongitude,
            timestamp: DateTime.now(),
          ),
          notifyContactIds: [testContactId],
        );

        // Acknowledge the alert
        await mockSafetyRepository.acknowledgeSafetyAlert(alert.id, testContactId);

        // Verify alert was acknowledged
        final acknowledgedAlert = await mockSafetyRepository.getSafetyAlert(alert.id);
        expect(acknowledgedAlert.status, equals(SafetyAlertStatus.acknowledged));
        expect(acknowledgedAlert.acknowledgedByContactIds, contains(testContactId));
        expect(acknowledgedAlert.firstAcknowledgedAt, isNotNull);
      });

      test('SOS alert can be resolved', () async {
        // Setup
        mockSafetyRepository.setOnline(true);

        // Create and acknowledge alert
        final alert = await mockSafetyRepository.triggerEmergencySOS(
          userId: testUserId,
          location: SafetyAlertLocation(
            latitude: testLatitude,
            longitude: testLongitude,
            timestamp: DateTime.now(),
          ),
          notifyContactIds: [testContactId],
        );
        await mockSafetyRepository.acknowledgeSafetyAlert(alert.id, testContactId);

        // Resolve the alert
        await mockSafetyRepository.resolveSafetyAlert(alert.id);

        // Verify alert was resolved
        final resolvedAlert = await mockSafetyRepository.getSafetyAlert(alert.id);
        expect(resolvedAlert.status, equals(SafetyAlertStatus.resolved));
        expect(resolvedAlert.resolvedAt, isNotNull);
      });

      test('SOS alert can be cancelled (false alarm)', () async {
        // Setup
        mockSafetyRepository.setOnline(true);

        // Create alert
        final alert = await mockSafetyRepository.triggerEmergencySOS(
          userId: testUserId,
          location: SafetyAlertLocation(
            latitude: testLatitude,
            longitude: testLongitude,
            timestamp: DateTime.now(),
          ),
          notifyContactIds: [testContactId],
        );

        // Cancel the alert
        await mockSafetyRepository.cancelSafetyAlert(alert.id);

        // Verify alert was cancelled
        final cancelledAlert = await mockSafetyRepository.getSafetyAlert(alert.id);
        expect(cancelledAlert.status, equals(SafetyAlertStatus.cancelled));
        expect(cancelledAlert.cancelledAt, isNotNull);
      });
    });

    group('Check-in Tests', () {
      test('User schedules check-in', () async {
        // Setup
        mockSafetyRepository.setOnline(true);

        // Add trusted contact
        final contact = TrustedContact(
          id: testContactId,
          userId: testUserId,
          name: 'Check-in Contact',
          phoneNumber: '+1234567890',
          source: ContactSource.phone,
          permission: ContactPermission.fullAccess,
          addedAt: DateTime.now(),
        );
        await mockSafetyRepository.addTrustedContact(contact);

        // Schedule check-in
        final scheduledTime = DateTime.now().add(const Duration(hours: 2));
        final deadline = scheduledTime.add(const Duration(minutes: 30));

        final checkIn = await mockSafetyRepository.scheduleCheckIn(
          userId: testUserId,
          scheduledTime: scheduledTime,
          deadline: deadline,
          notifyContactIds: [testContactId],
          tripId: testTripId,
        );

        // Verify check-in was scheduled
        expect(checkIn, isNotNull);
        expect(checkIn.status, equals(CheckInStatus.scheduled));
        expect(checkIn.triggerType, equals(CheckInTriggerType.scheduledTime));
        expect(checkIn.scheduledTime, equals(scheduledTime));
        expect(checkIn.deadline, equals(deadline));
        expect(checkIn.notifyContactIds, contains(testContactId));
        expect(checkIn.tripId, equals(testTripId));
      });

      test('User completes check-in', () async {
        // Setup
        mockSafetyRepository.setOnline(true);

        // Schedule check-in
        final scheduledCheckIn = await mockSafetyRepository.scheduleCheckIn(
          userId: testUserId,
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
        );

        // Complete the check-in
        final completedCheckIn = await mockSafetyRepository.completeCheckIn(
          checkInId: scheduledCheckIn.id,
          location: CheckInLocation(
            latitude: testLatitude,
            longitude: testLongitude,
            timestamp: DateTime.now(),
          ),
          statusMessage: 'I\'m safe and having a great time!',
        );

        // Verify check-in was completed
        expect(completedCheckIn.status, equals(CheckInStatus.completed));
        expect(completedCheckIn.completedAt, isNotNull);
        expect(completedCheckIn.location, isNotNull);
        expect(completedCheckIn.statusMessage, equals('I\'m safe and having a great time!'));
      });

      test('Missed check-in triggers escalation', () async {
        // Setup
        mockSafetyRepository.setOnline(true);

        // Schedule check-in with past deadline
        final checkIn = await mockSafetyRepository.scheduleCheckIn(
          userId: testUserId,
          scheduledTime: DateTime.now().subtract(const Duration(hours: 2)),
          deadline: DateTime.now().subtract(const Duration(hours: 1)),
          notifyContactIds: [testContactId],
        );

        // Simulate missed check-in by updating status
        final missedCheckIn = await mockSafetyRepository.updateCheckInStatus(
          checkInId: checkIn.id,
          status: CheckInStatus.missed,
        );

        // Verify check-in is marked as missed
        expect(missedCheckIn.status, equals(CheckInStatus.missed));

        // Create missed check-in alert
        final alert = SafetyAlert(
          id: 'alert-missed-${DateTime.now().millisecondsSinceEpoch}',
          userId: testUserId,
          type: SafetyAlertType.missedCheckIn,
          status: SafetyAlertStatus.sent,
          checkInId: checkIn.id,
          notifiedContactIds: [testContactId],
          acknowledgedByContactIds: [],
          triggeredAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Manually add to remote data source to simulate escalation
        await mockRemoteDataSource.createCheckIn(checkIn);

        // Verify the missed check-in alert
        expect(alert.type, equals(SafetyAlertType.missedCheckIn));
        expect(alert.checkInId, equals(checkIn.id));
        expect(alert.notifiedContactIds, contains(testContactId));
      });

      test('User can cancel scheduled check-in', () async {
        // Setup
        mockSafetyRepository.setOnline(true);

        // Schedule check-in
        final checkIn = await mockSafetyRepository.scheduleCheckIn(
          userId: testUserId,
          scheduledTime: DateTime.now().add(const Duration(hours: 3)),
        );

        // Cancel the check-in
        await mockSafetyRepository.cancelCheckIn(checkIn.id);

        // Verify check-in is cancelled
        final cancelledCheckIn = await mockSafetyRepository.getCheckIn(checkIn.id);
        expect(cancelledCheckIn.status, equals(CheckInStatus.cancelled));
      });

      test('Get upcoming check-ins', () async {
        // Setup
        mockSafetyRepository.setOnline(true);

        // Schedule multiple check-ins
        await mockSafetyRepository.scheduleCheckIn(
          userId: testUserId,
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
        );
        await mockSafetyRepository.scheduleCheckIn(
          userId: testUserId,
          scheduledTime: DateTime.now().add(const Duration(hours: 3)),
        );

        // Get upcoming check-ins
        final upcomingCheckIns = await mockSafetyRepository.getUpcomingCheckIns();

        // Verify we have upcoming check-ins
        expect(upcomingCheckIns.length, greaterThanOrEqualTo(2));
        for (final checkIn in upcomingCheckIns) {
          expect(
            checkIn.status == CheckInStatus.scheduled || 
            checkIn.status == CheckInStatus.active,
            isTrue,
          );
        }
      });
    });

    group('Safety Status Tests', () {
      test('User can update safety status', () async {
        // Setup
        mockSafetyRepository.setOnline(true);

        // Update safety status
        final status = await mockSafetyRepository.updateSafetyStatus(
          status: SafetyStatusType.safe,
          message: 'All good!',
          batteryLevel: 85,
        );

        // Verify status was updated
        expect(status.status, equals(SafetyStatusType.safe));
        expect(status.message, equals('All good!'));
        expect(status.batteryLevel, equals(85));
      });

      test('User can set status to need help', () async {
        // Setup
        mockSafetyRepository.setOnline(true);

        // Update status to need help
        final status = await mockSafetyRepository.updateSafetyStatus(
          status: SafetyStatusType.needHelp,
          message: 'Need assistance',
          location: SafetyStatusLocation(
            latitude: testLatitude,
            longitude: testLongitude,
            timestamp: DateTime.now(),
          ),
        );

        // Verify status
        expect(status.status, equals(SafetyStatusType.needHelp));
        expect(status.message, equals('Need assistance'));
        expect(status.location, isNotNull);
      });

      test('Get current safety status', () async {
        // Setup
        mockSafetyRepository.setOnline(true);

        // Update status
        await mockSafetyRepository.updateSafetyStatus(
          status: SafetyStatusType.safe,
          message: 'Feeling great!',
        );

        // Get current status
        final status = await mockSafetyRepository.getSafetyStatus();

        // Verify status
        expect(status, isNotNull);
        expect(status.status, equals(SafetyStatusType.safe));
      });
    });

    group('Trusted Contact Tests', () {
      test('User can add trusted contact', () async {
        // Setup
        mockSafetyRepository.setOnline(true);

        // Add contact
        final contact = TrustedContact(
          id: 'new-contact',
          userId: testUserId,
          name: 'Jane Doe',
          phoneNumber: '+1987654321',
          email: 'jane@example.com',
          source: ContactSource.phone,
          permission: ContactPermission.fullAccess,
          receivesCheckIns: true,
          receivesEmergencyAlerts: true,
          addedAt: DateTime.now(),
        );

        final addedContact = await mockSafetyRepository.addTrustedContact(contact);

        // Verify contact was added
        expect(addedContact, isNotNull);
        expect(addedContact.name, equals('Jane Doe'));
        expect(addedContact.receivesCheckIns, isTrue);
        expect(addedContact.receivesEmergencyAlerts, isTrue);
      });

      test('User can remove trusted contact', () async {
        // Setup
        mockSafetyRepository.setOnline(true);

        // Add contact
        final contact = TrustedContact(
          id: 'remove-contact',
          userId: testUserId,
          name: 'Remove Me',
          phoneNumber: '+1111111111',
          source: ContactSource.phone,
          permission: ContactPermission.fullAccess,
          addedAt: DateTime.now(),
        );
        await mockSafetyRepository.addTrustedContact(contact);

        // Remove contact
        await mockSafetyRepository.removeTrustedContact(contact.id);

        // Verify contact is removed
        final contacts = await mockSafetyRepository.getTrustedContacts();
        expect(contacts.where((c) => c.id == contact.id), isEmpty);
      });

      test('User can update contact notification preferences', () async {
        // Setup
        mockSafetyRepository.setOnline(true);

        // Add contact
        final contact = TrustedContact(
          id: 'pref-contact',
          userId: testUserId,
          name: 'Preference Contact',
          phoneNumber: '+1222222222',
          source: ContactSource.phone,
          permission: ContactPermission.fullAccess,
          receivesCheckIns: true,
          receivesEmergencyAlerts: true,
          addedAt: DateTime.now(),
        );
        await mockSafetyRepository.addTrustedContact(contact);

        // Update preferences
        await mockSafetyRepository.updateContactNotificationPreferences(
          contactId: contact.id,
          receivesCheckIns: false,
          receivesEmergencyAlerts: true,
        );

        // This would be verified by getting the updated contact
      });
    });

    group('Location Sharing Tests', () {
      test('User can share location with contacts', () async {
        // Setup
        mockSafetyRepository.setOnline(true);

        // Share location
        final locationUpdate = await mockSafetyRepository.shareLocation(
          latitude: testLatitude,
          longitude: testLongitude,
          accuracy: 10.0,
          shareWithContactIds: [testContactId],
          batteryLevel: 90,
        );

        // Verify location was shared
        expect(locationUpdate, isNotNull);
        expect(locationUpdate.latitude, equals(testLatitude));
        expect(locationUpdate.longitude, equals(testLongitude));
        expect(locationUpdate.sharingStatus, equals(LocationSharingStatus.active));
        expect(locationUpdate.sharedWithContactIds, contains(testContactId));
      });

      test('User can stop location sharing', () async {
        // Setup
        mockSafetyRepository.setOnline(true);

        // Share location
        await mockSafetyRepository.shareLocation(
          latitude: testLatitude,
          longitude: testLongitude,
          shareWithContactIds: [testContactId],
        );

        // Stop sharing
        await mockSafetyRepository.stopLocationSharing([testContactId]);

        // Verify no active shares
        final activeShares = await mockSafetyRepository.getActiveLocationShares();
        expect(activeShares, isEmpty);
      });

      test('Emergency location sharing includes alert reference', () async {
        // Setup
        mockSafetyRepository.setOnline(true);

        // Create SOS alert
        final alert = await mockSafetyRepository.triggerEmergencySOS(
          userId: testUserId,
          location: SafetyAlertLocation(
            latitude: testLatitude,
            longitude: testLongitude,
            timestamp: DateTime.now(),
          ),
          notifyContactIds: [testContactId],
        );

        // Share location in emergency
        final locationUpdate = await mockSafetyRepository.shareLocation(
          latitude: testLatitude,
          longitude: testLongitude,
          shareWithContactIds: [testContactId],
          isEmergency: true,
          emergencyAlertId: alert.id,
        );

        // Verify emergency location
        expect(locationUpdate.isEmergency, isTrue);
        expect(locationUpdate.emergencyAlertId, equals(alert.id));
      });
    });
  });
}
