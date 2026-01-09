import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Custom cache manager for destination images with optimized settings.
///
/// This cache manager provides:
/// - Longer cache duration (30 days) for destination images
/// - Maximum cache size of 200MB
/// - Maximum number of cached objects (200)
/// - Optimized for network image loading in destination discovery feature
///
/// Usage:
/// ```dart
/// CachedNetworkImage(
///   imageUrl: imageUrl,
///   cacheManager: destinationImageCacheManager,
/// )
/// ```
final destinationImageCacheManager = CacheManager(
  Config(
    'destinationImages',
    stalePeriod: const Duration(days: 30),
    maxNrOfCacheObjects: 200,
    repo: JsonCacheInfoRepository(databaseName: 'destination_images_cache'),
    fileService: HttpFileService(),
  ),
);

/// Custom cache manager for thumbnail images with optimized settings.
///
/// This cache manager is optimized for smaller thumbnail images:
/// - Longer cache duration (60 days) for thumbnails
/// - Smaller cache size (50MB)
/// - Maximum number of cached objects (500)
/// - Optimized for destination card thumbnails
final destinationThumbnailCacheManager = CacheManager(
  Config(
    'destinationThumbnails',
    stalePeriod: const Duration(days: 60),
    maxNrOfCacheObjects: 500,
    repo: JsonCacheInfoRepository(databaseName: 'destination_thumbnails_cache'),
    fileService: HttpFileService(),
  ),
);

/// Custom cache manager for curated list images with optimized settings.
///
/// This cache manager provides:
/// - Cache duration of 45 days for curated list images
/// - Maximum cache size of 100MB
/// - Maximum number of cached objects (100)
final curatedListImageCacheManager = CacheManager(
  Config(
    'curatedListImages',
    stalePeriod: const Duration(days: 45),
    maxNrOfCacheObjects: 100,
    repo: JsonCacheInfoRepository(databaseName: 'curated_list_images_cache'),
    fileService: HttpFileService(),
  ),
);
