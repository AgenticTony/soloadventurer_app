import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/services/thumbnail_service.dart';
import 'package:soloadventurer/features/travel/domain/models/photo.dart';

/// Example usage of the ThumbnailService.
///
/// This file demonstrates how to integrate the thumbnail service
/// into your application for optimal performance with large photo collections.
class ThumbnailServiceExamples {
  /// Example 1: Basic Thumbnail Generation
  ///
  /// Generate a thumbnail for a single photo and update the photo model.
  static Future<void> example1_BasicThumbnailGeneration() async {
    debugPrint('\n=== Example 1: Basic Thumbnail Generation ===\n');

    // Sample photo URL
    final photoUrl = 'https://example.com/photo.jpg';

    try {
      // Generate a medium-sized thumbnail (300x300)
      final thumbnailPath = await ThumbnailService.generateThumbnail(
        imageUrl: photoUrl,
        size: ThumbnailSize.medium,
      );

      debugPrint('Thumbnail generated: $thumbnailPath');

      // Update photo model with thumbnail URL
      final photo = Photo(
        id: '1',
        imageUrl: photoUrl,
        thumbnailUrl: thumbnailPath, // Use local thumbnail path
        tripId: 'trip-1',
        takenAt: DateTime.now(),
        width: 1920,
        height: 1080,
        sizeInBytes: 1024 * 1024, // 1 MB
        createdAt: DateTime.now(),
      );

      debugPrint('Photo thumbnail URL: ${photo.thumbnailUrl}');
      debugPrint('Photo display URL: ${photo.displayUrl}'); // Falls back to thumbnail
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
    }
  }

  /// Example 2: Batch Thumbnail Generation for Photo Gallery
  ///
  /// Efficiently generate thumbnails for multiple photos at once.
  static Future<void> example2_BatchThumbnailGeneration() async {
    debugPrint('\n=== Example 2: Batch Thumbnail Generation ===\n');

    // Simulate loading multiple photos from repository
    final photos = List.generate(
      20,
      (index) => Photo(
        id: 'photo-$index',
        imageUrl: 'https://example.com/photo-$index.jpg',
        tripId: 'trip-1',
        takenAt: DateTime.now(),
        width: 1920,
        height: 1080,
        sizeInBytes: 1024 * 1024,
        createdAt: DateTime.now(),
      ),
    );

    try {
      // Extract image URLs
      final imageUrls = photos.map((p) => p.imageUrl).toList();

      // Generate thumbnails in batch (faster than one-by-one)
      final thumbnails = await ThumbnailService.generateBatch(
        imageUrls: imageUrls,
        size: ThumbnailSize.medium,
      );

      debugPrint('Generated ${thumbnails.length} thumbnails');

      // Update all photos with their thumbnail URLs
      final updatedPhotos = photos.map((photo) {
        return photo.copyWith(
          thumbnailUrl: thumbnails[photo.imageUrl] ?? photo.imageUrl,
        );
      }).toList();

      debugPrint('Updated ${updatedPhotos.length} photos with thumbnails');
      debugPrint('First photo thumbnail: ${updatedPhotos.first.thumbnailUrl}');
    } catch (e) {
      debugPrint('Error generating batch thumbnails: $e');
    }
  }

  /// Example 3: Cache Management
  ///
  /// Monitor and manage the thumbnail cache.
  static Future<void> example3_CacheManagement() async {
    debugPrint('\n=== Example 3: Cache Management ===\n');

    try {
      // Get cache statistics
      final stats = await ThumbnailService.getCacheStats();

      debugPrint('Cache Statistics:');
      debugPrint('  - Total Size: ${stats.formattedSize}');
      debugPrint('  - Thumbnail Count: ${stats.count}');
      debugPrint('  - Average Size: ${stats.formattedAverageSize}');
      debugPrint('  - Initialized: ${stats.isInitialized}');

      // Clear cache if needed (e.g., on logout or low storage)
      if (stats.size > 50 * 1024 * 1024) {
        // Cache is larger than 50 MB
        debugPrint('Cache is large (${stats.formattedSize}), clearing...');

        await ThumbnailService.clearCache();

        final newStats = await ThumbnailService.getCacheStats();
        debugPrint('Cache cleared. New size: ${newStats.formattedSize}');
      }
    } catch (e) {
      debugPrint('Error managing cache: $e');
    }
  }

