import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';
import 'package:soloadventurer/features/journal/presentation/providers/memory_timeline_provider.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_entry_providers.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/timeline_item.dart';
import 'package:intl/intl.dart';

/// Screen displaying chronological timeline of all travel experiences
class MemoryTimelineScreen extends ConsumerStatefulWidget {
  const MemoryTimelineScreen({super.key});

  @override
  ConsumerState<MemoryTimelineScreen> createState() =>
      _MemoryTimelineScreenState();
}

class _MemoryTimelineScreenState extends ConsumerState<MemoryTimelineScreen> {
  @override
  Widget build(BuildContext context) {
    final timelineState = ref.watch(memoryTimelineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Timeline'),
        actions: [
          // Filter button (placeholder for future filtering)
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement timeline filtering
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filtering coming soon!')),
              );
            },
            tooltip: 'Filter timeline',
          ),
        ],
      ),
      body: timelineState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : timelineState.error != null
              ? _buildError(context, timelineState.error!)
              : !timelineState.hasContent
                  ? _buildEmptyState(context)
                  : _buildTimeline(context, timelineState),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to create entry
          context.push('/journal/create');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
      ),
    );
  }

  /// Build error state
  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error Loading Timeline',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(memoryTimelineProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Memories Yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Start documenting your travel adventures to see them appear here in a beautiful timeline.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              context.push('/journal/create');
            },
            icon: const Icon(Icons.add),
            label: const Text('Create First Entry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Build timeline
  Widget _buildTimeline(BuildContext context, MemoryTimelineState state) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(memoryTimelineProvider.notifier).refresh();
      },
      child: CustomScrollView(
        slivers: [
          // Summary header
          SliverToBoxAdapter(
            child: _buildSummaryHeader(context, state),
          ),

          // Timeline groups
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, groupIndex) {
                if (groupIndex >= state.groups.length) return null;

                final group = state.groups[groupIndex];
                return _buildTimelineGroup(context, group, state);
              },
              childCount: state.groups.length,
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  /// Build summary header
  Widget _buildSummaryHeader(BuildContext context, MemoryTimelineState state) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            color: theme.colorScheme.primary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Travel Memories',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${state.entryCount} ${state.entryCount == 1 ? 'entry' : 'entries'} across ${state.groupCount} time periods',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build timeline group
  Widget _buildTimelineGroup(
    BuildContext context,
    TimelineGroup group,
    MemoryTimelineState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group header
        _buildGroupHeader(context, group),

        // Timeline items
        ...group.entries.asMap().entries.map((entryMap) {
          final index = entryMap.key;
          final entry = entryMap.value;
          final mediaItems = state.mediaByEntry[entry.id] ?? [];

          return Column(
            children: [
              // Timeline connector (except for first item in group)
              if (index > 0) _buildTimelineConnector(context),

              // Timeline item
              TimelineItem(
                entry: entry,
                mediaItems: mediaItems,
                onTap: () => _navigateToEntryDetail(entry),
              ),
            ],
          );
        }),

        const SizedBox(height: 16),
      ],
    );
  }

  /// Build group header
  Widget _buildGroupHeader(BuildContext context, TimelineGroup group) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _getGroupIcon(group.type),
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                if (group.subtitle != null)
                  Text(
                    group.subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer
                          .withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${group.entryCount} ${group.entryCount == 1 ? 'entry' : 'entries'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build timeline connector line
  Widget _buildTimelineConnector(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        height: 24,
        width: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.3),
              theme.colorScheme.primary.withValues(alpha: 0.1),
            ],
          ),
        ),
      ),
    );
  }

  /// Get icon for group type
  IconData _getGroupIcon(TimelineGroupType type) {
    switch (type) {
      case TimelineGroupType.today:
        return Icons.today;
      case TimelineGroupType.yesterday:
        return Icons.history;
      case TimelineGroupType.thisWeek:
        return Icons.view_week;
      case TimelineGroupType.thisMonth:
        return Icons.calendar_month;
      case TimelineGroupType.thisYear:
        return Icons.calendar_today;
      case TimelineGroupType.month:
        return Icons.date_range;
      case TimelineGroupType.year:
        return Icons.event;
    }
  }

  /// Navigate to entry detail
  void _navigateToEntryDetail(JournalEntry entry) {
    context.push('/journal/entry/${entry.id}');
  }
}
