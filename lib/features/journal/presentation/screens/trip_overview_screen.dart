import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:soloadventurer/core/utils/string_extensions.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';
import 'package:soloadventurer/features/journal/domain/entities/media_item.dart';
import 'package:soloadventurer/features/journal/domain/entities/trip.dart';
import 'package:soloadventurer/features/journal/presentation/providers/trip_overview_provider.dart';
import 'package:soloadventurer/features/journal/presentation/providers/trip_providers.dart';

/// Screen displaying all entries and media for a specific trip
class TripOverviewScreen extends ConsumerStatefulWidget {
  final String tripId;

  const TripOverviewScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripOverviewScreen> createState() => _TripOverviewScreenState();
}

class _TripOverviewScreenState extends ConsumerState<TripOverviewScreen> {
  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(tripDetailProvider(widget.tripId));
    final overviewState = ref.watch(tripOverviewProvider(widget.tripId));

    return Scaffold(
      body: detailState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : detailState.error != null
              ? _buildError(context, detailState.error!)
              : detailState.trip == null
                  ? const Center(child: Text('Trip not found'))
                  : _buildContent(context, detailState.trip!, overviewState),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading trip',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(error),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(tripDetailProvider(widget.tripId).notifier)
                  .loadTrip(widget.tripId);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, Trip trip, TripOverviewState overviewState) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(tripOverviewProvider(widget.tripId).notifier).refresh(widget.tripId);
      },
      child: CustomScrollView(
        slivers: [
          // App bar with trip info
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                trip.name,
                style: const TextStyle(
                  color: Colors.white,
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
              background: trip.coverImageUrl != null
                  ? Image.network(
                      trip.coverImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder(context);
                      },
                    )
                  : _buildPlaceholder(context),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics
                  _buildStatistics(context, trip, overviewState),

                  const SizedBox(height: 24),

                  // Journal entries section
                  _buildEntriesSection(context, overviewState),

                  const SizedBox(height: 24),

                  // Media gallery section
                  _buildMediaSection(context, overviewState),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.flight_takeoff,
          size: 64,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildStatistics(
      BuildContext context, Trip trip, TripOverviewState overviewState) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trip Statistics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.article,
                    label: 'Entries',
                    value: overviewState.entryCount.toString(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatItem(
                    icon: Icons.photo_library,
                    label: 'Media',
                    value: overviewState.mediaCount.toString(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatItem(
                    icon: Icons.schedule,
                    label: 'Duration',
                    value: '${trip.duration.inDays}d',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntriesSection(
      BuildContext context, TripOverviewState overviewState) {
    final theme = Theme.of(context);

    if (overviewState.isLoadingEntries) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (overviewState.entries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.note_alt_outlined,
                size: 48,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'No entries yet',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Start documenting your trip adventures',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.article,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Journal Entries',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${overviewState.entryCount})',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...overviewState.sortedEntries
            .map((entry) => _buildEntryCard(context, entry)),
      ],
    );
  }

  Widget _buildEntryCard(BuildContext context, JournalEntry entry) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('/journal/entry/${entry.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and date row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (entry.isFavorite)
                    const Icon(
                      Icons.favorite,
                      size: 20,
                      color: Colors.red,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Date and location
              Wrap(
                spacing: 16,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${dateFormat.format(entry.entryDate)} at ${timeFormat.format(entry.entryDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  if (entry.hasLocation) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          entry.locationName ?? 'Unknown location',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              // Mood indicator
              if (entry.mood != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      _getMoodEmoji(entry.mood!),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.mood!.toCapitalized(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
              // Content preview
              if (entry.content.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  _getContentPreview(entry.content),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaSection(
      BuildContext context, TripOverviewState overviewState) {
    final theme = Theme.of(context);

    if (overviewState.isLoadingMedia) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (overviewState.mediaItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.photo_library,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Media Gallery',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${overviewState.mediaCount})',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildMediaGrid(context, overviewState.sortedMedia),
      ],
    );
  }

  Widget _buildMediaGrid(BuildContext context, List<MediaItem> mediaItems) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: mediaItems.length,
      itemBuilder: (context, index) {
        final media = mediaItems[index];
        return _buildMediaThumbnail(context, media);
      },
    );
  }

  Widget _buildMediaThumbnail(BuildContext context, MediaItem media) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Media thumbnail
          Image.network(
            media.storagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildMediaPlaceholder(context, media);
            },
          ),

          // Video indicator
          if (media.mediaType == MediaType.video)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),

          // Upload status overlay
          if (media.uploadStatus != UploadStatus.completed)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: _buildUploadStatusIcon(context, media.uploadStatus),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaPlaceholder(BuildContext context, MediaItem media) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          media.mediaType == MediaType.video
              ? Icons.videocam_outlined
              : Icons.image_outlined,
          size: 32,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildUploadStatusIcon(BuildContext context, UploadStatus status) {
    switch (status) {
      case UploadStatus.queued:
      case UploadStatus.uploading:
        return const CircularProgressIndicator(color: Colors.white);
      case UploadStatus.failed:
        return const Icon(Icons.error, color: Colors.red, size: 32);
      default:
        return const SizedBox.shrink();
    }
  }

  String _getContentPreview(String content) {
    // Simple plain text extraction from Delta JSON
    // For now, just return a placeholder
    // In production, you'd parse the Delta JSON and extract text
    if (content.startsWith('{"ops":')) {
      // Delta JSON format
      return 'Tap to read entry...';
    }
    return content;
  }

  String _getMoodEmoji(String mood) {
    final lowerMood = mood.toLowerCase();
    if (lowerMood.contains('happy') || lowerMood.contains('joy')) {
      return '😊';
    } else if (lowerMood.contains('adventurous') ||
        lowerMood.contains('excited')) {
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
    return '😊';
  }
}

/// Stat item widget for displaying statistics
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

