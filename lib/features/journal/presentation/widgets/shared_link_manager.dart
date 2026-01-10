import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soloadventurer/features/journal/domain/entities/shared_link.dart';
import 'package:soloadventurer/features/journal/presentation/providers/shared_link_providers.dart';

/// Widget for managing shared links for a trip
class SharedLinkManager extends ConsumerWidget {
  final String tripId;
  final String tripName;

  const SharedLinkManager({
    super.key,
    required this.tripId,
    required this.tripName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linksAsync = ref.watch(tripSharedLinksProvider(tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Links'),
      ),
      body: linksAsync.when(
        data: (links) {
          if (links.isEmpty) {
            return _EmptyState(tripName: tripName);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: links.length,
            itemBuilder: (context, index) {
              return SharedLinkCard(
                link: links[index],
                onDelete: () => _deleteLink(context, ref, links[index].id),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(tripSharedLinksProvider(tripId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SharedLinkCreator(
                tripId: tripId,
                tripName: tripName,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Link'),
      ),
    );
  }

  Future<void> _deleteLink(
      BuildContext context, WidgetRef ref, String linkId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Link?'),
        content: const Text(
          'Are you sure you want to delete this shared link? '
          'Anyone with the link will no longer be able to access your trip.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final service = ref.read(sharedLinkServiceProvider);
        await service.deleteSharedLink(linkId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Link deleted')),
          );
          ref.invalidate(tripSharedLinksProvider(tripId));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete link: $e')),
          );
        }
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  final String tripName;

  const _EmptyState({required this.tripName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.link_off,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No shared links',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Create a link to share "$tripName" with others',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

/// Card widget displaying a shared link
class SharedLinkCard extends ConsumerWidget {
  final SharedLink link;
  final VoidCallback onDelete;

  const SharedLinkCard({
    super.key,
    required this.link,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(sharedLinkStatisticsProvider(link.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showLinkDetails(context, link),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.link,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          link.shareUrl,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Created ${DateFormat('MMM dd, yyyy').format(link.createdAt)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      // Copy to clipboard
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copied!')),
                      );
                    },
                    tooltip: 'Copy link',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (link.hasPassword)
                    const Chip(
                      avatar: Icon(Icons.lock, size: 16),
                      label: Text('Password Protected'),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (!link.isActive)
                    Chip(
                      avatar: const Icon(Icons.block, size: 16),
                      label: const Text('Inactive'),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: theme.colorScheme.errorContainer,
                    ),
                  if (link.isExpired)
                    Chip(
                      avatar: const Icon(Icons.timer_off, size: 16),
                      label: const Text('Expired'),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: theme.colorScheme.errorContainer,
                    ),
                  if (link.expiresAt != null && !link.isExpired)
                    Chip(
                      avatar: const Icon(Icons.timer, size: 16),
                      label: Text(
                        'Expires ${DateFormat('MMM dd').format(link.expiresAt!)}',
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              statsAsync.when(
                data: (stats) {
                  return Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${stats.totalViews} views',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (stats.lastViewedAt != null) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Last ${_formatLastViewed(stats.lastViewedAt!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatLastViewed(DateTime lastViewed) {
    final now = DateTime.now();
    final difference = now.difference(lastViewed);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showLinkDetails(BuildContext context, SharedLink link) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SharedLinkDetailsSheet(link: link),
    );
  }
}

/// Bottom sheet with link details and actions
class SharedLinkDetailsSheet extends StatelessWidget {
  final SharedLink link;

  const SharedLinkDetailsSheet({
    super.key,
    required this.link,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.link),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Link Details',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Link URL
                  _DetailSection(
                    title: 'Share Link',
                    child: SelectableText(
                      link.shareUrl,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Status
                  _DetailSection(
                    title: 'Status',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StatusRow(
                          icon:
                              link.isActive ? Icons.check_circle : Icons.block,
                          label: link.isActive ? 'Active' : 'Inactive',
                          color: link.isActive ? Colors.green : Colors.red,
                        ),
                        if (link.hasPassword)
                          const _StatusRow(
                            icon: Icons.lock,
                            label: 'Password Protected',
                            color: Colors.orange,
                          ),
                        if (link.isExpired)
                          const _StatusRow(
                            icon: Icons.timer_off,
                            label: 'Expired',
                            color: Colors.red,
                          ),
                        if (link.expiresAt != null && !link.isExpired)
                          _StatusRow(
                            icon: Icons.timer,
                            label:
                                'Expires ${DateFormat('MMM dd, yyyy').format(link.expiresAt!)}',
                            color: Colors.blue,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Statistics
                  _DetailSection(
                    title: 'Statistics',
                    child: Consumer(
                      builder: (context, ref, _) {
                        final statsAsync =
                            ref.watch(sharedLinkStatisticsProvider(link.id));

                        return statsAsync.when(
                          data: (stats) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _StatRow(
                                  label: 'Total Views',
                                  value: stats.totalViews.toString(),
                                ),
                                _StatRow(
                                  label: 'Last Viewed',
                                  value: stats.lastViewedAt != null
                                      ? DateFormat('MMM dd, yyyy - HH:mm')
                                          .format(stats.lastViewedAt!)
                                      : 'Never',
                                ),
                                _StatRow(
                                  label: 'Days Active',
                                  value: stats.daysSinceCreation.toString(),
                                ),
                                _StatRow(
                                  label: 'Avg Views/Day',
                                  value: stats.averageViewsPerDay
                                      .toStringAsFixed(1),
                                ),
                              ],
                            );
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) =>
                              const Text('Failed to load statistics'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

/// Import SharedLinkCreator from shared_link_creator.dart
class SharedLinkCreator extends StatelessWidget {
  final String tripId;
  final String tripName;

  const SharedLinkCreator({
    super.key,
    required this.tripId,
    required this.tripName,
  });

  @override
  Widget build(BuildContext context) {
    // Placeholder - actual implementation in shared_link_creator.dart
    return const Scaffold(
      body: Center(child: Text('Shared Link Creator')),
    );
  }
}
