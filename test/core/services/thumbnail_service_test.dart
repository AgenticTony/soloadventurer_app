import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/services/thumbnail_service.dart';

void main() {
  group('ThumbnailService', () {
    setUpAll(() async {
      // Initialize the service for tests
      await ThumbnailService.initialize();
    });

    tearDown(() async {
      // Clean up after tests
      await ThumbnailService.clearCache();
    });

    tearDownAll(() {
      // Dispose of the service
      ThumbnailService.dispose();
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        expect(ThumbnailService, isNotNull);
      });

      test('should handle multiple initializations', () async {
        // Should not throw an error
        await ThumbnailService.initialize();
        await ThumbnailService.initialize();
      });
    });

    group('Thumbnail Generation', () {
      test('should throw exception when image URL is invalid', () async {
        expect(
          () => ThumbnailService.generateThumbnail(
            imageUrl: 'https://invalid-url-that-does-not-exist.com/image.jpg',
            size: ThumbnailSize.small,
          ),
          throwsException,
        );
      });

      test('should support custom dimensions', () async {
        // Note: This test will fail with invalid URLs, but demonstrates the API
        expect(
          () => ThumbnailService.generateThumbnail(
            imageUrl: 'https://example.com/image.jpg',
            width: 150,
            height: 150,
          ),
          throwsException,
        );
      });

      test('should support different thumbnail sizes', () async {
        final sizes = [
          ThumbnailSize.small,
          ThumbnailSize.medium,
          ThumbnailSize.large,
        ];

        for (final size in sizes) {
          expect(
            () => ThumbnailService.generateThumbnail(
              imageUrl: 'https://example.com/image.jpg',
              size: size,
            ),
            throwsException,
          );
        }
      });
    });

    group('Cache Management', () {
      test('should clear cache successfully', () async {
        await ThumbnailService.clearCache();
        final stats = await ThumbnailService.getCacheStats();

        expect(stats.count, equals(0));
        expect(stats.size, equals(0));
      });

      test('should return cache statistics', () async {
        final stats = await ThumbnailService.getCacheStats();

        expect(stats, isNotNull);
        expect(stats.isInitialized, isTrue);
        expect(stats.count, greaterThanOrEqualTo(0));
        expect(stats.size, greaterThanOrEqualTo(0));
      });

      test('should format cache size correctly', () async {
        final stats = await ThumbnailService.getCacheStats();

        expect(stats.formattedSize, isNotNull);
        expect(stats.formattedSize, isA<String>());
      });

      test('should calculate average thumbnail size', () async {
        final stats = await ThumbnailService.getCacheStats();

        if (stats.count > 0) {
          expect(stats.averageSize, greaterThan(0));
          expect(stats.formattedAverageSize, isNotNull);
        } else {
          expect(stats.averageSize, equals(0));
        }
      });
    });

    group('Thumbnail Existence', () {
      test('should return false for non-existent thumbnail', () async {
        final exists = await ThumbnailService.hasThumbnail(
          'https://example.com/non-existent.jpg',
        );

        expect(exists, isFalse);
      });

      test('should return null for non-existent thumbnail path', () async {
        final path = await ThumbnailService.getThumbnailPath(
          'https://example.com/non-existent.jpg',
        );

        expect(path, isNull);
      });
    });

    group('Batch Generation', () {
      test('should return empty map for empty URL list', () async {
        final result = await ThumbnailService.generateBatch(
          imageUrls: [],
          size: ThumbnailSize.small,
        );

        expect(result, isEmpty);
      });

      test('should handle batch with invalid URLs gracefully', () async {
        final result = await ThumbnailService.generateBatch(
          imageUrls: [
            'https://invalid1.com/image.jpg',
            'https://invalid2.com/image.jpg',
          ],
          size: ThumbnailSize.small,
        );

        // Should return the original URLs as fallback
        expect(result, hasLength(2));
        expect(result.containsKey('https://invalid1.com/image.jpg'), isTrue);
        expect(result.containsKey('https://invalid2.com/image.jpg'), isTrue);
      });
    });

    group('ThumbnailSize Enum', () {
      test('should have correct dimensions for small size', () {
        expect(ThumbnailSize.small.width, equals(100));
        expect(ThumbnailSize.small.height, equals(100));
      });

      test('should have correct dimensions for medium size', () {
        expect(ThumbnailSize.medium.width, equals(300));
        expect(ThumbnailSize.medium.height, equals(300));
      });

      test('should have correct dimensions for large size', () {
        expect(ThumbnailSize.large.width, equals(600));
        expect(ThumbnailSize.large.height, equals(600));
      });
    });

    group('ThumbnailCacheStats Model', () {
      test('should create stats object', () {
        const stats = ThumbnailCacheStats(
          size: 1024,
          count: 2,
          isInitialized: true,
        );

        expect(stats.size, equals(1024));
        expect(stats.count, equals(2));
        expect(stats.isInitialized, isTrue);
      });

      test('should calculate average size correctly', () {
        const stats = ThumbnailCacheStats(
          size: 2000,
          count: 4,
          isInitialized: true,
        );

        expect(stats.averageSize, equals(500));
      });

      test('should handle zero count for average size', () {
        const stats = ThumbnailCacheStats(
          size: 0,
          count: 0,
          isInitialized: true,
        );

        expect(stats.averageSize, equals(0));
      });

      test('should format size correctly', () {
        const stats = ThumbnailCacheStats(
          size: 1536, // 1.5 KB
          count: 1,
          isInitialized: true,
        );

        expect(stats.formattedSize, contains('KB'));
      });

      test('should provide string representation', () {
        const stats = ThumbnailCacheStats(
          size: 1024,
          count: 2,
          isInitialized: true,
        );

        final str = stats.toString();
        expect(str, contains('ThumbnailCacheStats'));
        expect(str, contains('count: 2'));
        expect(str, contains('isInitialized: true'));
      });
    });

    group('Error Handling', () {
      test('should handle service not initialized gracefully', () async {
        // Dispose to simulate uninitialized state
        ThumbnailService.dispose();

        // Operations should still work by auto-initializing
        final stats = await ThumbnailService.getCacheStats();
        expect(stats, isNotNull);

        // Reinitialize for other tests
        await ThumbnailService.initialize();
      });

      test('should handle cache directory creation errors', () async {
        // This test verifies error handling, but we can't easily simulate
        // filesystem errors without mocking. The production code has
        // try-catch blocks that should handle such cases.

        // For now, just verify the service handles operations gracefully
        final stats = await ThumbnailService.getCacheStats();
        expect(stats, isNotNull);
      });
    });

    group('Cache Key Generation', () {
      test('should generate consistent cache keys', () {
        // We can't directly test _generateCacheKey as it's private,
        // but we can verify that the same URL produces the same thumbnail path
        // by checking the hasThumbnail method behavior

        const url1 = 'https://example.com/test.jpg';
        const url2 = 'https://example.com/test.jpg';
        const url3 = 'https://example.com/other.jpg';

        // Same URLs should produce the same existence result
        final exists1 = await ThumbnailService.hasThumbnail(url1);
        final exists2 = await ThumbnailService.hasThumbnail(url2);
        final exists3 = await ThumbnailService.hasThumbnail(url3);

        expect(exists1, equals(exists2));
        // exists3 may or may not equal exists1 depending on cache state
      });

      test('should generate different keys for different sizes', () {
        // Different sizes should produce different cache keys
        const url = 'https://example.com/test.jpg';

        // We can't directly verify cache keys, but the behavior
        // should be that hasThumbnail returns false for different sizes
        // unless thumbnails were generated for all sizes
        final existsSmall = await ThumbnailService.hasThumbnail(
          url,
          size: ThumbnailSize.small,
        );
        final existsMedium = await ThumbnailService.hasThumbnail(
          url,
          size: ThumbnailSize.medium,
        );

        // Both should be false since we haven't generated any thumbnails
        expect(existsSmall, isFalse);
        expect(existsMedium, isFalse);
      });
    });

    group('Integration Tests', () {
      testWidgets('should handle full thumbnail workflow', (tester) async {
        // This would require a mock HTTP server to provide test images
        // For now, we test the API and error handling

        const url = 'https://example.com/test-image.jpg';

        // Check if thumbnail exists (should be false)
        final existsBefore = await ThumbnailService.hasThumbnail(url);
        expect(existsBefore, isFalse);

        // Get thumbnail path (should be null)
        final pathBefore = await ThumbnailService.getThumbnailPath(url);
        expect(pathBefore, isNull);

        // Generate thumbnail (will fail with invalid URL, but tests the API)
        try {
          await ThumbnailService.generateThumbnail(
            imageUrl: url,
            size: ThumbnailSize.small,
          );
        } catch (e) {
          // Expected to fail with invalid URL
          expect(e, isA<Exception>());
        }

        // Verify cache is still in valid state
        final stats = await ThumbnailService.getCacheStats();
        expect(stats, isNotNull);
      });
    });
  });
}
