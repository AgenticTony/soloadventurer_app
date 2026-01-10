import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_entry_providers.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';

// Generated file
part 'journal_search_provider.g.dart';

/// Search filters for journal entries
class JournalSearchFilters {
  /// Text search query (searches title and content)
  final String query;

  /// Location name filter
  final String? locationName;

  /// Start date filter (inclusive)
  final DateTime? startDate;

  /// End date filter (inclusive)
  final DateTime? endDate;

  /// Tag IDs to filter by (entries must have ALL these tags)
  final List<String> tagIds;

  /// Trip ID to filter entries from a specific trip
  final String? tripId;

  /// Filter by favorite status
  final bool? favoriteOnly;

  /// Filter by mood
  final String? mood;

  JournalSearchFilters({
    this.query = '',
    this.locationName,
    this.startDate,
    this.endDate,
    this.tagIds = const [],
    this.tripId,
    this.favoriteOnly,
    this.mood,
  });

  /// Check if any filters are active
  bool get hasActiveFilters =>
      query.isNotEmpty ||
      locationName != null ||
      startDate != null ||
      endDate != null ||
      tagIds.isNotEmpty ||
      tripId != null ||
      favoriteOnly == true ||
      mood != null;

  /// Get count of active filters
  int get activeFilterCount {
    int count = 0;
    if (query.isNotEmpty) count++;
    if (locationName != null) count++;
    if (startDate != null) count++;
    if (endDate != null) count++;
    if (tagIds.isNotEmpty) count++;
    if (tripId != null) count++;
    if (favoriteOnly == true) count++;
    if (mood != null) count++;
    return count;
  }

  JournalSearchFilters copyWith({
    String? query,
    String? locationName,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? tagIds,
    String? tripId,
    bool? favoriteOnly,
    bool clearFavoriteOnly = false,
    String? mood,
    bool clearLocationName = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearTripId = false,
    bool clearMood = false,
  }) {
    return JournalSearchFilters(
      query: query ?? this.query,
      locationName:
          clearLocationName ? null : (locationName ?? this.locationName),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      tagIds: tagIds ?? this.tagIds,
      tripId: clearTripId ? null : (tripId ?? this.tripId),
      favoriteOnly:
          clearFavoriteOnly ? null : (favoriteOnly ?? this.favoriteOnly),
      mood: clearMood ? null : (mood ?? this.mood),
    );
  }

