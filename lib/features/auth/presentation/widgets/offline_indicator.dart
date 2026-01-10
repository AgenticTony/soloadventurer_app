import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/offline_auth_manager.dart';
import 'package:soloadventurer/features/auth/presentation/providers/cached_data_provider.dart';

/// Configuration for the offline indicator widget
class OfflineIndicatorConfig {
  /// Whether to show the last sync time
  final bool showLastSyncTime;

  /// Whether to show a tooltip with more information
  final bool showTooltip;

  /// Whether to use compact mode (for app bar actions)
  final bool useCompactMode;

  /// Custom label for offline mode
  final String? offlineLabel;

  /// Custom label for online mode
  final String? onlineLabel;

  /// Custom icon for offline mode
  final IconData? offlineIcon;

  /// Custom icon for online mode
  final IconData? onlineIcon;

  const OfflineIndicatorConfig({
    this.showLastSyncTime = true,
    this.showTooltip = true,
    this.useCompactMode = false,
    this.offlineLabel,
    this.onlineLabel,
    this.offlineIcon,
    this.onlineIcon,
  });

  /// Creates a compact configuration for use in AppBar actions
  const OfflineIndicatorConfig.compact({
    this.showLastSyncTime = false,
    this.showTooltip = true,
    this.useCompactMode = true,
    this.offlineLabel,
    this.onlineLabel,
    this.offlineIcon,
    this.onlineIcon,
  });

  /// Creates a detailed configuration for standalone use
  const OfflineIndicatorConfig.detailed({
    this.showLastSyncTime = true,
    this.showTooltip = true,
    this.useCompactMode = false,
    this.offlineLabel,
    this.onlineLabel,
    this.offlineIcon,
    this.onlineIcon,
  });
}

/// A widget that indicates when the app is in offline mode
///
/// This widget provides:
/// - Visual feedback (color, icon) based on connectivity status
/// - Last sync time display
/// - Tooltip with detailed information
/// - Compact and detailed modes
/// - Non-intrusive design suitable for app bars
///
/// Example usage in AppBar:
/// ```dart
/// AppBar(
///   title: Text('My App'),
///   actions: [
///     OfflineIndicator(
///       config: OfflineIndicatorConfig.compact(),
///     ),
///   ],
/// )
/// ```
///
/// Example usage as standalone widget:
/// ```dart
/// OfflineIndicator(
///   config: OfflineIndicatorConfig.detailed(),
/// )
/// ```
class OfflineIndicator extends ConsumerWidget {
  /// Configuration for the indicator behavior
  final OfflineIndicatorConfig config;

  /// Optional callback when tapped
  final VoidCallback? onTap;

