import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import 'package:soloadventurer/features/offline/domain/entities/sync_operation.dart';
import 'package:soloadventurer/features/offline/domain/repositories/sync_queue_repository.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database_service.dart';
import 'package:soloadventurer/features/offline/presentation/providers/sync_settings_provider.dart';
import 'package:soloadventurer/features/offline/presentation/providers/sync_status_provider.dart';
import 'package:soloadventurer/features/offline/presentation/providers/connectivity_provider.dart';

/// Sync settings screen for managing sync preferences and viewing sync status
///
/// This screen provides:
/// - Toggle sync on/off
/// - Force sync now button
/// - Sync only on WiFi option
/// - Clear local data option
/// - View pending operations list
/// - Sync history and statistics
///
/// Example usage:
/// ```dart
/// Navigator.pushNamed(context, SyncSettingsScreen.routeName);
/// ```
class SyncSettingsScreen extends ConsumerStatefulWidget {
  /// Route name for navigation
  static const routeName = '/settings/sync';

  /// Creates a new [SyncSettingsScreen]
  const SyncSettingsScreen({super.key});

  @override
  ConsumerState<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends ConsumerState<SyncSettingsScreen> {
  /// List of pending operations
  List<SyncOperationEntity> _pendingOperations = [];

  /// Loading state for operations
  bool _isLoadingOperations = false;

  @override
  void initState() {
    super.initState();
    _loadPendingOperations();
  }

  /// Loads pending operations from sync queue
  Future<void> _loadPendingOperations() async {
    setState(() {
      _isLoadingOperations = true;
    });

    try {
      final repository = getIt<SyncQueueRepository>();
      final operations = await repository.getPendingOperations(limit: 10);

      if (mounted) {
        setState(() {
          _pendingOperations = operations;
          _isLoadingOperations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingOperations = false;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading operations: $e')),
        );
      }
    }
  }

  /// Handles force sync button press
  Future<void> _handleForceSync() async {
    final notifier = ref.read(syncStatusProvider.notifier);
    final isConnected = ref.read(isConnectedProvider);

    if (!isConnected) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot sync while offline'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      await notifier.triggerSync(force: true);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sync started'),
          duration: Duration(seconds: 2),
        ),
      );

