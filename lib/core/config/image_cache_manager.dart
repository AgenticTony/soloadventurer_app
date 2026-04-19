import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'
    as cache_manager;

/// Configuration for image caching and loading
class ImageCacheConfig {
  /// Maximum memory cache size in MB (default: 300)
  final int maxMemoryCacheSize;

  /// Maximum disk cache size in MB (default: 1000)
  final int maxDiskCacheSize;

  /// Default image quality for compression (1-100)
  final int imageQuality;

  /// Default placeholder image while loading
  final String? placeholderImage;

  /// Default error image to show on failure
  final String? errorImage;

  /// Enable high-resolution images for high-DPI screens
  final bool enableHighResImages;

  /// Preload nearby images in lists
  final bool enablePreloading;

  /// Number of images to preload ahead
  final int preloadRadius;

  /// Maximum image width (null = no limit)
  final int? maxWidth;

  /// Maximum image height (null = no limit)
  final int? maxHeight;

  const ImageCacheConfig({
    this.maxMemoryCacheSize = 300,
    this.maxDiskCacheSize = 1000,
    this.imageQuality = 85,
    this.placeholderImage,
    this.errorImage,
    this.enableHighResImages = true,
    this.enablePreloading = true,
    this.preloadRadius = 3,
    this.maxWidth,
    this.maxHeight,
  });

  /// Predefined configurations
  static const forList = ImageCacheConfig(
    maxMemoryCacheSize: 200,
    maxDiskCacheSize: 500,
    imageQuality: 80,
    enablePreloading: true,
    preloadRadius: 5,
    maxWidth: 800,
  );

  static const forGallery = ImageCacheConfig(
    maxMemoryCacheSize: 400,
    maxDiskCacheSize: 1000,
    imageQuality: 85,
    enablePreloading: true,
    preloadRadius: 3,
    maxWidth: 1200,
  );

  static const forThumbnails = ImageCacheConfig(
    maxMemoryCacheSize: 100,
    maxDiskCacheSize: 200,
    imageQuality: 70,
    enablePreloading: false,
    maxWidth: 300,
    maxHeight: 300,
  );

  static const forDetail = ImageCacheConfig(
    maxMemoryCacheSize: 500,
    maxDiskCacheSize: 2000,
    imageQuality: 95,
    enablePreloading: false,
  );
}

/// Image URL builder for generating optimized URLs
class ImageUrlBuilder {
  const ImageUrlBuilder();

  /// Build optimized image URL with size parameters
  String buildUrl(
    String baseUrl, {
    int? width,
    int? height,
    int quality = 85,
    String format = 'jpg',
  }) {
    if (!baseUrl.contains('http')) {
      return baseUrl;
    }

    final uri = Uri.parse(baseUrl);
    final params = Map<String, dynamic>.from(uri.queryParameters);

    if (width != null) params['w'] = width.toString();
    if (height != null) params['h'] = height.toString();
    params['q'] = quality.toString();
    params['fmt'] = format;

    return uri.replace(queryParameters: params).toString();
  }

  /// Build thumbnail URL
  String buildThumbnailUrl(
    String baseUrl, {
    int width = 300,
    int height = 300,
    int quality = 70,
  }) {
    return buildUrl(
      baseUrl,
      width: width,
      height: height,
      quality: quality,
    );
  }

  /// Build full resolution URL
  String buildFullUrl(String baseUrl, {int quality = 95}) {
    return buildUrl(baseUrl, quality: quality);
  }
}

/// Manages image caching and preloading for optimal performance
class ImageCacheManager {
  static ImageCacheManager? _instance;
  ImageCacheConfig _config;
  final ImageUrlBuilder _urlBuilder = const ImageUrlBuilder();

  ImageCacheManager._internal(this._config);

  /// Get singleton instance
  static ImageCacheManager get instance {
    _instance ??= ImageCacheManager._internal(ImageCacheConfig.forGallery);
    return _instance!;
  }

  /// Update configuration
  void updateConfig(ImageCacheConfig config) {
    _config = config;
    _applyConfig();
  }

  /// Get current configuration
  ImageCacheConfig get config => _config;

  /// Apply cache configuration
  void _applyConfig() {
    final cache = PaintingBinding.instance.imageCache;
    cache.maximumSize = _config.maxMemoryCacheSize ~/ 2;
    cache.maximumSizeBytes = _config.maxMemoryCacheSize * 1024 * 1024;

    // Configure disk cache
    // Note: Disk cache size is configured at the package level
    // This is just a placeholder for future enhancements
  }

  /// Clear all cached images
  Future<void> clearCache() async {
    try {
      // Clear memory cache
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      // Clear disk cache
      await cache_manager.DefaultCacheManager().emptyCache();
    } catch (e) {
    // intentional silent catch
    }
  }

  /// Preload a list of images
  Future<void> preloadImages(List<String> urls) async {
    if (!_config.enablePreloading || urls.isEmpty) return;

    try {
      final futures = urls.map((url) => precacheImage(
            CachedNetworkImageProvider(url),
            _getCurrentContext(),
          ));

      await Future.wait(futures, eagerError: false);
    } catch (e) {
    // intentional silent catch
    }
  }

