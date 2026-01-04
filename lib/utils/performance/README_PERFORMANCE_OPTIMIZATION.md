# Performance Optimization

This directory contains comprehensive performance optimization utilities for the SoloAdventurer app, focusing on image loading, list rendering, and database queries.

## Overview

The performance optimization system provides three main components:

1. **Image Caching** - Optimized image loading with caching and preloading
2. **List Pagination** - Efficient list rendering with pagination and infinite scroll
3. **Query Optimization** - Database query caching and field selection

## Table of Contents

- [Image Cache Manager](#image-cache-manager)
- [Paginated List Notifier](#paginated-list-notifier)
- [Query Optimizer](#query-optimizer)
- [Usage Examples](#usage-examples)
- [Best Practices](#best-practices)
- [Performance Metrics](#performance-metrics)

---

## Image Cache Manager

### Overview

The `ImageCacheManager` provides optimized image loading with automatic caching, preloading, and memory management. It uses `cached_network_image` package for efficient caching and provides multiple configurations for different use cases.

### Features

- ✅ Automatic memory and disk caching
- ✅ Image preloading for smooth scrolling
- ✅ Thumbnail generation for faster loading
- ✅ Configurable quality and size limits
- ✅ Progressive image loading
- ✅ Cache statistics and management
- ✅ Multiple predefined configurations

### Basic Usage

```dart
import 'package:soloadventurer/utils/performance/image_cache_manager.dart';

// Get singleton instance
final imageManager = ImageCacheManager.instance;

// Build cached thumbnail
Widget buildImage(String imageUrl) {
  return imageManager.buildThumbnail(
    imageUrl,
    fit: BoxFit.cover,
    placeholder: _buildPlaceholder(),
    errorWidget: _buildErrorWidget(),
  );
}

// Build full resolution image
Widget buildFullImage(String imageUrl) {
  return imageManager.buildFullImage(
    imageUrl,
    fit: BoxFit.contain,
  );
}

// Clear cache
await imageManager.clearCache();

// Get cache statistics
final stats = await imageManager.getCacheStats();
print('Cache: $stats');
```

### Configurations

#### Predefined Configurations

```dart
// For list items (smaller cache, lower quality)
imageManager.updateConfig(ImageCacheConfig.forList);

// For gallery view (larger cache, medium quality)
imageManager.updateConfig(ImageCacheConfig.forGallery);

// For thumbnails (small cache, low quality)
imageManager.updateConfig(ImageCacheConfig.forThumbnails);

// For detail view (largest cache, highest quality)
imageManager.updateConfig(ImageCacheConfig.forDetail);
```

#### Custom Configuration

```dart
final customConfig = ImageCacheConfig(
  maxMemoryCacheSize: 400,      // MB
  maxDiskCacheSize: 2000,        // MB
  imageQuality: 90,              // 1-100
  maxWidth: 1920,                // pixels
  maxHeight: 1080,               // pixels
  enablePreloading: true,
  preloadRadius: 5,              // number of images to preload
);

imageManager.updateConfig(customConfig);
```

### Image Preloading

```dart
// Preload list of images
final imageUrls = ['url1.jpg', 'url2.jpg', 'url3.jpg'];
await imageManager.preloadImages(imageUrls);

// Preload range around current index
await imageManager.preloadImageRange(allImageUrls, currentIndex);

// Set context for preloading
imageManager.setContext(context);
```

### Integration with MediaGallery

```dart
MediaGallery(
  mediaItems: items,
  config: MediaGalleryConfig.forTripOverview,
  onMediaTap: (media, index) {
    // Images are automatically cached
    // Preload nearby images
    final imageManager = ImageCacheManager.instance;
    final urls = items.map((m) => m.storagePath).toList();
    imageManager.preloadImageRange(urls, index);
  },
)
```

---

## Paginated List Notifier

### Overview

The `PaginatedNotifier` provides efficient list rendering with automatic pagination, infinite scroll, and state management. Perfect for large lists that would cause performance issues if loaded all at once.

### Features

- ✅ Automatic pagination with configurable page size
- ✅ Infinite scroll support
- ✅ Loading states for initial load and load more
- ✅ Error handling and retry
- ✅ Cache-friendly design
- ✅ Multiple predefined configurations

### Basic Usage

```dart
import 'package:soloadventurer/utils/performance/paginated_list_notifier.dart';

// Create a custom notifier for your data
class JournalListNotifier extends PaginatedNotifier<JournalEntry> {
  final JournalRepository _repository;

  JournalListNotifier(this._repository, PaginationConfig config)
      : super(config);

  @override
  Future<PaginatedResult<JournalEntry>> fetchPage(int page, int pageSize) async {
    final entries = await _repository.getEntriesPaginated(page, pageSize);
    final totalEntries = await _repository.getTotalCount();

    return PaginatedResult(
      items: entries,
      currentPage: page,
      totalPages: (totalEntries / pageSize).ceil(),
      totalItems: totalEntries,
      hasMore: entries.length == pageSize,
    );
  }
}

// Use in widget
final notifier = JournalListNotifier(repository, PaginationConfig.forMediumLists);

// Load initial page
await notifier.loadInitial();

// Load next page (usually triggered by scroll)
await notifier.loadNextPage();

// Check if should load more
bool shouldLoad = notifier.shouldLoadMore(currentIndex);
```

### Pagination Configurations

```dart
// For small lists (few items, faster initial load)
PaginationConfig.forSmallLists  // 10 items, threshold 3

// For medium lists (balanced)
PaginationConfig.forMediumLists // 20 items, threshold 5

// For large lists (more items, fewer network calls)
PaginationConfig.forLargeLists  // 50 items, threshold 10
```

### Integration with ListView

```dart
class OptimizedListView extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(journalListProvider);

    return ListView.builder(
      itemCount: state.hasMore
          ? state.items.length + 1
          : state.items.length,
      itemBuilder: (context, index) {
        // Check if need to load more
        if (state.shouldLoadMore(index)) {
          ref.read(journalListProvider.notifier).loadNextPage();
        }

        // Loading indicator at end
        if (index == state.items.length) {
          return const Center(child: CircularProgressIndicator());
        }

        // Build list item
        return JournalEntryCard(entry: state.items[index]);
      },
    );
  }
}
```

---

## Query Optimizer

### Overview

The `QueryOptimizer` provides intelligent caching for database queries with configurable TTL, field selection, and batch operations. It dramatically reduces redundant network calls and speeds up data loading.

### Features

- ✅ Automatic query result caching
- ✅ Configurable TTL per query
- ✅ Field selection for smaller payloads
- ✅ Batch query execution
- ✅ Cache statistics and hit rate tracking
- ✅ Automatic cleanup of expired entries
- ✅ LRU eviction policy

### Basic Usage

```dart
import 'package:soloadventurer/utils/performance/query_optimizer.dart';

// Create optimizer
final optimizer = QueryOptimizer(
  cacheConfig: CacheConfig.forLists,
  enableLogging: true, // Log queries for debugging
);

// Execute query with caching
final result = await optimizer.execute<List<JournalEntry>>(
  'journal_entries_user_123',  // Unique cache key
  () => repository.getEntries(),  // Fetcher function
  ttl: Duration(minutes: 2),  // Cache duration
  fields: QueryFields.forList,  // Field selection
);

if (result.isSuccess) {
  final entries = result.data!;
  print('Loaded ${entries.length} entries in ${result.durationMs}ms');
  print('From cache: ${result.fromCache}');
}

// Get statistics
final stats = optimizer.getStats();
print('Hit rate: ${(stats.hitRate * 100).toStringAsFixed(1)}%');

// Clear cache
optimizer.clearCache();

// Dispose when done
optimizer.dispose();
```

### Field Selection

```dart
// Predefined field selections
QueryFields.forList    // Minimal fields for list views
QueryFields.forDetail  // All fields for detail views
QueryFields.forCard    // Card-specific fields
QueryFields.forMetadata  // Metadata fields

// Custom field selection
final customFields = QueryFields.custom([
  'id',
  'title',
  'entry_date',
  'thumbnail_url',
]);

// Use in query
await optimizer.execute(
  'query_key',
  () => fetchWithFields(customFields.toSelectString()),
  fields: customFields,
);
```

### Cache Invalidation

```dart
// Invalidate specific cache entry
optimizer.invalidate('journal_entries_user_123');

// Invalidate multiple entries
optimizer.invalidateMultiple([
  'journal_entry_456',
  'media_entry_456',
  'tags_entry_456',
]);

// Clear all cache
optimizer.clearCache();

// Automatic cleanup runs periodically
// Can also trigger manually
optimizer.cache.cleanup();
```

### Batch Operations

```dart
// Execute multiple queries in batch
final queries = [
  {
    'key': 'entries',
    'fetcher': () => repo.getEntries(),
    'ttl': Duration(minutes: 2),
  },
  {
    'key': 'trips',
    'fetcher': () => repo.getTrips(),
    'ttl': Duration(minutes: 10),
  },
  {
    'key': 'tags',
    'fetcher': () => repo.getTags(),
    'ttl': Duration(minutes: 5),
  },
];

final results = await optimizer.executeBatch<JournalEntry>(queries);

for (final result in results) {
  if (result.isSuccess) {
    print('Loaded ${result.data!.length} items');
  }
}
```

### Database Integration

```dart
// In your data source implementation
class JournalRemoteDataSourceOptimized {
  final QueryOptimizer _queryOptimizer;

  Future<List<JournalEntryModel>> getEntries() async {
    final userId = _client.auth.currentUser?.id;
    final cacheKey = 'journal_entries_user_$userId';

    final result = await _queryOptimizer.execute<List<JournalEntryModel>>(
      cacheKey,
      () => _fetchUserEntries(userId),  // Actual database call
      ttl: const Duration(minutes: 2),
      fields: QueryFields.forList,
    );

    if (result.isError) {
      throw ServerException(message: result.error!);
    }

    return result.data!;
  }

  Future<List<JournalEntryModel>> _fetchUserEntries(String userId) async {
    final response = await _client
        .from('journal_entries')
        .select(QueryFields.forList.toSelectString())  // Only select needed fields
        .eq('user_id', userId)
        .order('entry_date', ascending: false);

    return (response as List)
        .map((json) => JournalEntryModel.fromJson(json))
        .toList();
  }
}
```

---

## Usage Examples

### Example 1: Optimized Journal List Screen

```dart
class OptimizedJournalListScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(optimizedJournalListProvider);

    return Scaffold(
      body: state.isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(
                optimizedJournalListProvider.notifier
              ).refresh(),
              child: ListView.builder(
                itemCount: state.hasMore
                    ? state.items.length + 1
                    : state.items.length,
                itemBuilder: (context, index) {
                  // Auto-load more when reaching threshold
                  if (ref.read(
                    optimizedJournalListProvider.notifier
                  ).shouldLoadMore(index)) {
                    ref.read(
                      optimizedJournalListProvider.notifier
                    ).loadNextPage();
                  }

                  if (index == state.items.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return JournalEntryCard(
                    entry: state.items[index],
                  );
                },
              ),
            ),
    );
  }
}
```

### Example 2: Image Preloading for Smooth Scrolling

```dart
class OptimizedGalleryView extends StatefulWidget {
  @override
  _OptimizedGalleryViewState createState() => _OptimizedGalleryViewState();
}

class _OptimizedGalleryViewState extends State<OptimizedGalleryView> {
  final ScrollController _scrollController = ScrollController();
  final ImageCacheManager _imageManager = ImageCacheManager.instance;
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more images
      _loadMoreImages();
    }

    // Preload nearby images
    final firstVisible = _scrollController.position.minScrollExtent;
    final lastVisible = _scrollController.position.maxScrollExtent;

    // Calculate current index and preload range
    // ...
  }

  Future<void> _loadMoreImages() async {
    // Fetch more images
    setState(() {
      _imageUrls.addAll(newImages);
    });

    // Preload new images
    await _imageManager.preloadImages(newImages);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: _imageUrls.length,
      itemBuilder: (context, index) {
        return _imageManager.buildThumbnail(
          _imageUrls[index],
          fit: BoxFit.cover,
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

### Example 3: Query Caching with Invalidations

```dart
class JournalRepositoryImpl {
  final QueryOptimizer _queryOptimizer;

  @override
  Future<JournalEntry> updateEntry(JournalEntry entry) async {
    // Update in database
    final updated = await _dataSource.updateEntry(entry);

    // Invalidate all relevant caches
    _queryOptimizer.invalidateMultiple([
      'journal_entry_${entry.id}',
      'journal_entries_user_${userId}',
      if (entry.tripId != null) 'journal_entries_trip_${entry.tripId}',
    ]);

    return updated;
  }
}
```

---

## Best Practices

### 1. Image Caching

✅ **DO:**
- Use thumbnails in lists, full images in detail views
- Preload images around the current scroll position
- Clear cache when memory pressure is high
- Use appropriate quality for different contexts

❌ **DON'T:**
- Load full-resolution images in lists
- Disable caching unless absolutely necessary
- Preload too many images at once
- Use very high quality for thumbnails

### 2. List Pagination

✅ **DO:**
- Use appropriate page size for your data (10-50 items)
- Load next page before user reaches end (threshold)
- Show loading indicators at bottom of list
- Handle errors gracefully with retry buttons

❌ **DON'T:**
- Load all items at once for large lists
- Use too small page size (too many network calls)
- Block UI while loading more data
- Forget to handle edge cases (empty lists, errors)

### 3. Query Optimization

✅ **DO:**
- Use field selection to reduce payload size
- Set appropriate TTL based on data freshness
- Invalidate cache when data changes
- Monitor cache hit rates

❌ **DON'T:**
- Cache frequently changing data with long TTL
- Select all fields when you only need a few
- Forget to dispose optimizer when done
- Ignore cache statistics

### 4. General Performance

✅ **DO:**
- Profile before optimizing
- Measure improvements with metrics
- Test on real devices
- Consider offline scenarios

❌ **DON'T:**
- Over-optimize prematurely
- Make things complex without benefit
- Ignore memory usage
- Assume desktop performance = mobile performance

---

## Performance Metrics

### Expected Improvements

When properly implemented, these optimizations should provide:

- **Image Loading**: 60-80% faster subsequent loads (from cache)
- **List Rendering**: 3-5x smoother scrolling with pagination
- **Database Queries**: 40-60% reduction in network calls (from cache)
- **Memory Usage**: 30-50% reduction with proper field selection
- **UI Responsiveness**: Maintain 60 FPS during scrolling

### Measuring Performance

```dart
// Measure query performance
final stopwatch = Stopwatch()..start();
final result = await optimizer.execute(...);
stopwatch.stop();

print('Query took: ${stopwatch.elapsedMilliseconds}ms');
print('From cache: ${result.fromCache}');

// Measure cache effectiveness
final stats = optimizer.getStats();
print('Cache hit rate: ${(stats.hitRate * 100).toStringAsFixed(1)}%');
print('Total requests: ${stats.totalRequests}');

// Measure image cache
final imageStats = await ImageCacheManager.instance.getCacheStats();
print('Memory usage: ${(imageStats.memoryUsagePercent).toStringAsFixed(1)}%');
print('Cached items: ${imageStats.currentMemoryCount}');
```

---

## Troubleshooting

### Images Not Caching

**Problem**: Images reload every time

**Solutions**:
1. Check that `cached_network_image` is properly initialized
2. Verify cache size limits aren't too small
3. Ensure URLs are consistent (same URL = same cache entry)
4. Check disk space availability

### List Janky When Scrolling

**Problem**: Scrolling isn't smooth

**Solutions**:
1. Reduce page size to load fewer items
2. Use `const` constructors for list items
3. Implement `AutomaticKeepAliveClientMixin`
4. Profile with Flutter DevTools to find bottlenecks
5. Consider using `ListView.builder` instead of `ListView`

### Cache Not Working

**Problem**: Queries still hit network

**Solutions**:
1. Verify cache keys are unique and consistent
2. Check TTL hasn't expired
3. Ensure cache isn't being invalidated prematurely
4. Enable logging to see cache hits/misses
5. Check that `forceRefresh` parameter is false

### High Memory Usage

**Problem**: App using too much memory

**Solutions**:
1. Reduce cache sizes (memory and disk)
2. Lower image quality settings
3. Implement cache cleanup on low memory warnings
4. Use field selection to reduce data size
5. Dispose unused notifiers and optimizers

---

## Additional Resources

- [Flutter Performance Best Practices](https://flutter.dev/docs/perf)
- [cached_network_image package](https://pub.dev/packages/cached_network_image)
- [Supabase Query Optimization](https://supabase.com/docs/guides/api/performance)
- [Flutter DevTools](https://flutter.dev/docs/development/tools/devtools/overview)

---

## API Reference

### ImageCacheManager

- `instance` - Get singleton instance
- `buildCachedImage()` - Build optimized cached image
- `buildThumbnail()` - Build thumbnail image
- `buildFullImage()` - Build full resolution image
- `preloadImages()` - Preload list of images
- `preloadImageRange()` - Preload range around index
- `clearCache()` - Clear all cached images
- `getCacheStats()` - Get cache statistics
- `updateConfig()` - Update configuration
- `setContext()` - Set context for preloading

### PaginatedNotifier

- `loadInitial()` - Load first page
- `loadNextPage()` - Load next page
- `refresh()` - Refresh from first page
- `retry()` - Retry failed operation
- `shouldLoadMore()` - Check if should load more
- `reset()` - Reset to initial state
- `clear()` - Clear all data

### QueryOptimizer

- `execute()` - Execute cached query
- `executeBatch()` - Execute multiple queries
- `invalidate()` - Invalidate cache entry
- `invalidateMultiple()` - Invalidate multiple entries
- `clearCache()` - Clear all cache
- `getStats()` - Get cache statistics
- `dispose()` - Dispose resources

---

## Contributing

When adding new performance optimizations:

1. Profile before and after changes
2. Document expected improvements
3. Add examples in this README
4. Consider edge cases and error handling
5. Test on low-end devices
6. Monitor memory usage

---

**Last Updated**: 2025-01-07
**Version**: 1.0.0
