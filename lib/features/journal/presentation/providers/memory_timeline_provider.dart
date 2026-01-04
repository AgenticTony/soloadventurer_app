import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';
import 'package:soloadventurer/features/journal/domain/entities/media_item.dart';
import 'package:soloadventurer/features/journal/domain/repositories/journal_repository.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';

/// State for the memory timeline
class MemoryTimelineState {
  /// All journal entries grouped and sorted
  final List<TimelineGroup> groups;

  /// All entries flattened (for filtering)
  final List<JournalEntry> allEntries;

  /// All media items for entries
  final Map<String, List<MediaItem>> mediaByEntry;

  /// Loading state
  final bool isLoading;

  /// Error message
  final String? error;

  MemoryTimelineState({
    this.groups = const [],
    this.allEntries = const [],
    this.mediaByEntry = const {},
    this.isLoading = false,
    this.error,
  });

  /// Number of entries in timeline
  int get entryCount => allEntries.length;

  /// Number of groups in timeline
  int get groupCount => groups.length;

  /// Whether timeline has content
  bool get hasContent => allEntries.isNotEmpty;

  MemoryTimelineState copyWith({
    List<TimelineGroup>? groups,
    List<JournalEntry>? allEntries,
    Map<String, List<MediaItem>>? mediaByEntry,
    bool? isLoading,
    String? error,
    Object? clearedError,
  }) {
    return MemoryTimelineState(
      groups: groups ?? this.groups,
      allEntries: allEntries ?? this.allEntries,
      mediaByEntry: mediaByEntry ?? this.mediaByEntry,
      isLoading: isLoading ?? this.isLoading,
      error: clearedError != null ? null : (error ?? this.error),
    );
  }
}

/// Represents a group of entries on the timeline
class TimelineGroup {
  /// Display title for the group (e.g., "Today", "This Week", "January 2024")
  final String title;

  /// Subtitle (optional)
  final String? subtitle;

  /// Entries in this group
  final List<JournalEntry> entries;

  /// Group type
  final TimelineGroupType type;

  TimelineGroup({
    required this.title,
    this.subtitle,
    required this.entries,
    required this.type,
  });

  /// Number of entries in group
  int get entryCount => entries.length;

  /// First entry date in group
  DateTime? get firstDate => entries.isNotEmpty ? entries.first.entryDate : null;

  /// Last entry date in group
  DateTime? get lastDate => entries.isNotEmpty ? entries.last.entryDate : null;
}

/// Timeline grouping types
enum TimelineGroupType {
  /// Entries from today
  today,

  /// Entries from yesterday
  yesterday,

  /// Entries from this week
  thisWeek,

  /// Entries from this month
  thisMonth,

  /// Entries from this year
  thisYear,

  /// Entries by month (older than this year)
  month,

  /// Entries by year (very old)
  year,
}

/// Provider for memory timeline
class MemoryTimelineNotifier extends StateNotifier<MemoryTimelineState> {
  final JournalRepository _repository;

  MemoryTimelineNotifier(this._repository) : super(MemoryTimelineState()) {
    loadTimeline();
  }

  /// Load all journal entries and build timeline
  Future<void> loadTimeline() async {
    state = state.copyWith(isLoading: true, clearedError: null);

    try {
      // Fetch all entries
      final entries = await _repository.getEntries();

      // Sort entries by date (newest first)
      final sortedEntries = entries.toList()
        ..sort((a, b) => b.entryDate.compareTo(a.entryDate));

      // Group entries
      final groups = _groupEntries(sortedEntries);

      // Fetch media for all entries
      final mediaByEntry = <String, List<MediaItem>>{};
      for (final entry in sortedEntries) {
        try {
          final media = await _repository.getMediaForEntry(entry.id);
          if (media.isNotEmpty) {
            mediaByEntry[entry.id] = media;
          }
        } catch (e) {
          // Continue if media fetch fails for individual entry
          mediaByEntry[entry.id] = [];
        }
      }

      state = state.copyWith(
        groups: groups,
        allEntries: sortedEntries,
        mediaByEntry: mediaByEntry,
        isLoading: false,
        clearedError: null,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load timeline: ${e.toString()}',
      );
    }
  }

