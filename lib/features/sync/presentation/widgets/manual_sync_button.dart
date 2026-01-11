import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sync_providers.dart';

/// Button widget for triggering manual sync operations
///
/// Features:
/// - Shows sync status with appropriate icon and label
/// - Displays loading indicator during sync
/// - Shows sync result summary after completion
/// - Disabled during sync operations
/// - Supports both elevated and text button styles
class ManualSyncButton extends ConsumerWidget {
  /// Callback when sync completes successfully
  final VoidCallback? onSuccess;

  /// Callback when sync fails
  final VoidCallback? onFailure;

  /// Button style variant
  final ManualSyncButtonStyle style;

  /// Whether to show sync result summary
  final bool showResultSummary;

  /// Custom label for the button
  final String? customLabel;

  const ManualSyncButton({
    super.key,
    this.onSuccess,
    this.onFailure,
    this.style = ManualSyncButtonStyle.elevated,
    this.showResultSummary = true,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(manualSyncStateProvider);
    final isSyncing = ref.watch(isSyncingProvider);
    final pendingCount = ref.watch(pendingOperationsCountProvider);

    return _buildButton(context, ref, state, isSyncing, pendingCount);
  }

  Widget _buildButton(
    BuildContext context,
    WidgetRef ref,
    dynamic state,
    bool isSyncing,
    int pendingCount,
  ) {
    final theme = Theme.of(context);

    // Determine label and icon
    final label = customLabel ?? _getLabel(state, pendingCount);
    final icon = _getIcon(state, isSyncing);

    // Build button based on style
    switch (style) {
      case ManualSyncButtonStyle.elevated:
        return ElevatedButton.icon(
          onPressed: isSyncing ? null : () => _handleSyncPress(ref, state),
          icon: icon,
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: _getBackgroundColor(theme, state),
            foregroundColor: _getForegroundColor(theme, state),
            disabledBackgroundColor:
                theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
          ),
        );

      case ManualSyncButtonStyle.text:
        return TextButton.icon(
          onPressed: isSyncing ? null : () => _handleSyncPress(ref, state),
          icon: icon,
          label: Text(label),
        );

      case ManualSyncButtonStyle.outlined:
        return OutlinedButton.icon(
          onPressed: isSyncing ? null : () => _handleSyncPress(ref, state),
          icon: icon,
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: _getForegroundColor(theme, state),
            side: BorderSide(
              color: _getBorderColor(theme, state),
            ),
          ),
        );
    }
  }

  void _handleSyncPress(BuildContextContext ref, dynamic state) {
    // Clear previous error if any
    if (state?.errorMessage != null) {
      ref.read(manualSyncNotifierProvider.notifier).clearError();
    }

    // Trigger sync
    ref.read(manualSyncNotifierProvider.notifier).triggerSync();
  }

  String _getLabel(dynamic state, int pendingCount) {
    if (state.isSyncing) {
      return 'Syncing...';
    }

    if (!state.hasResults) {
      return pendingCount > 0 ? 'Sync ($pendingCount)' : 'Sync Now';
    }

    if (state.lastSyncSuccess == true) {
      return 'Sync Again';
    }

    if (state.lastSyncSuccess == false) {
      return 'Retry Sync';
    }

    return 'Sync Now';
  }

  Widget _getIcon(dynamic state, bool isSyncing) {
    if (isSyncing) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (!state.hasResults) {
      return const Icon(Icons.sync);
    }

    if (state.lastSyncSuccess == true) {
      return const Icon(Icons.check_circle);
    }

    if (state.lastSyncSuccess == false) {
      return const Icon(Icons.error);
    }

    return const Icon(Icons.sync);
  }

  Color _getBackgroundColor(ThemeData theme, dynamic state) {
    if (!state.hasResults) {
      return theme.colorScheme.primary;
    }

    if (state.lastSyncSuccess == true) {
      return theme.colorScheme.primary;
    }

    if (state.lastSyncSuccess == false) {
      return theme.colorScheme.error;
    }

    return theme.colorScheme.primary;
  }

  Color _getForegroundColor(ThemeData theme, dynamic state) {
    if (!state.hasResults) {
      return theme.colorScheme.onPrimary;
    }

    if (state.lastSyncSuccess == true) {
      return theme.colorScheme.onPrimary;
    }

    if (state.lastSyncSuccess == false) {
      return theme.colorScheme.onError;
    }

    return theme.colorScheme.onPrimary;
  }

  Color _getBorderColor(ThemeData theme, dynamic state) {
    if (!state.hasResults) {
      return theme.colorScheme.outline;
    }

    if (state.lastSyncSuccess == true) {
      return theme.colorScheme.primary;
    }

    if (state.lastSyncSuccess == false) {
      return theme.colorScheme.error;
    }

    return theme.colorScheme.outline;
  }
}

/// Style variants for the manual sync button
enum ManualSyncButtonStyle {
  /// Elevated button style
  elevated,

  /// Text button style
  text,

  /// Outlined button style
  outlined,
}
