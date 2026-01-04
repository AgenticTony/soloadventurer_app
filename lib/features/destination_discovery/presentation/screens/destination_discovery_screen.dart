import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/destination.dart';
import '../../application/providers/destination_search_provider.dart';
import '../../application/providers/filter_provider.dart';
import '../widgets/destination_card.dart';
import '../widgets/filter_chips.dart';
import '../widgets/filter_modal.dart';

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
class DestinationDiscoveryScreen extends ConsumerStatefulWidget {
  /// Creates a new [DestinationDiscoveryScreen]
  const DestinationDiscoveryScreen({super.key});

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

  /// Debounce timer for search
  DateTime? _lastSearchTime;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Perform initial search on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performSearch();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
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

    // Debounce search to avoid excessive API calls
    final now = DateTime.now();
    if (_lastSearchTime == null ||
        now.difference(_lastSearchTime!).inMilliseconds > 500) {
      _lastSearchTime = now;
      _performSearch();
    } else {
      // Schedule search if not already scheduled
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && DateTime.now().difference(_lastSearchTime!).inMilliseconds >= 500) {
          _performSearch();
        }
      });
    }
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
              color: theme.colorScheme.outline.withOpacity(0.5),
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
          fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
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
  Widget _buildResultsList(ThemeData theme, AsyncValue<DestinationSearchState> searchState) {
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No destinations found',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search terms',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(filterProvider.notifier).reset();
                _clearSearch();
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear All Filters'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build error state widget
  Widget _buildErrorState(ThemeData theme, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _performSearch,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
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
