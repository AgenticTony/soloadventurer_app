import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/profile_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/profile_settings_screen.dart';
import '../providers/profile_providers.dart';
import '../../domain/entities/profile.dart';

class ProfileRoutes {
  // Route paths for deep linking
  static const String profilePath = '/profile';
  static const String editProfilePath = '/profile/edit';
  static const String settingsPath = '/profile/settings';
  static const String profileByIdPath = '/profile/:id';

  // Route names for navigation
  static const String profile = ProfileScreen.routeName;
  static const String editProfile = EditProfileScreen.routeName;
  static const String profileSettings = ProfileSettingsScreen.routeName;

  // URI patterns for deep linking
  static final profilePattern = Uri.parse(profilePath);
  static final editProfilePattern = Uri.parse(editProfilePath);
  static final settingsPattern = Uri.parse(settingsPath);
  static final profileByIdPattern = RegExp(r'^/profile/([^/]+)$');

  static Map<String, WidgetBuilder> routes = {
    profile: (context) => _guardRoute(const ProfileScreen()),
    editProfile: (context) => _guardRoute(const EditProfileScreen()),
    profileSettings: (context) => _guardRoute(const ProfileSettingsScreen()),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name?.startsWith('/profile') != true) return null;

    // Handle deep link paths
    final uri = Uri.parse(settings.name ?? '');
    final profileIdMatch = profileByIdPattern.firstMatch(uri.path);

    if (profileIdMatch != null) {
      final profileId = profileIdMatch.group(1);
      return MaterialPageRoute(
        builder: (context) => _guardRoute(
          ProfileScreen(profileId: profileId),
        ),
        settings: settings,
      );
    }

    switch (settings.name) {
      case editProfile:
        final profile = settings.arguments as Profile?;
        return MaterialPageRoute(
          builder: (context) => _guardRoute(const EditProfileScreen()),
          settings: settings,
        );
      default:
        return null;
    }
  }

  /// Guards a route to ensure profile is loaded
  static Widget _guardRoute(Widget child) {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(profileProvider);

        // If profile is not loaded, try to load it
        if (!state.isInitialized && !state.isLoading) {
          Future.microtask(
            () => ref.read(profileProvider.notifier).loadProfile(),
          );
        }

        return child;
      },
    );
  }

  /// Navigate to profile screen
  static void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, profile);
  }

  /// Navigate to a specific profile by ID
  static void navigateToProfileById(BuildContext context, String profileId) {
    Navigator.pushNamed(context, '/profile/$profileId');
  }

  /// Navigate to edit profile screen
  static void navigateToEditProfile(BuildContext context, {Profile? profile}) {
    Navigator.pushNamed(
      context,
      editProfile,
      arguments: profile,
    );
  }

  /// Navigate to profile settings screen
  static void navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, profileSettings);
  }

  /// Pop back to profile screen, clearing the stack
  static void popToProfile(BuildContext context) {
    Navigator.popUntil(
      context,
      (route) => route.settings.name == profile || route.isFirst,
    );
  }

  /// Replace current screen with profile screen
  static void replaceWithProfile(BuildContext context) {
    Navigator.pushReplacementNamed(context, profile);
  }

  /// Navigate to profile screen and remove all previous routes
  static void pushProfileAndRemoveUntil(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      profile,
      (route) => false,
    );
  }

  /// Check if current route is a profile route
  static bool isProfileRoute(String? routeName) {
    return routeName?.startsWith('/profile') == true;
  }

  /// Parse deep link URI
  static Map<String, String>? parseProfileDeepLink(Uri uri) {
    if (uri.path.startsWith(profilePath)) {
      final match = profileByIdPattern.firstMatch(uri.path);
      if (match != null) {
        return {'profileId': match.group(1)!};
      }
      return {};
    }
    return null;
  }
}
