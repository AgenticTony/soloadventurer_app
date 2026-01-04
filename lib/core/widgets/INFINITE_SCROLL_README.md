# InfiniteScrollListView

A generic infinite scroll list widget that automatically loads more data as the user scrolls towards the end. Combines `VirtualListView` for efficient rendering with automatic pagination logic, providing a complete solution for large datasets (500+ items).

## Features

✅ **Automatic pagination** - Loads next page when scrolling near the end
✅ **Pull-to-refresh** - Refresh data with pull-to-refresh gesture
✅ **Loading states** - Show initial loading and "loading more" indicators
✅ **Error handling** - Display errors and provide retry functionality
✅ **Configurable preload** - Adjust threshold for loading next page (default: 500px)
✅ **Virtual scrolling** - Efficient memory usage with VirtualListView
✅ **Cursor/offset support** - Works with both pagination strategies
✅ **End detection** - Shows "end of list" when no more data
✅ **Custom widgets** - Customize loading, error, and empty states
✅ **Type-safe** - Generic type parameter for type safety

## Performance Benefits

- **Memory efficient**: Only renders visible items (virtual scrolling)
- **Network efficient**: Loads data in pages (20 items per page by default)
- **Smooth scrolling**: Preloads next page before user reaches end
- **Scalable**: Handles 500+ items without performance degradation

## Basic Usage

### Minimal Example

```dart
InfiniteScrollListView<Trip>(
  fetchData: (cursor) async {
    return await tripRepository.getTripsCursor(
      userId: 'user123',
      cursor: cursor,
      pageSize: 20,
    );
  },
  itemBuilder: (context, trip) => TripCard(trip: trip),
)
```

### With Separators

```dart
InfiniteScrollListView<Trip>.withSeparators(
  fetchData: (cursor) => tripRepository.getTripsCursor(
    userId: 'user123',
    cursor: cursor,
    pageSize: 20,
  ),
  itemBuilder: (context, trip) => TripCard(trip: trip),
  separatorBuilder: (context, index) => Divider(height: 1),
)
```

### With Custom Widgets

```dart
InfiniteScrollListView<Trip>(
  fetchData: (cursor) async => await tripRepository.getTripsCursor(
    userId: 'user123',
    cursor: cursor,
    pageSize: 20,
  ),
  itemBuilder: (context, trip) => TripCard(trip: trip),

  // Custom loading states
  initialLoadingWidget: Center(
    child: CircularProgressIndicator(),
  ),
  loadingMoreWidget: Padding(
    padding: EdgeInsets.all(16),
    child: Center(child: CircularProgressIndicator()),
  ),

  // Custom error state
  errorWidget: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 48, color: Colors.red),
        SizedBox(height: 16),
        Text('Failed to load trips'),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _retry(),
          child: Text('Retry'),
        ),
      ],
    ),
  ),

  // Custom empty state
  emptyWidget: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.flight_takeoff, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text('No trips yet. Start your adventure!'),
      ],
    ),
  ),

  // Custom end of list indicator
  endOfListWidget: Padding(
    padding: EdgeInsets.all(16),
    child: Text(
      'You\'ve reached the end',
      style: TextStyle(color: Colors.grey),
    ),
  ),

  // Configure preload threshold (load 300px before end)
  preloadThreshold: 300.0,

  // Disable pull-to-refresh if needed
  enablePullToRefresh: true,
)
```

### With Header and Footer

```dart
InfiniteScrollListView<Trip>(
  fetchData: (cursor) async => await tripRepository.getTripsCursor(
    userId: 'user123',
    cursor: cursor,
    pageSize: 20,
  ),
  itemBuilder: (context, trip) => TripCard(trip: trip),

  // Add header at the top
  header: Padding(
    padding: EdgeInsets.all(16),
    child: Text(
      'My Trips',
      style: Theme.of(context).textTheme.headlineSmall,
    ),
  ),

  // Add footer after loading indicator
  footer: Padding(
    padding: EdgeInsets.all(16),
    child: ElevatedButton(
      onPressed: () => _scrollToTop(),
      child: Text('Scroll to Top'),
    ),
  ),
)
```

### With Custom Scroll Controller

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trips')),
      floatingActionButton: FloatingActionButton(
        onPressed: _scrollToTop,
        child: Icon(Icons.arrow_upward),
      ),
      body: InfiniteScrollListView<Trip>(
        fetchData: (cursor) async => await tripRepository.getTripsCursor(
          userId: 'user123',
          cursor: cursor,
          pageSize: 20,
        ),
        itemBuilder: (context, trip) => TripCard(trip: trip),
        controller: _scrollController,
      ),
    );
  }
}
```

## Integration with Repository

### Using TripRepository (Cursor-based)

```dart
class TripsScreen extends StatelessWidget {
  final TripRepository tripRepository;
  final String userId;

