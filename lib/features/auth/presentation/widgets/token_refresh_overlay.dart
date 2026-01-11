import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/token_manager.dart';
import '../providers/auth_notifier_provider.dart';

/// A widget that displays token refresh status and handles user feedback
/// This overlay will show loading states, error messages, and handle re-authentication
/// when needed.
///
/// IMPORTANT: Overlays are only shown when the user IS authenticated.
/// This prevents showing session expired messages on the login screen.
class TokenRefreshOverlay extends ConsumerWidget {
  /// The child widget to display when tokens are valid
  final Widget child;

  /// Optional navigator key for navigation when overlay is outside MaterialApp
  final GlobalKey<NavigatorState>? navigatorKey;

  const TokenRefreshOverlay({
    super.key,
    required this.child,
    this.navigatorKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenState = ref.watch(tokenManagerProvider);
    final authAsync = ref.watch(authProvider);

    // Only show overlays if user is authenticated
    // This prevents showing session messages on the login screen
    final bool isAuthenticated = authAsync.value?.isAuthenticated ?? false;

    return Stack(
      // Use non-directional alignment since this widget may be outside MaterialApp
      alignment: Alignment.topLeft,
      textDirection: TextDirection.ltr,
      children: [
        child,
        // Show overlay based on token state, but only if authenticated
        if (isAuthenticated && tokenState == FeatureAvailability.tokenExpired)
          _buildTokenExpiredOverlay(context, ref),
        if (isAuthenticated && tokenState == FeatureAvailability.unauthorized)
          _buildUnauthorizedOverlay(context),
        if (tokenState == FeatureAvailability.offlineNoCache)
          _buildOfflineOverlay(context),
      ],
    );
  }

  Widget _buildTokenExpiredOverlay(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Session Expired',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your session has expired. Please wait while we refresh it.',
                  ),
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // Navigate to login screen using navigatorKey if available
                      if (navigatorKey?.currentState != null) {
                        navigatorKey!.currentState!.pushReplacementNamed('/login');
                      }
                    },
                    child: const Text('Sign in again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnauthorizedOverlay(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Session Ended',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your session has ended. Please sign in again to continue.',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to login screen using navigatorKey if available
                      if (navigatorKey?.currentState != null) {
                        navigatorKey!.currentState!.pushReplacementNamed('/login');
                      }
                    },
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineOverlay(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: Colors.black54,
        child: const Center(
          child: Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No Internet Connection',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Please check your internet connection and try again.',
                  ),
                  SizedBox(height: 16),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
