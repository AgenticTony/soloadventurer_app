# LazyLoadImage Widget

A visibility-based lazy loading image widget that optimizes performance by only loading images when they become visible on screen.

## Overview

`LazyLoadImage` uses the `visibility_detector` package to detect when an image widget enters the viewport and only then initiates image loading. This significantly improves performance for lists and grids with many images.

## Benefits

- **Reduced Memory Footprint**: Off-screen images don't consume memory
- **Fewer Network Requests**: Only loads images that are actually visible
- **Improved Scroll Performance**: Smooth scrolling even with 500+ images
- **Battery Conservation**: Reduced network and processing activity
- **Better UX**: Faster initial rendering with placeholders

## Features

- ✅ Visibility-based lazy loading with configurable threshold
- ✅ Integration with `cached_network_image` for automatic caching
- ✅ Custom placeholder and error widgets
- ✅ Fade-in animations
- ✅ Border radius support
- ✅ Thumbnail support (load smaller image first)
- ✅ Memory cache size limits
- ✅ Multiple convenience constructors

## Basic Usage

### Simple Lazy-Loaded Image

```dart
import 'package:soloadventurer/core/widgets/widgets.dart';

LazyLoadImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => Container(
    color: Colors.grey[300],
    child: const Center(child: CircularProgressIndicator()),
  ),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)
```

### Photo Grid Item (Square)

```dart
LazyLoadImage.photo(
  imageUrl: photo.url,
  size: 100.0,
  placeholder: (context, url) => Container(
    color: Colors.grey[300],
    child: const Center(child: CircularProgressIndicator()),
  ),
)
```

### Card Image (Rectangular)

```dart
LazyLoadImage.card(
  imageUrl: trip.coverImage,
  width: double.infinity,
  height: 200.0,
)
```

### Thumbnail (Small)

```dart
LazyLoadImage.thumbnail(
  imageUrl: user.avatarUrl,
  size: 48.0,
)
```

## Advanced Usage

### Custom Visibility Threshold

Control when the image starts loading by adjusting the visibility threshold:

```dart
// Load when 1% visible (default, most aggressive)
LazyLoadImage(
  imageUrl: url,
  visibilityThreshold: 0.01,
)

// Load when 50% visible
LazyLoadImage(
  imageUrl: url,
  visibilityThreshold: 0.5,
)

// Load when fully visible
LazyLoadImage(
  imageUrl: url,
  visibilityThreshold: 1.0,
)
```

### With Thumbnail Loading

Load a smaller thumbnail first, then load the full image:

```dart
LazyLoadImage(
  imageUrl: 'https://example.com/full-image.jpg',
  thumbnailUrl: 'https://example.com/thumbnail.jpg',
  placeholder: (context, url) => Container(
    color: Colors.grey[300],
  ),
)
```

### Custom Fade-In Animation

```dart
LazyLoadImage(
  imageUrl: url,
  fadeInDuration: const Duration(milliseconds: 500),
)
```

### With Border Radius

```dart
LazyLoadImage.photo(
  imageUrl: url,
  borderRadius: BorderRadius.circular(12.0),
)
```

## Integration with Virtual Scrolling

Combine `LazyLoadImage` with `VirtualGridView` for optimal performance:

```dart
VirtualGridView<Photo>(
  itemCount: photos.length,
  crossAxisCount: 3,
  itemBuilder: (context, index) {
    final photo = photos[index];
    return LazyLoadImage.photo(
      imageUrl: photo.displayUrl,
      thumbnailUrl: photo.thumbnailUrl,
      key: ValueKey(photo.id),
    );
  },
)
```

## Use Cases

### Photo Gallery

```dart
VirtualGridView<Photo>(
  itemCount: photos.length,
  crossAxisCount: _getCrossAxisCount(context),
  itemBuilder: (context, index) {
    return LazyLoadImage.photo(
      imageUrl: photos[index].displayUrl,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image),
      ),
    );
  },
)
```

### Trip List with Thumbnails

```dart
VirtualListView<Trip>(
  itemCount: trips.length,
  itemBuilder: (context, index) {
    return ListTile(
      leading: LazyLoadImage.thumbnail(
        imageUrl: trips[index].thumbnailUrl,
        size: 48.0,
      ),
      title: Text(trips[index].title),
      subtitle: Text(trips[index].destination),
    );
  },
)
```

### Activity Cards with Cover Images

```dart
VirtualListView<Activity>(
  itemCount: activities.length,
  itemBuilder: (context, index) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LazyLoadImage.card(
            imageUrl: activities[index].coverImage,
            height: 200.0,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(activities[index].title),
          ),
        ],
      ),
    );
  },
)
```

## Performance Considerations

### Memory Usage

- With lazy loading: ~50 MB for 500 photos (only visible ones loaded)
- Without lazy loading: ~500+ MB for 500 photos (all loaded immediately)

### Network Requests

- With lazy loading: ~20-30 initial requests (visible items)
- Without lazy loading: 500 requests (all at once)

### Scroll Performance

- Target: ≥55 FPS with 500+ images
- Lazy loading helps maintain smooth scrolling by reducing memory pressure

