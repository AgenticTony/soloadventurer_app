import 'package:flutter/material.dart';
import '../models/paginated_data.dart';
import '../utils/preloading_strategy.dart';
import 'virtual_list_view.dart';

/// Pagination state for the infinite scroll list
enum InfiniteScrollStatus {
  /// Initial loading state (first page)
  initialLoading,

  /// Successfully loaded data
  loaded,

  /// Loading next page
  loadingMore,

  /// Error loading data
  error,

  /// Reached end of data (no more pages)
  reachedEnd,
}

/// State model for infinite scroll pagination
class InfiniteScrollState<T> {
  /// List of all loaded items
  final List<T> items;

  /// Current pagination status
  final InfiniteScrollStatus status;

  /// Current page info (null if not loaded yet)
  final PageInfo? pageInfo;

  /// Error message (null if no error)
  final String? errorMessage;

  /// Whether there are more items to load
  bool get hasNextPage => pageInfo?.hasNextPage ?? false;

  /// Whether this is the first page
  bool get isFirstPage => pageInfo?.isFirstPage ?? true;

  /// Total items loaded so far
  int get loadedItemCount => items.length;

  /// Whether the list is currently loading (initial or more)
  bool get isLoading =>
      status == InfiniteScrollStatus.initialLoading ||
      status == InfiniteScrollStatus.loadingMore;

  /// Creates a new infinite scroll state
  const InfiniteScrollState({
    this.items = const [],
    this.status = InfiniteScrollStatus.initialLoading,
    this.pageInfo,
    this.errorMessage,
  });

  /// Creates a copy with modified fields
  InfiniteScrollState<T> copyWith({
    List<T>? items,
    InfiniteScrollStatus? status,
    PageInfo? pageInfo,
    String? errorMessage,
  }) {
    return InfiniteScrollState<T>(
      items: items ?? this.items,
      status: status ?? this.status,
      pageInfo: pageInfo ?? this.pageInfo,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'InfiniteScrollState('
        'itemCount: ${items.length}, '
        'status: $status, '
        'hasNextPage: $hasNextPage, '
        'errorMessage: $errorMessage)';
  }
}

/// Function signature for fetching paginated data
typedef PaginatedDataFetcher<T> = Future<PaginatedData<T>> Function(
  String? cursor,
);

/// A generic infinite scroll list widget that automatically loads more data
/// as the user scrolls towards the end.
///
/// This widget combines [VirtualListView] for efficient rendering with
/// automatic pagination logic, providing a complete solution for large
/// datasets (500+ items).
///
/// Features:
/// - Automatic loading when scrolling near the end
/// - Pull-to-refresh support
/// - Loading and error states
/// - Configurable preload threshold (load before reaching end)
/// - Support for cursor-based and offset-based pagination
/// - Efficient virtual scrolling for memory management
/// - Retry functionality on errors
/// - Optional header and footer widgets
///
/// Example:
/// ```dart
/// InfiniteScrollListView<Trip>(
///   fetchData: (cursor) async {
///     return await tripRepository.getTripsCursor(
///       userId: 'user123',
///       cursor: cursor,
///       pageSize: 20,
///     );
///   },
///   itemBuilder: (context, trip) => TripCard(trip: trip),
/// )
/// ```
class InfiniteScrollListView<T> extends StatefulWidget {
  /// Function to fetch paginated data
  final PaginatedDataFetcher<T> fetchData;

  /// Builds the widget for each item
  final ItemWidgetBuilder<T> itemBuilder;

  /// Optional separator builder between items
  final NullableItemWidgetBuilder<T>? separatorBuilder;

  /// Optional widget to display at the top of the list
  final Widget? header;

  /// Optional widget to display at the bottom of the list
  final Widget? footer;

  /// Optional widget to display when the list is empty
  final Widget? emptyWidget;

  /// Optional custom widget for initial loading state
  final Widget? initialLoadingWidget;

  /// Optional custom widget for loading more indicator
  final Widget? loadingMoreWidget;

