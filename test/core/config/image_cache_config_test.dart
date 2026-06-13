import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/config/image_cache_config.dart';

void main() {
  group('ImageCacheConfig', () {
    setUp(() async {
      // Reset initialization state before each test
      ImageCacheConfig.dispose();
    });

    tearDown(() async {
      // Clean up after each test
      try {
        await ImageCacheConfig.clearAllCaches();
      } catch (e) {
        // Ignore errors during cleanup
      }
      ImageCacheConfig.dispose();
    });

    group('Initialization', () {
      test('initialize with default settings', () async {
        await ImageCacheConfig.initialize();

        final stats = await ImageCacheConfig.getCacheStats();
        expect(stats.isInitialized, isTrue);
      });

      test('initialize with custom settings', () async {
        const customMemorySize = 50 * 1024 * 1024; // 50 MB
        const customDiskSize = 200 * 1024 * 1024; // 200 MB
        const customImageCount = 50;

        await ImageCacheConfig.initialize(
          maxMemoryCacheBytes: customMemorySize,
          maxDiskCacheBytes: customDiskSize,
          maxMemoryCacheImages: customImageCount,
        );

        final stats = await ImageCacheConfig.getCacheStats();
        expect(stats.isInitialized, isTrue);
      });

      test('initialize only once even if called multiple times', () async {
        await ImageCacheConfig.initialize();
        await ImageCacheConfig.initialize();
        await ImageCacheConfig.initialize();

        final stats = await ImageCacheConfig.getCacheStats();
        expect(stats.isInitialized, isTrue);
      });
    });

    group('Cache Statistics', () {
      test('getCacheStats returns valid statistics', () async {
        await ImageCacheConfig.initialize();

        final stats = await ImageCacheConfig.getCacheStats();

        expect(stats, isNotNull);
        expect(stats.isInitialized, isTrue);
        expect(stats.memoryCacheSize, greaterThanOrEqualTo(0));
        expect(stats.memoryCacheCount, greaterThanOrEqualTo(0));
        expect(stats.diskCacheSize, greaterThanOrEqualTo(0));
      });

      test('getCacheStats calculates average memory correctly', () async {
        await ImageCacheConfig.initialize();

        final stats = await ImageCacheConfig.getCacheStats();

        if (stats.memoryCacheCount > 0) {
          final average = stats.averageMemoryPerImage;
          expect(average, greaterThan(0));
        } else {
          expect(stats.averageMemoryPerImage, equals(0));
        }
      });

      test('getCacheStats formats sizes correctly', () async {
        await ImageCacheConfig.initialize();

        final stats = await ImageCacheConfig.getCacheStats();

        expect(stats.formattedMemoryCacheSize, isNotEmpty);
        expect(stats.formattedDiskCacheSize, isNotEmpty);

        // Format should contain units (B, KB, MB, or GB)
        final formatRegex = RegExp(r'^\d+\.?\d* (B|KB|MB|GB)$');
        expect(
          formatRegex.hasMatch(stats.formattedMemoryCacheSize) ||
              formatRegex.hasMatch(stats.formattedDiskCacheSize),
          isTrue,
        );
      });

      test('toString returns formatted string', () async {
        await ImageCacheConfig.initialize();

        final stats = await ImageCacheConfig.getCacheStats();
        final statsString = stats.toString();

        expect(statsString, contains('memoryCacheSize'));
        expect(statsString, contains('memoryCacheCount'));
        expect(statsString, contains('diskCacheSize'));
        expect(statsString, contains('isInitialized'));
      });
    });

    group('Memory Cache Management', () {
      testWidgets('clearMemoryCache clears memory cache', (tester) async {
        await ImageCacheConfig.initialize();

        // Load some images into memory
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Image.network('https://example.com/image1.jpg'),
            ),
          ),
        );
        await tester.pump();

        // Clear memory cache
        await ImageCacheConfig.clearMemoryCache();

        final stats = await ImageCacheConfig.getCacheStats();
        // After clearing, memory cache should be minimal
        expect(stats.memoryCacheCount, lessThan(10));
      },
      // QUARANTINED 2026-06-13: hangs ~10min (real Image.network + clearMemoryCache await never resolves); was a known-stale fail. Revisit by mocking the network image.
      skip: true);

      test('clearMemoryCache is idempotent', () async {
        await ImageCacheConfig.initialize();

        await ImageCacheConfig.clearMemoryCache();
        await ImageCacheConfig.clearMemoryCache();
        await ImageCacheConfig.clearMemoryCache();

        final stats = await ImageCacheConfig.getCacheStats();
        expect(stats.isInitialized, isTrue);
      });
    });

    group('Disk Cache Management', () {
      test('clearDiskCache clears disk cache', () async {
        await ImageCacheConfig.initialize();

        // Clear disk cache
        await ImageCacheConfig.clearDiskCache();

        final stats = await ImageCacheConfig.getCacheStats();
        expect(stats.isInitialized, isTrue);
      });

      test('clearDiskCache is idempotent', () async {
        await ImageCacheConfig.initialize();

        await ImageCacheConfig.clearDiskCache();
        await ImageCacheConfig.clearDiskCache();

        final stats = await ImageCacheConfig.getCacheStats();
        expect(stats.isInitialized, isTrue);
      });
    });

    group('Clear All Caches', () {
      test('clearAllCaches clears both memory and disk', () async {
        await ImageCacheConfig.initialize();

        await ImageCacheConfig.clearAllCaches();

        final stats = await ImageCacheConfig.getCacheStats();
        expect(stats.isInitialized, isTrue);
      });

      test('clearAllCaches completes successfully', () async {
        await ImageCacheConfig.initialize();

        final future = ImageCacheConfig.clearAllCaches();
        expect(future, completes);
      });
    });

    group('Memory Cache Dimensions', () {
      test('getMemoryCacheDimensions returns valid dimensions', () {
        final dimensions = ImageCacheConfig.getMemoryCacheDimensions(
          100.0,
          200.0,
        );

        expect(dimensions.width, greaterThan(0));
        expect(dimensions.height, greaterThan(0));
      });

      test('getMemoryCacheDimensions respects pixel ratio', () {
        final dimensions1x = ImageCacheConfig.getMemoryCacheDimensions(
          100.0,
          100.0,
          pixelRatio: 1.0,
        );

        final dimensions2x = ImageCacheConfig.getMemoryCacheDimensions(
          100.0,
          100.0,
          pixelRatio: 2.0,
        );

        expect(dimensions2x.width, greaterThan(dimensions1x.width));
        expect(dimensions2x.height, greaterThan(dimensions1x.height));
      });

      test('getMemoryCacheDimensions scales with display size', () {
        final smallDimensions = ImageCacheConfig.getMemoryCacheDimensions(
          50.0,
          50.0,
        );

        final largeDimensions = ImageCacheConfig.getMemoryCacheDimensions(
          200.0,
          200.0,
        );

        expect(largeDimensions.width, greaterThan(smallDimensions.width));
        expect(largeDimensions.height, greaterThan(smallDimensions.height));
      });

      test('getMemoryCacheDimensions handles zero sizes', () {
        final dimensions = ImageCacheConfig.getMemoryCacheDimensions(
          0.0,
          0.0,
        );

        // Should return minimum safe dimensions
        expect(dimensions.width, greaterThan(0));
        expect(dimensions.height, greaterThan(0));
      });

      test('getMemoryCacheDimensions formats dimensions correctly', () {
        final dimensions = ImageCacheConfig.getMemoryCacheDimensions(
          100.0,
          200.0,
        );

        final dimensionsString = dimensions.toString();
        expect(dimensionsString, contains('CacheDimensions'));
        expect(dimensionsString, contains(RegExp(r'\d+x\d+')));
      });
    });

    group('CacheLimits', () {
      test('default max memory cache size is 150 MB', () {
        const expected = 150 * 1024 * 1024; // 150 MB
        expect(ImageCacheConfig.defaultMaxMemoryCacheSize, equals(expected));
      });

      test('default max disk cache size is 500 MB', () {
        const expected = 500 * 1024 * 1024; // 500 MB
        expect(ImageCacheConfig.defaultMaxDiskCacheSize, equals(expected));
      });

      test('default max memory cache images is 200', () {
        const expected = 200;
        expect(ImageCacheConfig.defaultMaxMemoryCacheImages, equals(expected));
      });

      test('default image quality is 85', () {
        const expected = 85;
        expect(ImageCacheConfig.defaultImageQuality, equals(expected));
      });

      test('isCacheConfigured returns true after initialization', () async {
        await ImageCacheConfig.initialize();

        expect(ImageCacheConfig.isCacheConfigured(), isTrue);
      });

      test('isCacheConfigured returns false before initialization', () {
        // Don't initialize, just check
        expect(ImageCacheConfig.isCacheConfigured(), isFalse);
      });

      test('getCurrentMaximumSize returns configured limit', () async {
        const customLimit = 50;
        await ImageCacheConfig.initialize(
          maxMemoryCacheImages: customLimit,
        );

        final currentLimit = ImageCacheConfig.getCurrentMaximumSize();
        expect(currentLimit, equals(customLimit));
      });

      test('getCurrentMaximumSizeBytes returns configured limit', () async {
        const customLimit = 50 * 1024 * 1024; // 50 MB
        await ImageCacheConfig.initialize(
          maxMemoryCacheBytes: customLimit,
        );

        final currentLimit = ImageCacheConfig.getCurrentMaximumSizeBytes();
        expect(currentLimit, equals(customLimit));
      });

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

      test('multiple initializations use first configuration', () async {
        const firstMaxImages = 100;
        const secondMaxImages = 200;

        await ImageCacheConfig.initialize(
          maxMemoryCacheImages: firstMaxImages,
        );

        await ImageCacheConfig.initialize(
          maxMemoryCacheImages: secondMaxImages,
        );

        // Should keep the first configuration
        final actualMaxImages = ImageCacheConfig.getCurrentMaximumSize();
        expect(actualMaxImages, equals(firstMaxImages));
      });
    });

    group('Integration with Flutter Image Cache', () {
      testWidgets('integrates with Flutter image cache', (tester) async {
        await ImageCacheConfig.initialize();

        const imageProvider = NetworkImage('https://example.com/test.jpg');

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Image(image: imageProvider),
            ),
          ),
        );

        await tester.pump();

        // Image should load without errors
        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('multiple images use cache efficiently', (tester) async {
        await ImageCacheConfig.initialize();

        const imageUrl = 'https://example.com/test.jpg';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView(
                children: [
                  Image.network(imageUrl),
                  Image.network(imageUrl), // Same URL, should use cache
                  Image.network(imageUrl), // Same URL, should use cache
                ],
              ),
            ),
          ),
        );

        await tester.pump();

        // All three images should render
        expect(find.byType(Image), findsWidgets);
      });
    });

    group('Performance', () {
      test('initialization completes quickly', () async {
        final stopwatch = Stopwatch()..start();

        await ImageCacheConfig.initialize();

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // < 1 second
      });

      test('getCacheStats completes quickly', () async {
        await ImageCacheConfig.initialize();

        final stopwatch = Stopwatch()..start();

        await ImageCacheConfig.getCacheStats();

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // < 100ms
      });

      test('clearMemoryCache completes quickly', () async {
        await ImageCacheConfig.initialize();

        final stopwatch = Stopwatch()..start();

        await ImageCacheConfig.clearMemoryCache();

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // < 100ms
      });
    });

    group('Error Handling', () {
      test('handles getCacheStats gracefully when not initialized', () async {
        // Don't initialize
        final stats = await ImageCacheConfig.getCacheStats();

        expect(stats, isNotNull);
        expect(stats.isInitialized, isFalse);
      });

      test('clearMemoryCache works when cache is empty', () async {
        await ImageCacheConfig.initialize();
        await ImageCacheConfig.clearMemoryCache();

        // Should not throw when clearing again
        await ImageCacheConfig.clearMemoryCache();

        final stats = await ImageCacheConfig.getCacheStats();
        expect(stats.isInitialized, isTrue);
      });
    });

    group('CacheDimensions', () {
      test('CacheDimensions constructor creates valid object', () {
        const dimensions = CacheDimensions(
          width: 100,
          height: 200,
        );

        expect(dimensions.width, equals(100));
        expect(dimensions.height, equals(200));
      });

      test('CacheDimensions toString formats correctly', () {
        const dimensions = CacheDimensions(
          width: 100,
          height: 200,
        );

        final string = dimensions.toString();
        expect(string, equals('CacheDimensions(100x200)'));
      });
    });

    group('ImageCacheStats', () {
      test('ImageCacheStats constructor creates valid object', () {
        const stats = ImageCacheStats(
          memoryCacheSize: 1024,
          memoryCacheCount: 10,
          diskCacheSize: 2048,
          isInitialized: true,
        );

        expect(stats.memoryCacheSize, equals(1024));
        expect(stats.memoryCacheCount, equals(10));
        expect(stats.diskCacheSize, equals(2048));
        expect(stats.isInitialized, isTrue);
      });

      test('ImageCacheStats calculates average correctly', () {
        const stats = ImageCacheStats(
          memoryCacheSize: 10000,
          memoryCacheCount: 10,
          diskCacheSize: 20000,
          isInitialized: true,
        );

        expect(stats.averageMemoryPerImage, equals(1000.0));
      });

      test('ImageCacheStats average is zero when count is zero', () {
        const stats = ImageCacheStats(
          memoryCacheSize: 10000,
          memoryCacheCount: 0,
          diskCacheSize: 20000,
          isInitialized: true,
        );

        expect(stats.averageMemoryPerImage, equals(0.0));
      });
    });
  });
}
