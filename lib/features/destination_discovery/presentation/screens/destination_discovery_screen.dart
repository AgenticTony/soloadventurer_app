import 'dart:async';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/destination.dart';
import '../../domain/models/destination_filter.dart';
import '../../application/state/destination_search_state.dart';
import '../../application/providers/destination_search_provider.dart';
import '../../application/providers/filter_provider.dart';
import '../widgets/destination_card.dart';
import '../widgets/filter_chips.dart';
import '../widgets/filter_modal.dart';
import '../utils/error_handler.dart';

/// Main screen for destination discovery with search and filters.
///
/// This screen provides a comprehensive destination discovery experience including:
/// - Search bar for text-based queries
/// - Quick filter chips for common filters
/// - Advanced filter modal for detailed filtering
/// - Grid/list of destination results
/// - Pull-to-refresh and infinite scroll pagination
/// - Loading, error, and empty states
///
/// The screen integrates with [DestinationSearchProvider] for search state
/// and [FilterProvider] for filter management.
///
/// Deep linking support:
/// The [initialFilter] parameter allows pre-filtering from deep links.
/// Example: `DestinationDiscoveryScreen(initialFilter: DestinationFilter(...))`
class DestinationDiscoveryScreen extends ConsumerStatefulWidget {
  /// Creates a new [DestinationDiscoveryScreen]
  ///
  /// The [initialFilter] parameter can be used to pre-apply filters from deep links.
  const DestinationDiscoveryScreen({
    super.key,
    this.initialFilter,
  });

  /// Optional initial filter from deep link
  final DestinationFilter? initialFilter;

  /// Route name for navigation
  static const String routeName = '/destinations';

  @override
  ConsumerState<DestinationDiscoveryScreen> createState() =>
      _DestinationDiscoveryScreenState();
}

