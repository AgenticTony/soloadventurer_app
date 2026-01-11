import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier_provider.dart';
import 'package:soloadventurer/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:soloadventurer/features/auth/presentation/screens/login_screen.dart';
import 'package:soloadventurer/features/home/presentation/screens/home_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authProvider);

    return authAsync.when(
      loading: () {
        debugPrint('AuthWrapper: Loading state detected');
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      error: (error, stack) {
        debugPrint('AuthWrapper: Error state - $error');
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(authProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
      data: (authState) {
        debugPrint('AuthWrapper build - Full authState: $authState');
        debugPrint('AuthWrapper - isLoggedIn: ${authState.isLoggedIn}');
        debugPrint(
            'AuthWrapper - requiresEmailVerification: ${authState.requiresEmailVerification}');
        debugPrint('AuthWrapper - user: ${authState.user}');

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
        debugPrint(
            'AuthWrapper: No special conditions met, showing login screen');
        return const LoginScreen();
      },
    );
  }
}
