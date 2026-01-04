import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
/// - Visibility-based lazy loading
/// - Configurable visibility threshold
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
  });

  @override
  State<LazyLoadImage> createState() => _LazyLoadImageState();
}

class _LazyLoadImageState extends State<LazyLoadImage> {
  /// Whether the image should be loaded
  bool _shouldLoad = false;

  /// Unique key for VisibilityDetector
  final Key _visibilityKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    // Wrap with VisibilityDetector to track when widget becomes visible
    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: (visibilityInfo) {
        // Only update state if visibility changed and we haven't loaded yet
        if (!_shouldLoad &&
            visibilityInfo.visibleFraction >= widget.visibilityThreshold) {
          setState(() {
            _shouldLoad = true;
          });
        }
      },
      child: _buildContent(),
    );
  }

  /// Builds the appropriate content based on load state
  Widget _buildContent() {
    // If not visible yet, show placeholder
    if (!_shouldLoad) {
      return _buildPlaceholder();
    }

    // If visible, load the image
    return _buildImage();
  }

  /// Builds placeholder widget
  Widget _buildPlaceholder() {
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

  /// Builds the actual image widget with caching
  Widget _buildImage() {
    final imageWidget = CachedNetworkImage(
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
          : (context, url, error) => _buildDefaultError(),
      memCacheWidth: widget.width?.toInt(),
      memCacheHeight: widget.height?.toInt(),
    );

    // Apply border radius if specified
    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  /// Builds default error widget
  Widget _buildDefaultError() {
    // Use enhanced error handling if enabled
    if (widget.useEnhancedErrorHandling) {
      return ImageErrorWidget(
        error: 'Failed to load',
        imageUrl: widget.imageUrl,
        width: widget.width,
        height: widget.height,
        borderRadius: widget.borderRadius,
        onRetry: widget.onRetry,
        showRetryButton: widget.onRetry != null,
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
      child: const Icon(
        Icons.broken_image,
        size: 48,
        color: Colors.grey,
      ),
    );
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
  /// - Retry button on error
  /// - Offline detection
  /// - Automatic error type classification
  ///
  /// Example:
  /// ```dart
  /// LazyLoadImage.optimized(
  ///   imageUrl: photo.url,
  ///   thumbnailUrl: photo.thumbnailUrl,
  ///   size: 100.0,
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
  ///   height: 200.0,
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
      borderRadius: borderRadius ?? BorderRadius.circular(4.0),
    );
  }
}
