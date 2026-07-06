import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/core/services/location_service.dart';
import 'package:soloadventurer/core/services/location_service_impl.dart';
import 'package:soloadventurer/core/services/notification_service.dart';
import 'package:soloadventurer/core/services/notification_service_impl.dart';
import 'package:soloadventurer/features/safety/data/repositories/safety_providers.dart';
import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import 'package:soloadventurer/features/safety/domain/entities/location_update.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';
import 'package:soloadventurer/features/safety/domain/repositories/safety_repository.dart';
import 'missed_checkin_detector.dart';

part 'missed_checkin_detector_impl.g.dart';

/// Implementation of [MissedCheckInDetector]
class MissedCheckInDetectorImpl implements MissedCheckInDetector {
  final SafetyRepository _safetyRepository;
  final LocationService _locationService;
  final NotificationService _notificationService;

  MissedCheckInDetectorStatus _status = MissedCheckInDetectorStatus.stopped;
  final _statusController =
      StreamController<MissedCheckInDetectorStatus>.broadcast();

  @override
  MissedCheckInDetectorStatus get status => _status;

  @override
  Stream<MissedCheckInDetectorStatus> get onStatusChanged =>
      _statusController.stream;

  MissedCheckInDetectorImpl({
    required SafetyRepository safetyRepository,
    required LocationService locationService,
    required NotificationService notificationService,
  })  : _safetyRepository = safetyRepository,
        _locationService = locationService,
        _notificationService = notificationService;

  @override
  Future<void> initialize() async {
    if (_status == MissedCheckInDetectorStatus.initialized) {
      return;
    }

    _updateStatus(MissedCheckInDetectorStatus.initialized);
  }

  @override
  Future<MissedCheckInDetectionResult> checkForMissedCheckIns() async {
    if (_status != MissedCheckInDetectorStatus.initialized) {
      return MissedCheckInDetectionResult.failure(
        'Detector is not initialized. Call initialize() first.',
      );
    }

    _updateStatus(MissedCheckInDetectorStatus.checking);

    try {
      // Get all upcoming check-ins (includes active and scheduled)
      final checkIns = await _safetyRepository.getUpcomingCheckIns();

      final missedCheckInIds = <String>[];
      var missedCount = 0;
      var alertsSent = 0;

      // Filter for check-ins that should be marked as missed
      final checkInsToProcess = checkIns.where((checkIn) {
        // Skip already processed missed check-ins
        if (checkIn.status == CheckInStatus.missed && checkIn.alertSent) {
          return false;
        }

        // Check if check-in is missed
        return isCheckInMissed(checkIn);
      }).toList();

      // Process each missed check-in
      for (final checkIn in checkInsToProcess) {
        try {
          // Get trusted contacts to notify
          final trustedContacts = await _getContactsForCheckIn(checkIn);

          if (trustedContacts.isEmpty) {
            // No contacts to notify, just mark as missed
            await _markCheckInAsMissed(checkIn);
            missedCheckInIds.add(checkIn.id);
            missedCount++;
            continue;
          }

          // Trigger the alert
          final alert = await triggerMissedCheckInAlert(
            checkIn: checkIn,
            trustedContacts: trustedContacts,
          );

          // Mark check-in as missed with alert sent
          await _markCheckInAsMissed(checkIn, alertSent: true);

          missedCheckInIds.add(checkIn.id);
          missedCount++;
          alertsSent++;

          // Show local notification to user
          await _notifyUserAboutMissedCheckIn(checkIn, alert);
        } catch (e) {
          // Continue processing other check-ins even if one fails
          continue;
        }
      }

      _updateStatus(MissedCheckInDetectorStatus.initialized);

      return MissedCheckInDetectionResult.success(
        processedCount: checkIns.length,
        missedCheckInsDetected: missedCount,
        alertsSent: alertsSent,
        missedCheckInIds: missedCheckInIds,
      );
    } catch (e) {
      _updateStatus(MissedCheckInDetectorStatus.error);
      return MissedCheckInDetectionResult.failure(
        'Failed to check for missed check-ins: ${e.toString()}',
      );
    }
  }

  @override
  bool isCheckInMissed(CheckIn checkIn) {
    // Skip completed or cancelled check-ins
    if (checkIn.status == CheckInStatus.completed ||
        checkIn.status == CheckInStatus.cancelled) {
      return false;
    }

    // Skip if already marked as missed and alert sent
    if (checkIn.status == CheckInStatus.missed && checkIn.alertSent) {
      return false;
    }

    // Check if deadline has passed (with grace period)
    if (checkIn.deadline == null) {
      return false;
    }

    final now = DateTime.now();
    final deadlineWithGrace = checkIn.deadline!.add(
      const Duration(minutes: MissedCheckInConfig.gracePeriodMinutes),
    );

    return now.isAfter(deadlineWithGrace);
  }

