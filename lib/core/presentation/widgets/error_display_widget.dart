import 'package:flutter/material.dart';
import 'package:soloadventurer/core/errors/app_error.dart';

/// Configuration for error display behavior
class ErrorDisplayConfig {
  /// Whether to show the error icon
  final bool showIcon;

  /// Whether to show the error code
  final bool showCode;

  /// Whether to show technical details (expandable)
  final bool showTechnicalDetails;

  /// Whether to auto-dismiss after duration
  final bool autoDismiss;

  /// Auto-dismiss duration
  final Duration dismissDuration;

  /// Custom error messages
  final Map<String, String>? customMessages;

  const ErrorDisplayConfig({
    this.showIcon = true,
    this.showCode = false,
    this.showTechnicalDetails = true,
    this.autoDismiss = false,
    this.dismissDuration = const Duration(seconds: 5),
    this.customMessages,
  });
}

/// Widget for displaying an error with recovery options
class ErrorDisplayWidget extends StatelessWidget {
  /// The error to display
  final AppError error;

  /// Configuration for display behavior
  final ErrorDisplayConfig config;

  /// Callback when an action is selected
  final Function(ErrorAction)? onAction;

  /// Optional custom title
  final String? title;

  /// Optional custom child widget
  final Widget? child;

  const ErrorDisplayWidget({
    super.key,
    required this.error,
    this.config = const ErrorDisplayConfig(),
    this.onAction,
    this.title,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine colors based on severity
    Color backgroundColor;
    Color iconColor;
    IconData iconData;

    switch (error.severity) {
      case ErrorSeverity.info:
        backgroundColor = colorScheme.primaryContainer;
        iconColor = colorScheme.primary;
        iconData = Icons.info_outline;
        break;
      case ErrorSeverity.warning:
        backgroundColor = colorScheme.errorContainer.withValues(alpha:0.3);
        iconColor = Colors.orange.shade700;
        iconData = Icons.warning_amber_outlined;
        break;
      case ErrorSeverity.error:
        backgroundColor = colorScheme.errorContainer;
        iconColor = colorScheme.error;
        iconData = Icons.error_outline;
        break;
      case ErrorSeverity.critical:
        backgroundColor = colorScheme.error;
        iconColor = colorScheme.onError;
        iconData = Icons.dangerous;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withValues(alpha:0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          if (config.showIcon || title != null || error.code != null)
            _buildHeader(
              context,
              iconData,
              iconColor,
              backgroundColor,
            ),

          // Error message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              config.customMessages?[error.code ?? ''] ?? error.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _getTextColor(colorScheme, error.severity),
              ),
            ),
          ),

          // Recovery actions
          if (error.availableActions.isNotEmpty)
            _buildActions(context, theme, colorScheme),

          // Technical details (expandable)
          if (config.showTechnicalDetails && error.technicalMessage != null)
            _buildTechnicalDetails(context, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    IconData iconData,
    Color iconColor,
    Color backgroundColor,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha:0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          if (config.showIcon) ...[
            Icon(iconData, color: iconColor, size: 24),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title ?? _getTitle(error.severity),
              style: theme.textTheme.titleSmall?.copyWith(
                color: _getTextColor(colorScheme, error.severity),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (config.showCode && error.code != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                error.code!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: iconColor,
                  fontFamily: 'monospace',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        children: error.availableActions.map((action) {
          final isPrimary = action == error.primaryAction;
          return _ActionChip(
            action: action,
            isPrimary: isPrimary,
            onPressed: () => onAction?.call(action),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTechnicalDetails(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Text(
        'Technical Details',
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha:0.6),
        ),
      ),
      iconColor: colorScheme.onSurface.withValues(alpha:0.6),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (error.technicalMessage != null) ...[
                Text(
                  'Message:',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  error.technicalMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (error.context != null && error.context!.isNotEmpty) ...[
                Text(
                  'Context:',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  error.context.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ],
              ...[
                const SizedBox(height: 8),
                Text(
                  'Error ID: ${error.id}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha:0.5),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _getTitle(ErrorSeverity severity) {
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

  Color _getTextColor(ColorScheme colorScheme, ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.critical:
        return colorScheme.onError;
      default:
        return colorScheme.onSurface;
    }
  }
}

/// Action chip widget for error recovery actions
class _ActionChip extends StatelessWidget {
  final ErrorAction action;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _ActionChip({
    required this.action,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final label = _getActionLabel(action);
    final icon = _getActionIcon(action);

    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      );
    }
  }

  String _getActionLabel(ErrorAction action) {
    switch (action) {
      case ErrorAction.retry:
        return 'Retry';
      case ErrorAction.cancel:
        return 'Cancel';
      case ErrorAction.dismiss:
        return 'Dismiss';
      case ErrorAction.report:
        return 'Report';
      case ErrorAction.reauthenticate:
        return 'Log In';
      case ErrorAction.checkConnection:
        return 'Check Connection';
      case ErrorAction.freeStorage:
        return 'Free Storage';
      case ErrorAction.updateApp:
        return 'Update App';
      case ErrorAction.contactSupport:
        return 'Contact Support';
      case ErrorAction.viewDetails:
        return 'Details';
      case ErrorAction.clearCache:
        return 'Clear Cache';
    }
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
}

/// Banner widget for displaying errors at the top of the screen
class ErrorBannerWidget extends StatelessWidget {
  /// The error to display
  final AppError error;

  /// Callback when an action is selected
  final Function(ErrorAction)? onAction;

  /// Callback when banner is dismissed
  final VoidCallback? onDismiss;

  const ErrorBannerWidget({
    super.key,
    required this.error,
    this.onAction,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: Text(error.message),
      leading: Icon(_getSeverityIcon(error.severity)),
      actions: error.availableActions.map((action) {
        return TextButton(
          onPressed: () => onAction?.call(action),
          child: Text(_getActionLabel(action)),
        );
      }).toList(),
      backgroundColor: _getBackgroundColor(context, error.severity),
    );
  }

  IconData _getSeverityIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Icons.info;
      case ErrorSeverity.warning:
        return Icons.warning;
      case ErrorSeverity.error:
        return Icons.error;
      case ErrorSeverity.critical:
        return Icons.dangerous;
    }
  }

  Color _getBackgroundColor(BuildContext context, ErrorSeverity severity) {
    final theme = Theme.of(context);
    switch (severity) {
      case ErrorSeverity.info:
        return theme.colorScheme.primaryContainer;
      case ErrorSeverity.warning:
        return Colors.orange.shade100;
      case ErrorSeverity.error:
        return theme.colorScheme.errorContainer;
      case ErrorSeverity.critical:
        return theme.colorScheme.error;
    }
  }

  String _getActionLabel(ErrorAction action) {
    switch (action) {
      case ErrorAction.retry:
        return 'Retry';
      case ErrorAction.dismiss:
        return 'Dismiss';
      case ErrorAction.report:
        return 'Report';
      case ErrorAction.reauthenticate:
        return 'Login';
      case ErrorAction.checkConnection:
        return 'WiFi';
      case ErrorAction.clearCache:
        return 'Clear';
      default:
        return action.name;
    }
  }
}

/// Card widget for displaying errors in a list
class ErrorCardWidget extends StatelessWidget {
  /// The error to display
  final AppError error;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when action is selected
  final Function(ErrorAction)? onAction;

  const ErrorCardWidget({
    super.key,
    required this.error,
    this.onTap,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getSeverityIcon(error.severity),
                    color: _getSeverityColor(error.severity),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      error.message,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  if (error.code != null)
                    Chip(
                      label: Text(
                        error.code!,
                        style: theme.textTheme.labelSmall,
                      ),
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                ],
              ),
              if (error.availableActions.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: error.availableActions.take(3).map((action) {
                    return ActionChip(
                      label: Text(_getActionLabel(action)),
                      onPressed: () => onAction?.call(action),
                      avatar: Icon(_getActionIcon(action), size: 18),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSeverityIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Icons.info_outline;
      case ErrorSeverity.warning:
        return Icons.warning_amber_outlined;
      case ErrorSeverity.error:
        return Icons.error_outline;
      case ErrorSeverity.critical:
        return Icons.dangerous_outlined;
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

  String _getActionLabel(ErrorAction action) {
    switch (action) {
      case ErrorAction.retry:
        return 'Retry';
      case ErrorAction.dismiss:
        return 'Dismiss';
      case ErrorAction.report:
        return 'Report';
      default:
        return action.name;
    }
  }

  IconData _getActionIcon(ErrorAction action) {
    switch (action) {
      case ErrorAction.retry:
        return Icons.refresh;
      case ErrorAction.dismiss:
        return Icons.close;
      case ErrorAction.report:
        return Icons.bug_report;
      default:
        return Icons.arrow_forward;
    }
  }
}
