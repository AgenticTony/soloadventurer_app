import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_manager.dart';
import 'package:soloadventurer/features/offline/presentation/providers/sync_status_provider.dart';
import 'package:soloadventurer/features/offline/presentation/providers/connectivity_provider.dart';

/// A dismissible banner that displays the current sync status
///
/// This widget shows different banner states based on [SyncState]:
/// - **Syncing**: Animated sync icon, progress indicator, current phase
/// - **Error**: Error message with retry button
/// - **Idle with pending**: Shows count of pending operations
/// - **Paused**: Shows paused message
///
/// The banner automatically dismisses on successful sync completion
/// and reappears when sync status changes.
///
/// Example usage:
/// ```dart
/// Scaffold(
///   body: CustomScrollView(
///     slivers: [
///       SliverToBoxAdapter(
///         child: SyncStatusBanner(),
///       ),
///       // Other slivers...
///     ],
///   ),
/// )
/// ```
///
/// Or as an overlay:
/// ```dart
/// Stack(
///   children: [
///     YourContent(),
///     Positioned(
///       top: 0,
///       left: 0,
///       right: 0,
///       child: SyncStatusBanner(),
///     ),
///   ],
/// )
/// ```
class SyncStatusBanner extends ConsumerStatefulWidget {
  /// Creates a new [SyncStatusBanner] instance
  const SyncStatusBanner({super.key});

  @override
  ConsumerState<SyncStatusBanner> createState() => _SyncStatusBannerState();
}

class _SyncStatusBannerState extends ConsumerState<SyncStatusBanner>
    with SingleTickerProviderStateMixin {
  /// Animation controller for sync icon rotation
  late AnimationController _rotationController;

  /// Previous sync state for detecting transitions
  SyncState? _previousState;

  /// Whether banner should be visible
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  /// Handles retry button press
  void _handleRetry() {
    final notifier = ref.read(syncStatusProvider.notifier);
    notifier.triggerSync(force: true);
  }

  /// Handles dismiss action
  void _handleDismiss() {
    setState(() {
      _isVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final syncStatus = ref.watch(syncStatusProvider);
    final connectivityState = ref.watch(connectivityProvider);
    final theme = Theme.of(context);

    // Determine visibility based on state
    _updateVisibility(syncStatus.state);

    // Don't show if not visible
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    // Build banner content based on state
    final bannerContent = _buildBannerContent(
      context,
      syncStatus,
      connectivityState,
      theme,
    );

    return Material(
      elevation: 4,
      child: bannerContent,
    );
  }

  /// Updates banner visibility based on sync state
  void _updateVisibility(SyncState currentState) {
    // Auto-dismiss on successful sync (transition from syncing to idle)
    if (_previousState == SyncState.syncing && currentState == SyncState.idle) {
      // Show success briefly then dismiss
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isVisible = false;
          });
        }
      });
      _isVisible = true;
    }
    // Show banner for non-idle states
    else if (currentState != SyncState.idle ||
        (currentState == SyncState.idle &&
            ref.read(syncStatusProvider).pendingOperations > 0)) {
      _isVisible = true;
    }

    _previousState = currentState;
  }

  /// Builds banner content based on sync state
  Widget _buildBannerContent(
    BuildContext context,
    SyncStatus status,
    ConnectivityState connectivityState,
    ThemeData theme,
  ) {
    switch (status.state) {
      case SyncState.syncing:
        return _buildSyncingBanner(context, status, theme);
      case SyncState.error:
        return _buildErrorBanner(context, status, theme);
      case SyncState.paused:
        return _buildPausedBanner(context, status, connectivityState, theme);
      case SyncState.idle:
        if (status.pendingOperations > 0) {
          return _buildPendingBanner(context, status, theme);
        }
        return const SizedBox.shrink();
    }
  }

  /// Builds banner for syncing state
  Widget _buildSyncingBanner(
    BuildContext context,
    SyncStatus status,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Animated sync icon
          RotationTransition(
            turns: _rotationController,
            child: Icon(
              Icons.sync,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Sync status text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getSyncingText(status.phase),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (status.currentOperation != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    status.currentOperation!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Progress indicator
          if (status.progress > 0) ...[
            const SizedBox(width: 12),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                value: status.progress,
                strokeWidth: 2,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
          ],

          // Dismiss button
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _handleDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: colorScheme.onPrimaryContainer,
          ),
        ],
      ),
    );
  }

  /// Builds banner for error state
  Widget _buildErrorBanner(
    BuildContext context,
    SyncStatus status,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.error.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),

          // Error message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sync Failed',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (status.errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    status.errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          colorScheme.onErrorContainer.withValues(alpha: 0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Retry button
          TextButton.icon(
            onPressed: _handleRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onErrorContainer,
            ),
          ),

          // Dismiss button
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _handleDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: colorScheme.onErrorContainer,
          ),
        ],
      ),
    );
  }

  /// Builds banner for paused state
  Widget _buildPausedBanner(
    BuildContext context,
    SyncStatus status,
    ConnectivityState connectivityState,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),

          // Paused message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sync Paused',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You are currently offline. Changes will sync when you reconnect.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          // Dismiss button
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _handleDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  /// Builds banner for idle state with pending operations
  Widget _buildPendingBanner(
    BuildContext context,
    SyncStatus status,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.secondary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_upload,
            color: colorScheme.onSecondaryContainer,
            size: 20,
          ),
          const SizedBox(width: 12),

          // Pending message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${status.pendingOperations} ${status.pendingOperations == 1 ? 'change' : 'changes'} pending sync',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to sync now',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          // Sync now button
          TextButton.icon(
            onPressed: _handleRetry,
            icon: const Icon(Icons.sync, size: 16),
            label: const Text('Sync'),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSecondaryContainer,
            ),
          ),

          // Dismiss button
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _handleDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: colorScheme.onSecondaryContainer,
          ),
        ],
      ),
    );
  }

  /// Returns descriptive text for current sync phase
  String _getSyncingText(SyncPhase phase) {
    switch (phase) {
      case SyncPhase.upload:
        return 'Uploading changes...';
      case SyncPhase.download:
        return 'Downloading changes...';
      case SyncPhase.conflictResolution:
        return 'Resolving conflicts...';
      case SyncPhase.finalization:
        return 'Finalizing sync...';
      case SyncPhase.none:
        return 'Syncing...';
    }
  }
}
