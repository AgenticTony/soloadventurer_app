import 'package:flutter/material.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/presentation/providers/auth_notifier_provider.dart';
import '../../domain/models/destination.dart';
import '../../domain/models/saved_destination.dart';
import '../../domain/models/curated_list.dart';
import '../../application/providers/curated_lists_provider.dart';
import '../../application/providers/saved_destinations_provider.dart';
import '../widgets/destination_card.dart';
import '../widgets/safety_score_badge.dart';
import '../widgets/solo_suitability_badge.dart';
import '../utils/error_handler.dart';

/// Detailed view of a curated list showing all its destinations.
///
/// This screen displays:
/// - Curated list header with cover image, title, and description
/// - List metadata (destination count, curator info, view/save counts)
/// - Safety and solo suitability score averages (if available)
/// - Best time to visit and duration recommendations
/// - Grid of destinations in the curated list
/// - Save/share functionality
/// - Pull-to-refresh support
/// - Loading, error, and empty states
///
/// The screen integrates with:
/// - [CuratedListsProvider] for curated list data
/// - [SavedDestinationsProvider] for bookmark functionality
class CuratedListDetailScreen extends ConsumerStatefulWidget {
  /// Creates a new [CuratedListDetailScreen]
  const CuratedListDetailScreen({
    super.key,
    required this.listId,
  });

  /// The unique identifier of the curated list to display
  final String listId;

  /// Route name for navigation
  static const String routeName = '/curated-lists/:id';

  @override
  ConsumerState<CuratedListDetailScreen> createState() =>
      _CuratedListDetailScreenState();
}

