import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/api/client/api_client.dart';
import 'package:soloadventurer/core/error/safety_exceptions.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_remote_data_source.dart';
import 'package:soloadventurer/features/safety/data/models/check_in_model.dart';
import 'package:soloadventurer/features/safety/data/models/location_update_model.dart';
import 'package:soloadventurer/features/safety/data/models/safety_alert_model.dart';
import 'package:soloadventurer/features/safety/data/models/safety_status_model.dart';
import 'package:soloadventurer/features/safety/data/models/trusted_contact_model.dart';
import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import 'package:soloadventurer/features/safety/domain/entities/location_update.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_status.dart';

/// Mock implementation of [SafetyRemoteDataSource] for testing
///
/// This implementation provides in-memory data storage and simulated API behavior
/// for development and testing purposes. It mimics the behavior of the real
/// remote data source without making actual network calls.
class MockSafetyRemoteDataSource implements SafetyRemoteDataSource {
  final ApiClient _apiClient;

  // In-memory storage for mock data
  final Map<String, TrustedContactModel> _trustedContacts = {};
  final Map<String, CheckInModel> _checkIns = {};
  final Map<String, LocationUpdateModel> _locationUpdates = {};
  final Map<String, SafetyAlertModel> _safetyAlerts = {};
  SafetyStatusModel? _currentSafetyStatus;
  int? _batteryLevel;

  /// Creates a new [MockSafetyRemoteDataSource]
  MockSafetyRemoteDataSource(this._apiClient);

  // ==================== Helper Methods ====================

  String _generateId() {
    return 'mock_${DateTime.now().millisecondsSinceEpoch}_${_trustedContacts.length}';
  }

  /// Check if offline mode is active
  void _checkOffline() {
    if (_apiClient.isOffline) {
      throw const SafetyOfflineException();
    }
  }

