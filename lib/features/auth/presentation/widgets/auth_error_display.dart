import 'package:flutter/material.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/auth_error_handler.dart';

/// A reusable widget for displaying authentication errors with recovery options
///
/// This widget provides:
/// - User-friendly error messages
/// - Actionable recovery steps
/// - Appropriate icons and colors based on error category
/// - Optional retry functionality
///
/// Example usage:
/// ```dart
/// AuthErrorDisplay(
///   error: exception,
///   onRetry: () => _retryLogin(),
///   onDismiss: () => _clearError(),
/// )
/// ```
class AuthErrorDisplay extends StatelessWidget {
  /// The error to display
  final Object error;

  /// Optional callback for retry action
  final VoidCallback? onRetry;

  /// Optional callback for dismiss action
  final VoidCallback? onDismiss;

  /// Optional custom retry button text
  final String? retryButtonText;

  /// Optional custom dismiss button text
  final String? dismissButtonText;

  /// Whether to show the dismiss button
  final bool showDismissButton;

  /// Whether to show the recovery actions
  final bool showRecoveryActions;

  const AuthErrorDisplay({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
    this.retryButtonText,
    this.dismissButtonText,
    this.showDismissButton = true,
    this.showRecoveryActions = true,
  });

  @override
  Widget build(BuildContext context) {
    const errorHandler = AuthErrorHandler();
    final errorInfo = errorHandler.handleError(error);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getErrorColor(context, errorInfo.category).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getErrorColor(context, errorInfo.category).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error header with icon
          Row(
            children: [
              Icon(
                _getErrorIcon(errorInfo.category),
                color: _getErrorColor(context, errorInfo.category),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getErrorTitle(errorInfo.category),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _getErrorColor(context, errorInfo.category),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (showDismissButton && onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Error message
          Text(
            errorInfo.userMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),

          // Recovery actions
          if (showRecoveryActions) ...[
            const SizedBox(height: 12),
            _buildRecoveryActions(context, errorInfo, theme),
          ],

          // Action buttons
          if (onRetry != null || onDismiss != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (onRetry != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _getErrorColor(context, errorInfo.category),
                      ),
                      child: Text(retryButtonText ?? 'Try Again'),
                    ),
                  ),
                if (onRetry != null && onDismiss != null)
                  const SizedBox(width: 12),
                if (onDismiss != null && !showDismissButton)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDismiss,
                      child: Text(dismissButtonText ?? 'Cancel'),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the recovery actions section
  Widget _buildRecoveryActions(
    BuildContext context,
    AuthErrorInfo errorInfo,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'What you can do:',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            errorInfo.recovery.primaryAction,
            style: theme.textTheme.bodySmall,
          ),
          if (errorInfo.recovery.secondaryAction != null) ...[
            const SizedBox(height: 4),
            Text(
              errorInfo.recovery.secondaryAction!,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  /// Gets the appropriate icon for an error category
  IconData _getErrorIcon(AuthErrorCategory category) {
    switch (category) {
      case AuthErrorCategory.network:
        return Icons.wifi_off;
      case AuthErrorCategory.credentials:
        return Icons.lock_outline;
      case AuthErrorCategory.expired:
        return Icons.schedule;
      case AuthErrorCategory.rateLimit:
        return Icons.timer_outlined;
      case AuthErrorCategory.server:
        return Icons.cloud_off;
      case AuthErrorCategory.validation:
        return Icons.error_outline;
      case AuthErrorCategory.unknown:
        return Icons.help_outline;
    }
  }

  /// Gets the appropriate color for an error category
  Color _getErrorColor(BuildContext context, AuthErrorCategory category) {
    final theme = Theme.of(context);

    switch (category) {
      case AuthErrorCategory.network:
        return Colors.orange;
      case AuthErrorCategory.credentials:
        return theme.colorScheme.error;
      case AuthErrorCategory.expired:
        return Colors.deepOrange;
      case AuthErrorCategory.rateLimit:
        return Colors.amber;
      case AuthErrorCategory.server:
        return Colors.purple;
      case AuthErrorCategory.validation:
        return theme.colorScheme.error;
      case AuthErrorCategory.unknown:
        return theme.colorScheme.onSurface;
    }
  }

  /// Gets the title for an error category
  String _getErrorTitle(AuthErrorCategory category) {
    switch (category) {
      case AuthErrorCategory.network:
        return 'Network Error';
      case AuthErrorCategory.credentials:
        return 'Authentication Failed';
      case AuthErrorCategory.expired:
        return 'Session Expired';
      case AuthErrorCategory.rateLimit:
        return 'Too Many Attempts';
      case AuthErrorCategory.server:
        return 'Server Error';
      case AuthErrorCategory.validation:
        return 'Invalid Input';
      case AuthErrorCategory.unknown:
        return 'Error';
    }
  }
}

/// A banner-style widget for displaying authentication errors at the top of screens
///
/// This is a more compact version suitable for displaying errors
/// at the top of auth screens without taking up too much space.
class AuthErrorBanner extends StatelessWidget {
  /// The error to display
  final Object error;

  /// Optional callback for dismiss action
  final VoidCallback? onDismiss;

  const AuthErrorBanner({
    super.key,
    required this.error,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    const errorHandler = AuthErrorHandler();
    final errorInfo = errorHandler.handleError(error);
    final theme = Theme.of(context);

    return Material(
      color: _getErrorColor(context, errorInfo.category).withOpacity(0.1),
      child: SafeArea(
        bottom: false,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getErrorColor(context, errorInfo.category).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  _getErrorColor(context, errorInfo.category).withOpacity(0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _getErrorIcon(errorInfo.category),
                color: _getErrorColor(context, errorInfo.category),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      errorInfo.userMessage,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (errorInfo.recovery.secondaryAction != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        errorInfo.recovery.secondaryAction!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Gets the appropriate icon for an error category
  IconData _getErrorIcon(AuthErrorCategory category) {
    switch (category) {
      case AuthErrorCategory.network:
        return Icons.wifi_off;
      case AuthErrorCategory.credentials:
        return Icons.lock_outline;
      case AuthErrorCategory.expired:
        return Icons.schedule;
      case AuthErrorCategory.rateLimit:
        return Icons.timer_outlined;
      case AuthErrorCategory.server:
        return Icons.cloud_off;
      case AuthErrorCategory.validation:
        return Icons.error_outline;
      case AuthErrorCategory.unknown:
        return Icons.help_outline;
    }
  }

  /// Gets the appropriate color for an error category
  Color _getErrorColor(BuildContext context, AuthErrorCategory category) {
    final theme = Theme.of(context);

    switch (category) {
      case AuthErrorCategory.network:
        return Colors.orange;
      case AuthErrorCategory.credentials:
        return theme.colorScheme.error;
      case AuthErrorCategory.expired:
        return Colors.deepOrange;
      case AuthErrorCategory.rateLimit:
        return Colors.amber;
      case AuthErrorCategory.server:
        return Colors.purple;
      case AuthErrorCategory.validation:
        return theme.colorScheme.error;
      case AuthErrorCategory.unknown:
        return theme.colorScheme.onSurface;
    }
  }
}
