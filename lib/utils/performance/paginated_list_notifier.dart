import 'package:flutter/foundation.dart';

/// Pagination configuration
class PaginationConfig {
  /// Number of items per page (default: 20)
  final int pageSize;

  /// Enable automatic pagination on scroll
  final bool enableAutoPagination;

  /// Number of items remaining to trigger next page load
  final int threshold;

  /// Initial page to load
  final int initialPage;

  const PaginationConfig({
    this.pageSize = 20,
    this.enableAutoPagination = true,
    this.threshold = 5,
    this.initialPage = 1,
  });

  /// Predefined configurations
  static const forSmallLists = PaginationConfig(
    pageSize: 10,
    enableAutoPagination: true,
    threshold: 3,
  );

  static const forMediumLists = PaginationConfig(
    pageSize: 20,
    enableAutoPagination: true,
    threshold: 5,
  );

  static const forLargeLists = PaginationConfig(
    pageSize: 50,
    enableAutoPagination: true,
    threshold: 10,
  );
}

/// Result of a paginated fetch
class PaginatedResult<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;

  const PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasMore,
  });

  factory PaginatedResult.empty() {
    return const PaginatedResult(
      items: [],
      currentPage: 1,
      totalPages: 0,
      totalItems: 0,
      hasMore: false,
    );
  }

  factory PaginatedResult.singlePage(List<T> items) {
    return PaginatedResult(
      items: items,
      currentPage: 1,
      totalPages: 1,
      totalItems: items.length,
      hasMore: false,
    );
  }

  PaginatedResult<T> copyWith({
    List<T>? items,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    bool? hasMore,
  }) {
    return PaginatedResult(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// State for paginated data
class PaginatedState<T> {
  final List<T> items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;
  final bool hasReachedMax;

  const PaginatedState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.hasMore = true,
    this.hasReachedMax = false,
  });

  PaginatedState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    bool? hasMore,
    bool? hasReachedMax,
  }) {
    return PaginatedState<T>(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      hasMore: hasMore ?? this.hasMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  bool get hasItems => items.isNotEmpty;
  bool get hasError => error != null;
  bool get isInitialLoading => isLoading && items.isEmpty;
  bool get isRefreshing => isLoading && items.isNotEmpty;
}

/// Base class for paginated notifiers
abstract class PaginatedNotifier<T> extends ChangeNotifier {
  final PaginationConfig config;

  PaginatedState<T> state = const PaginatedState();

  PaginatedNotifier(this.config);

  /// Fetch items for a specific page - must be implemented by subclasses
  Future<PaginatedResult<T>> fetchPage(int page, int pageSize);

  /// Load initial page
  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final result = await fetchPage(config.initialPage, config.pageSize);

      state = state.copyWith(
        items: result.items,
        isLoading: false,
        currentPage: result.currentPage,
        totalPages: result.totalPages,
        totalItems: result.totalItems,
        hasMore: result.hasMore,
        hasReachedMax: !result.hasMore,
      );
      notifyListeners();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      notifyListeners();
      rethrow;
    }
  }

  /// Load next page
  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore || state.hasReachedMax) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);
    notifyListeners();

    try {
      final nextPage = state.currentPage + 1;
      final result = await fetchPage(nextPage, config.pageSize);

      state = state.copyWith(
        items: [...state.items, ...result.items],
        isLoadingMore: false,
        currentPage: result.currentPage,
        totalPages: result.totalPages,
        totalItems: result.totalItems,
        hasMore: result.hasMore,
        hasReachedMax: !result.hasMore,
      );
      notifyListeners();
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  /// Refresh from first page
  Future<void> refresh() async {
    await loadInitial();
  }

  /// Retry last failed operation
  Future<void> retry() async {
    if (state.hasError && state.items.isEmpty) {
      await loadInitial();
    } else if (state.hasError && state.items.isNotEmpty) {
      await loadNextPage();
    }
  }

  /// Check if we should load more items based on index
  bool shouldLoadMore(int index) {
    if (!config.enableAutoPagination) return false;
    if (state.isLoadingMore || !state.hasMore) return false;

    final threshold = state.items.length - config.threshold;
    return index >= threshold;
  }

  /// Reset to initial state
  void reset() {
    state = const PaginatedState();
    notifyListeners();
  }

  /// Clear all data
  void clear() {
    state = state.copyWith(items: []);
    notifyListeners();
  }
}

/// Optimized list state with caching and pagination
class OptimizedListState<T> {
  final List<T> items;
  final Set<String> cachedIds;
  final Map<String, T> itemCache;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;

  const OptimizedListState({
    this.items = const [],
    this.cachedIds = const {},
    this.itemCache = const {},
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
  });

  OptimizedListState<T> copyWith({
    List<T>? items,
    Set<String>? cachedIds,
    Map<String, T>? itemCache,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return OptimizedListState<T>(
      items: items ?? this.items,
      cachedIds: cachedIds ?? this.cachedIds,
      itemCache: itemCache ?? this.itemCache,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  /// Check if item is cached
  bool isCached(String id) => cachedIds.contains(id);

  /// Get item from cache
  T? getCachedItem(String id) => itemCache[id];

  /// Get cache size
  int get cacheSize => itemCache.length;
}
