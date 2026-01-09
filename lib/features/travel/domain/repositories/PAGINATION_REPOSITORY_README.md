# Pagination Repository Pattern

Comprehensive guide for implementing and using pagination in SoloAdventurer repositories.

## Overview

The pagination repository pattern provides efficient data loading for large datasets (500+ items) using cursor-based and offset-based pagination strategies. This pattern is designed to handle trips, activities, and other data types while maintaining optimal performance.

## Architecture

### Core Components

1. **PaginatedRepositoryMixin** - Shared pagination logic
2. **PaginationParams** - Parameter object for pagination queries
3. **TripRepository** - Trip-specific repository interface
4. **ActivityRepository** - Activity-specific repository interface
5. **PaginatedData<T>** - Generic wrapper for paginated results
6. **PageInfo** - Pagination metadata

### File Structure

```
lib/
├── core/
│   ├── models/
│   │   ├── paginated_data.dart
│   │   └── page_info.dart
│   └── repositories/
│       └── paginated_repository_mixin.dart
└── features/
    └── travel/
        ├── domain/
        │   ├── models/
        │   │   ├── trip.dart
        │   │   └── activity.dart
        │   └── repositories/
        │       ├── trip_repository.dart
        │       └── activity_repository.dart
        └── infrastructure/
            └── repositories/
                ├── in_memory_trip_repository.dart
                └── in_memory_activity_repository.dart
```

## Pagination Strategies

### Cursor-Based Pagination (Recommended)

**Pros:**
- Consistent results even with concurrent inserts/deletes
- Better performance for large datasets
- No duplicate or skipped items
- Ideal for infinite scroll

**Cons:**
- Cannot jump to specific pages
- Slightly more complex implementation

**Use Cases:**
- Infinite scroll lists
- Social media feeds
- Activity streams
- Real-time data updates

### Offset-Based Pagination

**Pros:**
- Simple implementation
- Can jump to any page
- Familiar UX pattern

**Cons:**
- Can show duplicates/skip items with concurrent changes
- Performance degrades with large offsets
- Less consistent

**Use Cases:**
- Traditional page navigation (Page 1, 2, 3...)
- Search results with page numbers
- Admin dashboards

## Usage Examples

### Basic Cursor Pagination

```dart
// Initialize repository
final tripRepository = InMemoryTripRepository();

// Load first page
var paginatedData = await tripRepository.getTripsCursor(
  userId: 'user123',
  pageSize: 20,
);

// Display items
for (final trip in paginatedData.items) {
  print(trip.title);
}

// Load next page when user scrolls
if (paginatedData.hasNextPage) {
  paginatedData = await tripRepository.getTripsCursor(
    userId: 'user123',
    cursor: paginatedData.pageInfo.nextCursor,
    pageSize: 20,
  );
}
```

### Basic Offset Pagination

```dart
// Load page 1
final page1 = await tripRepository.getTripsOffset(
  userId: 'user123',
  page: 1,
  pageSize: 20,
);

// Load page 5 directly
final page5 = await tripRepository.getTripsOffset(
  userId: 'user123',
  page: 5,
  pageSize: 20,
);
```

### Filtering and Sorting

```dart
// Get active trips sorted by budget
final activeTrips = await tripRepository.getTripsCursor(
  userId: 'user123',
  filters: {'status': 'active'},
  sortBy: 'budget',
  sortOrder: SortOrder.descending,
  pageSize: 20,
);

// Get completed food activities
final completedFoodActivities = await activityRepository.getActivitiesCursor(
  userId: 'user123',
  tripId: 'trip456',
  filters: {
    'category': ActivityCategory.food,
    'isCompleted': true,
  },
  sortBy: 'startDateTime',
  sortOrder: SortOrder.ascending,
  pageSize: 20,
);
```

### Search

```dart
// Search trips
final searchResults = await tripRepository.searchTrips(
  userId: 'user123',
  query: 'Paris',
  cursor: null,
  pageSize: 20,
);

// Display results
for (final trip in searchResults.items) {
  print('${trip.title} - ${trip.destination}');
}

// Load more results
if (searchResults.hasNextPage) {
  final moreResults = await tripRepository.searchTrips(
    userId: 'user123',
    query: 'Paris',
    cursor: searchResults.pageInfo.nextCursor,
    pageSize: 20,
  );
}
```

### Lightweight Metadata Queries

