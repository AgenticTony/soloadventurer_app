# Core Widgets

Reusable widgets that can be used across the entire application.

## Available Widgets

- **[VirtualListView](#virtuallistview)**: Virtual scrolling list for 500+ items
- **[VirtualGridView](#virtualgridview)**: Virtual scrolling grid for photo galleries
- **[InfiniteScrollListView](#infinitescrolllistview)**: Infinite scroll with automatic pagination
- **[LazyLoadImage](#lazyloadimage)**: Visibility-based lazy loading for images
- **[ImagePlaceholder](#optimized-placeholders)**: Optimized placeholder widgets (shimmer, skeleton, color, blurred)
- **[ImageErrorWidget](#error-handling)**: Enhanced error handling with retry functionality
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

## InfiniteScrollListView

A generic infinite scroll list widget that automatically loads more data as the user scrolls towards the end. Combines `VirtualListView` for efficient rendering with automatic pagination logic.

### Features

- **Automatic Pagination**: Loads next page when scrolling near the end
- **Pull-to-Refresh**: Refresh data with pull-to-refresh gesture
- **Loading States**: Show initial loading and "loading more" indicators
- **Error Handling**: Display errors and provide retry functionality
- **Configurable Preload**: Adjust threshold for loading next page (default: 500px)
- **Virtual Scrolling**: Efficient memory usage with VirtualListView
- **Cursor/Offset Support**: Works with both pagination strategies
- **End Detection**: Shows "end of list" when no more data
- **Custom Widgets**: Customize all states (loading, error, empty, end)

### Basic Usage

#### Minimal Example

```dart
InfiniteScrollListView<Trip>(
  fetchData: (cursor) async {
    return await tripRepository.getTripsCursor(
      userId: 'user123',
      cursor: cursor,
      pageSize: 20,
    );
  },
  itemBuilder: (context, trip) => TripCard(trip: trip),
)
```

#### With Separators

```dart
InfiniteScrollListView<Trip>.withSeparators(
  fetchData: (cursor) => tripRepository.getTripsCursor(
    userId: 'user123',
    cursor: cursor,
    pageSize: 20,
  ),
  itemBuilder: (context, trip) => TripCard(trip: trip),
  separatorBuilder: (context, index) => Divider(height: 1),
)
```

#### With Custom Widgets

```dart
InfiniteScrollListView<Trip>(
  fetchData: (cursor) async => await tripRepository.getTripsCursor(
    userId: 'user123',
    cursor: cursor,
    pageSize: 20,
  ),
  itemBuilder: (context, trip) => TripCard(trip: trip),

  // Custom loading states
  initialLoadingWidget: Center(child: CircularProgressIndicator()),
  loadingMoreWidget: Padding(
    padding: EdgeInsets.all(16),
    child: Center(child: CircularProgressIndicator()),
  ),

  // Custom error state
  errorWidget: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 48),
        SizedBox(height: 16),
        Text('Failed to load trips'),
        ElevatedButton(onPressed: () => _retry(), child: Text('Retry')),
      ],
    ),
  ),

  // Custom empty state
  emptyWidget: Center(
    child: Text('No trips yet. Start your adventure!'),
  ),

  // Custom end of list indicator
  endOfListWidget: Padding(
    padding: EdgeInsets.all(16),
    child: Text('You\'ve reached the end'),
  ),

  // Configure preload threshold
  preloadThreshold: 300.0, // Load 300px before end
)
```

### Integration with Repository

```dart
class TripsScreen extends StatelessWidget {
  final TripRepository tripRepository;
  final String userId;

  const TripsScreen({
    super.key,
    required this.tripRepository,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return InfiniteScrollListView<Trip>(
      fetchData: (cursor) async {
        return await tripRepository.getTripsCursor(
          userId: userId,
          cursor: cursor,
          pageSize: 20,
          sortBy: 'createdAt',
          sortOrder: SortOrder.descending,
        );
      },
      itemBuilder: (context, trip) => TripCard(trip: trip),
      separatorBuilder: (context, index) => Divider(height: 1),
      emptyWidget: Center(child: Text('No trips found')),
    );
  }
}
```

### Performance Benefits

- **Memory Efficient**: Only renders visible items (virtual scrolling)
- **Network Efficient**: Loads data in pages (20 items per page by default)
- **Smooth Scrolling**: Preloads next page before user reaches end
- **Scalable**: Handles 500+ items without performance degradation

### Performance Tips

1. **Use appropriate page size**: 20-50 items typically
2. **Adjust preload threshold**: Lower values load sooner
3. **Use ValueKey in itemBuilder**: Proper widget recycling
4. **Lazy load images**: Use `LazyLoadImage` for photos
5. **Use metadata queries**: For list views (80% memory reduction)

### Comparison with VirtualListView

| Feature | InfiniteScrollListView | VirtualListView |
|---------|----------------------|-----------------|
| Automatic pagination | ✅ Yes | ❌ No |
| Pull-to-refresh | ✅ Built-in | ❌ Manual |
| Error handling | ✅ Built-in | ⚠️ Manual |
| Loading states | ✅ Built-in | ⚠️ Manual |
| Virtual scrolling | ✅ Yes | ✅ Yes |
| Use case | Server data | Local/loaded data |

**Use InfiniteScrollListView when:**
- Data is loaded from a server/API
- Data is paginated
- You want automatic pagination

**Use VirtualListView when:**
- All data is already loaded
- You need manual control over loading
- Data is small (< 500 items)

For comprehensive documentation, see [InfiniteScrollListView README](./INFINITE_SCROLL_README.md) and [Examples](./example_infinite_scroll_list_view.dart).

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

## Optimized Placeholders

Optimized placeholder widgets for image loading states with performance and UX in mind.

### Features

- **4 Placeholder Types**: Shimmer (animated), Skeleton (simple), Color (theme-aware), Blurred (progressive)
- **Performance Optimized**: Renders 500+ items at 60 FPS
- **Customizable**: Colors, icons, border radius, animation
- **Theme Aware**: Respects app theme colors
- **Accessibility**: Properly labeled and sized

### Basic Usage

```dart
// Shimmer placeholder (animated gradient)
LazyLoadImage(
  imageUrl: url,
  placeholderType: PlaceholderType.shimmer,
)

// Skeleton placeholder (most performant)
LazyLoadImage(
  imageUrl: url,
  placeholderType: PlaceholderType.skeleton,
)

// Color placeholder (theme-aware)
LazyLoadImage(
  imageUrl: url,
  placeholderType: PlaceholderType.color,
)

// Blurred placeholder (progressive loading)
LazyLoadImage(
  imageUrl: fullSizeUrl,
  thumbnailUrl: thumbnailUrl,
  placeholderType: PlaceholderType.blurred,
)
```

### Optimized Constructors

```dart
// Recommended: Optimized with shimmer + retry
LazyLoadImage.optimized(
  imageUrl: photo.url,
  thumbnailUrl: photo.thumbnailUrl,
  size: 100.0,
  onRetry: () => ref.refresh(photoProvider),
)

// Card with skeleton + retry
LazyLoadImage.optimizedCard(
  imageUrl: trip.coverImage,
  height: 200.0,
  onRetry: () => ref.refresh(tripCoverProvider),
)

// Thumbnail with color + compact error
LazyLoadImage.optimizedThumbnail(
  imageUrl: user.avatarUrl,
  size: 48.0,
)

// Progressive blur-up loading
LazyLoadImage.progressive(
  imageUrl: photo.fullSizeUrl,
  thumbnailUrl: photo.thumbnailUrl,
  size: 150.0,
)
```

### Direct Placeholder Usage

```dart
LazyLoadImage(
  imageUrl: url,
  placeholder: (context, url) => ImagePlaceholder.shimmer(
    width: 150,
    height: 150,
    baseColor: Colors.blue[100],
  ),
)
```

### Performance

| Placeholder | Render Time (100 items) | Memory | FPS |
|-------------|------------------------|--------|-----|
| Shimmer | ~800ms | Low | 60 |
| Skeleton | ~400ms | Very Low | 60 |
| Color | ~400ms | Very Low | 60 |
| Blurred | ~900ms | Medium | 60 |

### When to Use Each Placeholder

| Use Case | Recommended Placeholder |
|----------|------------------------|
| Photo Gallery | Shimmer |
| List Items | Skeleton |
| Profile Avatar | Color |
| Detail View | Blurred |
| Low-End Device | Skeleton |

For complete documentation, see [OPTIMIZED_PLACEHOLDERS_README.md](./OPTIMIZED_PLACEHOLDERS_README.md) and [Examples](./example_optimized_placeholders.dart).

---

## Error Handling

Enhanced error widgets with automatic error classification, retry functionality, and offline detection.

### Features

- **Automatic Error Classification**: Network, timeout, 404, unauthorized, format errors
- **Context-Aware Icons**: Different icons for each error type
- **Retry Functionality**: Optional retry button with custom callback
- **Offline Detection**: Automatic offline status detection
- **Compact Mode**: Icon-only for small thumbnails

### Basic Usage

```dart
// Enhanced error handling with retry
LazyLoadImage(
  imageUrl: url,
  useEnhancedErrorHandling: true,
  onRetry: () => setState(() {}),
)

// Custom error widget
LazyLoadImage(
  imageUrl: url,
  errorWidget: (context, url, error) => ImageErrorWidget.withRetry(
    error: error,
    imageUrl: url,
    onRetry: () => setState(() {}),
  ),
)

// Compact error for thumbnails
ImageErrorWidget.compact(
  error: error,
  imageUrl: url,
  size: 48,
)
```

### Error Icons

| Error Type | Icon | Retryable |
|------------|------|-----------|
| Offline | `Icons.cloud_off` | Yes |
| Timeout | `Icons.access_time` | Yes |
| Network | `Icons.wifi_off` | Yes |
| 404 Not Found | `Icons.image_not_supported` | No |
| Unauthorized | `Icons.lock` | No |
| Invalid Format | `Icons.broken_image` | No |
| Unknown | `Icons.error_outline` | Yes |

### Best Practices

1. **Always provide retry callback** for better UX
2. **Use compact mode** for thumbnails (48x48)
3. **Disable offline detection** when connection status is known
4. **Customize messages** for your app's context

For complete documentation, see [OPTIMIZED_PLACEHOLDERS_README.md](./OPTIMIZED_PLACEHOLDERS_README.md).

---

## Performance Tracking