import '../errors/exceptions.dart' as core;

/// Base exception class for safety feature specific exceptions
class SafetyException extends core.AppException {
  const SafetyException(super.message, {required super.code});
}

/// Trusted Contact Exceptions

/// Exception thrown when a trusted contact is not found
class TrustedContactNotFoundException extends SafetyException {
  const TrustedContactNotFoundException([
    String message = 'Trusted contact not found',
  ]) : super(message, code: 'trusted_contact_not_found');
}

/// Exception thrown when attempting to add a trusted contact that already exists
class TrustedContactAlreadyExistsException extends SafetyException {
  const TrustedContactAlreadyExistsException([
    String message = 'Trusted contact already exists',
  ]) : super(message, code: 'trusted_contact_already_exists');
}

/// Exception thrown when trusted contact information is invalid
class InvalidContactInformationException extends SafetyException {
  const InvalidContactInformationException([
    String message = 'Invalid contact information provided',
  ]) : super(message, code: 'invalid_contact_information');
}

/// Exception thrown when the maximum number of trusted contacts has been reached
class TrustedContactLimitExceededException extends SafetyException {
  const TrustedContactLimitExceededException([
    String message = 'Maximum number of trusted contacts reached',
  ]) : super(message, code: 'trusted_contact_limit_exceeded');
}

/// Exception thrown when a contact has no notification methods configured
class NoNotificationMethodException extends SafetyException {
  const NoNotificationMethodException([
    String message = 'Contact has no notification method configured',
  ]) : super(message, code: 'no_notification_method');
}

/// Check-in Exceptions

/// Exception thrown when a check-in is not found
class CheckInNotFoundException extends SafetyException {
  const CheckInNotFoundException([
    String message = 'Check-in not found',
  ]) : super(message, code: 'check_in_not_found');
}

/// Exception thrown when attempting to complete an already completed check-in
class CheckInAlreadyCompletedException extends SafetyException {
  const CheckInAlreadyCompletedException([
    String message = 'Check-in has already been completed',
  ]) : super(message, code: 'check_in_already_completed');
}

/// Exception thrown when a check-in is overdue
class CheckInOverdueException extends SafetyException {
  final DateTime overdueSince;

  const CheckInOverdueException(
    this.overdueSince, [
    String message = 'Check-in is overdue',
  ]) : super(message, code: 'check_in_overdue');

  @override
  String toString() =>
      'CheckInOverdueException: $message (Code: $code, Overdue since: $overdueSince)';
}

/// Exception thrown when check-in schedule parameters are invalid
class InvalidCheckInScheduleException extends SafetyException {
  const InvalidCheckInScheduleException([
    String message = 'Invalid check-in schedule parameters',
  ]) : super(message, code: 'invalid_check_in_schedule');
}

/// Exception thrown when check-in creation fails
class CheckInCreationFailedException extends SafetyException {
  const CheckInCreationFailedException([
    String message = 'Failed to create check-in',
  ]) : super(message, code: 'check_in_creation_failed');
}

/// Exception thrown when attempting to cancel a check-in that cannot be canceled
class CheckInCannotBeCanceledException extends SafetyException {
  const CheckInCannotBeCanceledException([
    String message = 'Check-in cannot be canceled',
  ]) : super(message, code: 'check_in_cannot_be_canceled');
}

/// Location Sharing Exceptions

/// Exception thrown when location services are unavailable
class LocationServiceUnavailableException extends SafetyException {
  const LocationServiceUnavailableException([
    String message = 'Location services are unavailable',
  ]) : super(message, code: 'location_service_unavailable');
}

/// Exception thrown when location permissions are denied
class LocationPermissionDeniedException extends SafetyException {
  final bool permanent;

  const LocationPermissionDeniedException([
    String message = 'Location permission denied',
    this.permanent = false,
  ]) : super(message, code: 'location_permission_denied');

  @override
  String toString() =>
      'LocationPermissionDeniedException: $message (Code: $code, Permanent: $permanent)';
}

/// Exception thrown when location data is invalid or missing
class InvalidLocationDataException extends SafetyException {
  const InvalidLocationDataException([
    String message = 'Invalid location data provided',
  ]) : super(message, code: 'invalid_location_data');
}

/// Exception thrown when attempting to stop location sharing that is not active
class LocationSharingNotActiveException extends SafetyException {
  const LocationSharingNotActiveException([
    String message = 'Location sharing is not active',
  ]) : super(message, code: 'location_sharing_not_active');
}

/// Exception thrown when location sharing cannot be started
class LocationSharingFailedException extends SafetyException {
  const LocationSharingFailedException([
    String message = 'Failed to start location sharing',
  ]) : super(message, code: 'location_sharing_failed');
}

/// Exception thrown when location update fails
class LocationUpdateFailedException extends SafetyException {
  const LocationUpdateFailedException([
    String message = 'Failed to update location',
  ]) : super(message, code: 'location_update_failed');
}

/// Emergency SOS Exceptions

/// Exception thrown when an emergency SOS is already active
class EmergencySOSAlreadyActiveException extends SafetyException {
  const EmergencySOSAlreadyActiveException([
    String message = 'Emergency SOS is already active',
  ]) : super(message, code: 'emergency_sos_already_active');
}

/// Exception thrown when triggering emergency SOS fails
class EmergencySOSTriggerFailedException extends SafetyException {
  const EmergencySOSTriggerFailedException([
    String message = 'Failed to trigger emergency SOS',
  ]) : super(message, code: 'emergency_sos_trigger_failed');
}

