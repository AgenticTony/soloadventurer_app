import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'virtual_list_view.dart';

/// Cache for storing aspect ratios to avoid recalculating them
///
/// This cache improves performance for photo galleries by storing
/// aspect ratios that have already been calculated or retrieved.
class AspectRatioCache {
  final Map<String, double> _cache = {};

  /// Gets the aspect ratio from cache, or computes it if not cached
  double get(String key, double Function() compute) {
    return _cache.putIfAbsent(key, compute);
  }

  /// Pre-populates the cache with multiple aspect ratios
  void preload(Map<String, double> ratios) {
    _cache.addAll(ratios);
  }

  /// Clears all cached aspect ratios
  void clear() {
    _cache.clear();
  }

  /// Returns the number of cached aspect ratios
  int get length => _cache.length;

  /// Checks if an aspect ratio is cached
  bool containsKey(String key) => _cache.containsKey(key);
}

/// A custom grid delegate that supports variable aspect ratios per item
///
/// This delegate calculates the height of each grid item based on its
/// individual aspect ratio, allowing photo galleries to display images
/// at their correct proportions while maintaining a grid layout.
class _VariableAspectRatioDelegate extends SliverGridDelegate {
  /// The number of columns in the grid
  final int crossAxisCount;

  /// The spacing between columns
  final double crossAxisSpacing;

  /// The spacing between rows
  final double mainAxisSpacing;

  /// Function that returns the aspect ratio for each item
  final double Function(int index) getAspectRatio;

  /// Creates a variable aspect ratio grid delegate
  const _VariableAspectRatioDelegate({
    required this.crossAxisCount,
    required this.getAspectRatio,
    this.crossAxisSpacing = 0.0,
    this.mainAxisSpacing = 0.0,
  });

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    // Calculate the number of columns
    final int crossAxisCount = this.crossAxisCount;

    // Calculate the available cross-axis width for all columns
    final double crossAxisExtent = constraints.crossAxisExtent;
    final double usableCrossAxisExtent =
        crossAxisExtent - (crossAxisCount - 1) * crossAxisSpacing;
    final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;

    return _SliverGridGridLayoutWithVariableAspectRatio(
      crossAxisCount: crossAxisCount,
      childCrossAxisExtent: childCrossAxisExtent,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      getAspectRatio: getAspectRatio,
    );
  }

  @override
  bool shouldRelayout(_VariableAspectRatioDelegate oldDelegate) {
    return oldDelegate.crossAxisCount != crossAxisCount ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.getAspectRatio != getAspectRatio;
  }
}

/// Custom grid layout that supports variable aspect ratios per item
class _SliverGridGridLayoutWithVariableAspectRatio extends SliverGridLayout {
  final int crossAxisCount;
  final double childCrossAxisExtent;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double Function(int index) getAspectRatio;

  const _SliverGridGridLayoutWithVariableAspectRatio({
    required this.crossAxisCount,
    required this.childCrossAxisExtent,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.getAspectRatio,
  });

  double getMinScrollOffset(int childCount) {
    return 0.0;
  }

  @override
  double computeMaxScrollOffset(int childCount) {
    return getMaxScrollOffset(childCount);
  }

