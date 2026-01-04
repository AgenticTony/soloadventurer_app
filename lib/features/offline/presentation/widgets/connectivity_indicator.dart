import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/offline/domain/services/connectivity_service.dart';
import 'package:soloadventurer/features/offline/presentation/providers/connectivity_provider.dart';
import 'package:soloadventurer/features/offline/presentation/providers/sync_status_provider.dart';

/// A small indicator widget showing connection status
///
/// This widget displays different states based on connectivity and sync status:
/// - **Online & Synced**: Green checkmark icon
/// - **Online & Syncing**: Animated rotating sync icon
/// - **Online & Pending**: Blue sync icon with pending count
/// - **Online & Error**: Red error icon
/// - **Offline**: Gray disconnected icon
///
/// The indicator shows a detailed status dialog when tapped, providing
/// information about connection type, sync status, pending operations, and last sync time.
///
/// Example usage in an AppBar:
/// ```dart
/// AppBar(
///   title: Text('My App'),
///   actions: [
///     ConnectivityIndicator(),
///     // Other actions...
///   ],
/// )
/// ```
///
/// Or in a custom app bar:
/// ```dart
/// SliverAppBar(
///   title: Text('My App'),
///   actions: [
///     ConnectivityIndicator(),
///   ],
/// )
/// ```
class ConnectivityIndicator extends ConsumerStatefulWidget {
  /// Creates a new [ConnectivityIndicator] instance
  const ConnectivityIndicator({super.key});

  @override
  ConsumerState<ConnectivityIndicator> createState() =>
      _ConnectivityIndicatorState();
}

