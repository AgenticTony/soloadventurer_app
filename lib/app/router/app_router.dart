import 'package:flutter/material.dart';
import 'package:soloadventurer/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:soloadventurer/features/auth/presentation/screens/login_screen.dart';
import 'package:soloadventurer/features/auth/presentation/screens/signup_screen.dart';
import 'package:soloadventurer/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:soloadventurer/features/home/presentation/screens/home_screen.dart';
import 'package:soloadventurer/features/profile/presentation/routes/profile_routes.dart';
import 'package:soloadventurer/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:soloadventurer/features/auth/presentation/screens/confirm_password_reset_screen.dart';
import 'package:soloadventurer/features/profile/presentation/screens/profile_screen.dart';
import 'package:soloadventurer/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:soloadventurer/features/profile/presentation/screens/profile_settings_screen.dart';
import 'package:soloadventurer/features/auth/presentation/routes/auth_routes.dart';
import 'package:soloadventurer/features/auth/presentation/pages/cloudwatch_test_page.dart';
import 'package:soloadventurer/features/safety/presentation/routes/safety_routes.dart';

/// App router for handling navigation
class AppRouter {
  /// Generate routes for the app
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // First check if it's a safety route
    if (settings.name?.startsWith('/safety') == true) {
      final route = SafetyRoutes.onGenerateRoute(settings);
      if (route != null) {
        return route;
      }
    }

    // Then check if it's a profile route
    if (settings.name?.startsWith('/profile') == true) {
      final route = ProfileRoutes.onGenerateRoute(settings);
      if (route != null) {
        return route;
      }
    }

    // Handle other routes
    Widget screen;
    switch (settings.name) {
      case '/':
        screen = const AuthWrapper();
        break;
      case AuthRoutes.login:
        screen = const LoginScreen();
        break;
      case AuthRoutes.signup:
        screen = const SignUpScreen();
        break;
      case AuthRoutes.verifyEmail:
        screen = const VerifyEmailScreen();
        break;
      case AuthRoutes.forgotPassword:
        screen = const ForgotPasswordScreen();
        break;
      case AuthRoutes.confirmPasswordReset:
        screen = const ConfirmPasswordResetScreen();
        break;
      case AuthRoutes.home:
        screen = const HomeScreen();
        break;
      case AuthRoutes.profile:
        screen = const ProfileScreen();
        break;
      case AuthRoutes.cloudWatchTest:
        screen = const CloudWatchTestPage();
        break;
      case '/edit-profile':
        screen = const EditProfileScreen();
        break;
      case '/profile-settings':
        screen = const ProfileSettingsScreen();
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
