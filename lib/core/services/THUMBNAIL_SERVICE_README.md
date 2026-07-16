# Thumbnail Service

A comprehensive service for generating and caching thumbnails to reduce memory footprint and improve app performance.

## Overview

The `ThumbnailService` provides a complete solution for thumbnail generation and caching in Flutter applications. It's designed specifically for photo-heavy applications (like travel apps with 500+ photos) to:

- **Reduce memory usage** by 95% (50KB thumbnail vs 1MB full image)
- **Improve scrolling performance** in photo galleries and lists
- **Reduce network bandwidth** by caching smaller images
- **Provide fast access** to cached thumbnails

## Features

### 🎯 Multiple Thumbnail Sizes

```dart
enum ThumbnailSize {
  small(100, 100),   // List items
  medium(300, 300),  // Grid items
  large(600, 600),   // Previews
}
```

### 💾 Intelligent Caching

- Automatic cache management with size limits (100 MB default)
- LRU (Least Recently Used) eviction when cache is full
- Persistent cache across app restarts
- File-based storage for reliability

### ⚡ Performance Optimizations

- Batch thumbnail generation for multiple images
- Concurrent processing (10 images at a time)
- JPEG compression (80% quality)
- Automatic cleanup when cache exceeds limits

### 🔍 Cache Management

- Check if thumbnail exists
- Get cached thumbnail path
- Clear all cached thumbnails
- View cache statistics

## Installation

### 1. Add Dependencies

Already included in `pubspec.yaml`:

```yaml
dependencies:
  path_provider: ^2.1.2  # For cache directory access
  http: ^1.2.1           # For downloading images
  crypto: ^3.0.3         # For cache key generation
```

### 2. Initialize in Bootstrap

Add to `lib/app/bootstrap.dart`:

```dart
import 'package:soloadventurer/core/services/thumbnail_service.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ... other initialization ...

  // Initialize thumbnail service
  await ThumbnailService.initialize();

  runApp(MyApp());
}
```

## Usage

### Basic Thumbnail Generation

```dart
import 'package:soloadventurer/core/services/thumbnail_service.dart';

// Generate a medium-sized thumbnail
final thumbnailPath = await ThumbnailService.generateThumbnail(
  imageUrl: 'https://example.com/photo.jpg',
  size: ThumbnailSize.medium,
);

// Update photo model with thumbnail
photo = photo.copyWith(thumbnailUrl: thumbnailPath);
```

### Custom Thumbnail Sizes

```dart
// Generate thumbnail with custom dimensions
final thumbnailPath = await ThumbnailService.generateThumbnail(
  imageUrl: photo.imageUrl,
  width: 150,
  height: 150,
);
```

### Check if Thumbnail Exists

```dart
// Check if a thumbnail is already cached
final hasThumbnail = await ThumbnailService.hasThumbnail(
  photo.imageUrl,
  size: ThumbnailSize.small,
);

if (hasThumbnail) {
  // Use cached thumbnail
  final path = await ThumbnailService.getThumbnailPath(photo.imageUrl);
} else {
  // Generate thumbnail
  await ThumbnailService.generateThumbnail(
    imageUrl: photo.imageUrl,
    size: ThumbnailSize.small,
  );
}
```

### Batch Thumbnail Generation

```dart
// Generate thumbnails for multiple photos efficiently
final imageUrls = photos.map((p) => p.imageUrl).toList();

final thumbnails = await ThumbnailService.generateBatch(
  imageUrls: imageUrls,
  size: ThumbnailSize.small,
);

// Update all photos with thumbnail paths
for (var i = 0; i < photos.length; i++) {
  photos[i] = photos[i].copyWith(
    thumbnailUrl: thumbnails[photos[i].imageUrl],
  );
}
```

### Cache Management

```dart
// Get cache statistics
final stats = await ThumbnailService.getCacheStats();
debugPrint('Cache size: ${stats.formattedSize}');
debugPrint('Thumbnail count: ${stats.count}');
debugPrint('Average size: ${stats.formattedAverageSize}');

// Clear all cached thumbnails (e.g., on logout)
await ThumbnailService.clearCache();
```

## Integration with PhotoGalleryScreen

