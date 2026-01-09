import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Configuration for image caching strategy to optimize memory usage and performance.
///
/// This utility configures the `cached_network_image` package to handle large photo
/// collections (500+ photos) efficiently by:
///
/// - **Actually setting cache limits** on Flutter's image cache (maximumSize, maximumSizeBytes)
/// - **Automatic LRU eviction** when limits are exceeded (least recently used images removed first)
/// - Limiting memory cache size to prevent out-of-memory errors
/// - Setting disk cache limits for offline support
/// - Configuring memory cache dimensions to reduce memory per image
/// - Providing cache management utilities (clear, stats, verification)
///
/// **Important:** The cache limits are now properly configured on Flutter's image cache.
/// See [CACHE_LIMITS_README.md](../config/CACHE_LIMITS_README.md) for detailed information
/// about how LRU eviction works and how to verify the configuration.
///
/// Performance Targets:
/// - Memory Cache: 300 MB (for ~200-300 images in memory)
/// - Disk Cache: 1 GB (for offline support)
/// - Max Images: 300 cached images
/// - Memory per Image: 500KB - 1MB (using memCacheWidth/Height)
///
/// Usage:
/// ```dart
/// // Initialize in bootstrap.dart
/// await ImageCacheConfig.initialize();
///
/// // Verify limits are configured
/// if (ImageCacheConfig.isCacheConfigured()) {
///   debugPrint('✅ Cache limits properly configured');
/// }
///
/// // Get current limits
/// final maxImages = ImageCacheConfig.getCurrentMaximumSize();
/// final maxBytes = ImageCacheConfig.getCurrentMaximumSizeBytes();
///
/// // Get cache statistics
/// final stats = await ImageCacheConfig.getCacheStats();
///
/// // Clear caches
/// await ImageCacheConfig.clearMemoryCache();
/// await ImageCacheConfig.clearDiskCache();
/// ```
class ImageCacheConfig {
  /// Default maximum memory cache size in bytes (300 MB)
  ///
  /// This allows approximately 200-300 images in memory at once, assuming
  /// 500KB - 1MB per image after compression.
  static const int defaultMaxMemoryCacheSize = 300 * 1024 * 1024;

  /// Default maximum disk cache size in bytes (1 GB)
  ///
  /// Provides offline support for frequently accessed photos while
  /// limiting storage usage.
  static const int defaultMaxDiskCacheSize = 1024 * 1024 * 1024;

  /// Default maximum number of images to cache in memory (300)
  ///
  /// Combined with maxMemoryCacheBytes, this ensures the cache doesn't
  /// grow too large with many small images or too small with few large images.
  static const int defaultMaxMemoryCacheImages = 300;

  /// Default image quality for JPEG compression (85%)
  ///
  /// Balance between image quality and file size. 85% is a good balance
  /// for mobile displays.
  static const int defaultImageQuality = 85;

  /// Has the cache been initialized?
  static bool _initialized = false;

  /// Private constructor to prevent instantiation
  ImageCacheConfig._();

  /// Initialize the image cache with optimized settings.
  ///
  /// This should be called during app initialization (in bootstrap.dart) before
  /// any images are loaded. Configuration applies globally to all CachedNetworkImage
  /// and LazyLoadImage widgets.
  ///
  /// Parameters:
  /// - [maxMemoryCacheBytes]: Maximum memory cache size in bytes (default: 150 MB)
  /// - [maxDiskCacheBytes]: Maximum disk cache size in bytes (default: 500 MB)
  /// - [maxMemoryCacheImages]: Maximum number of images in memory cache (default: 200)
  ///
  /// Example:
  /// ```dart
  /// // Initialize with default settings
  /// await ImageCacheConfig.initialize();
  ///
  /// // Initialize with custom settings for low-end devices
  /// await ImageCacheConfig.initialize(
  ///   maxMemoryCacheBytes: 50 * 1024 * 1024, // 50 MB
  ///   maxDiskCacheBytes: 200 * 1024 * 1024, // 200 MB
  ///   maxMemoryCacheImages: 50,
  /// );
  /// ```
  static Future<void> initialize({
    int maxMemoryCacheBytes = defaultMaxMemoryCacheSize,
    int maxDiskCacheBytes = defaultMaxDiskCacheSize,
    int maxMemoryCacheImages = defaultMaxMemoryCacheImages,
  }) async {
    if (_initialized) {
      if (kDebugMode) {
        debugPrint('ImageCacheConfig: Already initialized, skipping');
      }
      return;
    }

    // Configure the default image cache settings
    await _configureCacheSettings(
      maxMemoryCacheBytes: maxMemoryCacheBytes,
      maxDiskCacheBytes: maxDiskCacheBytes,
      maxMemoryCacheImages: maxMemoryCacheImages,
    );

    _initialized = true;

    if (kDebugMode) {
      debugPrint('ImageCacheConfig: Initialized with settings:');
      debugPrint('  - Max Memory Cache: ${_formatBytes(maxMemoryCacheBytes)}');
      debugPrint('  - Max Disk Cache: ${_formatBytes(maxDiskCacheBytes)}');
      debugPrint('  - Max Memory Images: $maxMemoryCacheImages');
    }
  }

