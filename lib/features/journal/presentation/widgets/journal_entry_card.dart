import 'package:soloadventurer/features/journal/domain/entities/shared_link.dart'; // For SyncStatus enum
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';

/// Card widget for displaying journal entry information
class JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;

  const JournalEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Semantics(
      button: true,
      label: entry.title,
      hint: 'View journal entry from ${dateFormat.format(entry.entryDate)}',
      value: entry.isFavorite ? 'Marked as favorite' : null,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with title and favorite icon
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        semanticsLabel: entry.title,
                      ),
                    ),
                    if (entry.isFavorite) ...[
                      const SizedBox(width: 8),
                      Semantics(
                        label: 'Marked as favorite',
                        child: Icon(
                          Icons.favorite,
                          size: 20,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                // Date and time
                Semantics(
                  label: 'Entry date and time',
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(entry.entryDate),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeFormat.format(entry.entryDate),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // Mood indicator (if present)
                if (entry.mood != null && entry.mood!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _MoodIndicator(mood: entry.mood!),
                ],

                // Location (if present)
                if (entry.locationName != null &&
                    entry.locationName!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Semantics(
                    label: 'Location: ${entry.locationName}',
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            entry.locationName!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Content preview
                if (entry.content.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Semantics(
                    label: 'Content preview',
                    child: ExcludeSemantics(
                      child: Text(
                        _getContentPreview(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.8),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],

                // Sync status indicator (if not synced)
                if (entry.syncStatus != SyncStatus.synced) ...[
                  const SizedBox(height: 8),
                  _SyncStatusIndicator(syncStatus: entry.syncStatus),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get a plain text preview of the content
  String _getContentPreview() {
    // Remove HTML tags for preview
    String plainText = entry.content
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();

    if (plainText.length > 150) {
      plainText = '${plainText.substring(0, 150)}...';
    }

    return plainText.isEmpty ? 'No content' : plainText;
  }
}

/// Widget for displaying mood indicator
class _MoodIndicator extends StatelessWidget {
  final String mood;

  const _MoodIndicator({required this.mood});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Mood: $mood',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Text(
                _getMoodEmoji(mood),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              mood,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMoodEmoji(String mood) {
    final lowerMood = mood.toLowerCase();
    if (lowerMood.contains('happy') || lowerMood.contains('joy')) {
      return '😊';
    } else if (lowerMood.contains('excited') ||
        lowerMood.contains('adventurous')) {
      return '🤩';
    } else if (lowerMood.contains('calm') || lowerMood.contains('peaceful')) {
      return '😌';
    } else if (lowerMood.contains('tired') || lowerMood.contains('exhausted')) {
      return '😴';
    } else if (lowerMood.contains('sad') || lowerMood.contains('down')) {
      return '😢';
    } else if (lowerMood.contains('surprised')) {
      return '😲';
    } else {
      return '😊'; // Default
    }
  }
}

/// Widget for displaying sync status
class _SyncStatusIndicator extends StatelessWidget {
  final SyncStatus syncStatus;

  const _SyncStatusIndicator({required this.syncStatus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Sync status: ${_getStatusText()}',
      child: Row(
        children: [
          Icon(
            _getStatusIcon(),
            size: 12,
            color: _getStatusColor(),
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusText(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: _getStatusColor(),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (syncStatus) {
      case SyncStatus.pending:
        return Icons.cloud_upload;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.conflict:
        return Icons.error;
      case SyncStatus.synced:
      default:
        return Icons.cloud_done;
    }
  }

  Color _getStatusColor() {
    switch (syncStatus) {
      case SyncStatus.pending:
        return Colors.orange;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.conflict:
        return Colors.red;
      case SyncStatus.synced:
      default:
        return Colors.green;
    }
  }

  String _getStatusText() {
    switch (syncStatus) {
      case SyncStatus.pending:
        return 'Pending sync';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.conflict:
        return 'Sync conflict';
      case SyncStatus.synced:
      default:
        return 'Synced';
    }
  }
}
