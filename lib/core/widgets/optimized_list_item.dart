import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A widget that wraps list items with [RepaintBoundary] for optimized rendering.
///
/// [RepaintBoundary] creates a separate layer for the wrapped widget, which prevents
/// the parent from needing to repaint when only this widget's content changes.
/// This is especially useful for complex list items that may repaint independently.
///
/// ## Performance Benefits
///
/// Wrapping list items with [RepaintBoundary] provides several performance benefits:
///
/// - **Isolates repaints**: When a single item changes, only that item repaints
/// - **Reduces paint complexity**: Complex items don't force parent repaints
/// - **Improves scrolling performance**: List can scroll while items repaint independently
/// - **Lowers GPU usage**: Fewer pixels need to be redrawn per frame
///
/// ## When to Use
///
/// Use [OptimizedListItem] for:
///
/// - List items with complex layouts (multiple children, images, etc.)
/// - Items that update independently from the list (e.g., live data)
/// - Lists with 50+ items where performance matters
/// - Items with frequent animations or visual changes
///
/// ## When NOT to Use
///
/// Avoid [OptimizedListItem] for:
///
/// - Very simple items (single text widget, etc.)
/// - Lists with fewer than 20 items
/// - Items that never change after initial render
/// - Deeply nested lists (may use too much memory for layers)
///
/// ## Memory Considerations
///
/// [RepaintBoundary] creates an additional layer, which consumes memory.
/// For most use cases this is negligible, but be mindful when using:
///
/// - Lists with 1000+ items all on screen simultaneously
/// - Very large items with complex content
/// - Low-memory devices
///
/// ## Example
///
/// ```dart
/// // Basic usage
/// OptimizedListItem(
///   child: ActivityCard(activity: activity),
/// )
///
/// // With enabled flag
/// OptimizedListItem(
///   enabled: !kDebugMode, // Disable in debug mode for easier debugging
///   child: ActivityCard(activity: activity),
/// )
///
/// // In a list builder
/// ListView.builder(
///   itemCount: activities.length,
///   itemBuilder: (context, index) {
///     return OptimizedListItem(
///       child: ActivityCard(activity: activities[index]),
///     );
///   },
/// )
/// ```
///
/// See also:
///
/// - [RepaintBoundary], which this widget wraps
/// - [VisibilityObserver], for visibility-based optimizations
class OptimizedListItem extends StatelessWidget {
  /// Whether to enable the repaint boundary optimization
  ///
  /// Set to `false` to disable the optimization. This is useful for:
  /// - Debugging layout issues
  /// - Temporarily disabling to compare performance
  /// - Conditional optimization based on device capabilities
  ///
  /// Defaults to `true` in release mode, `false` in debug mode for easier debugging.
  final bool enabled;

  /// The child widget to wrap with the repaint boundary
  ///
  /// This is typically a list item widget like a card, list tile, or custom widget.
  final Widget child;

  /// Optional key for the wrapped child widget
  ///
  /// If provided, this key will be applied to the child widget, not the
  /// [RepaintBoundary] itself.
  final Key? childKey;

  /// Creates an optimized list item with repaint boundary
  ///
  /// The [enabled] parameter controls whether the [RepaintBoundary] is applied.
  /// When disabled, the widget is returned as-is without wrapping.
  const OptimizedListItem({
    super.key,
    this.enabled = kReleaseMode,
    required this.child,
    this.childKey,
  });

  @override
  Widget build(BuildContext context) {
    // If optimization is disabled, return child directly
    if (!enabled) {
      return child;
    }

    // Wrap child with RepaintBoundary to isolate repaints
    return RepaintBoundary(
      child: childKey != null
          ? KeyedSubtree(
              key: childKey,
              child: child,
            )
          : child,
    );
  }

  /// Creates an optimized list item with automatic key management
  ///
  /// This constructor automatically generates a ValueKey based on the item's
  /// identity, which helps Flutter's widget matching algorithm.
  ///
  /// Example:
  /// ```dart
  /// OptimizedListItem.withKey(
  ///   item: activity,
  ///   child: ActivityCard(activity: activity),
  /// )
  /// ```
  factory OptimizedListItem.withKey({
    Key? key,
    required Object item,
    bool enabled = kReleaseMode,
    required Widget child,
  }) {
    return OptimizedListItem(
      key: key,
      enabled: enabled,
      childKey: ValueKey(item),
      child: child,
    );
  }
}