  /// Optional custom widget for error state
  final Widget? errorWidget;

  /// Optional custom widget for "end of list" indicator
  final Widget? endOfListWidget;

  /// Whether to enable pull-to-refresh
  final bool enablePullToRefresh;

  /// Distance from end (in pixels) to trigger loading next page
  /// Default: 500px (loads before user reaches end)
  /// Note: This is only used if [preloadConfig] is null
  final double preloadThreshold;

  /// Configuration for intelligent preloading
  /// If provided, overrides [preloadThreshold] and uses advanced strategies
  final PreloadConfig? preloadConfig;

  /// Callback when preload metrics are updated
  final void Function(PreloadMetrics)? onPreloadMetricsUpdated;

  /// The axis along which the list scrolls
  final Axis scrollDirection;

  /// Padding around the list
  final EdgeInsets? padding;

  /// Optional scroll controller
  final ScrollController? controller;

  /// Optional key for the widget
  final Key? key;

  const InfiniteScrollListView({
    this.key,
    required this.fetchData,
    required this.itemBuilder,
    this.separatorBuilder,
    this.header,
    this.footer,
    this.emptyWidget,
    this.initialLoadingWidget,
    this.loadingMoreWidget,
    this.errorWidget,
    this.endOfListWidget,
    this.enablePullToRefresh = true,
    this.preloadThreshold = 500.0,
    this.preloadConfig,
    this.onPreloadMetricsUpdated,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.controller,
  }) : super(key: key);

  @override
  State<InfiniteScrollListView<T>> createState() =>
      _InfiniteScrollListViewState<T>();
}

class _InfiniteScrollListViewState<T> extends State<InfiniteScrollListView<T>> {
  late ScrollController _scrollController;
  InfiniteScrollState<T> _state = const InfiniteScrollState();
  bool _isLoadingNextPage = false;
  late PreloadingManager _preloadingManager;
  DateTime? _lastScrollUpdate;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
    _preloadingManager = PreloadingManager(
      config: widget.preloadConfig ?? PreloadConfig.defaultConfig,
    );
    _loadInitialData();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  /// Loads the first page of data
  Future<void> _loadInitialData() async {
    if (_state.status == InfiniteScrollStatus.initialLoading) {
      setState(() {
        _state = _state.copyWith(
          status: InfiniteScrollStatus.initialLoading,
          items: [],
          pageInfo: null,
          errorMessage: null,
        );
      });
    }

    try {
      final pageData = await widget.fetchData(null);

      if (!mounted) return;

      setState(() {
        _state = _state.copyWith(
          items: pageData.items,
          pageInfo: pageData.pageInfo,
          status: pageData.items.isEmpty
              ? InfiniteScrollStatus.reachedEnd
              : InfiniteScrollStatus.loaded,
          errorMessage: null,
        );
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _state = _state.copyWith(
          status: InfiniteScrollStatus.error,
          errorMessage: e.toString(),
        );
      });
    }
  }

  /// Loads the next page of data
  Future<void> _loadNextPage() async {
    // Guard against multiple simultaneous loads
    if (_isLoadingNextPage) return;
    if (!_state.hasNextPage) return;
    if (_state.isLoading) return;

    final startTime = DateTime.now();
    setState(() {
      _state = _state.copyWith(status: InfiniteScrollStatus.loadingMore);
      _isLoadingNextPage = true;
    });

    try {
      final cursor = _state.pageInfo?.nextCursor;
      final pageData = await widget.fetchData(cursor);

      if (!mounted) return;

      // Calculate load time
      final loadTimeMs =
          DateTime.now().difference(startTime).inMilliseconds;

      // Record successful load
      if (widget.preloadConfig != null) {
        _preloadingManager.recordSuccessfulLoad(loadTimeMs);
        widget.onPreloadMetricsUpdated?.call(_preloadingManager.metrics);
      }

      setState(() {
        _state = _state.copyWith(
          items: [..._state.items, ...pageData.items],
          pageInfo: pageData.pageInfo,
          status: pageData.hasNextPage
              ? InfiniteScrollStatus.loaded
              : InfiniteScrollStatus.reachedEnd,
          errorMessage: null,
        );
        _isLoadingNextPage = false;
      });
    } catch (e) {
      if (!mounted) return;

      // Record failed load
      if (widget.preloadConfig != null) {
        _preloadingManager.recordFailedLoad();
        widget.onPreloadMetricsUpdated?.call(_preloadingManager.metrics);
      }

      setState(() {
        _state = _state.copyWith(
          status: InfiniteScrollStatus.error,
          errorMessage: e.toString(),
        );
        _isLoadingNextPage = false;
      });
    }
  }

