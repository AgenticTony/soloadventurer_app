import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';
import 'package:soloadventurer/features/journal/domain/repositories/journal_repository.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_entry_providers.dart';
import 'package:soloadventurer/utils/performance/paginated_list_notifier.dart';
import 'package:soloadventurer/utils/performance/query_optimizer.dart';

// ============================================================================
// Organization Mode
// ============================================================================

/// Defines how journal entries are organized in the list
enum JournalListOrganization {
  /// Organize entries by trip
  byTrip,

  /// Organize entries by date
  byDate,
}

// ============================================================================
// Optimized Journal List State
// ============================================================================

/// Optimized state for journal list operations with pagination and caching
class OptimizedJournalListState {
  /// All journal entries (paginated)
  final List<JournalEntry> entries;

  /// Whether data is currently loading
  final bool isLoading;

  /// Whether loading more data
  final bool isLoadingMore;

  /// Error message if any
  final String? error;

  /// Current organization mode
  final JournalListOrganization organizationMode;

  /// Entries organized by trip (tripId -> entries)
  final Map<String?, List<JournalEntry>> entriesByTrip;

  /// Entries organized by date (date string -> entries)
  final Map<String, List<JournalEntry>> entriesByDate;

  /// Current page
  final int currentPage;

  /// Total pages available
  final int totalPages;

  /// Total items across all pages
  final int totalItems;

  /// Whether more items are available
  final bool hasMore;

  /// Whether reached end of list
  final bool hasReachedMax;

  const OptimizedJournalListState({
    this.entries = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.organizationMode = JournalListOrganization.byDate,
    this.entriesByTrip = const {},
    this.entriesByDate = const {},
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.hasMore = true,
    this.hasReachedMax = false,
  });

  OptimizedJournalListState copyWith({
    List<JournalEntry>? entries,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    JournalListOrganization? organizationMode,
    Map<String?, List<JournalEntry>>? entriesByTrip,
    Map<String, List<JournalEntry>>? entriesByDate,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    bool? hasMore,
    bool? hasReachedMax,
  }) {
    return OptimizedJournalListState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      organizationMode: organizationMode ?? this.organizationMode,
      entriesByTrip: entriesByTrip ?? this.entriesByTrip,
      entriesByDate: entriesByDate ?? this.entriesByDate,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      hasMore: hasMore ?? this.hasMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  /// Whether there are any entries to display
  bool get hasEntries => entries.isNotEmpty;

  /// Whether initial loading
  bool get isInitialLoading => isLoading && entries.isEmpty;

  /// Whether refreshing
  bool get isRefreshing => isLoading && entries.isNotEmpty;

  /// Get the number of groups (trips or dates)
  int get groupCount {
    return organizationMode == JournalListOrganization.byTrip
        ? entriesByTrip.length
        : entriesByDate.length;
  }
}

// ============================================================================
// Optimized Journal List Notifier
// ============================================================================

/// Optimized notifier for managing journal list with pagination and caching
class OptimizedJournalListNotifier extends StateNotifier<OptimizedJournalListState> {
  final JournalRepository _repository;
  final QueryOptimizer _queryOptimizer;
  final PaginationConfig _paginationConfig;

  /// Date formatter for grouping entries by date
  final DateFormat _dateFormatter = DateFormat('MMMM yyyy');

  /// Cache for storing organized data
  Map<String?, List<JournalEntry>> _cachedEntriesByTrip = {};
  Map<String, List<JournalEntry>> _cachedEntriesByDate = {};

  OptimizedJournalListNotifier(
    this._repository, {
    QueryOptimizer? queryOptimizer,
    PaginationConfig? paginationConfig,
  })  : _queryOptimizer = queryOptimizer ?? QueryOptimizer(),
        _paginationConfig = paginationConfig ?? PaginationConfig.forMediumLists,
        super(const OptimizedJournalListState()) {
    loadInitial();
  }

  /// Loads initial page of journal entries with optimization
  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final result = await _queryOptimizer.execute<List<JournalEntry>>(
        'journal_entries_page_1',
        () => _fetchEntriesPage(1, _paginationConfig.pageSize),
        ttl: const Duration(minutes: 2),
      );

      if (result.isError) {
        throw Exception(result.error);
      }

      final entries = result.data ?? [];

      // Sort entries by date (newest first)
      entries.sort((a, b) => b.entryDate.compareTo(a.entryDate));

      // Organize entries
      final entriesByTrip = _organizeByTrip(entries);
      final entriesByDate = _organizeByDate(entries);

      state = state.copyWith(
        entries: entries,
        entriesByTrip: entriesByTrip,
        entriesByDate: entriesByDate,
        isLoading: false,
        currentPage: 1,
        totalItems: entries.length,
        hasMore: entries.length >= _paginationConfig.pageSize,
        hasReachedMax: entries.length < _paginationConfig.pageSize,
      );

      // Update cache
      _cachedEntriesByTrip = entriesByTrip;
      _cachedEntriesByDate = entriesByDate;

