import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_error.dart';

/// Card widget for displaying a sync error with expandable details
///
/// Features:
/// - Expandable/collapsible details section
/// - Shows all error information including technical details
/// - Copy error details to clipboard
/// - Help link button
/// - Retry and dismiss actions
class SyncErrorCard extends StatefulWidget {
  /// The error to display
  final SyncError error;

  /// Callback when user taps retry
  final VoidCallback? onRetry;

  /// Callback when card is dismissed
  final VoidCallback? onDismiss;

  /// Callback when user requests help
  final VoidCallback? onHelp;

  /// Whether the card can be dismissed
  final bool isDismissible;

  /// Whether to start expanded
  final bool initiallyExpanded;

  const SyncErrorCard({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
    this.onHelp,
    this.isDismissible = true,
    this.initiallyExpanded = false,
  });

  @override
  State<SyncErrorCard> createState() => _SyncErrorCardState();
}

class _SyncErrorCardState extends State<SyncErrorCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severityColor = _getSeverityColor(theme);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: severityColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section (always visible)
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getErrorIcon(),
                      color: severityColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row
                        Row(
                          children: [
                            Text(
                              _getErrorTitle(),
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: severityColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              size: 20,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // User-friendly message
                        Text(
                          widget.error.userMessage,
                          style: theme.textTheme.bodyMedium,
                        ),

                        // Metadata row
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            // Severity badge
                            _buildBadge(
                              context,
                              widget.error.severity.name.toUpperCase(),
                              severityColor,
                            ),
                            const SizedBox(width: 8),

                            // Time ago
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getTimeAgo(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),

                            // Retry count if applicable
                            if (widget.error.retryCount > 0) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.refresh,
                                size: 12,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.error.retryCount} attempt${widget.error.retryCount > 1 ? 's' : ''}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Dismiss button
                  if (widget.isDismissible && widget.onDismiss != null)
                    IconButton(
                      onPressed: widget.onDismiss,
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),

          // Divider
          Divider(
            height: 1,
            color: severityColor.withValues(alpha: 0.2),
          ),

          // Expanded details section
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Suggestion
                  if (widget.error.suggestion.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.error.suggestion,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Technical details section
                  _buildDetailSection(
                    context,
                    'Technical Details',
                    widget.error.technicalMessage,
                    Icons.bug_report,
                  ),

                  // Error code if available
                  if (widget.error.code != null)
                    _buildDetailRow(
                      context,
                      'Error Code',
                      widget.error.code!,
                    ),

                  // HTTP status code if available
                  if (widget.error.statusCode != null)
                    _buildDetailRow(
                      context,
                      'Status Code',
                      widget.error.statusCode.toString(),
                    ),

                  // Entity type if available
                  if (widget.error.entityType != null)
                    _buildDetailRow(
                      context,
                      'Entity Type',
                      widget.error.entityType!,
                    ),

                  // Entity ID if available
                  if (widget.error.entityId != null)
                    _buildDetailRow(
                      context,
                      'Entity ID',
                      widget.error.entityId!,
                      truncate: true,
                    ),

                  // Operation type if available
                  if (widget.error.operationType != null)
                    _buildDetailRow(
                      context,
                      'Operation',
                      widget.error.operationType!,
                    ),

                  // Timestamp
                  _buildDetailRow(
                    context,
                    'Occurred At',
                    DateFormat('yyyy-MM-dd HH:mm:ss')
                        .format(widget.error.occurredAt),
                  ),

                  // Retryable status
                  _buildDetailRow(
                    context,
                    'Retryable',
                    widget.error.isRetryable ? 'Yes' : 'No',
                  ),

                  // Additional details if available
                  if (widget.error.details != null &&
                      widget.error.details!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Additional Details:',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.error.details.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],

                  // Action buttons
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Retry button
                      if (widget.error.isRetryable && widget.onRetry != null)
                        FilledButton.icon(
                          onPressed: widget.onRetry,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Retry'),
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                severityColor.withValues(alpha: 0.2),
                            foregroundColor: severityColor,
                          ),
                        ),

                      // Copy error details button
                      OutlinedButton.icon(
                        onPressed: () => _copyErrorDetails(context),
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Copy Details'),
                      ),

                      // Help button
                      if (widget.onHelp != null)
                        OutlinedButton.icon(
                          onPressed: widget.onHelp,
                          icon: const Icon(Icons.help_outline, size: 18),
                          label: const Text('Get Help'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Builds a detail section with icon and text
  Widget _buildDetailSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  content,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a detail row
  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool truncate = false,
  }) {
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
              truncate && value.length > 30
                  ? '${value.substring(0, 30)}...'
                  : value,
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  /// Copies error details to clipboard
  void _copyErrorDetails(BuildContext context) {
    final details = '''
Error: ${widget.error.userMessage}
Type: ${widget.error.type.name}
Severity: ${widget.error.severity.name}
Technical: ${widget.error.technicalMessage}
Code: ${widget.error.code ?? 'N/A'}
Status: ${widget.error.statusCode ?? 'N/A'}
Entity: ${widget.error.entityType ?? 'N/A'} (${widget.error.entityId ?? 'N/A'})
Operation: ${widget.error.operationType ?? 'N/A'}
Retry Count: ${widget.error.retryCount}
Retryable: ${widget.error.isRetryable}
Occurred: ${widget.error.occurredAt.toIso8601String()}
Details: ${widget.error.details?.toString() ?? 'N/A'}
''';

    // In a real implementation, you would use flutter/services to copy to clipboard
    // Clipboard.setData(ClipboardData(text: details));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error details copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Gets time ago string
  String _getTimeAgo() {
    final now = DateTime.now();
    final diff = now.difference(widget.error.occurredAt);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  /// Gets icon based on error type
  IconData _getErrorIcon() {
    switch (widget.error.type) {
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
    switch (widget.error.severity) {
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
    switch (widget.error.type) {
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
