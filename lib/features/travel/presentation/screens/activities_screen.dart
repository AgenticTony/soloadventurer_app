import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/widgets/widgets.dart';
import 'package:soloadventurer/core/models/paginated_data.dart';

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

  const Activity({
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

/// Screen displaying a list of activities with infinite scroll pagination
///
/// This screen demonstrates the use of [InfiniteScrollListView] for efficiently
/// loading and rendering large lists of activities (500+ items) with automatic
/// pagination as the user scrolls.
class ActivitiesScreen extends ConsumerWidget {
  /// Creates a new [ActivitiesScreen]
  const ActivitiesScreen({super.key});

  /// Route name for navigation
  static const String routeName = '/trips/activities';

  /// Fetches paginated activity data
  ///
  /// In a real implementation, this would call a repository method:
  /// ```dart
  /// return await ref.read(activityRepositoryProvider).getActivitiesCursor(
  ///   tripId: tripId,
  ///   cursor: cursor,
  ///   pageSize: 20,
  /// );
  /// ```
  Future<PaginatedData<Activity>> _fetchActivities(String? cursor) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Parse cursor (page number)
    final page = cursor == null ? 1 : int.parse(cursor);
    const itemsPerPage = 20;

    // Generate mock activities
    final activities = List.generate(
      page == 5 ? 10 : itemsPerPage, // Last page has fewer items
      (i) => Activity(
        id: '${page}_$i',
        title: 'Activity ${(page - 1) * itemsPerPage + i + 1}',
        description:
            'Description for activity ${(page - 1) * itemsPerPage + i + 1}',
        startTime: DateTime.now().add(Duration(hours: i)),
        endTime: DateTime.now().add(Duration(hours: i + 2)),
        location: 'Location ${(page - 1) * itemsPerPage + i + 1}',
        category: [
          'Food',
          'Transport',
          'Accommodation',
          'Activity',
          'Sightseeing'
        ][i % 5],
        estimatedCost: (i % 3 + 1) * 20.0,
      ),
    );

    return PaginatedData(
      items: activities,
      pageInfo: PageInfo(
        currentPage: page,
        itemsPerPage: itemsPerPage,
        totalItems: 90,
        totalPages: 5,
        hasNextPage: page < 5,
        hasPreviousPage: page > 1,
        nextCursor: page < 5 ? '$page' : null,
        previousCursor: page > 1 ? '${page - 2}' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      body: InfiniteScrollListView<Activity>(
        fetchData: _fetchActivities,
        itemBuilder: (context, activity) => OptimizedListItem(
          child: _ActivityCard(
            key: ValueKey(activity.id),
            activity: activity,
            onTap: () {
              // Navigate to activity details
            },
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        padding: const EdgeInsets.all(8.0),
        // Custom empty state
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
        // Custom error state
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
                  // Retry is handled automatically by InfiniteScrollListView
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        // Load next page 300px before reaching end for faster perceived speed
        preloadThreshold: 300.0,
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
    final grey600 = Colors.grey[600];

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
                  Icon(Icons.access_time, size: 14, color: grey600),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimeRange(activity.startTime, activity.endTime),
                    style: TextStyle(color: grey600, fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.location_on, size: 14, color: grey600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      activity.location,
                      style: TextStyle(color: grey600, fontSize: 12),
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
    final iconData = _getIconData();
    final iconColor = _getIconColor();

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor),
    );
  }

  IconData _getIconData() {
    switch (category.toLowerCase()) {
      case 'food':
      case 'restaurant':
        return Icons.restaurant;
      case 'transport':
      case 'travel':
        return Icons.directions_car;
      case 'accommodation':
      case 'hotel':
        return Icons.hotel;
      case 'activity':
      case 'entertainment':
        return Icons.local_activity;
      case 'sightseeing':
        return Icons.photo_camera;
      default:
        return Icons.event;
    }
  }

  Color _getIconColor() {
    switch (category.toLowerCase()) {
      case 'food':
      case 'restaurant':
        return Colors.orange;
      case 'transport':
      case 'travel':
        return Colors.blue;
      case 'accommodation':
      case 'hotel':
        return Colors.purple;
      case 'activity':
      case 'entertainment':
        return Colors.green;
      case 'sightseeing':
        return Colors.teal;
      default:
        return Colors.grey;
    }
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
        color: Colors.green.withValues(alpha:0.1),
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