      notifyListeners();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      notifyListeners();
    }
  }

  /// Load next page of entries
  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore || state.hasReachedMax) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);
    notifyListeners();

    try {
      final nextPage = state.currentPage + 1;

      final result = await _queryOptimizer.execute<List<JournalEntry>>(
        'journal_entries_page_$nextPage',
        () => _fetchEntriesPage(nextPage, _paginationConfig.pageSize),
        ttl: const Duration(minutes: 2),
      );

      if (result.isError) {
        throw Exception(result.error);
      }

      final newEntries = result.data ?? [];
      final allEntries = [...state.entries, ...newEntries];

      // Sort all entries by date
      allEntries.sort((a, b) => b.entryDate.compareTo(a.entryDate));

      // Reorganize all entries
      final entriesByTrip = _organizeByTrip(allEntries);
      final entriesByDate = _organizeByDate(allEntries);

      state = state.copyWith(
        entries: allEntries,
        entriesByTrip: entriesByTrip,
        entriesByDate: entriesByDate,
        isLoadingMore: false,
        currentPage: nextPage,
        totalItems: allEntries.length,
        hasMore: newEntries.length >= _paginationConfig.pageSize,
        hasReachedMax: newEntries.length < _paginationConfig.pageSize,
      );

      // Update cache
      _cachedEntriesByTrip = entriesByTrip;
      _cachedEntriesByDate = entriesByDate;

      notifyListeners();
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
      notifyListeners();
    }
  }

  /// Fetch entries with field selection for optimization
  Future<List<JournalEntry>> _fetchEntriesPage(int page, int pageSize) async {
    // Use optimized query with field selection
    final entries = await _repository.getEntries();

    // Apply pagination
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    if (startIndex >= entries.length) {
      return [];
    }

    return entries.sublist(
      startIndex,
      endIndex.clamp(0, entries.length),
    );
  }

  /// Organizes entries by trip
  Map<String?, List<JournalEntry>> _organizeByTrip(List<JournalEntry> entries) {
    final Map<String?, List<JournalEntry>> grouped = {};

    for (final entry in entries) {
      final tripId = entry.tripId;

      if (!grouped.containsKey(tripId)) {
        grouped[tripId] = [];
      }

      grouped[tripId]!.add(entry);
    }

    // Sort each trip's entries by date (newest first)
    for (final tripId in grouped.keys) {
      grouped[tripId]!.sort((a, b) => b.entryDate.compareTo(a.entryDate));
    }

    return grouped;
  }

  /// Organizes entries by date
  Map<String, List<JournalEntry>> _organizeByDate(List<JournalEntry> entries) {
    final Map<String, List<JournalEntry>> grouped = {};

    for (final entry in entries) {
      // Group by month and year (e.g., "January 2025")
      final dateKey = _dateFormatter.format(entry.entryDate);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }

      grouped[dateKey]!.add(entry);
    }

    // Sort each date group's entries by date (newest first)
    for (final dateKey in grouped.keys) {
      grouped[dateKey]!.sort((a, b) => b.entryDate.compareTo(a.entryDate));
    }

    return grouped;
  }

  /// Toggle organization mode between byTrip and byDate
  void toggleOrganizationMode() {
    final newMode = state.organizationMode == JournalListOrganization.byTrip
        ? JournalListOrganization.byDate
        : JournalListOrganization.byTrip;

    state = state.copyWith(organizationMode: newMode);
    notifyListeners();
  }

  /// Set organization mode
  void setOrganizationMode(JournalListOrganization mode) {
    state = state.copyWith(organizationMode: mode);
    notifyListeners();
  }

  /// Check if should load more based on index
  bool shouldLoadMore(int index) {
    if (!state.hasMore || state.hasReachedMax) return false;
    final threshold = state.entries.length - _paginationConfig.threshold;
    return index >= threshold;
  }

  /// Refreshes the journal list
  Future<void> refresh() async {
    // Invalidate cache
    _queryOptimizer.invalidateMultiple([
      'journal_entries_page_1',
      for (int i = 2; i <= state.currentPage; i++) 'journal_entries_page_$i',
    ]);

    await loadInitial();
  }

  /// Clears any error state
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
      notifyListeners();
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'queryOptimizer': _queryOptimizer.getQueryStats(),
      'entriesByTripCount': _cachedEntriesByTrip.length,
      'entriesByDateCount': _cachedEntriesByDate.length,
    };
  }
}

// ============================================================================
// Providers
// ============================================================================

/// Provider for query optimizer
final journalQueryOptimizerProvider = Provider<QueryOptimizer>((ref) {
  return QueryOptimizer(cacheConfig: CacheConfig.forLists);
});

/// Provider for optimized journal list state
final optimizedJournalListProvider =
    StateNotifierProvider<OptimizedJournalListNotifier, OptimizedJournalListState>((ref) {
  final repository = ref.watch(journalRepositoryProvider);
  final queryOptimizer = ref.watch(journalQueryOptimizerProvider);

  return OptimizedJournalListNotifier(
    repository,
    queryOptimizer: queryOptimizer,
  );
});

/// Provider for entries grouped by trip (optimized)
final optimizedJournalEntriesByTripProvider = Provider<Map<String?, List<JournalEntry>>>(
  (ref) {
    final listState = ref.watch(optimizedJournalListProvider);
    return listState.entriesByTrip;
  },
);

/// Provider for entries grouped by date (optimized)
final optimizedJournalEntriesByDateProvider = Provider<Map<String, List<JournalEntry>>>(
  (ref) {
    final listState = ref.watch(optimizedJournalListProvider);
    return listState.entriesByDate;
  },
);
