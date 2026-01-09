import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/destination.dart';
import '../../domain/models/destination_filter.dart';
import '../../domain/repositories/destination_repository.dart';
import '../state/destination_search_state.dart';

/// Provider for the destination repository
///
/// This provider must be overridden in the main application to provide
/// the actual implementation of [DestinationRepository].
final destinationRepositoryProvider = Provider<DestinationRepository>((ref) {
  throw UnimplementedError(
    'destinationRepositoryProvider must be overridden with actual implementation',
  );
});

/// Provider for destination search state management
///
/// This provider manages the state of destination search operations including:
/// - Search results with pagination support
/// - Loading and error states
/// - Filter management
/// - Load more functionality
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
final destinationSearchProvider =
    StateNotifierProvider<DestinationSearchNotifier, AsyncValue<DestinationSearchState>>((ref) {
  final repository = ref.watch(destinationRepositoryProvider);
  return DestinationSearchNotifier(repository);
});

/// Notifier for managing destination search state
///
/// This notifier handles all destination search operations including:
/// - Searching destinations with filters
/// - Loading more results (pagination)
/// - Clearing search results
/// - Managing filter state
class DestinationSearchNotifier
    extends StateNotifier<AsyncValue<DestinationSearchState>> {
  final DestinationRepository _repository;

  /// Default page size for pagination
  static const int _defaultPageSize = 20;

  /// Creates a new [DestinationSearchNotifier]
  ///
  /// The [repository] parameter is required for performing search operations.
  DestinationSearchNotifier(this._repository)
      : super(const AsyncValue.data(DestinationSearchState.initial()));

  /// Search for destinations with the given filter
  ///
  /// The [filter] parameter specifies the search criteria. If reset is true,
  /// pagination will be reset to load results from the beginning.
  ///
  /// Throws an exception if the search fails.
  Future<void> search(DestinationFilter filter, {bool reset = true}) async {
    state = const AsyncValue.loading();

    try {
      // Reset pagination if requested
      final searchFilter = reset ? filter.resetPagination() : filter;

      // Perform search
      final destinations = await _repository.searchDestinations(searchFilter);

      // Update state with results
      state = AsyncValue.data(DestinationSearchState(
        results: destinations,
        filter: searchFilter,
        hasMore: destinations.length >= searchFilter.limit,
        currentOffset: searchFilter.offset + destinations.length,
        totalCount: destinations.length,
      ));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Load more destinations for the current search
  ///
  /// This method uses the current filter and offset to load the next page
  /// of results. Returns true if more results were loaded, false otherwise.
  ///
  /// Throws an exception if loading more results fails.
  Future<bool> loadMore() async {
    // Guard against loading more if not in success state
    if (!state.hasValue || state is AsyncLoading) {
      return false;
    }

    final currentState = state.value!;

    // Guard against loading more if no more results available
    if (!currentState.hasMore) {
      return false;
    }

    // Update state to loading while keeping current results
    state = AsyncValue.data(currentState);

    try {
      // Build filter for next page
      final nextFilter = currentState.filter.copyWith(
        offset: currentState.currentOffset,
        limit: _defaultPageSize,
      );

      // Fetch next page
      final newDestinations = await _repository.searchDestinations(nextFilter);

      // Combine existing and new results
      final combinedResults = [...currentState.results, ...newDestinations];

      // Update state
      state = AsyncValue.data(currentState.copyWith(
        results: combinedResults,
        filter: nextFilter,
        hasMore: newDestinations.length >= _defaultPageSize,
        currentOffset: nextFilter.offset + newDestinations.length,
        totalCount: (currentState.totalCount ?? 0) + newDestinations.length,
      ));

      return newDestinations.isNotEmpty;
    } catch (error, stackTrace) {
      // Revert to previous state on error
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Refresh the current search with the same filter
  ///
  /// This method re-executes the search with the current filter, resetting
  /// pagination to the beginning. Useful for pull-to-refresh functionality.
  ///
  /// Throws an exception if the refresh fails.
  Future<void> refresh() async {
    if (!state.hasValue) {
      return;
    }

    final currentState = state.value!;
    await search(currentState.filter, reset: true);
  }

  /// Clear all search results and reset to initial state
  ///
  /// This method resets the state to initial, clearing all results
  /// and filter settings.
  void clear() {
    state = const AsyncValue.data(DestinationSearchState.initial());
  }

  /// Update the filter without performing a search
  ///
  /// The [filter] parameter will be stored in the state but no search
  /// will be performed. Call [search] to execute the search.
  ///
  /// This is useful for updating filter state before triggering a search
  /// (e.g., when user is still adjusting filter options).
  void updateFilter(DestinationFilter filter) {
    if (!state.hasValue) {
      return;
    }

    final currentState = state.value!;
    state = AsyncValue.data(currentState.copyWith(filter: filter));
  }

  /// Reset the filter to default values
  ///
  /// This method resets the filter to default without performing a search.
  void resetFilter() {
    if (!state.hasValue) {
      return;
    }

    final currentState = state.value!;
    state = AsyncValue.data(currentState.copyWith(
      filter: const DestinationFilter(),
    ));
  }

  /// Search with a text query
  ///
  /// The [query] parameter is the text to search for. This is a convenience
  /// method that updates the filter's searchQuery and performs a search.
  ///
  /// Throws an exception if the search fails.
  Future<void> searchQuery(String query) async {
    if (!state.hasValue) {
      return;
    }

    final currentState = state.value!;
    final updatedFilter = currentState.filter.copyWith(searchQuery: query);
    await search(updatedFilter);
  }
}
