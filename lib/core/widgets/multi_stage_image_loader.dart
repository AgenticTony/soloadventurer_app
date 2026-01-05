import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'image_error_widget.dart';
import 'image_placeholder.dart';

/// A multi-stage image loading widget that progressively loads images at
/// different resolutions for optimal performance.
///
/// This widget implements a three-stage loading pipeline:
/// 1. **Thumbnail** - Small preview image (150x150) loads instantly
/// 2. **Medium** - Medium resolution (800x600) for grid/list views
/// 3. **Full** - Full resolution on demand (when tapped or explicitly loaded)
///
/// This approach provides:
/// - **Fast initial display** - Thumbnail appears almost instantly
/// - **Optimal memory usage** - Only loads high-res when needed
/// - **Smooth user experience** - Progressive enhancement with transitions
/// - **Bandwidth efficiency** - Smaller images for quick browsing
///
/// Features:
/// - Automatic stage progression with smooth transitions
/// - Manual control to load full resolution on demand
/// - Configurable dimensions for each stage
/// - Error handling at each stage with fallback to previous stage
/// - Memory-efficient caching per stage
/// - Progress indicators during loading
/// - Optional tap-to-load-full functionality
///
/// Example:
/// ```dart
/// MultiStageImageLoader(
///   thumbnailUrl: 'https://example.com/thumb.jpg',
///   mediumUrl: 'https://example.com/medium.jpg',
///   fullUrl: 'https://example.com/full.jpg',
///   fit: BoxFit.cover,
///   width: 200,
///   height: 200,
/// )
///
/// // With manual full-resolution loading
/// MultiStageImageLoader(
///   thumbnailUrl: photo.thumbnailUrl,
///   mediumUrl: photo.mediumUrl,
///   fullUrl: photo.fullUrl,
///   initialStage: ImageLoadStage.thumbnail,
///   loadFullOnTap: true,
///   onStageChanged: (stage) {
///     debugPrint('Current stage: $stage');
///   },
/// )
/// ```
class MultiStageImageLoader extends StatefulWidget {
  /// URL of the thumbnail image (typically 150x150)
  final String thumbnailUrl;

  /// URL of the medium resolution image (typically 800x600)
  final String mediumUrl;

  /// URL of the full resolution image (original size)
  final String fullUrl;

  /// How to inscribe the image into the space allocated for it
  final BoxFit fit;

  /// Optional width constraint
  final double? width;

  /// Optional height constraint
  final double? height;

  /// Optional border radius
  final BorderRadius? borderRadius;

  /// Initial stage to load
  final ImageLoadStage initialStage;

  /// Whether to load full resolution when tapped
  final bool loadFullOnTap;

  /// Whether to automatically progress to medium after thumbnail loads
  final bool autoProgressToMedium;

  /// Duration of fade transition between stages
  final Duration transitionDuration;

  /// Custom placeholder widget
  final Widget Function(BuildContext)? placeholder;

  /// Custom error widget for when all stages fail
  final Widget Function(BuildContext, dynamic)? errorWidget;

  /// Callback when the load stage changes
  final void Function(ImageLoadStage stage)? onStageChanged;

  /// Maximum memory cache width for thumbnail stage
  final int? thumbnailMemCacheWidth;

  /// Maximum memory cache height for thumbnail stage
  final int? thumbnailMemCacheHeight;

  /// Maximum memory cache width for medium stage
  final int? mediumMemCacheWidth;

  /// Maximum memory cache height for medium stage
  final int? mediumMemCacheHeight;

  /// Creates a multi-stage image loader
  const MultiStageImageLoader({
    super.key,
    required this.thumbnailUrl,
    required this.mediumUrl,
    required this.fullUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.initialStage = ImageLoadStage.thumbnail,
    this.loadFullOnTap = true,
    this.autoProgressToMedium = true,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.placeholder,
    this.errorWidget,
    this.onStageChanged,
    this.thumbnailMemCacheWidth = 150,
    this.thumbnailMemCacheHeight = 150,
    this.mediumMemCacheWidth = 800,
    this.mediumMemCacheHeight = 600,
  });

  @override
  State<MultiStageImageLoader> createState() => _MultiStageImageLoaderState();
}