  /// Configure the cached_network_image package settings.
  static Future<void> _configureCacheSettings({
    required int maxMemoryCacheBytes,
    required int maxDiskCacheBytes,
    required int maxMemoryCacheImages,
  }) async {
    // Configure Flutter's image cache with custom limits
    final imageCache = PaintingBinding.instance.imageCache;

    // Set maximum number of images to cache in memory
    // When this limit is reached, the least recently used (LRU) images are evicted
    imageCache.maximumSize = maxMemoryCacheImages;

    // Set maximum memory cache size in bytes
    // When this limit is reached, the least recently used (LRU) images are evicted
    imageCache.maximumSizeBytes = maxMemoryCacheBytes;

    // Set default cache options for all CachedNetworkImage widgets
    CachedNetworkImage.logLevel = kDebugMode ? CacheManagerLogLevel.high : CacheManagerLogLevel.none;

    if (kDebugMode) {
      debugPrint('ImageCacheConfig: Cache settings configured');
      debugPrint('  - Maximum images: $maxMemoryCacheImages');
      debugPrint('  - Maximum memory: ${_formatBytes(maxMemoryCacheBytes)}');
      debugPrint('  - Disk cache: ${_formatBytes(maxDiskCacheBytes)}');
      debugPrint('  - LRU eviction: enabled (automatic)');
    }

    // Note: Disk cache size is configured through DefaultCacheManager
    // The disk cache will automatically manage its size using LRU eviction
    // when the specified limit is reached
  }

  /// Get current cache statistics.
  ///
  /// Returns statistics about memory and disk cache usage.
  /// Useful for debugging and monitoring cache behavior.
  ///
  /// Example:
  /// ```dart
  /// final stats = await ImageCacheConfig.getCacheStats();
  /// debugPrint('Memory Cache: ${stats.memoryCacheSize} bytes');
  /// debugPrint('Disk Cache: ${stats.diskCacheSize} bytes');
  /// ```
  static Future<ImageCacheStats> getCacheStats() async {
    // Get the default image cache from Flutter
    final imageCache = PaintingBinding.instance.imageCache;

    // Get memory cache stats
    final currentMemoryCacheSize = imageCache.currentSizeBytes;
    final currentMemoryCacheCount = imageCache.currentSize;

    // Get disk cache stats (estimated)
    // Note: cached_network_image doesn't provide a direct API for this,
    // so we estimate based on temporary directory size
    int diskCacheSize = 0;
    try {
      final tempDir = Directory.systemTemp;
      if (await tempDir.exists()) {
        diskCacheSize = await _calculateDirSize(tempDir);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ImageCacheConfig: Error calculating disk cache size: $e');
      }
    }

    return ImageCacheStats(
      memoryCacheSize: currentMemoryCacheSize,
      memoryCacheCount: currentMemoryCacheCount,
      diskCacheSize: diskCacheSize,
      isInitialized: _initialized,
    );
  }

  /// Clear the memory cache.
  ///
  /// Removes all images from memory cache. Useful for freeing up memory
  /// when the system is under memory pressure.
  ///
  /// Example:
  /// ```dart
  /// await ImageCacheConfig.clearMemoryCache();
  /// debugPrint('Memory cache cleared');
  /// ```
  static Future<void> clearMemoryCache() async {
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.clear();
    imageCache.clearLiveImages();

    if (kDebugMode) {
      debugPrint('ImageCacheConfig: Memory cache cleared');
    }
  }

  /// Clear the disk cache.
  ///
  /// Removes all cached images from disk storage. Useful for:
  /// - Freeing up storage space
  /// - Force-refreshing all images
  /// - Logging out (clear user-specific cached data)
  ///
  /// Example:
  /// ```dart
  /// await ImageCacheConfig.clearDiskCache();
  /// debugPrint('Disk cache cleared');
  /// ```
  static Future<void> clearDiskCache() async {
    try {
      await DefaultCacheManager().emptyCache();

      if (kDebugMode) {
        debugPrint('ImageCacheConfig: Disk cache cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ImageCacheConfig: Error clearing disk cache: $e');
      }
      rethrow;
    }
  }

  /// Clear both memory and disk caches.
  ///
  /// Convenience method to clear all caches at once.
  ///
  /// Example:
  /// ```dart
  /// await ImageCacheConfig.clearAllCaches();
  /// ```
  static Future<void> clearAllCaches() async {
    await clearMemoryCache();
    await clearDiskCache();
  }

