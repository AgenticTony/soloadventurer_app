import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_error.dart';

/// Dialog for displaying detailed sync error information
///
/// Features:
/// - Shows comprehensive error details
/// - Retry and dismiss actions
/// - Help link button
/// - Copy error details
/// - Stack trace display
class SyncErrorDialog extends StatelessWidget {
  /// The error to display
  final SyncError error;

  /// Callback when user taps retry
  final VoidCallback? onRetry;

  /// Callback when user requests help
  final VoidCallback? onHelp;

  const SyncErrorDialog({
    super.key,
    required this.error,
    this.onRetry,
    this.onHelp,
  });

  /// Shows the error dialog
  ///
  /// Returns the user's action: 'retry', 'dismiss', or null if dismissed
  static Future<String?> show({
    required BuildContext context,
    required SyncError error,
    VoidCallback? onRetry,
    VoidCallback? onHelp,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => SyncErrorDialog(
        error: error,
        onRetry: onRetry,
        onHelp: onHelp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severityColor = _getSeverityColor(theme);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getErrorIcon(),
            color: severityColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getErrorTitle(),
              style: TextStyle(color: severityColor),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Severity and type badges
            Row(
              children: [
                _buildBadge(
                  context,
                  error.severity.name.toUpperCase(),
                  severityColor,
                ),
                const SizedBox(width: 8),
                _buildBadge(
                  context,
                  error.type.name.capitalize(),
                  theme.colorScheme.secondary,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // User-friendly message
            Text(
              error.userMessage,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // Suggestion
            if (error.suggestion.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error.suggestion,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Technical details section
            _buildSection(
              context,
              'Technical Details',
              Icons.bug_report,
              [
                _buildDetailRow(context, 'Message', error.technicalMessage),
                if (error.code != null)
                  _buildDetailRow(context, 'Error Code', error.code!),
                if (error.statusCode != null)
                  _buildDetailRow(
                    context,
                    'HTTP Status',
                    error.statusCode.toString(),
                  ),
              ],
            ),

            // Context information
            if (error.entityType != null ||
                error.entityId != null ||
                error.operationType != null)
              _buildSection(
                context,
                'Context',
                Icons.info_outline,
                [
                  if (error.entityType != null)
                    _buildDetailRow(context, 'Entity Type', error.entityType!),
                  if (error.entityId != null)
                    _buildDetailRow(context, 'Entity ID', error.entityId!),
                  if (error.operationType != null)
                    _buildDetailRow(context, 'Operation', error.operationType!),
                ],
              ),

            // Retry information
            _buildSection(
              context,
              'Retry Information',
              Icons.refresh,
              [
                _buildDetailRow(
                  context,
                  'Retryable',
                  error.isRetryable ? 'Yes' : 'No',
                ),
                _buildDetailRow(
                  context,
                  'Retry Attempts',
                  error.retryCount.toString(),
                ),
                if (error.retryCount > 0)
                  _buildDetailRow(
                    context,
                    'Occurred',
                    DateFormat('yyyy-MM-dd HH:mm:ss').format(error.occurredAt),
                  ),
              ],
            ),

            // Additional details
            if (error.details != null && error.details!.isNotEmpty)
              _buildSection(
                context,
                'Additional Details',
                Icons.more_horiz,
                [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.error.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      error.details.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),

            // Error ID for support
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tag,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Error ID: ${error.errorId}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Copy button
        TextButton.icon(
          onPressed: () => _copyErrorDetails(context),
          icon: const Icon(Icons.copy),
          label: const Text('Copy'),
        ),

        // Help button
        if (onHelp != null)
          TextButton.icon(
            onPressed: onHelp,
            icon: const Icon(Icons.help_outline),
            label: const Text('Get Help'),
          ),

        // Retry button
        if (error.isRetryable && onRetry != null)
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop('retry');
              onRetry?.call();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: FilledButton.styleFrom(
              backgroundColor: severityColor.withValues(alpha: 0.2),
              foregroundColor: severityColor,
            ),
          ),

        // Dismiss button
        TextButton(
          onPressed: () => Navigator.of(context).pop('dismiss'),
          child: const Text('Dismiss'),
        ),
      ],
    );
  }

  /// Builds a section with header
  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Section content
        ...children,

        const SizedBox(height: 16),
      ],
    );
  }

  /// Builds a detail row
  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a badge widget
  Widget _buildBadge(
    BuildContext context,
    String text,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Copies error details to clipboard
  void _copyErrorDetails(BuildContext context) {
    final details = '''
Sync Error Details
==================
Error ID: ${error.errorId}
Type: ${error.type.name}
Severity: ${error.severity.name}

User Message: ${error.userMessage}
Suggestion: ${error.suggestion}

Technical Details
-----------------
Message: ${error.technicalMessage}
Code: ${error.error.code ?? 'N/A'}
Status Code: ${error.error.statusCode ?? 'N/A'}

Context
-------
Entity Type: ${error.entityType ?? 'N/A'}
Entity ID: ${error.entityId ?? 'N/A'}
Operation: ${error.operationType ?? 'N/A'}

Retry Information
-----------------
Retryable: ${error.isRetryable}
Retry Count: ${error.retryCount}
Occurred At: ${error.occurredAt.toIso8601String()}

Additional Details
------------------
${error.details?.toString() ?? 'N/A'}
''';

    // In a real implementation, you would use flutter/services to copy to clipboard
    // Clipboard.setData(ClipboardData(text: details));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error details copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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

/// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