class _MultiStageImageLoaderState extends State<MultiStageImageLoader>
    with SingleTickerProviderStateMixin {
  /// Current loading stage
  ImageLoadStage _currentStage = ImageLoadStage.thumbnail;

  /// Whether the current stage has finished loading
  bool _isLoading = false;

  /// Error from the most recent load attempt
  dynamic _loadError;

  /// Animation controller for stage transitions
  late AnimationController _animationController;

  /// Fade animation for smooth transitions
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentStage = widget.initialStage;

    // Setup animation for smooth transitions
    _animationController = AnimationController(
      duration: widget.transitionDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start loading the initial stage
    _loadStage(_currentStage);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Loads the specified image stage
  void _loadStage(ImageLoadStage stage) {
    if (_currentStage == stage && _loadError == null) {
      return; // Already at this stage without error
    }

    setState(() {
      _currentStage = stage;
      _isLoading = true;
      _loadError = null;
    });

    widget.onStageChanged?.call(stage);

    // Trigger animation for smooth transition
    _animationController.forward(from: 0.0);
  }

  /// Loads the full resolution image
  void _loadFullResolution() {
    if (_currentStage != ImageLoadStage.full) {
      _loadStage(ImageLoadStage.full);
    }
  }

  /// Handles tap gesture if loadFullOnTap is enabled
  void _handleTap() {
    if (widget.loadFullOnTap && _currentStage != ImageLoadStage.full) {
      _loadFullResolution();
    }
  }

  /// Gets the URL for the current stage
  String _getUrlForStage(ImageLoadStage stage) {
    switch (stage) {
      case ImageLoadStage.thumbnail:
        return widget.thumbnailUrl;
      case ImageLoadStage.medium:
        return widget.mediumUrl;
      case ImageLoadStage.full:
        return widget.fullUrl;
    }
  }

  /// Gets memory cache dimensions for the current stage
  MapEntry<int?, int?> _getMemCacheDimensions(ImageLoadStage stage) {
    switch (stage) {
      case ImageLoadStage.thumbnail:
        return MapEntry(widget.thumbnailMemCacheWidth, widget.thumbnailMemCacheHeight);
      case ImageLoadStage.medium:
        return MapEntry(widget.mediumMemCacheWidth, widget.mediumMemCacheHeight);
      case ImageLoadStage.full:
        return MapEntry(widget.width?.toInt(), widget.height?.toInt());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: _buildCurrentStage(),
    );
  }

  /// Builds the current stage widget
  Widget _buildCurrentStage() {
    final url = _getUrlForStage(_currentStage);
    final memCacheDims = _getMemCacheDimensions(_currentStage);

    final imageWidget = CachedNetworkImage(
      imageUrl: url,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      memCacheWidth: memCacheDims.key,
      memCacheHeight: memCacheDims.value,
      fadeInDuration: widget.transitionDuration,
      placeholder: widget.placeholder != null
          ? (context, url) => widget.placeholder!(context)
          : (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) {
        // Try falling back to previous stage
        if (_currentStage.index > 0) {
          final previousStage = ImageLoadStage.values[_currentStage.index - 1];
          // Don't infinite loop back to same stage
          if (previousStage != _currentStage) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _currentStage = previousStage;
                  _loadError = error;
                  _isLoading = false;
                });
              }
            });
          }
        } else {
          // All stages failed, show error widget
          setState(() {
            _loadError = error;
            _isLoading = false;
          });
        }

        // Show error while we transition
        return _buildErrorWidget(error);
      },
      imageBuilder: (context, imageProvider) {
        setState(() {
          _isLoading = false;
          _loadError = null;
        });

        // Auto-progress to medium if enabled and currently at thumbnail
        if (widget.autoProgressToMedium &&
            _currentStage == ImageLoadStage.thumbnail) {
          // Delay slightly to let thumbnail display first
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _currentStage == ImageLoadStage.thumbnail) {
              _loadStage(ImageLoadStage.medium);
            }
          });
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: Image(image: imageProvider, fit: widget.fit),
        );
      },
    );

    return _applyBorderRadius(imageWidget);
  }

  /// Builds placeholder widget
  Widget _buildPlaceholder() {
    return ImagePlaceholder.shimmer(
      width: widget.width,
      height: widget.height,
      borderRadius: widget.borderRadius,
    );
  }

  /// Builds error widget
  Widget _buildErrorWidget(dynamic error) {
    if (widget.errorWidget != null) {
      return widget.errorWidget!(context, error);
    }

    return ImageErrorWidget(
      error: error,
      imageUrl: _getUrlForStage(_currentStage),
      width: widget.width,
      height: widget.height,
      borderRadius: widget.borderRadius,
      showRetryButton: false,
    );
  }

  /// Applies border radius if specified
  Widget _applyBorderRadius(Widget child) {
    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: child,
      );
    }
    return child;
  }
}

/// Stages of image loading in the progressive loading pipeline.
enum ImageLoadStage {
  /// Small thumbnail (150x150) for instant preview
  thumbnail,

  /// Medium resolution (800x600) for grid/list views
  medium,

  /// Full resolution for detailed viewing
  full,
}

/// Extension on ImageLoadStage for additional utilities
extension ImageLoadStageExtension on ImageLoadStage {
  /// Gets the display name for the stage
  String get displayName {
    switch (this) {
      case ImageLoadStage.thumbnail:
        return 'Thumbnail';
      case ImageLoadStage.medium:
        return 'Medium';
      case ImageLoadStage.full:
        return 'Full';
    }
  }

