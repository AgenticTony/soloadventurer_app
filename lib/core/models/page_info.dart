/// Model containing pagination metadata for paginated data responses
///
/// This model contains information about the current page, total items,
/// and navigation state for implementing cursor-based or offset-based pagination.
class PageInfo {
  /// Current page number (1-based) or offset cursor
  final int currentPage;

  /// Number of items per page
  final int itemsPerPage;

  /// Total number of items across all pages (null if unknown)
  final int? totalItems;

  /// Total number of pages (null if totalItems is unknown)
  final int? totalPages;

  /// Whether there is a next page available
  final bool hasNextPage;

  /// Whether there is a previous page available
  final bool hasPreviousPage;

  /// Optional cursor for cursor-based pagination (null for offset-based)
  final String? nextCursor;

  /// Optional cursor for the previous page (null for offset-based)
  final String? previousCursor;

  /// Creates a new [PageInfo] instance
  PageInfo({
    required this.currentPage,
    required this.itemsPerPage,
    this.totalItems,
    this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
    this.nextCursor,
    this.previousCursor,
  });

  /// Creates a [PageInfo] from JSON data
  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      currentPage: json['currentPage'] as int,
      itemsPerPage: json['itemsPerPage'] as int,
      totalItems: json['totalItems'] as int?,
      totalPages: json['totalPages'] as int?,
      hasNextPage: json['hasNextPage'] as bool,
      hasPreviousPage: json['hasPreviousPage'] as bool,
      nextCursor: json['nextCursor'] as String?,
      previousCursor: json['previousCursor'] as String?,
    );
  }

  /// Converts [PageInfo] to JSON
  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'itemsPerPage': itemsPerPage,
      'totalItems': totalItems,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
      'nextCursor': nextCursor,
      'previousCursor': previousCursor,
    };
  }

  /// Calculates the offset (for offset-based pagination)
  int get offset => (currentPage - 1) * itemsPerPage;

  /// Whether this is the first page
  bool get isFirstPage => currentPage == 1;

  /// Whether this is the last page (only valid if totalPages is not null)
  bool get isLastPage => totalPages != null && currentPage >= totalPages!;

  /// Creates a copy of this [PageInfo] with modified fields
  PageInfo copyWith({
    int? currentPage,
    int? itemsPerPage,
    int? totalItems,
    int? totalPages,
    bool? hasNextPage,
    bool? hasPreviousPage,
    String? nextCursor,
    String? previousCursor,
  }) {
    return PageInfo(
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
      nextCursor: nextCursor ?? this.nextCursor,
      previousCursor: previousCursor ?? this.previousCursor,
    );
  }

  @override
  String toString() {
    return 'PageInfo('
        'currentPage: $currentPage, '
        'itemsPerPage: $itemsPerPage, '
        'totalItems: ${totalItems ?? 'unknown'}, '
        'totalPages: ${totalPages ?? 'unknown'}, '
        'hasNextPage: $hasNextPage, '
        'hasPreviousPage: $hasPreviousPage, '
        'nextCursor: ${nextCursor ?? 'none'}, '
        'previousCursor: ${previousCursor ?? 'none'})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PageInfo &&
        other.currentPage == currentPage &&
        other.itemsPerPage == itemsPerPage &&
        other.totalItems == totalItems &&
        other.totalPages == totalPages &&
        other.hasNextPage == hasNextPage &&
        other.hasPreviousPage == hasPreviousPage &&
        other.nextCursor == nextCursor &&
        other.previousCursor == previousCursor;
  }

  @override
  int get hashCode {
    return currentPage.hashCode ^
        itemsPerPage.hashCode ^
        totalItems.hashCode ^
        totalPages.hashCode ^
        hasNextPage.hashCode ^
        hasPreviousPage.hashCode ^
        nextCursor.hashCode ^
        previousCursor.hashCode;
  }
}
