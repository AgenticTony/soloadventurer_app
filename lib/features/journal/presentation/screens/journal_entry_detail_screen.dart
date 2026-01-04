import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';
import 'package:soloadventurer/features/journal/domain/entities/media_item.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_entry_detail_provider.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_entry_providers.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/rich_text_viewer.dart';

/// Screen for viewing a single journal entry with all content
class JournalEntryDetailScreen extends ConsumerWidget {
  /// Route name for navigation
  static const routeName = '/journal/entry';

  /// ID of the journal entry to display
  final String entryId;

  /// Creates a new [JournalEntryDetailScreen]
  const JournalEntryDetailScreen({
    super.key,
    required this.entryId,
  });

  /// Extract entry ID from route arguments
  static String extractEntryId(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      return args;
    }
    throw ArgumentError('entryId must be provided as route argument');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(journalEntryDetailProvider(entryId));
    final theme = Theme.of(context);

    return Scaffold(
      body: detailState.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : detailState.error != null
              ? _buildError(context, ref, detailState.error!)
              : detailState.entry == null
                  ? _buildNotFound(context)
                  : _buildContent(context, ref, detailState),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String error) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Entry',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(journalEntryDetailProvider(entryId).notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.not_interested,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Entry Not Found',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'The journal entry you\'re looking for doesn\'t exist.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    JournalEntryDetailState detailState,
  ) {
    final entry = detailState.entry!;
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        // App Bar with entry title
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          actions: [
            // Favorite toggle
            IconButton(
              icon: Icon(
                entry.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: entry.isFavorite ? Colors.red : null,
              ),
              onPressed: () async {
                final success = await ref
                    .read(journalEntryDetailProvider(entryId).notifier)
                    .toggleFavorite();
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(detailState.error ?? 'Failed to update'),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }
              },
              tooltip: entry.isFavorite ? 'Remove from favorites' : 'Add to favorites',
            ),

            // Edit button
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Navigate to edit screen (Phase 2+)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit feature coming soon!'),
                  ),
                );
              },
              tooltip: 'Edit entry',
            ),

            // More options menu
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'share':
                    _handleShare(context, entry);
                    break;
                  case 'delete':
                    _handleDelete(context, ref);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 12),
                      Text('Share'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              entry.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 4,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and location row
                _buildMetadataRow(context, entry),

                const SizedBox(height: 24),

                // Mood indicator
                if (entry.mood != null) ...[
                  _buildMoodIndicator(context, entry.mood!),
                  const SizedBox(height: 16),
                ],

                // Rich text content
                RichTextViewer(
                  content: entry.content,
                  showBorder: false,
                  textStyle: theme.textTheme.bodyLarge,
                ),

                const SizedBox(height: 24),

                // Media section (placeholder for Phase 3)
                if (detailState.hasMedia) ...[
                  _buildMediaSection(context, detailState.mediaItems),
                  const SizedBox(height: 24),
                ],

                // Trip info section (placeholder for Phase 5)
                if (entry.tripId != null) ...[
                  _buildTripSection(context, entry.tripId!),
                  const SizedBox(height: 16),
                ],

                // Sync status indicator
                if (entry.syncStatus != SyncStatus.synced) ...[
                  _buildSyncStatusIndicator(context, entry.syncStatus),
                  const SizedBox(height: 16),
                ],

                // Metadata footer
                _buildMetadataFooter(context, entry),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataRow(BuildContext context, JournalEntry entry) {
    final theme = Theme.of(context);
    final dateFormatter = DateFormat('MMMM d, yyyy');
    final timeFormatter = DateFormat('h:mm a');

    return Wrap(
      spacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Date icon
        Icon(
          Icons.calendar_today,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        // Date text
        Text(
          '${dateFormatter.format(entry.entryDate)} at ${timeFormatter.format(entry.entryDate)}',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),

        // Location if available
        if (entry.hasLocation) ...[
          Icon(
            Icons.location_on,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          Text(
            entry.locationName ?? 'Unknown location',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMoodIndicator(BuildContext context, String mood) {
    final theme = Theme.of(context);

    // Map common moods to emojis
    final emoji = _getMoodEmoji(mood);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Text(
            mood.toCapitalized(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection(BuildContext context, List<MediaItem> mediaItems) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.photo_library,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Photos & Videos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${mediaItems.length})',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Media grid placeholder
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                const SizedBox(height: 8),
                Text(
                  'Media viewer coming in Phase 3',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTripSection(BuildContext context, String tripId) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.flight_takeoff,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Part of a trip',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Trip ID: $tripId',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatusIndicator(BuildContext context, SyncStatus status) {
    final theme = Theme.of(context);

    Color color;
    IconData icon;
    String text;

    switch (status) {
      case SyncStatus.pending:
        color = Colors.orange;
        icon = Icons.cloud_sync;
        text = 'Syncing...';
        break;
      case SyncStatus.conflict:
        color = Colors.red;
        icon = Icons.cloud_off;
        text = 'Sync conflict';
        break;
      case SyncStatus.offlineOnly:
        color = Colors.grey;
        icon = Icons.cloud_off;
        text = 'Offline only';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataFooter(BuildContext context, JournalEntry entry) {
    final theme = Theme.of(context);
    final createdFormatter = DateFormat('MMM d, yyyy • h:mm a');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entry Info',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Created ${createdFormatter.format(entry.createdAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          if (entry.updatedAt != entry.createdAt) ...[
            const SizedBox(height: 2),
            Text(
              'Updated ${createdFormatter.format(entry.updatedAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleShare(BuildContext context, JournalEntry entry) {
    // TODO: Implement share functionality (Phase 8)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share feature coming soon!'),
      ),
    );
  }

  void _handleDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text(
          'Are you sure you want to delete this journal entry? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ref
                  .read(journalEntryDetailProvider(entryId).notifier)
                  .deleteEntry();

              if (success && context.mounted) {
                Navigator.of(context).pop(true); // Return to previous screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Entry deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ref.read(journalEntryDetailProvider(entryId)).error ??
                          'Failed to delete entry',
                    ),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _getMoodEmoji(String mood) {
    final lowerMood = mood.toLowerCase();
    if (lowerMood.contains('happy') || lowerMood.contains('joy')) {
      return '😊';
    } else if (lowerMood.contains('adventurous') || lowerMood.contains('excited')) {
      return '🤩';
    } else if (lowerMood.contains('tired') || lowerMood.contains('exhausted')) {
      return '😴';
    } else if (lowerMood.contains('sad') || lowerMood.contains('down')) {
      return '😢';
    } else if (lowerMood.contains('calm') || lowerMood.contains('peaceful')) {
      return '😌';
    } else if (lowerMood.contains('surprised')) {
      return '😲';
    } else if (lowerMood.contains('love') || lowerMood.contains('grateful')) {
      return '🥰';
    }
    return '😊'; // Default
  }
}

/// Extension to capitalize the first letter of a string
extension StringCapitalization on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : this;
}
