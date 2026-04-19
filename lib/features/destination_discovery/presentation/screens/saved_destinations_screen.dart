import 'package:flutter/material.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier_provider.dart';
import '../../domain/models/saved_destination.dart';
import '../../domain/models/destination.dart';
import '../../application/providers/saved_destinations_provider.dart';
import '../../application/state/saved_destinations_state.dart';
import '../widgets/add_to_trip_flow.dart';
import '../widgets/safety_score_badge.dart';
import '../widgets/solo_suitability_badge.dart';
import '../utils/error_handler.dart';

/// Screen showing user's saved destinations (wishlist and trips).
///
/// This screen displays destinations that the user has saved to their wishlist
/// or added to their trips. Features include:
/// - Tab or section for wishlist vs trip destinations
/// - Destinations grid/list with notes display
/// - Remove from saved functionality
/// - Add to trip functionality (placeholder)
/// - Pull-to-refresh
/// - Loading, error, and empty states
/// - Edit notes functionality
///
/// The screen integrates with:
/// - [SavedDestinationsProvider] for saved destinations data
/// - [authProvider] for current user authentication
class SavedDestinationsScreen extends ConsumerStatefulWidget {
  /// Creates a new [SavedDestinationsScreen]
  const SavedDestinationsScreen({super.key});

  /// Route name for navigation
  static const String routeName = '/saved-destinations';

  @override
  ConsumerState<SavedDestinationsScreen> createState() =>
      _SavedDestinationsScreenState();
}

