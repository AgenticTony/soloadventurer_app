import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soloadventurer/features/journal/domain/entities/trip.dart';
import 'package:soloadventurer/features/journal/presentation/providers/trip_providers.dart';
import 'package:soloadventurer/features/journal/presentation/screens/create_trip_screen.dart';

/// Screen displaying a list of all trips
class TripListScreen extends ConsumerStatefulWidget {
  const TripListScreen({super.key});

  @override
  ConsumerState<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends ConsumerState<TripListScreen> {
  @override
  Widget build(BuildContext context) {
    final tripListState = ref.watch(tripListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        actions: [
          // Filter toggle: All / Ongoing
          TextButton.icon(
            onPressed: () {
              // Toggle between all and ongoing trips
              final notifier = ref.read(tripListProvider.notifier);
              // For now, just reload all trips
              // TODO: Implement filter toggle in a future update
              notifier.loadTrips();
            },
            icon: const Icon(Icons.filter_list),
            label: const Text('All'),
          ),
        ],
      ),
      body: _buildBody(tripListState),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<Trip>(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateTripScreen(),
            ),
          );

          if (result != null) {
            // Refresh the trip list after creating a new trip
            ref.read(tripListProvider.notifier).loadTrips();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(TripListState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading trips',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(tripListProvider.notifier).loadTrips();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flight_takeoff,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No trips yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Create your first trip to start organizing your journal entries'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push<Trip>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateTripScreen(),
                  ),
                );

                if (result != null) {
                  ref.read(tripListProvider.notifier).loadTrips();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Trip'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(tripListProvider.notifier).loadTrips();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.trips.length,
        itemBuilder: (context, index) {
          final trip = state.trips[index];
          return _TripCard(
            trip: trip,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/trip/${trip.id}',
              );
            },
          );
        },
      ),
    );
  }
}

/// Card widget for displaying trip information
class _TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;

  const _TripCard({
    required this.trip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image or placeholder
            if (trip.coverImageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  trip.coverImageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder(context);
                  },
                ),
              )
            else
              _buildPlaceholder(context),

            // Trip information
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trip name
                  Text(
                    trip.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Destination
                  if (trip.destination != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            trip.destination!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Date range
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateRange(trip.startDate, trip.endDate, dateFormat),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Status indicators
                  Row(
                    children: [
                      // Ongoing badge
                      if (trip.isOngoing)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Text(
                            'Ongoing',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      // Duration
                      const SizedBox(width: 8),
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(trip.duration),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),

                      const Spacer(),

                      // Public indicator
                      if (trip.isPublic) ...[
                        Icon(
                          Icons.public,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ],
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

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.3),
            Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.flight_takeoff,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  String _formatDateRange(DateTime startDate, DateTime? endDate, DateFormat format) {
    final start = format.format(startDate);
    if (endDate == null) {
      return '$start - Present';
    }
    final end = format.format(endDate);
    return '$start - $end';
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    if (days == 0) return 'Today';
    if (days == 1) return '1 day';
    return '$days days';
  }
}
