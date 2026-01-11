import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier_provider.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';
import 'package:soloadventurer/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:soloadventurer/features/auth/presentation/screens/login_screen.dart';
import 'package:soloadventurer/features/home/presentation/screens/home_screen.dart';
import 'package:soloadventurer/features/profile/presentation/providers/profile_providers.dart';

/// A widget that wraps the app and handles authentication state
/// by directly rendering the appropriate screen based on auth state.
class AuthWrapper extends ConsumerStatefulWidget {
  /// Creates a new [AuthWrapper]
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _hasInitializedProfile = false;

  @override
  Widget build(BuildContext context) {
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

        // Handle password reset flow
        if (authState.requiresPasswordReset) {
          debugPrint('AuthWrapper: User requires password reset');
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
          _hasInitializedProfile = false;
          return const VerifyEmailScreen();
        }

        // Only show home screen if user is logged in and verified
        if (authState.isLoggedIn && !authState.requiresEmailVerification) {
          debugPrint(
              'AuthWrapper: User authenticated and verified, showing HomeScreen');
          final userId = authState.user!.id;

          // Initialize profile loading only once after authentication
          if (!_hasInitializedProfile) {
            _hasInitializedProfile = true;
            // Schedule profile loading for the next frame
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ref.read(profileDomainProvider(userId).notifier).loadProfile();
              }
            });
          }

          return const HomeScreen();
        }

        // Show login screen if not in verification state and not logged in
        debugPrint(
            'AuthWrapper: No special conditions met, showing login screen');
        _hasInitializedProfile = false;
        return const LoginScreen();
      },
    );
  }
}