  /// Example 4: Check Thumbnail Existence
  ///
  /// Check if a thumbnail already exists before generating it.
  static Future<void> example4_CheckThumbnailExistence() async {
    debugPrint('\n=== Example 4: Check Thumbnail Existence ===\n');

    final photoUrl = 'https://example.com/photo.jpg';

    try {
      // Check if thumbnail exists
      final hasSmall = await ThumbnailService.hasThumbnail(
        photoUrl,
        size: ThumbnailSize.small,
      );

      final hasMedium = await ThumbnailService.hasThumbnail(
        photoUrl,
        size: ThumbnailSize.medium,
      );

      debugPrint('Small thumbnail exists: $hasSmall');
      debugPrint('Medium thumbnail exists: $hasMedium');

      // Only generate if it doesn't exist
      if (!hasMedium) {
        debugPrint('Generating medium thumbnail...');
        final path = await ThumbnailService.generateThumbnail(
          imageUrl: photoUrl,
          size: ThumbnailSize.medium,
        );
        debugPrint('Thumbnail generated: $path');
      } else {
        debugPrint('Using cached thumbnail');
        final path = await ThumbnailService.getThumbnailPath(
          photoUrl,
          size: ThumbnailSize.medium,
        );
        debugPrint('Cached thumbnail path: $path');
      }
    } catch (e) {
      debugPrint('Error checking thumbnail existence: $e');
    }
  }

  /// Example 5: Custom Thumbnail Dimensions
  ///
  /// Generate thumbnails with custom dimensions for specific use cases.
  static Future<void> example5_CustomThumbnailDimensions() async {
    debugPrint('\n=== Example 5: Custom Thumbnail Dimensions ===\n');

    final photoUrl = 'https://example.com/photo.jpg';

    try {
      // Generate a wide thumbnail for list items
      final wideThumbnail = await ThumbnailService.generateThumbnail(
        imageUrl: photoUrl,
        width: 200,
        height: 100,
      );

      debugPrint('Wide thumbnail (200x100): $wideThumbnail');

      // Generate a square thumbnail for avatars
      final squareThumbnail = await ThumbnailService.generateThumbnail(
        imageUrl: photoUrl,
        width: 80,
        height: 80,
      );

      debugPrint('Square thumbnail (80x80): $squareThumbnail');

      // Generate a large preview
      final largeThumbnail = await ThumbnailService.generateThumbnail(
        imageUrl: photoUrl,
        width: 800,
        height: 600,
      );

      debugPrint('Large thumbnail (800x600): $largeThumbnail');
    } catch (e) {
      debugPrint('Error generating custom thumbnails: $e');
    }
  }

  /// Example 6: Photo Gallery Integration
  ///
  /// Complete example of integrating thumbnail service with a photo gallery.
  static Future<List<Photo>> example6_PhotoGalleryIntegration(
    List<Photo> photos,
  ) async {
    debugPrint('\n=== Example 6: Photo Gallery Integration ===\n');

    try {
      debugPrint('Loading ${photos.length} photos...');

      // Step 1: Check which photos need thumbnails
      final photosNeedingThumbnails = <Photo>[];
      for (final photo in photos) {
        final hasThumbnail = await ThumbnailService.hasThumbnail(
          photo.imageUrl,
          size: ThumbnailSize.medium,
        );

        if (!hasThumbnail) {
          photosNeedingThumbnails.add(photo);
        }
      }

      debugPrint(
        '${photosNeedingThumbnails.length} photos need new thumbnails',
      );

      // Step 2: Generate thumbnails in batch for photos that need them
      if (photosNeedingThumbnails.isNotEmpty) {
        final imageUrls = photosNeedingThumbnails.map((p) => p.imageUrl).toList();

        final thumbnails = await ThumbnailService.generateBatch(
          imageUrls: imageUrls,
          size: ThumbnailSize.medium,
        );

        debugPrint('Generated ${thumbnails.length} new thumbnails');
      }

      // Step 3: Update all photos with thumbnail URLs
      final updatedPhotos = <Photo>[];
      for (final photo in photos) {
        final thumbnailPath = await ThumbnailService.getThumbnailPath(
          photo.imageUrl,
          size: ThumbnailSize.medium,
        );

        updatedPhotos.add(
          photo.copyWith(thumbnailUrl: thumbnailPath ?? photo.imageUrl),
        );
      }

      debugPrint('Updated ${updatedPhotos.length} photos with thumbnails');

      // Step 4: Log cache statistics
      final stats = await ThumbnailService.getCacheStats();
      debugPrint('Cache statistics:');
      debugPrint('  - Total size: ${stats.formattedSize}');
      debugPrint('  - Thumbnail count: ${stats.count}');

      return updatedPhotos;
    } catch (e) {
      debugPrint('Error integrating with photo gallery: $e');
      return photos; // Return original photos on error
    }
  }

