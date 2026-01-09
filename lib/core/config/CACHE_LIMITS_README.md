# Image Cache Limits and LRU Eviction

## Overview

This document explains how image cache limits are configured and how LRU (Least Recently Used) eviction works to prevent memory issues when handling large photo collections (500+ images).

## What Was Implemented

### 1. Actual Cache Limit Configuration

**Problem:** The previous implementation defined cache limits but didn't actually configure Flutter's image cache with these limits.

**Solution:** Modified `_configureCacheSettings()` to properly set:

```dart
final imageCache = PaintingBinding.instance.imageCache;

// Set maximum number of images to cache in memory
imageCache.maximumSize = maxMemoryCacheImages;

// Set maximum memory cache size in bytes
imageCache.maximumSizeBytes = maxMemoryCacheBytes;
```

### 2. LRU Eviction

Flutter's image cache uses **automatic LRU eviction**. When either limit is reached:

- The cache evicts the **least recently used** images first
- Images that haven't been accessed in the longest time are removed
- This continues until the cache is under both limits again

**Example:**
```
Cache Configuration:
- maximumSize: 200 images
- maximumSizeBytes: 150 MB

Scenario: Cache has 200 images using 160 MB
→ Evicts least recently used images until usage is ≤ 150 MB

Scenario: Cache has 250 images using 140 MB
→ Evicts least recently used images until count is ≤ 200
```

### 3. New Utility Methods

Added methods to verify and inspect cache configuration:

```dart
// Check if cache limits are properly configured
bool isConfigured = ImageCacheConfig.isCacheConfigured();

// Get current maximum number of images
int maxImages = ImageCacheConfig.getCurrentMaximumSize();

// Get current maximum memory size in bytes
int maxBytes = ImageCacheConfig.getCurrentMaximumSizeBytes();
```

## Default Configuration

### Mid-Range Devices (Default)
```dart
await ImageCacheConfig.initialize();
```

- **Max Images:** 200
- **Max Memory:** 150 MB (~100-200 images)
- **Max Disk:** 500 MB
- **Average Image Size:** 500KB - 1MB

### Low-End Devices
```dart
await ImageCacheConfig.initialize(
  maxMemoryCacheBytes: 50 * 1024 * 1024,  // 50 MB
  maxDiskCacheBytes: 200 * 1024 * 1024,   // 200 MB
  maxMemoryCacheImages: 50,
);
```

### High-End Devices
```dart
await ImageCacheConfig.initialize(
  maxMemoryCacheBytes: 300 * 1024 * 1024, // 300 MB
  maxDiskCacheBytes: 1024 * 1024 * 1024,  // 1 GB
  maxMemoryCacheImages: 500,
);
```

## How LRU Eviction Works

### Access Pattern Tracking

Flutter's image cache tracks the **last access time** for each cached image:

```dart
// Image loaded and cached
image1.resolve(configuration); // Last access: now

// Later...
image2.resolve(configuration); // Last access: now

// Even later...
image1.resolve(configuration); // Last access: now (image1 becomes most recent)
```

### Eviction Algorithm

When a cache limit is exceeded:

1. **Identify** all images currently in cache
2. **Sort** by last access time (oldest first)
3. **Remove** images from oldest to newest
4. **Stop** when both limits are satisfied

```dart
// Pseudocode for LRU eviction
while (cache.size > maximumSize || cache.bytes > maximumSizeBytes) {
  final oldestImage = cache.findOldestImage();
  cache.remove(oldestImage);
}
```

### Dual-Limit Checking

Both limits are checked simultaneously:

```dart
// Both conditions must be satisfied
if (cache.size <= maximumSize && cache.bytes <= maximumSizeBytes) {
  // Cache is within limits
} else {
  // Evict least recently used images
}
```

## Verification

### Verify Cache Configuration

```dart
// After initialization
await ImageCacheConfig.initialize();

// Check if limits are properly set
if (ImageCacheConfig.isCacheConfigured()) {
  debugPrint('✅ Cache limits configured');
} else {
  debugPrint('⚠️ Cache limits NOT configured');
}

// Get actual limits
final maxImages = ImageCacheConfig.getCurrentMaximumSize();
final maxBytes = ImageCacheConfig.getCurrentMaximumSizeBytes();

debugPrint('Max images: $maxImages');
debugPrint('Max memory: ${maxBytes / (1024 * 1024)} MB');
```

### Monitor Cache Usage

```dart
final stats = await ImageCacheConfig.getCacheStats();

debugPrint('Current usage:');
debugPrint('  - Images: ${stats.memoryCacheCount}/${maxImages}');
debugPrint('  - Memory: ${stats.formattedMemoryCacheSize}');
debugPrint('  - Average: ${stats.averageMemoryPerImage ~/ 1024} KB per image');
```

## Performance Benefits

### Memory Management

**Without Cache Limits:**
```
500 photos × 1 MB per image = 500 MB
→ Out of memory crash on most devices
```

**With Cache Limits (150 MB, 200 images):**
```
30 visible images × 50 KB cached image = 1.5 MB
+ Cache overhead = ~15 MB
Total = ~16.5 MB → Well within device limits
```

### LRU Efficiency

For a photo gallery with 500 photos:

1. **Initial Scroll (photos 1-30):** Cache fills to ~15 MB
2. **Scroll to photo 100:** Photos 1-30 still in cache (recently used)
3. **Scroll to photo 250:** Photos 1-30 evicted (least recently used)
4. **Scroll back to photo 1:** Reloaded from disk cache (if available) or network

**Key Benefits:**
- **Memory bounded:** Never exceeds configured limit
- **Smooth scrolling:** Recently viewed photos stay in cache
- **Automatic management:** No manual cache clearing needed
- **Predictable behavior:** Memory usage stays within limits

