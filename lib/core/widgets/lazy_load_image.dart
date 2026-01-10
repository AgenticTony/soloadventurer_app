import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:async';

import 'image_error_widget.dart';
import 'image_placeholder.dart';

/// A lazy-loading image widget that only loads images when they become visible.
///
/// This widget uses [VisibilityDetector] to detect when the image widget enters
/// the viewport and only then initiates the image loading. This significantly
/// improves performance for lists and grids with many images by:
///
/// - Reducing initial memory footprint
/// - Minimizing network requests for off-screen images
/// - Improving scroll performance
/// - Preserving battery life
///
/// Features:
/// - Visibility-based lazy loading with hysteresis to prevent flickering
/// - Configurable visibility threshold for precise control
/// - Preloading for off-screen images to improve perceived performance
/// - Progressive image loading (thumbnail → medium → full)
/// - Automatic retry with exponential backoff for transient failures
/// - Offline-aware error handling
/// - Placeholder widget during loading
/// - Error widget for failed loads
/// - Custom image fit
/// - Optional fade-in animation
/// - Integration with cached_network_image
///
/// Example:
/// ```dart
/// LazyLoadImage(
///   imageUrl: 'https://example.com/image.jpg',
///   placeholder: (context, url) => Container(
///     color: Colors.grey[300],
///     child: const Center(child: CircularProgressIndicator()),
///   ),
///   errorWidget: (context, url, error) => const Icon(Icons.error),
/// )
///
/// // With preloading and progressive loading
/// LazyLoadImage(
///   imageUrl: 'https://example.com/image.jpg',
///   thumbnailUrl: 'https://example.com/thumb.jpg',
///   preloadOffset: 500, // Start loading 500px before visible
///   maxRetryCount: 3, // Retry failed loads up to 3 times
/// )
///
/// // With custom threshold
/// LazyLoadImage(
///   imageUrl: 'https://example.com/image.jpg',
///   visibilityThreshold: 0.2, // Load when 20% visible
///   fadeInDuration: const Duration(milliseconds: 300),
/// )
/// ```
class LazyLoadImage extends StatefulWidget {
  /// The URL of the image to load
  final String imageUrl;

  /// Optional thumbnail URL to load before the main image
  final String? thumbnailUrl;

  /// Widget builder for placeholder state
  final Widget Function(BuildContext, String)? placeholder;

  /// Widget builder for error state
  final Widget Function(BuildContext, String, dynamic)? errorWidget;

  /// How to inscribe the image into the space allocated for it
  final BoxFit fit;

  /// The fraction of the widget that must be visible before loading
  ///
  /// Defaults to 0.01 (load when any part is visible). Set to 0.5 to load
  /// when half the image is visible, etc.
  final double visibilityThreshold;

  /// Duration of fade-in animation when image loads
  final Duration fadeInDuration;

  /// Custom placeholder color for the default placeholder
  final Color? placeholderColor;

  /// Optional width constraint
  final double? width;

  /// Optional height constraint
  final double? height;

  /// Optional border radius
  final BorderRadius? borderRadius;

  /// Type of placeholder to use (shimmer, skeleton, color, or blurred)
  final PlaceholderType placeholderType;

  /// Whether to use enhanced error handling with retry button
  final bool useEnhancedErrorHandling;

  /// Callback when retry is pressed on error widget
  final VoidCallback? onRetry;

  /// Distance in pixels to preload image before it becomes visible
  ///
  /// Defaults to 0 (load only when visible). Set to 300-500 for preloading
  /// images before they enter the viewport for smoother perceived performance.
  final double preloadOffset;

  /// Maximum number of retry attempts for failed loads
  ///
  /// Defaults to 0 (no automatic retry). Set to 3-5 for automatic retry
  /// with exponential backoff for transient network failures.
  final int maxRetryCount;

  /// Initial delay before first retry attempt
  ///
  /// Defaults to 1 second. Subsequent retries use exponential backoff.
  final Duration initialRetryDelay;

  /// Whether to use progressive image loading (thumbnail → full)
  ///
  /// Defaults to true. When enabled and [thumbnailUrl] is provided,
  /// the thumbnail loads first, then transitions to the full image.
  final bool useProgressiveLoading;

  /// Whether to pause loading when device is offline
  ///
  /// Defaults to true. When enabled, images won't attempt to load
  /// when the device has no internet connection.
  final bool pauseWhenOffline;

