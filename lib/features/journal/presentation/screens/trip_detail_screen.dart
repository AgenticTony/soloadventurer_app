import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soloadventurer/features/journal/presentation/providers/trip_providers.dart';
import 'package:soloadventurer/features/journal/presentation/screens/create_trip_screen.dart';

/// Screen displaying trip details
class TripDetailScreen extends ConsumerWidget {
  final String tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(tripDetailProvider(tripId));

    return Scaffold(
      body: detailState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : detailState.error != null
              ? _buildError(context, detailState.error!, ref)
              : detailState.trip == null
                  ? const Center(child: Text('Trip not found'))
                  : _buildContent(context, detailState.trip!, detailState.entryCount, ref),
    );
  }

  Widget _buildError(BuildContext context, String error, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading trip',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(error),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(tripDetailProvider(tripId).notifier).loadTrip(tripId);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, trip, int entryCount, WidgetRef ref) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        // App bar with cover image
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              trip.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 4,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
            background: trip.coverImageUrl != null
                ? Image.network(
                    trip.coverImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholder(context);
                    },
                  )
                : _buildPlaceholder(context),
          ),
          actions: [
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateTripScreen(tripId: trip.id),
                  ),
                );

                if (result != null) {
                  // Reload trip details
                  ref.read(tripDetailProvider(tripId).notifier).loadTrip(tripId);
                }
              },
            ),

            // More options menu
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'delete':
                    _showDeleteDialog(context, ref, trip);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Trip'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status badges
                Wrap(
                  spacing: 8,
                  children: [
                    // Ongoing badge
                    if (trip.isOngoing)
                      Chip(
                        label: const Text('Ongoing'),
                        backgroundColor: Colors.green.withOpacity(0.1),
                        avatar: const Icon(Icons.flight_takeoff, size: 16),
                      ),

                    // Public badge
                    if (trip.isPublic)
                      Chip(
                        label: const Text('Public'),
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        avatar: const Icon(Icons.public, size: 16),
                      ),

                    // Duration chip
                    Chip(
                      label: Text(_formatDuration(trip.duration)),
                      avatar: const Icon(Icons.schedule, size: 16),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Destination section
                if (trip.destination != null) ...[
                  _buildSection(
                    context,
                    icon: Icons.location_on,
                    title: 'Destination',
                    child: Text(
                      trip.destination!,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Date range section
                _buildSection(
                  context,
                  icon: Icons.calendar_today,
                  title: 'Dates',
                  child: Text(
                    _formatDateRange(trip.startDate, trip.endDate, dateFormat),
                    style: theme.textTheme.bodyLarge,
                  ),
                ),

                const SizedBox(height: 24),

                // Description section
                if (trip.description != null && trip.description!.isNotEmpty) ...[
                  _buildSection(
                    context,
                    icon: Icons.description,
                    title: 'Description',
                    child: Text(
                      trip.description!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Statistics section
                _buildSection(
                  context,
                  icon: Icons.bar_chart,
                  title: 'Statistics',
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.article,
                          label: 'Entries',
                          value: entryCount.toString(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.schedule,
                          label: 'Duration',
                          value: '${trip.duration.inDays}d',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Entries section (placeholder for future)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.article),
                    title: Text('Journal Entries ($entryCount)'),
                    subtitle: entryCount > 0
                        ? 'View all entries for this trip'
                        : 'No entries yet',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to trip entries list
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Coming soon: View trip entries'),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Media gallery section (placeholder for future)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Media Gallery'),
                    subtitle: const Text('View all photos and videos'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to media gallery
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Coming soon: Media gallery'),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Metadata
                _buildMetadata(context, trip, dateFormat),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.5),
            Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.flight_takeoff,
          size: 64,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildMetadata(BuildContext context, trip, DateFormat dateFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trip Information',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Created: ${dateFormat.format(trip.createdAt)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
        Text(
          'Last Updated: ${dateFormat.format(trip.updatedAt)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
        if (trip.lastSyncedAt != null)
          Text(
            'Last Synced: ${dateFormat.format(trip.lastSyncedAt!)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip'),
        content: Text(
          'Are you sure you want to delete "${trip.name}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(tripDetailProvider(tripId).notifier).deleteTrip();
              if (success && context.mounted) {
                Navigator.pop(context); // Go back to trip list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Trip deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
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

/// Stat card widget for displaying statistics
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