## Integration Points

### With MemoryMonitor

The cache limits work with the memory monitoring system from phase-6-subtask-1:

```dart
await MemoryMonitor.initialize(
  config: MemoryMonitorConfig(
    warningThresholdBytes: 150 * 1024 * 1024,
    criticalThresholdBytes: 180 * 1024 * 1024,
  ),
  onAlert: (alert) async {
    if (alert.level == MemoryAlertLevel.critical) {
      // Clear image cache to free memory
      await ImageCacheConfig.clearMemoryCache();
    }
  },
);
```

### With LazyLoadImage

LazyLoadImage widget respects the configured cache limits:

```dart
LazyLoadImage.photo(
  imageUrl: photo.url,
  size: 100.0,
  // Uses cached dimensions to reduce memory footprint
  // Subject to LRU eviction when cache is full
)
```

### With ThumbnailService

Thumbnails are cached with the same limits:

```dart
// Thumbnails cached by ImageCacheConfig
// LRU eviction applies to thumbnails too
final thumbnail = await ThumbnailService.generate(
  imageUrl: url,
  size: ThumbnailSize.small, // 100x100 pixels, ~10 KB
);
```

## Testing

### Unit Tests

Added comprehensive tests to verify cache limit configuration:

```dart
test('cache limits are properly set on Flutter image cache', () async {
  const expectedMaxImages = 100;
  const expectedMaxBytes = 75 * 1024 * 1024; // 75 MB

  await ImageCacheConfig.initialize(
    maxMemoryCacheImages: expectedMaxImages,
    maxMemoryCacheBytes: expectedMaxBytes,
  );

  final actualMaxImages = ImageCacheConfig.getCurrentMaximumSize();
  final actualMaxBytes = ImageCacheConfig.getCurrentMaximumSizeBytes();

  expect(actualMaxImages, equals(expectedMaxImages));
  expect(actualMaxBytes, equals(expectedMaxBytes));
  expect(ImageCacheConfig.isCacheConfigured(), isTrue);
});
```

Run tests:
```bash
flutter test test/core/config/image_cache_config_test.dart
```

### Manual Verification

1. **Start App:**
   ```dart
   await ImageCacheConfig.initialize();
   debugPrint('Cache configured: ${ImageCacheConfig.isCacheConfigured()}');
   ```

2. **Monitor During Scroll:**
   ```dart
   // In a photo gallery screen
   final stats = await ImageCacheConfig.getCacheStats();
   debugPrint('Cache usage: ${stats.memoryCacheCount}/${ImageCacheConfig.getCurrentMaximumSize()} images');
   ```

3. **Trigger Eviction:**
   - Load enough photos to exceed the limit
   - Verify that old photos are evicted
   - Verify that recently viewed photos remain

## Troubleshooting

### Issue: Cache limits not working

**Symptoms:**
- Memory usage exceeds configured limit
- Too many images in cache

**Solution:**
```dart
// Verify configuration
debugPrint('Configured: ${ImageCacheConfig.isCacheConfigured()}');
debugPrint('Max size: ${ImageCacheConfig.getCurrentMaximumSize()}');
debugPrint('Max bytes: ${ImageCacheConfig.getCurrentMaximumSizeBytes()}');

// Re-initialize if needed
ImageCacheConfig.dispose();
await ImageCacheConfig.initialize();
```

### Issue: Frequent cache evictions

**Symptoms:**
- Images constantly reloading
- Janky scrolling

**Solution:**
```dart
// Increase cache limits for better performance
await ImageCacheConfig.initialize(
  maxMemoryCacheBytes: 200 * 1024 * 1024, // 200 MB
  maxMemoryCacheImages: 300,
);
```

### Issue: Out of memory errors

**Symptoms:**
- App crashes with OOM
- System kills app

**Solution:**
```dart
// Decrease cache limits for low-memory devices
await ImageCacheConfig.initialize(
  maxMemoryCacheBytes: 50 * 1024 * 1024, // 50 MB
  maxMemoryCacheImages: 50,
);
```

## Best Practices

1. **Always initialize during app startup:**
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await ImageCacheConfig.initialize();
     runApp(MyApp());
   }
   ```

2. **Use device-specific configurations:**
   ```dart
   final deviceInfo = DeviceInfo();
   final config = deviceInfo.isLowEnd
     ? CacheConfig.lowEnd
     : CacheConfig.defaultConfig;

   await ImageCacheConfig.initialize(
     maxMemoryCacheBytes: config.maxMemory,
     maxMemoryCacheImages: config.maxImages,
   );
   ```

3. **Monitor cache usage in development:**
   ```dart
   if (kDebugMode) {
     Timer.periodic(Duration(seconds: 30), (_) async {
       final stats = await ImageCacheConfig.getCacheStats();
       debugPrint('Cache: ${stats.memoryCacheCount} images, ${stats.formattedMemoryCacheSize}');
     });
   }
   ```

4. **Clear caches on memory alerts:**
   ```dart
   await MemoryMonitor.initialize(
     onAlert: (alert) async {
       if (alert.level == MemoryAlertLevel.warning) {
         await ImageCacheConfig.clearMemoryCache();
       }
     },
   );
   ```

## Summary

The image cache limits and LRU eviction system ensures:

✅ **Bounded Memory Usage:** Never exceeds configured limits
✅ **Automatic Eviction:** LRU algorithm removes least recently used images
✅ **Smooth Performance:** Recently viewed images stay cached
✅ **Predictable Behavior:** Memory usage stays within device limits
✅ **Easy Configuration:** Simple initialization with sensible defaults
✅ **Full Control:** Custom limits for different device types

This implementation addresses the memory optimization goals from phase-6, ensuring the app can handle 500+ photos without running out of memory or experiencing performance issues.
