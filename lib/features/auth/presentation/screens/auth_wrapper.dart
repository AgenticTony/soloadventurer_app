import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/domain/providers/auth_providers.dart';
import 'package:soloadventurer/features/auth/domain/state/auth_state.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_navigation_provider.dart';
import 'package:soloadventurer/features/auth/presentation/widgets/navigation_error_handler.dart';
import 'package:soloadventurer/features/profile/presentation/providers/profile_providers.dart';

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
    final authState = ref.watch(authStateProvider);
    final isLoading = ref.watch(isLoadingProvider);

    debugPrint('AuthWrapper build - authState: $authState');

    // Show loading indicator while initializing
    return NavigationErrorHandler(
      child: isLoading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : authState.isLoading
              ? const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : authState.error != null
                  ? Scaffold(
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: ${authState.error}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(authNotifierProvider.notifier)
                                    .signOut();
                              },
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _buildAuthenticatedContent(authState),
    );
  }

  Widget _buildAuthenticatedContent(AuthState state) {
    // Handle password reset flow
    if (state.requiresPasswordReset) {
      debugPrint('AuthWrapper: User requires password reset');
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show login screen if not authenticated
    if (!state.isLoggedIn) {
      debugPrint('AuthWrapper: User not authenticated, navigating to login');
      _hasInitializedProfile = false;
      // Use navigation provider for consistent navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(authNavigationProvider.notifier).navigateToLogin();
        }
      });
      // Show loading until navigation is handled
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If authenticated and has user, show home screen
    if (state.user != null) {
      debugPrint(
          'AuthWrapper: User authenticated, showing HomeScreen or EditProfileScreen');
      final userId = state.user!.id;

      // Initialize profile loading only once after authentication
      if (!_hasInitializedProfile) {
        _hasInitializedProfile = true;
        // Schedule profile loading for the next frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(profileUIProvider(userId).notifier).loadProfile();
          }
        });
      }

      // Use navigation provider for consistent navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(authNavigationProvider.notifier).navigateToHome();
        }
      });
      // Show loading until navigation is handled
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Fallback loading state
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