## Best Practices

### 1. Always Provide Keys in Lists

```dart
// Good
LazyLoadImage.photo(
  key: ValueKey(photo.id),
  imageUrl: photo.url,
)

// Bad
LazyLoadImage.photo(
  imageUrl: photo.url, // No key can cause widget reuse issues
)
```

### 2. Use Appropriate Convenience Constructors

```dart
// For photo grids
LazyLoadImage.photo(imageUrl: url, size: 100.0)

// For card layouts
LazyLoadImage.card(imageUrl: url, height: 200.0)

// For small thumbnails
LazyLoadImage.thumbnail(imageUrl: url, size: 48.0)
```

### 3. Provide Placeholder and Error Widgets

```dart
LazyLoadImage(
  imageUrl: url,
  placeholder: (context, url) => Container(
    color: Colors.grey[300],
    child: const Center(child: CircularProgressIndicator()),
  ),
  errorWidget: (context, url, error) => Container(
    color: Colors.grey[300],
    child: const Icon(Icons.broken_image),
  ),
)
```

### 4. Adjust Visibility Threshold Based on Use Case

```dart
// Photo grid: Load as soon as any part is visible
LazyLoadImage.photo(
  imageUrl: url,
  visibilityThreshold: 0.01,
)

// Hero images: Load when more visible to reduce flicker
LazyLoadImage(
  imageUrl: url,
  visibilityThreshold: 0.5,
)
```

### 5. Use Thumbnails for Large Lists

```dart
LazyLoadImage(
  imageUrl: fullSizeUrl,
  thumbnailUrl: thumbnailUrl, // Load small image first
)
```

## Migration Guide

### From Image.network

**Before:**
```dart
Image.network(
  imageUrl,
  fit: BoxFit.cover,
  loadingBuilder: (context, child, progress) {
    if (progress == null) return child;
    return CircularProgressIndicator();
  },
  errorBuilder: (context, error, stack) {
    return Icon(Icons.error);
  },
)
```

**After:**
```dart
LazyLoadImage(
  imageUrl: imageUrl,
  fit: BoxFit.cover,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### From CachedNetworkImage

**Before:**
```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  fit: BoxFit.cover,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

**After:**
```dart
LazyLoadImage(
  imageUrl: imageUrl,
  fit: BoxFit.cover,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

Note: `LazyLoadImage` uses `CachedNetworkImage` internally, so caching is preserved.

## Troubleshooting

### Images Not Loading

**Problem:** Images show placeholder but never load.

**Solution:** Check that:
1. The image URL is valid
2. The device has network connectivity
3. The visibility threshold is achievable (0.01-0.5 recommended)

### Images Load Too Late

**Problem:** User scrolls past image before it loads.

**Solution:** Reduce visibility threshold to load earlier:
```dart
LazyLoadImage(
  imageUrl: url,
  visibilityThreshold: 0.01, // Load when barely visible
)
```

### Images Load Too Early

**Problem:** Too many images load at once, affecting performance.

**Solution:** Increase visibility threshold:
```dart
LazyLoadImage(
  imageUrl: url,
  visibilityThreshold: 0.5, // Load when 50% visible
)
```

### Memory Still High

**Problem:** Memory usage is still high with lazy loading.

**Solution:**
1. Use thumbnails instead of full images
2. Reduce image quality/size server-side
3. Implement cache size limits in `cached_network_image` configuration (see phase-3-subtask-2)

## Testing

### Widget Test

```dart
testWidgets('LazyLoadImage shows placeholder before visibility', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: LazyLoadImage(
        imageUrl: 'https://example.com/test.jpg',
        placeholder: (context, url) => const Text('Loading'),
      ),
    ),
  );

  expect(find.text('Loading'), findsOneWidget);
});
```

### Performance Test

```dart
test('LazyLoadImage reduces memory usage with 500 images', () async {
  final memoryBefore = await PerformanceReporter.captureMemoryUsage();

  // Render 500 images (off-screen)
  await tester.pumpWidget(
    MaterialApp(
      home: ListView.builder(
        itemCount: 500,
        itemBuilder: (context, index) => SizedBox(
          height: 100,
          child: LazyLoadImage(imageUrl: 'https://example.com/$index.jpg'),
        ),
      ),
    ),
  );

  final memoryAfter = await PerformanceReporter.captureMemoryUsage();
  final memoryDelta = memoryAfter - memoryBefore;

  // Memory should be < 100MB since images aren't loaded yet
  expect(memoryDelta, lessThan(100 * 1024 * 1024));
});
```

## Future Enhancements

- [ ] Add progressive image loading (blur-up effect)
- [ ] Implement image preloading for next items
- [ ] Add GIF support with pause when not visible
- [ ] Support for local images with lazy loading
- [ ] Integration with advanced image caching strategies (phase-3-subtask-2)

## See Also

- [VirtualGridView](./VIRTUAL_GRID_VIEW_README.md) - For efficient grid layouts
- [VirtualListView](./README.md) - For efficient list layouts
- [Performance Tracking Guide](./PERFORMANCE_TRACKING_GUIDE.md) - For monitoring image performance
