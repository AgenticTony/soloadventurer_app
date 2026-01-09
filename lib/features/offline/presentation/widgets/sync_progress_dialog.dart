import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import 'package:soloadventurer/features/offline/domain/entities/sync_operation.dart';
import 'package:soloadventurer/features/offline/domain/repositories/sync_queue_repository.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_manager.dart';
import 'package:soloadventurer/features/offline/presentation/providers/sync_status_provider.dart';

/// A dialog showing detailed sync progress with operations list
///
/// This dialog displays comprehensive sync information including:
/// - Current sync progress with animated progress bar
/// - List of pending operations in the queue
/// - Failed operations with error messages and retry buttons
/// - Cancel and retry all actions
///
/// The dialog updates in real-time as sync progresses and can be
/// used as a modal dialog or adapted to a bottom sheet.
///
/// Example usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => const SyncProgressDialog(),
/// );
/// ```
///
/// Or as a bottom sheet:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   builder: (context) => const SyncProgressDialog(),
/// );
/// ```
class SyncProgressDialog extends ConsumerStatefulWidget {
  /// Creates a new [SyncProgressDialog] instance
  const SyncProgressDialog({super.key});

  @override
  ConsumerState<SyncProgressDialog> createState() => _SyncProgressDialogState();
}

class _SyncProgressDialogState extends ConsumerState<SyncProgressDialog>
    with SingleTickerProviderStateMixin {
  /// Animation controller for progress rotation
  late AnimationController _rotationController;

  /// List of pending operations
  List<SyncOperationEntity> _pendingOperations = [];

  /// List of failed operations
  List<SyncOperationEntity> _failedOperations = [];

  /// Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _loadOperations();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  /// Loads operations from the sync queue
  Future<void> _loadOperations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = getIt<SyncQueueRepository>();

      // Load pending and failed operations in parallel
      final results = await Future.wait([
        repository.getPendingOperations(limit: 20),
        repository.getOperationsByStatus(SyncOperationStatus.failed),
      ]);

      setState(() {
        _pendingOperations = results[0];
        _failedOperations = results[1];
        _isLoading = false;
      });
    } catch (e) {
      // Handle error silently
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Handles cancel sync button press
  void _handleCancelSync() async {
    final notifier = ref.read(syncStatusProvider.notifier);
    await notifier.stopSync();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Handles retry failed operations button press
  void _handleRetryFailed() async {
    final notifier = ref.read(syncStatusProvider.notifier);
    await notifier.triggerSync(force: true);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final syncStatus = ref.watch(syncStatusProvider);
    final theme = Theme.of(context);

    // Update animation based on sync state
    if (syncStatus.isSyncing) {
      if (!_rotationController.isAnimating) {
        _rotationController.repeat();
      }
    } else {
      _rotationController.stop();
    }

    return AlertDialog(
      title: Row(
        children: [
          // Animated sync icon
          if (syncStatus.isSyncing)
            RotationTransition(
              turns: _rotationController,
              child: Icon(
                Icons.sync,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            )
          else if (syncStatus.hasError)
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
              size: 24,
            )
          else if (syncStatus.pendingOperations > 0)
            Icon(
              Icons.cloud_upload,
              color: theme.colorScheme.secondary,
              size: 24,
            )
          else
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            ),
          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Text(
              _getTitle(syncStatus),
              style: theme.textTheme.titleLarge,
            ),
          ),

          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _loadOperations,
            tooltip: 'Refresh',
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sync progress section
            _buildProgressSection(context, syncStatus, theme),

            const SizedBox(height: 16),

            // Pending operations section
            if (_pendingOperations.isNotEmpty) ...[
              _buildOperationsSection(
                context,
                title: 'Pending Operations',
                operations: _pendingOperations,
                icon: Icons.pending_actions,
                color: theme.colorScheme.secondary,
                theme: theme,
              ),
              const SizedBox(height: 16),
            ],

            // Failed operations section
            if (_failedOperations.isNotEmpty) ...[
              _buildOperationsSection(
                context,
                title: 'Failed Operations',
                operations: _failedOperations,
                icon: Icons.error_outline,
                color: theme.colorScheme.error,
                theme: theme,
              ),
              const SizedBox(height: 16),
            ],

            // Empty state
            if (!_isLoading &&
                _pendingOperations.isEmpty &&
                _failedOperations.isEmpty &&
                !syncStatus.isSyncing)
              _buildEmptyState(context, theme),
          ],
        ),
      ),
      actions: [
        // Cancel sync button (only when syncing)
        if (syncStatus.isSyncing)
          TextButton.icon(
            onPressed: _handleCancelSync,
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Cancel Sync'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
          ),

        // Retry failed button (only if there are failed operations)
        if (_failedOperations.isNotEmpty && !syncStatus.isSyncing)
          TextButton.icon(
            onPressed: _handleRetryFailed,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry All'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),

        // Close button
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  /// Builds the progress section
  Widget _buildProgressSection(
    BuildContext context,
    SyncStatus syncStatus,
    ThemeData theme,
  ) {
    // Show progress bar when syncing
    if (syncStatus.isSyncing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: syncStatus.progress,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            valueColor:
                AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          const SizedBox(height: 8),

          // Progress percentage and phase
          Row(
            children: [
              Text(
                '${(syncStatus.progress * 100).toInt()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getPhaseLabel(syncStatus.phase),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          // Current operation
          if (syncStatus.currentOperation != null) ...[
            const SizedBox(height: 4),
            Text(
              syncStatus.currentOperation!,
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      );
    }

    // Show sync status when not syncing
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: syncStatus.hasError
            ? theme.colorScheme.errorContainer
            : syncStatus.pendingOperations > 0
                ? theme.colorScheme.secondaryContainer
                : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            syncStatus.hasError
                ? Icons.error_outline
                : syncStatus.pendingOperations > 0
                    ? Icons.cloud_upload
                    : Icons.check_circle,
            color: syncStatus.hasError
                ? theme.colorScheme.error
                : syncStatus.pendingOperations > 0
                    ? theme.colorScheme.onSecondaryContainer
                    : Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getStatusMessage(syncStatus),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: syncStatus.hasError
                    ? theme.colorScheme.onErrorContainer
                    : syncStatus.pendingOperations > 0
                        ? theme.colorScheme.onSecondaryContainer
                        : theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an operations section (pending or failed)
  Widget _buildOperationsSection(
    BuildContext context, {
    required String title,
    required List<SyncOperationEntity> operations,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              '$title (${operations.length})',
              style: theme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Operations list
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: operations.length > 5 ? 5 : operations.length,
            itemBuilder: (context, index) {
              final operation = operations[index];
              return _buildOperationTile(context, operation, theme);
            },
          ),
        ),

        // Show more indicator
        if (operations.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'And ${operations.length - 5} more...',
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  /// Builds a single operation tile
  Widget _buildOperationTile(
    BuildContext context,
    SyncOperationEntity operation,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: Icon(
          _getOperationIcon(operation.operation),
          color: _getOperationColor(operation, theme),
          size: 20,
        ),
        title: Text(
          operation.description,
          style: theme.textTheme.bodyMedium,
        ),
        subtitle: operation.errorMessage != null
            ? Text(
                operation.errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : Text(
                _getOperationTypeLabel(operation.operation),
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
        trailing: operation.status == SyncOperationStatus.failed
            ? Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
                size: 16,
              )
            : null,
      ),
    );
  }

  /// Builds empty state widget
  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'All synced!',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No pending or failed operations',
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns the dialog title based on sync status
  String _getTitle(SyncStatus syncStatus) {
    if (syncStatus.isSyncing) {
      return 'Syncing...';
    } else if (syncStatus.hasError) {
      return 'Sync Failed';
    } else if (syncStatus.pendingOperations > 0) {
      return 'Pending Sync';
    }
    return 'Sync Status';
  }

  /// Returns the label for sync phase
  String _getPhaseLabel(SyncPhase phase) {
    switch (phase) {
      case SyncPhase.upload:
        return 'Uploading changes';
      case SyncPhase.download:
        return 'Downloading changes';
      case SyncPhase.conflictResolution:
        return 'Resolving conflicts';
      case SyncPhase.finalization:
        return 'Finalizing';
      case SyncPhase.none:
        return 'Preparing';
    }
  }

  /// Returns the status message based on sync status
  String _getStatusMessage(SyncStatus syncStatus) {
    if (syncStatus.hasError) {
      return syncStatus.errorMessage ?? 'Sync encountered an error';
    } else if (syncStatus.pendingOperations > 0) {
      return '${syncStatus.pendingOperations} ${syncStatus.pendingOperations == 1 ? 'change' : 'changes'} waiting to sync';
    }
    return 'All data is up to date';
  }

  /// Returns the icon for operation type
  IconData _getOperationIcon(SyncOperationType operation) {
    switch (operation) {
      case SyncOperationType.create:
        return Icons.add_circle_outline;
      case SyncOperationType.update:
        return Icons.edit;
      case SyncOperationType.delete:
        return Icons.delete_outline;
    }
  }

  /// Returns the color for operation
  Color _getOperationColor(SyncOperationEntity operation, ThemeData theme) {
    if (operation.status == SyncOperationStatus.failed) {
      return theme.colorScheme.error;
    }
    switch (operation.operation) {
      case SyncOperationType.create:
        return Colors.green;
      case SyncOperationType.update:
        return theme.colorScheme.primary;
      case SyncOperationType.delete:
        return Colors.red;
    }
  }

  /// Returns the label for operation type
  String _getOperationTypeLabel(SyncOperationType operation) {
    switch (operation) {
      case SyncOperationType.create:
        return 'Create';
      case SyncOperationType.update:
        return 'Update';
      case SyncOperationType.delete:
        return 'Delete';
    }
  }
}
