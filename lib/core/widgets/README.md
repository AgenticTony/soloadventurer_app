# Core Widgets

Reusable widgets that can be used across the entire application.

## Available Widgets

- **[VirtualListView](#virtuallistview)**: Virtual scrolling list for 500+ items
- **[VirtualGridView](#virtualgridview)**: Virtual scrolling grid for photo galleries
- **[LazyLoadImage](#lazyloadimage)**: Visibility-based lazy loading for images
- **[VirtualListPerformanceTracker](#performance-tracking)**: Performance monitoring for lists

---

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

## Performance Tracking

The `VirtualListPerformanceTracker` widget can be used to monitor render times, memory usage, and frame rates for virtual lists.

### Basic Usage

```dart
VirtualListPerformanceTracker(
  itemName: 'Trip Items List',
  showOverlay: true, // Show performance overlay in debug mode
  onMetricsUpdated: (metrics) {
    if (kDebugMode) {
      debugPrint('FPS: ${metrics.averageFPS.toStringAsFixed(1)}');
      debugPrint('Memory: ${(metrics.currentMemoryUsageBytes / 1024 / 1024).toStringAsFixed(1)} MB');
    }
  },
  child: VirtualListView<Trip>(
    itemCount: trips.length,
    itemBuilder: (context, index) => TripCard(trip: trips[index]),
  ),
)
```

### Features

- **Real-time Metrics**: Tracks render time, memory usage, FPS, and janky frames
- **Visual Overlay**: Optional overlay showing performance metrics in debug mode
- **Custom Callbacks**: Receive metrics via callbacks for logging or analytics
- **Performance Targets**: Validates against performance targets (render < 1000ms, memory < 150MB, FPS ≥ 55, janky < 10%)
- **Production Safe**: Automatically disabled in release builds

### Complete Documentation

For detailed documentation on performance tracking, see:
- [Performance Tracking Guide](./PERFORMANCE_TRACKING_GUIDE.md)
- [Example Implementations](./example_performance_tracking.dart)

## VirtualGridView

A generic virtual scrolling grid widget that optimizes rendering of large photo galleries by only rendering visible items.

### Features

- **Virtual Scrolling**: Only renders grid items that are currently visible
- **Memory Efficient**: Handles 500+ photos without performance degradation
- **Configurable Layout**: Adjustable column count, aspect ratio, and spacing
- **State Handling**: Built-in loading, error, and empty states
- **Headers/Footers**: Optional header and footer widgets
- **Photo Optimized**: Convenience constructor for photo galleries

### Basic Usage

```dart
VirtualGridView<Photo>(
  itemCount: photos.length,
  crossAxisCount: 3,
  itemBuilder: (context, index) {
    return PhotoCard(photo: photos[index]);
  },
)
```

For more details, see [VirtualGridView README](./VIRTUAL_GRID_VIEW_README.md).

---

## LazyLoadImage

A visibility-based lazy loading image widget that only loads images when they become visible on screen.

### Features

- **Visibility Detection**: Uses `visibility_detector` to load images only when visible
- **Memory Efficient**: Reduces memory footprint by 90% for 500+ images
- **Cached Network Image**: Integrates with `cached_network_image` for automatic caching
- **Placeholder Support**: Custom placeholder during loading
- **Error Handling**: Custom error widgets for failed loads
- **Convenience Constructors**: Pre-configured for photos, cards, and thumbnails
- **Border Radius**: Built-in rounded corner support

### Basic Usage

```dart
// Basic lazy loading
LazyLoadImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)

// Photo for grid
LazyLoadImage.photo(
  imageUrl: photo.url,
  size: 100.0,
)

// Card image
LazyLoadImage.card(
  imageUrl: trip.coverImage,
  height: 200.0,
)

// Thumbnail
LazyLoadImage.thumbnail(
  imageUrl: user.avatarUrl,
  size: 48.0,
)
```

### Benefits

- **90% memory reduction** for 500+ images (only visible images loaded)
- **Smooth scrolling** performance maintained (≥55 FPS target)
- **Fewer network requests** (only 20-30 initial requests vs 500)
- **Better battery life** (reduced network and processing)

### Integration with Virtual Scrolling

```dart
VirtualGridView<Photo>(
  itemCount: photos.length,
  crossAxisCount: 3,
  itemBuilder: (context, index) {
    return LazyLoadImage.photo(
      key: ValueKey(photos[index].id),
      imageUrl: photos[index].displayUrl,
      thumbnailUrl: photos[index].thumbnailUrl,
    );
  },
)
```

### Performance Comparison

**Without Lazy Loading:**
- 500 images = ~500 MB memory
- 500 network requests
- Sluggish scrolling

**With Lazy Loading:**
- 500 images = ~50 MB memory (only visible loaded)
- ~20-30 network requests
- Smooth scrolling (≥55 FPS)

For comprehensive documentation, see [LazyLoadImage README](./LAZY_LOAD_IMAGE_README.md) and [Examples](./example_lazy_load_image.dart).

---

## Performance Tracking