import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/destination.dart';
import '../../domain/models/saved_destination.dart';
import '../../application/providers/destination_detail_provider.dart';
import '../../application/providers/saved_destinations_provider.dart';
import '../widgets/add_to_trip_flow.dart';
import '../widgets/destination_card.dart';
import '../widgets/safety_score_badge.dart';
import '../widgets/solo_suitability_badge.dart';
import '../widgets/safety_insights.dart';
import '../widgets/activity_list.dart';
import '../utils/error_handler.dart';

/// Detailed view of a single destination with comprehensive information.
///
/// This screen displays:
/// - Hero image gallery with swipeable images
/// - Destination name and detailed description
/// - Prominent safety and solo suitability scores
/// - Detailed safety insights with expandable sections
/// - Popular activities for solo travelers
/// - Best time to visit information
/// - Budget level and cost estimates
/// - Location information
/// - Save/bookmark functionality
/// - Add to trip functionality (placeholder)
/// - Related destinations suggestions
/// - Smooth animations and transitions
///
/// The screen integrates with:
/// - [DestinationDetailProvider] for destination data
/// - [SavedDestinationsProvider] for bookmark functionality
class DestinationDetailScreen extends ConsumerStatefulWidget {
  /// Creates a new [DestinationDetailScreen]
  const DestinationDetailScreen({
    super.key,
    required this.destinationId,
  });

  /// The unique identifier of the destination to display
  final String destinationId;

  /// Route name for navigation
  static const String routeName = '/destinations/:id';

  @override
  ConsumerState<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends ConsumerState<DestinationDetailScreen>
    with SingleTickerProviderStateMixin {
  /// Controller for image gallery page view
  late PageController _pageController;

  /// Current image index in gallery
  int _currentImageIndex = 0;

  /// Animation controller for smooth transitions
  late AnimationController _animationController;

  /// Animation for fading in content
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    // Load related destinations after initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRelatedDestinations();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Load related destinations
  Future<void> _loadRelatedDestinations() async {
    final detailNotifier = ref.read(destinationDetailProvider(widget.destinationId).notifier);
    try {
      await detailNotifier.loadRelatedDestinations();
    } catch (error) {
      // Error is handled in the provider's state
    }
  }

  /// Refresh destination data
  Future<void> _refreshDestination() async {
    final detailNotifier = ref.read(destinationDetailProvider(widget.destinationId).notifier);
    try {
      await detailNotifier.refresh();
      await _loadRelatedDestinations();
    } catch (error) {
      // Error is handled in the provider's state
    }
  }

  /// Handle save/bookmark destination
  Future<void> _toggleBookmark(Destination destination) async {
    // Get current user from auth state
    final authState = ref.read(authNotifierProvider);

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
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  // TODO: Implement undo
                },
              ),
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

