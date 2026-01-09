/// Safety feature route names
class SafetyRoutes {
  // Safety Hub
  static const safetyHub = '/safety';

  // Trusted Contacts
  static const trustedContacts = '/safety/trusted-contacts';
  static const addEditTrustedContact = '/safety/trusted-contacts/add';
  static const editTrustedContact = '/safety/trusted-contacts/edit';

  // Check-ins
  static const checkInHome = '/safety/check-ins';
  static const manualCheckIn = '/safety/check-ins/manual';
  static const scheduleCheckIn = '/safety/check-ins/schedule';
  static const checkInHistory = '/safety/check-ins/history';

  // Emergency & SOS
  static const emergencySOS = '/safety/emergency';
  static const statusUpdate = '/safety/status-update';

  // Location Sharing
  static const locationSharing = '/safety/location-sharing';

  /// Private constructor to prevent instantiation
  const SafetyRoutes._();
}