```dart
// Get only essential fields for list rendering (50% less memory)
final tripsMetadata = await tripRepository.getTripsMetadata(
  userId: 'user123',
  pageSize: 50,
);

// Display in list (fast with 500+ items)
for (final metadata in tripsMetadata.items) {
  ListTile(
    title: Text(metadata.title),
    subtitle: Text(metadata.destination),
    leading: metadata.coverImageUrl != null
        ? Image.network(metadata.coverImageUrl!)
        : null,
    onTap: () async {
      // Load full trip details on tap
      final fullTrip = await tripRepository.getTripById(
        tripId: metadata.id,
      );
      // Navigate to trip details
    },
  );
}
```

### Date Range Queries

```dart
// Get trips in date range
final tripsInJune = await tripRepository.getTripsInDateRange(
  userId: 'user123',
  startDate: DateTime(2024, 6, 1),
  endDate: DateTime(2024, 6, 30),
  cursor: null,
  pageSize: 20,
);

// Get activities for today
final today = DateTime.now();
final startOfDay = DateTime(today.year, today.month, today.day);
final endOfDay = startOfDay.add(const Duration(days: 1));

final todayActivities = await activityRepository.getActivitiesInDateRange(
  userId: 'user123',
  tripId: 'trip456',
  startDate: startOfDay,
  endDate: endOfDay,
  cursor: null,
  pageSize: 20,
);
```

### Convenience Methods

```dart
// Get upcoming activities
final upcoming = await activityRepository.getUpcomingActivities(
  userId: 'user123',
  tripId: 'trip456',
  pageSize: 10,
);

// Get completed activities
final completed = await activityRepository.getCompletedActivities(
  userId: 'user123',
  tripId: 'trip456',
  pageSize: 20,
);

// Get priority activities
final priority = await activityRepository.getPriorityActivities(
  userId: 'user123',
  tripId: 'trip456',
  pageSize: 10,
);
```

### Bulk Operations

```dart
// Mark multiple activities as completed
final updatedCount = await activityRepository.bulkUpdateActivities(
  activityIds: ['activity1', 'activity2', 'activity3'],
  updates: {'isCompleted': true},
);

print('Updated $updatedCount activities');
```

### Counting

```dart
// Count total trips
final totalTrips = await tripRepository.countTrips(
  userId: 'user123',
);

// Count active trips
final activeTrips = await tripRepository.countTrips(
  userId: 'user123',
  filters: {'status': 'active'},
);

// Count incomplete activities
final incompleteCount = await activityRepository.countActivities(
  userId: 'user123',
  tripId: 'trip456',
  filters: {'isCompleted': false},
);
```

## Implementing a Custom Repository

### Step 1: Extend the Mixin

```dart
import 'package:soloadventurer/core/repositories/paginated_repository_mixin.dart';

class MyCustomRepository with PaginatedRepositoryMixin {
  // Your implementation
}
```

### Step 2: Implement Pagination Methods

```dart
class DatabaseTripRepository with PaginatedRepositoryMixin
    implements TripRepository {

  final Database _db;

  DatabaseTripRepository(this._db);

  @override
  Future<PaginatedData<Trip>> getTripsCursor({
    required String userId,
    String? cursor,
    int pageSize = 20,
    String sortBy = 'createdAt',
    SortOrder sortOrder = SortOrder.descending,
    Map<String, dynamic>? filters,
  }) async {
    // Validate page size
    final validatedPageSize = validatePageSize(pageSize);

    // Parse cursor
    final offset = parseOffsetCursor(cursor) ?? 0;

    // Build query
    var query = _db.select('trips')
        .where('userId = ?', [userId]);

    // Apply filters
    if (filters != null) {
      if (filters.containsKey('status')) {
        query = query.where('status = ?', [filters['status']]);
      }
    }

    // Get total count
    final totalItems = await query.count();

    // Apply sorting
    query = query.orderBy('$sortBy ${sortOrder == SortOrder.ascending ? 'ASC' : 'DESC'}');

    // Apply pagination
    query = query.limit(validatedPageSize).offset(offset);

    // Execute query
    final rows = await query.get();
    final trips = rows.map((row) => Trip.fromJson(row)).toList();

    // Determine if there's a next page
    final hasNextPage = (offset + validatedPageSize) < totalItems;

    // Generate next cursor
    final nextCursor = hasNextPage
        ? generateOffsetCursor(offset + validatedPageSize)
        : null;

    // Create page info
    final pageInfo = createCursorPageInfo(
      currentCursor: cursor,
      pageSize: validatedPageSize,
      itemsCount: trips.length,
      hasNextPage: hasNextPage,
      nextCursor: nextCursor,
    );

    return PaginatedData<Trip>(
      items: trips,
      pageInfo: pageInfo,
    );
  }

  // Implement other methods...
}
```