  @override
  Future<SafetyAlert> triggerMissedCheckInAlert({
    required CheckIn checkIn,
    required List<TrustedContact> trustedContacts,
  }) async {
    // Get last known location
    SafetyAlertLocation? alertLocation;

    if (MissedCheckInConfig.includeLocationInAlerts) {
      try {
        final lastKnownLocation = await _getLastKnownLocation();

        if (lastKnownLocation != null) {
          alertLocation = SafetyAlertLocation(
            latitude: lastKnownLocation.latitude,
            longitude: lastKnownLocation.longitude,
            accuracy: lastKnownLocation.accuracy,
            altitude: lastKnownLocation.altitude,
            address: lastKnownLocation.address,
            placeName: lastKnownLocation.placeName,
            timestamp: lastKnownLocation.createdAt,
            mapsUrl: _buildMapsUrl(
              lastKnownLocation.latitude,
              lastKnownLocation.longitude,
            ),
          );
        }
      } catch (e) {
        // Continue without location if unable to get it
      }
    }

    // Get battery level
    int? batteryLevel;
    try {
      batteryLevel = await _safetyRepository.getBatteryLevel();
    } catch (e) {
      // Continue without battery level if unable to get it
    }

    // Create safety alert
    final alert = await _safetyRepository.triggerEmergencySOS(
      userId: checkIn.userId,
      message: MissedCheckInConfig.defaultAlertMessage,
      location: alertLocation ??
          SafetyAlertLocation(
            latitude: 0.0,
            longitude: 0.0,
            timestamp: DateTime.now(),
          ),
      notifyContactIds: trustedContacts.map((c) => c.id).toList(),
      batteryLevel: batteryLevel,
      tripId: checkIn.tripId,
    );

    return alert;
  }

  /// Gets trusted contacts that should be notified for a check-in
  Future<List<TrustedContact>> _getContactsForCheckIn(CheckIn checkIn) async {
    try {
      // Get all trusted contacts
      final allContacts = await _safetyRepository.getTrustedContacts();

      // Filter contacts who should receive check-in notifications
      // and are in the check-in's notify list
      final relevantContacts = allContacts.where((contact) {
        // Check if contact should receive check-ins
        if (!contact.receivesCheckIns) {
          return false;
        }

        // Check if contact is in the notify list
        if (checkIn.notifyContactIds.isEmpty) {
          // If no specific contacts listed, notify all with check-ins permission
          return true;
        }

        return checkIn.notifyContactIds.contains(contact.id);
      }).toList();

      return relevantContacts;
    } catch (e) {
      return [];
    }
  }

  /// Gets the last known location from recent location updates
  Future<LocationUpdate?> _getLastKnownLocation() async {
    try {
      final updates = await _safetyRepository.getLocationUpdates(
        limit: MissedCheckInConfig.maxRecentLocations,
      );

      if (updates.isEmpty) {
        // Try to get current location
        try {
          final currentLocation = await _locationService.getCurrentLocation();
          return LocationUpdate(
            id: 'current',
            userId: '', // Will be filled by repository
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude,
            accuracy: currentLocation.accuracy,
            altitude: currentLocation.altitude,
            sharingStatus: LocationSharingStatus.active,
            sharedWithContactIds: [], // No contacts sharing yet
            createdAt: DateTime.now(),
          );
        } catch (e) {
          return null;
        }
      }

      // Find the most recent location within the max age limit
      const maxAge = Duration(hours: MissedCheckInConfig.maxLocationAgeHours);
      final now = DateTime.now();

      for (final update in updates) {
        final age = now.difference(update.createdAt);
        if (age <= maxAge) {
          return update;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Marks a check-in as missed
  Future<void> _markCheckInAsMissed(
    CheckIn checkIn, {
    bool alertSent = false,
  }) async {
    try {
      if (checkIn.status != CheckInStatus.missed) {
        await _safetyRepository.updateCheckInStatus(
          checkInId: checkIn.id,
          status: CheckInStatus.missed,
        );
      }
    } catch (e) {
      // Ignore errors when updating status
    }
  }

  /// Notifies the user about a missed check-in
  Future<void> _notifyUserAboutMissedCheckIn(
    CheckIn checkIn,
    SafetyAlert alert,
  ) async {
    try {
      String? locationDescription;

      if (alert.location != null) {
        locationDescription = alert.location!.address ??
            alert.location!.placeName ??
            '${alert.location!.latitude.toStringAsFixed(4)}, '
                '${alert.location!.longitude.toStringAsFixed(4)}';
      }

      await _notificationService.showMissedCheckInAlert(
        checkInId: checkIn.id,
        lastKnownLocation: locationDescription,
      );
    } catch (e) {
      // Ignore notification errors
    }
  }

  /// Builds a Google Maps URL for the given coordinates
  String _buildMapsUrl(double latitude, double longitude) {
    return 'https://www.google.com/maps?q=$latitude,$longitude';
  }

  /// Updates the detector status
  void _updateStatus(MissedCheckInDetectorStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(_status);
    }
  }

  @override
  void dispose() {
    // Emit the final `stopped` transition BEFORE closing — the previous order
    // added an event to an already-closed controller (throws "Cannot add event
    // after closing") whenever the detector had been active. See test.
    _updateStatus(MissedCheckInDetectorStatus.stopped);
    _statusController.close();
  }
}

/// Provider for MissedCheckInDetectorImpl
@riverpod
MissedCheckInDetector missedCheckInDetectorImpl(
  Ref ref,
) {
  final safetyRepository = ref.watch(safetyRepositoryProvider);
  final locationService = ref.watch(locationServiceImplProvider);
  final notificationService = ref.watch(notificationServiceImplProvider);

  final detector = MissedCheckInDetectorImpl(
    safetyRepository: safetyRepository,
    locationService: locationService,
    notificationService: notificationService,
  );

  // Initialize the detector
  detector.initialize();

  // Dispose when provider is disposed
  ref.onDispose(() => detector.dispose());

  return detector;
}

/// Provider override for MissedCheckInDetector interface
@riverpod
MissedCheckInDetector missedCheckInDetectorOverride(
  Ref ref,
) {
  return ref.watch(missedCheckInDetectorImplProvider);
}
