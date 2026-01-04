# Image Cache Configuration

Optimized image caching strategy for handling large photo collections (500+ photos) with memory efficiency and smooth scrolling performance.

## Overview

The `ImageCacheConfig` utility configures the `cached_network_image` package to optimize memory usage and performance when displaying large numbers of photos. It works in conjunction with the `LazyLoadImage` widget to provide a complete image optimization solution.

## Configuration

### Default Settings

```dart
ImageCacheConfig.initialize();
```

Default configuration optimized for mid-range devices:
- **Memory Cache**: 150 MB (~100-200 images)
- **Disk Cache**: 500 MB (offline support)
- **Max Memory Images**: 200 images
- **Image Quality**: 85% JPEG compression

### Custom Settings

For low-end devices or specific use cases:

```dart
// Low-end device configuration
await ImageCacheConfig.initialize(
  maxMemoryCacheBytes: 50 * 1024 * 1024,  // 50 MB
  maxDiskCacheBytes: 200 * 1024 * 1024,   // 200 MB
  maxMemoryCacheImages: 50,
);

// High-end device configuration
await ImageCacheConfig.initialize(
  maxMemoryCacheBytes: 300 * 1024 * 1024, // 300 MB
  maxDiskCacheBytes: 1024 * 1024 * 1024,  // 1 GB
  maxMemoryCacheImages: 500,
);
```

## Memory Cache Dimensions

The `LazyLoadImage` widget uses `memCacheWidth` and `memCacheHeight` parameters to cache images at reduced resolution, significantly lowering memory usage.

### Example: Photo Grid

```dart
LazyLoadImage.photo(
  imageUrl: photo.url,
  size: 100.0,
)
// Internally caches at ~150x150 pixels (1.5x for sharpness)
// Memory: ~30-50 KB per image vs 500-1000 KB at full resolution
```

### Example: Card Image

```dart
LazyLoadImage.card(
  imageUrl: trip.coverImage,
  width: double.infinity,
  height: 200.0,
)
// Caches at screen width x 300 pixels
// Memory: ~100-200 KB per image
```

### Custom Cache Dimensions

```dart
final dimensions = ImageCacheConfig.getMemoryCacheDimensions(
  100.0,  // display width
  100.0,  // display height
);

CachedNetworkImage(
  imageUrl: url,
  memCacheWidth: dimensions.width,
  memCacheHeight: dimensions.height,
)
```

## Cache Management

### Get Cache Statistics

```dart
final stats = await ImageCacheConfig.getCacheStats();
debugPrint('Memory Cache: ${stats.formattedMemoryCacheSize}');
debugPrint('Cached Images: ${stats.memoryCacheCount}');
debugPrint('Average Memory per Image: ${stats.formattedMemoryCacheSize / stats.memoryCacheCount}');
debugPrint('Disk Cache: ${stats.formattedDiskCacheSize}');
```

### Clear Memory Cache

Useful for freeing memory under memory pressure:

```dart
await ImageCacheConfig.clearMemoryCache();
```

### Clear Disk Cache

Useful for logging out or freeing storage:

```dart
await ImageCacheConfig.clearDiskCache();
```

### Clear All Caches

```dart
await ImageCacheConfig.clearAllCaches();
```

## Performance Benefits

### Memory Usage Comparison

**Without Optimization:**
- 500 photos at full resolution (1920x1080)
- Memory: ~500 MB - 1 GB
- Result: App crashes or severe lag

**With Image Cache Config + Lazy Loading:**
- 500 photos with memory cache dimensions (150x150)
- Only 20-30 images loaded (visible)
- Memory: ~50-100 MB
- Result: Smooth scrolling, no crashes

### Example Calculation

**Photo Gallery Grid (500 photos):**

Without optimization:
```
500 images × 1 MB per image = 500 MB
+ Thumbnail rendering = +200 MB
+ Image decoding overhead = +100 MB
Total = ~800 MB → Out of memory on most devices
```

With ImageCacheConfig + LazyLoadImage:
```
30 visible images × 50 KB per cached image = 1.5 MB
+ Grid rendering overhead = 5 MB
+ Framework overhead = 10 MB
Total = ~16.5 MB → Well within limits
```

**Memory Reduction: 98%**

## Architecture

### Cache Strategy

1. **Memory Cache (Fastest)**
   - Stores ~100-200 images in memory
   - Instant access (no I/O)
   - Limited by memory constraints
   - Evicted by LRU policy when full

2. **Disk Cache (Fast)**
   - Stores frequently accessed images
   - Persistent across app restarts
   - Limited by storage constraints
   - Used for offline support

3. **Network (Slowest)**
   - Downloads images on-demand
   - Only for images not in cache
   - Lazy loaded when visible
   - Reduced network requests

### Cache Flow Diagram

```
┌─────────────┐
│ Request     │
│ Image       │
└──────┬──────┘
       │
       v
┌─────────────┐     Yes      ┌──────────────┐
│ In Memory   │──────────────►│ Return       │
│ Cache?      │               │ Immediately  │
└─────────────┘               └──────────────┘
       │ No
       v
┌─────────────┐     Yes      ┌──────────────┐
│ On Disk     │──────────────►│ Load & Cache │
│ Cache?      │               │ in Memory    │
└─────────────┘               └──────────────┘
       │ No
       v
┌─────────────┐
│ Download    │
│ from Network│
└──────┬──────┘
       │
       v
┌─────────────┐
│ Cache to    │
│ Disk &      │
│ Memory      │
└─────────────┘
```