class _DestinationDiscoveryScreenState
    extends ConsumerState<DestinationDiscoveryScreen> {
  /// Scroll controller for pagination
  final ScrollController _scrollController = ScrollController();

  /// Search text controller
  final TextEditingController _searchController = TextEditingController();

  /// Timer for search debouncing
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Apply initial filter from deep link and perform search
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyInitialFilter();
      _performSearch();
    });
  }

  /// Apply initial filter from deep link if provided
  void _applyInitialFilter() {
    if (widget.initialFilter != null &&
        widget.initialFilter!.hasActiveFilters) {
      final filterNotifier = ref.read(filterProvider.notifier);
      filterNotifier.updateFilter(widget.initialFilter!);

      // Update search controller if search query is provided
      if (widget.initialFilter!.searchQuery != null) {
        _searchController.text = widget.initialFilter!.searchQuery!;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Handles scroll events for pagination
  void _onScroll() {
    if (_isBottomReached) {
      _loadMoreDestinations();
    }
  }

  /// Check if user has scrolled to the bottom
  bool get _isBottomReached {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.8); // Trigger at 80% of scroll
  }

  /// Perform search with current filter
  Future<void> _performSearch() async {
    final filter = ref.read(filterProvider);
    final searchNotifier = ref.read(destinationSearchProvider.notifier);

    try {
      await searchNotifier.search(filter);
    } catch (error) {
      // Error is handled in the provider's state
    }
  }

  /// Load more destinations (pagination)
  Future<void> _loadMoreDestinations() async {
    final searchState = ref.read(destinationSearchProvider);
    final searchNotifier = ref.read(destinationSearchProvider.notifier);

    // Guard: Don't load if already loading or no more results
    if (!searchState.hasValue ||
        searchState is AsyncLoading ||
        !searchState.value!.hasMore) {
      return;
    }

    try {
      await searchNotifier.loadMore();
    } catch (error) {
      // Error is handled in the provider's state
    }
  }

  /// Refresh search results (pull-to-refresh)
  Future<void> _refreshDestinations() async {
    final searchNotifier = ref.read(destinationSearchProvider.notifier);

    try {
      await searchNotifier.refresh();
    } catch (error) {
      // Error is handled in the provider's state
    }
  }

  /// Handle search text changes with debouncing
  void _onSearchChanged(String query) {
    final filterNotifier = ref.read(filterProvider.notifier);
    filterNotifier.updateSearchQuery(query.isEmpty ? null : query);

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Schedule new search with debounce
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _performSearch();
      }
    });
  }

  /// Clear search text and reset filter
  void _clearSearch() {
    _searchController.clear();
    final filterNotifier = ref.read(filterProvider.notifier);
    filterNotifier.updateSearchQuery(null);
    _performSearch();
  }

  /// Open advanced filter modal
  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModal(
        onApply: _performSearch,
      ),
    );
  }

  /// Navigate to destination detail
  void _navigateToDetail(Destination destination) {
    // TODO: Implement navigation in subtask 6.1
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to ${destination.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Handle destination save/bookmark
  void _onBookmarkTap(Destination destination) {
    // TODO: Implement save functionality in subtask 5.2 or 7.1
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${destination.name} saved to wishlist'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchState = ref.watch(destinationSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Destinations'),
        actions: [
          // Advanced filter button
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _openFilterModal,
            tooltip: 'Advanced Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(theme),

          // Filter chips
          _buildFilterChips(),

          // Results list
          Expanded(
            child: _buildResultsList(theme, searchState),
          ),
        ],
      ),
    );
  }

  /// Build the search bar
  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Semantics(
        label: 'Search destinations',
        hint: 'Enter destination name to search',
        textField: true,
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search destinations...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  /// Build the filter chips row
  Widget _buildFilterChips() {
    return FilterChips(
      onFilterChanged: _performSearch,
    );
  }

  /// Build the results list with proper state handling
  Widget _buildResultsList(
      ThemeData theme, AsyncValue<DestinationSearchState> searchState) {
    return searchState.when(
      data: (state) {
        // Initial state - show loading indicator in center
        if (state.isInitial) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Empty state
        if (state.isEmpty) {
          return _buildEmptyState(theme);
        }

        // Results list with pull-to-refresh
        return RefreshIndicator(
          onRefresh: _refreshDestinations,
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: state.resultCount + (state.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the end if more results available
              if (index == state.resultCount) {
                return _buildLoadingMoreIndicator(theme);
              }

              final destination = state.results[index];
              return DestinationCard(
                key: ValueKey(destination.id),
                destination: destination,
                onTap: () => _navigateToDetail(destination),
                onBookmarkTap: () => _onBookmarkTap(destination),
              );
            },
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => _buildErrorState(theme, error),
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState(ThemeData theme) {
    final filter = ref.read(filterProvider);
    final hasActiveFilters = filter.hasActiveFilters;

    return DestinationEmptyStateWidget(
      title: hasActiveFilters ? 'No destinations found' : 'No destinations yet',
      message: hasActiveFilters
          ? 'Try adjusting your filters or search terms to find more destinations.'
          : 'Start exploring destinations around the world!',
      icon: hasActiveFilters ? Icons.filter_list_off : Icons.explore,
      actionLabel: hasActiveFilters ? 'Clear All Filters' : 'Discover Now',
      onAction: hasActiveFilters
          ? () {
              ref.read(filterProvider.notifier).reset();
              _clearSearch();
            }
          : null,
    );
  }

  /// Build error state widget
  Widget _buildErrorState(ThemeData theme, Object error) {
    return DestinationErrorWidget(
      error: error,
      onRetry: _performSearch,
      customMessage: _getCustomErrorMessage(error),
    );
  }

  /// Get custom error message based on error type
  String? _getCustomErrorMessage(Object error) {
    // Provide contextual error messages for search
    if (error is NetworkConnectivityException) {
      return 'Unable to search destinations. Please check your internet connection and try again.';
    } else if (error is NetworkTimeoutException) {
      return 'Search request timed out. Please try again.';
    } else if (error is ServerException) {
      return 'Our servers are experiencing issues. Please try again later.';
    }
    // Use default message from error handler
    return null;
  }

  /// Build loading indicator for "load more" pagination
  Widget _buildLoadingMoreIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        color: theme.colorScheme.primary,
      ),
    );
  }
}