### Step 3: Handle Sorting

```dart
List<Trip> _sortTrips(List<Trip> trips, String field, SortOrder order) {
  final sortedTrips = List<Trip>.from(trips);

  sortedTrips.sort((a, b) {
    int comparison;
    switch (field) {
      case 'title':
        comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
        break;
      case 'startDate':
        comparison = a.startDate.compareTo(b.startDate);
        break;
      case 'createdAt':
      default:
        comparison = a.createdAt.compareTo(b.createdAt);
        break;
    }

    return order == SortOrder.ascending ? comparison : -comparison;
  });

  return sortedTrips;
}
```

## Best Practices

### 1. Use Metadata Queries for Lists

When displaying lists of 500+ items, use metadata queries to reduce memory usage:

```dart
// ❌ BAD - Loads all trip data
final allTrips = await tripRepository.getTripsCursor(
  userId: 'user123',
  pageSize: 500,
);

// ✅ GOOD - Loads only essential data
final tripMetadata = await tripRepository.getTripsMetadata(
  userId: 'user123',
  pageSize: 500,
);
```

### 2. Implement Lazy Loading

Combine pagination with virtual scrolling for optimal performance:

```dart
// Use with VirtualListView widget
VirtualListView<Trip>(
  itemCount: paginatedData.itemCount,
  itemBuilder: (context, index) {
    final trip = paginatedData.items[index];
    return TripListItem(trip: trip);
  },
  // Load more when near end
  onLoadMore: () async {
    if (paginatedData.hasNextPage) {
      final nextPage = await tripRepository.getTripsCursor(
        userId: 'user123',
        cursor: paginatedData.pageInfo.nextCursor,
      );
      setState(() {
        paginatedData = paginatedData.copyWith(
          items: [...paginatedData.items, ...nextPage.items],
          pageInfo: nextPage.pageInfo,
        );
      });
    }
  },
)
```

### 3. Cache Pages

Cache loaded pages to avoid re-fetching:

```dart
class PaginatedTripCache {
  final Map<String, PaginatedData<Trip>> _cache = {};

  Future<PaginatedData<Trip>> getOrFetch(
    String key,
    Future<PaginatedData<Trip>> Function() fetcher,
  ) async {
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    final data = await fetcher();
    _cache[key] = data;
    return data;
  }

  void clear() {
    _cache.clear();
  }
}
```

### 4. Handle Errors Gracefully

```dart
try {
  final paginatedData = await tripRepository.getTripsCursor(
    userId: 'user123',
    pageSize: 20,
  );
  // Update UI
} on NetworkException {
  // Show network error
  showError('Failed to load trips. Please check your connection.');
} on AuthException {
  // Redirect to login
  navigateToLogin();
} catch (e) {
  // Show generic error
  showError('An unexpected error occurred.');
}
```

### 5. Use Appropriate Page Sizes

- **Mobile lists**: 10-20 items
- **Tablet/desktop**: 20-50 items
- **Metadata queries**: 50-100 items
- **Never exceed 100** (enforced by maxPageSize)

### 6. Prefer Cursor-Based Pagination

Use cursor-based pagination for:
- Infinite scroll
- Real-time data
- Large datasets (1000+ items)

Use offset-based pagination for:
- Search results with page numbers
- Admin dashboards
- Small datasets (< 100 items)

### 7. Implement Preloading

Load next page before user reaches end:

```dart
// When user scrolls to 80% of list
if (scrollController.position.pixels >=
    scrollController.position.maxScrollExtent * 0.8) {
  _preloadNextPage();
}

Future<void> _preloadNextPage() async {
  if (paginatedData.hasNextPage && !_isLoading) {
    _isLoading = true;
    final nextPage = await tripRepository.getTripsCursor(
      userId: 'user123',
      cursor: paginatedData.pageInfo.nextCursor,
    );
    setState(() {
      paginatedData = nextPage;
      _isLoading = false;
    });
  }
}
```

## Performance Considerations

### Memory Usage

- **Full objects**: ~1 KB per trip
- **Metadata objects**: ~200 bytes per trip (80% reduction)
- **500 trips**: ~500 KB (full) vs ~100 KB (metadata)

### Network Usage

- **First page**: ~20 KB (20 trips)
- **Each subsequent page**: ~20 KB
- **500 trips**: ~500 KB total (25 pages)