  double getMaxScrollOffset(int childCount) {
    if (childCount == 0) return 0.0;

    final int rowCount = (childCount + crossAxisCount - 1) ~/ crossAxisCount;
    double maxMainAxisExtent = 0.0;

    // Calculate the total height by summing up each row's height
    for (int row = 0; row < rowCount; row++) {
      double maxRowHeight = 0.0;

      // Find the tallest item in this row
      for (int col = 0; col < crossAxisCount; col++) {
        final int index = row * crossAxisCount + col;
        if (index < childCount) {
          final double aspectRatio = getAspectRatio(index);
          final double childHeight = childCrossAxisExtent / aspectRatio;
          maxRowHeight = math.max(maxRowHeight, childHeight);
        }
      }

      // Add row height plus spacing (except for the last row)
      maxMainAxisExtent += maxRowHeight;
      if (row < rowCount - 1) {
        maxMainAxisExtent += mainAxisSpacing;
      }
    }

    return maxMainAxisExtent;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final int row = index ~/ crossAxisCount;
    final int col = index % crossAxisCount;

    final double aspectRatio = getAspectRatio(index);
    final double childHeight = childCrossAxisExtent / aspectRatio;

    // Calculate the main-axis position (vertical position)
    double mainAxisOffset = 0.0;
    for (int r = 0; r < row; r++) {
      double maxRowHeight = 0.0;
      for (int c = 0; c < crossAxisCount; c++) {
        final int i = r * crossAxisCount + c;
        final double ar = getAspectRatio(i);
        final double h = childCrossAxisExtent / ar;
        maxRowHeight = math.max(maxRowHeight, h);
      }
      mainAxisOffset += maxRowHeight + mainAxisSpacing;
    }

    // Calculate cross-axis position (horizontal position)
    final double crossAxisOffset =
        col * (childCrossAxisExtent + crossAxisSpacing);

    return SliverGridGeometry(
      scrollOffset: mainAxisOffset,
      crossAxisOffset: crossAxisOffset,
      mainAxisExtent: childHeight,
      crossAxisExtent: childCrossAxisExtent,
    );
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    if (scrollOffset <= 0.0) return 0;

    double currentOffset = 0.0;
    int row = 0;

    // Iterate through rows until we find where the scroll offset falls
    // Use a maximum row limit to prevent infinite loops
    while (row < 10000) {
      double maxRowHeight = 0.0;

      // Calculate the height of this row
      for (int col = 0; col < crossAxisCount; col++) {
        final int i = row * crossAxisCount + col;
        final double ar = getAspectRatio(i);
        final double h = childCrossAxisExtent / ar;
        maxRowHeight = math.max(maxRowHeight, h);
      }

      // Check if this row contains the scroll offset
      if (currentOffset + maxRowHeight > scrollOffset) {
        return row * crossAxisCount;
      }

      currentOffset += maxRowHeight + mainAxisSpacing;
      row++;
    }

    // Fallback: if we've gone through many rows, return a reasonable estimate
    return 0;
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    if (scrollOffset <= 0.0) return 0;

    double currentOffset = 0.0;
    int row = 0;

    // Iterate through rows until we find where the scroll offset falls
    while (row < 10000) {
      double maxRowHeight = 0.0;

      // Calculate the height of this row
      for (int col = 0; col < crossAxisCount; col++) {
        final int i = row * crossAxisCount + col;
        final double ar = getAspectRatio(i);
        final double h = childCrossAxisExtent / ar;
        maxRowHeight = math.max(maxRowHeight, h);
      }

      // Check if this row contains the scroll offset
      if (currentOffset + maxRowHeight > scrollOffset) {
        return (row + 1) * crossAxisCount - 1;
      }

      currentOffset += maxRowHeight + mainAxisSpacing;
      row++;
    }

    // Fallback: return a reasonable upper estimate
    return (row + 1) * crossAxisCount;
  }
}

