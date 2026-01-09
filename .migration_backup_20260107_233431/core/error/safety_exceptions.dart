import '../errors/exceptions.dart' as core;

/// Base exception class for safety feature specific exceptions
class SafetyException extends core.AppException {
  const SafetyException({
    required super.message,
    super.code,  // Optional to match base class AppException
  });
}

/// Trusted Contact Exceptions

/// Exception thrown when a trusted contact is not found
class TrustedContactNotFoundException extends SafetyException {
  const TrustedContactNotFoundException({super.message = 'Trusted contact not found'})
      : super(code: 'trusted_contact_not_found');
}

/// Exception thrown when attempting to add a trusted contact that already exists
class TrustedContactAlreadyExistsException extends SafetyException {
  const TrustedContactAlreadyExistsException({super.message = 'Trusted contact already exists'})
      : super(code: 'trusted_contact_already_exists');
}

/// Exception thrown when trusted contact information is invalid
class InvalidContactInformationException extends SafetyException {
  const InvalidContactInformationException({super.message = 'Invalid contact information provided'})
      : super(code: 'invalid_contact_information');
}

/// Exception thrown when the maximum number of trusted contacts has been reached
class TrustedContactLimitExceededException extends SafetyException {
  const TrustedContactLimitExceededException({super.message = 'Maximum number of trusted contacts reached'})
      : super(code: 'trusted_contact_limit_exceeded');
}

/// Exception thrown when a contact has no notification methods configured
class NoNotificationMethodException extends SafetyException {
  const NoNotificationMethodException({super.message = 'Contact has no notification method configured'})
      : super(code: 'no_notification_method');
}

/// Check-in Exceptions

/// Exception thrown when a check-in is not found
class CheckInNotFoundException extends SafetyException {
  const CheckInNotFoundException({super.message = 'Check-in not found'})
      : super(code: 'check_in_not_found');
}

/// Exception thrown when attempting to complete an already completed check-in
class CheckInAlreadyCompletedException extends SafetyException {
  const CheckInAlreadyCompletedException({super.message = 'Check-in has already been completed'})
      : super(code: 'check_in_already_completed');
}

/// Exception thrown when a check-in is overdue
class CheckInOverdueException extends SafetyException {
  final DateTime overdueSince;

  const CheckInOverdueException(
    this.overdueSince, {
    super.message = 'Check-in is overdue',
  }) : super(code: 'check_in_overdue');

  @override
  String toString() =>
      'CheckInOverdueException: $message (Code: $code, Overdue since: $overdueSince)';
}

/// Exception thrown when check-in schedule parameters are invalid
class InvalidCheckInScheduleException extends SafetyException {
  const InvalidCheckInScheduleException({super.message = 'Invalid check-in schedule parameters'})
      : super(code: 'invalid_check_in_schedule');
}

/// Exception thrown when check-in creation fails
class CheckInCreationFailedException extends SafetyException {
  const CheckInCreationFailedException({super.message = 'Failed to create check-in'})
      : super(code: 'check_in_creation_failed');
}

/// Exception thrown when attempting to cancel a check-in that cannot be canceled
class CheckInCannotBeCanceledException extends SafetyException {
  const CheckInCannotBeCanceledException({super.message = 'Check-in cannot be canceled'})
      : super(code: 'check_in_cannot_be_canceled');
}

/// Location Sharing Exceptions

/// Exception thrown when location services are unavailable
class LocationServiceUnavailableException extends SafetyException {
  const LocationServiceUnavailableException({super.message = 'Location services are unavailable'})
      : super(code: 'location_service_unavailable');
}

/// Exception thrown when location permissions are denied
class LocationPermissionDeniedException extends SafetyException {
  final bool permanent;

  const LocationPermissionDeniedException({
    super.message = 'Location permission denied',
    this.permanent = false,
  }) : super(code: 'location_permission_denied');

  @override
  String toString() =>
      'LocationPermissionDeniedException: $message (Code: $code, Permanent: $permanent)';
}

/// Exception thrown when location data is invalid or missing
class InvalidLocationDataException extends SafetyException {
  const InvalidLocationDataException({super.message = 'Invalid location data provided'})
      : super(code: 'invalid_location_data');
}

/// Exception thrown when attempting to stop location sharing that is not active
class LocationSharingNotActiveException extends SafetyException {
  const LocationSharingNotActiveException({super.message = 'Location sharing is not active'})
      : super(code: 'location_sharing_not_active');
}

/// Exception thrown when location sharing cannot be started
class LocationSharingFailedException extends SafetyException {
  const LocationSharingFailedException({super.message = 'Failed to start location sharing'})
      : super(code: 'location_sharing_failed');
}

/// Exception thrown when location update fails
class LocationUpdateFailedException extends SafetyException {
  const LocationUpdateFailedException({super.message = 'Failed to update location'})
      : super(code: 'location_update_failed');
}

/// Emergency SOS Exceptions

/// Exception thrown when an emergency SOS is already active
class EmergencySOSAlreadyActiveException extends SafetyException {
  const EmergencySOSAlreadyActiveException({super.message = 'Emergency SOS is already active'})
      : super(code: 'emergency_sos_already_active');
}

/// Exception thrown when triggering emergency SOS fails
class EmergencySOSTriggerFailedException extends SafetyException {
  const EmergencySOSTriggerFailedException({super.message = 'Failed to trigger emergency SOS'})
      : super(code: 'emergency_sos_trigger_failed');
}