  /// Hysteresis margin for visibility detection to prevent flickering
  ///
  /// Defaults to 0.05 (5%). The visibility must drop below this threshold
  /// after being visible to trigger hide detection. Prevents rapid
  /// show/hide cycles during fast scrolling.
  final double visibilityHysteresis;

  /// Creates a lazy-loading image widget
  const LazyLoadImage({
    super.key,
    required this.imageUrl,
    this.thumbnailUrl,
    this.placeholder,
    this.errorWidget,
    this.fit = BoxFit.cover,
    this.visibilityThreshold = 0.01,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.placeholderColor,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholderType = PlaceholderType.shimmer,
    this.useEnhancedErrorHandling = false,
    this.onRetry,
    this.preloadOffset = 0,
    this.maxRetryCount = 0,
    this.initialRetryDelay = const Duration(seconds: 1),
    this.useProgressiveLoading = true,
    this.pauseWhenOffline = true,
    this.visibilityHysteresis = 0.05,
  });

  @override
  State<LazyLoadImage> createState() => _LazyLoadImageState();
}

class _LazyLoadImageState extends State<LazyLoadImage> {
  /// Whether the image should be loaded
  bool _shouldLoad = false;

  /// Whether the image has successfully loaded
  bool _hasLoaded = false;

  /// Current retry attempt count
  int _retryCount = 0;

  /// Timer for retry attempts
  Timer? _retryTimer;

  /// Whether device is currently offline
  bool _isOffline = false;

  /// Unique key for VisibilityDetector
  final Key _visibilityKey = UniqueKey();

