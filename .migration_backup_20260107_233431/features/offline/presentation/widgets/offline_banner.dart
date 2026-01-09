import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/offline/presentation/providers/connectivity_provider.dart';
import 'package:soloadventurer/features/offline/presentation/providers/sync_status_provider.dart';

/// A prominent banner that displays when the app is in offline mode
///
/// This widget appears when connectivity is lost and informs users that
/// their data will sync automatically when they reconnect. The banner is
/// dismissible but will reappear when the app returns to the foreground.
///
/// Features:
/// - Shows when device is offline (no internet connection)
/// - Displays count of pending operations that will sync later
/// - Dismissible by user with close button
/// - Reappears when app is brought to foreground
/// - Distinctive orange/amber styling to differentiate from sync banner
/// - Optional message about cached data availability
///
/// Example usage in an app shell:
/// ```dart
/// Scaffold(
///   body: Column(
///     children: [
///       OfflineBanner(),
///       // Other content...
///     ],
///   ),
/// )
/// ```
///
/// Or as a sliver in CustomScrollView:
/// ```dart
/// CustomScrollView(
///   slivers: [
///     SliverToBoxAdapter(
///       child: OfflineBanner(),
///     ),
///     // Other slivers...
///   ],
/// )
/// ```
class OfflineBanner extends ConsumerStatefulWidget {
  /// Creates a new [OfflineBanner] instance
  const OfflineBanner({super.key});

  @override
  ConsumerState<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends ConsumerState<OfflineBanner>
    with WidgetsBindingObserver {
  /// Whether banner should be visible
  bool _isVisible = false;

  /// Whether user has manually dismissed the banner
  bool _isManuallyDismissed = false;

  /// Previous offline state for detecting changes
  bool? _wasOffline;

  @override
  void initState() {
    super.initState();
    // Add app lifecycle observer to detect foreground events
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove observer when widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reset manual dismissal when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      if (_isManuallyDismissed) {
        setState(() {
          _isManuallyDismissed = false;
        });
      }
    }
  }

  /// Handles dismiss action
  void _handleDismiss() {
    setState(() {
      _isManuallyDismissed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectivityState = ref.watch(connectivityProvider);
    final syncStatus = ref.watch(syncStatusProvider);
    final theme = Theme.of(context);

    // Check if currently offline
    final isOffline = !connectivityState.isConnected;

    // Detect offline state transition
    if (_wasOffline != null && _wasOffline != isOffline) {
      // State changed, reset manual dismissal
      if (_isManuallyDismissed) {
        _isManuallyDismissed = false;
      }
    }
    _wasOffline = isOffline;

    // Update visibility based on offline state and manual dismissal
    _updateVisibility(isOffline, syncStatus.pendingOperations);

    // Don't show if not visible
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    // Build offline banner
    final colorScheme = theme.colorScheme;

    return Material(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          // Use distinctive orange/amber color for offline banner
          color: colorScheme.errorContainer.withOpacity(0.3),
          border: Border(
            bottom: BorderSide(
              color: colorScheme.error.withOpacity(0.5),
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            // Offline icon
            Icon(
              Icons.cloud_off,
              color: colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 12),

            // Offline message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'You\'re offline',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _buildMessage(syncStatus.pendingOperations),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onErrorContainer.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),

            // Pending operations indicator
            if (syncStatus.pendingOperations > 0) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.error.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.pending,
                      color: colorScheme.error,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${syncStatus.pendingOperations}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Dismiss button
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: _handleDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: colorScheme.onErrorContainer,
              splashRadius: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Updates banner visibility based on offline state and pending operations
  void _updateVisibility(bool isOffline, int pendingOperations) {
    // Show banner when offline and not manually dismissed
    if (isOffline && !_isManuallyDismissed) {
      _isVisible = true;
    } else {
      _isVisible = false;
    }
  }

  /// Builds message text based on pending operations count
  String _buildMessage(int pendingOperations) {
    if (pendingOperations > 0) {
      return 'Changes will sync automatically when you reconnect';
    } else {
      return 'Your data is available. Changes will sync when you reconnect';
    }
  }
}
