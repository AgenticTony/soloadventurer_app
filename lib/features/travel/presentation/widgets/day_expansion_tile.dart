import 'package:flutter/material.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary_item.dart';
import 'package:soloadventurer/features/travel/presentation/widgets/itinerary_item_tile.dart';

/// A widget that displays a day's itinerary items in an expandable tile
class DayExpansionTile extends StatefulWidget {
  /// The day number (-based)
  final int dayNumber;

  /// The items for this day
  final List<ItineraryItem> items;

  /// Whether reorder mode is active
  final bool isReorderMode;

  /// Callback when an item's completion is toggled
  final void Function(String itemId) onToggleCompletion;

  /// Callback when an item is removed
  final void Function(String itemId) onRemove;

  /// Callback when items are reordered
  final void Function(int oldIndex, int newIndex) onReorder;

  const DayExpansionTile({
    super.key,
    required this.dayNumber,
    required this.items,
    required this.isReorderMode,
    required this.onToggleCompletion,
    required this.onRemove,
    required this.onReorder,
  });

  @override
  State<DayExpansionTile> createState() => _DayExpansionTileState();
}

class _DayExpansionTileState extends State<DayExpansionTile> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final completedCount =
        widget.items.where((item) => item.isCompleted).length;
    final totalCount = widget.items.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          // Day Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Day Number Circle
                  Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: completedCount == totalCount
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.dayNumber}',
                        style: TextStyle(
                          color: completedCount == totalCount
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  // Day Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Day ${widget.dayNumber}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (totalCount > 0)
                          Text(
                            '$completedCount of $totalCount activities completed',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                      ],
                    ),
                  ),
                  // Expand/Collapse Icon
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          // Items List (shown when expanded)
          if (_isExpanded) ...[
            const Divider(height: 1.0),
            if (widget.items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'No activities planned',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: widget.items.length,
                onReorder: widget.onReorder,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return ItineraryItemTile(
                    key: ValueKey(item.id),
                    item: item,
                    isReorderMode: widget.isReorderMode,
                    onToggleCompletion: () => widget.onToggleCompletion(item.id),
                    onRemove: () => _showRemoveDialog(context, item),
                  );
                },
              ),
            const SizedBox(height: 16.0),
          ],
        ],
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, ItineraryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Activity'),
        content: Text(
          'Are you sure you want to remove "${item.name}" from your itinerary?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onRemove(item.id);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
