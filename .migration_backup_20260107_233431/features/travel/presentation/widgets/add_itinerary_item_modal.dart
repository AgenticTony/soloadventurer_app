import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Add Item Modal for selecting activity types
class AddItineraryItemModal extends ConsumerWidget {
  const AddItineraryItemModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.25,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Activity',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Activity Type Grid
              Expanded(
                child: GridView.count(
                  controller: scrollController,
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: const [
                    _ActivityTypeCard(type: ActivityType.activity),
                    _ActivityTypeCard(type: ActivityType.lunch),
                    _ActivityTypeCard(type: ActivityType.dinner),
                    _ActivityTypeCard(type: ActivityType.hotelCheckIn),
                    _ActivityTypeCard(type: ActivityType.hotelCheckOut),
                    _ActivityTypeCard(type: ActivityType.flightArrival),
                    _ActivityTypeCard(type: ActivityType.flightDeparture),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Activity type for itinerary items
enum ActivityType {
  activity(
    Icons.attractions,
    'Activity',
  ),
  lunch(
    Icons.restaurant,
    'Lunch',
  ),
  dinner(
    Icons.dining,
    'Dinner',
  ),
  hotelCheckIn(
    Icons.hotel,
    'Hotel Check In',
  ),
  hotelCheckOut(
    Icons.logout,
    'Hotel Check Out',
  ),
  flightArrival(
    Icons.flight_land,
    'Flight Arrival',
  ),
  flightDeparture(
    Icons.flight_takeoff,
    'Flight Departure',
  );

  const ActivityType(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _ActivityTypeCard extends StatelessWidget {
  final ActivityType type;

  const _ActivityTypeCard({required this.type});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Return the selected activity type to the caller
        Navigator.pop(context, type);
      },
      borderRadius: BorderRadius.circular(8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                type.icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                type.label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