  const OfflineIndicator({
    super.key,
    this.config = const OfflineIndicatorConfig.compact(),
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineStateAsync = ref.watch(offlineStateProvider);

    return offlineStateAsync.when(
      data: (state) {
        final isOffline = state != OfflineAuthState.online;

        if (config.useCompactMode) {
          return _buildCompactIndicator(context, state, isOffline);
        } else {
          return _buildDetailedIndicator(context, state, isOffline);
        }
      },
      loading: () => _buildLoadingIndicator(context),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Builds a compact indicator for use in AppBar actions
  Widget _buildCompactIndicator(
    BuildContext context,
    OfflineAuthState state,
    bool isOffline,
  ) {
    final theme = Theme.of(context);
    final icon = isOffline
        ? (config.offlineIcon ?? Icons.cloud_off)
        : (config.onlineIcon ?? Icons.cloud_done);
    final color =
        isOffline ? theme.colorScheme.error : theme.colorScheme.primary;
    final label = isOffline
        ? (config.offlineLabel ?? 'Offline')
        : (config.onlineLabel ?? 'Online');

    final indicator = IconButton(
      icon: Icon(icon),
      color: color,
      tooltip: config.showTooltip ? _buildTooltipText(state, isOffline) : label,
      onPressed: onTap,
    );

    return indicator;
  }

  /// Builds a detailed indicator for standalone use
  Widget _buildDetailedIndicator(
    BuildContext context,
    OfflineAuthState state,
    bool isOffline,
  ) {
    final theme = Theme.of(context);
    final icon = isOffline
        ? (config.offlineIcon ?? Icons.cloud_off)
        : (config.onlineIcon ?? Icons.cloud_done);
    final color =
        isOffline ? theme.colorScheme.error : theme.colorScheme.primary;
    final label = isOffline
        ? (config.offlineLabel ?? 'Offline Mode')
        : (config.onlineLabel ?? 'Online');

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (config.showLastSyncTime && isOffline)
                    _buildLastSyncTime(context, state, theme),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the last sync time display
  Widget _buildLastSyncTime(
    BuildContext context,
    OfflineAuthState state,
    ThemeData theme,
  ) {
    // Get the cached data info from the provider
    return Consumer(
      builder: (context, ref, _) {
        final cachedDataAsync = ref.watch(cachedDataProvider);

        return cachedDataAsync.when(
          data: (cachedDataProvider) async {
            try {
              final isOffline = await cachedDataProvider.isOffline();

              if (!isOffline) {
                return const SizedBox.shrink();
              }

              final cachedDataInfo =
                  await cachedDataProvider.getCachedDataInfo();

              final lastSyncAt = cachedDataInfo.lastCachedAt;
              if (lastSyncAt == null) {
                return Text(
                  'No sync data',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                );
              }

              final timeAgo = _formatTimeAgo(lastSyncAt);
              return Text(
                'Last sync: $timeAgo',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              );
            } catch (e) {
              return const SizedBox.shrink();
            }
          },
          loading: () => const SizedBox(
            width: 100,
            height: 14,
            child: LinearProgressIndicator(),
          ),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  /// Builds a loading indicator
  Widget _buildLoadingIndicator(BuildContext context) {
    if (config.useCompactMode) {
      return const IconButton(
        icon: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        onPressed: null,
      );
    } else {
      return const Card(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
  }

  /// Builds the tooltip text based on state
  String _buildTooltipText(OfflineAuthState state, bool isOffline) {
    if (!isOffline) {
      return 'Connected to server';
    }

    switch (state) {
      case OfflineAuthState.offlineWithCache:
        return 'Offline - Using cached data';
      case OfflineAuthState.offlineWithoutCache:
        return 'Offline - No cached data available';
      case OfflineAuthState.needsSync:
        return 'Syncing with server...';
      case OfflineAuthState.online:
        return 'Connected to server';
    }
  }

  /// Formats a datetime as a "time ago" string
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes minute${minutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days day${days == 1 ? '' : 's'} ago';
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
  }
}

/// A banner widget that shows offline status at the top of the screen
///
/// This is more intrusive than the compact indicator and can be used
/// when you want to make the offline status very visible to the user.
///
/// Example usage:
/// ```dart
/// Scaffold(
///   body: Column(
///     children: [
///       OfflineBanner(),
///       // Rest of app content
///     ],
///   ),
/// )
/// ```
class OfflineBanner extends ConsumerWidget {
  /// Whether the banner can be dismissed
  final bool dismissible;

  /// Optional callback when banner is dismissed
  final VoidCallback? onDismiss;

  const OfflineBanner({
    super.key,
    this.dismissible = true,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineStateAsync = ref.watch(offlineStateProvider);

    return offlineStateAsync.when(
      data: (state) {
        final isOffline = state != OfflineAuthState.online;

        if (!isOffline) {
          return const SizedBox.shrink();
        }

        return _buildBanner(context, state);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBanner(BuildContext context, OfflineAuthState state) {
    final theme = Theme.of(context);
    final backgroundColor = theme.colorScheme.errorContainer;
    final textColor = theme.colorScheme.onErrorContainer;

    String message;
    IconData icon;

    switch (state) {
      case OfflineAuthState.offlineWithCache:
        message = 'You\'re offline. Using cached data.';
        icon = Icons.cloud_off;
        break;
      case OfflineAuthState.offlineWithoutCache:
        message = 'You\'re offline. Some features may be unavailable.';
        icon = Icons.cloud_off;
        break;
      case OfflineAuthState.needsSync:
        message = 'Syncing your data...';
        icon = Icons.sync;
        break;
      case OfflineAuthState.online:
        return const SizedBox.shrink();
    }

    return Material(
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                ),
              ),
              if (dismissible)
                IconButton(
                  icon: Icon(Icons.close, color: textColor, size: 20),
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
}
