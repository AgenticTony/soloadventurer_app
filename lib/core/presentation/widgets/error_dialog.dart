import 'package:flutter/material.dart';
import 'package:soloadventurer/core/errors/app_error.dart';
import 'package:soloadventurer/core/presentation/widgets/error_display_widget.dart';

/// Dialog for displaying errors with recovery options
class ErrorDialog extends StatelessWidget {
  /// The error to display
  final AppError error;

  /// Callback when an action is selected
  final Function(ErrorAction)? onAction;

  /// Configuration for display behavior
  final ErrorDisplayConfig config;

  const ErrorDialog({
    super.key,
    required this.error,
    this.onAction,
    this.config = const ErrorDisplayConfig(),
  });

  /// Show the error dialog
  static Future<void> show(
    BuildContext context,
    AppError error, {
    Function(ErrorAction)? onAction,
    ErrorDisplayConfig config = const ErrorDisplayConfig(),
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => ErrorDialog(
        error: error,
        onAction: onAction,
        config: config,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: _buildTitle(context),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error icon and message
            _buildErrorMessage(context),
            const SizedBox(height: 16),

            // Technical details (expandable)
            if (config.showTechnicalDetails && error.technicalMessage != null)
              _buildTechnicalDetails(context),

            // Available actions
            if (error.availableActions.isNotEmpty)
              _buildActionsSection(context, theme),
          ],
        ),
      ),
      actions: _buildDialogActions(context),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final icon = _getSeverityIcon(error.severity);
    final iconColor = _getSeverityColor(error.severity);
    final title = _getSeverityTitle(error.severity);

    return Row(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: iconColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (error.code != null)
          Chip(
            label: Text(
              error.code!,
              style: theme.textTheme.labelSmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
            backgroundColor: iconColor.withValues(alpha:0.1),
          ),
      ],
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              error.message,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalDetails(BuildContext context) {
    return ExpansionTile(
      title: Text(
        'Technical Details',
        style: Theme.of(context).textTheme.labelMedium,
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha:0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (error.technicalMessage != null) ...[
                Text(
                  'Message:',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  error.technicalMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                ),
                const SizedBox(height: 8),
              ],
              if (error.context != null && error.context!.isNotEmpty) ...[
                Text(
                  'Context:',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  error.context.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                ),
              ],
              ...[
                const SizedBox(height: 8),
                Text(
                  'Error ID: ${error.id}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha:0.5),
                        fontFamily: 'monospace',
                      ),
                ),
              ],
            ],
          ),
        )
      ],
    );
  }

  Widget _buildActionsSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What would you like to do?',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...error.availableActions.map((action) {
          final isPrimary = action == error.primaryAction;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ActionButton(
              action: action,
              isPrimary: isPrimary,
              onTap: () {
                onAction?.call(action);
                Navigator.of(context).pop();
              },
            ),
          );
        }),
      ],
    );
  }

  List<Widget> _buildDialogActions(BuildContext context) {
    return [
      if (error.availableActions.contains(ErrorAction.dismiss))
        TextButton(
          onPressed: () {
            onAction?.call(ErrorAction.dismiss);
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
    ];
  }

  IconData _getSeverityIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Icons.info;
      case ErrorSeverity.warning:
        return Icons.warning_amber;
      case ErrorSeverity.error:
        return Icons.error;
      case ErrorSeverity.critical:
        return Icons.dangerous;
    }
  }

  Color _getSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Colors.blue;
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.error:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red.shade900;
    }
  }

  String _getSeverityTitle(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return 'Information';
      case ErrorSeverity.warning:
        return 'Warning';
      case ErrorSeverity.error:
        return 'Error';
      case ErrorSeverity.critical:
        return 'Critical Error';
    }
  }
}

/// Action button widget for error dialog
class _ActionButton extends StatelessWidget {
  final ErrorAction action;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.action,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final icon = _getActionIcon(action);
    final label = _getActionLabel(action);
    final description = _getActionDescription(action);