      // Reload operations after a delay
      Future.delayed(const Duration(seconds: 2), _loadPendingOperations);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start sync: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Handles clear local data
  Future<void> _handleClearLocalData() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Local Data?'),
        content: const Text(
          'This will delete all local data including trips, journals, and '
          'sync history. Make sure you\'re synced before clearing.\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('CLEAR DATA'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final dbService = getIt<DatabaseService>();
      await dbService.reset();

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Local data cleared successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      // Reload operations
      _loadPendingOperations();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to clear data: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Shows sync history dialog
  void _showSyncHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync History'),
        content: const Text(
          'Sync history tracking will be implemented in a future update.\n\n'
          'For now, you can view pending operations below.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final syncSettings = ref.watch(syncSettingsProvider);
    final syncStatus = ref.watch(syncStatusProvider);
    final isConnected = ref.watch(isConnectedProvider);
    final connectionType = ref.watch(connectionTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Settings'),
      ),
      body: ListView(
        children: [
          // Sync Status Section
          _buildSection(
            context,
            'Sync Status',
            [
              ListTile(
                leading: Icon(
                  isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: isConnected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
                title: Text(
                  isConnected ? 'Connected' : 'Offline',
                  style: theme.textTheme.titleSmall,
                ),
                subtitle: Text(
                  isConnected
                      ? 'Connected via ${connectionType.name}'
                      : 'No internet connection',
                ),
              ),
              ListTile(
                leading: Icon(
                  syncStatus.isSyncing
                      ? Icons.sync
                      : syncStatus.hasError
                          ? Icons.error_outline
                          : Icons.check_circle,
                  color: syncStatus.isSyncing
                      ? theme.colorScheme.primary
                      : syncStatus.hasError
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                ),
                title: Text(
                  _getSyncStatusText(syncStatus),
                  style: theme.textTheme.titleSmall,
                ),
                subtitle: Text(
                  _getSyncStatusSubtitle(syncStatus),
                ),
                trailing: syncStatus.isSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              if (syncStatus.lastSyncTime != null)
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Last Sync'),
                  subtitle: Text(_formatLastSyncTime(syncStatus.lastSyncTime!)),
                ),
            ],
          ),

          // Sync Settings Section
          _buildSection(
            context,
            'Sync Settings',
            [
              SwitchListTile(
                title: const Text('Enable Sync'),
                subtitle: Text(
                  syncSettings.syncEnabled
                      ? 'Changes will sync automatically'
                      : 'Sync is disabled - changes will only be saved locally',
                ),
                value: syncSettings.syncEnabled,
                onChanged: (value) async {
                  final notifier = ref.read(syncSettingsProvider.notifier);
                  await notifier.setSyncEnabled(value);
                },
              ),
              SwitchListTile(
                title: const Text('Sync Only on WiFi'),
                subtitle: Text(
                  syncSettings.syncOnlyOnWifi
                      ? 'Will only sync when connected to WiFi'
                      : 'Will sync on any connection (WiFi or cellular)',
                ),
                value: syncSettings.syncOnlyOnWifi,
                onChanged: (value) async {
                  final notifier = ref.read(syncSettingsProvider.notifier);
                  await notifier.setSyncOnlyOnWifi(value);
                },
              ),
            ],
          ),

          // Manual Sync Section
          _buildSection(
            context,
            'Manual Sync',
            [
              ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('Sync Now'),
                subtitle: const Text('Force sync all changes'),
                trailing: FilledButton(
                  onPressed: isConnected && syncStatus.syncEnabled
                      ? _handleForceSync
                      : null,
                  child: const Text('SYNC'),
                ),
              ),
              if (!isConnected)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Cannot sync while offline',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              if (!syncSettings.syncEnabled)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Sync is disabled',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),

          // Data Management Section
          _buildSection(
            context,
            'Data Management',
            [
              ListTile(
                leading: Icon(
                  Icons.delete_sweep,
                  color: theme.colorScheme.error,
                ),
                title: const Text('Clear Local Data'),
                subtitle: const Text(
                  'Delete all local data (trips, journals, etc.)',
                ),
                textColor: theme.colorScheme.error,
                onTap: _handleClearLocalData,
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Sync History'),
                subtitle: const Text('View recent sync activity'),
                onTap: _showSyncHistory,
              ),
            ],
          ),

          // Pending Operations Section
          if (syncStatus.pendingOperations > 0 || _pendingOperations.isNotEmpty)
            _buildSection(
              context,
              'Pending Operations (${syncStatus.pendingOperations})',
              [
                if (_isLoadingOperations)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_pendingOperations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('No pending operations')),
                  )
                else
                  ...List<Widget>.generate(
                    _pendingOperations.length,
                    (index) {
                      final op = _pendingOperations[index];
                      return _buildOperationTile(context, op);
                    },
                  ),
                if (syncStatus.pendingOperations > _pendingOperations.length)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'And ${syncStatus.pendingOperations - _pendingOperations.length} more...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Refresh'),
                  subtitle: const Text('Reload pending operations'),
                  onTap: _loadPendingOperations,
                ),
              ],
            ),

          // Info Section
          _buildSection(
            context,
            'About Sync',
            [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('How Sync Works'),
                subtitle: const Text(
                  'Changes are saved locally first, then synced to the cloud '
                  'when you\'re online. You can view and edit all your data '
                  'even without internet.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a section with a header and children
  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...children,
      ],
    );
  }

  /// Builds a tile for a sync operation
  Widget _buildOperationTile(
    BuildContext context,
    SyncOperationEntity operation,
  ) {
    final theme = Theme.of(context);

    IconData icon;
    String operationText;

    switch (operation.operation) {
      case SyncOperationType.create:
        icon = Icons.add;
        operationText = 'Create';
        break;
      case SyncOperationType.update:
        icon = Icons.edit;
        operationText = 'Update';
        break;
      case SyncOperationType.delete:
        icon = Icons.delete;
        operationText = 'Delete';
        break;
    }

    return ListTile(
      leading: Icon(icon),
      title: Text('$operationText ${operation.entityType}'),
      subtitle: Text(_formatOperationAge(operation.createdAt)),
      trailing: _buildPriorityBadge(context, operation.priority),
    );
  }

  /// Builds a badge for operation priority
  Widget _buildPriorityBadge(
    BuildContext context,
    SyncPriority priority,
  ) {
    final theme = Theme.of(context);

    Color color;
    String text;

    switch (priority) {
      case SyncPriority.high:
        color = theme.colorScheme.error;
        text = 'HIGH';
        break;
      case SyncPriority.normal:
        color = theme.colorScheme.primary;
        text = 'NORMAL';
        break;
      case SyncPriority.low:
        color = theme.colorScheme.surfaceContainerHighest;
        text = 'LOW';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Gets sync status text
  String _getSyncStatusText(SyncStatus status) {
    if (status.isSyncing) {
      return 'Syncing...';
    } else if (status.hasError) {
      return 'Sync Error';
    } else if (status.pendingOperations > 0) {
      return 'Pending Sync';
    } else {
      return 'Synced';
    }
  }

  /// Gets sync status subtitle
  String _getSyncStatusSubtitle(SyncStatus status) {
    if (status.isSyncing) {
      return '${(status.progress * 100).toInt()}% complete';
    } else if (status.hasError) {
      return status.errorMessage ?? 'Unknown error';
    } else if (status.pendingOperations > 0) {
      return '${status.pendingOperations} changes waiting to sync';
    } else {
      return 'All data up to date';
    }
  }

  /// Formats last sync time
  String _formatLastSyncTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  /// Formats operation age
  String _formatOperationAge(DateTime time) {
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