  /// Example 7: Memory-Efficient Photo Loading
  ///
  /// Load photos with minimal memory footprint using thumbnails.
  static Future<void> example7_MemoryEfficientPhotoLoading() async {
    debugPrint('\n=== Example 7: Memory-Efficient Photo Loading ===\n');

    // Scenario: Loading 500 photos in a gallery

    final photoCount = 500;
    final avgOriginalSize = 1.0; // 1 MB per photo
    final avgThumbnailSize = 0.05; // 50 KB per thumbnail

    final originalMemory = photoCount * avgOriginalSize;
    final thumbnailMemory = photoCount * avgThumbnailSize;

    debugPrint('Memory Comparison for $photoCount photos:');
    debugPrint('  - Original images: ${originalMemory.toStringAsFixed(1)} MB');
    debugPrint('  - With thumbnails: ${thumbnailMemory.toStringAsFixed(1)} MB');
    debugPrint('  - Memory saved: ${(originalMemory - thumbnailMemory).toStringAsFixed(1)} MB');
    debugPrint('  - Reduction: ${((1 - thumbnailMemory / originalMemory) * 100).toStringAsFixed(1)}%');

    // With LazyLoadImage, only visible photos are loaded
    final visiblePhotos = 30; // Typical 3x10 grid on screen
    final actualMemory = visiblePhotos * avgThumbnailSize;

    debugPrint('\nWith LazyLoadImage (only visible photos loaded):');
    debugPrint('  - Visible photos: $visiblePhotos');
    debugPrint('  - Actual memory: ${actualMemory.toStringAsFixed(1)} MB');
    debugPrint('  - Total reduction: ${((1 - actualMemory / originalMemory) * 100).toStringAsFixed(1)}%');

    debugPrint('\n✅ This demonstrates why thumbnails + lazy loading is critical for large photo galleries!');
  }

  /// Example 8: Thumbnail Size Selection Guide
  ///
  /// Choose the right thumbnail size for different use cases.
  static Future<void> example8_ThumbnailSizeSelection() async {
    debugPrint('\n=== Example 8: Thumbnail Size Selection Guide ===\n');

    final photoUrl = 'https://example.com/photo.jpg';

    try {
      debugPrint('Generating different thumbnail sizes for comparison...\n');

      // Small (100x100) - Best for:
      // - List items
      // - Navigation tiles
      // - User avatars
      // - Quick previews
      final smallStart = DateTime.now();
      final smallPath = await ThumbnailService.generateThumbnail(
        imageUrl: photoUrl,
        size: ThumbnailSize.small,
      );
      final smallDuration = DateTime.now().difference(smallStart);

      debugPrint('Small Thumbnail (100x100):');
      debugPrint('  - Use case: List items, avatars, navigation');
      debugPrint('  - Generation time: ${smallDuration.inMilliseconds}ms');
      debugPrint('  - Path: $smallPath');

      // Medium (300x300) - Best for:
      // - Grid items
      // - Gallery thumbnails
      // - Card images
      // - Search results
      final mediumStart = DateTime.now();
      final mediumPath = await ThumbnailService.generateThumbnail(
        imageUrl: photoUrl,
        size: ThumbnailSize.medium,
      );
      final mediumDuration = DateTime.now().difference(mediumStart);

      debugPrint('\nMedium Thumbnail (300x300):');
      debugPrint('  - Use case: Photo galleries, grid layouts');
      debugPrint('  - Generation time: ${mediumDuration.inMilliseconds}ms');
      debugPrint('  - Path: $mediumPath');

      // Large (600x600) - Best for:
      // - Full-screen previews
      // - Detail views
      // - Lightbox thumbnails
      // - Image editors
      final largeStart = DateTime.now();
      final largePath = await ThumbnailService.generateThumbnail(
        imageUrl: photoUrl,
        size: ThumbnailSize.large,
      );
      final largeDuration = DateTime.now().difference(largeStart);

      debugPrint('\nLarge Thumbnail (600x600):');
      debugPrint('  - Use case: Previews, detail views, lightbox');
      debugPrint('  - Generation time: ${largeDuration.inMilliseconds}ms');
      debugPrint('  - Path: $largePath');

      debugPrint('\n💡 Tip: Use the smallest size that meets your needs for optimal performance!');
    } catch (e) {
      debugPrint('Error generating size comparison: $e');
    }
  }

  /// Run all examples.
  static Future<void> runAllExamples() async {
    debugPrint('\n========================================');
    debugPrint('ThumbnailService Examples');
    debugPrint('========================================');

    await example1_BasicThumbnailGeneration();
    await example2_BatchThumbnailGeneration();
    await example3_CacheManagement();
    await example4_CheckThumbnailExistence();
    await example5_CustomThumbnailDimensions();
    await example7_MemoryEfficientPhotoLoading();
    await example8_ThumbnailSizeSelection();

    debugPrint('\n========================================');
    debugPrint('Examples Complete!');
    debugPrint('========================================\n');
  }
}
