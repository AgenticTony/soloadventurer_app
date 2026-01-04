# Core Widgets

Reusable widgets that can be used across the entire application.

## VirtualListView

A generic virtual scrolling list widget that optimizes rendering of large lists by only rendering visible items.

### Features

- **Virtual Scrolling**: Only renders items that are currently visible, significantly reducing memory usage
- **Memory Efficient**: Handles 500+ items without performance degradation
- **Flexible Layout**: Supports both vertical and horizontal scrolling
- **Separators**: Built-in support for item separators
- **State Handling**: Built-in loading, error, and empty states
- **Headers/Footers**: Optional header and footer widgets
- **Fixed Item Extent**: Optional fixed height for items to improve performance
- **Customizable**: Full control over padding, physics, and scroll controller

### Basic Usage

#### Simple List

```dart
import 'package:soloadventurer/core/widgets/widgets.dart';

VirtualListView<String>(
  itemCount: names.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(names[index]),
    );
  },
)
```

#### List with Separators

```dart
VirtualListView<Item>(
  itemCount: items.length,
  separatorBuilder: (context, index) {
    return Divider(height: 1);
  },
  itemBuilder: (context, index) {
    return ItemCard(item: items[index]);
  },
)
```

#### List with Loading and Empty States

```dart
VirtualListView<Trip>(
  itemCount: trips.length,
  isLoading: isLoading,
  hasError: hasError,
  loadingWidget: LoadingView(),
  errorWidget: ErrorView(
    message: 'Failed to load trips',
    onRetry: () => ref.read(tripsProvider.notifier).loadTrips(),
  ),
  emptyWidget: EmptyView(
    message: 'No trips yet',
    icon: Icons.flight_takeoff,
  ),
  itemBuilder: (context, index) {
    return TripCard(trip: trips[index]);
  },
)
```

#### List with Fixed Item Height

```dart
VirtualListView<String>(
  itemCount: items.length,
  itemExtent: 80.0, // Fixed height for each item
  itemBuilder: (context, index) {
    return Container(
      height: 80,
      child: Text(items[index]),
    );
  },
)
```

#### Horizontal List

```dart
VirtualListView.horizontal<Photo>(
  itemCount: photos.length,
  itemExtent: 120.0, // Width for horizontal items
  itemBuilder: (context, index) {
    return PhotoThumbnail(photo: photos[index]);
  },
)
```

#### List with Header and Footer

```dart
VirtualListView<Item>(
  itemCount: items.length,
  header: Column(
    children: [
      Padding(
        padding: EdgeInsets.all(16),
        child: Text('Trip Items', style: Theme.of(context).textTheme.headlineSmall),
      ),
      Divider(),
    ],
  ),
  footer: Padding(
    padding: EdgeInsets.all(16),
    child: Text('Total: ${items.length} items'),
  ),
  itemBuilder: (context, index) {
    return ItemCard(item: items[index]);
  },
)
```

### Performance Considerations

1. **Use itemExtent when possible**: If all items have the same height, provide `itemExtent` for better performance
2. **Avoid complex widgets in itemBuilder**: Keep item widgets simple for smooth scrolling
3. **Use const constructors**: Make item widgets const when possible
4. **Limit separators**: Separators double the widget count, use simple separator widgets
5. **Consider pagination**: For extremely large lists (1000+ items), consider pagination

### When to Use VirtualListView

Use `VirtualListView` when:
- Displaying lists with 50+ items
- Lists may grow to 500+ items
- Memory efficiency is important
- Consistent list behavior across the app is desired

Use regular `ListView.builder` when:
- Lists are always small (< 50 items)
- Custom list behavior is needed that VirtualListView doesn't support

### Architecture

The VirtualListView is a wrapper around Flutter's built-in `ListView.builder`, providing:
- Consistent API for all lists in the app
- Built-in state handling (loading, error, empty)
- Separator support
- Optional headers/footers
- Convenience constructors for common scenarios

### Migration from ListView.builder

Before:
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemCard(item: items[index]);
  },
)
```

After:
```dart
VirtualListView<Item>(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemCard(item: items[index]);
  },
)
```

### Testing

Example test for a widget using VirtualListView:

```dart
testWidgets('VirtualListView renders items', (tester) async {
  final items = List.generate(100, (i) => 'Item $i');

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: VirtualListView<String>(
          itemCount: items.length,
          itemBuilder: (context, index) => Text(items[index]),
        ),
      ),
    ),
  );

  expect(find.text('Item 0'), findsOneWidget);
  expect(find.text('Item 1'), findsOneWidget);
});
```

## Adding New Widgets

When adding new widgets to this directory:

1. Ensure the widget is truly reusable across multiple features
2. Follow existing code patterns (StatelessWidget, documentation, etc.)
3. Include comprehensive documentation with examples
4. Export the widget from `widgets.dart`
5. Add usage examples to this README

## Future Enhancements

Potential improvements for VirtualListView:
- Add built-in pull-to-refresh support
- Add infinite scroll pagination support
- Add animated list transitions
- Add group headers with sticky positioning (using flutter_sticky_headers)
- Add grid layout support (VirtualGridView)