  /// Handles scroll events to trigger pagination
  void _onScroll() {
    if (!_state.hasNextPage) return;
    if (_state.isLoading) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Calculate velocity
    if (_lastScrollUpdate != null) {
      final timeDiff = DateTime.now().difference(_lastScrollUpdate!);
      if (timeDiff.inMicroseconds > 0) {
        final velocity = (timeDiff.inMicroseconds > 0)
            ? (_scrollController.position.pixels - currentScroll) /
                timeDiff.inMicroseconds * 1000000
            : 0.0;

        // Update velocity in preloading manager
        if (widget.preloadConfig != null) {
          _preloadingManager.updateVelocity(velocity.abs());
        }
      }
    }
    _lastScrollUpdate = DateTime.now();

    // Use intelligent preloading if configured
    if (widget.preloadConfig != null) {
      if (_preloadingManager.shouldPreload(maxScroll, currentScroll)) {
        _preloadingManager.markPreloadTriggered();
        _loadNextPage();
      }
    } else {
      // Fallback to simple threshold-based preloading
      if (maxScroll - currentScroll <= widget.preloadThreshold) {
        _loadNextPage();
      }
    }
  }

  /// Handles pull-to-refresh
  Future<void> _onRefresh() async {
    // Reset preloading manager on refresh
    if (widget.preloadConfig != null) {
      _preloadingManager.reset();
    }
    await _loadInitialData();
  }

