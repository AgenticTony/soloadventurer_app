import 'package:flutter/material.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_error.dart';

/// Banner widget for displaying sync errors with retry and dismiss actions
///
/// Features:
/// - Severity-based color coding (low/medium/high)
/// - Retry button for retryable errors
/// - Dismissible banner
/// - Shows user-friendly error message and suggestion
class SyncErrorBanner extends StatelessWidget {
  /// The error to display
  final SyncError error;

  /// Callback when user taps retry
  final VoidCallback? onRetry;

  /// Callback when banner is dismissed
  final VoidCallback? onDismiss;

  /// Callback when user taps for more details
  final VoidCallback? onViewDetails;

  /// Whether the banner can be dismissed
  final bool isDismissible;

  /// Whether to show the retry button
  final bool showRetryButton;

  const SyncErrorBanner({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
    this.onViewDetails,
    this.isDismissible = true,
    this.showRetryButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severityColor = _getSeverityColor(theme);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            severityColor.withValues(alpha: 0.15),
            severityColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: severityColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getErrorIcon(),
              color: severityColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Text(
                      _getErrorTitle(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: severityColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (error.retryCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: severityColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Retry ${error.retryCount}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: severityColor,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),

                // Error message
                Text(
                  error.userMessage,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Suggestion
                if (error.suggestion.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    error.suggestion,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Action buttons row
                if (onViewDetails != null ||
                    (error.isRetryable && onRetry != null)) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (error.isRetryable &&
                          showRetryButton &&
                          onRetry != null)
                        TextButton.icon(
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Retry'),
                          style: TextButton.styleFrom(
                            foregroundColor: severityColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      if (onViewDetails != null) ...[
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: onViewDetails,
                          icon: const Icon(Icons.info_outline, size: 16),
                          label: const Text('Details'),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Dismiss button
          if (isDismissible && onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close),
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  /// Gets icon based on error type
  IconData _getErrorIcon() {
    switch (error.type) {
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

  /// Gets color based on severity
  Color _getSeverityColor(ThemeData theme) {
    switch (error.severity) {
      case SyncErrorSeverity.low:
        return Colors.orange;
      case SyncErrorSeverity.medium:
        return Colors.deepOrange;
      case SyncErrorSeverity.high:
        return theme.colorScheme.error;
    }
  }

  /// Gets title based on error type
  String _getErrorTitle() {
    switch (error.type) {
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
}

/// Multiple errors banner
///
/// Shows a banner when multiple sync errors are detected
class MultipleSyncErrorsBanner extends StatelessWidget {
  /// List of errors
  final List<SyncError> errors;

  /// Callback when user taps to view all errors
  final VoidCallback onViewAll;

  /// Callback when banner is dismissed
  final VoidCallback? onDismiss;

  /// Whether the banner can be dismissed
  final bool isDismissible;

  const MultipleSyncErrorsBanner({
    super.key,
    required this.errors,
    required this.onViewAll,
    this.onDismiss,
    this.isDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highestSeverity = _getHighestSeverity();
    final severityColor = _getSeverityColorFromEnum(highestSeverity, theme);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            severityColor.withValues(alpha: 0.15),
            severityColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: severityColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.error_outline,
              color: severityColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${errors.length} Sync Error${errors.length > 1 ? 's' : ''}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: severityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getSummaryText(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Row(
            children: [
              // View all button
              FilledButton.tonal(
                onPressed: onViewAll,
                style: FilledButton.styleFrom(
                  backgroundColor: severityColor.withValues(alpha: 0.2),
                  foregroundColor: severityColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: const Text('View All'),
              ),

              // Dismiss button
              if (isDismissible && onDismiss != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Gets the highest severity
  SyncErrorSeverity _getHighestSeverity() {
    if (errors.any((e) => e.severity == SyncErrorSeverity.high)) {
      return SyncErrorSeverity.high;
    } else if (errors.any((e) => e.severity == SyncErrorSeverity.medium)) {
      return SyncErrorSeverity.medium;
    }
    return SyncErrorSeverity.low;
  }

  /// Gets color based on severity
  Color _getSeverityColorFromEnum(SyncErrorSeverity severity, ThemeData theme) {
    switch (severity) {
      case SyncErrorSeverity.low:
        return Colors.orange;
      case SyncErrorSeverity.medium:
        return Colors.deepOrange;
      case SyncErrorSeverity.high:
        return theme.colorScheme.error;
    }
  }

  /// Gets summary text for errors
  String _getSummaryText() {
    final highSeverity =
        errors.where((e) => e.severity == SyncErrorSeverity.high).length;
    final mediumSeverity =
        errors.where((e) => e.severity == SyncErrorSeverity.medium).length;
    final lowSeverity =
        errors.where((e) => e.severity == SyncErrorSeverity.low).length;

    final parts = <String>[];
    if (highSeverity > 0) {
      parts.add('$highSeverity high');
    }
    if (mediumSeverity > 0) {
      parts.add('$mediumSeverity medium');
    }
    if (lowSeverity > 0) {
      parts.add('$lowSeverity low');
    }

    if (parts.isEmpty) {
      return 'Multiple sync errors detected';
    }

    return '${parts.join(', ')} severity';
  }
}
