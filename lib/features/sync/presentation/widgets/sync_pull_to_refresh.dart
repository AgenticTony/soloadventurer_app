import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sync_providers.dart';

/// Wrapper widget that adds pull-to-refresh sync functionality
///
/// Features:
/// - Pull down to trigger manual sync
/// - Shows sync progress in refresh indicator
/// - Optional success/error snackbar notifications
/// - Works with any scrollable content
/// - Respects existing RefreshIndicator behavior
class SyncPullToRefresh extends ConsumerStatefulWidget {
  /// The child widget to wrap (typically a ListView or CustomScrollView)
  final Widget child;

  /// Callback when sync completes successfully
  final VoidCallback? onSuccess;

  /// Callback when sync fails
  final VoidCallback? onFailure;

  /// Whether to show snackbar notifications on sync completion
  final bool showNotifications;

  /// Whether to trigger sync automatically on widget mount
  final bool triggerOnMount;

  /// Custom refresh indicator key
  final Key? refreshIndicatorKey;

  const SyncPullToRefresh({
    super.key,
    required this.child,
    this.onSuccess,
    this.onFailure,
    this.showNotifications = true,
    this.triggerOnMount = false,
    this.refreshIndicatorKey,
  });

  @override
  ConsumerState<SyncPullToRefresh> createState() => _SyncPullToRefreshState();
}

class _SyncPullToRefreshState extends ConsumerState<SyncPullToRefresh> {
  @override
  void initState() {
    super.initState();

    if (widget.triggerOnMount) {
      // Trigger sync on next frame after widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(manualSyncNotifierProvider.notifier).triggerSync();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSyncing = ref.watch(isSyncingProvider);
    final state = ref.watch(manualSyncStateProvider);

    // Listen to state changes and show notifications
    ref.listen<ManualSyncState>(
      manualSyncStateProvider,
      (previous, next) {
        if (!widget.showNotifications) return;

        // Check if sync just completed
        if (previous?.isSyncing == true && !next.isSyncing) {
          _handleSyncCompletion(context, next);
        }
      },
    );

    return RefreshIndicator(
      key: widget.refreshIndicatorKey,
      onRefresh: isSyncing
          ? null // Disable refresh during sync
          : () => _handleRefresh(context),
      child: widget.child,
    );
  }

  Future<void> _handleRefresh(BuildContext context) async {
    // Trigger sync
    await ref.read(manualSyncNotifierProvider.notifier).triggerSync();

    // Wait a bit for visual feedback
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _handleSyncCompletion(BuildContext context, ManualSyncState state) {
    final theme = Theme.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (!state.hasResults) return;

    if (state.lastSyncSuccess == true) {
      // Show success notification
      if (widget.showNotifications) {
        _showSuccessSnackBar(
          context,
          scaffoldMessenger,
          theme,
          state,
        );
      }

      widget.onSuccess?.call();
    } else if (state.lastSyncSuccess == false) {
      // Show error notification
      if (widget.showNotifications) {
        _showErrorSnackBar(
          context,
          scaffoldMessenger,
          theme,
          state,
        );
      }

      widget.onFailure?.call();
    }
  }

  void _showSuccessSnackBar(
    BuildContext context,
    ScaffoldMessengerState scaffoldMessenger,
    ThemeData theme,
    ManualSyncState state,
  ) {
    final message = state.failureCount == 0
        ? 'Successfully synced ${state.successCount} ${_pluralize('item', state.successCount)}'
        : 'Synced ${state.successCount} ${_pluralize('item', state.successCount)}, '
          '${state.failureCount} ${_pluralize('failure', state.failureCount)}';

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: theme.colorScheme.primary,
        duration: const Duration(seconds: 2),
        action: state.failureCount > 0
            ? SnackBarAction(
                label: 'View',
                textColor: theme.colorScheme.onPrimary,
                onPressed: () {
                  // Navigate to sync errors or show details
                  // This can be customized by the parent widget
                },
              )
            : null,
      ),
    );
  }

  void _showErrorSnackBar(
    BuildContext context,
    ScaffoldMessengerState scaffoldMessenger,
    ThemeData theme,
    ManualSyncState state,
  ) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          state.errorMessage ?? 'Sync failed',
        ),
        backgroundColor: theme.colorScheme.error,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Retry',
          textColor: theme.colorScheme.onError,
          onPressed: () {
            ref.read(manualSyncNotifierProvider.notifier).triggerSync();
          },
        ),
      ),
    );
  }

  String _pluralize(String word, int count) {
    return count == 1 ? word : '${word}s';
  }
}