/// A widget that wraps list items with conditional repaint boundary based on complexity
///
/// This widget automatically determines whether to use [RepaintBoundary] based on
/// the estimated complexity of the child widget.
///
/// ## Complexity Estimation
///
/// The complexity is estimated based on:
///
/// - Number of direct children (more children = more complex)
/// - Presence of images (images are expensive to repaint)
/// - Presence of animations (animations cause frequent repaints)
/// - Custom complexity value provided by the caller
///
/// ## Example
///
/// ```dart
/// // Automatic complexity detection
/// AutoOptimizedListItem(
///   hasImages: true,
///   childCount: 5,
///   child: ActivityCard(activity: activity),
/// )
///
/// // With custom complexity
/// AutoOptimizedListItem(
///   complexityScore: 80, // High complexity
///   child: ComplexWidget(),
/// )
/// ```
class AutoOptimizedListItem extends StatelessWidget {
  /// The child widget to potentially wrap with a repaint boundary
  final Widget child;

  /// Estimated number of direct children in the widget
  final int? childCount;

  /// Whether the child contains images
  final bool hasImages;

  /// Whether the child contains animations
  final bool hasAnimations;

  /// Custom complexity score (0-100)
  ///
  /// If provided, this overrides automatic complexity detection.
  /// Values >= 50 will enable repaint boundary.
  final int? complexityScore;

  /// Custom threshold for enabling repaint boundary
  ///
  /// Defaults to 50. Lower values enable optimization for simpler widgets.
  final int threshold;

  /// Whether to enable the optimization at all
  final bool enabled;

  /// Creates an auto-optimized list item
  const AutoOptimizedListItem({
    super.key,
    required this.child,
    this.childCount,
    this.hasImages = false,
    this.hasAnimations = false,
    this.complexityScore,
    this.threshold = 50,
    this.enabled = kReleaseMode,
  });

  @override
  Widget build(BuildContext context) {
    // If optimization is disabled, return child directly
    if (!enabled) {
      return child;
    }

    // Calculate complexity score if not provided
    final score = complexityScore ?? _calculateComplexity();

    // Use RepaintBoundary if complexity exceeds threshold
    if (score >= threshold) {
      return RepaintBoundary(child: child);
    }

    return child;
  }

  /// Calculates complexity score based on widget characteristics
  int _calculateComplexity() {
    int score = 0;

    // Base score for existing
    score += 10;

    // Add score for each child (up to 50 points)
    if (childCount != null) {
      score += (childCount! * 5).clamp(0, 50);
    }

    // Add score for images (they're expensive to repaint)
    if (hasImages) {
      score += 30;
    }

    // Add score for animations (frequent repaints)
    if (hasAnimations) {
      score += 20;
    }

    return score.clamp(0, 100);
  }

  /// Creates an auto-optimized item optimized for cards with images
  ///
  /// This factory constructor is optimized for common list card patterns
  /// that include images, text, and actions.
  factory AutoOptimizedListItem.card({
    Key? key,
    required Widget child,
    int imageCount = 1,
    bool enabled = kReleaseMode,
  }) {
    return AutoOptimizedListItem(
      key: key,
      child: child,
      hasImages: imageCount > 0,
      childCount: 4, // Typical card: image, title, subtitle, actions
      enabled: enabled,
    );
  }

  /// Creates an auto-optimized item optimized for list tiles
  ///
  /// This factory constructor is optimized for ListTile-like widgets
  /// that typically have leading, title, subtitle, and trailing widgets.
  factory AutoOptimizedListItem.listTile({
    Key? key,
    required Widget child,
    bool hasLeading = true,
    bool hasTrailing = true,
    bool enabled = kReleaseMode,
  }) {
    return AutoOptimizedListItem(
      key: key,
      child: child,
      childCount: (hasLeading ? 1 : 0) + 2 + (hasTrailing ? 1 : 0),
      enabled: enabled,
    );
  }
}
