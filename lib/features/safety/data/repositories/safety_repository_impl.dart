import 'package:soloadventurer/core/error/exceptions.dart';
import 'package:soloadventurer/core/error/safety_exceptions.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_local_data_source.dart';
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
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';
import 'package:soloadventurer/features/safety/domain/repositories/safety_repository.dart';

/// Implementation of [SafetyRepository] that coordinates between local and remote data sources
class SafetyRepositoryImpl implements SafetyRepository {
  final SafetyRemoteDataSource _remoteDataSource;
  final SafetyLocalDataSource _localDataSource;

  /// Creates a new [SafetyRepositoryImpl] with the given data sources
  const SafetyRepositoryImpl({
    required SafetyRemoteDataSource remoteDataSource,
    required SafetyLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  // ==================== Trusted Contacts Operations ====================

  @override
  Future<TrustedContact> addTrustedContact(TrustedContact contact) async {
    try {
      final contactModel = TrustedContactModel.fromEntity(contact);
      final createdContact = await _remoteDataSource.addTrustedContact(contactModel);
      await _localDataSource.cacheTrustedContact(createdContact);
      return createdContact.toEntity();
    } on SafetyException {
      rethrow;
    } on AppException catch (e) {
      throw SafetyOfflineException('Failed to add trusted contact: ${e.message}');
    } catch (e) {
      throw SafetyException('Failed to add trusted contact: ${e.toString()}',
          code: 'add_trusted_contact_failed');
    }
  }

  @override
  Future<void> removeTrustedContact(String contactId) async {
    try {
      await _remoteDataSource.removeTrustedContact(contactId);
      await _localDataSource.removeCachedTrustedContact(contactId);
    } on SafetyException {
      rethrow;
    } on AppException catch (e) {
      throw SafetyOfflineException('Failed to remove trusted contact: ${e.message}');
    } catch (e) {
      throw SafetyException('Failed to remove trusted contact: ${e.toString()}',
          code: 'remove_trusted_contact_failed');
    }
  }

  @override
  Future<TrustedContact> updateTrustedContact(TrustedContact contact) async {
    try {
      final contactModel = TrustedContactModel.fromEntity(contact);
      final updatedContact = await _remoteDataSource.updateTrustedContact(contactModel);
      await _localDataSource.cacheTrustedContact(updatedContact);
      return updatedContact.toEntity();
    } on SafetyException {
      rethrow;
    } on AppException catch (e) {
      throw SafetyOfflineException('Failed to update trusted contact: ${e.message}');
    } catch (e) {
      throw SafetyException('Failed to update trusted contact: ${e.toString()}',
          code: 'update_trusted_contact_failed');
    }
  }

  @override
  Future<List<TrustedContact>> getTrustedContacts() async {
    try {
      final contacts = await _remoteDataSource.getTrustedContacts();
      await _localDataSource.cacheTrustedContacts(contacts);
      return contacts.map((model) => model.toEntity()).toList();
    } on AppException catch (_) {
      // Fallback to cache when offline
      final cachedContacts = await _localDataSource.getCachedTrustedContacts();
      return cachedContacts.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw SafetyException('Failed to get trusted contacts: ${e.toString()}',
          code: 'get_trusted_contacts_failed');
    }
  }

  @override
  Future<TrustedContact> getTrustedContact(String contactId) async {
    try {
      final contact = await _remoteDataSource.getTrustedContact(contactId);
      await _localDataSource.cacheTrustedContact(contact);
      return contact.toEntity();
    } on AppException catch (_) {
      // Fallback to cache when offline
      final cachedContact = await _localDataSource.getCachedTrustedContact(contactId);
      if (cachedContact == null) {
        throw const TrustedContactNotFoundException();
      }
      return cachedContact.toEntity();
    } catch (e) {
      throw SafetyException('Failed to get trusted contact: ${e.toString()}',
          code: 'get_trusted_contact_failed');
    }
  }

  // ==================== Check-in Operations ====================

  @override
  Future<CheckIn> createCheckIn(CheckIn checkIn) async {
    try {
      final checkInModel = CheckInModel.fromEntity(checkIn);
      final createdCheckIn = await _remoteDataSource.createCheckIn(checkInModel);
      await _localDataSource.cacheCheckIn(createdCheckIn);
      return createdCheckIn.toEntity();
    } on SafetyException {
      rethrow;
    } on AppException catch (e) {
      throw SafetyOfflineException('Failed to create check-in: ${e.message}');
    } catch (e) {
      throw SafetyException('Failed to create check-in: ${e.toString()}',
          code: 'create_check_in_failed');
    }
  }

  @override
  Future<CheckIn> completeCheckIn({
    required String checkInId,
    required CheckInLocation location,
    String? statusMessage,
  }) async {
    try {
      final completedCheckIn = await _remoteDataSource.completeCheckIn(
        checkInId: checkInId,
        location: location,
        statusMessage: statusMessage,
      );
      await _localDataSource.cacheCheckIn(completedCheckIn);
      return completedCheckIn.toEntity();
    } on SafetyException {
      rethrow;
    } on AppException catch (e) {
      throw SafetyOfflineException('Failed to complete check-in: ${e.message}');
    } catch (e) {
      throw SafetyException('Failed to complete check-in: ${e.toString()}',
          code: 'complete_check_in_failed');
    }
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
    try {
      final scheduledCheckIn = await _remoteDataSource.scheduleCheckIn(
        userId: userId,
        scheduledTime: scheduledTime,
        deadline: deadline,
        location: location,
        statusMessage: statusMessage,
        notifyContactIds: notifyContactIds,
        tripId: tripId,
        triggerType: triggerType,
      );
      await _localDataSource.cacheCheckIn(scheduledCheckIn);
      return scheduledCheckIn.toEntity();
    } on SafetyException {
      rethrow;
    } on AppException catch (e) {
      throw SafetyOfflineException('Failed to schedule check-in: ${e.message}');
    } catch (e) {
      throw SafetyException('Failed to schedule check-in: ${e.toString()}',
          code: 'schedule_check_in_failed');
    }
  }

  @override
  Future<void> cancelCheckIn(String checkInId) async {
    try {
      await _remoteDataSource.cancelCheckIn(checkInId);
      await _localDataSource.removeCachedCheckIn(checkInId);
    } on SafetyException {
      rethrow;
    } on AppException catch (e) {
      throw SafetyOfflineException('Failed to cancel check-in: ${e.message}');
    } catch (e) {
      throw SafetyException('Failed to cancel check-in: ${e.toString()}',
          code: 'cancel_check_in_failed');
    }
  }

  @override
  Future<List<CheckIn>> getUpcomingCheckIns() async {
    try {
      final checkIns = await _remoteDataSource.getUpcomingCheckIns();
      await _localDataSource.cacheCheckIns(checkIns);
      return checkIns.map((model) => model.toEntity()).toList();
    } on AppException catch (_) {
      // Fallback to cache when offline
      final cachedCheckIns = await _localDataSource.getCachedUpcomingCheckIns();
      return cachedCheckIns.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw SafetyException('Failed to get upcoming check-ins: ${e.toString()}',
          code: 'get_upcoming_check_ins_failed');
    }
  }

  @override
  Future<List<CheckIn>> getAllCheckIns() async {
    try {
      final checkIns = await _remoteDataSource.getAllCheckIns();
      await _localDataSource.cacheCheckIns(checkIns);
      return checkIns.map((model) => model.toEntity()).toList();
    } on AppException catch (_) {
      // Fallback to cache when offline
      final cachedCheckIns = await _localDataSource.getCachedCheckIns();
      return cachedCheckIns.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw SafetyException('Failed to get all check-ins: ${e.toString()}',
          code: 'get_all_check_ins_failed');
    }
  }

  @override
  Future<CheckIn> getCheckIn(String checkInId) async {
    try {
      final checkIn = await _remoteDataSource.getCheckIn(checkInId);
      await _localDataSource.cacheCheckIn(checkIn);
      return checkIn.toEntity();
    } on AppException catch (_) {
      // Fallback to cache when offline
      final cachedCheckIn = await _localDataSource.getCachedCheckIn(checkInId);
      if (cachedCheckIn == null) {
        throw const CheckInNotFoundException();
      }
      return cachedCheckIn.toEntity();
    } catch (e) {
      throw SafetyException('Failed to get check-in: ${e.toString()}',
          code: 'get_check_in_failed');
    }
  }

  @override
  Future<List<CheckIn>> getCheckInsByTrip(String tripId) async {
    try {
      final checkIns = await _remoteDataSource.getCheckInsByTrip(tripId);
      return checkIns.map((model) => model.toEntity()).toList();
    } on AppException catch (_) {
      // Fallback to cache when offline - filter by tripId
      final cachedCheckIns = await _localDataSource.getCachedCheckIns();
      final filteredCheckIns = cachedCheckIns
          .where((checkIn) => checkIn.tripId == tripId)
          .toList();
      return filteredCheckIns.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw SafetyException('Failed to get check-ins by trip: ${e.toString()}',
          code: 'get_check_ins_by_trip_failed');
    }
  }

  @override
  Future<CheckIn> updateCheckInStatus({
    required String checkInId,
    required CheckInStatus status,
  }) async {
    try {
      final updatedCheckIn = await _remoteDataSource.updateCheckInStatus(
        checkInId: checkInId,
        status: status,
      );
      await _localDataSource.cacheCheckIn(updatedCheckIn);
      return updatedCheckIn.toEntity();
    } on SafetyException {
      rethrow;
    } on AppException catch (e) {
      throw SafetyOfflineException('Failed to update check-in status: ${e.message}');
    } catch (e) {
      throw SafetyException('Failed to update check-in status: ${e.toString()}',
          code: 'update_check_in_status_failed');
    }
  }

  // ==================== Location Sharing Operations ====================

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
    try {
      final locationUpdate = await _remoteDataSource.shareLocation(
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
      await _localDataSource.cacheLocationUpdate(locationUpdate);
      return locationUpdate.toEntity();
    } on SafetyException {
      rethrow;
    } on AppException catch (e) {
      throw SafetyOfflineException('Failed to share location: ${e.message}');
    } catch (e) {
      throw SafetyException('Failed to share location: ${e.toString()}',
          code: 'share_location_failed');
    }
  }

  @override
  Future<void> stopLocationSharing(List<String> contactIds) async {
    try {
      await _remoteDataSource.stopLocationSharing(contactIds);
      // Note: We don't remove from cache as we want to keep historical records
    } on SafetyException {
      rethrow;
    } on AppException catch (e) {
      throw SafetyOfflineException('Failed to stop location sharing: ${e.message}');
    } catch (e) {
      throw SafetyException('Failed to stop location sharing: ${e.toString()}',
          code: 'stop_location_sharing_failed');
    }
  }

  @override
  Future<void> stopAllLocationSharing() async {
    try {
      await _remoteDataSource.stopAllLocationSharing();
      // Note: We don't remove from cache as we want to keep historical records
    } on SafetyException {
      rethrow;
    } on AppException catch (e) {
      throw SafetyOfflineException('Failed to stop all location sharing: ${e.message}');
    } catch (e) {
      throw SafetyException('Failed to stop all location sharing: ${e.toString()}',
          code: 'stop_all_location_sharing_failed');
    }
  }

  @override
  Future<List<LocationUpdate>> getActiveLocationShares() async {
    try {
      final locationUpdates = await _remoteDataSource.getActiveLocationShares();
      await _localDataSource.cacheLocationUpdates(locationUpdates);
      return locationUpdates.map((model) => model.toEntity()).toList();
    } on AppException catch (_) {
      // Fallback to cache when offline
      final cachedUpdates = await _localDataSource.getCachedActiveLocationShares();
      return cachedUpdates.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw SafetyException('Failed to get active location shares: ${e.toString()}',
          code: 'get_active_location_shares_failed');
    }
  }

  @override
  Future<List<LocationUpdate>> getLocationUpdates({
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final locationUpdates = await _remoteDataSource.getLocationUpdates(
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );
      return locationUpdates.map((model) => model.toEntity()).toList();
    } on AppException catch (_) {
      // Fallback to cache when offline
      final cachedUpdates = await _localDataSource.getCachedLocationUpdates();
      // Apply limit and filtering
      var filteredUpdates = cachedUpdates;
      if (startDate != null) {
        filteredUpdates = filteredUpdates
            .where((update) => update.timestamp.isAfter(startDate))
            .toList();
      }
      if (endDate != null) {
        filteredUpdates = filteredUpdates
            .where((update) => update.timestamp.isBefore(endDate))
            .toList();
      }
      if (filteredUpdates.length > limit) {
        filteredUpdates = filteredUpdates.take(limit).toList();
      }
      return filteredUpdates.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw SafetyException('Failed to get location updates: ${e.toString()}',
          code: 'get_location_updates_failed');
    }
  }

  @override
  Future<void> updateLocationSharingPermission({
    required String contactId,
    required bool enabled,
  }) async {
    try {
      await _remoteDataSource.updateLocationSharingPermission(
        contactId: contactId,
        enabled: enabled,
      );
      // Update the cached contact with new permission
      final cachedContact = await _localDataSource.getCachedTrustedContact(contactId);
      if (cachedContact != null) {
        final updatedContact = cachedContact.copyWith(
          locationSharingEnabled: enabled,
        );
        await _localDataSource.cacheTrustedContact(updatedContact);
      }
    } on SafetyException {
      rethrow;
    } on AppException catch (e) {
      throw SafetyOfflineException('Failed to update location sharing permission: ${e.message}');
    } catch (e) {
      throw SafetyException('Failed to update location sharing permission: ${e.toString()}',
          code: 'update_location_sharing_permission_failed');
    }
  }

  // ==================== Emergency SOS Operations ====================

  @override
  Future<SafetyAlert> triggerEmergencySOS({
    required String userId,
    String? message,
    required SafetyAlertLocation location,
    required List<String> notifyContactIds,
    int? batteryLevel,
    String? tripId,
  }) async {
    try {
      final alert = await _remoteDataSource.triggerEmergencySOS(
        userId: userId,
        message: message,
        location: location,
        notifyContactIds: notifyContactIds,
        batteryLevel: batteryLevel,
        tripId: tripId,
      );
      await _localDataSource.cacheSafetyAlert(alert);
      return alert.toEntity();
    } on SafetyException {
      rethrow;
    } on AppException catch (e) {
      throw SafetyOfflineException('Failed to trigger emergency SOS: ${e.message}');
    } catch (e) {
      throw SafetyException('Failed to trigger emergency SOS: ${e.toString()}',
          code: 'trigger_emergency_sos_failed');
    }
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
    try {
      final safetyStatus = await _remoteDataSource.updateSafetyStatus(
        status: status,
        message: message,
        location: location,
        batteryLevel: batteryLevel,
        safetyAlertId: safetyAlertId,
        checkInId: checkInId,
      );
      await _localDataSource.cacheSafetyStatus(safetyStatus);
      return safetyStatus.toEntity();
    } on SafetyException {
      rethrow;
    } on AppException catch (e) {
      throw SafetyOfflineException('Failed to update safety status: ${e.message}');
    } catch (e) {
      throw SafetyException('Failed to update safety status: ${e.toString()}',
          code: 'update_safety_status_failed');
    }
  }

  @override
  Future<SafetyStatus> getSafetyStatus() async {
    try {
      final safetyStatus = await _remoteDataSource.getSafetyStatus();
      await _localDataSource.cacheSafetyStatus(safetyStatus);
      return safetyStatus.toEntity();
    } on AppException catch (_) {
      // Fallback to cache when offline
      final cachedStatus = await _localDataSource.getCachedSafetyStatus();
      if (cachedStatus == null) {
        throw const SafetyException('No safety status available',
            code: 'safety_status_not_found');
      }
      return cachedStatus.toEntity();
    } catch (e) {
      throw SafetyException('Failed to get safety status: ${e.toString()}',
          code: 'get_safety_status_failed');
    }
  }

  @override
  Future<SafetyStatus> getSafetyStatusForUser(String userId) async {
    try {
      final safetyStatus = await _remoteDataSource.getSafetyStatusForUser(userId);
      // Note: We don't cache other users' status
      return safetyStatus.toEntity();
    } on SafetyException {
      rethrow;
    } on AppException catch (e) {
      throw SafetyOfflineException('Failed to get safety status for user: ${e.message}');
    } catch (e) {
      throw SafetyException('Failed to get safety status for user: ${e.toString()}',
          code: 'get_safety_status_for_user_failed');
    }
  }

  // ==================== Safety Alerts Operations ====================

  @override
  Future<List<SafetyAlert>> getSafetyAlerts() async {
    try {
      final alerts = await _remoteDataSource.getSafetyAlerts();
      await _localDataSource.cacheSafetyAlerts(alerts);
      return alerts.map((model) => model.toEntity()).toList();
    } on AppException catch (_) {
      // Fallback to cache when offline
      final cachedAlerts = await _localDataSource.getCachedSafetyAlerts();
      return cachedAlerts.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw SafetyException('Failed to get safety alerts: ${e.toString()}',
          code: 'get_safety_alerts_failed');
    }
  }

  @override
  Future<SafetyAlert> getSafetyAlert(String alertId) async {
    try {
      final alert = await _remoteDataSource.getSafetyAlert(alertId);
      await _localDataSource.cacheSafetyAlert(alert);
      return alert.toEntity();
    } on AppException catch (_) {
      // Fallback to cache when offline
      final cachedAlert = await _localDataSource.getCachedSafetyAlert(alertId);
      if (cachedAlert == null) {
        throw const SafetyAlertNotFoundException();
      }
      return cachedAlert.toEntity();
    } catch (e) {
      throw SafetyException('Failed to get safety alert: ${e.toString()}',
          code: 'get_safety_alert_failed');
    }
  }

  @override
  Future<List<SafetyAlert>> getRecentSafetyAlerts({
    int limit = 20,
    SafetyAlertType? type,
  }) async {
    try {
      final alerts = await _remoteDataSource.getRecentSafetyAlerts(
        limit: limit,
        type: type,
      );
      return alerts.map((model) => model.toEntity()).toList();
    } on AppException catch (_) {
      // Fallback to cache when offline
      final cachedAlerts = await _localDataSource.getCachedRecentSafetyAlerts(limit: limit);
      if (type != null) {
        final filteredAlerts = cachedAlerts.where((alert) => alert.type == type).toList();
        return filteredAlerts.map((model) => model.toEntity()).toList();
      }
      return cachedAlerts.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw SafetyException('Failed to get recent safety alerts: ${e.toString()}',
          code: 'get_recent_safety_alerts_failed');
    }
  }

  @override
  Future<void> acknowledgeSafetyAlert(String alertId, String contactId) async {
    try {
      await _remoteDataSource.acknowledgeSafetyAlert(alertId, contactId);
      // Update cached alert
      final cachedAlert = await _localDataSource.getCachedSafetyAlert(alertId);
      if (cachedAlert != null) {
        final acknowledgedBy = [...cachedAlert.acknowledgedBy, contactId];
        final updatedAlert = cachedAlert.copyWith(
          acknowledgedBy: acknowledgedBy,
          acknowledgedAt: DateTime.now(),
        );
        await _localDataSource.cacheSafetyAlert(updatedAlert);
      }
    } on SafetyException {
      rethrow;
    } on AppException catch (e) {
      throw SafetyOfflineException('Failed to acknowledge safety alert: ${e.message}');
    } catch (e) {
      throw SafetyException('Failed to acknowledge safety alert: ${e.toString()}',
          code: 'acknowledge_safety_alert_failed');
    }
  }

  @override
  Future<void> resolveSafetyAlert(String alertId) async {
    try {
      await _remoteDataSource.resolveSafetyAlert(alertId);
      // Update cached alert
      final cachedAlert = await _localDataSource.getCachedSafetyAlert(alertId);
      if (cachedAlert != null) {
        final updatedAlert = cachedAlert.copyWith(
          status: SafetyAlertStatus.resolved,
          resolvedAt: DateTime.now(),
        );
        await _localDataSource.cacheSafetyAlert(updatedAlert);
      }
    } on SafetyException {
      rethrow;
    } on AppException catch (e) {
      throw SafetyOfflineException('Failed to resolve safety alert: ${e.message}');
    } catch (e) {
      throw SafetyException('Failed to resolve safety alert: ${e.toString()}',
          code: 'resolve_safety_alert_failed');
    }
  }

  @override
  Future<void> cancelSafetyAlert(String alertId) async {
    try {
      await _remoteDataSource.cancelSafetyAlert(alertId);
      // Update cached alert
      final cachedAlert = await _localDataSource.getCachedSafetyAlert(alertId);
      if (cachedAlert != null) {
        final updatedAlert = cachedAlert.copyWith(
          status: SafetyAlertStatus.canceled,
          resolvedAt: DateTime.now(),
        );
        await _localDataSource.cacheSafetyAlert(updatedAlert);
      }
    } on SafetyException {
      rethrow;
    } on AppException catch (e) {
      throw SafetyOfflineException('Failed to cancel safety alert: ${e.message}');
    } catch (e) {
      throw SafetyException('Failed to cancel safety alert: ${e.toString()}',
          code: 'cancel_safety_alert_failed');
    }
  }

  @override
  Future<List<SafetyAlert>> getMissedCheckInAlerts() async {
    try {
      final alerts = await _remoteDataSource.getMissedCheckInAlerts();
      return alerts.map((model) => model.toEntity()).toList();
    } on AppException catch (_) {
      // Fallback to cache when offline
      final cachedAlerts = await _localDataSource.getCachedMissedCheckInAlerts();
      return cachedAlerts.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw SafetyException('Failed to get missed check-in alerts: ${e.toString()}',
          code: 'get_missed_check_in_alerts_failed');
    }
  }

  // ==================== Battery & Location Services ====================

  @override
  Future<void> updateBatteryLevel(int level) async {
    try {
      await _remoteDataSource.updateBatteryLevel(level);
      await _localDataSource.cacheBatteryLevel(level);
    } on SafetyException {
      rethrow;
    } on AppException catch (e) {
      throw SafetyOfflineException('Failed to update battery level: ${e.message}');
    } catch (e) {
      throw SafetyException('Failed to update battery level: ${e.toString()}',
          code: 'update_battery_level_failed');
    }
  }

  @override
  Future<int?> getBatteryLevel() async {
    try {
      final batteryLevel = await _remoteDataSource.getBatteryLevel();
      if (batteryLevel != null) {
        await _localDataSource.cacheBatteryLevel(batteryLevel);
      }
      return batteryLevel;
    } on AppException catch (_) {
      // Fallback to cache when offline
      return await _localDataSource.getCachedBatteryLevel();
    } catch (e) {
      throw SafetyException('Failed to get battery level: ${e.toString()}',
          code: 'get_battery_level_failed');
    }
  }

  // ==================== Settings & Preferences ====================

  @override
  Future<void> updateContactNotificationPreferences({
    required String contactId,
    required bool receivesCheckIns,
    required bool receivesEmergencyAlerts,
  }) async {
    try {
      await _remoteDataSource.updateContactNotificationPreferences(
        contactId: contactId,
        receivesCheckIns: receivesCheckIns,
        receivesEmergencyAlerts: receivesEmergencyAlerts,
      );
      // Update the cached contact with new preferences
      final cachedContact = await _localDataSource.getCachedTrustedContact(contactId);
      if (cachedContact != null) {
        final updatedContact = cachedContact.copyWith(
          receivesCheckIns: receivesCheckIns,
          receivesEmergencyAlerts: receivesEmergencyAlerts,
        );
        await _localDataSource.cacheTrustedContact(updatedContact);
      }
    } on SafetyException {
      rethrow;
    } on AppException catch (e) {
      throw SafetyOfflineException('Failed to update contact notification preferences: ${e.message}');
    } catch (e) {
      throw SafetyException('Failed to update contact notification preferences: ${e.toString()}',
          code: 'update_contact_notification_preferences_failed');
    }
  }

  @override
  Future<Map<String, dynamic>> getSafetySettings() async {
    try {
      final settings = await _remoteDataSource.getSafetySettings();
      await _localDataSource.cacheSafetySettings(settings);
      return settings;
    } on AppException catch (_) {
      // Fallback to cache when offline
      final cachedSettings = await _localDataSource.getCachedSafetySettings();
      if (cachedSettings == null) {
        throw const SafetySettingsLoadFailedException();
      }
      return cachedSettings;
    } catch (e) {
      throw SafetyException('Failed to get safety settings: ${e.toString()}',
          code: 'get_safety_settings_failed');
    }
  }

  @override
  Future<void> updateSafetySettings(Map<String, dynamic> settings) async {
    try {
      await _remoteDataSource.updateSafetySettings(settings);
      await _localDataSource.cacheSafetySettings(settings);
    } on SafetyException {
      rethrow;
    } on AppException catch (e) {
      throw SafetyOfflineException('Failed to update safety settings: ${e.message}');
    } catch (e) {
      throw SafetyException('Failed to update safety settings: ${e.toString()}',
          code: 'update_safety_settings_failed');
    }
  }
}