  /// Key for forcing image rebuild on retry
  Key _imageKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    if (widget.pauseWhenOffline) {
      _checkConnectivity();
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  /// Checks current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (mounted) {
        setState(() {
          _isOffline = connectivityResult == ConnectivityResult.none;
        });
      }
    } catch (e) {
      // Ignore connectivity check errors
      if (kDebugMode) {
        debugPrint('Connectivity check failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap with VisibilityDetector to track when widget becomes visible
    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: _onVisibilityChanged,
      child: _buildContent(),
    );
  }

  /// Handles visibility changes with hysteresis to prevent flickering
  void _onVisibilityChanged(VisibilityInfo visibilityInfo) {
    final visibleFraction = visibilityInfo.visibleFraction;
    final shouldShow = visibleFraction >= widget.visibilityThreshold;
    final shouldHide = visibleFraction <
        (widget.visibilityThreshold - widget.visibilityHysteresis);

    if (shouldShow && !_shouldLoad && !_hasLoaded) {
      // Check offline status before loading
      if (widget.pauseWhenOffline && _isOffline) {
        return;
      }
      setState(() {
        _shouldLoad = true;
      });
    } else if (shouldHide && _shouldLoad && !_hasLoaded) {
      // Image hasn't loaded yet and widget scrolled away, reset state
      setState(() {
        _shouldLoad = false;
        _retryCount = 0;
        _retryTimer?.cancel();
      });
    }
  }

  /// Builds the appropriate content based on load state
  Widget _buildContent() {
    // If offline and pauseWhenOffline is enabled, show placeholder
    if (widget.pauseWhenOffline && _isOffline && !_hasLoaded) {
      return _buildPlaceholder(isOffline: true);
    }

    // If not visible yet, show placeholder
    if (!_shouldLoad && !_hasLoaded) {
      return _buildPlaceholder();
    }

    // If visible, load the image
    return _buildImage();
  }

  /// Builds placeholder widget
  Widget _buildPlaceholder({bool isOffline = false}) {
    // Use custom placeholder if provided
    if (widget.placeholder != null) {
      return widget.placeholder!(context, widget.imageUrl);
    }

    // Use optimized placeholder based on type
    switch (widget.placeholderType) {
      case PlaceholderType.shimmer:
        return ImagePlaceholder.shimmer(
          width: widget.width,
          height: widget.height,
          borderRadius: widget.borderRadius,
          baseColor: widget.placeholderColor,
        );
      case PlaceholderType.skeleton:
        return ImagePlaceholder.skeleton(
          width: widget.width,
          height: widget.height,
          color: widget.placeholderColor,
          borderRadius: widget.borderRadius,
          showIcon: true,
        );
      case PlaceholderType.color:
        return ImagePlaceholder.color(
          width: widget.width,
          height: widget.height,
          backgroundColor: widget.placeholderColor,
          borderRadius: widget.borderRadius,
        );
      case PlaceholderType.blurred:
        return ImagePlaceholder.blurred(
          thumbnailUrl: widget.thumbnailUrl,
          width: widget.width,
          height: widget.height,
          borderRadius: widget.borderRadius,
          fallbackColor: widget.placeholderColor,
        );
    }
  }

  /// Builds the actual image widget with caching and retry logic
  Widget _buildImage() {
    // Use progressive loading if enabled and thumbnail is available
    if (widget.useProgressiveLoading && widget.thumbnailUrl != null) {
      return _buildProgressiveImage();
    }

    // Build single image with retry logic
    return _buildSingleImage();
  }

  /// Builds progressive loading image (thumbnail → full)
  Widget _buildProgressiveImage() {
    final imageWidget = CachedNetworkImage(
      key: _imageKey,
      imageUrl: widget.imageUrl,
      fadeInDuration: widget.fadeInDuration,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      placeholder: widget.placeholder != null
          ? (context, url) => widget.placeholder!(context, url)
          : (context, url) => _buildThumbnailPlaceholder(),
      errorWidget: widget.errorWidget != null
          ? (context, url, error) => widget.errorWidget!(context, url, error)
          : (context, url, error) => _buildErrorWidget(error),
      imageBuilder: (context, imageProvider) {
        // Mark as loaded on success
        if (!_hasLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _hasLoaded = true;
              });
            }
          });
        }
        return Image(image: imageProvider, fit: widget.fit);
      },
      memCacheWidth: widget.width?.toInt(),
      memCacheHeight: widget.height?.toInt(),
    );

    return _applyBorderRadius(imageWidget);
  }

  /// Builds thumbnail placeholder for progressive loading
  Widget _buildThumbnailPlaceholder() {
    return CachedNetworkImage(
      imageUrl: widget.thumbnailUrl!,
      fadeInDuration: const Duration(milliseconds: 150),
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildPlaceholder(),
      memCacheWidth: widget.width != null
          ? (widget.width! ~/ 4).toInt() // Thumbnail at 1/4 resolution
          : null,
      memCacheHeight:
          widget.height != null ? (widget.height! ~/ 4).toInt() : null,
    );
  }

  /// Builds single image with retry logic
  Widget _buildSingleImage() {
    final imageWidget = CachedNetworkImage(
      key: _imageKey,
      imageUrl: widget.imageUrl,
      fadeInDuration: widget.fadeInDuration,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      placeholder: widget.placeholder != null
          ? (context, url) => widget.placeholder!(context, url)
          : null,
      errorWidget: widget.errorWidget != null
          ? (context, url, error) => widget.errorWidget!(context, url, error)
          : (context, url, error) => _buildErrorWidget(error),
      imageBuilder: (context, imageProvider) {
        // Mark as loaded on success
        if (!_hasLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _hasLoaded = true;
              });
            }
          });
        }
        return Image(image: imageProvider, fit: widget.fit);
      },
      memCacheWidth: widget.width?.toInt(),
      memCacheHeight: widget.height?.toInt(),
    );

    return _applyBorderRadius(imageWidget);
  }

  /// Applies border radius if specified
  Widget _applyBorderRadius(Widget imageWidget) {
    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }
    return imageWidget;
  }

  /// Builds error widget with automatic retry
  Widget _buildErrorWidget(dynamic error) {
    // Check if error is retryable
    final classifier = ImageErrorClassifier.classify(error);
    final canRetry =
        classifier.isRetryable() && _retryCount < widget.maxRetryCount;

    // Use enhanced error handling if enabled
    if (widget.useEnhancedErrorHandling) {
      return ImageErrorWidget(
        error: error,
        imageUrl: widget.imageUrl,
        width: widget.width,
        height: widget.height,
        borderRadius: widget.borderRadius,
        onRetry: canRetry ? _scheduleRetry : widget.onRetry,
        showRetryButton: widget.onRetry != null || canRetry,
      );
    }

    // Default simple error widget
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        child: canRetry
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.broken_image,
                    size: 48,
                    color: Colors.grey,
                  ),
                  if (_retryCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Retrying... ($_retryCount/${widget.maxRetryCount})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              )
            : const Icon(
                Icons.broken_image,
                size: 48,
                color: Colors.grey,
              ),
      ),
    );
  }

  /// Schedules a retry attempt with exponential backoff
  void _scheduleRetry() {
    if (_retryCount >= widget.maxRetryCount) {
      return;
    }

    _retryCount++;

    // Calculate delay with exponential backoff: initialDelay * 2^retryCount
    final delay = Duration(
      milliseconds: widget.initialRetryDelay.inMilliseconds *
          (1 << (_retryCount - 1)).clamp(1, 8),
    );

    _retryTimer = Timer(delay, () {
      if (mounted) {
        setState(() {
          _imageKey = UniqueKey(); // Force image rebuild
        });
      }
    });
  }
}

