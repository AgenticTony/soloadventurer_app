import 'package:flutter/material.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_error.dart';

/// Helper functions for displaying sync error toasts and snack bars
///
/// Provides convenient static methods for showing error notifications
/// with various configurations and options.
class SyncErrorToast {
  /// Shows a simple error toast/snackbar
  ///
  /// Displays a brief error message with the option to retry
  static void showError({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? snackBarAction,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: snackBarAction ??
            (onAction != null && actionLabel != null
                ? SnackBarAction(
                    label: actionLabel,
                    onPressed: onAction,
                  )
                : null),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Shows a toast for a specific SyncError
  ///
  /// Displays user-friendly error message with appropriate styling
  static void showSyncError({
    required BuildContext context,
    required SyncError error,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    Duration duration = const Duration(seconds: 5),
  }) {
    final theme = Theme.of(context);
    final severityColor = _getSeverityColor(error.severity, theme);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(error.type),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getErrorTitle(error.type),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    error.userMessage,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: duration,
        backgroundColor: severityColor,
        action: error.isRetryable && onRetry != null
            ? SnackBarAction(
                label: 'RETRY',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Shows a dismissible error banner
  ///
  /// Similar to a SnackBar but with more prominent styling
  static void showErrorBanner({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    Duration duration = const Duration(seconds: 6),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        duration: duration,
        backgroundColor: Colors.red.shade700,
        action: onRetry != null
            ? SnackBarAction(
                label: 'RETRY',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Shows a warning toast (less severe than error)
  static void showWarning({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        duration: duration,
        backgroundColor: Colors.orange,
        action: onAction != null && actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  /// Shows an info toast
  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        duration: duration,
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Shows a success toast
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        duration: duration,
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Shows a custom error toast with a widget
  static void showCustom({
    required BuildContext context,
    required Widget content,
    Duration duration = const Duration(seconds: 4),
    Color? backgroundColor,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: content,
        duration: duration,
        backgroundColor: backgroundColor,
        action: action,
      ),
    );
  }

  /// Shows multiple errors in a single toast
  static void showMultipleErrors({
    required BuildContext context,
    required List<SyncError> errors,
    VoidCallback? onViewAll,
    Duration duration = const Duration(seconds: 5),
  }) {
    if (errors.isEmpty) return;

    final theme = Theme.of(context);
    final highestSeverity = _getHighestSeverity(errors);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${errors.length} Sync Error${errors.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getSummaryText(errors),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: duration,
        backgroundColor: _getSeverityColor(highestSeverity, theme),
        action: onViewAll != null
            ? SnackBarAction(
                label: 'VIEW ALL',
                textColor: Colors.white,
                onPressed: onViewAll,
              )
            : null,
      ),
    );
  }

  /// Clears all currently showing snack bars/toasts
  static void clear(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  /// Hides the current snackbar/toast
  static void hideCurrent(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Gets color based on severity
  static Color _getSeverityColor(SyncErrorSeverity severity, ThemeData theme) {
    switch (severity) {
      case SyncErrorSeverity.low:
        return Colors.orange;
      case SyncErrorSeverity.medium:
        return Colors.deepOrange;
      case SyncErrorSeverity.high:
        return theme.colorScheme.error;
    }
  }

  /// Gets icon based on error type
  static IconData _getErrorIcon(SyncErrorType type) {
    switch (type) {
      case SyncErrorType.network:
        return Icons.wifi_off;
      case SyncErrorType.authentication:
        return Icons.lock_outline;
      case SyncErrorType.server:
        return Icons.cloud_off;
      case SyncErrorType.validation:
        return Icons.error_outline;
      case SyncErrorType.conflict:
        return Icons.sync_problem;
      case SyncErrorType.timeout:
        return Icons.access_time;
      case SyncErrorType.notFound:
        return Icons.search_off;
      case SyncErrorType.rateLimited:
        return Icons.speed;
      case SyncErrorType.quotaExceeded:
        return Icons.storage;
      case SyncErrorType.unknown:
        return Icons.help_outline;
    }
  }

  /// Gets title based on error type
  static String _getErrorTitle(SyncErrorType type) {
    switch (type) {
      case SyncErrorType.network:
        return 'Network Error';
      case SyncErrorType.authentication:
        return 'Authentication Failed';
      case SyncErrorType.server:
        return 'Server Error';
      case SyncErrorType.validation:
        return 'Invalid Data';
      case SyncErrorType.conflict:
        return 'Sync Conflict';
      case SyncErrorType.timeout:
        return 'Request Timeout';
      case SyncErrorType.notFound:
        return 'Not Found';
      case SyncErrorType.rateLimited:
        return 'Rate Limited';
      case SyncErrorType.quotaExceeded:
        return 'Quota Exceeded';
      case SyncErrorType.unknown:
        return 'Sync Error';
    }
  }

  /// Gets the highest severity from a list of errors
  static SyncErrorSeverity _getHighestSeverity(List<SyncError> errors) {
    if (errors.any((e) => e.severity == SyncErrorSeverity.high)) {
      return SyncErrorSeverity.high;
    } else if (errors.any((e) => e.severity == SyncErrorSeverity.medium)) {
      return SyncErrorSeverity.medium;
    }
    return SyncErrorSeverity.low;
  }

  /// Gets summary text for multiple errors
  static String _getSummaryText(List<SyncError> errors) {
    final highSeverity = errors
        .where((e) => e.severity == SyncErrorSeverity.high)
        .length;
    final mediumSeverity = errors
        .where((e) => e.severity == SyncErrorSeverity.medium)
        .length;
    final lowSeverity = errors
        .where((e) => e.severity == SyncErrorSeverity.low)
        .length;

    if (highSeverity > 0) {
      return '$highSeverity high severity error${highSeverity > 1 ? 's' : ''}';
    } else if (mediumSeverity > 0) {
      return '$mediumSeverity medium severity error${mediumSeverity > 1 ? 's' : ''}';
    } else {
      return '$lowSeverity low severity error${lowSeverity > 1 ? 's' : ''}';
    }
  }
}
