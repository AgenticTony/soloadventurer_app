import 'page_info.dart';

export 'page_info.dart';

/// Generic model wrapping paginated data with metadata
///
/// This model contains a list of items along with pagination information,
/// providing a complete response structure for paginated API endpoints.
/// Supports both cursor-based and offset-based pagination strategies.
class PaginatedData<T> {
  /// List of items for the current page
  final List<T> items;

  /// Pagination metadata
  final PageInfo pageInfo;

  /// Creates a new [PaginatedData] instance
  PaginatedData({
    required this.items,
    required this.pageInfo,
  });

  /// Creates a [PaginatedData] from JSON data
  ///
  /// The [items] parameter should be a list of JSON objects that can be
  /// converted to type T using the [fromJson] function.
  factory PaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final itemsList = json['items'] as List<dynamic>;
    final items = itemsList
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();

    return PaginatedData(
      items: items,
      pageInfo: PageInfo.fromJson(json['pageInfo'] as Map<String, dynamic>),
    );
  }

  /// Converts [PaginatedData] to JSON
  ///
  /// The [toJson] function should convert an item of type T to JSON.
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJson) {
    return {
      'items': items.map(toJson).toList(),
      'pageInfo': pageInfo.toJson(),
    };
  }

  /// Number of items in the current page
  int get itemCount => items.length;

  /// Whether the current page is empty
  bool get isEmpty => items.isEmpty;

  /// Whether the current page has items
  bool get isNotEmpty => items.isNotEmpty;

  /// Whether there is a next page available
  bool get hasNextPage => pageInfo.hasNextPage;

  /// Whether there is a previous page available
  bool get hasPreviousPage => pageInfo.hasPreviousPage;

  /// Current page number
  int get currentPage => pageInfo.currentPage;

  /// Items per page
  int get itemsPerPage => pageInfo.itemsPerPage;

  /// Total items across all pages (null if unknown)
  int? get totalItems => pageInfo.totalItems;

  /// Total pages across all pages (null if unknown)
  int? get totalPages => pageInfo.totalPages;

  /// Creates an empty [PaginatedData] with default page info
  factory PaginatedData.empty() {
    return PaginatedData(
      items: [],
      pageInfo: PageInfo(
        currentPage: 1,
        itemsPerPage: 20,
        totalItems: 0,
        totalPages: 0,
        hasNextPage: false,
        hasPreviousPage: false,
      ),
    );
  }

  /// Creates a copy of this [PaginatedData] with modified fields
  PaginatedData<T> copyWith({
    List<T>? items,
    PageInfo? pageInfo,
  }) {
    return PaginatedData<T>(
      items: items ?? this.items,
      pageInfo: pageInfo ?? this.pageInfo,
    );
  }

  /// Returns the first item in the current page (null if empty)
  T? get firstOrNull {
    if (items.isEmpty) return null;
    return items.first;
  }

  /// Returns the last item in the current page (null if empty)
  T? get lastOrNull {
    if (items.isEmpty) return null;
    return items.last;
  }

  @override
  String toString() {
    return 'PaginatedData('
        'itemCount: $itemCount, '
        'pageInfo: $pageInfo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PaginatedData<T> &&
        other.items.length == items.length &&
        other.pageInfo == pageInfo;
  }

  @override
  int get hashCode {
    return items.length.hashCode ^ pageInfo.hashCode;
  }
}