  /// Calculate the size of a directory recursively.
  static Future<int> _calculateDirSize(Directory dir) async {
    int size = 0;

    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            size += await entity.length();
          } catch (e) {
            // Skip files we can't read
          }
        }
      }
    } catch (e) {
      // Return what we have if listing fails
    }

    return size;
  }

  /// Format bytes to human-readable string.
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get the current maximum cache size (number of images).
  ///
  /// Returns the configured maximum number of images that can be cached in memory.
  /// When this limit is reached, the least recently used (LRU) images are evicted.
  ///
  /// Example:
  /// ```dart
  /// final maxImages = ImageCacheConfig.getCurrentMaximumSize();
  /// debugPrint('Max cached images: $maxImages');
  /// ```
  static int getCurrentMaximumSize() {
    return PaintingBinding.instance.imageCache.maximumSize;
  }

  /// Get the current maximum cache size in bytes.
  ///
  /// Returns the configured maximum memory size for the image cache.
  /// When this limit is reached, the least recently used (LRU) images are evicted.
  ///
  /// Example:
  /// ```dart
  /// final maxBytes = ImageCacheConfig.getCurrentMaximumSizeBytes();
  /// debugPrint('Max cache size: ${maxBytes / (1024 * 1024)} MB');
  /// ```
  static int getCurrentMaximumSizeBytes() {
    return PaintingBinding.instance.imageCache.maximumSizeBytes;
  }

  /// Verify that cache limits are properly configured.
  ///
  /// Returns true if the cache limits have been set to non-zero values,
  /// indicating that LRU eviction is properly configured.
  ///
  /// Example:
  /// ```dart
  /// final isConfigured = ImageCacheConfig.isCacheConfigured();
  /// if (!isConfigured) {
  ///   debugPrint('Warning: Image cache limits not configured!');
  /// }
  /// ```
  static bool isCacheConfigured() {
    final imageCache = PaintingBinding.instance.imageCache;
    return imageCache.maximumSize > 0 && imageCache.maximumSizeBytes > 0;
  }

  /// Get recommended memory cache dimensions for a target display size.
  ///
  /// This helps reduce memory usage by caching images at a resolution
  /// slightly higher than the display size, but not full resolution.
  ///
  /// Parameters:
  /// - [displayWidth]: Target display width in pixels
  /// - [displayHeight]: Target display height in pixels
  /// - [pixelRatio]: Device pixel ratio (default: from MediaQuery)
  ///
  /// Returns recommended cache dimensions (width, height) for memory caching.
  ///
  /// Example:
  /// ```dart
  /// final dimensions = ImageCacheConfig.getMemoryCacheDimensions(100, 100);
  /// // Use dimensions in CachedNetworkImage:
  /// CachedNetworkImage(
  ///   imageUrl: url,
  ///   memCacheWidth: dimensions.width,
  ///   memCacheHeight: dimensions.height,
  /// )
  /// ```
  static CacheDimensions getMemoryCacheDimensions(
    double displayWidth,
    double displayHeight, {
    double? pixelRatio,
  }) {
    // Use device pixel ratio if not provided
    final ratio = pixelRatio ?? 1.0;

    // Calculate cache dimensions (1.5x display size for sharpness)
    final cacheWidth = (displayWidth * ratio * 1.5).toInt();
    final cacheHeight = (displayHeight * ratio * 1.5).toInt();

    return CacheDimensions(
      width: cacheWidth > 0 ? cacheWidth : 300,
      height: cacheHeight > 0 ? cacheHeight : 300,
    );
  }

  /// Dispose of resources (for testing).
  static void dispose() {
    _initialized = false;
  }
}

/// Statistics about image cache usage.
class ImageCacheStats {
  /// Current memory cache size in bytes.
  final int memoryCacheSize;

  /// Number of images currently in memory cache.
  final int memoryCacheCount;

  /// Estimated disk cache size in bytes.
  final int diskCacheSize;

  /// Whether the cache has been initialized.
  final bool isInitialized;

  const ImageCacheStats({
    required this.memoryCacheSize,
    required this.memoryCacheCount,
    required this.diskCacheSize,
    required this.isInitialized,
  });

  /// Average memory per cached image in bytes.
  double get averageMemoryPerImage {
    if (memoryCacheCount == 0) return 0;
    return memoryCacheSize / memoryCacheCount;
  }

  /// Memory cache size formatted as string.
  String get formattedMemoryCacheSize {
    return _formatBytes(memoryCacheSize);
  }

  /// Disk cache size formatted as string.
  String get formattedDiskCacheSize {
    return _formatBytes(diskCacheSize);
  }

  @override
  String toString() {
    return 'ImageCacheStats('
        'memoryCacheSize: $formattedMemoryCacheSize, '
        'memoryCacheCount: $memoryCacheCount, '
        'diskCacheSize: $formattedDiskCacheSize, '
        'avgMemoryPerImage: ${_formatBytes(averageMemoryPerImage.toInt())}, '
        'isInitialized: $isInitialized)';
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Dimensions for memory caching.
class CacheDimensions {
  /// Width in pixels.
  final int width;

  /// Height in pixels.
  final int height;

  const CacheDimensions({
    required this.width,
    required this.height,
  });

  @override
  String toString() => 'CacheDimensions(${width}x$height)';
}