/// Exception thrown when no trusted contacts are configured for SOS
class NoTrustedContactsConfiguredException extends SafetyException {
  const NoTrustedContactsConfiguredException([
    String message = 'No trusted contacts configured for emergency alerts',
  ]) : super(message, code: 'no_trusted_contacts_configured');
}

/// Safety Alert Exceptions

/// Exception thrown when a safety alert is not found
class SafetyAlertNotFoundException extends SafetyException {
  const SafetyAlertNotFoundException([
    String message = 'Safety alert not found',
  ]) : super(message, code: 'safety_alert_not_found');
}

/// Exception thrown when attempting to acknowledge an already acknowledged alert
class SafetyAlertAlreadyAcknowledgedException extends SafetyException {
  const SafetyAlertAlreadyAcknowledgedException([
    String message = 'Safety alert has already been acknowledged',
  ]) : super(message, code: 'safety_alert_already_acknowledged');
}

/// Exception thrown when attempting to resolve an already resolved alert
class SafetyAlertAlreadyResolvedException extends SafetyException {
  const SafetyAlertAlreadyResolvedException([
    String message = 'Safety alert has already been resolved',
  ]) : super(message, code: 'safety_alert_already_resolved');
}

/// Exception thrown when alert creation fails
class SafetyAlertCreationFailedException extends SafetyException {
  const SafetyAlertCreationFailedException([
    String message = 'Failed to create safety alert',
  ]) : super(message, code: 'safety_alert_creation_failed');
}

/// Background Task & Notification Exceptions

/// Exception thrown when notification permissions are denied
class NotificationPermissionDeniedException extends SafetyException {
  const NotificationPermissionDeniedException([
    String message = 'Notification permission denied',
  ]) : super(message, code: 'notification_permission_denied');
}

/// Exception thrown when scheduling a notification fails
class NotificationSchedulingFailedException extends SafetyException {
  const NotificationSchedulingFailedException([
    String message = 'Failed to schedule notification',
  ]) : super(message, code: 'notification_scheduling_failed');
}

/// Exception thrown when background task registration fails
class BackgroundTaskRegistrationFailedException extends SafetyException {
  const BackgroundTaskRegistrationFailedException([
    String message = 'Failed to register background task',
  ]) : super(message, code: 'background_task_registration_failed');
}

/// Exception thrown when background task initialization fails
class BackgroundTaskInitializationFailedException extends SafetyException {
  const BackgroundTaskInitializationFailedException([
    String message = 'Failed to initialize background task',
  ]) : super(message, code: 'background_task_initialization_failed');
}

/// Exception thrown when missed check-in detection fails
class MissedCheckInDetectionFailedException extends SafetyException {
  const MissedCheckInDetectionFailedException([
    String message = 'Failed to detect missed check-in',
  ]) : super(message, code: 'missed_check_in_detection_failed');
}

/// Battery & Power Related Exceptions

/// Exception thrown when battery level is critically low
class BatteryCriticallyLowException extends SafetyException {
  final int batteryLevel;

  const BatteryCriticallyLowException(
    this.batteryLevel, [
    String message = 'Battery level is critically low',
  ]) : super(message, code: 'battery_critically_low');

  @override
  String toString() =>
      'BatteryCriticallyLowException: $message (Code: $code, Battery level: $batteryLevel%)';
}

/// Exception thrown when battery monitoring is unavailable
class BatteryMonitoringUnavailableException extends SafetyException {
  const BatteryMonitoringUnavailableException([
    String message = 'Battery monitoring is unavailable on this device',
  ]) : super(message, code: 'battery_monitoring_unavailable');
}

/// Settings & Configuration Exceptions

/// Exception thrown when safety settings are invalid
class InvalidSafetySettingsException extends SafetyException {
  const InvalidSafetySettingsException([
    String message = 'Invalid safety settings',
  ]) : super(message, code: 'invalid_safety_settings');
}

/// Exception thrown when safety settings cannot be saved
class SafetySettingsSaveFailedException extends SafetyException {
  const SafetySettingsSaveFailedException([
    String message = 'Failed to save safety settings',
  ]) : super(message, code: 'safety_settings_save_failed');
}

/// Exception thrown when safety settings cannot be loaded
class SafetySettingsLoadFailedException extends SafetyException {
  const SafetySettingsLoadFailedException([
    String message = 'Failed to load safety settings',
  ]) : super(message, code: 'safety_settings_load_failed');
}

/// Cache & Storage Exceptions (Safety-specific)

/// Exception thrown when safety data cannot be cached
class SafetyCacheException extends SafetyException {
  const SafetyCacheException([
    String message = 'Failed to cache safety data',
  ]) : super(message, code: 'safety_cache_error');
}

/// Exception thrown when safety data cannot be retrieved from cache
class SafetyCacheRetrievalException extends SafetyException {
  const SafetyCacheRetrievalException([
    String message = 'Failed to retrieve safety data from cache',
  ]) : super(message, code: 'safety_cache_retrieval_error');
}

/// Network & Sync Exceptions (Safety-specific)

/// Exception thrown when safety data synchronization fails
class SafetySyncFailedException extends SafetyException {
  const SafetySyncFailedException([
    String message = 'Failed to synchronize safety data',
  ]) : super(message, code: 'safety_sync_failed');
}

/// Exception thrown when offline mode prevents safety operations
class SafetyOfflineException extends SafetyException {
  const SafetyOfflineException([
    String message = 'Cannot perform safety operation while offline',
  ]) : super(message, code: 'safety_offline');
}
