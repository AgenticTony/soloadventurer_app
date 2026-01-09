import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_navigation_provider.dart';
import 'package:soloadventurer/features/auth/presentation/routes/auth_routes.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/auth_error_handler.dart';

/// Screen displayed when authentication credentials are invalid
///
/// This screen provides clear feedback about credential errors
/// and offers options to try again or reset password.
class CredentialsErrorScreen extends ConsumerWidget {
  /// Error information from AuthErrorHandler
  final AuthErrorInfo errorInfo;

  /// Optional custom message to display
  final String? customMessage;

  /// Callback when user chooses to try again
  final VoidCallback? onTryAgain;

  /// Creates a new [CredentialsErrorScreen]
  const CredentialsErrorScreen({
    super.key,
    required this.errorInfo,
    this.customMessage,
    this.onTryAgain,
  });

  /// Route name for navigation
  static const routeName = '/auth/credentials-error';

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
                  Icons.lock_person,
                  size: 80,
                  color: theme.colorScheme.error,
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  'Authentication Failed',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 16),

                // Error message
                Text(
                  customMessage ?? errorInfo.userMessage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 32),

                // Recovery guidance card
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'What to do',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        errorInfo.recovery.primaryAction,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (errorInfo.recovery.secondaryAction != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          errorInfo.recovery.secondaryAction!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Try again button
                ElevatedButton(
                  onPressed: () => _handleTryAgain(context, ref),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 16),

                // Forgot password button
                OutlinedButton.icon(
                  onPressed: () => _navigateToForgotPassword(context, ref),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.lock_reset),
                  label: const Text(
                    'Forgot Password?',
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 16),

                // Sign up link (for user not found scenario)
                if (errorInfo.errorCode == 'USER_NOT_FOUND')
                  TextButton.icon(
                    onPressed: () => _navigateToSignUp(context, ref),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Create an Account'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.secondary,
                    ),
                  ),

                const SizedBox(height: 16),

                // Back button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Go Back',
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Additional help section
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Common Issues',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Check that Caps Lock is not on\n'
                        '• Verify your email address is spelled correctly\n'
                        '• Ensure you\'re using the correct password for this account\n'
                        '• Reset your password if you\'ve forgotten it',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTryAgain(BuildContext context, WidgetRef ref) {
    // Pop this screen first
    Navigator.of(context).pop();
    // Then call the callback
    onTryAgain?.call();
  }

  void _navigateToForgotPassword(BuildContext context, WidgetRef ref) {
    ref
        .read(authNavigationProvider.notifier)
        .navigateTo(AuthRoutes.forgotPassword);
  }

  void _navigateToSignUp(BuildContext context, WidgetRef ref) {
    ref
        .read(authNavigationProvider.notifier)
        .navigateTo(AuthRoutes.signup);
  }
}
