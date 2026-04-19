import 'dart:async';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/destination_filter.dart';
import '../../application/providers/destination_search_provider.dart';
import '../../application/providers/unified_discovery_provider.dart';
import '../../application/providers/filter_provider.dart';
import '../../application/providers/activity_selection_provider.dart';
import '../widgets/filter_chips.dart';
import '../widgets/filter_modal.dart';
import '../utils/error_handler.dart';
import 'viator_booking_screen.dart';

/// Main screen for destination discovery with search, filters, and layered API tabs.
///
/// This screen provides a comprehensive destination discovery experience:
/// - Search bar for text-based queries
/// - Quick filter chips for common filters
/// - Tab layout: "Eat & Drink" (Google) | "Things to Do" (Viator) | "Sights" (Google)
/// - Grid/list of results from both Google Places and Viator APIs
/// - Pull-to-refresh per tab
/// - Loading, error, and empty states
///
/// The screen integrates with:
/// - [UnifiedDiscoveryProvider] for tabbed Google Places + Viator results
/// - [DestinationSearchProvider] for GraphQL-based destination search
/// - [FilterProvider] for filter management
class DestinationDiscoveryScreen extends ConsumerStatefulWidget {
  const DestinationDiscoveryScreen({
    super.key,
    this.initialFilter,
  });

  /// Optional initial filter from deep link.
  final DestinationFilter? initialFilter;

  /// Route name for navigation.
  static const String routeName = '/destinations';

  @override
  ConsumerState<DestinationDiscoveryScreen> createState() =>
      _DestinationDiscoveryScreenState();
}

class _DestinationDiscoveryScreenState
    extends ConsumerState<DestinationDiscoveryScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: DiscoveryTab.values.length,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyInitialFilter();
      _performSearch();
    });
  }

  void _applyInitialFilter() {
    if (widget.initialFilter != null &&
        widget.initialFilter!.hasActiveFilters) {
      final filterNotifier = ref.read(filterProvider.notifier);
      filterNotifier.updateFilter(widget.initialFilter!);

      if (widget.initialFilter!.searchQuery != null) {
        _searchController.text = widget.initialFilter!.searchQuery!;
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final tab = DiscoveryTab.values[_tabController.index];
    ref.read(unifiedDiscoveryProvider.notifier).setTab(tab);
  }

  void _onScroll() {
    // Reserved for future pagination on unified results.
  }

  Future<void> _performSearch() async {
    final filter = ref.read(filterProvider);
    final searchNotifier = ref.read(destinationSearchProvider.notifier);
    try {
      await searchNotifier.search(filter);
    } catch (_) {
      // Error is handled in the provider's state.
    }
  }

  void _onSearchChanged(String query) {
    final filterNotifier = ref.read(filterProvider.notifier);
    filterNotifier.updateSearchQuery(query.isEmpty ? null : query);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _performSearch();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    final filterNotifier = ref.read(filterProvider.notifier);
    filterNotifier.updateSearchQuery(null);
    _performSearch();
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Destinations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _openFilterModal,
            tooltip: 'Advanced Filters',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.restaurant), text: 'Eat & Drink'),
            Tab(icon: Icon(Icons.local_activity), text: 'Things to Do'),
            Tab(icon: Icon(Icons.photo_camera), text: 'Sights'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(theme),
          _buildFilterChips(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Eat & Drink (Google Places)
                _buildUnifiedTabView(theme, DiscoveryTab.eatDrink),
                // Tab 2: Things to Do (Viator)
                _buildUnifiedTabView(theme, DiscoveryTab.thingsToDo),
                // Tab 3: Sights (Google Places)
                _buildUnifiedTabView(theme, DiscoveryTab.sights),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildFilterChips() {
    return FilterChips(
      onFilterChanged: _performSearch,
    );
  }

  /// Build the unified tab view for a specific discovery tab.
  Widget _buildUnifiedTabView(ThemeData theme, DiscoveryTab tab) {
    final unifiedState = ref.watch(unifiedDiscoveryProvider);

    return unifiedState.when(
      data: (state) {
        final results = state.tabResults[tab];

        // Not loaded yet.
        if (results == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Empty state.
        if (results.isEmpty) {
          return _buildEmptyState(theme, tab);
        }

        // Results grid.
        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(unifiedDiscoveryProvider.notifier).refreshActiveTab();
          },
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return _UnifiedPlaceCard(
                result: result,
                onTap: () => _onPlaceTap(result),
              );
            },
          ),
        );
      },
      loading: () => _buildShimmerGrid(theme),
      error: (error, _) => _buildErrorState(theme, error),
    );
  }

  void _onPlaceTap(UnifiedPlaceResult result) {
    if (result.isBookable) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ViatorBookingScreen(
            productCode: result.viatorProductCode ?? result.activity.id,
            productTitle: result.activity.name,
            price: result.activity.cost ?? 0,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Viewing ${result.activity.name}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Widget _buildEmptyState(ThemeData theme, DiscoveryTab tab) {
    final hasFilter = ref.read(filterProvider).hasActiveFilters;

    return DestinationEmptyStateWidget(
      title: hasFilter ? 'No results found' : 'Explore ${tab.label}',
      message: hasFilter
          ? 'Try adjusting your filters or search terms.'
          : 'Search for a destination to discover ${tab.label.toLowerCase()}.',
      icon: Icons.explore,
      actionLabel: hasFilter ? 'Clear All Filters' : null,
      onAction: hasFilter
          ? () {
              ref.read(filterProvider.notifier).reset();
              _clearSearch();
            }
          : null,
    );
  }

  Widget _buildErrorState(ThemeData theme, Object error) {
    return DestinationErrorWidget(
      error: error,
      onRetry: () => ref.read(unifiedDiscoveryProvider.notifier).refreshActiveTab(),
      customMessage: _getCustomErrorMessage(error),
    );
  }

  String? _getCustomErrorMessage(Object error) {
    if (error is NetworkConnectivityException) {
      return 'Unable to search. Please check your internet connection and try again.';
    } else if (error is NetworkTimeoutException) {
      return 'Search request timed out. Please try again.';
    } else if (error is ServerException) {
      return 'Our servers are experiencing issues. Please try again later.';
    }
    return null;
  }

  Widget _buildShimmerGrid(ThemeData theme) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _ShimmerCard(theme: theme),
    );
  }
}

