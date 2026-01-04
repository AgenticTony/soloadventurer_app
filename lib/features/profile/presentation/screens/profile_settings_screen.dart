import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/sync/presentation/widgets/widgets.dart';
import 'package:soloadventurer/features/sync/presentation/providers/sync_providers.dart';
import '../providers/profile_providers.dart';
import '../widgets/loading_view.dart';

class ProfileSettingsScreen extends ConsumerWidget {
  /// Route name for navigation
  static const routeName = '/profile/settings';

  /// Creates a new [ProfileSettingsScreen]
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileUIProvider('current'));
    final theme = Theme.of(context);

    if (state.isProcessing) {
      return const LoadingView();
    }

    if (!state.isInitialized) {
      return const Scaffold(
        body: Center(
          child: Text('No profile data available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
      ),
      body: SyncPullToRefresh(
        showNotifications: true,
        child: ListView(
          children: [
            _buildSyncSection(context, ref),
          _buildSection(
            context,
            'Privacy',
            [
              SwitchListTile(
                title: const Text('Public Profile'),
                subtitle: Text(
                  state.profile!.isPublic
                      ? 'Your profile is visible to everyone'
                      : 'Your profile is private',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                value: state.profile!.isPublic,
                onChanged: (value) {
                  ref
                      .read(profileUIProvider('current').notifier)
                      .updateProfile({
                    'isPublic': value,
                  });
                },
              ),
            ],
          ),
          _buildSection(
            context,
            'Account',
            [
              ListTile(
                title: const Text('Delete Account'),
                subtitle: const Text(
                  'Permanently delete your account and all data',
                ),
                leading: Icon(
                  Icons.delete_forever,
                  color: theme.colorScheme.error,
                ),
                textColor: theme.colorScheme.error,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Account'),
                      content: const Text(
                        'Are you sure you want to delete your account? This action cannot be undone and will permanently delete all your data.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ref
                                .read(profileUIProvider('current').notifier)
                                .deleteProfile();
                            Navigator.pop(context); // Pop settings screen
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                          ),
                          child: const Text('DELETE'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          if (state.hasError) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                state.error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ]),
      ),
    );
  }

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

  Widget _buildSyncSection(BuildContext context, WidgetRef ref) {
    final isSyncing = ref.watch(isSyncingProvider);
    final syncStatusText = ref.watch(syncStatusTextProvider);
    final lastSyncTime = ref.watch(lastSyncTimeProvider);
    final pendingCount = ref.watch(pendingOperationsCountProvider);
    final syncResultSummary = ref.watch(syncResultSummaryProvider);

    return _buildSection(
      context,
      'Sync',
      [
        // Sync status card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status row
                  Row(
                    children: [
                      Icon(
                        _getSyncIcon(ref),
                        size: 20,
                        color: _getSyncColor(context, ref),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          syncStatusText,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                color: _getSyncColor(context, ref),
                              ),
                        ),
                      ),
                      if (pendingCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$pendingCount pending',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                          ),
                        ),
                    ],
                  ),
                  if (lastSyncTime != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Last sync: ${_formatSyncTime(lastSyncTime)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                  if (syncResultSummary != null && !isSyncing) ...[
                    const SizedBox(height: 8),
                    Text(
                      syncResultSummary,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getSyncColor(context, ref),
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        // Manual sync button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SizedBox(
            width: double.infinity,
            child: ManualSyncButton(
              style: ManualSyncButtonStyle.elevated,
              showResultSummary: true,
            ),
          ),
        ),
        // Pull to refresh hint
        if (!isSyncing)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Pull down to sync',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
      ],
    );
  }

  IconData _getSyncIcon(WidgetRef ref) {
    final state = ref.watch(manualSyncStateProvider);
    final status = ref.watch(syncStatusProvider);

    if (state.isSyncing) {
      return Icons.sync;
    }

    switch (status) {
      case SyncStatus.success:
        return Icons.check_circle;
      case SyncStatus.failed:
        return Icons.error;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.pending:
        return Icons.pending;
      case SyncStatus.idle:
      default:
        return Icons.cloud_done;
    }
  }

  Color _getSyncColor(BuildContext context, WidgetRef ref) {
    final state = ref.watch(manualSyncStateProvider);
    final theme = Theme.of(context);

    if (state.isSyncing) {
      return theme.colorScheme.primary;
    }

    if (!state.hasResults) {
      return theme.colorScheme.onSurface;
    }

    if (state.lastSyncSuccess == true) {
      return theme.colorScheme.primary;
    }

    if (state.lastSyncSuccess == false) {
      return theme.colorScheme.error;
    }

    return theme.colorScheme.onSurface;
  }

  String _formatSyncTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
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
