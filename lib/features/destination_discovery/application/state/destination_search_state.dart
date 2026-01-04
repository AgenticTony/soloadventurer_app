import '../../domain/models/destination.dart';
import '../../domain/models/destination_filter.dart';

/// State class for destination search
class DestinationSearchState {
  /// List of search results
  final List<Destination> results;

  /// Current filter being used for search
  final DestinationFilter filter;

  /// Whether there are more results to load
  final bool hasMore;

  /// Current offset for pagination
  final int currentOffset;

  /// Total count of results available
  final int? totalCount;

  /// Whether this is the initial search
  final bool isInitial;

  /// Creates an initial search state
  const DestinationSearchState.initial()
      : results = const [],
        filter = const DestinationFilter(),
        hasMore = true,
        currentOffset = 0,
        totalCount = null,
        isInitial = true;

  /// Creates a search state with the given fields
  const DestinationSearchState({
    required this.results,
    required this.filter,
    required this.hasMore,
    required this.currentOffset,
    this.totalCount,
    this.isInitial = false,
  });

  /// Creates a copy of this state with the given fields replaced
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
  int get resultCount => results.length;

  /// Returns true if no results have been found
  bool get isEmpty => results.isEmpty && !isInitial;

  /// Returns true if results have been loaded
  bool get hasResults => results.isNotEmpty;
}