  /// Retries loading the next page after an error
  void _retry() {
    if (_state.items.isEmpty) {
      _loadInitialData();
    } else {
      _loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show initial loading state
    if (_state.status == InfiniteScrollStatus.initialLoading) {
      return widget.initialLoadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    // Show error state
    if (_state.status == InfiniteScrollStatus.error) {
      return widget.errorWidget ??
          _buildDefaultErrorWidget();
    }

    // Build the list with pull-to-refresh wrapper
    final list = VirtualListView<T>(
      itemCount: _state.loadedItemCount,
      itemBuilder: (context, index) {
        return widget.itemBuilder(context, _state.items[index]);
      },
      separatorBuilder: widget.separatorBuilder,
      header: widget.header,
      footer: _buildFooter(),
      padding: widget.padding,
      controller: _scrollController,
      scrollDirection: widget.scrollDirection,
      emptyWidget: widget.emptyWidget,
    );

    if (!widget.enablePullToRefresh) {
      return list;
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: list,
    );
  }

  /// Builds the footer widget (loading more or end of list)
  Widget? _buildFooter() {
    // If there's a custom footer, show it
    if (widget.footer != null) {
      return widget.footer;
    }

    // Show loading more indicator
    if (_state.status == InfiniteScrollStatus.loadingMore) {
      return widget.loadingMoreWidget ??
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
    }

    // Show end of list indicator
    if (_state.status == InfiniteScrollStatus.reachedEnd &&
        _state.items.isNotEmpty) {
      return widget.endOfListWidget ??
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'You\'ve reached the end',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
    }

    return null;
  }

  /// Builds the default error widget
  Widget _buildDefaultErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _state.errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _retry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension on InfiniteScrollListView for convenience constructors
extension InfiniteScrollListViewExtensions on InfiniteScrollListView {
  /// Creates an infinite scroll list with default settings
  static InfiniteScrollListView<T> withDefaults<T>({
    Key? key,
    required PaginatedDataFetcher<T> fetchData,
    required ItemWidgetBuilder<T> itemBuilder,
    NullableItemWidgetBuilder<T>? separatorBuilder,
    Widget? header,
    Widget? footer,
    Widget? emptyWidget,
    Widget? initialLoadingWidget,
    Widget? loadingMoreWidget,
    Widget? errorWidget,
    Widget? endOfListWidget,
    bool enablePullToRefresh = true,
    double preloadThreshold = 500.0,
    PreloadConfig? preloadConfig,
    void Function(PreloadMetrics)? onPreloadMetricsUpdated,
    EdgeInsets? padding,
    ScrollController? controller,
  }) {
    return InfiniteScrollListView<T>(
      key: key,
      fetchData: fetchData,
      itemBuilder: itemBuilder,
      separatorBuilder: separatorBuilder,
      header: header,
      footer: footer,
      emptyWidget: emptyWidget,
      initialLoadingWidget: initialLoadingWidget,
      loadingMoreWidget: loadingMoreWidget,
      errorWidget: errorWidget,
      endOfListWidget: endOfListWidget,
      enablePullToRefresh: enablePullToRefresh,
      preloadThreshold: preloadThreshold,
      preloadConfig: preloadConfig,
      onPreloadMetricsUpdated: onPreloadMetricsUpdated,
      padding: padding,
      controller: controller,
    );
  }

  /// Creates an infinite scroll list with separators
  static InfiniteScrollListView<T> withSeparators<T>({
    Key? key,
    required PaginatedDataFetcher<T> fetchData,
    required ItemWidgetBuilder<T> itemBuilder,
    NullableItemWidgetBuilder<T>? separatorBuilder,
    Widget? header,
    Widget? footer,
    Widget? emptyWidget,
    bool enablePullToRefresh = true,
    double preloadThreshold = 500.0,
    PreloadConfig? preloadConfig,
    void Function(PreloadMetrics)? onPreloadMetricsUpdated,
    EdgeInsets? padding,
    ScrollController? controller,
  }) {
    return InfiniteScrollListView<T>(
      key: key,
      fetchData: fetchData,
      itemBuilder: itemBuilder,
      separatorBuilder: separatorBuilder ??
          (context, index) => const Divider(height: 1),
      header: header,
      footer: footer,
      emptyWidget: emptyWidget,
      enablePullToRefresh: enablePullToRefresh,
      preloadThreshold: preloadThreshold,
      preloadConfig: preloadConfig,
      onPreloadMetricsUpdated: onPreloadMetricsUpdated,
      padding: padding,
      controller: controller,
    );
  }

  /// Creates an infinite scroll list with intelligent preloading
  static InfiniteScrollListView<T> withIntelligentPreloading<T>({
    Key? key,
    required PaginatedDataFetcher<T> fetchData,
    required ItemWidgetBuilder<T> itemBuilder,
    NullableItemWidgetBuilder<T>? separatorBuilder,
    Widget? header,
    Widget? footer,
    Widget? emptyWidget,
    PreloadConfig preloadConfig = PreloadConfig.defaultConfig,
    void Function(PreloadMetrics)? onPreloadMetricsUpdated,
    bool enablePullToRefresh = true,
    EdgeInsets? padding,
    ScrollController? controller,
  }) {
    return InfiniteScrollListView<T>(
      key: key,
      fetchData: fetchData,
      itemBuilder: itemBuilder,
      separatorBuilder: separatorBuilder,
      header: header,
      footer: footer,
      emptyWidget: emptyWidget,
      enablePullToRefresh: enablePullToRefresh,
      preloadConfig: preloadConfig,
      onPreloadMetricsUpdated: onPreloadMetricsUpdated,
      padding: padding,
      controller: controller,
    );
  }
}
