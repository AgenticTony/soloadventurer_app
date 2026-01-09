import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/core/domain/services/connectivity_service.dart';
import 'package:soloadventurer/features/journal/data/datasources/journal_local_data_source.dart';
import 'package:soloadventurer/features/journal/data/datasources/journal_remote_data_source.dart';
import 'package:soloadventurer/features/journal/data/datasources/tag_local_data_source.dart';
import 'package:soloadventurer/features/journal/data/datasources/tag_remote_data_source.dart';
import 'package:soloadventurer/features/journal/data/datasources/trip_local_data_source.dart';
import 'package:soloadventurer/features/journal/data/datasources/trip_remote_data_source.dart';
import 'package:soloadventurer/features/journal/data/services/sync_service_impl.dart';
import 'package:soloadventurer/features/journal/domain/services/sync_service.dart';

part 'sync_service_example.g.dart';

/// Provider for the sync service
///
/// This should be added to your dependency injection setup
@riverpod
SyncService syncService(SyncServiceRef ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);

  // Get data source implementations from your providers
  // These should already be defined in your app
  final journalLocal = ref.watch(journalLocalDataSourceProvider);
  final journalRemote = ref.watch(journalRemoteDataSourceProvider);
  final tripLocal = ref.watch(tripLocalDataSourceProvider);
  final tripRemote = ref.watch(tripRemoteDataSourceProvider);
  final tagLocal = ref.watch(tagLocalDataSourceProvider);
  final tagRemote = ref.watch(tagRemoteDataSourceProvider);

  final service = SyncServiceImpl(
    journalLocalDataSource: journalLocal,
    journalRemoteDataSource: journalRemote,
    tripLocalDataSource: tripLocal,
    tripRemoteDataSource: tripRemote,
    tagLocalDataSource: tagLocal,
    tagRemoteDataSource: tagRemote,
    connectivityService: connectivityService,
  );

  ref.onDispose(() => service.dispose());

  return service;
}

/// Provider for sync service state
@riverpod
class SyncServiceNotifier extends _$SyncServiceNotifier {
  @override
  SyncState build() {
    final syncService = ref.watch(syncServiceProvider);

    // Listen to progress stream
    syncService.progressStream.listen((progress) {
      state = SyncState(
        isSyncing: syncService.isSyncing,
        progress: progress,
        lastSyncTime: syncService.lastSyncTime,
        statistics: syncService.getStatistics(),
      );
    });

    return SyncState(
      isSyncing: false,
      progress: const SyncProgress(totalItems: 0),
      lastSyncTime: syncService.lastSyncTime,
      statistics: syncService.getStatistics(),
    );
  }

  Future<void> performFullSync() async {
    final syncService = ref.read(syncServiceProvider);

    if (syncService.isSyncing) {
      return; // Already syncing
    }

    await syncService.syncAll();
  }

  Future<void> performQuickSync() async {
    final syncService = ref.read(syncServiceProvider);

    if (syncService.isSyncing) {
      return;
    }

    await syncService.syncPending();
  }

  Future<void> uploadOnly() async {
    final syncService = ref.read(syncServiceProvider);
    await syncService.uploadChanges();
  }

  Future<void> downloadOnly() async {
    final syncService = ref.read(syncServiceProvider);
    await syncService.downloadChanges();
  }

  Future<void> cancelCurrentSync() async {
    final syncService = ref.read(syncServiceProvider);
    await syncService.cancelSync();
  }
}

/// State for sync operations
class SyncState {
  final bool isSyncing;
  final SyncProgress progress;
  final DateTime? lastSyncTime;
  final SyncStatistics statistics;

  const SyncState({
    required this.isSyncing,
    required this.progress,
    this.lastSyncTime,
    required this.statistics,
  });

  double get progressValue => progress.progress;

  String get statusText {
    if (!isSyncing) {
      return lastSyncTime != null
          ? 'Last synced: ${_formatTime(lastSyncTime!)}'
          : 'Never synced';
    }

    final currentOp = progress.currentOperation;
    if (currentOp != null) {
      return 'Syncing ${_formatOperationType(currentOp)}...';
    }
    return 'Syncing...';
  }

