import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';
import 'package:soloadventurer/features/journal/domain/entities/media_item.dart';

/// Widget for displaying a journal entry in the timeline
class TimelineItem extends StatelessWidget {
  /// The journal entry to display
  final JournalEntry entry;

  /// Media items for this entry
  final List<MediaItem> mediaItems;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Whether to show full content or preview
  final bool showFullContent;

  /// Maximum number of media thumbnails to show
  final int maxMediaThumbnails;

  const TimelineItem({
    super.key,
    required this.entry,
    this.mediaItems = const [],
    this.onTap,
    this.showFullContent = false,
    this.maxMediaThumbnails = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title and actions
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        _buildMetadata(context),
                      ],
                    ),
                  ),
                  if (entry.isFavorite) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.favorite,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                  ],
                ],
              ),

              // Mood indicator
              if (entry.mood != null) ...[
                const SizedBox(height: 8),
                _buildMoodIndicator(context),
              ],

              // Content preview
              if (entry.content.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildContentPreview(context),
              ],

              // Media thumbnails
              if (mediaItems.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildMediaThumbnails(context),
              ],

              // Location indicator
              if (entry.locationName != null) ...[
                const SizedBox(height: 12),
                _buildLocationRow(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build metadata row (date, time)
  Widget _buildMetadata(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final entryDate = entry.entryDate;

    String dateStr;
    if (entryDate.year == now.year &&
        entryDate.month == now.month &&
        entryDate.day == now.day) {
      dateStr = 'Today';
    } else if (entryDate.year == now.year &&
        entryDate.month == now.month &&
        entryDate.day == now.day - 1) {
      dateStr = 'Yesterday';
    } else {
      dateStr = DateFormat('MMM d, yyyy').format(entryDate);
    }

    final timeStr = DateFormat('h:mm a').format(entryDate);

    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          '$dateStr at $timeStr',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Build mood indicator
  Widget _buildMoodIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final emoji = _getMoodEmoji(entry.mood);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 6),
          Text(
            entry.mood!.toLowerCase(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build content preview
  Widget _buildContentPreview(BuildContext context) {
    final theme = Theme.of(context);

    // Strip HTML tags for preview
    final plainText = entry.content.replaceAll(RegExp(r'<[^>]*>'), '').trim();

    final maxLines = showFullContent ? null : 3;

    return Text(
      plainText,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }

  /// Build media thumbnails
  Widget _buildMediaThumbnails(BuildContext context) {
    final theme = Theme.of(context);
    final displayItems = mediaItems.take(maxMediaThumbnails).toList();
    final remainingCount = mediaItems.length - maxMediaThumbnails;

    return Row(
      children: [
        ...displayItems.map((media) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _MediaThumbnail(
              media: media,
              size: 60,
            ),
          );
        }),
        if (remainingCount > 0)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '+$remainingCount',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Build location row
  Widget _buildLocationRow(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            entry.locationName!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Get emoji for mood
  String _getMoodEmoji(String? mood) {
    if (mood == null) return '😊';

    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'adventurous':
        return '🤠';
      case 'tired':
        return '😴';
      case 'sad':
        return '😢';
      case 'calm':
        return '😌';
      case 'surprised':
        return '😲';
      case 'grateful':
        return '🙏';
      default:
        return '😊';
    }
  }
}

/// Widget for media thumbnail
class _MediaThumbnail extends StatelessWidget {
  final MediaItem media;
  final double size;

  const _MediaThumbnail({
    required this.media,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha:0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Image
          Image.network(
            media.storagePath,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder(context);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildLoadingIndicator(context);
            },
          ),

          // Video indicator
          if (media.mediaType == MediaType.video)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha:0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        media.mediaType == MediaType.video
            ? Icons.videocam_off
            : Icons.image_not_supported,
        size: 24,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