  /// Refresh timeline data
  Future<void> refresh() async {
    await loadTimeline();
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(clearedError: true);
  }

  /// Group entries by time periods
  List<TimelineGroup> _groupEntries(List<JournalEntry> entries) {
    if (entries.isEmpty) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final thisYearStart = DateTime(now.year, 1, 1);

    final groups = <TimelineGroup>[];

    // Group entries by time period
    final todayEntries = <JournalEntry>[];
    final yesterdayEntries = <JournalEntry>[];
    final thisWeekEntries = <JournalEntry>[];
    final thisMonthEntries = <JournalEntry>[];
    final thisYearEntries = <JournalEntry>[];

    // Map for month/year grouping
    final monthGroups = <String, List<JournalEntry>>{};

    for (final entry in entries) {
      final entryDate = DateTime(
        entry.entryDate.year,
        entry.entryDate.month,
        entry.entryDate.day,
      );

      if (entryDate == today) {
        todayEntries.add(entry);
      } else if (entryDate == yesterday) {
        yesterdayEntries.add(entry);
      } else if (entryDate.isAfter(thisWeekStart) || entryDate == thisWeekStart) {
        thisWeekEntries.add(entry);
      } else if (entryDate.isAfter(thisMonthStart) || entryDate == thisMonthStart) {
        thisMonthEntries.add(entry);
      } else if (entryDate.isAfter(thisYearStart) || entryDate == thisYearStart) {
        thisYearEntries.add(entry);
      } else {
        // Older entries - group by month and year
        final monthKey = '${entry.entryDate.year}-${entry.entryDate.month.toString().padLeft(2, '0')}';
        monthGroups.putIfAbsent(monthKey, () => []).add(entry);
      }
    }

    // Add groups in order
    if (todayEntries.isNotEmpty) {
      groups.add(TimelineGroup(
        title: 'Today',
        entries: todayEntries,
        type: TimelineGroupType.today,
      ));
    }

    if (yesterdayEntries.isNotEmpty) {
      groups.add(TimelineGroup(
        title: 'Yesterday',
        entries: yesterdayEntries,
        type: TimelineGroupType.yesterday,
      ));
    }

    if (thisWeekEntries.isNotEmpty) {
      groups.add(TimelineGroup(
        title: 'This Week',
        subtitle: _formatWeekRange(thisWeekStart, today),
        entries: thisWeekEntries,
        type: TimelineGroupType.thisWeek,
      ));
    }

    if (thisMonthEntries.isNotEmpty) {
      groups.add(TimelineGroup(
        title: 'This Month',
        subtitle: _formatMonth(now.year, now.month),
        entries: thisMonthEntries,
        type: TimelineGroupType.thisMonth,
      ));
    }

    if (thisYearEntries.isNotEmpty) {
      groups.add(TimelineGroup(
        title: 'This Year',
        entries: thisYearEntries,
        type: TimelineGroupType.thisYear,
      ));
    }

    // Add older month/year groups
    final sortedMonthKeys = monthGroups.keys.toList()..sort();
    for (final monthKey in sortedMonthKeys) {
      final parts = monthKey.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final entries = monthGroups[monthKey]!;

      groups.add(TimelineGroup(
        title: _formatMonth(year, month),
        subtitle: year.toString(),
        entries: entries,
        type: TimelineGroupType.month,
      ));
    }

    return groups;
  }

  /// Format week range
  String _formatWeekRange(DateTime start, DateTime end) {
    final startFormat = '${start.month}/${start.day}';
    final endFormat = '${end.month}/${end.day}';
    return '$startFormat - $endFormat';
  }

  /// Format month name
  String _formatMonth(int year, int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

/// Provider for journal repository (to be injected)
final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  throw UnimplementedError('JournalRepository must be provided');
});

/// Provider for memory timeline
final memoryTimelineProvider =
    StateNotifierProvider<MemoryTimelineNotifier, MemoryTimelineState>((ref) {
  final repository = ref.watch(journalRepositoryProvider);
  return MemoryTimelineNotifier(repository);
});