  String _formatOperationType(SyncOperationType type) {
    switch (type) {
      case SyncOperationType.entries:
        return 'entries';
      case SyncOperationType.media:
        return 'media';
      case SyncOperationType.trips:
        return 'trips';
      case SyncOperationType.tags:
        return 'tags';
      case SyncOperationType.full:
        return 'data';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

/// Example screen showing sync integration
class SyncExampleScreen extends ConsumerWidget {
  const SyncExampleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncServiceNotifierProvider);
    final syncService = ref.read(syncServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Example'),
      ),
      body: Column(
        children: [
          // Sync Status Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        syncState.isSyncing
                            ? Icons.sync
                            : Icons.cloud_done,
                        color: syncState.isSyncing
                            ? Colors.blue
                            : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          syncState.statusText,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  if (syncState.isSyncing) ...[
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: syncState.progressValue,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(syncState.progressValue * 100).toStringAsFixed(1)}% '
                      '(${syncState.progress.syncedItems}/${syncState.progress.totalItems})',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildStatistics(context, syncState.statistics),
                ],
              ),
            ),
          ),

          // Sync Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: syncState.isSyncing
                      ? null
                      : () => ref
                          .read(syncServiceNotifierProvider.notifier)
                          .performFullSync(),
                  icon: const Icon(Icons.sync),
                  label: const Text('Full Sync'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: syncState.isSyncing
                      ? null
                      : () => ref
                          .read(syncServiceNotifierProvider.notifier)
                          .performQuickSync(),
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Quick Sync (Pending Only)'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: syncState.isSyncing
                            ? null
                            : () => ref
                                .read(syncServiceNotifierProvider.notifier)
                                .uploadOnly(),
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Upload'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: syncState.isSyncing
                            ? null
                            : () => ref
                                .read(syncServiceNotifierProvider.notifier)
                                .downloadOnly(),
                        icon: const Icon(Icons.cloud_download),
                        label: const Text('Download'),
                      ),
                    ),
                  ],
                ),
                if (syncState.isSyncing)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: OutlinedButton.icon(
                      onPressed: () => ref
                          .read(syncServiceNotifierProvider.notifier)
                          .cancelCurrentSync(),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel Sync'),
                    ),
                  ),
              ],
            ),
          ),

          // Conflicts Section
          Expanded(
            child: StreamBuilder<SyncConflict>(
              stream: syncService.conflictStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text('No conflicts'),
                  );
                }

                final conflict = snapshot.data!;
                return Card(
                  margin: const EdgeInsets.all(16),
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.orange),
                    title: Text('Conflict: ${conflict.entityType}'),
                    subtitle: Text(
                      'Local: ${conflict.localUpdatedAt}\n'
                      'Remote: ${conflict.remoteUpdatedAt}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.open_in_full),
                      onPressed: () {
                        _showConflictDialog(context, conflict, ref);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(BuildContext context, SyncStatistics stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Text('Total syncs: ${stats.totalSyncs}'),
        Text('Success rate: ${(stats.successRate * 100).toStringAsFixed(1)}%'),
        Text('Items uploaded: ${stats.totalUploaded}'),
        Text('Items downloaded: ${stats.totalDownloaded}'),
        Text('Conflicts resolved: ${stats.totalConflictsResolved}'),
      ],
    );
  }

  void _showConflictDialog(
    BuildContext context,
    SyncConflict conflict,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Conflict'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Entity: ${conflict.entityType} (${conflict.entityId})'),
            const SizedBox(height: 16),
            const Text('Choose resolution strategy:'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              final syncService = ref.read(syncServiceProvider);
              syncService.resolveConflict(
                conflict,
                ConflictResolutionStrategy.localWins,
              );
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.phone_android),
            label: const Text('Keep Local'),
          ),
          TextButton.icon(
            onPressed: () {
              final syncService = ref.read(syncServiceProvider);
              syncService.resolveConflict(
                conflict,
                ConflictResolutionStrategy.remoteWins,
              );
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.cloud),
            label: const Text('Keep Remote'),
          ),
          TextButton.icon(
            onPressed: () {
              final syncService = ref.read(syncServiceProvider);
              syncService.resolveConflict(
                conflict,
                ConflictResolutionStrategy.mostRecent,
              );
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.schedule),
            label: const Text('Most Recent'),
          ),
        ],
      ),
    );
  }
}

