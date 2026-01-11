import 'package:flutter/material.dart';
import '../../domain/models/sync_history_entry.dart';
import '../../domain/models/sync_status.dart';
import '../../domain/services/sync_history_service.dart';

/// User-facing sync history screen
///
/// Displays a simplified view of recent sync activity
/// for transparency and user confidence.
class SyncHistoryScreen extends StatefulWidget {
  /// History service to query for sync entries
  final SyncHistoryService historyService;

  /// Number of recent entries to show (default: 10)
  final int showRecentCount;

  const SyncHistoryScreen({
    super.key,
    required this.historyService,
    this.showRecentCount = 10,
  });

  @override
  State<SyncHistoryScreen> createState() => _SyncHistoryScreenState();
}

class _SyncHistoryScreenState extends State<SyncHistoryScreen> {
  late StreamSubscription<List<SyncHistoryEntry>> _subscription;
  List<SyncHistoryEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _entries = widget.historyService.getLatestEntries(widget.showRecentCount);
    _subscribeToUpdates();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _subscribeToUpdates() {
    _subscription = widget.historyService.entriesStream.listen(
      (entries) {
        if (mounted) {
          setState(() {
            _entries = entries.take(widget.showRecentCount).toList();
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = widget.historyService.getStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync History'),
      ),
      body: _entries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_sync_outlined,
                    size: 64,
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No sync activity yet',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your data syncs automatically when you\'re online',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Summary card
                _buildSummaryCard(context, stats),
                const Divider(height: 1),
                // Recent activity list
                Expanded(
                  child: ListView.builder(
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      return _SyncActivityTile(entry: entry);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, SyncHistoryStats stats) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sync Status',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatusIndicator(
                  label: 'Recent Syncs',
                  count: stats.totalSyncs,
                  icon: Icons.sync,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatusIndicator(
                  label: 'Successful',
                  count: stats.successfulSyncs,
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatusIndicator(
                  label: 'Failed',
                  count: stats.failedSyncs,
                  icon: Icons.error_outline,
                  color: stats.failedSyncs > 0 ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
          if (stats.successRate != null && stats.totalSyncs > 0) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: stats.successRate,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                stats.successRate! >= 0.9
                    ? Colors.green
                    : stats.successRate! >= 0.7
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Success rate: ${(stats.successRate! * 100).toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SyncActivityTile extends StatelessWidget {
  final SyncHistoryEntry entry;

  const _SyncActivityTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: _buildLeadingIcon(context),
      title: Text(
        _getTitle(),
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(_getSubtitle()),
      trailing: Text(
        _formatTimestamp(entry.startedAt),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context) {
    final theme = Theme.of(context);

    IconData icon;
    Color color;

    switch (entry.status) {
      case SyncOperationStatus.success:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case SyncOperationStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
      case SyncOperationStatus.syncing:
        icon = Icons.sync;
        color = Colors.blue;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
    }

    return Icon(icon, color: color, size: 32);
  }

  String _getTitle() {
    if (entry.isManual) {
      return 'Manual sync';
    } else {
      return 'Auto sync';
    }
  }

  String _getSubtitle() {
    final buffer = StringBuffer();

    switch (entry.status) {
      case SyncOperationStatus.success:
        buffer.write('${entry.successCount} items synced');
        if (entry.failureCount > 0) {
          buffer.write(', ${entry.failureCount} failed');
        }
        break;
      case SyncOperationStatus.failed:
        if (entry.error != null) {
          buffer.write(entry.error!.userMessage);
        } else {
          buffer.write('${entry.failureCount} items failed to sync');
        }
        break;
      case SyncOperationStatus.syncing:
        buffer.write('Syncing in progress...');
        break;
      default:
        buffer.write('Unknown status');
    }

    if (entry.connectionType != null) {
      buffer.write(' via ${entry.connectionType}');
    }

    return buffer.toString();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
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

class _StatusIndicator extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  const _StatusIndicator({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