  /// Preload images with index range
  Future<void> preloadImageRange(
    List<String> urls,
    int currentIndex,
  ) async {
    if (!_config.enablePreloading) return;

    final startIndex =
        (currentIndex - _config.preloadRadius).clamp(0, urls.length);
    final endIndex =
        (currentIndex + _config.preloadRadius).clamp(0, urls.length);

    final urlsToPreload = urls.sublist(startIndex, endIndex).toList();
    await preloadImages(urlsToPreload);
  }

  /// Build optimized image widget
  Widget buildCachedImage(
    String imageUrl, {
    Widget? placeholder,
    Widget? errorWidget,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    int? customMaxWidth,
    int? customMaxHeight,
  }) {
    final optimizedUrl = _urlBuilder.buildUrl(
      imageUrl,
      width: customMaxWidth ?? _config.maxWidth,
      height: customMaxHeight ?? _config.maxHeight,
      quality: _config.imageQuality,
    );

    return CachedNetworkImage(
      imageUrl: optimizedUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: placeholder != null
          ? (context, url) => placeholder
          : (context, url) => _buildDefaultPlaceholder(),
      errorWidget: errorWidget != null
          ? (context, url, error) => errorWidget
          : (context, url, error) => _buildDefaultErrorWidget(),
      memCacheWidth: customMaxWidth ?? _config.maxWidth,
      memCacheHeight: customMaxHeight ?? _config.maxHeight,
    );
  }

  /// Build thumbnail image widget
  Widget buildThumbnail(
    String imageUrl, {
    Widget? placeholder,
    Widget? errorWidget,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
  }) {
    final thumbnailUrl = _urlBuilder.buildThumbnailUrl(
      imageUrl,
      width: _config.maxWidth ?? 300,
      height: _config.maxHeight ?? 300,
      quality: _config.imageQuality,
    );

    return CachedNetworkImage(
      imageUrl: thumbnailUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: placeholder != null
          ? (context, url) => placeholder
          : (context, url) => _buildDefaultPlaceholder(),
      errorWidget: errorWidget != null
          ? (context, url, error) => errorWidget
          : (context, url, error) => _buildDefaultErrorWidget(),
      memCacheWidth: 300,
      memCacheHeight: 300,
    );
  }

  /// Build full resolution image widget
  Widget buildFullImage(
    String imageUrl, {
    Widget? placeholder,
    Widget? errorWidget,
    BoxFit fit = BoxFit.contain,
    double? width,
    double? height,
  }) {
    final fullUrl = _urlBuilder.buildFullUrl(imageUrl);

    return CachedNetworkImage(
      imageUrl: fullUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: placeholder != null
          ? (context, url) => placeholder
          : (context, url) => _buildDefaultPlaceholder(),
      errorWidget: errorWidget != null
          ? (context, url, error) => errorWidget
          : (context, url, error) => _buildDefaultErrorWidget(),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      color: const Color(0xFFE0E0E0),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      color: const Color(0xFFE0E0E0),
      child: const Center(
        child: Icon(Icons.broken_image, size: 48, color: Color(0xFF9E9E9E)),
      ),
    );
  }

  /// Get current context (for preloading)
  /// Note: This needs to be set by the app using setContext()
  BuildContext? _currentContext;

  void setContext(BuildContext context) {
    _currentContext = context;
  }

  BuildContext _getCurrentContext() {
    if (_currentContext == null) {
      throw Exception(
          'ImageCacheManager context not set. Call setContext() first.');
    }
    return _currentContext!;
  }

  /// Get cache statistics
  Future<ImageCacheStats> getCacheStats() async {
    final memoryCache = PaintingBinding.instance.imageCache;

    return ImageCacheStats(
      currentMemoryCacheSize: memoryCache.currentSizeBytes,
      maxMemoryCacheSize: _config.maxMemoryCacheSize * 1024 * 1024,
      currentMemoryCount: memoryCache.currentSize,
      maxMemoryCount: _config.maxMemoryCacheSize ~/ 2,
    );
  }
}

/// Statistics about image cache
class ImageCacheStats {
  final int currentMemoryCacheSize;
  final int maxMemoryCacheSize;
  final int currentMemoryCount;
  final int maxMemoryCount;

  const ImageCacheStats({
    required this.currentMemoryCacheSize,
    required this.maxMemoryCacheSize,
    required this.currentMemoryCount,
    required this.maxMemoryCount,
  });

  double get memoryUsagePercent =>
      (currentMemoryCacheSize / maxMemoryCacheSize * 100);

  double get countUsagePercent => (currentMemoryCount / maxMemoryCount * 100);

  @override
  String toString() {
    return 'ImageCacheStats(size: ${(currentMemoryCacheSize / 1024 / 1024).toStringAsFixed(1)}MB / ${(maxMemoryCacheSize / 1024 / 1024).toStringAsFixed(1)}MB, count: $currentMemoryCount / $maxMemoryCount)';
  }
}
