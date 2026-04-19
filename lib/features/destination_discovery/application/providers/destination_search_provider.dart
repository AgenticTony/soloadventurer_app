import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/destination_filter.dart';
import '../state/destination_search_state.dart';
import 'destination_repository_provider.dart';

part 'destination_search_provider.g.dart';

/// Riverpod 3.0 Migration Notes:
/// - Converted from `StateNotifier<AsyncValue<T>>` to `AsyncNotifier<T>`
/// - Dependencies injected via ref.watch() in build() method
/// - build() returns `Future<T>` not `AsyncValue<T>` (Riverpod 3.0 handles wrapping)
/// - State is automatically `AsyncValue<DestinationSearchState>` when consumed
/// - Initialization logic moved from constructor to build() method

/// Provider for destination search state management
///
/// This provider manages the state of destination search operations including:
/// - Search results with pagination support
/// - Loading and error states
/// - Filter management
/// - Load more functionality
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
/// State is automatically wrapped in AsyncValue when consumed.
///
/// Usage:
/// ```dart
/// final searchState = ref.watch(destinationSearchProvider);
/// final searchNotifier = ref.read(destinationSearchProvider.notifier);
///
/// // Perform search
/// await searchNotifier.search(filter);
///
/// // Load more results
/// await searchNotifier.loadMore();
///
/// // Clear search
/// searchNotifier.clear();
/// ```
@riverpod
class DestinationSearch extends _$DestinationSearch {
  /// Default page size for pagination
  static const int _defaultPageSize = 20;

  /// Initialize the notifier and perform initial search
  ///
  /// Riverpod 3.0: build() returns `Future<DestinationSearchState>`
  /// AsyncValue wrapping is handled automatically by the framework
  @override
  Future<DestinationSearchState> build() async {
    // Get dependencies via ref.watch()
    ref.watch(destinationRepositoryProvider);

    // Return initial state (no auto-load for search provider)
    return DestinationSearchState.initial();
  }

  /// Search for destinations with the given filter
  ///
  /// The [filter] parameter specifies the search criteria. If reset is true,
  /// pagination will be reset to load results from the beginning.
  ///
  /// Throws an exception if the search fails.
  Future<void> search(DestinationFilter filter, {bool reset = true}) async {
    // Get repository
    final repository = ref.read(destinationRepositoryProvider);

    // Reset pagination if requested
    final searchFilter = reset ? filter.resetPagination() : filter;

    // Set loading state using AsyncValue.guard
    state = await AsyncValue.guard(() async {
      // Perform search
      final destinations = await repository.searchDestinations(searchFilter);

      // Return new state with results
      return DestinationSearchState(
        results: destinations,
        filter: searchFilter,
        hasMore: destinations.length >= searchFilter.limit,
        currentOffset: searchFilter.offset + destinations.length,
        totalCount: destinations.length,
      );
    });
  }

  /// Load more destinations for the current search
  ///
  /// This method uses the current filter and offset to load the next page
  /// of results. Returns true if more results were loaded, false otherwise.
  ///
  /// Throws an exception if loading more results fails.
  Future<bool> loadMore() async {
    // Get repository
    final repository = ref.read(destinationRepositoryProvider);

    // Guard against loading more if not in success state
    final currentState = state.value;
    if (currentState == null || state.isLoading) {
      return false;
    }

    // Guard against loading more if no more results available
    if (!currentState.hasMore) {
      return false;
    }

    // Build filter for next page
    final nextFilter = currentState.filter.copyWith(
      offset: currentState.currentOffset,
      limit: _defaultPageSize,
    );

    // Set loading state using AsyncValue.guard
    state = await AsyncValue.guard(() async {
      // Fetch next page
      final newDestinations = await repository.searchDestinations(nextFilter);

      // Combine existing and new results
      final combinedResults = [...currentState.results, ...newDestinations];

      // Return updated state
      return currentState.copyWith(
        results: combinedResults,
        filter: nextFilter,
        hasMore: newDestinations.length >= _defaultPageSize,
        currentOffset: nextFilter.offset + newDestinations.length,
        totalCount: (currentState.totalCount ?? 0) + newDestinations.length,
      );
    });

    // Return whether new results were loaded
    final newState = state.value;
    if (newState != null) {
      return newState.results.length > currentState.results.length;
    }
    return false;
  }

  /// Refresh the current search with the same filter
  ///
  /// This method re-executes the search with the current filter, resetting
  /// pagination to the beginning. Useful for pull-to-refresh functionality.
  ///
  /// Throws an exception if the refresh fails.
  Future<void> refresh() async {
    final currentState = state.value;
    if (currentState == null) {
      return;
    }

    await search(currentState.filter, reset: true);
  }

  /// Clear all search results and reset to initial state
  ///
  /// This method resets the state to initial, clearing all results
  /// and filter settings.
  void clear() {
    state = AsyncValue.data(DestinationSearchState.initial());
  }

  /// Update the filter without performing a search
  ///
  /// The [filter] parameter will be stored in the state but no search
  /// will be performed. Call [search] to execute the search.
  ///
  /// This is useful for updating filter state before triggering a search
  /// (e.g., when user is still adjusting filter options).
  void updateFilter(DestinationFilter filter) {
    final currentState = state.value;
    if (currentState == null) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(filter: filter));
  }

  /// Reset the filter to default values
  ///
  /// This method resets the filter to default without performing a search.
  void resetFilter() {
    final currentState = state.value;
    if (currentState == null) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(
      filter: DestinationFilter(),
    ));
  }

  /// Search with a text query
  ///
  /// The [query] parameter is the text to search for. This is a convenience
  /// method that updates the filter's searchQuery and performs a search.
  ///
  /// Throws an exception if the search fails.
  Future<void> searchQuery(String query) async {
    final currentState = state.value;
    if (currentState == null) {
      return;
    }

    final updatedFilter = currentState.filter.copyWith(searchQuery: query);
    await search(updatedFilter);
  }
}
