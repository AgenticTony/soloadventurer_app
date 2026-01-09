import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_navigation_provider.dart';
import 'package:soloadventurer/features/auth/presentation/routes/auth_routes.dart';

/// Screen displayed when the user's session has expired
///
/// This screen provides clear feedback about session expiration
/// and offers options to re-authenticate.
class SessionExpiredScreen extends ConsumerWidget {
  /// Optional custom message to display
  final String? customMessage;

  /// Creates a new [SessionExpiredScreen]
  const SessionExpiredScreen({
    super.key,
    this.customMessage,
  });

  /// Route name for navigation
  static const routeName = '/auth/session-expired';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Error icon
                Icon(
                  Icons.lock_clock,
                  size: 80,
                  color: theme.colorScheme.error,
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  'Session Expired',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 16),

                // Message
                Text(
                  customMessage ??
                      'Your session has expired. Please sign in again to continue.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 48),

                // Illustration card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lock_clock,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'For your security, we automatically sign you out after a period of inactivity.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Sign in button
                ElevatedButton(
                  onPressed: () => _navigateToLogin(context, ref),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Sign In Again',
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 16),

                // Cancel button (go back to home)
                TextButton(
                  onPressed: () => _navigateToHome(context, ref),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context, WidgetRef ref) {
    ref
        .read(authNavigationProvider.notifier)
        .navigateTo(AuthRoutes.login);
  }

  void _navigateToHome(BuildContext context, WidgetRef ref) {
    ref
        .read(authNavigationProvider.notifier)
        .navigateTo(AuthRoutes.home);
  }
}
