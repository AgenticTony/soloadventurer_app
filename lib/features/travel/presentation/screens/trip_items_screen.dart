import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/widgets/widgets.dart';
import 'package:soloadventurer/features/travel/domain/models/trip.dart';

/// Provider for trip items data
///
/// In a real implementation, this would fetch data from a repository
/// For demonstration purposes, we're using a simple provider
final tripItemsProvider = Provider<List<Trip>>((ref) {
  // This would normally come from a repository
  return [];
});

/// Provider for loading state
final tripItemsLoadingProvider = Provider<bool>((ref) => false);

/// Provider for error state
final tripItemsErrorProvider = Provider<bool>((ref) => false);

/// Screen displaying a list of trip items with virtual scrolling
///
/// This screen demonstrates the use of [VirtualListView] for efficiently
/// rendering large lists of trip items (500+ items).
class TripItemsScreen extends ConsumerWidget {
  /// Creates a new [TripItemsScreen]
  const TripItemsScreen({super.key});

  /// Route name for navigation
  static const String routeName = '/trips/items';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripItemsProvider);
    final isLoading = ref.watch(tripItemsLoadingProvider);
    final hasError = ref.watch(tripItemsErrorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Items'),
      ),
      body: VirtualListView<Trip>(
        itemCount: trips.length,
        isLoading: isLoading,
        hasError: hasError,
        loadingWidget: const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to load trips'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // Retry logic would go here
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        emptyWidget: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flight_takeoff, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No trips yet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('Create your first trip to get started'),
            ],
          ),
        ),
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final trip = trips[index];
          return _TripListItem(
            key: ValueKey(trip.id),
            trip: trip,
            onTap: () {
              // Navigate to trip details
            },
          );
        },
      ),
    );
  }
}

/// Widget displaying a single trip item in the list
class _TripListItem extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;

  const _TripListItem({
    super.key,
    required this.trip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trip.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (trip.description != null) ...[
              const SizedBox(height: 4),
              Text(
                trip.description!,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${_formatDate(trip.startDate)} - ${_formatDate(trip.endDate)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    trip.destination,
                    style: TextStyle(color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