## Integration with LazyLoadImage

The `ImageCacheConfig` works seamlessly with `LazyLoadImage`:

```dart
// In bootstrap.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize image cache configuration
  await ImageCacheConfig.initialize();

  runApp(MyApp());
}

// In UI
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

## Cache Settings by Image Type

### Photos (Grid)

```dart
// LazyLoadImage.photo() uses:
// - Size: 100x100 (default)
// - Memory cache: ~150x150 pixels
// - Memory per image: ~30-50 KB
LazyLoadImage.photo(
  imageUrl: url,
  size: 100.0,
)
```

### Card Images

```dart
// LazyLoadImage.card() uses:
// - Size: Full width x 200 height
// - Memory cache: Scaled by device pixel ratio
// - Memory per image: ~100-200 KB
LazyLoadImage.card(
  imageUrl: url,
  height: 200.0,
)
```

### Thumbnails (List)

```dart
// LazyLoadImage.thumbnail() uses:
// - Size: 48x48 (default)
// - Memory cache: ~72x72 pixels
// - Memory per image: ~10-15 KB
LazyLoadImage.thumbnail(
  imageUrl: url,
  size: 48.0,
)
```

## Debugging

### Enable Logging

In debug mode, `ImageCacheConfig` logs cache initialization and operations:

```dart
// Debug output:
// ImageCacheConfig: Initialized with settings:
//   - Max Memory Cache: 150.0 MB
//   - Max Disk Cache: 500.0 MB
//   - Max Memory Images: 200
```

### Monitor Cache Size

```dart
// Periodic cache monitoring
Timer.periodic(Duration(minutes: 5), (timer) async {
  final stats = await ImageCacheConfig.getCacheStats();
  if (stats.memoryCacheSize > 100 * 1024 * 1024) {
    // Cache exceeds 100 MB, consider clearing
    await ImageCacheConfig.clearMemoryCache();
  }
});
```

### Memory Pressure Handling

```dart
// Listen to memory pressure warnings
import 'dart:io';

// On memory warnings, clear caches
if (Platform.isIOS) {
  // iOS memory pressure handling
} else if (Platform.isAndroid) {
  // Android memory trimming
}
```

## Best Practices

1. **Initialize Early**: Call `ImageCacheConfig.initialize()` in `bootstrap.dart` before any image loading

2. **Use LazyLoadImage**: Always use `LazyLoadImage` for visible-only loading

3. **Set Cache Dimensions**: Use `memCacheWidth` and `memCacheHeight` for all large images

4. **Monitor Cache Size**: Check cache stats in development to ensure settings are optimal

5. **Clear on Logout**: Clear disk cache when user logs out to free storage

6. **Device-Specific Settings**: Adjust cache limits based on device capabilities

7. **Profile Memory**: Use Flutter DevTools to monitor actual memory usage

## Testing

### Unit Tests

```dart
test('ImageCacheConfig initializes correctly', () async {
  await ImageCacheConfig.initialize();

  final stats = await ImageCacheConfig.getCacheStats();
  expect(stats.isInitialized, isTrue);
});
```

### Integration Tests

```dart
testWidgets('Image cache limits memory usage', (tester) async {
  // Load 500 photos
  final photos = List.generate(500, (i) => Photo(id: '$i', url: 'https://...'));

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: VirtualGridView<Photo>(
          itemCount: photos.length,
          crossAxisCount: 3,
          itemBuilder: (context, index) => LazyLoadImage.photo(
            imageUrl: photos[index].url,
          ),
        ),
      ),
    ),
  );

  // Check memory usage is within limits
  final stats = await ImageCacheConfig.getCacheStats();
  expect(stats.memoryCacheSize, lessThan(150 * 1024 * 1024)); // 150 MB
});
```

## Troubleshooting

### High Memory Usage

**Problem**: Memory usage exceeds cache limits

**Solutions**:
1. Verify `memCacheWidth` and `memCacheHeight` are set
2. Reduce `maxMemoryCacheImages` in `initialize()`
3. Check for image leaks (images not disposed)
4. Use `clearMemoryCache()` periodically

### Images Not Caching

**Problem**: Images reload every time

**Solutions**:
1. Ensure `ImageCacheConfig.initialize()` is called before image loading
2. Check disk cache size is not exceeded
3. Verify image URLs are consistent
4. Check cache directory permissions

### App Startup Delay

**Problem**: App takes too long to start

**Solutions**:
1. Move `ImageCacheConfig.initialize()` after initial frame
2. Reduce disk cache size (disk cache can be slow to initialize)
3. Use async loading for cache configuration
4. Defer cache initialization for non-critical images

## Performance Targets

With `ImageCacheConfig` and `LazyLoadImage`:

- ✅ Memory usage: < 150 MB for 500 photos
- ✅ Scroll FPS: ≥ 55 FPS
- ✅ App startup: < 2 seconds
- ✅ Network requests: 95% reduction (20-30 vs 500)
- ✅ Battery efficiency: Improved (less network/CPU usage)

## See Also

- [LazyLoadImage Documentation](../widgets/LAZY_LOAD_IMAGE_README.md)
- [VirtualListView Documentation](../widgets/README.md#virtuallistview)
- [Performance Testing Guide](../../test/utils/performance/README.md)
