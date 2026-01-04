# Travel Feature - Virtual Scrolling Implementation

This directory contains the presentation layer for the travel feature, demonstrating the use of `VirtualListView` for efficient rendering of large lists.

## Screens

### TripItemsScreen
- **Route:** `/trips/items`
- **Purpose:** Displays a list of trip items with virtual scrolling
- **Features:**
  - Virtual scrolling for handling 500+ trips efficiently
  - Loading, error, and empty states
  - Dividers between items
  - Tap handling for navigation to trip details

### ActivitiesScreen
- **Route:** `/trips/activities`
- **Purpose:** Displays a list of activities with virtual scrolling
- **Features:**
  - Virtual scrolling for handling 500+ activities efficiently
  - Loading, error, and empty states
  - Card-based layout with category icons
  - Cost badges
  - Time and location information
  - Floating action button for adding activities

## Architecture

### Virtual Scrolling Benefits

Both screens use `VirtualListView<T>` from `lib/core/widgets/widgets.dart` which provides:

1. **Memory Efficiency**: Only renders visible items, reducing memory footprint
2. **Performance**: Maintains smooth scrolling even with 500+ items
3. **Consistent API**: Same interface across all list views in the app
4. **State Management**: Built-in loading, error, and empty states
5. **Separators**: Efficient separator rendering interleaved with items

### Data Flow

```
Provider (Riverpod) → ConsumerWidget → VirtualListView → Item Widgets
```

1. Data providers (`tripItemsProvider`, `activitiesProvider`) supply the list data
2. Screen widgets watch the providers using `ref.watch()`
3. `VirtualListView` efficiently renders only visible items
4. Individual item widgets (`_TripListItem`, `_ActivityCard`) display the content

## Usage Examples

### Basic List with Separators

```dart
VirtualListView<Trip>(
  itemCount: trips.length,
  separatorBuilder: (context, index) => const Divider(height: 1),
  itemBuilder: (context, index) => TripListItem(trip: trips[index]),
)
```

### List with States

```dart
VirtualListView<Activity>(
  itemCount: activities.length,
  isLoading: isLoading,
  hasError: hasError,
  loadingWidget: const Center(child: CircularProgressIndicator()),
  errorWidget: const Center(child: Text('Failed to load')),
  emptyWidget: const Center(child: Text('No activities')),
  itemBuilder: (context, index) => ActivityCard(activity: activities[index]),
)
```

### List with Padding

```dart
VirtualListView<Item>(
  itemCount: items.length,
  padding: const EdgeInsets.all(8.0),
  itemBuilder: (context, index) => ItemCard(item: items[index]),
)
```

## Performance Considerations

1. **Fixed Item Extent**: If items have consistent height, set `itemExtent` for better performance
2. **Avoid Complex Builds**: Keep item builders simple for smooth scrolling
3. **Use const Constructors**: Use `const` wherever possible in item widgets
4. **Efficient Separators**: Use the built-in `separatorBuilder` instead of wrapping items

## Migration from ListView.builder

### Before
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemWidget(item: items[index]);
  },
)
```

### After
```dart
VirtualListView<Item>(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(item: items[index]),
)
```

## Future Enhancements

- [ ] Add pull-to-refresh functionality
- [ ] Implement infinite scroll pagination
- [ ] Add search and filtering
- [ ] Implement swipe-to-actions (edit, delete)
- [ ] Add animations for item insertion/deletion
- [ ] Support for sticky headers with date grouping
- [ ] Implement drag-and-drop reordering

## Testing

To test these screens with large datasets:

```dart
final testTrips = PerformanceTestDataGenerator().generateTriips(500);
// Use testTrips with the tripItemsProvider override
```

See `test/utils/performance/performance_test_utils.dart` for test data generation utilities.