class _CuratedListDetailScreenState
    extends ConsumerState<CuratedListDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load curated list on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCuratedList();
    });
  }

  /// Load curated list details
  Future<void> _loadCuratedList() async {
    final curatedListsNotifier = ref.read(curatedListsProvider.notifier);

    try {
      await curatedListsNotifier.loadCuratedList(widget.listId);
    } catch (error) {
      // Error is handled in the provider's state
    }
  }

  /// Refresh curated list data
  Future<void> _refreshList() async {
    final curatedListsNotifier = ref.read(curatedListsProvider.notifier);

    try {
      await curatedListsNotifier.refreshSelectedList();
    } catch (error) {
      // Error is handled in the provider's state
    }
  }

  /// Share curated list
  void _shareList() {
    // TODO: Implement share functionality in later phase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Handle save/bookmark destination
  Future<void> _toggleBookmark(Destination destination) async {
    // Get current user from auth state
    final authState = ref.read(authProvider);

    if (!authState.hasValue || authState.value!.user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to save destinations'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final userId = authState.value!.user!.id;

    // Check if already saved
    final savedState = ref.read(savedDestinationsProvider(userId));
    final isAlreadySaved = savedState.hasValue &&
        savedState.value!.isDestinationInWishlist(destination.id);

    final savedNotifier = ref.read(savedDestinationsProvider(userId).notifier);

    try {
      if (isAlreadySaved) {
        // Unsave the destination
        await savedNotifier.unsaveDestination(
          userId: userId,
          destinationId: destination.id,
          saveType: SaveType.wishlist,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${destination.name} removed from wishlist'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Save the destination
        await savedNotifier.saveDestination(
          userId: userId,
          destination: destination,
          saveType: SaveType.wishlist,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${destination.name} saved to wishlist'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${error.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Navigate to destination detail
  void _navigateToDestination(Destination destination) {
    // TODO: Implement navigation in subtask 6.1
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${destination.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final curatedListsState = ref.watch(curatedListsProvider);

    // Get auth state for save functionality
    final authState = ref.watch(authProvider);
    final userId = authState.value?.user?.id;
    final savedState =
        userId != null ? ref.watch(savedDestinationsProvider(userId)) : null;

    return Scaffold(
      body: curatedListsState.when(
        data: (state) {
          final curatedList = state.selectedList;

          if (curatedList == null) {
            return _buildEmptyState(theme);
          }

          return RefreshIndicator(
            onRefresh: _refreshList,
            child: CustomScrollView(
              slivers: [
                // App bar with hero image
                _buildSliverAppBar(curatedList, theme),

                // Content
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and description section
                      _buildTitleSection(curatedList, theme),

                      // Scores section (if available)
                      if (curatedList.hasSafetyScores ||
                          curatedList.hasSoloSuitabilityScores)
                        _buildScoresSection(curatedList, theme),

                      // Metadata section
                      _buildMetadataSection(curatedList, theme),

                      // Trip details (if available)
                      if (curatedList.bestTimeToVisit != null ||
                          curatedList.recommendedDuration != null)
                        _buildTripDetailsSection(curatedList, theme),

                      // Destinations grid
                      if (curatedList.hasDestinations)
                        _buildDestinationsSection(
                          curatedList.destinations,
                          savedState,
                          theme,
                        ),

                      // Bottom padding
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => _buildLoadingState(theme),
        error: (error, stackTrace) => _buildErrorState(theme, error),
      ),
      floatingActionButton: curatedListsState.when(
        data: (state) {
          if (state.selectedList == null) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: _shareList,
            icon: const Icon(Icons.share),
            label: const Text('Share List'),
            backgroundColor: theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.onPrimaryContainer,
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  /// Builds the sliver app bar with hero image
  Widget _buildSliverAppBar(CuratedList curatedList, ThemeData theme) {
    final imageUrl = curatedList.coverImageUrl;

    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: Icon(
                      Icons.collections_bookmark,
                      size: 80,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.3),
                    ),
                  ),
                ),
              )
            : Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Icon(
                    Icons.collections_bookmark,
                    size: 80,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.3),
                  ),
                ),
              ),
      ),
      actions: [
        // Share button
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _shareList,
          tooltip: 'Share',
        ),
      ],
    );
  }

  /// Builds the title and description section
  Widget _buildTitleSection(CuratedList curatedList, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name with type badge
          Row(
            children: [
              Expanded(
                child: Text(
                  curatedList.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Type badge
          _buildTypeBadge(curatedList, theme),

          const SizedBox(height: 16),

          // Description
          Text(
            curatedList.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds type badge
  Widget _buildTypeBadge(CuratedList curatedList, ThemeData theme) {
    final typeInfo = _getTypeInfo(curatedList.type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: typeInfo['color'] as Color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            typeInfo['icon'] as IconData,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            typeInfo['label'] as String,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the scores section
  Widget _buildScoresSection(CuratedList curatedList, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Row(
        children: [
          // Safety score
          if (curatedList.hasSafetyScores)
            Expanded(
              child: Column(
                children: [
                  SafetyScoreBadge(
                    score: curatedList.averageSafetyScore!,
                    label: 'Safety',
                    showLabel: true,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Avg. Safety',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

          if (curatedList.hasSafetyScores &&
              curatedList.hasSoloSuitabilityScores)
            const VerticalDivider(),

          // Solo suitability score
          if (curatedList.hasSoloSuitabilityScores)
            Expanded(
              child: Column(
                children: [
                  SoloSuitabilityBadge(
                    score: curatedList.averageSoloSuitabilityScore!,
                    label: 'Solo',
                    showLabel: true,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Avg. Solo Score',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the metadata section
  Widget _buildMetadataSection(CuratedList curatedList, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Destination count
          Row(
            children: [
              Icon(
                Icons.place,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                curatedList.destinationCountLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // View and save counts
          Row(
            children: [
              Icon(
                Icons.visibility,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                _formatCount(curatedList.viewCount),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.bookmark,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                _formatCount(curatedList.saveCount),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          // Curator info
          if (curatedList.hasCuratorInfo) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (curatedList.curatorImageUrl != null)
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(curatedList.curatorImageUrl!),
                  )
                else
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 18,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  'Curated by ${curatedList.curatorName}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the trip details section
  Widget _buildTripDetailsSection(CuratedList curatedList, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (curatedList.bestTimeToVisit != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Best Time to Visit',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            curatedList.bestTimeToVisit!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              if (curatedList.bestTimeToVisit != null &&
                  curatedList.recommendedDuration != null)
                const SizedBox(height: 12),
              if (curatedList.recommendedDuration != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recommended Duration',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            curatedList.recommendedDuration!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the destinations grid section
  Widget _buildDestinationsSection(
    List<Destination> destinations,
    AsyncValue? savedState,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Destinations',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: destinations.length,
            itemBuilder: (context, index) {
              final destination = destinations[index];
              final isSaved = savedState != null &&
                  savedState.hasValue &&
                  savedState.value!.isDestinationInWishlist(destination.id);

              return DestinationCard(
                destination: destination,
                onTap: () => _navigateToDestination(destination),
                onBookmarkTap: () => _toggleBookmark(destination),
                isSaved: isSaved,
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds loading state
  Widget _buildLoadingState(ThemeData theme) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  /// Builds empty state
  Widget _buildEmptyState(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(),
      body: DestinationEmptyStateWidget(
        title: 'Curated list not found',
        message:
            'The curated list you\'re looking for doesn\'t exist or has been removed. '
            'Browse our other curated collections for amazing destinations!',
        icon: Icons.collections_bookmark,
        actionLabel: 'Browse Collections',
        onAction: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// Builds error state
  Widget _buildErrorState(ThemeData theme, Object error) {
    return Scaffold(
      appBar: AppBar(),
      body: DestinationErrorWidget(
        error: error,
        onRetry: _loadCuratedList,
        customMessage: _getCustomErrorMessage(error),
      ),
    );
  }

  /// Get custom error message for curated list detail
  String? _getCustomErrorMessage(Object error) {
    if (error is NetworkConnectivityException) {
      return 'Unable to load this collection. Please check your internet connection.';
    } else if (error is NetworkTimeoutException) {
      return 'Loading collection details timed out. Please try again.';
    } else if (error is NotFoundException) {
      return 'This collection could not be found. It may have been removed.';
    } else if (error is ServerException) {
      return 'Unable to load collection details due to a server error. Please try again later.';
    }
    return null;
  }

  /// Returns type information for badge
  Map<String, dynamic> _getTypeInfo(CuratedListType type) {
    switch (type) {
      case CuratedListType.popularSolo:
        return {
          'icon': Icons.trending_up,
          'label': 'Popular Solo',
          'color': Colors.purple,
        };
      case CuratedListType.hiddenGems:
        return {
          'icon': Icons.diamond,
          'label': 'Hidden Gems',
          'color': Colors.amber,
        };
      case CuratedListType.budgetFriendly:
        return {
          'icon': Icons.attach_money,
          'label': 'Budget-Friendly',
          'color': Colors.green,
        };
      case CuratedListType.adventure:
        return {
          'icon': Icons.hiking,
          'label': 'Adventure',
          'color': Colors.orange,
        };
      case CuratedListType.cultural:
        return {
          'icon': Icons.museum,
          'label': 'Cultural',
          'color': Colors.brown,
        };
      case CuratedListType.beach:
        return {
          'icon': Icons.beach_access,
          'label': 'Beach & Coastal',
          'color': Colors.lightBlue,
        };
      case CuratedListType.urban:
        return {
          'icon': Icons.location_city,
          'label': 'Urban',
          'color': Colors.blueGrey,
        };
      case CuratedListType.nature:
        return {
          'icon': Icons.park,
          'label': 'Nature',
          'color': Colors.green.shade700,
        };
      case CuratedListType.food:
        return {
          'icon': Icons.restaurant,
          'label': 'Food & Culinary',
          'color': Colors.red.shade700,
        };
      case CuratedListType.wellness:
        return {
          'icon': Icons.spa,
          'label': 'Wellness',
          'color': Colors.teal,
        };
      case CuratedListType.seasonal:
        return {
          'icon': Icons.calendar_today,
          'label': 'Seasonal',
          'color': Colors.indigo,
        };
      case CuratedListType.custom:
        return {
          'icon': Icons.playlist_add_check,
          'label': 'Custom',
          'color': Colors.cyan,
        };
    }
  }

  /// Formats count number (e.g., 1200 -> 1.2k)
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    } else {
      return count.toString();
    }
  }
}