  /// Gets the recommended memory cache size
  int get recommendedCacheSize {
    switch (this) {
      case ImageLoadStage.thumbnail:
        return 150;
      case ImageLoadStage.medium:
        return 800;
      case ImageLoadStage.full:
        return 1920; // Full HD
    }
  }

  /// Gets the next stage in the progression
  ImageLoadStage? get nextStage {
    if (this == ImageLoadStage.full) return null;
    return ImageLoadStage.values[index + 1];
  }
}

/// Extension on MultiStageImageLoader for common use cases
extension MultiStageImageLoaderExtensions on MultiStageImageLoader {
  /// Creates a photo grid item optimized for gallery views
  ///
  /// This is optimized for use in photo galleries where:
  /// - Thumbnail shows instantly in grid
  /// - Medium loads when user pauses scrolling
  /// - Full loads only when user taps to view
  ///
  /// Example:
  /// ```dart
  /// MultiStageImageLoader.photoGrid(
  ///   thumbnailUrl: photo.thumbnailUrl,
  ///   mediumUrl: photo.mediumUrl,
  ///   fullUrl: photo.fullUrl,
  ///   size: 150.0,
  ///   loadFullOnTap: true,
  /// )
  /// ```
  static MultiStageImageLoader photoGrid({
    Key? key,
    required String thumbnailUrl,
    required String mediumUrl,
    required String fullUrl,
    double size = 150.0,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    bool loadFullOnTap = true,
    void Function(ImageLoadStage stage)? onStageChanged,
  }) {
    return MultiStageImageLoader(
      key: key,
      thumbnailUrl: thumbnailUrl,
      mediumUrl: mediumUrl,
      fullUrl: fullUrl,
      width: size,
      height: size,
      fit: fit,
      borderRadius: borderRadius ?? BorderRadius.circular(4.0),
      loadFullOnTap: loadFullOnTap,
      autoProgressToMedium: false, // Don't auto-progress in grid
      initialStage: ImageLoadStage.thumbnail,
      onStageChanged: onStageChanged,
    );
  }

  /// Creates a card image optimized for list/card views
  ///
  /// This is optimized for cards where:
  /// - Thumbnail loads immediately for layout
  /// - Medium loads automatically for better quality
  /// - Full loads on tap for detail view
  ///
  /// Example:
  /// ```dart
  /// MultiStageImageLoader.card(
  ///   thumbnailUrl: trip.thumbnailUrl,
  ///   mediumUrl: trip.coverImage,
  ///   fullUrl: trip.fullCoverImage,
  ///   width: double.infinity,
  ///   height: 200.0,
  /// )
  /// ```
  static MultiStageImageLoader card({
    Key? key,
    required String thumbnailUrl,
    required String mediumUrl,
    required String fullUrl,
    double width = double.infinity,
    double height = 200.0,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    bool loadFullOnTap = true,
    void Function(ImageLoadStage stage)? onStageChanged,
  }) {
    return MultiStageImageLoader(
      key: key,
      thumbnailUrl: thumbnailUrl,
      mediumUrl: mediumUrl,
      fullUrl: fullUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius ?? BorderRadius.circular(8.0),
      loadFullOnTap: loadFullOnTap,
      autoProgressToMedium: true, // Auto-progress to medium
      initialStage: ImageLoadStage.thumbnail,
      onStageChanged: onStageChanged,
      mediumMemCacheWidth: 1200, // Higher quality for cards
      mediumMemCacheHeight: 900,
    );
  }

  /// Creates a hero image for full-screen viewing
  ///
  /// This is optimized for hero images where:
  /// - Medium loads quickly for preview
  /// - Full loads automatically for best quality
  /// - No tap-to-load (auto-loads full resolution)
  ///
  /// Example:
  /// ```dart
  /// MultiStageImageLoader.hero(
  ///   thumbnailUrl: photo.thumbnailUrl,
  ///   mediumUrl: photo.mediumUrl,
  ///   fullUrl: photo.fullUrl,
  ///   width: double.infinity,
  ///   height: double.infinity,
  /// )
  /// ```
  static MultiStageImageLoader hero({
    Key? key,
    required String thumbnailUrl,
    required String mediumUrl,
    required String fullUrl,
    double width = double.infinity,
    double height = double.infinity,
    BoxFit fit = BoxFit.contain,
    BorderRadius? borderRadius,
    void Function(ImageLoadStage stage)? onStageChanged,
  }) {
    return MultiStageImageLoader(
      key: key,
      thumbnailUrl: thumbnailUrl,
      mediumUrl: mediumUrl,
      fullUrl: fullUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      loadFullOnTap: false, // Auto-loads full
      autoProgressToMedium: true,
      initialStage: ImageLoadStage.medium, // Start with medium
      onStageChanged: onStageChanged,
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}
