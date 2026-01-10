import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/data/datasources/journal_remote_data_source_optimized.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';
import 'package:soloadventurer/features/journal/domain/repositories/journal_repository.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_list_provider_optimized.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/media_gallery.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/journal_entry_card.dart';
import 'package:soloadventurer/utils/performance/image_cache_manager.dart';
import 'package:soloadventurer/utils/performance/paginated_list_notifier.dart';
import 'package:soloadventurer/utils/performance/query_optimizer.dart';

/// Example 1: Basic Image Caching
/// Demonstrates basic usage of ImageCacheManager for optimized image loading
class Example1_BasicImageCaching extends StatelessWidget {
  const Example1_BasicImageCaching({super.key});

  final String sampleImageUrl =
      'https://images.unsplash.com/photo-1469474968028-56623f02e42e';

  @override
  Widget build(BuildContext context) {
    final imageManager = ImageCacheManager.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Basic Image Caching')),
      body: Column(
        children: [
          // Thumbnail (fast, cached)
          Container(
            height: 200,
            margin: const EdgeInsets.all(16),
            child: imageManager.buildThumbnail(
              sampleImageUrl,
              fit: BoxFit.cover,
            ),
          ),

          // Full resolution (cached, higher quality)
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: imageManager.buildFullImage(
                sampleImageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 2: Image Preloading
/// Demonstrates preloading images for smooth gallery scrolling
class Example2_ImagePreloading extends StatefulWidget {
  const Example2_ImagePreloading({super.key});

  @override
  State<Example2_ImagePreloading> createState() =>
      _Example2_ImagePreloadingState();
}

class _Example2_ImagePreloadingState extends State<Example2_ImagePreloading> {
  final ScrollController _scrollController = ScrollController();
  final ImageCacheManager _imageManager = ImageCacheManager.instance;

  // Sample image URLs
  final List<String> _imageUrls = List.generate(
    20,
    (index) => 'https://picsum.photos/400/400?random=$index',
  );

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _imageManager.setContext(context);

    // Preload first few images
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _imageManager.preloadImageRange(_imageUrls, 0);
    });
  }

  void _onScroll() {
    // Calculate current visible index
    final pixels = _scrollController.position.pixels;
    const itemHeight = 120.0; // Approximate height
    final newIndex = (pixels / itemHeight).floor();

    if (newIndex != _currentIndex) {
      setState(() => _currentIndex = newIndex);

      // Preload images around current position
      _imageManager.preloadImageRange(_imageUrls, newIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Preloading'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Text('Currently viewing index $_currentIndex'),
        ),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _imageUrls.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8),
            child: SizedBox(
              height: 100,
              child: _imageManager.buildThumbnail(
                _imageUrls[index],
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

/// Example 3: Cache Statistics
/// Demonstrates monitoring cache performance
class Example3_CacheStatistics extends StatefulWidget {
  const Example3_CacheStatistics({super.key});

  @override
  State<Example3_CacheStatistics> createState() =>
      _Example3_CacheStatisticsState();
}

class _Example3_CacheStatisticsState extends State<Example3_CacheStatistics> {
  final ImageCacheManager _imageManager = ImageCacheManager.instance;
  ImageCacheStats? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _imageManager.getCacheStats();
    setState(() => _stats = stats);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cache Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await _imageManager.clearCache();
              _loadStats();
            },
          ),
        ],
      ),
      body: _stats == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ListTile(
                  title: const Text('Memory Cache'),
                  subtitle: Text(
                    '${(_stats!.currentMemoryCacheSize / 1024 / 1024).toStringAsFixed(1)} MB / '
                    '${(_stats!.maxMemoryCacheSize / 1024 / 1024).toStringAsFixed(1)} MB',
                  ),
                  trailing: Text(
                    '${(_stats!.memoryUsagePercent).toStringAsFixed(1)}%',
                  ),
                ),
                ListTile(
                  title: const Text('Cache Count'),
                  subtitle: Text('${_stats!.currentMemoryCount} images'),
                  trailing: Text('${_stats!.maxMemoryCount} max'),
                ),
                ElevatedButton(
                  onPressed: _loadStats,
                  child: const Text('Refresh Stats'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _imageManager.clearCache();
                    _loadStats();
                  },
                  child: const Text('Clear Cache'),
                ),
              ],
            ),
    );
  }
}

