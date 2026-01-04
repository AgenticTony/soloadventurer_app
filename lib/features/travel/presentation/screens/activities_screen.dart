import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/widgets/widgets.dart';

/// Model representing an activity in a trip
class Activity {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String category;
  final double? estimatedCost;

  Activity({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.category,
    this.estimatedCost,
  });
}

/// Provider for activities data
///
/// In a real implementation, this would fetch data from a repository
/// For demonstration purposes, we're using a simple provider
final activitiesProvider = Provider<List<Activity>>((ref) {
  // This would normally come from a repository
  return [];
});

/// Provider for loading state
final activitiesLoadingProvider = Provider<bool>((ref) => false);

/// Provider for error state
final activitiesErrorProvider = Provider<bool>((ref) => false);

/// Screen displaying a list of activities with virtual scrolling
///
/// This screen demonstrates the use of [VirtualListView] for efficiently
/// rendering large lists of activities (500+ items).
class ActivitiesScreen extends ConsumerWidget {
  /// Creates a new [ActivitiesScreen]
  const ActivitiesScreen({super.key});

  /// Route name for navigation
  static const String routeName = '/trips/activities';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activitiesProvider);
    final isLoading = ref.watch(activitiesLoadingProvider);
    final hasError = ref.watch(activitiesErrorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
            tooltip: 'Filter',
          ),
        ],
      ),
      body: VirtualListView<Activity>(
        itemCount: activities.length,
        isLoading: isLoading,
        hasError: hasError,
        padding: const EdgeInsets.all(8.0),
        loadingWidget: const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to load activities'),
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
              Icon(Icons.event, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No activities yet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('Add activities to your trip'),
            ],
          ),
        ),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return _ActivityCard(
            key: ValueKey(activity.id),
            activity: activity,
            onTap: () {
              // Navigate to activity details
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new activity
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Widget displaying a single activity as a card
class _ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback onTap;

  const _ActivityCard({
    super.key,
    required this.activity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CategoryIcon(category: activity.category),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (activity.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            activity.description!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (activity.estimatedCost != null) ...[
                    const SizedBox(width: 8),
                    _CostBadge(cost: activity.estimatedCost!),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimeRange(activity.startTime, activity.endTime),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      activity.location,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    final startHour = start.hour.toString().padLeft(2, '0');
    final startMin = start.minute.toString().padLeft(2, '0');
    final endHour = end.hour.toString().padLeft(2, '0');
    final endMin = end.minute.toString().padLeft(2, '0');
    return '$startHour:$startMin - $endHour:$endMin';
  }
}

/// Widget displaying the category icon
class _CategoryIcon extends StatelessWidget {
  final String category;

  const _CategoryIcon({required this.category});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (category.toLowerCase()) {
      case 'food':
      case 'restaurant':
        iconData = Icons.restaurant;
        iconColor = Colors.orange;
        break;
      case 'transport':
      case 'travel':
        iconData = Icons.directions_car;
        iconColor = Colors.blue;
        break;
      case 'accommodation':
      case 'hotel':
        iconData = Icons.hotel;
        iconColor = Colors.purple;
        break;
      case 'activity':
      case 'entertainment':
        iconData = Icons.local_activity;
        iconColor = Colors.green;
        break;
      case 'sightseeing':
        iconData = Icons.photo_camera;
        iconColor = Colors.teal;
        break;
      default:
        iconData = Icons.event;
        iconColor = Colors.grey;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor),
    );
  }
}

/// Widget displaying the estimated cost badge
class _CostBadge extends StatelessWidget {
  final double cost;

  const _CostBadge({required this.cost});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Text(
        '\$${cost.toStringAsFixed(0)}',
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
