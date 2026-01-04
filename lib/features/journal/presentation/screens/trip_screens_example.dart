import 'package:flutter/material.dart';
import 'package:soloadventurer/features/journal/presentation/screens/trip_list_screen.dart';
import 'package:soloadventurer/features/journal/presentation/screens/create_trip_screen.dart';
import 'package:soloadventurer/features/journal/presentation/screens/trip_detail_screen.dart';

/// Example demonstrating how to use the trip management screens
///
/// This file shows common navigation patterns and integration examples
/// for the trip management system.

class TripScreensExample extends StatelessWidget {
  const TripScreensExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Management Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ExampleCard(
            title: 'View Trip List',
            description: 'Display all user trips',
            icon: Icons.list,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TripListScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ExampleCard(
            title: 'Create New Trip',
            description: 'Open trip creation form',
            icon: Icons.add,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateTripScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ExampleCard(
            title: 'View Trip Details',
            description: 'Show specific trip information',
            icon: Icons.info,
            onTap: () {
              // Replace with actual trip ID
              const tripId = 'your-trip-id-here';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TripDetailScreen(tripId: tripId),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ExampleCard(
            title: 'Edit Trip',
            description: 'Open trip editing form',
            icon: Icons.edit,
            onTap: () {
              // Replace with actual trip ID
              const tripId = 'your-trip-id-here';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateTripScreen(tripId: tripId),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ExampleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Example: Integrating trip selection into journal entry creation
///
/// When creating a journal entry, you might want to associate it with a trip.
/// Here's how you could add trip selection to your journal entry form:

class JournalEntryWithTripExample extends StatelessWidget {
  const JournalEntryWithTripExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Journal Entry')),
      body: Column(
        children: [
          // Your existing form fields...

          // Trip selector
          ListTile(
            leading: const Icon(Icons.flight_takeoff),
            title: const Text('Trip'),
            subtitle: const Text('Select a trip (optional)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              // Navigate to trip list and wait for selection
              final selectedTripId = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (context) => const TripListScreen(),
                ),
              );

              if (selectedTripId != null) {
                // Associate the entry with the selected trip
                // Use the tripId when creating the journal entry
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Example: Showing trips in a home screen dashboard
///
/// Display ongoing trips and quick actions on your home screen:

class HomeDashboardWithTripsExample extends StatelessWidget {
  const HomeDashboardWithTripsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Column(
        children: [
          // Ongoing trips section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ongoing Trips',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.chevron_right),
              ],
            ),
          ),

          // Horizontal list of ongoing trip cards
          // Use ConsumerWidget with tripListProvider to get ongoing trips
          Container(
            height: 200,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3, // Replace with actual ongoing trips count
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(right: 12),
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip Name', // Replace with actual trip name
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('Destination'),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to trip detail
                          },
                          child: const Text('View Trip'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Quick action to create new trip
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateTripScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Start New Trip'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example: Using trip repository programmatically
///
/// For advanced use cases where you need to work with trips outside of UI:

class TripRepositoryExample {
  // Example: Creating a trip programmatically
  static Future<void> createTripExample(BuildContext context) async {
    // This would typically be done in a provider or service
    // final repository = ref.read(tripRepositoryProvider);
    //
    // final trip = Trip(
    //   id: '',
    //   userId: Supabase.instance.client.auth.currentUser!.id,
    //   name: 'European Adventure',
    //   description: 'Exploring the best of Europe',
    //   startDate: DateTime(2024, 6, 1),
    //   endDate: DateTime(2024, 6, 21),
    //   destination: 'Europe',
    //   isPublic: false,
    //   createdAt: DateTime.now(),
    //   updatedAt: DateTime.now(),
    // );
    //
    // try {
    //   final createdTrip = await repository.createTrip(trip);
    //   // Handle success
    // } catch (e) {
    //   // Handle error
    // }
  }

  // Example: Querying trips
  static Future<void> queryTripsExample() async {
    // Get all trips
    // final allTrips = await repository.getTrips();

    // Get only ongoing trips
    // final ongoingTrips = await repository.getOngoingTrips();

    // Get trips for a specific date range
    // final summerTrips = await repository.getTripsByDateRange(
    //   DateTime(2024, 6, 1),
    //   DateTime(2024, 8, 31),
    // );

    // Get entry count for a trip
    // final entryCount = await repository.getEntryCountForTrip(tripId);
  }
}
