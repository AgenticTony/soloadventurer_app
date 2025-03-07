import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/domain/providers/auth_providers.dart';
import 'package:soloadventurer/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:soloadventurer/features/auth/presentation/screens/login_screen.dart';
import 'package:soloadventurer/features/home/presentation/screens/home_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    debugPrint('AuthWrapper build - Full authState: $authState');
    debugPrint('AuthWrapper - isLoggedIn: ${authState.isLoggedIn}');
    debugPrint(
        'AuthWrapper - requiresEmailVerification: ${authState.requiresEmailVerification}');
    debugPrint('AuthWrapper - user: ${authState.user}');

    if (authState.isLoading) {
      debugPrint('AuthWrapper: Loading state detected');
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Email verification takes precedence over other states
    if (authState.requiresEmailVerification) {
      debugPrint(
          'AuthWrapper: Email verification required, showing verification screen');
      return const VerifyEmailScreen();
    }

    // Only show home screen if user is logged in and verified
    if (authState.isLoggedIn && !authState.requiresEmailVerification) {
      debugPrint(
          'AuthWrapper: User authenticated and verified, showing HomeScreen');
      return const HomeScreen();
    }

    // Show login screen if not in verification state and not logged in
    debugPrint('AuthWrapper: No special conditions met, showing login screen');
    return const LoginScreen();
  }
}
