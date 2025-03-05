import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_provider.dart';
import 'package:soloadventurer/features/auth/presentation/screens/login_screen.dart';
import 'package:soloadventurer/features/home/presentation/screens/home_screen.dart';
import 'package:soloadventurer/features/profile/presentation/providers/profile_providers.dart';
import 'package:soloadventurer/features/profile/presentation/screens/edit_profile_screen.dart';

/// A widget that wraps the app and handles authentication state
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
    final initializationState = ref.watch(authInitProvider);
    final authState = ref.watch(authProvider);

    debugPrint('AuthWrapper build - authState: $authState');
    debugPrint(
        'AuthWrapper build - isAuthenticated: ${authState.isAuthenticated}');
    debugPrint('AuthWrapper build - isLoading: ${authState.isLoading}');
    debugPrint('AuthWrapper build - error: ${authState.error}');

    // Show loading indicator while initializing
    return initializationState.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
      data: (_) {
        // Show loading indicator while checking auth state
        if (authState.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show error if there is one
        if (authState.error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${authState.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(authProvider.notifier).clearError();
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        // Show login screen if not authenticated
        if (!authState.isAuthenticated) {
          debugPrint(
              'AuthWrapper: User not authenticated, showing LoginScreen');
          _hasInitializedProfile = false;
          return const LoginScreen();
        }

        // If authenticated and has user, show home screen
        if (authState.user != null) {
          debugPrint(
              'AuthWrapper: User authenticated, showing HomeScreen or EditProfileScreen');
          final userId = authState.user!.id;

          // Initialize profile loading only once after authentication
          if (!_hasInitializedProfile) {
            _hasInitializedProfile = true;
            // Schedule profile loading for the next frame
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ref.read(profileUIProvider(userId).notifier).loadProfile();
              }
            });
            // If this is a new user (just registered), show the edit profile screen
            if (authState.isNewUser) {
              return const EditProfileScreen(isInitialSetup: true);
            }
          }

          return const HomeScreen();
        }

        // Fallback loading state
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