  /// Handle add to trip
  void _addToTrip(Destination destination) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddToTripFlow(
        destination: destination,
        showDatesSelection: true,
        showNotesStep: true,
        onSuccess: (tripId, tripName) {
          // Optionally navigate to the trip detail screen
          // Navigator.pushNamed(context, '/trips/$tripId');
        },
        onCancel: () {
          // Handle cancel if needed
        },
      ),
    );
  }

  /// Navigate to related destination
  void _navigateToRelatedDestination(Destination destination) {
    // TODO: Implement navigation in subtask 6.1
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to ${destination.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detailState = ref.watch(destinationDetailProvider(widget.destinationId));

    // Get auth state for save functionality
    final authState = ref.watch(authNotifierProvider);
    final userId = authState.value?.user?.id;
    final savedState = userId != null
        ? ref.watch(savedDestinationsProvider(userId))
        : null;

    return Scaffold(
      body: detailState.when(
        data: (state) {
          final destination = state.destination;

          if (destination == null) {
            return _buildEmptyState(theme);
          }

          return RefreshIndicator(
            onRefresh: _refreshDestination,
            child: CustomScrollView(
              slivers: [
                // App bar with hero image
                _buildSliverAppBar(destination, theme),

                // Content
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and description
                        _buildTitleSection(destination, theme),

                        // Scores section
                        _buildScoresSection(destination, theme),

                        // Quick info chips
                        _buildQuickInfoSection(destination, theme),

                        // Best time to visit
                        if (destination.bestTimeToVisit != null)
                          _buildBestTimeToVisit(destination, theme),

                        // Safety insights
                        SafetyInsights(
                          insights: destination.safetyInsights,
                        ),

                        // Popular activities
                        if (destination.popularActivities.isNotEmpty)
                          _buildActivitiesSection(destination, theme),

                        // Related destinations
                        if (state.hasRelatedDestinations)
                          _buildRelatedDestinationsSection(state.relatedDestinations, theme),

                        // Bottom padding for FAB
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => _buildLoadingState(theme),
        error: (error, stackTrace) => _buildErrorState(theme, error),
      ),
      floatingActionButton: detailState.when(
        data: (state) {
          final destination = state.destination;
          if (destination == null) return const SizedBox.shrink();

          // Check if destination is saved
          final isSaved = savedState.hasValue &&
              savedState.value!.isDestinationInWishlist(destination.id);

          return _buildFloatingActionButtons(destination, theme, isSaved);
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  /// Builds the sliver app bar with hero image gallery
  Widget _buildSliverAppBar(Destination destination, ThemeData theme) {
    final images = destination.images.isEmpty
        ? [destination.coverImageUrl]
        : destination.images;

    final validImages = images.whereType<String>().toList();

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: validImages.isEmpty
            ? _buildImagePlaceholder(theme)
            : _buildImageGallery(validImages, theme),
      ),
      actions: [
        // Share button
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // TODO: Implement share functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Share coming soon!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          tooltip: 'Share',
        ),
      ],
    );
  }

  /// Builds the image gallery with page view
  Widget _buildImageGallery(List<String> images, ThemeData theme) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: images.length,
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: images[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => _buildImagePlaceholder(theme),
            );
          },
        ),

        // Image indicator
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentImageIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentImageIndex == index
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Builds placeholder when no image is available
  Widget _buildImagePlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.place,
          size: 80,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
        ),
      ),
    );
  }

  /// Builds the title and description section
  Widget _buildTitleSection(Destination destination, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name with hidden gem badge
          Row(
            children: [
              Expanded(
                child: Text(
                  destination.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (destination.isHiddenGem)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.diamond,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Hidden Gem',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Location
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                [
                  destination.region,
                  destination.countryCode,
                ].whereType<String>().join(', '),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            destination.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the scores section with safety and solo suitability
  Widget _buildScoresSection(Destination destination, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Row(
        children: [
          // Safety score
          Expanded(
            child: Column(
              children: [
                SafetyScoreBadge(
                  score: destination.safetyScore,
                  label: 'Safety',
                  showLabel: true,
                ),
                const SizedBox(height: 4),
                Text(
                  'Safety Score',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const VerticalDivider(),

          // Solo suitability score
          Expanded(
            child: Column(
              children: [
                SoloSuitabilityBadge(
                  score: destination.soloSuitabilityScore,
                  label: 'Solo',
                  showLabel: true,
                ),
                const SizedBox(height: 4),
                Text(
                  'Solo Score',
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

  /// Builds quick info chips
  Widget _buildQuickInfoSection(Destination destination, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // Budget level chip
          _buildInfoChip(
            theme,
            _getBudgetIcon(destination.budgetLevel),
            _getBudgetLabel(destination.budgetLevel),
          ),

          // Daily cost chip
          if (destination.averageDailyCost != null)
            _buildInfoChip(
              theme,
              Icons.payments,
              '\$${destination.averageDailyCost}/day',
            ),

          // Activity level chips
          ...destination.activityLevels.take(2).map(
                (level) => _buildInfoChip(
                  theme,
                  _getActivityIcon(level),
                  _getActivityLabel(level),
                ),
              ),

          // Tags
          ...destination.tags.take(3).map(
                (tag) => _buildInfoChip(
                  theme,
                  Icons.local_offer,
                  tag.capitalize(),
                ),
              ),
        ],
      ),
    );
  }

  /// Builds a single info chip
  Widget _buildInfoChip(ThemeData theme, IconData icon, String label) {
    return Chip(
      avatar: Icon(
        icon,
        size: 18,
        color: theme.colorScheme.primary,
      ),
      label: Text(label),
      labelStyle: theme.textTheme.labelSmall,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  /// Builds best time to visit section
  Widget _buildBestTimeToVisit(Destination destination, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
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
                      destination.bestTimeToVisit!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the activities section
  Widget _buildActivitiesSection(Destination destination, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Activities',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ActivityList(
            activities: destination.popularActivities,
            layout: ActivityListLayout.list,
            showDescription: true,
            showCategory: true,
            showCostLevel: true,
          ),
        ],
      ),
    );
  }

  /// Builds the related destinations section
  Widget _buildRelatedDestinationsSection(
    List<Destination> relatedDestinations,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Related Destinations',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: relatedDestinations.length,
              itemBuilder: (context, index) {
                final destination = relatedDestinations[index];
                return SizedBox(
                  width: 280,
                  child: DestinationCard(
                    destination: destination,
                    onTap: () => _navigateToRelatedDestination(destination),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds floating action buttons
  Widget _buildFloatingActionButtons(Destination destination, ThemeData theme, bool isSaved) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Save/Bookmark button
        FloatingActionButton.extended(
          heroTag: 'save',
          onPressed: () => _toggleBookmark(destination),
          icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
          label: Text(isSaved ? 'Saved' : 'Save'),
          backgroundColor: isSaved
              ? theme.colorScheme.primary
              : theme.colorScheme.primaryContainer,
          foregroundColor: isSaved
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onPrimaryContainer,
        ),

        const SizedBox(width: 12),

        // Add to trip button
        FloatingActionButton.extended(
          heroTag: 'add_to_trip',
          onPressed: () => _addToTrip(destination),
          icon: const Icon(Icons.add),
          label: const Text('Add to Trip'),
          backgroundColor: theme.colorScheme.secondaryContainer,
          foregroundColor: theme.colorScheme.onSecondaryContainer,
        ),
      ],
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
        title: 'Destination not found',
        message: 'The destination you\'re looking for doesn\'t exist or has been removed. '
            'Try browsing our other amazing destinations!',
        icon: Icons.place,
        actionLabel: 'Browse Destinations',
        onAction: () {
          // Navigate back to discovery screen
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
        onRetry: _refreshDestination,
        customMessage: _getCustomErrorMessage(error),
      ),
    );
  }

  /// Get custom error message for destination detail
  String? _getCustomErrorMessage(Object error) {
    if (error is NetworkConnectivityException) {
      return 'Unable to load destination details. Please check your internet connection.';
    } else if (error is NetworkTimeoutException) {
      return 'Loading destination details timed out. Please try again.';
    } else if (error is NotFoundException) {
      return 'This destination could not be found. It may have been removed.';
    } else if (error is ServerException) {
      return 'Unable to load destination details due to a server error. Please try again later.';
    }
    return null;
  }

  /// Returns budget level icon
  IconData _getBudgetIcon(BudgetLevel level) {
    switch (level) {
      case BudgetLevel.budget:
        return Icons.attach_money;
      case BudgetLevel.moderate:
        return Icons.money;
      case BudgetLevel.expensive:
        return Icons.trending_up;
    }
  }

  /// Returns budget level label
  String _getBudgetLabel(BudgetLevel level) {
    switch (level) {
      case BudgetLevel.budget:
        return 'Budget-friendly';
      case BudgetLevel.moderate:
        return 'Moderate';
      case BudgetLevel.expensive:
        return 'Luxury';
    }
  }

  /// Returns activity level icon
  IconData _getActivityIcon(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.relaxed:
        return Icons.self_improvement;
      case ActivityLevel.moderate:
        return Icons.directions_walk;
      case ActivityLevel.adventurous:
        return Icons.hiking;
    }
  }

  /// Returns activity level label
  String _getActivityLabel(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.relaxed:
        return 'Relaxed';
      case ActivityLevel.moderate:
        return 'Moderate';
      case ActivityLevel.adventurous:
        return 'Adventurous';
    }
  }
}

/// Extension on String to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