> **Note (2026-07-17):** `PhotoGalleryScreen` was **deleted** in Story 0.7 — it was unwired scaffold over a phantom `photos` table (see `docs/reports/phantom-schema-refs-2026-07-16.md`). The example below is retained as an **illustration of the API only**; the class no longer exists. The real media path is `media_items` + the journal (FOUNDATIONS §7).


Update your photo gallery to use thumbnails:

```dart
import 'package:soloadventurer/core/services/thumbnail_service.dart';

class PhotoGalleryScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends ConsumerState<PhotoGalleryScreen> {
  List<Photo> _photos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPhotosWithThumbnails();
  }

  Future<void> _loadPhotosWithThumbnails() async {
    setState(() => _isLoading = true);

    try {
      // Load photos from repository
      final photos = await ref.watch(photoRepositoryProvider).getPhotos();

      // Generate thumbnails in batch
      final imageUrls = photos.map((p) => p.imageUrl).toList();
      final thumbnails = await ThumbnailService.generateBatch(
        imageUrls: imageUrls,
        size: ThumbnailSize.medium,
      );

      // Update photos with thumbnails
      setState(() {
        _photos = photos.map((photo) {
          return photo.copyWith(
            thumbnailUrl: thumbnails[photo.imageUrl] ?? photo.imageUrl,
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return VirtualGridView<Photo>(
      itemCount: _photos.length,
      crossAxisCount: 3,
      itemBuilder: (context, index) {
        final photo = _photos[index];
        return LazyLoadImage.photo(
          key: ValueKey(photo.id),
          imageUrl: photo.displayUrl, // Uses thumbnailUrl if available
        );
      },
    );
  }
}
```

## Performance Benefits

### Memory Usage Comparison

**Without Thumbnails (500 photos):**
```
500 photos × 1 MB per image = 500 MB
+ Decoding overhead = +200 MB
+ Grid rendering = +100 MB
Total = ~800 MB → Out of memory on most devices
```

**With Thumbnails + LazyLoadImage:**
```
30 visible photos × 50 KB per thumbnail = 1.5 MB
+ Grid rendering overhead = 5 MB
+ Framework overhead = 10 MB
Total = ~16.5 MB → Well within limits
```

**Memory Reduction: 98%**

### Network Savings

**Without Thumbnails:**
- Downloads 500 full-size images on first load
- Total: ~500 MB network traffic

**With Thumbnails:**
- Downloads 500 thumbnails on first load
- Downloads full images only when tapped
- Total: ~25 MB for thumbnails

**Network Reduction: 95%**

## API Reference

### Methods

#### `initialize()`

Initialize the thumbnail service. Should be called during app startup.

```dart
static Future<void> initialize()
```

#### `generateThumbnail()`

Generate a thumbnail for a single image URL.

```dart
static Future<String> generateThumbnail({
  required String imageUrl,
  ThumbnailSize size = ThumbnailSize.medium,
  int? width,
  int? height,
})
```

**Parameters:**
- `imageUrl` - URL of the original image
- `size` - Thumbnail size preset (small, medium, large)
- `width` - Optional custom width
- `height` - Optional custom height

**Returns:** Local file path of the thumbnail

#### `generateBatch()`

Generate thumbnails for multiple images efficiently.

```dart
static Future<Map<String, String>> generateBatch({
  required List<String> imageUrls,
  ThumbnailSize size = ThumbnailSize.medium,
})
```

**Parameters:**
- `imageUrls` - List of image URLs
- `size` - Thumbnail size preset

**Returns:** Map of image URLs to thumbnail paths

#### `hasThumbnail()`

Check if a thumbnail exists in cache.

```dart
static Future<bool> hasThumbnail(
  String imageUrl, {
  ThumbnailSize size = ThumbnailSize.medium,
})
```

#### `getThumbnailPath()`

Get the cached thumbnail path.

```dart
static Future<String?> getThumbnailPath(
  String imageUrl, {
  ThumbnailSize size = ThumbnailSize.medium,
})
```

#### `clearCache()`

Clear all cached thumbnails.

```dart
static Future<void> clearCache()
```

#### `getCacheStats()`

Get current cache statistics.

```dart
static Future<ThumbnailCacheStats> getCacheStats()
```

**Returns:** `ThumbnailCacheStats` object with:
- `size` - Total cache size in bytes
- `count` - Number of cached thumbnails
- `isInitialized` - Whether service is initialized
- `formattedSize` - Human-readable size string
- `averageSize` - Average size per thumbnail
- `formattedAverageSize` - Human-readable average size

