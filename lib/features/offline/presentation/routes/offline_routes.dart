import 'package:flutter/material.dart';
import '../screens/sync_settings_screen.dart';

/// Offline feature route names
class OfflineRoutes {
  static const syncSettings = '/settings/sync';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    Widget screen;
    switch (settings.name) {
      case syncSettings:
        screen = const SyncSettingsScreen();
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
