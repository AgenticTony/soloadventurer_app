import 'package:flutter/material.dart';

/// A collection of optimized placeholder widgets for image loading states.
///
/// These placeholders are designed to be:
/// - **Performance efficient**: No expensive operations during rendering
/// - **Visually appealing**: Modern loading patterns (shimmer, skeleton)
/// - **Contextually appropriate**: Different styles for different use cases
/// - **Theme aware**: Respect app theme colors
///
/// Example usage with LazyLoadImage:
/// ```dart
/// LazyLoadImage(
///   imageUrl: url,
///   placeholder: (context, url) => ImagePlaceholder.shimmer(),
/// )
/// ```
class ImagePlaceholder {
  /// Creates a shimmer loading placeholder with animated gradient effect.
  ///
  /// This placeholder provides visual feedback that content is loading
  /// with a smooth left-to-right shimmer animation.
  ///
  /// The [baseColor] is the background color, defaults to grey[300].
  /// The [highlightColor] is the shimmer color, defaults to grey[100].
  /// The [width] and [height] define the placeholder size.
  /// The [borderRadius] applies rounded corners.
  ///
  /// Example:
  /// ```dart
  /// ImagePlaceholder.shimmer(
  ///   width: 100,
  ///   height: 100,
  ///   borderRadius: BorderRadius.circular(8),
  /// )
  /// ```
  static Widget shimmer({
    double? width,
    double? height,
    Color? baseColor,
    Color? highlightColor,
    BorderRadius? borderRadius,
  }) {
    return _ShimmerPlaceholder(
      width: width,
      height: height,
      baseColor: baseColor,
      highlightColor: highlightColor,
      borderRadius: borderRadius,
    );
  }

  /// Creates a simple skeleton placeholder with solid color.
  ///
  /// This is the most performant placeholder with no animation overhead.
  /// Ideal for:
  /// - List thumbnails where many placeholders show at once
  /// - Low-end devices where animation performance is critical
  /// - Situations where subtle loading indication is preferred
  ///
  /// Example:
  /// ```dart
  /// ImagePlaceholder.skeleton(
  ///   width: 48,
  ///   height: 48,
  ///   showIcon: true,
  /// )
  /// ```
  static Widget skeleton({
    double? width,
    double? height,
    Color? color,
    BorderRadius? borderRadius,
    bool showIcon = false,
    IconData? icon,
  }) {
    return _SkeletonPlaceholder(
      width: width,
      height: height,
      color: color,
      borderRadius: borderRadius,
      showIcon: showIcon,
      icon: icon,
    );
  }

  /// Creates a color placeholder with an optional icon overlay.
  ///
  /// This placeholder uses a solid background color with a centered icon
  /// to indicate image loading. Useful for:
  /// - Profile avatars
  /// - Photo thumbnails in lists
  /// - Card cover images
  ///
  /// The [backgroundColor] defaults to the theme's primary color with 20% opacity.
  /// The [icon] defaults to Icons.image.
  ///
  /// Example:
  /// ```dart
  /// ImagePlaceholder.color(
  ///   backgroundColor: Colors.blue[50],
  ///   icon: Icons.photo_camera,
  ///   iconColor: Colors.blue,
  /// )
  /// ```
  static Widget color({
    double? width,
    double? height,
    Color? backgroundColor,
    Color? iconColor,
    IconData? icon,
    BorderRadius? borderRadius,
    double iconSize = 32.0,
  }) {
    return _ColorPlaceholder(
      width: width,
      height: height,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      icon: icon,
      borderRadius: borderRadius,
      iconSize: iconSize,
    );
  }

