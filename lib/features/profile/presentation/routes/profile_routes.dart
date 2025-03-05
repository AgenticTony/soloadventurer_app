import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';
import '../screens/edit_profile_screen.dart';

/// Profile route names
class ProfileRoutes {
  static const profile = '/profile';
  static const editProfile = '/profile/edit';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case profile:
        return MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
          settings: settings,
        );
      case editProfile:
        final isInitialSetup = settings.arguments as bool? ?? false;
        return MaterialPageRoute(
          builder: (context) =>
              EditProfileScreen(isInitialSetup: isInitialSetup),
          settings: settings,
        );
      default:
        return null;
    }
  }

  static void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, profile);
  }

  static void navigateToEditProfile(BuildContext context,
      {bool isInitialSetup = false}) {
    Navigator.pushNamed(context, editProfile, arguments: isInitialSetup);
  }

  static void popToProfile(BuildContext context) {
    Navigator.popUntil(
      context,
      (route) => route.settings.name == profile || route.isFirst,
    );
  }
}
