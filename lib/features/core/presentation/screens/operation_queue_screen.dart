import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/operation_queue_provider.dart';
import '../widgets/operation_list_item.dart';

/// Screen that displays all pending and failed operations in the queue
///
/// This screen provides visibility into the operation queue, allowing users to:
/// - View pending operations waiting to be processed
/// - View failed operations that exceeded max retry attempts
/// - Manually retry failed operations
/// - Remove specific failed operations
/// - Clear all failed operations
/// - Refresh the queue state
class OperationQueueScreen extends ConsumerStatefulWidget {
  /// Creates a new [OperationQueueScreen]
  const OperationQueueScreen({super.key});

  @override
  ConsumerState<OperationQueueScreen> createState() => _OperationQueueScreenState();
}

class _OperationQueueScreenState extends ConsumerState<OperationQueueScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(operationQueueNotifierProvider.notifier).refreshState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final queueState = ref.watch(operationQueueNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Operation Queue'),
        actions: [
          // Operation count badges
          if (queueState.pendingCount > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Chip(
                  label: Text(
                    '${queueState.pendingCount} pending',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ),
          if (queueState.failedCount > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Chip(
                  label: Text(
                    '${queueState.failedCount} failed',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: colorScheme.error,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(operationQueueNotifierProvider.notifier).refreshState();
        },
        child: queueState.pendingCount == 0 && queueState.failedCount == 0
            ? _buildEmptyState(context)
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Processing Status Banner
                    if (queueState.isProcessing) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Colors.blue.withOpacity(0.1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Processing operations...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Pending Operations Section
                    if (queueState.pendingCount > 0) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.pending,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Pending Operations (${queueState.pendingCount})',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...queueState.pendingOperations.map((operation) => OperationListItem(
                            operation: operation,
                            isFailed: false,
                          )),
                      const SizedBox(height: 16),
                    ],

                    // Failed Operations Section
                    if (queueState.failedCount > 0) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Failed Operations (${queueState.failedCount})',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            if (queueState.failedCount > 1)
                              TextButton.icon(
                                onPressed: () => _showClearAllDialog(context),
                                icon: const Icon(Icons.delete_sweep, size: 18),
                                label: const Text('Clear All'),
                                style: TextButton.styleFrom(
                                  foregroundColor: colorScheme.error,
                                ),
                              ),
                          ],
                        ),
                      ),
                      ...queueState.failedOperations.map((operation) => OperationListItem(
                            operation: operation,
                            isFailed: true,
                            onRetry: () => _retryOperation(operation.id),
                            onRemove: () => _removeOperation(operation.id),
                          )),
                      const SizedBox(height: 16),
                    ],

                    // Bottom padding
                    const SizedBox(height: 80),
                  ],
                ),
              ),
      ),
      floatingActionButton: queueState.isProcessing
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                await ref.read(operationQueueNotifierProvider.notifier).processQueue();
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Process Queue'),
            ),
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'All Clear!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No operations are currently pending or failed.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your changes have been synced successfully.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Retry a specific failed operation
  Future<void> _retryOperation(String operationId) async {
    try {
      await ref.read(operationQueueNotifierProvider.notifier).retryOperation(operationId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Operation queued for retry'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to retry operation: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Remove a specific failed operation
  Future<void> _removeOperation(String operationId) async {
    final confirmed = await _showConfirmDialog(
      context,
      title: 'Remove Operation',
      content: 'Are you sure you want to remove this operation? This action cannot be undone.',
      confirmText: 'Remove',
      isDestructive: true,
    );

    if (confirmed == true) {
      try {
        await ref.read(operationQueueNotifierProvider.notifier).removeFailedOperation(operationId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Operation removed'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove operation: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  /// Show dialog to clear all failed operations
  Future<void> _showClearAllDialog(BuildContext context) async {
    final confirmed = await _showConfirmDialog(
      context,
      title: 'Clear All Failed Operations',
      content: 'Are you sure you want to clear all ${ref.read(operationQueueNotifierProvider).failedCount} failed operations? This action cannot be undone.',
      confirmText: 'Clear All',
      isDestructive: true,
    );

    if (confirmed == true) {
      try {
        await ref.read(operationQueueNotifierProvider.notifier).clearFailedOperations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All failed operations cleared'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to clear operations: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  /// Show confirmation dialog
  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmText,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? colorScheme.error : colorScheme.primary,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