### Database Queries

- Use indexed columns for sorting (createdAt, startDate, title)
- Limit SELECT columns for metadata queries
- Use prepared statements for filters
- Consider query result caching

## Testing

### Unit Tests

```dart
test('getTripsCursor returns correct page', () async {
  final repository = InMemoryTripRepository();

  // Insert test data
  for (var i = 0; i < 50; i++) {
    await repository.createTrip(trip: Trip(...));
  }

  // Test pagination
  final page1 = await repository.getTripsCursor(
    userId: 'user123',
    pageSize: 20,
  );

  expect(page1.items.length, equals(20));
  expect(page1.hasNextPage, isTrue);

  final page2 = await repository.getTripsCursor(
    userId: 'user123',
    cursor: page1.pageInfo.nextCursor,
    pageSize: 20,
  );

  expect(page2.items.length, equals(20));
  expect(page2.items.first.id, isNot(page1.items.first.id));
});
```

### Integration Tests

```dart
testWidgets('infinite scroll loads more trips', (tester) async {
  final repository = InMemoryTripRepository();

  // Pump widget with infinite scroll
  await tester.pumpWidget(
    MaterialApp(
      home: TripListScreen(repository: repository),
    ),
  );

  // Scroll to bottom
  await tester.fling(
    find.byType(Scrollable),
    const Offset(0, -500),
    10000,
  );

  // Wait for next page to load
  await tester.pumpAndSettle();

  // Verify more items loaded
  expect(find.byType(TripListItem), findsWidgets);
});
```

## Troubleshooting

### Issue: Duplicates Across Pages

**Cause:** Concurrent inserts while using offset-based pagination

**Solution:** Use cursor-based pagination instead

```dart
// ❌ Offset-based - can show duplicates
final page1 = await repo.getTripsOffset(page: 1, pageSize: 20);
// Another trip is inserted here
final page2 = await repo.getTripsOffset(page: 2, pageSize: 20);
// page2 might include the same trip as page1

// ✅ Cursor-based - no duplicates
final page1 = await repo.getTripsCursor(cursor: null, pageSize: 20);
// Another trip is inserted here
final page2 = await repo.getTripsCursor(
  cursor: page1.pageInfo.nextCursor,
  pageSize: 20,
);
// No duplicates guaranteed
```

### Issue: Poor Performance with Large Offsets

**Cause:** Offset-based pagination becomes slow with large offsets (1000+)

**Solution:** Use cursor-based pagination or keyset pagination

```dart
// ❌ Slow - scans 10,000 rows
final page = await repo.getTripsOffset(page: 500, pageSize: 20);

// ✅ Fast - uses indexed cursor
final page = await repo.getTripsCursor(
  cursor: 'cursor_from_last_page',
  pageSize: 20,
);
```

### Issue: Memory Usage Too High

**Cause:** Loading full objects for list rendering

**Solution:** Use metadata queries

```dart
// ❌ High memory - 500 KB for 500 trips
final trips = await repo.getTripsCursor(pageSize: 500);

// ✅ Low memory - 100 KB for 500 metadata objects
final metadata = await repo.getTripsMetadata(pageSize: 500);
```

## Migration Guide

### From Simple List to Pagination

**Before:**
```dart
final allTrips = await tripRepository.getAllTrips();
ListView.builder(
  itemCount: allTrips.length,
  itemBuilder: (context, index) => TripItem(allTrips[index]),
)
```

**After:**
```dart
var paginatedData = await tripRepository.getTripsCursor(
  userId: 'user123',
  pageSize: 20,
);

VirtualListView<Trip>(
  itemCount: paginatedData.itemCount,
  itemBuilder: (context, index) => TripItem(paginatedData.items[index]),
  onLoadMore: () async {
    if (paginatedData.hasNextPage) {
      setState(() {
        paginatedData = await tripRepository.getTripsCursor(
          userId: 'user123',
          cursor: paginatedData.pageInfo.nextCursor,
        );
      });
    }
  },
)
```

## Additional Resources

- [Virtual Scrolling Implementation](../widgets/README.md)
- [Performance Testing Guide](../../../../test/utils/performance/README.md)
- [API Documentation](api/trip_repository.md)

## Changelog

### Version 1.0.0 (2026-01-04)
- Initial implementation
- Cursor-based pagination
- Offset-based pagination
- Filtering and sorting support
- Metadata queries
- Search functionality
- Bulk operations