  const TripsScreen({
    super.key,
    required this.tripRepository,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return InfiniteScrollListView<Trip>(
      fetchData: (cursor) async {
        return await tripRepository.getTripsCursor(
          userId: userId,
          cursor: cursor,
          pageSize: 20,
          sortBy: 'createdAt',
          sortOrder: SortOrder.descending,
        );
      },
      itemBuilder: (context, trip) => TripCard(trip: trip),
      separatorBuilder: (context, index) => Divider(height: 1),
      emptyWidget: Center(
        child: Text('No trips found. Start planning!'),
      ),
    );
  }
}
```

### Using ActivityRepository (with filters)

```dart
class ActivitiesScreen extends StatelessWidget {
  final ActivityRepository activityRepository;
  final String tripId;

  const ActivitiesScreen({
    super.key,
    required this.activityRepository,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context) {
    return InfiniteScrollListView<Activity>(
      fetchData: (cursor) async {
        return await activityRepository.getActivitiesCursor(
          tripId: tripId,
          cursor: cursor,
          pageSize: 20,
          sortBy: 'startDateTime',
          sortOrder: SortOrder.ascending,
        );
      },
      itemBuilder: (context, activity) => ActivityCard(activity: activity),
      separatorBuilder: (context, index) => SizedBox(height: 8),
      padding: EdgeInsets.all(16),
    );
  }
}
```

## Pagination Strategies

### Cursor-based Pagination (Recommended)

Cursor-based pagination is the recommended approach for infinite scroll as it:
- Prevents duplicate/skipped items when new data is added
- Provides consistent pagination even with concurrent updates
- More efficient for large datasets

```dart
// Repository returns cursor in pageInfo.nextCursor
final pageData = await tripRepository.getTripsCursor(
  userId: 'user123',
  cursor: cursor,  // null for first page
  pageSize: 20,
);

// Use the cursor for next page
final nextCursor = pageData.pageInfo.nextCursor;
```

### Offset-based Pagination

Offset-based pagination is useful for traditional page navigation:

```dart
// Repository calculates offset internally
final pageData = await tripRepository.getTripsOffset(
  userId: 'user123',
  page: 1,  // 1-based page number
  pageSize: 20,
);

// pageInfo.currentPage contains current page
```

## Performance Tips

### 1. Adjust Preload Threshold

Load next page closer to the end for faster perceived speed:

```dart
InfiniteScrollListView<Trip>(
  fetchData: (cursor) => _fetchData(cursor),
  itemBuilder: (context, trip) => TripCard(trip: trip),
  preloadThreshold: 300.0,  // Load 300px before end (default: 500)
)
```

### 2. Optimize Item Builder

Use `const` constructors and `ValueKey` for better performance:

```dart
itemBuilder: (context, trip) => TripCard(
  key: ValueKey(trip.id),  // Important for widget recycling
  trip: trip,
),
```

### 3. Lazy Load Images

Use `LazyLoadImage` in your item builder for photo galleries:

```dart
itemBuilder: (context, photo) => LazyLoadImage.photo(
  key: ValueKey(photo.id),
  imageUrl: photo.displayUrl,
  thumbnailUrl: photo.thumbnailUrl,
),
```

### 4. Use Lightweight Data

Consider using metadata-only queries for list rendering:

```dart
// For list views, use metadata (80% memory reduction)
final metadata = await tripRepository.getTripsMetadata(
  userId: 'user123',
  pageSize: 50,
);

// Load full details only when needed
final trip = await tripRepository.getTripById(tripId);
```

## State Management with Riverpod

### Using Riverpod Provider

```dart
// Define provider
final tripsProvider = StateNotifierProvider<TripsNotifier, InfiniteScrollState<Trip>>((ref) {
  return TripsNotifier(ref.read(tripRepositoryProvider));
});

class TripsNotifier extends StateNotifier<InfiniteScrollState<Trip>> {
  final TripRepository _repository;

  TripsNotifier(this._repository) : super(const InfiniteScrollState());

