import 'package:flutter/material.dart';
import '../../domain/models/sync_history_entry.dart';
import '../../domain/models/sync_status.dart';
import '../../domain/services/sync_history_service.dart';

/// Developer-accessible sync history viewer
///
/// Displays a log of recent sync operations with timestamps,
/// success/failure status, and detailed information for debugging.
class SyncHistoryViewer extends StatefulWidget {
  /// History service to query for sync entries
  final SyncHistoryService historyService;

  /// Whether to show auto-refresh
  final bool autoRefresh;

  /// Refresh interval for auto-refresh (default: 5 seconds)
  final Duration refreshInterval;

  const SyncHistoryViewer({
    super.key,
    required this.historyService,
    this.autoRefresh = true,
    this.refreshInterval = const Duration(seconds: 5),
  });

  @override
  State<SyncHistoryViewer> createState() => _SyncHistoryViewerState();
}

class _SyncHistoryViewerState extends State<SyncHistoryViewer> {
  late StreamSubscription<List<SyncHistoryEntry>> _subscription;
  List<SyncHistoryEntry> _entries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _subscribeToUpdates();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _loadEntries() {
    setState(() {
      _isLoading = true;
      _error = null;
      _entries = widget.historyService.entries;
      _isLoading = false;
    });
  }

  void _subscribeToUpdates() {
    if (widget.autoRefresh) {
      _subscription = widget.historyService.entriesStream.listen(
        (entries) {
          if (mounted) {
            setState(() {
              _entries = entries;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _error = error.toString();
            });
          }
        },
      );
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      setState(() {
        _entries = widget.historyService.entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all sync history?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final result = await widget.historyService.clearHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.isSuccess
                  ? 'History cleared (${result.affectedCount} entries)'
                  : 'Failed to clear history: ${result.error}',
            ),
            backgroundColor: result.isSuccess ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportHistory() async {
    try {
      final json = widget.historyService.exportToJson();
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Export History'),
            content: SingleChildScrollView(
              child: SelectableText(json),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEntryDetails(SyncHistoryEntry entry) {
    showDialog(
      context: context,
      builder: (context) => _SyncHistoryEntryDialog(entry: entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportHistory,
            tooltip: 'Export JSON',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearHistory,
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading history',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : _entries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: theme.colorScheme.surfaceContainerHighest,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No sync history yet',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sync operations will appear here',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Statistics header
                        _buildStatisticsHeader(theme),
                        const Divider(height: 1),
                        // History list
                        Expanded(
                          child: ListView.builder(
                            itemCount: _entries.length,
                            itemBuilder: (context, index) {
                              final entry = _entries[index];
                              return _SyncHistoryEntryTile(
                                entry: entry,
                                onTap: () => _showEntryDetails(entry),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildStatisticsHeader(ThemeData theme) {
    final stats = widget.historyService.getStats();

    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _StatItem(
                label: 'Total',
                value: stats.totalSyncs.toString(),
                icon: Icons.sync,
                color: Colors.blue,
              ),
              _StatItem(
                label: 'Success',
                value: stats.successfulSyncs.toString(),
                icon: Icons.check_circle,
                color: Colors.green,
              ),
              _StatItem(
                label: 'Failed',
                value: stats.failedSyncs.toString(),
                icon: Icons.error,
                color: Colors.red,
              ),
              _StatItem(
                label: 'Success Rate',
                value: stats.successRate != null
                    ? '${(stats.successRate! * 100).toStringAsFixed(1)}%'
                    : 'N/A',
                icon: Icons.show_chart,
                color: Colors.purple,
              ),
              _StatItem(
                label: 'Manual',
                value: stats.manualSyncs.toString(),
                icon: Icons.touch_app,
                color: Colors.orange,
              ),
              _StatItem(
                label: 'Auto',
                value: stats.automaticSyncs.toString(),
                icon: Icons.autorenew,
                color: Colors.teal,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SyncHistoryEntryTile extends StatelessWidget {
  final SyncHistoryEntry entry;
  final VoidCallback onTap;

  const _SyncHistoryEntryTile({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Status icon
            _buildStatusIcon(context),
            const SizedBox(width: 12),
            // Entry details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getEntryTitle(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getEntrySubtitle(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Timestamp
            Text(
              _formatTimestamp(entry.startedAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
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

    return Icon(icon, color: color, size: 28);
  }

  String _getEntryTitle() {
    if (entry.isManual) {
      return 'Manual Sync';
    } else {
      return 'Auto Sync';
    }
  }

  String _getEntrySubtitle() {
    final buffer = StringBuffer();

    if (entry.status == SyncOperationStatus.success) {
      buffer.write('${entry.successCount} succeeded');
      if (entry.failureCount > 0) {
        buffer.write(', ${entry.failureCount} failed');
      }
    } else if (entry.status == SyncOperationStatus.failed) {
      buffer.write('${entry.failureCount} failed');
      if (entry.error != null) {
        buffer.write(' - ${entry.error!.userMessage}');
      }
    } else {
      buffer.write('In progress...');
    }

    if (entry.connectionType != null) {
      buffer.write(' • ${entry.connectionType}');
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
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class _SyncHistoryEntryDialog extends StatelessWidget {
  final SyncHistoryEntry entry;

  const _SyncHistoryEntryDialog({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Sync Entry ${entry.id}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _DetailRow(
              label: 'Status',
              value: entry.status.name.toUpperCase(),
              valueColor: _getStatusColor(entry.status),
            ),
            const Divider(),
            _DetailRow(
              label: 'Type',
              value: entry.isManual ? 'Manual' : 'Automatic',
            ),
            _DetailRow(
              label: 'Started',
              value: entry.startedAt.toIso8601String(),
            ),
            if (entry.completedAt != null)
              _DetailRow(
                label: 'Completed',
                value: entry.completedAt!.toIso8601String(),
              ),
            if (entry.duration != null)
              _DetailRow(
                label: 'Duration',
                value: entry.duration!.inMilliseconds > 1000
                    ? '${(entry.duration!.inMilliseconds / 1000).toStringAsFixed(2)}s'
                    : '${entry.duration!.inMilliseconds}ms',
              ),
            const Divider(),
            _DetailRow(
              label: 'Total Operations',
              value: entry.totalCount.toString(),
            ),
            _DetailRow(
              label: 'Successful',
              value: entry.successCount.toString(),
              valueColor: Colors.green,
            ),
            _DetailRow(
              label: 'Failed',
              value: entry.failureCount.toString(),
              valueColor: entry.failureCount > 0 ? Colors.red : null,
            ),
            if (entry.successRate != null)
              _DetailRow(
                label: 'Success Rate',
                value: '${(entry.successRate! * 100).toStringAsFixed(1)}%',
              ),
            if (entry.connectionType != null)
              _DetailRow(
                label: 'Connection',
                value: entry.connectionType!,
              ),
            if (entry.error != null) ...[
              const Divider(),
              Text(
                'Error',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.error!.userMessage,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                entry.error!.technicalMessage,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Color _getStatusColor(SyncOperationStatus status) {
    switch (status) {
      case SyncOperationStatus.success:
        return Colors.green;
      case SyncOperationStatus.failed:
        return Colors.red;
      case SyncOperationStatus.syncing:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