/// Example 4: Paginated List
/// Demonstrates using PaginatedNotifier for efficient list rendering
class Example4_PaginatedList extends ConsumerStatefulWidget {
  const Example4_PaginatedList({super.key});

  @override
  ConsumerState<Example4_PaginatedList> createState() =>
      _Example4_PaginatedListState();
}

class _Example4_PaginatedListState
    extends ConsumerState<Example4_PaginatedList> {
  // This would use the OptimizedJournalListNotifier from the actual implementation
  late final OptimizedJournalListNotifier _notifier;

  @override
  void initState() {
    super.initState();
    // Initialize notifier with pagination config
    // _notifier = OptimizedJournalListNotifier(repository);
  }

  @override
  Widget build(BuildContext context) {
    // final state = ref.watch(optimizedJournalListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paginated List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // ref.read(optimizedJournalListProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: /* state.isInitialLoading
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

                  return JournalEntryCard(entry: state.items[index]);
                },
              ),
            ), */
          const Center(
        child: Text('Use OptimizedJournalListProvider from app'),
      ),
    );
  }
}

/// Example 5: Query Caching
/// Demonstrates using QueryOptimizer for database query caching
class Example5_QueryCaching extends StatefulWidget {
  const Example5_QueryCaching({super.key});

  @override
  State<Example5_QueryCaching> createState() => _Example5_QueryCachingState();
}

class _Example5_QueryCachingState extends State<Example5_QueryCaching> {
  late final QueryOptimizer _optimizer;
  CacheStats? _stats;
  List<JournalEntry> _entries = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _optimizer = QueryOptimizer(
      cacheConfig: CacheConfig.forLists,
      enableLogging: true,
    );
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);

    // Simulate query with caching
    final result = await _optimizer.execute<List<JournalEntry>>(
      'example_entries',
      () async {
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 500));
        return []; // Return mock data
      },
      ttl: const Duration(minutes: 2),
      fields: QueryFields.forList,
    );

    if (result.isSuccess) {
      setState(() {
        _entries = result.data!;
        _isLoading = false;
      });

      // Show stats
      final stats = _optimizer.getStats();
      setState(() => _stats = stats);
    }
  }

  Future<void> _loadEntriesAgain() async {
    // This should be from cache (much faster)
    await _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Query Caching'),
      ),
      body: Column(
        children: [
          if (_stats != null)
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cache Stats:',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Total Queries: ${_stats!.totalRequests}'),
                    Text('Cache Hits: ${_stats!.totalHits}'),
                    Text('Cache Misses: ${_stats!.totalMisses}'),
                    Text(
                        'Hit Rate: ${(_stats!.hitRate * 100).toStringAsFixed(1)}%'),
                  ],
                ),
              ),
            ),
          ElevatedButton(
            onPressed: _loadEntriesAgain,
            child: const Text('Load Again (Should be cached)'),
          ),
          ElevatedButton(
            onPressed: () {
              _optimizer.clearCache();
              setState(() => _stats = null);
            },
            child: const Text('Clear Cache'),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Entry ${index + 1}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _optimizer.dispose();
    super.dispose();
  }
}