  /// Simulate network delay
  Future<void> _simulateDelay({int milliseconds = 300}) async {
    if (_apiClient.isOffline) return;
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  // ==================== Trusted Contacts Operations ====================

  @override
  Future<TrustedContactModel> addTrustedContact(
      TrustedContactModel contact) async {
    await _simulateDelay();
    _checkOffline();

    // Validate contact
    if (contact.email == null && contact.phoneNumber == null) {
      throw const InvalidContactInformationException(
        'Contact must have either email or phone number',
      );
    }

    // Check if contact already exists
    final existingContact = _trustedContacts.values.any(
      (c) => c.email == contact.email || c.phoneNumber == contact.phoneNumber,
    );

    if (existingContact) {
      throw const TrustedContactAlreadyExistsException();
    }

    // Check contact limit
    if (_trustedContacts.length >= 10) {
      throw const TrustedContactLimitExceededException();
    }

    // Create new contact with generated ID
    final newContact = TrustedContactModel(
      id: _generateId(),
      userId: contact.userId,
      name: contact.name,
      email: contact.email,
      phoneNumber: contact.phoneNumber,
      contactSource: contact.contactSource,
      receivesCheckInNotifications: contact.receivesCheckInNotifications,
      receivesEmergencyAlerts: contact.receivesEmergencyAlerts,
      receivesLocationUpdates: contact.receivesLocationUpdates,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _trustedContacts[newContact.id] = newContact;
    debugPrint('Mock: Added trusted contact ${newContact.id}');
    return newContact;
  }

  @override
  Future<void> removeTrustedContact(String contactId) async {
    await _simulateDelay();
    _checkOffline();

    if (!_trustedContacts.containsKey(contactId)) {
      throw const TrustedContactNotFoundException();
    }

    _trustedContacts.remove(contactId);
    debugPrint('Mock: Removed trusted contact $contactId');
  }

  @override
  Future<TrustedContactModel> updateTrustedContact(
      TrustedContactModel contact) async {
    await _simulateDelay();
    _checkOffline();

    if (!_trustedContacts.containsKey(contact.id)) {
      throw const TrustedContactNotFoundException();
    }

    final updatedContact = contact.copyWith(updatedAt: DateTime.now());
    _trustedContacts[contact.id] = updatedContact;
    debugPrint('Mock: Updated trusted contact ${contact.id}');
    return updatedContact;
  }

  @override
  Future<List<TrustedContactModel>> getTrustedContacts() async {
    await _simulateDelay();
    _checkOffline();

    return _trustedContacts.values.toList();
  }

  @override
  Future<TrustedContactModel> getTrustedContact(String contactId) async {
    await _simulateDelay();
    _checkOffline();

    final contact = _trustedContacts[contactId];
    if (contact == null) {
      throw const TrustedContactNotFoundException();
    }

    return contact;
  }

  // ==================== Check-in Operations ====================

  @override
  Future<CheckInModel> createCheckIn(CheckInModel checkIn) async {
    await _simulateDelay();
    _checkOffline();

    final newCheckIn = CheckInModel(
      id: _generateId(),
      userId: checkIn.userId,
      scheduledTime: checkIn.scheduledTime,
      deadline: checkIn.deadline,
      location: checkIn.location,
      status: CheckInStatus.scheduled,
      statusMessage: checkIn.statusMessage,
      triggerType: checkIn.triggerType ?? CheckInTriggerType.manual,
      notifyContactIds: checkIn.notifyContactIds,
      tripId: checkIn.tripId,
      completedAt: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _checkIns[newCheckIn.id] = newCheckIn;
    debugPrint('Mock: Created check-in ${newCheckIn.id}');
    return newCheckIn;
  }

  @override
  Future<CheckInModel> completeCheckIn({
    required String checkInId,
    required CheckInLocation location,
    String? statusMessage,
  }) async {
    await _simulateDelay();
    _checkOffline();

    final checkIn = _checkIns[checkInId];
    if (checkIn == null) {
      throw const CheckInNotFoundException();
    }

    if (checkIn.status == CheckInStatus.completed) {
      throw const CheckInAlreadyCompletedException();
    }

    final completedCheckIn = checkIn.copyWith(
      status: CheckInStatus.completed,
      location: location,
      statusMessage: statusMessage ?? checkIn.statusMessage,
      completedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _checkIns[checkInId] = completedCheckIn;
    debugPrint('Mock: Completed check-in $checkInId');
    return completedCheckIn;
  }

  @override
  Future<CheckInModel> scheduleCheckIn({
    required String userId,
    required DateTime scheduledTime,
    DateTime? deadline,
    CheckInLocation? location,
    String? statusMessage,
    List<String>? notifyContactIds,
    String? tripId,
    CheckInTriggerType? triggerType,
  }) async {
    await _simulateDelay();
    _checkOffline();

    if (scheduledTime.isBefore(DateTime.now())) {
      throw const InvalidCheckInScheduleException(
        'Scheduled time must be in the future',
      );
    }

    final checkIn = CheckInModel(
      id: _generateId(),
      userId: userId,
      scheduledTime: scheduledTime,
      deadline: deadline,
      location: location,
      status: CheckInStatus.scheduled,
      statusMessage: statusMessage,
      triggerType: triggerType ?? CheckInTriggerType.scheduled,
      notifyContactIds: notifyContactIds,
      tripId: tripId,
      completedAt: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _checkIns[checkIn.id] = checkIn;
    debugPrint('Mock: Scheduled check-in ${checkIn.id}');
    return checkIn;
  }

  @override
  Future<void> cancelCheckIn(String checkInId) async {
    await _simulateDelay();
    _checkOffline();

    final checkIn = _checkIns[checkInId];
    if (checkIn == null) {
      throw const CheckInNotFoundException();
    }

    if (checkIn.status == CheckInStatus.completed) {
      throw const CheckInCannotBeCanceledException();
    }

    _checkIns.remove(checkInId);
    debugPrint('Mock: Canceled check-in $checkInId');
  }

  @override
  Future<List<CheckInModel>> getUpcomingCheckIns() async {
    await _simulateDelay();
    _checkOffline();

    return _checkIns.values
        .where((checkIn) =>
            checkIn.status == CheckInStatus.scheduled &&
            checkIn.scheduledTime.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  @override
  Future<List<CheckInModel>> getAllCheckIns() async {
    await _simulateDelay();
    _checkOffline();

    return _checkIns.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<CheckInModel> getCheckIn(String checkInId) async {
    await _simulateDelay();
    _checkOffline();

    final checkIn = _checkIns[checkInId];
    if (checkIn == null) {
      throw const CheckInNotFoundException();
    }

    return checkIn;
  }

  @override
  Future<List<CheckInModel>> getCheckInsByTrip(String tripId) async {
    await _simulateDelay();
    _checkOffline();

    return _checkIns.values
        .where((checkIn) => checkIn.tripId == tripId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<CheckInModel> updateCheckInStatus({
    required String checkInId,
    required CheckInStatus status,
  }) async {
    await _simulateDelay();
    _checkOffline();

    final checkIn = _checkIns[checkInId];
    if (checkIn == null) {
      throw const CheckInNotFoundException();
    }

    final updatedCheckIn = checkIn.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    _checkIns[checkInId] = updatedCheckIn;
    debugPrint('Mock: Updated check-in status for $checkInId to ${status.name}');
    return updatedCheckIn;
  }

  // ==================== Location Sharing Operations ====================

  @override
  Future<LocationUpdateModel> shareLocation({
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
    await _simulateDelay();
    _checkOffline();

    if (shareWithContactIds.isEmpty) {
      throw const InvalidLocationDataException(
        'Must specify at least one contact to share with',
      );
    }

    final locationUpdate = LocationUpdateModel(
      id: _generateId(),
      userId: 'mock-user-id',
      location: LocationUpdateLocation(
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
        altitude: altitude,
        speed: speed,
        heading: heading,
        timestamp: DateTime.now(),
      ),
      address: address,
      placeName: placeName,
      sharedWithContactIds: shareWithContactIds,
      sharingStatus: LocationSharingStatus.active,
      batteryLevel: batteryLevel,
      isEmergencyShare: isEmergency,
      emergencyAlertId: emergencyAlertId,
      checkInId: checkInId,
      startedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      createdAt: DateTime.now(),
    );

    _locationUpdates[locationUpdate.id] = locationUpdate;
    debugPrint('Mock: Shared location ${locationUpdate.id}');
    return locationUpdate;
  }

  @override
  Future<void> stopLocationSharing(List<String> contactIds) async {
    await _simulateDelay();
    _checkOffline();

    // Update location shares for specified contacts
    _locationUpdates.forEach((id, update) {
      if (update.sharingStatus == LocationSharingStatus.active &&
          update.sharedWithContactIds
              .any((contactId) => contactIds.contains(contactId))) {
        _locationUpdates[id] = update.copyWith(
          sharingStatus: LocationSharingStatus.stopped,
        );
      }
    });

    debugPrint('Mock: Stopped location sharing for contacts: $contactIds');
  }

  @override
  Future<void> stopAllLocationSharing() async {
    await _simulateDelay();
    _checkOffline();

    // Stop all active location shares
    _locationUpdates.forEach((id, update) {
      if (update.sharingStatus == LocationSharingStatus.active) {
        _locationUpdates[id] = update.copyWith(
          sharingStatus: LocationSharingStatus.stopped,
        );
      }
    });

    debugPrint('Mock: Stopped all location sharing');
  }

  @override
  Future<List<LocationUpdateModel>> getActiveLocationShares() async {
    await _simulateDelay();
    _checkOffline();

    return _locationUpdates.values
        .where((update) => update.sharingStatus == LocationSharingStatus.active)
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  @override
  Future<List<LocationUpdateModel>> getLocationUpdates({
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await _simulateDelay();
    _checkOffline();

    var updates = _locationUpdates.values.toList();

    if (startDate != null) {
      updates = updates.where((u) => u.createdAt.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      updates = updates.where((u) => u.createdAt.isBefore(endDate)).toList();
    }

    updates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return updates.take(limit).toList();
  }

  @override
  Future<void> updateLocationSharingPermission({
    required String contactId,
    required bool enabled,
  }) async {
    await _simulateDelay();
    _checkOffline();

    if (!_trustedContacts.containsKey(contactId)) {
      throw const TrustedContactNotFoundException();
    }

    final contact = _trustedContacts[contactId]!;
    _trustedContacts[contactId] = contact.copyWith(
      receivesLocationUpdates: enabled,
      updatedAt: DateTime.now(),
    );

    debugPrint('Mock: Updated location sharing permission for $contactId');
  }

  // ==================== Emergency SOS Operations ====================

  @override
  Future<SafetyAlertModel> triggerEmergencySOS({
    required String userId,
    String? message,
    required SafetyAlertLocation location,
    required List<String> notifyContactIds,
    int? batteryLevel,
    String? tripId,
  }) async {
    await _simulateDelay();
    _checkOffline();

    // Check if there's already an active emergency alert
    final hasActiveSOS = _safetyAlerts.values.any(
      (alert) =>
          alert.alertType == SafetyAlertType.emergencySOS &&
          alert.status == SafetyAlertStatus.active,
    );

    if (hasActiveSOS) {
      throw const EmergencySOSAlreadyActiveException();
    }

    if (notifyContactIds.isEmpty) {
      throw const NoTrustedContactsConfiguredException();
    }

    final alert = SafetyAlertModel(
      id: _generateId(),
      userId: userId,
      alertType: SafetyAlertType.emergencySOS,
      status: SafetyAlertStatus.active,
      location: location,
      message: message,
      notifiedContactIds: notifyContactIds,
      acknowledgedByContactIds: [],
      batteryLevel: batteryLevel,
      triggeredAt: DateTime.now(),
      resolvedAt: null,
      canceledAt: null,
      tripId: tripId,
      checkInId: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _safetyAlerts[alert.id] = alert;
    debugPrint('Mock: Triggered emergency SOS ${alert.id}');
    return alert;
  }

  @override
  Future<SafetyStatusModel> updateSafetyStatus({
    required SafetyStatusType status,
    String? message,
    SafetyStatusLocation? location,
    int? batteryLevel,
    String? safetyAlertId,
    String? checkInId,
  }) async {
    await _simulateDelay();
    _checkOffline();

    final safetyStatus = SafetyStatusModel(
      id: _generateId(),
      userId: 'mock-user-id',
      status: status,
      message: message,
      location: location,
      batteryLevel: batteryLevel,
      safetyAlertId: safetyAlertId,
      checkInId: checkInId,
      updatedAt: DateTime.now(),
    );

    _currentSafetyStatus = safetyStatus;
    debugPrint('Mock: Updated safety status to ${status.name}');
    return safetyStatus;
  }

  @override
  Future<SafetyStatusModel> getSafetyStatus() async {
    await _simulateDelay();
    _checkOffline();

    if (_currentSafetyStatus == null) {
      // Return default safe status
      _currentSafetyStatus = SafetyStatusModel(
        id: _generateId(),
        userId: 'mock-user-id',
        status: SafetyStatusType.safe,
        updatedAt: DateTime.now(),
      );
    }

    return _currentSafetyStatus!;
  }

  @override
  Future<SafetyStatusModel> getSafetyStatusForUser(String userId) async {
    await _simulateDelay();
    _checkOffline();

    // For mock purposes, return current status regardless of userId
    return getSafetyStatus();
  }

  // ==================== Safety Alerts Operations ====================

  @override
  Future<List<SafetyAlertModel>> getSafetyAlerts() async {
    await _simulateDelay();
    _checkOffline();

    return _safetyAlerts.values.toList()
      ..sort((a, b) => b.triggeredAt.compareTo(a.triggeredAt));
  }

  @override
  Future<SafetyAlertModel> getSafetyAlert(String alertId) async {
    await _simulateDelay();
    _checkOffline();

    final alert = _safetyAlerts[alertId];
    if (alert == null) {
      throw const SafetyAlertNotFoundException();
    }

    return alert;
  }

  @override
  Future<List<SafetyAlertModel>> getRecentSafetyAlerts({
    int limit = 20,
    SafetyAlertType? type,
  }) async {
    await _simulateDelay();
    _checkOffline();

    var alerts = _safetyAlerts.values.toList();

    if (type != null) {
      alerts = alerts.where((alert) => alert.alertType == type).toList();
    }

    alerts.sort((a, b) => b.triggeredAt.compareTo(a.triggeredAt));
    return alerts.take(limit).toList();
  }

  @override
  Future<void> acknowledgeSafetyAlert(String alertId, String contactId) async {
    await _simulateDelay();
    _checkOffline();

    final alert = _safetyAlerts[alertId];
    if (alert == null) {
      throw const SafetyAlertNotFoundException();
    }

    if (alert.status != SafetyAlertStatus.active) {
      throw const SafetyAlertAlreadyAcknowledgedException();
    }

    final acknowledgedBy = List<String>.from(alert.acknowledgedByContactIds);
    if (acknowledgedBy.contains(contactId)) {
      throw const SafetyAlertAlreadyAcknowledgedException();
    }

    acknowledgedBy.add(contactId);
    _safetyAlerts[alertId] = alert.copyWith(
      acknowledgedByContactIds: acknowledgedBy,
      updatedAt: DateTime.now(),
    );

    debugPrint('Mock: Acknowledged safety alert $alertId by contact $contactId');
  }

  @override
  Future<void> resolveSafetyAlert(String alertId) async {
    await _simulateDelay();
    _checkOffline();

    final alert = _safetyAlerts[alertId];
    if (alert == null) {
      throw const SafetyAlertNotFoundException();
    }

    if (alert.status == SafetyAlertStatus.resolved) {
      throw const SafetyAlertAlreadyResolvedException();
    }

    _safetyAlerts[alertId] = alert.copyWith(
      status: SafetyAlertStatus.resolved,
      resolvedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    debugPrint('Mock: Resolved safety alert $alertId');
  }

  @override
  Future<void> cancelSafetyAlert(String alertId) async {
    await _simulateDelay();
    _checkOffline();

    final alert = _safetyAlerts[alertId];
    if (alert == null) {
      throw const SafetyAlertNotFoundException();
    }

    if (alert.status != SafetyAlertStatus.active) {
      throw const SafetyAlertAlreadyResolvedException();
    }

    _safetyAlerts[alertId] = alert.copyWith(
      status: SafetyAlertStatus.canceled,
      canceledAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    debugPrint('Mock: Canceled safety alert $alertId');
  }

  @override
  Future<List<SafetyAlertModel>> getMissedCheckInAlerts() async {
    await _simulateDelay();
    _checkOffline();

    return _safetyAlerts.values
        .where((alert) => alert.alertType == SafetyAlertType.missedCheckIn)
        .toList()
      ..sort((a, b) => b.triggeredAt.compareTo(a.triggeredAt));
  }

  // ==================== Battery & Location Services ====================

  @override
  Future<void> updateBatteryLevel(int level) async {
    await _simulateDelay();
    _checkOffline();

    if (level < 0 || level > 100) {
      throw const InvalidSafetySettingsException(
        'Battery level must be between 0 and 100',
      );
    }

    _batteryLevel = level;
    debugPrint('Mock: Updated battery level to $level%');
  }

  @override
  Future<int?> getBatteryLevel() async {
    await _simulateDelay();
    _checkOffline();

    return _batteryLevel;
  }

  // ==================== Settings & Preferences ====================

  @override
  Future<void> updateContactNotificationPreferences({
    required String contactId,
    required bool receivesCheckIns,
    required bool receivesEmergencyAlerts,
  }) async {
    await _simulateDelay();
    _checkOffline();

    final contact = _trustedContacts[contactId];
    if (contact == null) {
      throw const TrustedContactNotFoundException();
    }

    _trustedContacts[contactId] = contact.copyWith(
      receivesCheckInNotifications: receivesCheckIns,
      receivesEmergencyAlerts: receivesEmergencyAlerts,
      updatedAt: DateTime.now(),
    );

    debugPrint('Mock: Updated notification preferences for $contactId');
  }

  @override
  Future<Map<String, dynamic>> getSafetySettings() async {
    await _simulateDelay();
    _checkOffline();

    // Return default mock settings
    return {
      'checkInRemindersEnabled': true,
      'locationSharingEnabled': true,
      'emergencyAlertsEnabled': true,
      'batteryMonitoringEnabled': true,
      'checkInReminderMinutes': 15,
      'locationUpdateInterval': 5,
      'maxTrustedContacts': 10,
    };
  }

  @override
  Future<void> updateSafetySettings(Map<String, dynamic> settings) async {
    await _simulateDelay();
    _checkOffline();

    // Validate settings
    if (settings.containsKey('maxTrustedContacts')) {
      final maxContacts = settings['maxTrustedContacts'] as int?;
      if (maxContacts != null && (maxContacts < 1 || maxContacts > 50)) {
        throw const InvalidSafetySettingsException(
          'Max trusted contacts must be between 1 and 50',
        );
      }
    }

    debugPrint('Mock: Updated safety settings: $settings');
  }
}