class _SavedDestinationsScreenState
    extends ConsumerState<SavedDestinationsScreen>
    with SingleTickerProviderStateMixin {
  /// Tab controller for wishlist/trip tabs
  late TabController _tabController;

  /// Selected filter for saved destinations
  SavedDestinationFilter _selectedFilter = SavedDestinationFilter.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initial load is handled automatically by the provider
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Refresh saved destinations
  Future<void> _refreshSavedDestinations() async {
    final authState = ref.read(authProvider);

    if (!authState.hasValue || authState.value!.user == null) {
      return;
    }

    final userId = authState.value!.user!.id;
    final savedNotifier = ref.read(savedDestinationsProvider(userId).notifier);

    try {
      await savedNotifier.refresh();
    } catch (error) {
      // Error is handled in the provider's state
    }
  }

  /// Handle destination card tap
  void _onDestinationTap(String destinationId) {
    // TODO: Implement navigation in subtask 6.1
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing destination: $destinationId'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Handle remove from saved
  Future<void> _onRemoveSaved(
    SavedDestination savedDest,
  ) async {
    final authState = ref.read(authProvider);

    if (!authState.hasValue || authState.value!.user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to manage saved destinations'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final userId = authState.value!.user!.id;
    final savedNotifier = ref.read(savedDestinationsProvider(userId).notifier);

    try {
      await savedNotifier.unsaveDestination(
        userId: userId,
        destinationId: savedDest.destination.id,
        saveType: savedDest.saveType,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${savedDest.destination.name} removed from ${savedDest.isWishlist ? 'wishlist' : 'trip'}',
            ),
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
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove: ${error.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Handle add to trip
  void _onAddToTrip(Destination destination) {
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

  /// Handle edit notes
  Future<void> _onEditNotes(SavedDestination savedDest) async {
    final authState = ref.read(authProvider);

    if (!authState.hasValue || authState.value!.user == null) {
      return;
    }

    final userId = authState.value!.user!.id;
    final TextEditingController notesController =
        TextEditingController(text: savedDest.notes);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Notes for ${savedDest.destination.name}'),
        content: TextField(
          controller: notesController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Add your personal notes about this destination...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(notesController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      final savedNotifier =
          ref.read(savedDestinationsProvider(userId).notifier);
      try {
        await savedNotifier.updateNotes(savedDest.destination.id, result);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notes updated'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update notes: ${error.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    notesController.dispose();
  }

  /// Get saved destinations based on selected filter and tab
  List<SavedDestination> _getFilteredDestinations(
    List<SavedDestination> allSaved,
  ) {
    // Filter by tab index
    final tabIndex = _tabController.index;
    final SaveType? saveTypeFilter = tabIndex == 0 ? SaveType.wishlist : null;

    var filtered = allSaved;

    // Apply tab filter
    if (saveTypeFilter != null) {
      filtered =
          filtered.where((item) => item.saveType == saveTypeFilter).toList();
    } else {
      // Show only trip items in second tab
      filtered = filtered.where((item) => item.isTrip).toList();
    }

    // Apply additional filter
    switch (_selectedFilter) {
      case SavedDestinationFilter.withNotes:
        return filtered.where((item) => item.hasNotes).toList();
      case SavedDestinationFilter.recentlyAdded:
        return filtered..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SavedDestinationFilter.all:
        return filtered;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Destinations'),
        actions: [
          // Filter button
          PopupMenuButton<SavedDestinationFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: SavedDestinationFilter.all,
                child: _buildFilterMenuItem(
                  context,
                  SavedDestinationFilter.all,
                  'All Saved',
                  Icons.bookmark,
                ),
              ),
              PopupMenuItem(
                value: SavedDestinationFilter.withNotes,
                child: _buildFilterMenuItem(
                  context,
                  SavedDestinationFilter.withNotes,
                  'With Notes',
                  Icons.edit_note,
                ),
              ),
              PopupMenuItem(
                value: SavedDestinationFilter.recentlyAdded,
                child: _buildFilterMenuItem(
                  context,
                  SavedDestinationFilter.recentlyAdded,
                  'Recently Added',
                  Icons.schedule,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Wishlist'),
            Tab(text: 'Trips'),
          ],
        ),
      ),
      body: authState.when(
        data: (authData) {
          // Check if user is authenticated
          if (authData.user == null) {
            return _buildSignInPrompt();
          }

          final userId = authData.user!.id;
          final savedState = ref.watch(savedDestinationsProvider(userId));

          return _buildSavedDestinationsContent(savedState);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _buildErrorState(
          error,
          isAuthError: true,
        ),
      ),
    );
  }

  /// Build the main saved destinations content
  Widget _buildSavedDestinationsContent(
    AsyncValue<SavedDestinationsState> savedState,
  ) {
    return savedState.when(
      data: (state) {
        final filteredDestinations = _getFilteredDestinations(
          state.savedDestinations,
        );

        // Empty state
        if (filteredDestinations.isEmpty) {
          return _buildEmptyState();
        }

        // Destinations grid
        return RefreshIndicator(
          onRefresh: _refreshSavedDestinations,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDestinationsGrid(filteredDestinations),
              _buildDestinationsGrid(filteredDestinations),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => _buildErrorState(error),
    );
  }

  /// Build destinations grid
  Widget _buildDestinationsGrid(List<SavedDestination> savedDestinations) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: savedDestinations.length,
      itemBuilder: (context, index) {
        final savedDest = savedDestinations[index];
        return _SavedDestinationCard(
          savedDestination: savedDest,
          onTap: () => _onDestinationTap(savedDest.destination.id),
          onRemove: () => _onRemoveSaved(savedDest),
          onEditNotes: () => _onEditNotes(savedDest),
          onAddToTrip: savedDest.isWishlist
              ? () => _onAddToTrip(savedDest.destination)
              : null,
        );
      },
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState() {
    final isWishlistTab = _tabController.index == 0;

    return DestinationEmptyStateWidget(
      title: isWishlistTab ? 'Your wishlist is empty' : 'No trips planned yet',
      message: isWishlistTab
          ? 'Start exploring and save destinations you\'re interested in!'
          : 'Add destinations to your trips to start planning your adventure!',
      icon: isWishlistTab ? Icons.bookmark_border : Icons.flight_takeoff,
      actionLabel: 'Discover Destinations',
      onAction: () {
        // TODO: Navigate to destination discovery screen in subtask 6.1
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Navigate to discovery - to be implemented'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }

  /// Build error state widget
  Widget _buildErrorState(
    Object error, {
    bool isAuthError = false,
  }) {
    // Use custom error widget for non-auth errors
    if (!isAuthError) {
      return DestinationErrorWidget(
        error: error,
        onRetry: _refreshSavedDestinations,
        customMessage: _getCustomErrorMessage(error),
      );
    }

    // Keep existing auth error handling
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Authentication Required',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
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
          ],
        ),
      ),
    );
  }

  /// Get custom error message for saved destinations
  String? _getCustomErrorMessage(Object error) {
    if (error is NetworkConnectivityException) {
      return 'Unable to load your saved destinations. Please check your internet connection.';
    } else if (error is NetworkTimeoutException) {
      return 'Loading saved destinations timed out. Please try again.';
    } else if (error is ServerException) {
      return 'Unable to load saved destinations due to a server error. Please try again later.';
    }
    return null;
  }

  /// Build sign in prompt widget
  Widget _buildSignInPrompt() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Sign In to View Saved Destinations',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to see your wishlist and planned trips.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to sign in screen in subtask 6.2
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sign in flow - to be implemented'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build filter menu item
  Widget _buildFilterMenuItem(
    BuildContext context,
    SavedDestinationFilter filter,
    String label,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isSelected = _selectedFilter == filter;

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isSelected ? theme.colorScheme.primary : null,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? theme.colorScheme.primary : null,
            fontWeight: isSelected ? FontWeight.bold : null,
          ),
        ),
        if (isSelected) ...[
          const Spacer(),
          Icon(
            Icons.check,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ],
      ],
    );
  }
}

/// Filter options for saved destinations
enum SavedDestinationFilter {
  /// Show all saved destinations
  all,

  /// Show only destinations with notes
  withNotes,

  /// Show recently added destinations
  recentlyAdded,
}

/// Card widget for displaying a single saved destination
class _SavedDestinationCard extends StatelessWidget {
  final SavedDestination savedDestination;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onEditNotes;
  final VoidCallback? onAddToTrip;

  const _SavedDestinationCard({
    required this.savedDestination,
    required this.onTap,
    required this.onRemove,
    required this.onEditNotes,
    this.onAddToTrip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final destination = savedDestination.destination;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination image
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  if (destination.coverImageUrl != null)
                    Image.network(
                      destination.coverImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.place,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.3),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.place,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.3),
                      ),
                    ),

                  // Save type badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: savedDestination.isWishlist
                            ? Colors.purple.withValues(alpha: 0.9)
                            : Colors.orange.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            savedDestination.isWishlist
                                ? Icons.bookmark
                                : Icons.flight_takeoff,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            savedDestination.isWishlist ? 'Wishlist' : 'Trip',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Destination name
                  Text(
                    destination.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Notes preview
                  if (savedDestination.hasNotes) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.edit_note,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            savedDestination.notes!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Scores row
                  Row(
                    children: [
                      SafetyScoreBadge(
                        score: destination.safetyScore,
                        showLabel: false,
                      ),
                      const SizedBox(width: 8),
                      SoloSuitabilityBadge(
                        score: destination.soloSuitabilityScore,
                        showLabel: false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Action buttons
                  Row(
                    children: [
                      // Edit notes button
                      IconButton(
                        icon: const Icon(Icons.edit_note),
                        onPressed: onEditNotes,
                        tooltip: 'Edit notes',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 20,
                      ),

                      const SizedBox(width: 8),

                      // Add to trip button (wishlist only)
                      if (onAddToTrip != null) ...[
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: onAddToTrip,
                          tooltip: 'Add to trip',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 20,
                        ),
                        const SizedBox(width: 8),
                      ],

                      const Spacer(),

                      // Remove button
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: onRemove,
                        tooltip: 'Remove',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 20,
                        color: theme.colorScheme.error,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
