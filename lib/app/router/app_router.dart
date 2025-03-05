import 'package:flutter/material.dart';
import 'package:soloadventurer/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:soloadventurer/features/auth/presentation/screens/login_screen.dart';
import 'package:soloadventurer/features/auth/presentation/screens/signup_screen.dart';
import 'package:soloadventurer/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:soloadventurer/features/home/presentation/screens/home_screen.dart';
import 'package:soloadventurer/features/profile/presentation/routes/profile_routes.dart';

/// App router for handling navigation
class AppRouter {
  /// Generate routes for the app
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // First check if it's a profile route
    if (settings.name?.startsWith('/profile') == true) {
      return ProfileRoutes.onGenerateRoute(settings);
    }

    // Handle other routes
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (context) => const AuthWrapper(),
          settings: settings,
        );
      case '/login':
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
          settings: settings,
        );
      case '/signup':
        return MaterialPageRoute(
          builder: (context) => const SignUpScreen(),
          settings: settings,
        );
      case '/verify-email':
        return MaterialPageRoute(
          builder: (context) => const VerifyEmailScreen(),
          settings: settings,
        );
      case '/home':
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
