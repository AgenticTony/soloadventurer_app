import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

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

    // Default placeholder
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.placeholderColor ?? Colors.grey[300],
        borderRadius: widget.borderRadius,
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
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
}