/// Card displaying a unified place result (Google Places or Viator).
class _UnifiedPlaceCard extends ConsumerWidget {
  final UnifiedPlaceResult result;
  final VoidCallback onTap;

  const _UnifiedPlaceCard({
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activity = result.activity;

    final isSelected = ref.watch(activitySelectionProvider).contains(result.activity.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: () {
          ref.read(activitySelectionProvider.notifier).toggleSelection(result);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isSelected
                    ? 'Removed ${result.activity.name} from interests'
                    : 'Added ${result.activity.name} to your interests',
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (activity.photoUrl != null && activity.photoUrl!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: activity.photoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => _ImagePlaceholder(theme: theme),
                    )
                  else
                    _ImagePlaceholder(theme: theme),

                  // Source badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: result.isBookable
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            result.isBookable ? Icons.local_activity : Icons.place,
                            size: 14,
                            color: result.isBookable
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            result.isBookable ? 'Bookable' : 'Place',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: result.isBookable
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Price badge (Viator only)
                  if (result.hasPrice)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade700,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          result.formattedPrice!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (activity.rating > 0)
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                          const SizedBox(width: 2),
                          Text(
                            activity.rating.toStringAsFixed(1),
                            style: theme.textTheme.labelSmall,
                          ),
                          if (activity.reviewCount > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '(${activity.reviewCount})',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    const Spacer(),
                    // Book button for Viator items
                    if (result.isBookable)
                      SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          child: ElevatedButton.icon(
                            onPressed: onTap,
                            icon: const Icon(Icons.shopping_cart, size: 14),
                            label: const Text('Book'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              textStyle: theme.textTheme.labelSmall,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder for missing images.
class _ImagePlaceholder extends StatelessWidget {
  final ThemeData theme;
  const _ImagePlaceholder({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

/// Shimmer placeholder card.
class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard({required this.theme});
  final ThemeData theme;

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final baseColor = theme.colorScheme.surfaceContainerHighest;
    final highlightColor = theme.colorScheme.surface;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                Color.lerp(baseColor, highlightColor, value)!,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 80,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 10,
                        width: 60,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