  Future<void> loadInitial() async {
    state = state.copyWith(status: InfiniteScrollStatus.initialLoading);
    try {
      final pageData = await _repository.getTripsCursor(
        userId: 'user123',
        pageSize: 20,
      );
      state = state.copyWith(
        items: pageData.items,
        pageInfo: pageData.pageInfo,
        status: InfiniteScrollStatus.loaded,
      );
    } catch (e) {
      state = state.copyWith(
        status: InfiniteScrollStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadNextPage() async {
    if (!state.hasNextPage || state.isLoading) return;
    state = state.copyWith(status: InfiniteScrollStatus.loadingMore);
    try {
      final pageData = await _repository.getTripsCursor(
        userId: 'user123',
        cursor: state.pageInfo?.nextCursor,
        pageSize: 20,
      );
      state = state.copyWith(
        items: [...state.items, ...pageData.items],
        pageInfo: pageData.pageInfo,
        status: pageData.hasNextPage
            ? InfiniteScrollStatus.loaded
            : InfiniteScrollStatus.reachedEnd,
      );
    } catch (e) {
      state = state.copyWith(status: InfiniteScrollStatus.error);
    }
  }
}

// Use in widget
class TripsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripsProvider);

    return InfiniteScrollListView<Trip>(
      fetchData: (cursor) async {
        return await ref.read(tripRepositoryProvider).getTripsCursor(
          userId: 'user123',
          cursor: cursor,
          pageSize: 20,
        );
      },
      itemBuilder: (context, trip) => TripCard(trip: trip),
    );
  }
}
```

## Customization Examples

### Horizontal Scrolling

```dart
InfiniteScrollListView<Trip>(
  fetchData: (cursor) => _fetchData(cursor),
  itemBuilder: (context, trip) => TripCard(trip: trip),
  scrollDirection: Axis.horizontal,
)
```

### With Custom Padding

```dart
InfiniteScrollListView<Trip>(
  fetchData: (cursor) => _fetchData(cursor),
  itemBuilder: (context, trip) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: TripCard(trip: trip),
  ),
  padding: EdgeInsets.symmetric(vertical: 8),
)
```

### Disable Pull-to-Refresh

```dart
InfiniteScrollListView<Trip>(
  fetchData: (cursor) => _fetchData(cursor),
  itemBuilder: (context, trip) => TripCard(trip: trip),
  enablePullToRefresh: false,  // Disable pull-to-refresh
)
```

## Error Handling

### Default Error Widget

The widget provides a default error widget with:
- Error icon
- Error message
- Retry button

### Custom Error Widget

Create your own error widget:

```dart
errorWidget: Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.wifi_off, size: 48, color: Colors.orange),
      SizedBox(height: 16),
      Text('No internet connection'),
      SizedBox(height: 8),
      Text('Check your connection and try again'),
      SizedBox(height: 16),
      ElevatedButton.icon(
        onPressed: () => _retry(),
        icon: Icon(Icons.refresh),
        label: Text('Retry'),
      ),
    ],
  ),
)
```

### Retry Logic

The widget automatically handles retry for both initial load and pagination errors.

## Testing

### Widget Test Example

```dart
testWidgets('InfiniteScrollListView loads data', (WidgetTester tester) async {
  final mockRepository = MockTripRepository();

  when(mockRepository.getTripsCursor(
    userId: any,
    cursor: null,
    pageSize: any,
  )).thenAnswer((_) async => PaginatedData<Trip>(
    items: [Trip(id: '1', title: 'Trip 1')],
    pageInfo: PageInfo(
      currentPage: 1,
      itemsPerPage: 20,
      hasNextPage: true,
      hasPreviousPage: false,
    ),
  ));

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: InfiniteScrollListView<Trip>(
          fetchData: (cursor) => mockRepository.getTripsCursor(
            userId: 'user123',
            cursor: cursor,
            pageSize: 20,
          ),
          itemBuilder: (context, trip) => Text(trip.title),
        ),
      ),
    ),
  );

  // Wait for initial load
  await tester.pumpAndSettle();

  // Verify first item is displayed
  expect(find.text('Trip 1'), findsOneWidget);
});
```

### Performance Test

```dart
testWidgets('InfiniteScrollListView handles 500 items efficiently', (WidgetTester tester) async {
  final mockRepository = MockTripRepository();

  // Mock 5 pages of data (100 items per page)
  when(mockRepository.getTripsCursor(
    userId: any,
    cursor: anyNamed('cursor'),
    pageSize: any,
  )).thenAnswer((_) async {
    final cursor = invocation.namedArguments[#cursor] as String?;
    final page = cursor == null ? 1 : int.parse(cursor) + 1;

    return PaginatedData<Trip>(
      items: List.generate(100, (i) => Trip(
        id: '${page}_$i',
        title: 'Trip ${page}_$i',
      )),
      pageInfo: PageInfo(
        currentPage: page,
        itemsPerPage: 100,
        hasNextPage: page < 5,
        hasPreviousPage: page > 1,
        nextCursor: page < 5 ? '$page' : null,
      ),
    );
  });

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: InfiniteScrollListView<Trip>(
          fetchData: (cursor) => mockRepository.getTripsCursor(
            userId: 'user123',
            cursor: cursor,
            pageSize: 100,
          ),
          itemBuilder: (context, trip) => ListTile(title: Text(trip.title)),
        ),
      ),
    ),
  );

  // Wait for initial load
  await tester.pumpAndSettle();

  // Scroll to trigger pagination
  final scrollController = tester.widget<InfiniteScrollListView<Trip>>(
    find.byType(InfiniteScrollListView<Trip>)
  ).controller as ScrollController;

  // Simulate scrolling to end
  scrollController.jumpTo(scrollController.position.maxScrollExtent);
  await tester.pumpAndSettle();

  // Verify multiple pages loaded
  expect(find.text('Trip 1_0'), findsOneWidget);
  expect(find.text('Trip 2_0'), findsOneWidget);
});
```

## Troubleshooting

### Items Not Loading

- **Issue**: List shows loading indicator but never displays items
- **Solution**:
  1. Check that `fetchData` returns valid `PaginatedData<T>`
  2. Verify `pageInfo.hasNextPage` is set correctly
  3. Ensure `itemBuilder` returns a non-null widget
  4. Check for errors in debug console

### Pagination Not Triggering

- **Issue**: Next page doesn't load when scrolling
- **Solution**:
  1. Check `preloadThreshold` (default: 500px)
  2. Verify `pageInfo.nextCursor` is not null
  3. Ensure `hasNextPage` is true in `PageInfo`
  4. Check that `_isLoadingNextPage` flag is not stuck

### Duplicate Items

- **Issue**: Same items appear multiple times in list
- **Solution**:
  1. Use cursor-based pagination (recommended)
  2. Verify backend returns consistent cursor values
  3. Check that items are not duplicated in repository response

### Memory Issues

- **Issue**: App uses too much memory with many items
- **Solution**:
  1. Use smaller page size (e.g., 20 instead of 100)
  2. Implement item recycling with `ValueKey`
  3. Use `LazyLoadImage` for photo lists
  4. Consider pagination cleanup (remove old pages)

## API Reference

### InfiniteScrollListView Constructor

```dart
InfiniteScrollListView<T>({
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
  Axis scrollDirection = Axis.vertical,
  EdgeInsets? padding,
  ScrollController? controller,
})
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `fetchData` | `PaginatedDataFetcher<T>` | required | Function to fetch paginated data |
| `itemBuilder` | `ItemWidgetBuilder<T>` | required | Builds widget for each item |
| `separatorBuilder` | `NullableItemWidgetBuilder<T>?` | null | Builds separator between items |
| `header` | `Widget?` | null | Widget at top of list |
| `footer` | `Widget?` | null | Widget at bottom of list |
| `emptyWidget` | `Widget?` | null | Widget when list is empty |
| `initialLoadingWidget` | `Widget?` | null | Widget during initial load |
| `loadingMoreWidget` | `Widget?` | null | Widget during pagination |
| `errorWidget` | `Widget?` | null | Widget on error |
| `endOfListWidget` | `Widget?` | null | Widget when no more pages |
| `enablePullToRefresh` | `bool` | true | Enable pull-to-refresh |
| `preloadThreshold` | `double` | 500.0 | Distance from end to load (px) |
| `scrollDirection` | `Axis` | vertical | Scroll direction |
| `padding` | `EdgeInsets?` | null | Padding around list |
| `controller` | `ScrollController?` | null | Optional scroll controller |

