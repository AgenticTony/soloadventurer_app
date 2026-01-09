import 'package:flutter/material.dart';
import '../screens/safety_hub_screen.dart';
import '../screens/trusted_contacts_screen.dart';
import '../screens/add_edit_trusted_contact_screen.dart';
import '../screens/check_in_home_screen.dart';
import '../screens/manual_check_in_screen.dart';
import '../screens/schedule_check_in_screen.dart';
import '../screens/check_in_history_screen.dart';
import '../screens/emergency_sos_screen.dart';
import '../screens/status_update_screen.dart';
import '../screens/location_sharing_screen.dart';

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

  /// Generate routes for safety feature
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    Widget screen;

    switch (settings.name) {
      // Safety Hub
      case safetyHub:
        screen = const SafetyHubScreen();
        break;

      // Trusted Contacts
      case trustedContacts:
        screen = const TrustedContactsScreen();
        break;

      case addEditTrustedContact:
        final args = settings.arguments as Map<String, dynamic>?;
        screen = AddEditTrustedContactScreen(
          contact: args?['contact'],
        );
        break;

      case editTrustedContact:
        final args = settings.arguments as Map<String, dynamic>?;
        screen = AddEditTrustedContactScreen(
          contact: args?['contact'],
        );
        break;

      // Check-ins
      case checkInHome:
        screen = const CheckInHomeScreen();
        break;

      case manualCheckIn:
        final args = settings.arguments as Map<String, dynamic>?;
        screen = ManualCheckInScreen(
          existingCheckIn: args?['checkIn'],
        );
        break;

      case scheduleCheckIn:
        final args = settings.arguments as Map<String, dynamic>?;
        screen = ScheduleCheckInScreen(
          tripId: args?['tripId'],
        );
        break;

      case checkInHistory:
        screen = const CheckInHistoryScreen();
        break;

      // Emergency & SOS
      case emergencySOS:
        screen = const EmergencySOSScreen();
        break;

      case statusUpdate:
        screen = const StatusUpdateScreen();
        break;

      // Location Sharing
      case locationSharing:
        screen = const LocationSharingScreen();
        break;

      default:
        return null;
    }

    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
