import '../models/paginated_data.dart';
import '../models/page_info.dart';

/// Mixin providing common pagination functionality for repositories
///
/// This mixin provides reusable methods for cursor-based and offset-based
/// pagination. It can be used with any repository class to add pagination
/// capabilities.
///
/// Example usage:
/// ```dart
/// class TripRepository with PaginatedRepositoryMixin {
///   @override
///   Future<PaginatedData<Trip>> getPaginatedTrips(PaginationParams params) async {
///     // Implementation
///   }
/// }
/// ```
mixin PaginatedRepositoryMixin {
  /// Default page size for pagination queries
  static const int defaultPageSize = 20;

  /// Maximum page size to prevent excessive data loading
  static const int maxPageSize = 100;

  /// Validates and adjusts page size to be within acceptable bounds
  ///
  /// Returns [pageSize] if it's within bounds, otherwise returns
  /// [defaultPageSize] or [maxPageSize] as appropriate.
  int validatePageSize(int? pageSize) {
    if (pageSize == null || pageSize <= 0) {
      return defaultPageSize;
    }
    if (pageSize > maxPageSize) {
      return maxPageSize;
    }
    return pageSize;
  }

  /// Creates PageInfo for a paginated response (cursor-based)
  ///
  /// Parameters:
  /// - [currentCursor]: The cursor used for this page
  /// - [pageSize]: Number of items per page
  /// - [itemsCount]: Actual number of items returned
  /// - [hasNextPage]: Whether there are more items after this page
  /// - [nextCursor]: Cursor for the next page (null if no more pages)
  /// - [previousCursor]: Cursor for the previous page (null if first page)
  PageInfo createCursorPageInfo({
    required String? currentCursor,
    required int pageSize,
    required int itemsCount,
    required bool hasNextPage,
    String? nextCursor,
    String? previousCursor,
  }) {
    return PageInfo(
      currentPage: _calculatePageNumber(currentCursor),
      itemsPerPage: pageSize,
      totalItems: null, // Unknown for cursor-based
      totalPages: null, // Unknown for cursor-based
      hasNextPage: hasNextPage,
      hasPreviousPage: previousCursor != null,
      nextCursor: nextCursor,
      previousCursor: previousCursor,
    );
  }

  /// Creates PageInfo for a paginated response (offset-based)
  ///
  /// Parameters:
  /// - [currentPage]: Current page number (1-based)
  /// - [pageSize]: Number of items per page
  /// - [totalItems]: Total number of items across all pages
  /// - [itemsCount]: Actual number of items returned this page
  PageInfo createOffsetPageInfo({
    required int currentPage,
    required int pageSize,
    required int totalItems,
    required int itemsCount,
  }) {
    final totalPages = (totalItems / pageSize).ceil();

    return PageInfo(
      currentPage: currentPage,
      itemsPerPage: pageSize,
      totalItems: totalItems,
      totalPages: totalPages,
      hasNextPage: currentPage < totalPages,
      hasPreviousPage: currentPage > 1,
      nextCursor: null, // Not used for offset-based
      previousCursor: null, // Not used for offset-based
    );
  }

  /// Generates a simple cursor from an offset
  ///
  /// This is a basic implementation. In production, you should use
  /// encoded cursor strings containing timestamp or ID information.
  String generateOffsetCursor(int offset) {
    return 'offset_$offset';
  }

  /// Parses an offset from a cursor string
  ///
  /// Returns null if the cursor is invalid or not an offset cursor.
  int? parseOffsetCursor(String? cursor) {
    if (cursor == null || !cursor.startsWith('offset_')) {
      return null;
    }
    final offsetStr = cursor.substring('offset_'.length);
    return int.tryParse(offsetStr);
  }

  /// Calculates page number from a cursor
  ///
  /// Returns 1 for null cursor (first page)
  int _calculatePageNumber(String? cursor) {
    final offset = parseOffsetCursor(cursor);
    if (offset == null || offset == 0) {
      return 1;
    }
    // Page number is offset / pageSize + 1, but we don't have pageSize here
    // This is a simplified calculation
    return (offset ~/ defaultPageSize) + 1;
  }

  /// Creates empty PaginatedData for a given type
  PaginatedData<T> createEmptyPaginatedData<T>() {
    return PaginatedData<T>.empty();
  }

  /// Creates PaginatedData from items and PageInfo
  PaginatedData<T> createPaginatedData<T>({
    required List<T> items,
    required PageInfo pageInfo,
  }) {
    return PaginatedData<T>(
      items: items,
      pageInfo: pageInfo,
    );
  }
}

/// Parameters for pagination queries
class PaginationParams {
  /// Page size (number of items per page)
  final int pageSize;

  /// Cursor for cursor-based pagination (null for first page)
  final String? cursor;

  /// Page number for offset-based pagination (1-based)
  final int? page;

  /// Sort field (e.g., 'createdAt', 'title')
  final String? sortBy;

  /// Sort order (ascending or descending)
  final SortOrder sortOrder;

  /// Additional filters (key-value pairs)
  final Map<String, dynamic>? filters;

  const PaginationParams({
    this.pageSize = 20,
    this.cursor,
    this.page,
    this.sortBy,
    this.sortOrder = SortOrder.descending,
    this.filters,
  });

  /// Creates params for the first page
  const PaginationParams.firstPage({
    this.pageSize = 20,
    this.sortBy,
    this.sortOrder = SortOrder.descending,
    this.filters,
  })  : cursor = null,
        page = 1;

  /// Creates params for cursor-based pagination
  const PaginationParams.cursorBased({
    required this.cursor,
    this.pageSize = 20,
    this.sortBy,
    this.sortOrder = SortOrder.descending,
    this.filters,
  }) : page = null;

  /// Creates params for offset-based pagination
  const PaginationParams.offsetBased({
    required this.page,
    this.pageSize = 20,
    this.sortBy,
    this.sortOrder = SortOrder.descending,
    this.filters,
  })  : cursor = null;

  /// Copy with method for creating modified params
  PaginationParams copyWith({
    int? pageSize,
    String? cursor,
    int? page,
    String? sortBy,
    SortOrder? sortOrder,
    Map<String, dynamic>? filters,
  }) {
    return PaginationParams(
      pageSize: pageSize ?? this.pageSize,
      cursor: cursor ?? this.cursor,
      page: page ?? this.page,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      filters: filters ?? this.filters,
    );
  }

  @override
  String toString() {
    return 'PaginationParams('
        'pageSize: $pageSize, '
        'cursor: ${cursor ?? 'none'}, '
        'page: ${page ?? 'none'}, '
        'sortBy: ${sortBy ?? 'none'}, '
        'sortOrder: $sortOrder, '
        'filters: ${filters?.length ?? 0} filters)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PaginationParams &&
        other.pageSize == pageSize &&
        other.cursor == cursor &&
        other.page == page &&
        other.sortBy == sortBy &&
        other.sortOrder == sortOrder &&
        _mapEquals(other.filters, filters);
  }

  @override
  int get hashCode {
    return pageSize.hashCode ^
        cursor.hashCode ^
        page.hashCode ^
        sortBy.hashCode ^
        sortOrder.hashCode ^
        (filters?.hashCode ?? 0);
  }

  bool _mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || b[key] != a[key]) return false;
    }
    return true;
  }
}

/// Sort order enum
enum SortOrder {
  /// Ascending order (A-Z, 0-9, oldest to newest)
  ascending,

  /// Descending order (Z-A, 9-0, newest to oldest)
  descending,
}