## Best Practices

1. **Use cursor-based pagination** for infinite scroll (recommended)
2. **Set appropriate page size** (20-50 items typically)
3. **Adjust preload threshold** based on your use case
4. **Use ValueKey in itemBuilder** for proper widget recycling
5. **Handle errors gracefully** with custom error widgets
6. **Provide empty state** with helpful message and action
7. **Use LazyLoadImage** for photo galleries
8. **Consider performance** with metadata queries for list views
9. **Test with large datasets** (500+ items) to ensure performance
10. **Monitor memory usage** with performance tracking tools

## Comparison with Other Approaches

| Feature | InfiniteScrollListView | Manual Implementation | PaginationButtons |
|---------|----------------------|----------------------|------------------|
| Automatic loading | ✅ | ❌ Manual | ❌ Manual |
| Memory efficient | ✅ Virtual scrolling | ❌ All items | ⚠️ Depends |
| Pull-to-refresh | ✅ Built-in | ❌ Manual | ❌ Manual |
| Error handling | ✅ Built-in | ❌ Manual | ❌ Manual |
| Loading states | ✅ Built-in | ❌ Manual | ⚠️ Partial |
| Preloading | ✅ Configurable | ❌ Manual | ❌ No |
| Code complexity | Low | High | Medium |
| Maintenance | Easy | Hard | Medium |

## See Also

- [VirtualListView](virtual_list_view.dart) - Virtual scrolling list widget
- [VirtualGridView](virtual_grid_view.dart) - Virtual scrolling grid widget
- [PaginatedData](../models/paginated_data.dart) - Paginated data model
- [PageInfo](../models/page_info.dart) - Pagination metadata model
- [TripRepository](../../features/travel/domain/repositories/trip_repository.dart) - Repository example