/// Example of auto-sync on connectivity changes
class AutoSyncExample extends ConsumerStatefulWidget {
  const AutoSyncExample({super.key});

  @override
  ConsumerState<AutoSyncExample> createState() => _AutoSyncExampleState();
}

class _AutoSyncExampleState extends ConsumerState<AutoSyncExample> {
  StreamSubscription<NetworkStatus>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _setupAutoSync();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _setupAutoSync() {
    final connectivityService = ref.read(connectivityServiceProvider);

    _connectivitySubscription =
        connectivityService.onConnectivityChanged.listen((status) {
      if (status == NetworkStatus.connected) {
        // Auto-sync when connection is restored
        final syncService = ref.read(syncServiceProvider);

        if (!syncService.isSyncing) {
          // Use quick sync for automatic background sync
          syncService.syncPending().then((result) {
            if (result.success) {
              // Show notification or update UI
              debugPrint('Auto-sync completed successfully');
            } else {
              debugPrint('Auto-sync failed: ${result.errors}');
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

/// Example of manual sync with custom configuration
class CustomSyncExample extends ConsumerWidget {
  const CustomSyncExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Sync'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _performCustomSync(ref),
          child: const Text('Sync with Custom Config'),
        ),
      ),
    );
  }

  Future<void> _performCustomSync(WidgetRef ref) async {
    final syncService = ref.read(syncServiceProvider);

    // Create custom configuration
    final customConfig = SyncConfig(
      batchSize: 20, // Smaller batches
      batchDelay: 100,
      maxRetries: 5, // More retries
      operationTimeout: const Duration(minutes: 1),
      syncMedia: false, // Skip media for now
      autoResolveConflicts: true,
      conflictResolutionStrategy: ConflictResolutionStrategy.mostRecent,
      syncPendingOnly: true,
    );

    final result = await syncService.syncAll(customConfig);

    if (result.success) {
      debugPrint('Custom sync successful!');
    } else {
      debugPrint('Custom sync failed: ${result.errors}');
    }
  }
}

/// Example: Sync status indicator widget
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncServiceNotifierProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (syncState.isSyncing) ...[
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            '${(syncState.progressValue * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ] else ...[
          const Icon(Icons.cloud_done, size: 16),
          const SizedBox(width: 4),
          Text(
            syncState.lastSyncTime != null
                ? 'Synced'
                : 'Pending',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

// Example providers for data sources (these should be in your actual DI setup)
// These are placeholders - replace with your actual providers

@riverpod
JournalLocalDataSource journalLocalDataSource(
    JournalLocalDataSourceRef ref) {
  throw UnimplementedError('Provider not implemented');
}

@riverpod
JournalRemoteDataSource journalRemoteDataSource(
    JournalRemoteDataSourceRef ref) {
  throw UnimplementedError('Provider not implemented');
}

@riverpod
TripLocalDataSource tripLocalDataSource(TripLocalDataSourceRef ref) {
  throw UnimplementedError('Provider not implemented');
}

@riverpod
TripRemoteDataSource tripRemoteDataSource(TripRemoteDataSourceRef ref) {
  throw UnimplementedError('Provider not implemented');
}

@riverpod
TagLocalDataSource tagLocalDataSource(TagLocalDataSourceRef ref) {
  throw UnimplementedError('Provider not implemented');
}

@riverpod
TagRemoteDataSource tagRemoteDataSource(TagRemoteDataSourceRef ref) {
  throw UnimplementedError('Provider not implemented');
}