/// Example 6: Custom Pagination Configuration
/// Demonstrates custom pagination settings
class Example6_CustomPagination extends StatelessWidget {
  const Example6_CustomPagination({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Pagination')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Small Lists'),
            subtitle: Text('10 items per page, threshold 3'),
            trailing: Text('PaginationConfig.forSmallLists'),
          ),
          const ListTile(
            title: Text('Medium Lists'),
            subtitle: Text('20 items per page, threshold 5'),
            trailing: Text('PaginationConfig.forMediumLists'),
          ),
          const ListTile(
            title: Text('Large Lists'),
            subtitle: Text('50 items per page, threshold 10'),
            trailing: Text('PaginationConfig.forLargeLists'),
          ),
          const Divider(),
          const ListTile(
            title: Text('Custom Configuration'),
            subtitle: Text('Define your own page size and threshold'),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                const customConfig = PaginationConfig(
                  pageSize: 30,
                  enableAutoPagination: true,
                  threshold: 8,
                  initialPage: 1,
                );
                // Use customConfig in your notifier
              },
              child: const Text('Create Custom Config'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 7: Optimized Media Gallery
/// Demonstrates MediaGallery with automatic image caching
class Example7_OptimizedMediaGallery extends StatelessWidget {
  const Example7_OptimizedMediaGallery({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock media items
    final mediaItems = List.generate(
      12,
      (index) => MediaItem(
        id: 'media_$index',
        journalEntryId: 'entry_$index',
        storagePath: 'https://picsum.photos/400/400?random=$index',
        mediaType: index % 3 == 0 ? MediaType.video : MediaType.image,
        uploadStatus: UploadStatus.completed,
        orderIndex: index,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Optimized Media Gallery')),
      body: MediaGallery(
        mediaItems: mediaItems,
        config: MediaGalleryConfig.forTripOverview,
        onMediaTap: (media, index) {
          // Images are automatically cached by ImageCacheManager
          print('Tapped media ${media.id} at index $index');
        },
      ),
    );
  }
}

/// Example 8: Field Selection Optimization
/// Demonstrates using QueryFields for efficient data loading
class Example8_FieldSelection extends StatelessWidget {
  const Example8_FieldSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Field Selection')),
      body: ListView(
        children: [
          _buildFieldSection(
            'QueryFields.forList',
            QueryFields.forList.fields.toList(),
            'Minimal fields for list views',
          ),
          _buildFieldSection(
            'QueryFields.forDetail',
            QueryFields.forDetail.fields.toList(),
            'All fields for detail views',
          ),
          _buildFieldSection(
            'QueryFields.forCard',
            QueryFields.forCard.fields.toList(),
            'Card-specific fields',
          ),
          _buildFieldSection(
            'QueryFields.forMetadata',
            QueryFields.forMetadata.fields.toList(),
            'Metadata fields only',
          ),
        ],
      ),
    );
  }

  Widget _buildFieldSection(
      String title, List<String> fields, String description) {
    return ExpansionTile(
      title: Text(title),
      subtitle: Text(description),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fields (${fields.length}):',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...fields.map((field) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Text('• $field'),
                  )),
              const SizedBox(height: 16),
              Text('Supabase select:\n${fields.join(', ')}',
                  style:
                      const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Main menu for all examples
class PerformanceOptimizationExamplesMenu extends StatelessWidget {
  const PerformanceOptimizationExamplesMenu({super.key});

  static final List<Map<String, dynamic>> _examples = [
    {
      'title': 'Basic Image Caching',
      'description': 'Learn how to use ImageCacheManager',
      'widget': const Example1_BasicImageCaching(),
    },
    {
      'title': 'Image Preloading',
      'description': 'Preload images for smooth scrolling',
      'widget': const Example2_ImagePreloading(),
    },
    {
      'title': 'Cache Statistics',
      'description': 'Monitor cache performance',
      'widget': const Example3_CacheStatistics(),
    },
    {
      'title': 'Paginated List',
      'description': 'Efficient list rendering with pagination',
      'widget': const Example4_PaginatedList(),
    },
    {
      'title': 'Query Caching',
      'description': 'Cache database query results',
      'widget': const Example5_QueryCaching(),
    },
    {
      'title': 'Custom Pagination',
      'description': 'Configure pagination settings',
      'widget': const Example6_CustomPagination(),
    },
    {
      'title': 'Optimized Media Gallery',
      'description': 'MediaGallery with automatic caching',
      'widget': const Example7_OptimizedMediaGallery(),
    },
    {
      'title': 'Field Selection',
      'description': 'Optimize queries with field selection',
      'widget': const Example8_FieldSelection(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Optimization Examples'),
      ),
      body: ListView.builder(
        itemCount: _examples.length,
        itemBuilder: (context, index) {
          final example = _examples[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(example['title']),
              subtitle: Text(example['description']),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => example['widget'] as Widget,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Run all examples
void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        home: PerformanceOptimizationExamplesMenu(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