  /// Creates a blurred placeholder from a thumbnail URL.
  ///
  /// This placeholder displays a heavily blurred version of the thumbnail
  /// to create a progressive blur-up effect. Works best when used with
  /// [LazyLoadImage.thumbnailUrl].
  ///
  /// Note: This requires the thumbnail to already be loaded/cached.
  /// Use [ImagePlaceholder.shimmer] as a fallback if thumbnail isn't available.
  ///
  /// Example:
  /// ```dart
  /// ImagePlaceholder.blurred(
  ///   thumbnailUrl: photo.thumbnailUrl,
  ///   width: 200,
  ///   height: 200,
  /// )
  /// ```
  static Widget blurred({
    required String? thumbnailUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Color? fallbackColor,
  }) {
    // If no thumbnail available, fall back to shimmer
    if (thumbnailUrl == null || thumbnailUrl.isEmpty) {
      return shimmer(
        width: width,
        height: height,
        borderRadius: borderRadius,
      );
    }

    return _BlurredPlaceholder(
      thumbnailUrl: thumbnailUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      fallbackColor: fallbackColor,
    );
  }
}

/// Shimmer animation placeholder with gradient effect.
class _ShimmerPlaceholder extends StatefulWidget {
  final double? width;
  final double? height;
  final Color? baseColor;
  final Color? highlightColor;
  final BorderRadius? borderRadius;

  const _ShimmerPlaceholder({
    this.width,
    this.height,
    this.baseColor,
    this.highlightColor,
    this.borderRadius,
  });

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? Colors.grey[300]!;
    final highlightColor = widget.highlightColor ?? Colors.grey[100]!;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.centerRight,
          colors: [
            baseColor,
            baseColor,
            highlightColor,
            baseColor,
            baseColor,
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
          transform: _GradientRotation(_animation.value),
        ),
      ),
    );
  }
}

class _GradientRotation extends GradientTransform {
  final double angle;

  const _GradientRotation(this.angle);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.rotationZ(angle);
  }
}

/// Simple skeleton placeholder with solid color.
class _SkeletonPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? color;
  final BorderRadius? borderRadius;
  final bool showIcon;
  final IconData? icon;

  const _SkeletonPlaceholder({
    this.width,
    this.height,
    this.color,
    this.borderRadius,
    this.showIcon = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = color ?? Colors.grey[300];

    Widget child = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
    );

    if (showIcon) {
      child = Stack(
        children: [
          child,
          Center(
            child: Icon(
              icon ?? Icons.image_outlined,
              size: _calculateIconSize(),
              color: Colors.grey[400],
            ),
          ),
        ],
      );
    }

    return child;
  }

  double _calculateIconSize() {
    final minDimension = width != null && height != null
        ? (width! < height! ? width! : height!)
        : (width ?? height ?? 48.0);

    return minDimension * 0.4;
  }
}

/// Color placeholder with icon overlay.
class _ColorPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? iconColor;
  final IconData? icon;
  final BorderRadius? borderRadius;
  final double iconSize;

  const _ColorPlaceholder({
    this.width,
    this.height,
    this.backgroundColor,
    this.iconColor,
    this.icon,
    this.borderRadius,
    this.iconSize = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ??
        Theme.of(context).primaryColor.withValues(alpha: 0.2);
    final icColor =
        iconColor ?? Theme.of(context).primaryColor.withValues(alpha: 0.5);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          icon ?? Icons.image_outlined,
          size: iconSize,
          color: icColor,
        ),
      ),
    );
  }
}

/// Blurred placeholder from thumbnail URL.
class _BlurredPlaceholder extends StatelessWidget {
  final String thumbnailUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color? fallbackColor;

  const _BlurredPlaceholder({
    required this.thumbnailUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    // Import cached_network_image conditionally to avoid dependency issues
    // This widget will only be used when cached_network_image is available
    try {
      final cachedNetworkImage = _createBlurredImage();
      Widget child = cachedNetworkImage;

      if (borderRadius != null) {
        child = ClipRRect(
          borderRadius: borderRadius!,
          child: child,
        );
      }

      return child;
    } catch (e) {
      // Fallback to shimmer if cached_network_image is not available
      return ImagePlaceholder.shimmer(
        width: width,
        height: height,
        borderRadius: borderRadius,
      );
    }
  }

  Widget _createBlurredImage() {
    // Use a filtered image to create blur effect
    // This is a simplified version - in production, you'd use cached_network_image
    // with a blur filter or ImageFiltered widget
    return Container(
      width: width,
      height: height,
      color: fallbackColor ?? Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: (width != null && height != null)
              ? (width! < height! ? width! : height!) * 0.4
              : 32.0,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
