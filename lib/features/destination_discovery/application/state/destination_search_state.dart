import '../../domain/models/destination.dart';
import '../../domain/models/destination_filter.dart';

/// State class for destination search
///
/// This class holds the current state of destination search operations including:
/// - Search results list
/// - Active filter criteria
/// - Pagination metadata (hasMore, currentOffset, totalCount)
/// - Initial state tracking
///
/// The state is immutable and uses the [copyWith] pattern for updates.
///
/// Example:
/// ```dart
/// // Initial state
/// final initialState = DestinationSearchState.initial();
///
/// // State with results
/// final loadedState = DestinationSearchState(
///   results: [destination1, destination2],
///   filter: DestinationFilter(searchQuery: 'beach'),
///   hasMore: true,
///   currentOffset: 20,
///   totalCount: 100,
/// );
///
/// // Copy with updates
/// final updatedState = loadedState.copyWith(
///   results: [...loadedState.results, destination3],
///   currentOffset: 21,
/// );
/// ```
class DestinationSearchState {
  /// List of search results
  ///
  /// Contains the destinations loaded so far. This list grows as more
  /// results are loaded via pagination.
  final List<Destination> results;

  /// Current filter being used for search
  ///
  /// Stores the active filter criteria including search query, budget level,
  /// safety score, activity level, and other filter parameters.
  final DestinationFilter filter;

  /// Whether there are more results to load
  ///
  /// When true, indicates that additional destinations can be loaded by
  /// calling the loadMore() method. When false, all available results
  /// have been loaded.
  final bool hasMore;

  /// Current offset for pagination
  ///
  /// The number of results that have been loaded so far. Used as the
  /// starting point for the next page of results.
  final int currentOffset;

  /// Total count of results available
  ///
  /// The total number of destinations matching the filter. This may be
  /// null if the API doesn't provide total counts.
  final int? totalCount;

  /// Whether this is the initial search
  ///
  /// True when the state is in its initial form before any search has
  /// been performed. Used to distinguish between "no results" and
  /// "search not performed yet".
  final bool isInitial;

  /// Creates an initial search state
  ///
  /// This constructor creates a state with empty results, default filter,
  /// pagination reset, and isInitial set to true. Use this to reset the
  /// search to its initial state.
  const DestinationSearchState.initial()
      : results = const [],
        filter = const DestinationFilter(),
        hasMore = true,
        currentOffset = 0,
        totalCount = null,
        isInitial = true;

  /// Creates a search state with the given fields
  ///
  /// All fields except [totalCount] and [isInitial] are required.
  /// Use [copyWith] to create modified versions of an existing state.
  const DestinationSearchState({
    required this.results,
    required this.filter,
    required this.hasMore,
    required this.currentOffset,
    this.totalCount,
    this.isInitial = false,
  });

  /// Creates a copy of this state with the given fields replaced
  ///
  /// This method is used for immutable state updates. Only the fields
  /// provided as parameters will be replaced; all other fields retain
  /// their current values.
  ///
  /// Example:
  /// ```dart
  /// final newState = oldState.copyWith(
  ///   results: newResults,
  ///   hasMore: false,
  /// );
  /// ```
  DestinationSearchState copyWith({
    List<Destination>? results,
    DestinationFilter? filter,
    bool? hasMore,
    int? currentOffset,
    int? totalCount,
    bool? isInitial,
  }) {
    return DestinationSearchState(
      results: results ?? this.results,
      filter: filter ?? this.filter,
      hasMore: hasMore ?? this.hasMore,
      currentOffset: currentOffset ?? this.currentOffset,
      totalCount: totalCount ?? this.totalCount,
      isInitial: isInitial ?? this.isInitial,
    );
  }

  /// Returns the number of results loaded so far
  ///
  /// This is a convenience getter that returns the length of the results list.
  int get resultCount => results.length;

  /// Returns true if no results have been found
  ///
  /// This is true when results are empty AND the search is not in its
  /// initial state. This distinguishes between "searched but found nothing"
  /// and "haven't searched yet".
  bool get isEmpty => results.isEmpty && !isInitial;

  /// Returns true if results have been loaded
  ///
  /// This is the opposite of [isEmpty] and is useful for conditional UI rendering.
  bool get hasResults => results.isNotEmpty;
}