/// Exception thrown when no trusted contacts are configured for SOS
class NoTrustedContactsConfiguredException extends SafetyException {
  const NoTrustedContactsConfiguredException({super.message = 'No trusted contacts configured for emergency alerts'})
      : super(code: 'no_trusted_contacts_configured');
}

/// Safety Alert Exceptions

/// Exception thrown when a safety alert is not found
class SafetyAlertNotFoundException extends SafetyException {
  const SafetyAlertNotFoundException({super.message = 'Safety alert not found'})
      : super(code: 'safety_alert_not_found');
}

/// Exception thrown when attempting to acknowledge an already acknowledged alert
class SafetyAlertAlreadyAcknowledgedException extends SafetyException {
  const SafetyAlertAlreadyAcknowledgedException({super.message = 'Safety alert has already been acknowledged'})
      : super(code: 'safety_alert_already_acknowledged');
}

/// Exception thrown when attempting to resolve an already resolved alert
class SafetyAlertAlreadyResolvedException extends SafetyException {
  const SafetyAlertAlreadyResolvedException({super.message = 'Safety alert has already been resolved'})
      : super(code: 'safety_alert_already_resolved');
}

/// Exception thrown when alert creation fails
class SafetyAlertCreationFailedException extends SafetyException {
  const SafetyAlertCreationFailedException({super.message = 'Failed to create safety alert'})
      : super(code: 'safety_alert_creation_failed');
}

/// Background Task & Notification Exceptions

/// Exception thrown when notification permissions are denied
class NotificationPermissionDeniedException extends SafetyException {
  const NotificationPermissionDeniedException({super.message = 'Notification permission denied'})
      : super(code: 'notification_permission_denied');
}

/// Exception thrown when scheduling a notification fails
class NotificationSchedulingFailedException extends SafetyException {
  const NotificationSchedulingFailedException({super.message = 'Failed to schedule notification'})
      : super(code: 'notification_scheduling_failed');
}

/// Exception thrown when background task registration fails
class BackgroundTaskRegistrationFailedException extends SafetyException {
  const BackgroundTaskRegistrationFailedException({super.message = 'Failed to register background task'})
      : super(code: 'background_task_registration_failed');
}

/// Exception thrown when background task initialization fails
class BackgroundTaskInitializationFailedException extends SafetyException {
  const BackgroundTaskInitializationFailedException({super.message = 'Failed to initialize background task'})
      : super(code: 'background_task_initialization_failed');
}

/// Exception thrown when missed check-in detection fails
class MissedCheckInDetectionFailedException extends SafetyException {
  const MissedCheckInDetectionFailedException({super.message = 'Failed to detect missed check-in'})
      : super(code: 'missed_check_in_detection_failed');
}

/// Battery & Power Related Exceptions

/// Exception thrown when battery level is critically low
class BatteryCriticallyLowException extends SafetyException {
  final int batteryLevel;

  const BatteryCriticallyLowException(
    this.batteryLevel, {
    super.message = 'Battery level is critically low',
  }) : super(code: 'battery_critically_low');

  @override
  String toString() =>
      'BatteryCriticallyLowException: $message (Code: $code, Battery level: $batteryLevel%)';
}

/// Exception thrown when battery monitoring is unavailable
class BatteryMonitoringUnavailableException extends SafetyException {
  const BatteryMonitoringUnavailableException({super.message = 'Battery monitoring is unavailable on this device'})
      : super(code: 'battery_monitoring_unavailable');
}

/// Settings & Configuration Exceptions

/// Exception thrown when safety settings are invalid
class InvalidSafetySettingsException extends SafetyException {
  const InvalidSafetySettingsException({super.message = 'Invalid safety settings'})
      : super(code: 'invalid_safety_settings');
}

/// Exception thrown when safety settings cannot be saved
class SafetySettingsSaveFailedException extends SafetyException {
  const SafetySettingsSaveFailedException({super.message = 'Failed to save safety settings'})
      : super(code: 'safety_settings_save_failed');
}

/// Exception thrown when safety settings cannot be loaded
class SafetySettingsLoadFailedException extends SafetyException {
  const SafetySettingsLoadFailedException({super.message = 'Failed to load safety settings'})
      : super(code: 'safety_settings_load_failed');
}

/// Cache & Storage Exceptions (Safety-specific)

/// Exception thrown when safety data cannot be cached
class SafetyCacheException extends SafetyException {
  const SafetyCacheException({super.message = 'Failed to cache safety data'})
      : super(code: 'safety_cache_error');
}

/// Exception thrown when safety data cannot be retrieved from cache
class SafetyCacheRetrievalException extends SafetyException {
  const SafetyCacheRetrievalException({super.message = 'Failed to retrieve safety data from cache'})
      : super(code: 'safety_cache_retrieval_error');
}

/// Network & Sync Exceptions (Safety-specific)

/// Exception thrown when safety data synchronization fails
class SafetySyncFailedException extends SafetyException {
  const SafetySyncFailedException({super.message = 'Failed to synchronize safety data'})
      : super(code: 'safety_sync_failed');
}

/// Exception thrown when offline mode prevents safety operations
class SafetyOfflineException extends SafetyException {
  const SafetyOfflineException({super.message = 'Cannot perform safety operation while offline'})
      : super(code: 'safety_offline');
}