class _ConnectivityIndicatorState
    extends ConsumerState<ConnectivityIndicator>
    with SingleTickerProviderStateMixin {
  /// Animation controller for sync icon rotation
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  /// Handles tap to show detailed status dialog
  void _handleTap() {
    final connectivityState = ref.read(connectivityProvider);
    final syncStatus = ref.read(syncStatusProvider);

    showDialog(
      context: context,
      builder: (context) => _ConnectivityStatusDialog(
        connectivityState: connectivityState,
        syncStatus: syncStatus,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectivityState = ref.watch(connectivityProvider);
    final syncStatus = ref.watch(syncStatusProvider);
    final theme = Theme.of(context);

    // Determine icon, color, and badge based on state
    final iconData = _getIcon(connectivityState, syncStatus);
    final iconColor = _getIconColor(connectivityState, syncStatus, theme);
    final shouldAnimate = _shouldAnimateIcon(connectivityState, syncStatus);
    final badgeCount = _getBadgeCount(connectivityState, syncStatus);

    Widget iconWidget = Icon(
      iconData,
      color: iconColor,
      size: 20,
    );

    // Add rotation animation for syncing state
    if (shouldAnimate) {
      if (!_rotationController.isAnimating) {
        _rotationController.repeat();
      }
      iconWidget = RotationTransition(
        turns: _rotationController,
        child: iconWidget,
      );
    } else {
      _rotationController.stop();
    }

    // Wrap with ink well for tap feedback
    return InkWell(
      onTap: _handleTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            iconWidget,
            // Show badge if there are pending operations or errors
            if (badgeCount > 0) ...[
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : badgeCount.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Returns the appropriate icon for the current state
  IconData _getIcon(
    ConnectivityState connectivityState,
    SyncStatus syncStatus,
  ) {
    // If offline, show disconnected icon
    if (!connectivityState.isConnected) {
      return Icons.cloud_off;
    }

    // If syncing, show sync icon
    if (syncStatus.isSyncing) {
      return Icons.sync;
    }

    // If error, show error icon
    if (syncStatus.hasError) {
      return Icons.error_outline;
    }

    // If has pending operations, show upload icon
    if (syncStatus.pendingOperations > 0) {
      return Icons.cloud_upload;
    }

    // Default: show checkmark for online & synced
    return Icons.check_circle;
  }

  /// Returns the appropriate icon color for the current state
  Color _getIconColor(
    ConnectivityState connectivityState,
    SyncStatus syncStatus,
    ThemeData theme,
  ) {
    // If offline, show gray
    if (!connectivityState.isConnected) {
      return theme.colorScheme.onSurfaceVariant.withOpacity(0.6);
    }

    // If syncing, show primary color
    if (syncStatus.isSyncing) {
      return theme.colorScheme.primary;
    }

    // If error, show error color
    if (syncStatus.hasError) {
      return theme.colorScheme.error;
    }

    // If has pending operations, show secondary color
    if (syncStatus.pendingOperations > 0) {
      return theme.colorScheme.secondary;
    }

    // Default: show green for online & synced
    return Colors.green;
  }

  /// Returns whether the icon should be animated
  bool _shouldAnimateIcon(
    ConnectivityState connectivityState,
    SyncStatus syncStatus,
  ) {
    return connectivityState.isConnected && syncStatus.isSyncing;
  }

  /// Returns the badge count to display (0 if no badge)
  int _getBadgeCount(
    ConnectivityState connectivityState,
    SyncStatus syncStatus,
  ) {
    // Show badge for error or pending operations
    if (syncStatus.hasError) {
      return 1; // Just show indicator dot for error
    }

    if (syncStatus.pendingOperations > 0) {
      return syncStatus.pendingOperations;
    }

    return 0;
  }
}

/// Dialog showing detailed connectivity and sync status
class _ConnectivityStatusDialog extends StatelessWidget {
  /// Current connectivity state
  final ConnectivityState connectivityState;

  /// Current sync status
  final SyncStatus syncStatus;

  /// Creates a new [_ConnectivityStatusDialog]
  const _ConnectivityStatusDialog({
    required this.connectivityState,
    required this.syncStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Connection Status'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection status
            _buildStatusRow(
              context,
              icon: connectivityState.isConnected
                  ? Icons.wifi
                  : Icons.wifi_off,
              label: 'Connection',
              value: connectivityState.isConnected
                  ? _getConnectionTypeLabel(connectivityState.connectionType)
                  : 'Disconnected',
              color: connectivityState.isConnected
                  ? Colors.green
                  : theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
            const SizedBox(height: 12),

            // Sync status
            _buildStatusRow(
              context,
              icon: _getSyncStatusIcon(syncStatus.state),
              label: 'Sync Status',
              value: _getSyncStatusLabel(syncStatus.state),
              color: _getSyncStatusColor(syncStatus.state, theme),
            ),
            const SizedBox(height: 12),

            // Sync progress (if syncing)
            if (syncStatus.isSyncing) ...[
              _buildStatusRow(
                context,
                icon: Icons.progress_bar,
                label: 'Progress',
                value: '${(syncStatus.progress * 100).toInt()}%',
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
            ],

            // Pending operations
            _buildStatusRow(
              context,
              icon: Icons.pending_actions,
              label: 'Pending Changes',
              value: syncStatus.pendingOperations.toString(),
              color: syncStatus.pendingOperations > 0
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
            const SizedBox(height: 12),

            // Last sync time
            _buildStatusRow(
              context,
              icon: Icons.access_time,
              label: 'Last Sync',
              value: syncStatus.lastSyncTime != null
                  ? _formatTimestamp(syncStatus.lastSyncTime!)
                  : 'Never',
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
            ),

            // Error message (if any)
            if (syncStatus.errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        syncStatus.errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
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
      actions: [
        // Force sync button (if online and not syncing)
        if (connectivityState.isConnected && !syncStatus.isSyncing)
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // Trigger sync via provider
              // Note: This would need to be handled by the parent widget
              // or via a callback, but for now we'll just close the dialog
            },
            icon: const Icon(Icons.sync),
            label: const Text('Sync Now'),
          ),

        // Close button
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  /// Builds a status row with icon, label, and value
  Widget _buildStatusRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Returns the icon for sync status
  IconData _getSyncStatusIcon(SyncState state) {
    switch (state) {
      case SyncState.syncing:
        return Icons.sync;
      case SyncState.error:
        return Icons.error;
      case SyncState.paused:
        return Icons.pause_circle;
      case SyncState.idle:
        return Icons.check_circle;
    }
  }

  /// Returns the label for sync status
  String _getSyncStatusLabel(SyncState state) {
    switch (state) {
      case SyncState.syncing:
        return 'Syncing...';
      case SyncState.error:
        return 'Failed';
      case SyncState.paused:
        return 'Paused';
      case SyncState.idle:
        return 'Synced';
    }
  }

  /// Returns the color for sync status
  Color _getSyncStatusColor(SyncState state, ThemeData theme) {
    switch (state) {
      case SyncState.syncing:
        return theme.colorScheme.primary;
      case SyncState.error:
        return theme.colorScheme.error;
      case SyncState.paused:
        return theme.colorScheme.onSurfaceVariant.withOpacity(0.6);
      case SyncState.idle:
        return Colors.green;
    }
  }

  /// Returns the label for connection type
  String _getConnectionTypeLabel(ConnectionType type) {
    switch (type) {
      case ConnectionType.wifi:
        return 'WiFi';
      case ConnectionType.cellular:
        return 'Cellular';
      case ConnectionType.none:
        return 'None';
      case ConnectionType.other:
        return 'Other';
    }
  }

  /// Formats a timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
