import 'package:flutter/material.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary_item.dart';

/// A tile widget that displays a single itinerary item
class ItineraryItemTile extends StatelessWidget {
  /// The itinerary item to display
  final ItineraryItem item;

  /// Whether reorder mode is active
  final bool isReorderMode;

  /// Callback when completion is toggled
  final VoidCallback onToggleCompletion;

  /// Callback when the item is removed
  final VoidCallback onRemove;

  const ItineraryItemTile({
    super.key,
    required this.item,
    required this.isReorderMode,
    required this.onToggleCompletion,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            width: 4.0,
            color: _getColorForType(context, item),
          ),
        ),
      ),
      child: ListTile(
        // Drag handle for reorder mode
        leading: isReorderMode
            ? const Icon(Icons.drag_handle, color: Colors.grey)
            : _buildCompletionCheckbox(context),
        // Time
        title: Row(
          children: [
            Text(
              _formatTime(item.time),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8.0),
            // Activity type icon
            Icon(
              _getIconForType(item),
              size: 20.0,
              color: _getColorForType(context, item),
            ),
            const SizedBox(width: 8.0),
            // Activity name
            Expanded(
              child: Text(
                item.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                    ),
              ),
            ),
          ],
        ),
        // Location and notes
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.location != null) ...[
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16.0, color: Colors.grey),
                  const SizedBox(width: 4.0),
                  Expanded(
                    child: Text(
                      item.location!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ],
            if (item.note != null && item.note!.isNotEmpty) ...[
              const SizedBox(height: 4.0),
              Text(
                item.note!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ],
        ),
        // Trailing actions
        trailing: isReorderMode
            ? IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onRemove,
                color: Colors.red,
              )
            : null,
        onTap: () => _showItemDetails(context),
      ),
    );
  }

  Widget _buildCompletionCheckbox(BuildContext context) {
    return Checkbox(
      value: item.isCompleted,
      onChanged: (_) => onToggleCompletion(),
      shape: const CircleBorder(),
    );
  }

  void _showItemDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            _buildDetailRow(
              context,
              Icons.access_time,
              _formatTime(item.time),
            ),
            if (item.location != null)
              _buildDetailRow(
                context,
                Icons.location_on,
                item.location!,
              ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.pop(context);
                    onRemove();
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove'),
                ),
                const SizedBox(width: 8.0),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onToggleCompletion();
                  },
                  icon: Icon(item.isCompleted ? Icons.check_box : Icons.check_box_outline_blank),
                  label: Text(item.isCompleted ? 'Mark Incomplete' : 'Mark Complete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20.0, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 8.0),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  IconData _getIconForType(ItineraryItem item) {
    return item.map(
      flightArrival: (_) => Icons.flight_land,
      flightDeparture: (_) => Icons.flight_takeoff,
      hotelCheckIn: (_) => Icons.hotel,
      hotelCheckOut: (_) => Icons.logout,
      activity: (_) => Icons.attractions,
      lunch: (_) => Icons.restaurant,
      dinner: (_) => Icons.dining,
    );
  }

  Color _getColorForType(BuildContext context, ItineraryItem item) {
    final theme = Theme.of(context);
    return item.map(
      flightArrival: (_) => Colors.blue,
      flightDeparture: (_) => Colors.blue,
      hotelCheckIn: (_) => Colors.purple,
      hotelCheckOut: (_) => Colors.purple,
      activity: (_) => theme.colorScheme.primary,
      lunch: (_) => Colors.orange,
      dinner: (_) => Colors.orange,
    );
  }
}
