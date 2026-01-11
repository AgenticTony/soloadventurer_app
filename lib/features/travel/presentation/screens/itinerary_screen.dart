import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';
import 'package:soloadventurer/features/travel/application/providers/itinerary_providers.dart';
import 'package:soloadventurer/features/travel/presentation/widgets/add_itinerary_item_modal.dart';
import 'package:soloadventurer/features/travel/presentation/widgets/ai_suggestions_bottom_sheet.dart';
import 'package:soloadventurer/features/travel/presentation/widgets/day_expansion_tile.dart';

// Export for convenience
export 'package:soloadventurer/features/travel/presentation/widgets/add_itinerary_item_modal.dart'
    show ActivityType;

part 'itinerary_screen.g.dart';

/// Main itinerary screen
/// Displays an itinerary with day-by-day breakdown, progress tracking, and item management
class ItineraryScreen extends ConsumerWidget {
  /// The ID of the itinerary to display
  final String itineraryId;

  const ItineraryScreen({
    super.key,
    required this.itineraryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itineraryAsync = ref.watch(itineraryProvider(itineraryId));
    final isReorderMode = ref.watch(isReorderModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Itinerary'),
        actions: [
          // View Mode Tabs
          _buildViewModeTabs(context, ref),
          // Reorder Button
          IconButton(
            icon: Icon(isReorderMode ? Icons.check : Icons.swap_vert),
            onPressed: () {
              ref.read(isReorderModeProvider.notifier).toggle();
            },
          ),
          // AI Suggestions Button
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () => _showAISuggestions(context),
          ),
        ],
      ),
      body: switch (itineraryAsync) {
        AsyncData(:final value) => Column(
            children: [
              // Progress Section
              _buildProgressSection(context, value),
              // Day-by-Day List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: value.numberOfDays,
                  itemBuilder: (context, index) {
                    final dayNumber = index + 1;
                    final items = value.getItemsForDay(dayNumber);
                    return DayExpansionTile(
                      dayNumber: dayNumber,
                      items: items,
                      isReorderMode: isReorderMode,
                      onToggleCompletion: (itemId) {
                        ref
                            .read(itineraryProvider(itineraryId).notifier)
                            .toggleItemCompletion(itemId);
                      },
                      onRemove: (itemId) {
                        ref
                            .read(itineraryProvider(itineraryId).notifier)
                            .removeItem(itemId);
                      },
                      onReorder: (oldIndex, newIndex) {
                        final itemIds = items.map((item) => item.id).toList();
                        // Reorder the list
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final item = itemIds.removeAt(oldIndex);
                        itemIds.insert(newIndex, item);
                        ref
                            .read(itineraryProvider(itineraryId).notifier)
                            .reorderItems(itemIds);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError(:final error) =>
          _buildErrorView(context, ref, error.toString()),
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, Itinerary itinerary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                itinerary.destination.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '${itinerary.numberOfDays} Days',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress Bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: itinerary.completionPercentage / 100,
                    minHeight: 8,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${itinerary.completionPercentage.toInt()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${itinerary.completedItemsCount} of ${itinerary.itemsCount} activities completed',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeTabs(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(viewModeProvider);
    return SegmentedButton<ViewMode>(
      segments: const [
        ButtonSegment(
          value: ViewMode.list,
          label: Text('List'),
          icon: Icon(Icons.list),
        ),
        ButtonSegment(
          value: ViewMode.calendar,
          label: Text('Calendar'),
          icon: Icon(Icons.calendar_today),
        ),
        ButtonSegment(
          value: ViewMode.map,
          label: Text('Map'),
          icon: Icon(Icons.map),
        ),
      ],
      selected: {viewMode},
      onSelectionChanged: (Set<ViewMode> newSelection) {
        ref.read(viewModeProvider.notifier).setMode(newSelection.first);
      },
    );
  }

  Widget _buildErrorView(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(itineraryProvider(itineraryId));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemModal(BuildContext context) {
    showModalBottomSheet<ActivityType>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddItineraryItemModal(),
    ).then((selectedType) {
      if (selectedType != null) {
        // Handle the selected activity type
        // For now, show a snackbar - in production, navigate to detail screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected: ${selectedType.label}'),
            action: SnackBarAction(
              label: 'Configure',
              onPressed: () {
                // TODO: Navigate to activity configuration screen
              },
            ),
          ),
        );
      }
    });
  }

  void _showAISuggestions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AISuggestionsBottomSheet(),
    );
  }
}

/// Provider for view mode
@riverpod
class ViewModeNotifier extends _$ViewModeNotifier {
  @override
  ViewMode build() => ViewMode.list;

  void setMode(ViewMode mode) => state = mode;
}

/// Provider for reorder mode
@riverpod
class IsReorderModeNotifier extends _$IsReorderModeNotifier {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

/// View mode enum
enum ViewMode {
  list,
  calendar,
  map,
}