/// A generic virtual grid widget that optimizes rendering of large grids.
///
/// This widget wraps [GridView.builder] with virtual scrolling to efficiently
/// handle grids with 500+ items by only rendering visible items. It provides
/// a consistent API for all grid views across the app and ensures optimal
/// performance for large datasets.
///
/// Features:
/// - Virtual scrolling for memory efficiency
/// - Configurable cross-axis count (number of columns)
/// - Prototype item support for improved performance
/// - Configurable aspect ratio for grid items
/// - Per-item aspect ratio support for photo galleries
/// - Optional spacing between items
/// - Support for headers and footers
/// - Loading and error state handling
/// - Optional padding and physics customization
///
/// Example:
/// ```dart
/// VirtualGridView<String>(
///   itemCount: items.length,
///   crossAxisCount: 3,
///   itemBuilder: (context, index) => ImageCard(item: items[index]),
/// )
///
/// // With aspect ratio
/// VirtualGridView<Item>(
///   itemCount: items.length,
///   crossAxisCount: 2,
///   childAspectRatio: 1.0,
///   itemBuilder: (context, index) => PhotoCard(item: items[index]),
/// )
///
/// // With prototype item for improved performance
/// VirtualGridView<Item>(
///   itemCount: items.length,
///   crossAxisCount: 2,
///   prototypeItem: PhotoCard(item: items.first), // Measured once for all items
///   itemBuilder: (context, index) => PhotoCard(item: items[index]),
/// )
///
/// // With per-item aspect ratio for photos
/// VirtualGridView<Photo>(
///   itemCount: photos.length,
///   crossAxisCount: 3,
///   itemAspectRatioBuilder: (context, index, photo) => photo.aspectRatio,
///   itemBuilder: (context, index, photo) => PhotoGridItem(photo: photo),
/// )
/// ```
class VirtualGridView<T> extends StatelessWidget {
  /// The total number of items in the grid
  final int itemCount;

  /// Optional list of items (required for per-item aspect ratio support)
  ///
  /// This is only needed when using [itemAspectRatioBuilder] to provide
  /// access to the actual item data for calculating aspect ratios.
  final List<T>? items;

  /// Builds the widget for each item at the given index
  final NullableItemWidgetBuilder<T> itemBuilder;

  /// Optional widget to display at the top of the grid
  final Widget? header;

  /// Optional widget to display at the bottom of the grid
  final Widget? footer;

  /// Optional widget to display when the grid is empty
  final Widget? emptyWidget;

  /// Optional widget to display when loading
  final Widget? loadingWidget;

  /// Optional widget to display when there's an error
  final Widget? errorWidget;

  /// Whether the grid is currently loading
  final bool isLoading;

  /// Whether the grid has an error
  final bool hasError;

  /// The number of children in the cross axis
  final int crossAxisCount;

  /// Optional prototype item to estimate child extents (improves performance)
  final Widget? prototypeItem;

  /// The ratio of the cross-axis to the main-axis extent of each child
  final double childAspectRatio;

  /// The spacing between columns
  final double crossAxisSpacing;

  /// The spacing between rows
  final double mainAxisSpacing;

  /// Padding around the grid
  final EdgeInsets? padding;

  /// Custom scroll physics
  final ScrollPhysics? physics;

  /// Optional scroll controller
  final ScrollController? controller;

  /// Optional key for the grid
  final Key? gridKey;

  /// Optional builder for per-item aspect ratios
  ///
  /// If provided, each grid item can have its own aspect ratio.
  /// This is useful for photo galleries where photos have different dimensions.
  /// The builder should return the aspect ratio (width / height) for each item.
  ///
  /// For optimal performance, the aspect ratios should be cached or pre-calculated.
  /// When this is null, [childAspectRatio] is used for all items.
  final double Function(BuildContext context, int index, T item)?
      itemAspectRatioBuilder;