    return Material(
      color: isPrimary
          ? colorScheme.primary.withValues(alpha:0.1)
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? colorScheme.primary.withValues(alpha:0.2)
                      : colorScheme.onSurfaceVariant.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isPrimary ? colorScheme.primary : null,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight:
                            isPrimary ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (description != null)
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha:0.6),
                        ),
                      ),
                  ],
                ),
              ),
              if (isPrimary)
                Icon(
                  Icons.arrow_forward,
                  color: colorScheme.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getActionIcon(ErrorAction action) {
    switch (action) {
      case ErrorAction.retry:
        return Icons.refresh;
      case ErrorAction.cancel:
        return Icons.cancel;
      case ErrorAction.dismiss:
        return Icons.close;
      case ErrorAction.report:
        return Icons.bug_report;
      case ErrorAction.reauthenticate:
        return Icons.login;
      case ErrorAction.checkConnection:
        return Icons.wifi;
      case ErrorAction.freeStorage:
        return Icons.storage;
      case ErrorAction.updateApp:
        return Icons.system_update;
      case ErrorAction.contactSupport:
        return Icons.support_agent;
      case ErrorAction.viewDetails:
        return Icons.visibility;
      case ErrorAction.clearCache:
        return Icons.delete_sweep;
    }
  }

  String _getActionLabel(ErrorAction action) {
    switch (action) {
      case ErrorAction.retry:
        return 'Try Again';
      case ErrorAction.cancel:
        return 'Cancel';
      case ErrorAction.dismiss:
        return 'Dismiss';
      case ErrorAction.report:
        return 'Report Issue';
      case ErrorAction.reauthenticate:
        return 'Log In Again';
      case ErrorAction.checkConnection:
        return 'Check Connection';
      case ErrorAction.freeStorage:
        return 'Free Up Storage';
      case ErrorAction.updateApp:
        return 'Update App';
      case ErrorAction.contactSupport:
        return 'Contact Support';
      case ErrorAction.viewDetails:
        return 'View Details';
      case ErrorAction.clearCache:
        return 'Clear Cache';
    }
  }

  String? _getActionDescription(ErrorAction action) {
    switch (action) {
      case ErrorAction.retry:
        return 'Retry the operation';
      case ErrorAction.cancel:
        return 'Cancel and go back';
      case ErrorAction.dismiss:
        return 'Hide this message';
      case ErrorAction.report:
        return 'Send error report to support';
      case ErrorAction.reauthenticate:
        return 'Your session has expired';
      case ErrorAction.checkConnection:
        return 'Check your internet connection';
      case ErrorAction.freeStorage:
        return 'Free up device storage space';
      case ErrorAction.updateApp:
        return 'Update to the latest version';
      case ErrorAction.contactSupport:
        return 'Get help from our support team';
      case ErrorAction.viewDetails:
        return 'See technical information';
      case ErrorAction.clearCache:
        return 'Clear app cache and data';
    }
  }
}

/// Bottom sheet variant of error dialog
class ErrorBottomSheet extends StatelessWidget {
  /// The error to display
  final AppError error;

  /// Callback when an action is selected
  final Function(ErrorAction)? onAction;

  /// Configuration for display behavior
  final ErrorDisplayConfig config;

  const ErrorBottomSheet({
    super.key,
    required this.error,
    this.onAction,
    this.config = const ErrorDisplayConfig(),
  });

  /// Show the error bottom sheet
  static Future<void> show(
    BuildContext context,
    AppError error, {
    Function(ErrorAction)? onAction,
    ErrorDisplayConfig config = const ErrorDisplayConfig(),
    bool isDismissible = true,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: true,
      builder: (context) => ErrorBottomSheet(
        error: error,
        onAction: onAction,
        config: config,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha:0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  _getSeverityIcon(error.severity),
                  color: _getSeverityColor(error.severity),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getSeverityTitle(error.severity),
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ErrorDisplayWidget(
                error: error,
                config: config,
                onAction: (action) {
                  onAction?.call(action);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSeverityIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Icons.info;
      case ErrorSeverity.warning:
        return Icons.warning_amber;
      case ErrorSeverity.error:
        return Icons.error;
      case ErrorSeverity.critical:
        return Icons.dangerous;
    }
  }

  Color _getSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Colors.blue;
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.error:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red.shade900;
    }
  }

  String _getSeverityTitle(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return 'Information';
      case ErrorSeverity.warning:
        return 'Warning';
      case ErrorSeverity.error:
        return 'Error';
      case ErrorSeverity.critical:
        return 'Critical Error';
    }
  }
}
