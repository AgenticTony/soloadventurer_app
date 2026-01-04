import 'package:flutter/material.dart';

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
/// - Configurable aspect ratio for grid items
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
/// ```
class VirtualGridView<T> extends StatelessWidget {
  /// The total number of items in the grid
  final int itemCount;

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

  /// Creates a generic virtual grid view with efficient rendering
  const VirtualGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.crossAxisCount,
    this.header,
    this.footer,
    this.emptyWidget,
    this.loadingWidget,
    this.errorWidget,
    this.isLoading = false,
    this.hasError = false,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 4.0,
    this.mainAxisSpacing = 4.0,
    this.padding,
    this.physics,
    this.controller,
    this.gridKey,
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
    final grid = _buildGrid();

    if (header == null && footer == null) {
      return grid;
    }

    // Wrap with header and footer if provided
    return CustomScrollView(
      controller: controller,
      physics: physics,
      slivers: [
        if (header != null)
          SliverToBoxAdapter(child: header!),
        grid,
        if (footer != null)
          SliverToBoxAdapter(child: footer!),
      ],
    );
  }

  /// Builds the appropriate grid widget based on configuration
  Widget _buildGrid() {
    // If using CustomScrollView, we need a SliverGrid
    if (header != null || footer != null) {
      return SliverGrid(
        gridDelegate: _buildGridDelegate(),
        delegate: _buildDelegate(),
      );
    }

    // Otherwise use a regular GridView.builder
    return GridView.builder(
      key: gridKey,
      controller: controller,
      physics: physics,
      padding: padding,
      gridDelegate: _buildGridDelegate(),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }

  /// Builds the sliver grid delegate
  SliverGridDelegate _buildGridDelegate() {
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
    int crossAxisCount = 3,
    EdgeInsets? padding,
    ScrollController? controller,
  }) {
    return VirtualGridView<T>(
      key: key,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      crossAxisCount: crossAxisCount,
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
    int crossAxisCount = 2,
    EdgeInsets? padding,
    ScrollController? controller,
  }) {
    return VirtualGridView<T>(
      key: key,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      crossAxisCount: crossAxisCount,
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
