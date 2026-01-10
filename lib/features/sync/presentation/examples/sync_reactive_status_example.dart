import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/sync_status_icon.dart';
import '../widgets/sync_status_badge.dart';
import '../providers/sync_providers.dart';

/// Example demonstrating real-time reactive sync status updates
///
/// This widget shows how multiple components can consume sync state
/// and update immediately when sync state changes using Riverpod's
/// reactive state management.
///
/// Key Features:
/// - All status indicators update immediately when sync state changes
/// - Multiple components can observe the same state independently
/// - No stale status indicators - state flows from single source of truth
/// - Efficient rebuilds - only components watching changed state rebuild
class SyncReactiveStatusExample extends ConsumerWidget {
  const SyncReactiveStatusExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reactive Sync Status'),
        actions: const [
          // Status indicator in app bar - updates reactively
          _AppBarStatusIndicator(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          // Section 1: Status cards showing different aspects
          SectionTitle('Status Overview'),
          SizedBox(height: 8),
          _StatusOverviewCard(),
          SizedBox(height: 24),

          // Section 2: Multiple independent indicators
          SectionTitle('Multiple Status Indicators'),
          SizedBox(height: 8),
          _MultipleIndicatorsRow(),
          SizedBox(height: 24),

          // Section 3: Queue information
          SectionTitle('Queue Information'),
          SizedBox(height: 8),
          _QueueInfoCard(),
          SizedBox(height: 24),

          // Section 4: Detailed status with timestamps
          SectionTitle('Detailed Status'),
          SizedBox(height: 8),
          _DetailedStatusCard(),
          SizedBox(height: 24),

          // Section 5: Action buttons to test reactivity
          SectionTitle('Test Reactivity'),
          SizedBox(height: 8),
          _ActionButtons(),
        ],
      ),
    );
  }
}

/// Section title widget
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }
}

/// Status indicator in app bar
///
/// Demonstrates that status indicators can be placed anywhere
/// and will update immediately when sync state changes.
class _AppBarStatusIndicator extends ConsumerWidget {
  const _AppBarStatusIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(globalSyncOperationStatusProvider);
    final queueSize = ref.watch(globalQueueSizeProvider);

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          SyncOperationStatusIcon(
            status: status,
            size: 20,
          ),
          if (queueSize > 0) ...[
            const SizedBox(width: 4),
            SyncOperationStatusBadge(
              count: queueSize,
              size: 16,
            ),
          ],
        ],
      ),
    );
  }
}

/// Status overview card
///
/// Shows main sync status with icon and description.
/// Updates immediately when sync status changes.
class _StatusOverviewCard extends ConsumerWidget {
  const _StatusOverviewCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(globalSyncOperationStatusProvider);
    final statusText = ref.watch(globalSyncOperationStatusTextProvider);

    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SyncOperationStatusIcon(
              status: status,
              size: 48,
              withBackground: true,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.displayName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Multiple independent indicators row
///
/// Demonstrates that multiple components can watch the same state
/// and all will update immediately when state changes.
class _MultipleIndicatorsRow extends ConsumerWidget {
  const _MultipleIndicatorsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(globalSyncOperationStatusProvider);
    final queueSize = ref.watch(globalQueueSizeProvider);
    final isSyncing = ref.watch(isGloballySyncingProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All indicators update instantly',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Indicator 1: Icon only
                Column(
                  children: [
                    SyncOperationStatusIcon(status: status),
                    const SizedBox(height: 8),
                    const Text('Icon'),
                  ],
                ),
                // Indicator 2: Icon with badge
                Column(
                  children: [
                    SyncOperationStatusBadge(
                      count: queueSize,
                      child: SyncOperationStatusIcon(status: status),
                    ),
                    const SizedBox(height: 8),
                    const Text('Badge'),
                  ],
                ),
                // Indicator 3: Text status
                Column(
                  children: [
                    Text(
                      isSyncing ? '• Syncing' : '• Idle',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Text'),
                  ],
                ),
                // Indicator 4: Small indicator
                Column(
                  children: [
                    SyncOperationStatusIndicator(status: status),
                    const SizedBox(height: 8),
                    const Text('Dot'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Queue information card
///
/// Shows current queue size and pending operations.
/// Updates immediately when operations are added/removed.
class _QueueInfoCard extends ConsumerWidget {
  const _QueueInfoCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueSize = ref.watch(globalQueueSizeProvider);
    final hasPending = ref.watch(hasGlobalPendingOperationsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasPending ? Icons.pending : Icons.check_circle,
                  color: hasPending
                      ? Theme.of(context).colorScheme.error
                      : const Color(0xFF4CAF50),
                ),
                const SizedBox(width: 8),
                Text(
                  'Queue Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pending Operations:'),
                Text(
                  '$queueSize',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: queueSize > 0
                            ? Theme.of(context).colorScheme.error
                            : const Color(0xFF4CAF50),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status:'),
                Text(
                  hasPending ? 'Has Pending Items' : 'Queue Empty',
                  style: TextStyle(
                    color: hasPending
                        ? Theme.of(context).colorScheme.error
                        : const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Detailed status card with timestamps
///
/// Shows comprehensive sync information including timing and success rates.
/// Updates immediately when any aspect of sync state changes.
class _DetailedStatusCard extends ConsumerWidget {
  const _DetailedStatusCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(syncStatusDetailsProvider);
    final lastSyncTime = ref.watch(lastSuccessfulSyncTimeProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              details,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
            if (lastSyncTime != null) ...[
              const SizedBox(height: 12),
              Text(
                'Last successful sync: ${_formatTime(lastSyncTime)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

/// Action buttons to test reactivity
///
/// Provides buttons to trigger sync operations and verify
/// that all indicators update immediately.
class _ActionButtons extends ConsumerWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSyncing = ref.watch(isGloballySyncingProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Test Immediate Updates',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: isSyncing
                  ? null
                  : () {
                      // TODO: Trigger sync operation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Sync triggered - watch all indicators update'),
                        ),
                      );
                    },
              icon: const Icon(Icons.sync),
              label: const Text('Trigger Sync'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Add operations to queue
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Operations added - watch queue count update'),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add to Queue'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                ref.read(syncStateNotifierProvider.notifier).refresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('State refreshed'),
                  ),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh State'),
            ),
          ],
        ),
      ),
    );
  }
}
