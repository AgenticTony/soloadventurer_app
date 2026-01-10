import 'package:flutter/material.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';

/// Utility class for handling errors in the destination discovery feature.
///
/// Provides user-friendly error messages, icons, and recovery actions
/// for different types of errors that may occur during destination discovery.
class DestinationErrorHandler {
  /// Get user-friendly error message based on exception type
  static String getErrorMessage(Object error) {
    if (error is NetworkConnectivityException) {
      return 'No internet connection. Please check your network and try again.';
    } else if (error is NetworkTimeoutException) {
      return 'Request timed out. The server took too long to respond. Please try again.';
    } else if (error is UnauthorizedException) {
      return 'You need to sign in to access this feature.';
    } else if (error is ForbiddenException) {
      return 'You don\'t have permission to access this content.';
    } else if (error is NotFoundException) {
      return 'The requested destination or list could not be found.';
    } else if (error is ServerException) {
      return 'Server error. Our team has been notified. Please try again later.';
    } else if (error is ValidationException) {
      return error.message;
    } else if (error is BadRequestException) {
      return 'Invalid request. Please check your filters and try again.';
    } else if (error is AppException) {
      return error.message;
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  /// Get appropriate icon for error type
  static IconData getErrorIcon(Object error) {
    if (error is NetworkConnectivityException) {
      return Icons.wifi_off;
    } else if (error is NetworkTimeoutException) {
      return Icons.access_time;
    } else if (error is UnauthorizedException) {
      return Icons.lock_outline;
    } else if (error is ForbiddenException) {
      return Icons.block;
    } else if (error is NotFoundException) {
      return Icons.search_off;
    } else if (error is ServerException) {
      return Icons.cloud_off;
    } else if (error is ValidationException) {
      return Icons.warning_amber;
    } else if (error is BadRequestException) {
      return Icons.error_outline;
    } else {
      return Icons.error_outline;
    }
  }

  /// Get error title for display
  static String getErrorTitle(Object error) {
    if (error is NetworkConnectivityException) {
      return 'No Internet Connection';
    } else if (error is NetworkTimeoutException) {
      return 'Request Timed Out';
    } else if (error is UnauthorizedException) {
      return 'Sign In Required';
    } else if (error is ForbiddenException) {
      return 'Access Denied';
    } else if (error is NotFoundException) {
      return 'Not Found';
    } else if (error is ServerException) {
      return 'Server Error';
    } else if (error is ValidationException) {
      return 'Validation Error';
    } else if (error is BadRequestException) {
      return 'Invalid Request';
    } else {
      return 'Something Went Wrong';
    }
  }

  /// Check if error is network-related
  static bool isNetworkError(Object error) {
    return error is NetworkConnectivityException ||
        error is NetworkTimeoutException;
  }

  /// Check if error is auth-related
  static bool isAuthError(Object error) {
    return error is UnauthorizedException || error is ForbiddenException;
  }

  /// Check if error is retryable
  static bool isRetryable(Object error) {
    return error is NetworkConnectivityException ||
        error is NetworkTimeoutException ||
        error is ServerException;
  }

  /// Get suggested action button label
  static String getActionLabel(Object error) {
    if (error is NetworkConnectivityException) {
      return 'Retry';
    } else if (error is NetworkTimeoutException) {
      return 'Retry';
    } else if (error is UnauthorizedException) {
      return 'Sign In';
    } else if (error is ForbiddenException) {
      return 'Go Back';
    } else if (error is NotFoundException) {
      return 'Browse Destinations';
    } else if (error is ServerException) {
      return 'Try Again';
    } else if (error is ValidationException) {
      return 'Fix Errors';
    } else if (error is BadRequestException) {
      return 'Reset Filters';
    } else {
      return 'Try Again';
    }
  }

  /// Get secondary action label (optional)
  static String? getSecondaryActionLabel(Object error) {
    if (error is NetworkConnectivityException) {
      return 'View Offline Content';
    } else if (error is NetworkTimeoutException) {
      return null;
    } else if (error is NotFoundException) {
      return null;
    }
    return null;
  }
}

/// Widget for displaying polished error states with recovery options
class DestinationErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  final VoidCallback? onSecondaryAction;
  final String? customMessage;

  const DestinationErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.onSecondaryAction,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorMessage =
        customMessage ?? DestinationErrorHandler.getErrorMessage(error);
    final errorTitle = DestinationErrorHandler.getErrorTitle(error);
    final errorIcon = DestinationErrorHandler.getErrorIcon(error);
    final actionLabel = DestinationErrorHandler.getActionLabel(error);
    final secondaryActionLabel =
        DestinationErrorHandler.getSecondaryActionLabel(error);
    final isNetworkError = DestinationErrorHandler.isNetworkError(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isNetworkError
                    ? theme.colorScheme.errorContainer.withOpacity(0.3)
                    : theme.colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                errorIcon,
                size: 48,
                color: isNetworkError
                    ? theme.colorScheme.error
                    : theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),

            // Error title
            Text(
              errorTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Error message
            Text(
              errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Primary action button
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(_getActionIcon(error)),
              label: Text(actionLabel),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),

            // Secondary action button (if available)
            if (secondaryActionLabel != null && onSecondaryAction != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onSecondaryAction,
                icon: const Icon(Icons.offline_pin),
                label: Text(secondaryActionLabel),
              ),
            ],

            // Additional help text for network errors
            if (isNetworkError) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tip: Some content may be available offline once loaded',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getActionIcon(Object error) {
    if (error is NetworkConnectivityException ||
        error is NetworkTimeoutException ||
        error is ServerException) {
      return Icons.refresh;
    } else if (error is UnauthorizedException) {
      return Icons.login;
    } else if (error is ForbiddenException) {
      return Icons.arrow_back;
    } else if (error is NotFoundException) {
      return Icons.explore;
    } else if (error is ValidationException) {
      return Icons.edit;
    } else if (error is BadRequestException) {
      return Icons.clear_all;
    } else {
      return Icons.refresh;
    }
  }
}

/// Widget for displaying empty states with helpful messages
class DestinationEmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const DestinationEmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Action button (if provided)
            if (actionLabel != null && onAction != null)
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
              ),
          ],
        ),
      ),
    );
  }
}
