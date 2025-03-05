import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';
import '../screens/edit_profile_screen.dart';

/// Profile route names
class ProfileRoutes {
  static const profile = '/profile';
  static const editProfile = '/profile/edit';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    Widget screen;
    switch (settings.name) {
      case profile:
        screen = const ProfileScreen();
        break;
      case editProfile:
        final isInitialSetup = settings.arguments as bool? ?? false;
        screen = EditProfileScreen(isInitialSetup: isInitialSetup);
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