## Models

### `ThumbnailSize`

Enum for common thumbnail sizes:

```dart
enum ThumbnailSize {
  small(100, 100),   // For list items
  medium(300, 300),  // For grid items
  large(600, 600),   // For previews
}
```

### `ThumbnailCacheStats`

Statistics about the thumbnail cache:

```dart
class ThumbnailCacheStats {
  final int size;           // Total cache size in bytes
  final int count;          // Number of thumbnails
  final bool isInitialized; // Service initialization status

  String get formattedSize;         // Human-readable size
  double get averageSize;           // Average size per thumbnail
  String get formattedAverageSize;  // Human-readable average
}
```

## Testing

The thumbnail service includes comprehensive tests:

```bash
# Run thumbnail service tests
flutter test test/core/services/thumbnail_service_test.dart
```

### Test Coverage

- ✅ Initialization
- ✅ Thumbnail generation
- ✅ Cache management
- ✅ Batch processing
- ✅ Error handling
- ✅ Cache statistics
- ✅ Thumbnail existence checks
- ✅ Custom dimensions
- ✅ Different thumbnail sizes

## Best Practices

### 1. Initialize Early

Initialize the service during app startup in `bootstrap.dart`:

```dart
await ThumbnailService.initialize();
```

### 2. Use Batch Generation

When loading multiple photos, use `generateBatch()` instead of generating one at a time:

```dart
// ❌ Bad: Sequential generation
for (final photo in photos) {
  final thumbnail = await ThumbnailService.generateThumbnail(
    imageUrl: photo.imageUrl,
  );
}

// ✅ Good: Batch generation
final thumbnails = await ThumbnailService.generateBatch(
  imageUrls: photos.map((p) => p.imageUrl).toList(),
);
```

### 3. Choose Appropriate Sizes

Select the right thumbnail size for the use case:

```dart
// List items - small thumbnails
ThumbnailService.generateThumbnail(
  imageUrl: photo.imageUrl,
  size: ThumbnailSize.small,  // 100x100
);

// Grid items - medium thumbnails
ThumbnailService.generateThumbnail(
  imageUrl: photo.imageUrl,
  size: ThumbnailSize.medium, // 300x300
);

// Full-screen preview - large thumbnails
ThumbnailService.generateThumbnail(
  imageUrl: photo.imageUrl,
  size: ThumbnailSize.large,  // 600x600
);
```

### 4. Check Cache Before Generating

Avoid regenerating existing thumbnails:

```dart
if (!await ThumbnailService.hasThumbnail(photo.imageUrl)) {
  await ThumbnailService.generateThumbnail(
    imageUrl: photo.imageUrl,
  );
}
```

### 5. Clear Cache on Logout

Remove cached thumbnails when user logs out:

```dart
Future<void> logout() async {
  await ThumbnailService.clearCache();
  await authRepository.logout();
}
```

## Troubleshooting

### Issue: Thumbnails not appearing

**Solution:** Ensure the service is initialized:
```dart
await ThumbnailService.initialize();
```

### Issue: Cache grows too large

**Solution:** The service automatically cleans up when cache exceeds 100 MB. You can also manually clear:
```dart
await ThumbnailService.clearCache();
```

### Issue: Slow thumbnail generation

**Solution:** Use batch generation for multiple images:
```dart
final thumbnails = await ThumbnailService.generateBatch(
  imageUrls: imageUrls,
);
```

### Issue: Out of memory errors

**Solution:** Ensure you're using `LazyLoadImage` with thumbnails:
```dart
LazyLoadImage.photo(
  imageUrl: photo.displayUrl, // Uses thumbnailUrl if available
)
```

## Future Enhancements

Potential improvements for future versions:

- [ ] Progressive JPEG loading for better UX
- [ ] WebP format support for better compression
- [ ] Background thumbnail generation queue
- [ ] Thumbnail preloading for next items in list
- [ ] Adaptive quality based on network conditions
- [ ] Integration with cloud image services (Cloudinary, Imgix)

## Related Services

- **ImageCacheConfig**: Manages `cached_network_image` settings
- **LazyLoadImage**: Widget for visibility-based lazy loading
- **VirtualGridView**: Virtual scrolling for photo grids

## License

This service is part of the SoloAdventurer application.