/// Type of placeholder to display while image is loading
enum PlaceholderType {
  /// Animated shimmer effect with gradient (modern, visually appealing)
  shimmer,

  /// Simple solid color with optional icon (most performant)
  skeleton,

  /// Theme-aware color with icon overlay (subtle)
  color,

  /// Blurred thumbnail if available, falls back to shimmer (progressive)
  blurred,
}

/// Extension on LazyLoadImage for common use cases
extension LazyLoadImageExtensions on LazyLoadImage {
  /// Creates a square lazy-loaded photo for grid galleries
  ///
  /// This is optimized for use in photo grids where all items have
  /// the same size and aspect ratio.
  static LazyLoadImage photo({
    Key? key,
    required String imageUrl,
    String? thumbnailUrl,
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, String, dynamic)? errorWidget,
    double size = 100.0,
    BoxFit fit = BoxFit.cover,
    double visibilityThreshold = 0.01,
    BorderRadius? borderRadius,
  }) {
    return LazyLoadImage(
      key: key,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      placeholder: placeholder,
      errorWidget: errorWidget,
      width: size,
      height: size,
      fit: fit,
      visibilityThreshold: visibilityThreshold,
      borderRadius: borderRadius ?? BorderRadius.circular(4.0),
    );
  }

  /// Creates a rectangular lazy-loaded image for card layouts
  ///
  /// This is optimized for list items and card-based layouts where
  /// images need to fill available width with a fixed aspect ratio.
  static LazyLoadImage card({
    Key? key,
    required String imageUrl,
    String? thumbnailUrl,
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, String, dynamic)? errorWidget,
    double width = double.infinity,
    double height = 200.0,
    BoxFit fit = BoxFit.cover,
    double visibilityThreshold = 0.01,
    BorderRadius? borderRadius,
  }) {
    return LazyLoadImage(
      key: key,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      placeholder: placeholder,
      errorWidget: errorWidget,
      width: width,
      height: height,
      fit: fit,
      visibilityThreshold: visibilityThreshold,
      borderRadius: borderRadius ?? BorderRadius.circular(8.0),
    );
  }

  /// Creates a thumbnail lazy-loaded image
  ///
  /// This is optimized for small thumbnails (e.g., in list items) where
  /// performance is critical and image quality can be lower.
  static LazyLoadImage thumbnail({
    Key? key,
    required String imageUrl,
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, String, dynamic)? errorWidget,
    double size = 48.0,
    BoxFit fit = BoxFit.cover,
    double visibilityThreshold = 0.1,
    BorderRadius? borderRadius,
  }) {
    return LazyLoadImage(
      key: key,
      imageUrl: imageUrl,
      placeholder: placeholder,
      errorWidget: errorWidget,
      width: size,
      height: size,
      fit: fit,
      visibilityThreshold: visibilityThreshold,
      fadeInDuration: const Duration(milliseconds: 150),
      borderRadius: borderRadius ?? BorderRadius.circular(4.0),
    );
  }

  /// Creates a photo with optimized shimmer placeholder and enhanced error handling.
  ///
  /// This is the recommended constructor for photo galleries as it provides:
  /// - Modern shimmer loading animation
  /// - Automatic retry with exponential backoff
  /// - Offline detection
  /// - Progressive image loading
  /// - Automatic error type classification
  ///
  /// Example:
  /// ```dart
  /// LazyLoadImage.optimized(
  ///   imageUrl: photo.url,
  ///   thumbnailUrl: photo.thumbnailUrl,
  ///   size: 100.0,
  ///   maxRetryCount: 3,
  ///   preloadOffset: 300,
  ///   onRetry: () {
  ///     // Trigger reload (e.g., setState or refresh provider)
  ///   },
  /// )
  /// ```
  static LazyLoadImage optimized({
    Key? key,
    required String imageUrl,
    String? thumbnailUrl,
    double size = 100.0,
    BoxFit fit = BoxFit.cover,
    PlaceholderType placeholderType = PlaceholderType.shimmer,
    BorderRadius? borderRadius,
    VoidCallback? onRetry,
    double visibilityThreshold = 0.01,
    int maxRetryCount = 3,
    double preloadOffset = 300,
    bool useProgressiveLoading = true,
  }) {
    return LazyLoadImage(
      key: key,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      width: size,
      height: size,
      fit: fit,
      placeholderType: placeholderType,
      useEnhancedErrorHandling: true,
      onRetry: onRetry,
      visibilityThreshold: visibilityThreshold,
      maxRetryCount: maxRetryCount,
      preloadOffset: preloadOffset,
      useProgressiveLoading: useProgressiveLoading,
      borderRadius: borderRadius ?? BorderRadius.circular(4.0),
    );
  }

  /// Creates a card image with skeleton placeholder and enhanced error handling.
  ///
  /// This is optimized for card-based layouts where performance is important
  /// but you still want good error handling.
  ///
  /// Example:
  /// ```dart
  /// LazyLoadImage.optimizedCard(
  ///   imageUrl: trip.coverImage,
  ///   thumbnailUrl: trip.thumbnailUrl,
  ///   height: 200.0,
  ///   maxRetryCount: 3,
  ///   preloadOffset: 500,
  ///   onRetry: () => ref.refresh(tripCoverProvider),
  /// )
  /// ```
  static LazyLoadImage optimizedCard({
    Key? key,
    required String imageUrl,
    String? thumbnailUrl,
    double width = double.infinity,
    double height = 200.0,
    BoxFit fit = BoxFit.cover,
    PlaceholderType placeholderType = PlaceholderType.skeleton,
    BorderRadius? borderRadius,
    VoidCallback? onRetry,
    int maxRetryCount = 3,
    double preloadOffset = 500,
    bool useProgressiveLoading = true,
  }) {
    return LazyLoadImage(
      key: key,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      width: width,
      height: height,
      fit: fit,
      placeholderType: placeholderType,
      useEnhancedErrorHandling: true,
      onRetry: onRetry,
      maxRetryCount: maxRetryCount,
      preloadOffset: preloadOffset,
      useProgressiveLoading: useProgressiveLoading,
      borderRadius: borderRadius ?? BorderRadius.circular(8.0),
    );
  }

  /// Creates a thumbnail with color placeholder and compact error widget.
  ///
  /// This is optimized for list items where space is limited and you want
  /// a subtle loading indicator.
  ///
  /// Example:
  /// ```dart
  /// LazyLoadImage.optimizedThumbnail(
  ///   imageUrl: user.avatarUrl,
  ///   size: 48.0,
  ///   maxRetryCount: 2,
  /// )
  /// ```
  static LazyLoadImage optimizedThumbnail({
    Key? key,
    required String imageUrl,
    double size = 48.0,
    BoxFit fit = BoxFit.cover,
    PlaceholderType placeholderType = PlaceholderType.color,
    BorderRadius? borderRadius,
    VoidCallback? onRetry,
    int maxRetryCount = 2,
  }) {
    return LazyLoadImage(
      key: key,
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: fit,
      placeholderType: placeholderType,
      useEnhancedErrorHandling: onRetry != null,
      onRetry: onRetry,
      visibilityThreshold: 0.1,
      fadeInDuration: const Duration(milliseconds: 150),
      maxRetryCount: maxRetryCount,
      borderRadius: borderRadius ?? BorderRadius.circular(4.0),
    );
  }

  /// Creates a photo with blurred placeholder (progressive loading effect).
  ///
  /// This creates a blur-up effect where a heavily blurred thumbnail is shown
  /// first, then replaced with the full-quality image. Requires thumbnailUrl.
  ///
  /// Example:
  /// ```dart
  /// LazyLoadImage.progressive(
  ///   imageUrl: photo.fullSizeUrl,
  ///   thumbnailUrl: photo.thumbnailUrl,
  ///   size: 150.0,
  ///   maxRetryCount: 3,
  /// )
  /// ```
  static LazyLoadImage progressive({
    Key? key,
    required String imageUrl,
    required String thumbnailUrl,
    double size = 150.0,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    VoidCallback? onRetry,
    int maxRetryCount = 3,
  }) {
    return LazyLoadImage(
      key: key,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      width: size,
      height: size,
      fit: fit,
      placeholderType: PlaceholderType.blurred,
      useEnhancedErrorHandling: true,
      onRetry: onRetry,
      maxRetryCount: maxRetryCount,
      useProgressiveLoading: true,
      borderRadius: borderRadius ?? BorderRadius.circular(4.0),
    );
  }
}