  /// Creates a generic virtual grid view with efficient rendering
  const VirtualGridView({
    super.key,
    required this.itemCount,
    this.items,
    required this.itemBuilder,
    required this.crossAxisCount,
    this.header,
    this.footer,
    this.emptyWidget,
    this.loadingWidget,
    this.errorWidget,
    this.isLoading = false,
    this.hasError = false,
    this.prototypeItem,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 4.0,
    this.mainAxisSpacing = 4.0,
    this.padding,
    this.physics,
    this.controller,
    this.gridKey,
    this.itemAspectRatioBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // Show loading state if provided
    if (isLoading && loadingWidget != null) {
      return loadingWidget!;
    }

    // Show error state if provided
    if (hasError && errorWidget != null) {
      return errorWidget!;
    }

    // Show empty state if grid is empty
    if (itemCount == 0 && emptyWidget != null) {
      return emptyWidget!;
    }

    // Build the grid with optional header and footer
    final grid = _buildGrid(context);

    if (header == null && footer == null) {
      return grid;
    }

    // Wrap with header and footer if provided
    return CustomScrollView(
      controller: controller,
      physics: physics,
      slivers: [
        if (header != null) SliverToBoxAdapter(child: header!),
        grid,
        if (footer != null) SliverToBoxAdapter(child: footer!),
      ],
    );
  }

  /// Builds the appropriate grid widget based on configuration
  Widget _buildGrid(BuildContext context) {
    // If using CustomScrollView, we need a SliverGrid
    if (header != null || footer != null) {
      return SliverGrid(
        gridDelegate: _buildGridDelegate(context),
        delegate: _buildDelegate(),
      );
    }

    // Otherwise use a regular GridView.builder
    return GridView.builder(
      key: gridKey,
      controller: controller,
      physics: physics,
      padding: padding,
      gridDelegate: _buildGridDelegate(context),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }

  /// Builds the sliver grid delegate
  SliverGridDelegate _buildGridDelegate(BuildContext context) {
    // If per-item aspect ratio builder is provided, use custom delegate
    if (itemAspectRatioBuilder != null) {
      if (items == null) {
        throw ArgumentError(
          'items must be provided when using itemAspectRatioBuilder',
        );
      }
      return _VariableAspectRatioDelegate(
        crossAxisCount: crossAxisCount,
        getAspectRatio: (index) {
          if (index >= items!.length) return childAspectRatio;
          return itemAspectRatioBuilder!(context, index, items![index]);
        },
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      );
    }

    // Otherwise use standard fixed cross axis count delegate
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
    );
  }

  /// Builds the sliver delegate for CustomScrollView usage
  SliverChildDelegate _buildDelegate() {
    return SliverChildBuilderDelegate(
      itemBuilder,
      childCount: itemCount,
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
    );
  }
}

/// Extension on VirtualGridView for common constructors
extension VirtualGridViewExtensions on VirtualGridView {
  /// Creates a photo grid with optimized settings
  static VirtualGridView<T> photoGrid<T>({
    Key? key,
    required int itemCount,
    required NullableItemWidgetBuilder<T> itemBuilder,
    Widget? header,
    Widget? footer,
    Widget? emptyWidget,
    Widget? loadingWidget,
    Widget? errorWidget,
    bool isLoading = false,
    bool hasError = false,
    Widget? prototypeItem,
    int crossAxisCount = 3,
    EdgeInsets? padding,
    ScrollController? controller,
  }) {
    return VirtualGridView<T>(
      key: key,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      crossAxisCount: crossAxisCount,
      prototypeItem: prototypeItem,
      childAspectRatio: 1.0, // Square photos
      crossAxisSpacing: 2.0,
      mainAxisSpacing: 2.0,
      header: header,
      footer: footer,
      emptyWidget: emptyWidget,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
      isLoading: isLoading,
      hasError: hasError,
      padding: padding,
      controller: controller,
    );
  }

  /// Creates a card grid with wider aspect ratio
  static VirtualGridView<T> cardGrid<T>({
    Key? key,
    required int itemCount,
    required NullableItemWidgetBuilder<T> itemBuilder,
    Widget? header,
    Widget? footer,
    Widget? emptyWidget,
    Widget? loadingWidget,
    Widget? errorWidget,
    bool isLoading = false,
    bool hasError = false,
    Widget? prototypeItem,
    int crossAxisCount = 2,
    EdgeInsets? padding,
    ScrollController? controller,
  }) {
    return VirtualGridView<T>(
      key: key,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      crossAxisCount: crossAxisCount,
      prototypeItem: prototypeItem,
      childAspectRatio: 1.2, // Slightly wider cards
      crossAxisSpacing: 8.0,
      mainAxisSpacing: 8.0,
      header: header,
      footer: footer,
      emptyWidget: emptyWidget,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
      isLoading: isLoading,
      hasError: hasError,
      padding: padding,
      controller: controller,
    );
  }
}
