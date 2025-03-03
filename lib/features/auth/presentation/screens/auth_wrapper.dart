import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_provider.dart';
import 'package:soloadventurer/features/auth/presentation/screens/login_screen.dart';
import 'package:soloadventurer/features/home/presentation/screens/home_screen.dart';

/// A widget that wraps the app and handles authentication state
class AuthWrapper extends ConsumerWidget {
  /// Creates a new [AuthWrapper]
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    debugPrint('AuthWrapper build - authState: $authState');
    debugPrint(
        'AuthWrapper build - isAuthenticated: ${authState.isAuthenticated}');
    debugPrint('AuthWrapper build - isLoading: ${authState.isLoading}');
    debugPrint('AuthWrapper build - error: ${authState.error}');

    // Show loading indicator while checking auth state
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show login screen if not authenticated
    if (!authState.isAuthenticated) {
      return const LoginScreen();
    }

    // Navigate to home screen if authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed('/home');
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