  JournalSearchFilters clearFilters() {
    return JournalSearchFilters(
      query: query, // Keep the query when clearing filters
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalSearchFilters &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          locationName == other.locationName &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          tagIds == other.tagIds &&
          tripId == other.tripId &&
          favoriteOnly == other.favoriteOnly &&
          mood == other.mood;

  @override
  int get hashCode =>
      query.hashCode ^
      locationName.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      tagIds.hashCode ^
      tripId.hashCode ^
      favoriteOnly.hashCode ^
      mood.hashCode;
}

/// State for journal search
class JournalSearchState {
  /// Current search results
  final List<JournalEntry> results;

  /// Whether a search is in progress
  final bool isSearching;

  /// Current search filters
  final JournalSearchFilters filters;

  /// Error message if search failed
  final String? error;

  /// Total number of results
  int get resultCount => results.length;

  /// Whether there are any results
  bool get hasResults => results.isNotEmpty;

  /// Whether this is the initial state (no search performed yet)
  bool get isInitial =>
      !isSearching &&
      error == null &&
      filters.query.isEmpty &&
      !filters.hasActiveFilters;

  JournalSearchState({
    this.results = const [],
    this.isSearching = false,
    JournalSearchFilters? filters,
    this.error,
  }) : filters = filters ?? JournalSearchFilters();

  JournalSearchState copyWith({
    List<JournalEntry>? results,
    bool? isSearching,
    JournalSearchFilters? filters,
    String? error,
    bool clearError = false,
  }) {
    return JournalSearchState(
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      filters: filters ?? this.filters,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Notifier for journal search
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
@riverpod
class JournalSearch extends _$JournalSearch {
  @override
  JournalSearchState build() {
    return JournalSearchState();
  }

  /// Perform search with current filters
  Future<void> search() async {
    final filters = state.filters;

    // If no filters are active, clear results
    if (!filters.hasActiveFilters) {
      state = state.copyWith(results: [], clearError: true);
      return;
    }

    state = state.copyWith(isSearching: true, clearError: true);

    try {
      final repository = ref.read(journalRepositoryProvider);
      List<JournalEntry> results = [];

      // Perform search based on active filters
      if (filters.query.isNotEmpty) {
        // Text search (use repository search method)
        results = await repository.searchEntries(filters.query);
      } else {
        // Get all entries and filter client-side
        // In production, you'd want server-side filtering for better performance
        results = await repository.getEntries();
      }

      // Apply additional filters
      results = _applyFilters(results, filters);

      state = state.copyWith(
        results: results,
        isSearching: false,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isSearching: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        error: 'Search failed: ${e.toString()}',
      );
    }
  }

  /// Apply filters to a list of entries
  List<JournalEntry> _applyFilters(
    List<JournalEntry> entries,
    JournalSearchFilters filters,
  ) {
    var filtered = entries;

    // Filter by location
    if (filters.locationName != null && filters.locationName!.isNotEmpty) {
      filtered = filtered.where((entry) {
        return entry.locationName?.toLowerCase().contains(
                  filters.locationName!.toLowerCase(),
                ) ==
            true;
      }).toList();
    }

    // Filter by date range
    if (filters.startDate != null) {
      filtered = filtered
          .where((entry) => !entry.entryDate.isBefore(filters.startDate!))
          .toList();
    }

    if (filters.endDate != null) {
      // Include the entire end date
      final endOfDay = DateTime(
        filters.endDate!.year,
        filters.endDate!.month,
        filters.endDate!.day,
        23,
        59,
        59,
      );
      filtered = filtered
          .where((entry) => !entry.entryDate.isAfter(endOfDay))
          .toList();
    }

    // Filter by trip
    if (filters.tripId != null) {
      filtered =
          filtered.where((entry) => entry.tripId == filters.tripId).toList();
    }

    // Filter by favorite
    if (filters.favoriteOnly == true) {
      filtered = filtered.where((entry) => entry.isFavorite).toList();
    }

    // Filter by mood
    if (filters.mood != null && filters.mood!.isNotEmpty) {
      filtered = filtered.where((entry) => entry.mood == filters.mood).toList();
    }

    // Filter by tags
    // TODO: Optimize tag filtering with a single query or batch loading
    // Currently skipping async tag filtering as it requires refactoring
    // to properly handle async predicates in filter operations
    // if (filters.tagIds.isNotEmpty) {
    //   filtered = filtered.where((entry) async {
    //     final repository = ref.read(journalRepositoryProvider);
    //     final entryTags = await repository.getTagsForEntry(entry.id);
    //     // Entry must have ALL the specified tags
    //     return filters.tagIds.every((tagId) => entryTags.contains(tagId));
    //   }).toList();
    // }

    return filtered;
  }

  /// Update search query
  void updateQuery(String query) {
    state = state.copyWith(filters: state.filters.copyWith(query: query));
  }

  /// Update location filter
  void updateLocationFilter(String? locationName) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        locationName: locationName,
        clearLocationName: locationName == null,
      ),
    );
  }

  /// Update date range filter
  void updateDateRangeFilter(DateTime? startDate, DateTime? endDate) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        startDate: startDate,
        endDate: endDate,
        clearStartDate: startDate == null,
        clearEndDate: endDate == null,
      ),
    );
  }

  /// Update tags filter
  void updateTagsFilter(List<String> tagIds) {
    state = state.copyWith(
      filters: state.filters.copyWith(tagIds: tagIds),
    );
  }

  /// Update trip filter
  void updateTripFilter(String? tripId) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        tripId: tripId,
        clearTripId: tripId == null,
      ),
    );
  }

  /// Update favorite filter
  void updateFavoriteFilter(bool? favoriteOnly) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        favoriteOnly: favoriteOnly,
        clearFavoriteOnly: favoriteOnly == null,
      ),
    );
  }

  /// Update mood filter
  void updateMoodFilter(String? mood) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        mood: mood,
        clearMood: mood == null,
      ),
    );
  }

  /// Clear all filters except query
  void clearFilters() {
    state = state.copyWith(filters: state.filters.clearFilters());
  }

  /// Clear all state (including query)
  void clearAll() {
    state = JournalSearchState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Refresh search with current filters
  Future<void> refresh() async {
    await search();
  }
}
