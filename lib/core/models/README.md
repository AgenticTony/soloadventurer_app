# Pagination Models

This directory contains reusable models for handling paginated API responses and data structures.

## Overview

The pagination models provide a complete solution for handling paginated data in your application, supporting both cursor-based and offset-based pagination strategies.

## Models

### PageInfo

Contains pagination metadata including:

- **currentPage**: Current page number (1-based) or offset cursor
- **itemsPerPage**: Number of items per page
- **totalItems**: Total number of items across all pages (optional)
- **totalPages**: Total number of pages (optional)
- **hasNextPage**: Whether there is a next page available
- **hasPreviousPage**: Whether there is a previous page available
- **nextCursor**: Optional cursor for cursor-based pagination
- **previousCursor**: Optional cursor for the previous page

**Useful Getters:**
- `offset`: Calculates the offset for offset-based pagination
- `isFirstPage`: Whether this is the first page
- `isLastPage`: Whether this is the last page (when totalPages is known)

### PaginatedData\<T\>

Generic wrapper for paginated data containing:

- **items**: List of items for the current page (generic type T)
- **pageInfo**: Pagination metadata

**Useful Getters:**
- `itemCount`: Number of items in the current page
- `isEmpty`: Whether the current page is empty
- `isNotEmpty`: Whether the current page has items
- `hasNextPage`: Whether there is a next page available
- `hasPreviousPage`: Whether there is a previous page available
- `firstOrNull`: Returns the first item (null if empty)
- `lastOrNull`: Returns the last item (null if empty)

## Usage Examples

### Creating Paginated Data

```dart
// Create PageInfo
final pageInfo = PageInfo(
  currentPage: 1,
  itemsPerPage: 20,
  totalItems: 100,
  totalPages: 5,
  hasNextPage: true,
  hasPreviousPage: false,
);

// Create PaginatedData with your model
final paginatedTrips = PaginatedData<Trip>(
  items: trips,
  pageInfo: pageInfo,
);
```

### Cursor-Based Pagination

```dart
final pageInfo = PageInfo(
  currentPage: 1,
  itemsPerPage: 20,
  hasNextPage: true,
  hasPreviousPage: false,
  nextCursor: 'eyJpZCI6IjEyMzQ1Njc4OTAifQ==',
  previousCursor: null,
);

final paginatedData = PaginatedData<Activity>(
  items: activities,
  pageInfo: pageInfo,
);
```

### JSON Serialization

```dart
// Serialize to JSON
final json = paginatedData.toJson((item) => item.toJson());

// Deserialize from JSON
final paginatedData = PaginatedData.fromJson(
  json,
  (itemJson) => Trip.fromJson(itemJson),
);
```

### Empty State

```dart
// Create empty paginated data
final emptyData = PaginatedData<Trip>.empty();

if (emptyData.isEmpty) {
  // Show empty state UI
}
```

### Checking Navigation State

```dart
if (paginatedData.hasNextPage) {
  // Show "Load More" button
  // Enable next page navigation
}

if (paginatedData.hasPreviousPage) {
  // Enable previous page navigation
}
```

### Using with Infinite Scroll

```dart
// In a repository or service
Future<PaginatedData<Trip>> loadTrips({
  required int page,
  required int itemsPerPage,
  String? cursor,
}) async {
  final response = await api.getTrips(
    page: page,
    itemsPerPage: itemsPerPage,
    cursor: cursor,
  );

  return PaginatedData.fromJson(
    response.data,
    (json) => Trip.fromJson(json),
  );
}

// In a UI widget
@override
Widget build(BuildContext context) {
  final paginatedTrips = ref.watch(tripsProvider);

  return ListView.builder(
    itemCount: paginatedTrips.itemCount,
    itemBuilder: (context, index) {
      final trip = paginatedTrips.items[index];
      return TripCard(trip: trip);
    },
  );
}
```

## Pagination Strategies

### Offset-Based Pagination

Uses page numbers and calculates offset:

```dart
final pageInfo = PageInfo(
  currentPage: 2,
  itemsPerPage: 20,
  totalItems: 100,
  totalPages: 5,
  hasNextPage: true,
  hasPreviousPage: true,
);

// Calculate offset for API query
final offset = pageInfo.offset; // 20
```

**Pros:**
- Simple to implement
- Easy to navigate to specific pages
- Works well for static datasets

**Cons:**
- Can show duplicate items if data changes during pagination
- Less efficient for very large datasets

### Cursor-Based Pagination

Uses opaque cursors for navigation:

```dart
final pageInfo = PageInfo(
  currentPage: 1,
  itemsPerPage: 20,
  hasNextPage: true,
  hasPreviousPage: false,
  nextCursor: 'eyJpZCI6IjEyMzQ1Njc4OTAifQ==',
);

// Use cursor for next page query
final nextPage = await loadTrips(cursor: pageInfo.nextCursor);
```

**Pros:**
- No duplicate items when data changes
- More efficient for large, changing datasets
- Better for real-time data

**Cons:**
- Cannot jump to specific pages
- Slightly more complex to implement

## Testing

The models include comprehensive test coverage:

```bash
# Run tests for pagination models
flutter test test/core/models/
```

## Best Practices

1. **Use appropriate pagination strategy**:
   - Offset-based for static datasets
   - Cursor-based for dynamic/real-time data

2. **Handle unknown totals**:
   - TotalItems and totalPages can be null
   - Always check hasNextPage/hasPreviousPage for navigation

3. **Use empty constructor**:
   - Use `PaginatedData.empty()` for initial states
   - Check `isEmpty` before accessing items

4. **Type safety**:
   - Always specify generic type: `PaginatedData<Trip>`
   - Use proper fromJson/toJson functions

5. **Error handling**:
   - Check `isEmpty` before accessing firstOrNull/lastOrNull
   - Validate pagination state before navigation

## Integration Points

These models integrate with:
- **Repository pattern**: Use in data repositories for paginated queries
- **State management**: Works seamlessly with Riverpod providers
- **API clients**: Serialize/deserialize from API responses
- **UI widgets**: Use with infinite scroll widgets and list views

## Performance Considerations

- Models are immutable (use copyWith for updates)
- Generic type T provides type safety without runtime overhead
- JSON serialization is efficient for typical page sizes (20-50 items)
- Empty state creation is lightweight (no allocation overhead)

## Future Enhancements

Potential additions:
- [ ] Merge multiple pages into single PaginatedData
- [ ] Filter/sort utilities for paginated data
- [ ] Pagination state enums (loading, error, success)
- [ ] Built-in retry logic for failed page loads
- [ ] Prefetching strategy for next pages
