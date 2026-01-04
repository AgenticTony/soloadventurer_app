import 'package:flutter/material.dart';

/// A generic virtual list widget that optimizes rendering of large lists.
///
/// This widget wraps [ListView.builder] with virtual scrolling to efficiently
/// handle lists with 500+ items by only rendering visible items. It provides
/// a consistent API for all list views across the app and ensures optimal
/// performance for large datasets.
///
/// Features:
/// - Virtual scrolling for memory efficiency
/// - Configurable item extent for fixed-height items
/// - Optional separators between items
/// - Support for headers and footers
/// - Loading and error state handling
/// - Optional padding and physics customization
///
/// Example:
/// ```dart
/// VirtualListView<String>(
///   itemCount: names.length,
///   itemBuilder: (context, index) => ListTile(title: Text(names[index])),
/// )
///
/// // With separators
/// VirtualListView<Item>(
///   itemCount: items.length,
///   separatorBuilder: (context, index) => Divider(height: 1),
///   itemBuilder: (context, index) => ItemCard(item: items[index]),
/// )
/// ```
class VirtualListView<T> extends StatelessWidget {
  /// The total number of items in the list
  final int itemCount;

  /// Builds the widget for each item at the given index
  final NullableItemWidgetBuilder<T> itemBuilder;

  /// Optional separator builder between items
  final NullableItemWidgetBuilder<T>? separatorBuilder;

  /// Optional widget to display at the top of the list
  final Widget? header;

  /// Optional widget to display at the bottom of the list
  final Widget? footer;

  /// Optional widget to display when the list is empty
  final Widget? emptyWidget;

  /// Optional widget to display when loading
  final Widget? loadingWidget;

  /// Optional widget to display when there's an error
  final Widget? errorWidget;

  /// Whether the list is currently loading
  final bool isLoading;

  /// Whether the list has an error
  final bool hasError;

  /// The axis along which the list scrolls
  final Axis scrollDirection;

  /// Whether the list is reversed
  final bool reverse;

  /// Optional fixed extent for each item (improves performance)
  final double? itemExtent;

  /// Optional fixed extent for separators (improves performance)
  final double? separatorExtent;

  /// Padding around the list
  final EdgeInsets? padding;

  /// Custom scroll physics
  final ScrollPhysics? physics;

  /// Optional scroll controller
  final ScrollController? controller;

  /// Optional key for the list
  final Key? listKey;

  /// Creates a generic virtual list view with efficient rendering
  const VirtualListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorBuilder,
    this.header,
    this.footer,
    this.emptyWidget,
    this.loadingWidget,
    this.errorWidget,
    this.isLoading = false,
    this.hasError = false,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.itemExtent,
    this.separatorExtent,
    this.padding,
    this.physics,
    this.controller,
    this.listKey,
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

    // Show empty state if list is empty
    if (itemCount == 0 && emptyWidget != null) {
      return emptyWidget!;
    }

    // Build the list with optional header and footer
    final list = _buildList();

    if (header == null && footer == null) {
      return list;
    }

    // Wrap with header and footer if provided
    return CustomScrollView(
      controller: controller,
      physics: physics,
      scrollDirection: scrollDirection,
      reverse: reverse,
      slivers: [
        if (header != null)
          SliverToBoxAdapter(child: header!),
        list,
        if (footer != null)
          SliverToBoxAdapter(child: footer!),
      ],
    );
  }

  /// Builds the appropriate list widget based on configuration
  Widget _buildList() {
    // If using CustomScrollView, we need a SliverList
    if (header != null || footer != null) {
      return SliverList(
        delegate: _buildDelegate(),
      );
    }

    // Otherwise use a regular ListView.builder
    return ListView.builder(
      key: listKey,
      controller: controller,
      physics: physics,
      scrollDirection: scrollDirection,
      reverse: reverse,
      padding: padding,
      itemCount: _calculateItemCount(),
      itemExtent: itemExtent,
      itemBuilder: _buildItem,
    );
  }

  /// Builds the sliver delegate for CustomScrollView usage
  SliverChildDelegate _buildDelegate() {
    return SliverChildBuilderDelegate(
      _buildItem,
      childCount: _calculateItemCount(),
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
    );
  }

  /// Calculates the total number of items including separators
  int _calculateItemCount() {
    if (separatorBuilder == null) {
      return itemCount;
    }

    // For separators, we need itemCount + (itemCount - 1) for separators
    // But if itemCount is 0, we still return 0
    if (itemCount == 0) return 0;

    return itemCount + (itemCount - 1);
  }

  /// Builds an item or separator at the given index
  Widget _buildItem(BuildContext context, int index) {
    // If no separators, build the item directly
    if (separatorBuilder == null) {
      return itemBuilder(context, index);
    }

    // Calculate the actual item index (accounting for separators)
    final itemIndex = index ~/ 2;

    // If index is odd, it's a separator
    if (index.isOdd) {
      return separatorBuilder!(context, itemIndex);
    }

    // Otherwise, it's an item
    return itemBuilder(context, itemIndex);
  }
}

/// Extension on VirtualListView for common constructors
extension VirtualListViewExtensions on VirtualListView {
  /// Creates a vertical virtual list with default settings
  static VirtualListView<T> vertical<T>({
    Key? key,
    required int itemCount,
    required NullableItemWidgetBuilder<T> itemBuilder,
    NullableItemWidgetBuilder<T>? separatorBuilder,
    Widget? header,
    Widget? footer,
    Widget? emptyWidget,
    Widget? loadingWidget,
    Widget? errorWidget,
    bool isLoading = false,
    bool hasError = false,
    double? itemExtent,
    double? separatorExtent,
    EdgeInsets? padding,
    ScrollController? controller,
  }) {
    return VirtualListView<T>(
      key: key,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      separatorBuilder: separatorBuilder,
      header: header,
      footer: footer,
      emptyWidget: emptyWidget,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
      isLoading: isLoading,
      hasError: hasError,
      scrollDirection: Axis.vertical,
      itemExtent: itemExtent,
      separatorExtent: separatorExtent,
      padding: padding,
      controller: controller,
    );
  }

  /// Creates a horizontal virtual list with default settings
  static VirtualListView<T> horizontal<T>({
    Key? key,
    required int itemCount,
    required NullableItemWidgetBuilder<T> itemBuilder,
    NullableItemWidgetBuilder<T>? separatorBuilder,
    Widget? header,
    Widget? footer,
    Widget? emptyWidget,
    Widget? loadingWidget,
    Widget? errorWidget,
    bool isLoading = false,
    bool hasError = false,
    double? itemExtent,
    double? separatorExtent,
    EdgeInsets? padding,
    ScrollController? controller,
  }) {
    return VirtualListView<T>(
      key: key,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      separatorBuilder: separatorBuilder,
      header: header,
      footer: footer,
      emptyWidget: emptyWidget,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
      isLoading: isLoading,
      hasError: hasError,
      scrollDirection: Axis.horizontal,
      itemExtent: itemExtent,
      separatorExtent: separatorExtent,
      padding: padding,
      controller: controller,
    );
  }
}
