import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/trip.dart';
import '../providers/trip_detail_provider.dart';
import '../../../destination_discovery/presentation/widgets/destination_card.dart';
import '../../../destination_discovery/presentation/widgets/safety_score_badge.dart';
import '../../../destination_discovery/presentation/widgets/solo_suitability_badge.dart';
import '../../../destination_discovery/domain/models/destination.dart';
import '../../domain/repositories/travel_operation_repository.dart';

/// Detailed view of a trip with destinations from discovery feature.
///
/// This screen displays:
/// - Trip title, description, and dates
/// - List of destinations from the discovery feature
/// - Safety and solo suitability scores for each destination
/// - Notes for each destination
/// - Link to destination details
/// - Budget and companion information
///
/// The screen integrates with:
/// - [TripDetailProvider] for trip and destination data
/// - Destination discovery feature for destination details
class TripDetailScreen extends ConsumerStatefulWidget {
  /// Creates a new [TripDetailScreen]
  const TripDetailScreen({
    super.key,
    required this.trip,
  });

  /// The trip to display
  final Trip trip;

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load trip data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTripData();
    });
  }

  /// Load trip data with destinations
  Future<void> _loadTripData() async {
    final notifier = ref.read(tripDetailProvider(widget.trip.id).notifier);
    try {
      await notifier.loadTrip(widget.trip);
    } catch (error) {
      // Error is handled in the provider's state
    }
  }

  /// Refresh trip data
  Future<void> _refreshTrip() async {
    final notifier = ref.read(tripDetailProvider(widget.trip.id).notifier);
    try {
      await notifier.refresh();
    } catch (error) {
      // Error is handled in the provider's state
    }
  }

  /// Navigate to destination detail
  void _navigateToDestinationDetail(String destinationId) {
    // TODO: Navigate to destination detail screen using app router
    // Navigator.pushNamed(
    //   context,
    //   DestinationDiscoveryRoutes.destinationDetail,
    //   arguments: {'destinationId': destinationId},
    // );
  }

  /// Edit destination notes
  Future<void> _editDestinationNotes(
      Destination destination, String currentNotes) async {
    final controller = TextEditingController(text: currentNotes);

    final newNotes = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notes for ${destination.name}'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Add your notes about this destination...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newNotes != null && mounted) {
      final notifier = ref.read(tripDetailProvider(widget.trip.id).notifier);
      notifier.updateDestinationNotes(destination.id, newNotes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notes updated'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripDetailState = ref.watch(tripDetailProvider(widget.trip.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with cover image
          _buildSliverAppBar(context, tripDetailState),

          // Trip information
          SliverToBoxAdapter(
            child: tripDetailState.hasError
                ? _buildErrorState(context, tripDetailState.errorMessage!)
                : tripDetailState.isLoadingData
                    ? _buildLoadingState()
                    : _buildTripContent(context, tripDetailState),
          ),
        ],
      ),
    );
  }

  /// Build the sliver app bar with cover image
  Widget _buildSliverAppBar(
      BuildContext context, TripDetailState tripDetailState) {
    final hasCoverImage = widget.trip.coverImageUrl != null &&
        widget.trip.coverImageUrl!.isNotEmpty;

    return SliverAppBar(
      expandedHeight: hasCoverImage ? 250 : 120,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(widget.trip.title),
        background: hasCoverImage
            ? CachedNetworkImage(
                imageUrl: widget.trip.coverImageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              )
            : null,
      ),
      actions: [
        // Refresh button
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshTrip,
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  /// Build trip content
  Widget _buildTripContent(
      BuildContext context, TripDetailState tripDetailState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip dates and status
          _buildTripInfo(context),

          const SizedBox(height: 24),

          // Budget
          if (widget.trip.budget > 0) _buildBudgetInfo(context),

          const SizedBox(height: 24),

          // Companions
          if (widget.trip.travelCompanionIds != null &&
              widget.trip.travelCompanionIds!.isNotEmpty)
            _buildCompanionsInfo(context),

          const SizedBox(height: 24),

          // Destinations section
          _buildDestinationsSection(context, tripDetailState),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Build trip information
  Widget _buildTripInfo(BuildContext context) {
    final startDate = widget.trip.startDate;
    final endDate = widget.trip.endDate;
    final duration = endDate.difference(startDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status badge
        Chip(
          label: Text(
            widget.trip.status.toUpperCase(),
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: _getStatusColor(context, widget.trip.status),
        ),

        const SizedBox(height: 12),

        // Dates
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${_formatDate(startDate)} - ${_formatDate(endDate)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Duration
        Row(
          children: [
            const Icon(Icons.schedule, size: 20),
            const SizedBox(width: 8),
            Text(
              '${duration.inDays} ${duration.inDays == 1 ? 'day' : 'days'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),

        // Description
        if (widget.trip.description != null &&
            widget.trip.description!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            widget.trip.description!,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ],
    );
  }

  /// Build budget information
  Widget _buildBudgetInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet, size: 20),
            const SizedBox(width: 12),
            Text(
              'Budget: \$${widget.trip.budget}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  /// Build companions information
  Widget _buildCompanionsInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.group, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${widget.trip.travelCompanionIds!.length} ${widget.trip.travelCompanionIds!.length == 1 ? 'companion' : 'companions'}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build destinations section
  Widget _buildDestinationsSection(
      BuildContext context, TripDetailState tripDetailState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Text(
          'Destinations',
          style: Theme.of(context).textTheme.headlineSmall,
        ),

        const SizedBox(height: 16),

        // Destinations list or empty state
        if (!tripDetailState.hasDestinations)
          _buildNoDestinationsState(context)
        else
          ...tripDetailState.destinations.map((destination) =>
              _buildDestinationCard(context, destination, tripDetailState)),
      ],
    );
  }

  /// Build destination card
  Widget _buildDestinationCard(
      BuildContext context, Destination destination, TripDetailState state) {
    final notes = state.trip?.destinationNotes[destination.id];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToDestinationDetail(destination.id),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Destination header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      destination.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_note),
                    onPressed: () => _editDestinationNotes(destination, notes ?? ''),
                    tooltip: 'Edit notes',
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () => _navigateToDestinationDetail(destination.id),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Location
              if (destination.location != null)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${destination.location!.countryCode} • ${destination.location!.region}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),

              const SizedBox(height: 12),

              // Scores row
              Row(
                children: [
                  // Safety score
                  SafetyScoreBadge(
                    score: destination.safetyScore,
                    showLabel: true,
                  ),

                  const SizedBox(width: 12),

                  // Solo suitability score
                  SoloSuitabilityBadge(
                    score: destination.soloSuitabilityScore,
                    showLabel: true,
                  ),

                  const SizedBox(width: 12),

                  // Budget level
                  Chip(
                    label: Text(
                      destination.budgetLevel.name.toUpperCase(),
                      style: const TextStyle(fontSize: 10),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),

              // Notes if present
              if (notes != null && notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Notes',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notes,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build no destinations state
  Widget _buildNoDestinationsState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.place_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No destinations added yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Discover amazing destinations and add them to your trip!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(32.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load trip data',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refreshTrip,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  /// Get status color
  Color _getStatusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'planning':
        return Theme.of(context).colorScheme.primaryContainer;
      case 'upcoming':
        return Theme.of(context).colorScheme.secondaryContainer;
      case 'ongoing':
        return Theme.of(context).colorScheme.tertiaryContainer;
      case 'completed':
        return Theme.of(context).colorScheme.surfaceContainerHighest;
      default:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
  }

  /// Format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
