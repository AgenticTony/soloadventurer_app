import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/models/paginated_data.dart';
import 'package:soloadventurer/core/models/page_info.dart';
import 'package:soloadventurer/core/widgets/infinite_scroll_list_view.dart';

void main() {
  group('InfiniteScrollListView', () {
    late MockPaginatedDataFetcher mockFetcher;

    setUp(() {
      mockFetcher = MockPaginatedDataFetcher();
    });

    testWidgets('renders initial loading state', (WidgetTester tester) async {
      // Setup mock to return data
      mockFetcher.setData(
        PaginatedData<String>(
          items: ['Item 1', 'Item 2'],
          pageInfo: PageInfo(
            currentPage: 1,
            itemsPerPage: 20,
            hasNextPage: true,
            hasPreviousPage: false,
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteScrollListView<String>(
              fetchData: mockFetcher.fetch,
              itemBuilder: (context, item) => Text(item),
            ),
          ),
        ),
      );

      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders items after data loads', (WidgetTester tester) async {
      mockFetcher.setData(
        PaginatedData<String>(
          items: ['Item 1', 'Item 2', 'Item 3'],
          pageInfo: PageInfo(
            currentPage: 1,
            itemsPerPage: 20,
            hasNextPage: false,
            hasPreviousPage: false,
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteScrollListView<String>(
              fetchData: mockFetcher.fetch,
              itemBuilder: (context, item) => Text(item),
            ),
          ),
        ),
      );

      // Wait for async data load
      await tester.pumpAndSettle();

      // Verify items are rendered
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('shows empty widget when no data', (WidgetTester tester) async {
      mockFetcher.setData(
        PaginatedData<String>(
          items: [],
          pageInfo: PageInfo(
            currentPage: 1,
            itemsPerPage: 20,
            hasNextPage: false,
            hasPreviousPage: false,
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteScrollListView<String>(
              fetchData: mockFetcher.fetch,
              itemBuilder: (context, item) => Text(item),
              emptyWidget: const Center(child: Text('No items')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No items'), findsOneWidget);
    });

    testWidgets('shows error widget on fetch error', (WidgetTester tester) async {
      mockFetcher.setError(Exception('Network error'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteScrollListView<String>(
              fetchData: mockFetcher.fetch,
              itemBuilder: (context, item) => Text(item),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show error icon
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      // Should show retry button
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows loading more indicator when loading next page',
        (WidgetTester tester) async {
      // First page
      mockFetcher.setData(
        PaginatedData<String>(
          items: ['Item 1', 'Item 2'],
          pageInfo: PageInfo(
            currentPage: 1,
            itemsPerPage: 20,
            hasNextPage: true,
            hasPreviousPage: false,
            nextCursor: 'page1',
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteScrollListView<String>(
              fetchData: mockFetcher.fetch,
              itemBuilder: (context, item) => ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Setup second page
      mockFetcher.setData(
        PaginatedData<String>(
          items: ['Item 3', 'Item 4'],
          pageInfo: PageInfo(
            currentPage: 2,
            itemsPerPage: 20,
            hasNextPage: false,
            hasPreviousPage: true,
          ),
        ),
      );

      // Scroll to trigger pagination
      final scrollable = find.byType(Scrollable);
      await tester.drag(scrollable, const Offset(0, -500));
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows end of list widget when no more pages',
        (WidgetTester tester) async {
      mockFetcher.setData(
        PaginatedData<String>(
          items: ['Item 1', 'Item 2'],
          pageInfo: PageInfo(
            currentPage: 1,
            itemsPerPage: 20,
            hasNextPage: false,
            hasPreviousPage: false,
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteScrollListView<String>(
              fetchData: mockFetcher.fetch,
              itemBuilder: (context, item) => ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show end of list indicator
      expect(find.text('You\'ve reached the end'), findsOneWidget);
    });

    testWidgets('renders separators between items', (WidgetTester tester) async {
      mockFetcher.setData(
        PaginatedData<String>(
          items: ['Item 1', 'Item 2', 'Item 3'],
          pageInfo: PageInfo(
            currentPage: 1,
            itemsPerPage: 20,
            hasNextPage: false,
            hasPreviousPage: false,
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteScrollListView<String>(
              fetchData: mockFetcher.fetch,
              itemBuilder: (context, item) => Text(item),
              separatorBuilder: (context, index) => const Divider(height: 1),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have 3 dividers (n items - 1)
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('renders header widget', (WidgetTester tester) async {
      mockFetcher.setData(
        PaginatedData<String>(
          items: ['Item 1'],
          pageInfo: PageInfo(
            currentPage: 1,
            itemsPerPage: 20,
            hasNextPage: false,
            hasPreviousPage: false,
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteScrollListView<String>(
              fetchData: mockFetcher.fetch,
              itemBuilder: (context, item) => Text(item),
              header: const Text('Header'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Header'), findsOneWidget);
    });

    testWidgets('renders footer widget', (WidgetTester tester) async {
      mockFetcher.setData(
        PaginatedData<String>(
          items: ['Item 1'],
          pageInfo: PageInfo(
            currentPage: 1,
            itemsPerPage: 20,
            hasNextPage: false,
            hasPreviousPage: false,
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteScrollListView<String>(
              fetchData: mockFetcher.fetch,
              itemBuilder: (context, item) => Text(item),
              footer: const Text('Footer'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Footer'), findsOneWidget);
    });

    testWidgets('handles pull-to-refresh', (WidgetTester tester) async {
      int fetchCount = 0;

      mockFetcher.setData(
        PaginatedData<String>(
          items: ['Item 1', 'Item 2'],
          pageInfo: PageInfo(
            currentPage: 1,
            itemsPerPage: 20,
            hasNextPage: true,
            hasPreviousPage: false,
            nextCursor: 'page1',
          ),
        ),
        onFetch: () => fetchCount++,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteScrollListView<String>(
              fetchData: mockFetcher.fetch,
              itemBuilder: (context, item) => ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(fetchCount, 1);

      // Perform pull-to-refresh
      await tester.drag(
        find.byType(RefreshIndicator),
        const Offset(0, 300),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('respects preload threshold', (WidgetTester tester) async {
      int fetchCount = 0;

      // First page
      mockFetcher.setData(
        PaginatedData<String>(
          items: List.generate(20, (i) => 'Item $i'),
          pageInfo: PageInfo(
            currentPage: 1,
            itemsPerPage: 20,
            hasNextPage: true,
            hasPreviousPage: false,
            nextCursor: 'page1',
          ),
        ),
        onFetch: () => fetchCount++,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteScrollListView<String>(
              fetchData: mockFetcher.fetch,
              itemBuilder: (context, item) => Container(
                height: 50,
                child: Text(item),
              ),
              preloadThreshold: 100.0, // Load when 100px from end
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(fetchCount, 1);

      // Setup second page
      mockFetcher.setData(
        PaginatedData<String>(
          items: List.generate(20, (i) => 'Item ${i + 20}'),
          pageInfo: PageInfo(
            currentPage: 2,
            itemsPerPage: 20,
            hasNextPage: false,
            hasPreviousPage: true,
          ),
        ),
      );

      // Scroll near the end (should trigger pagination)
      final scrollable = find.byType(Scrollable);
      await tester.drag(scrollable, const Offset(0, -900)); // Scroll close to end
      await tester.pump();

      // Should have triggered next page load
      expect(fetchCount, greaterThan(1));
    });

    testWidgets('works with custom scroll controller',
        (WidgetTester tester) async {
      final controller = ScrollController();

      mockFetcher.setData(
        PaginatedData<String>(
          items: ['Item 1', 'Item 2'],
          pageInfo: PageInfo(
            currentPage: 1,
            itemsPerPage: 20,
            hasNextPage: false,
            hasPreviousPage: false,
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteScrollListView<String>(
              fetchData: mockFetcher.fetch,
              itemBuilder: (context, item) => Text(item),
              controller: controller,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify controller is attached
      expect(controller.hasClients, true);

      controller.dispose();
    });

    testWidgets('renders custom initial loading widget',
        (WidgetTester tester) async {
      mockFetcher.setData(
        PaginatedData<String>(
          items: ['Item 1'],
          pageInfo: PageInfo(
            currentPage: 1,
            itemsPerPage: 20,
            hasNextPage: false,
            hasPreviousPage: false,
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteScrollListView<String>(
              fetchData: mockFetcher.fetch,
              itemBuilder: (context, item) => Text(item),
              initialLoadingWidget: const Center(
                child: Text('Custom Loading...'),
              ),
            ),
          ),
        ),
      );

      // Should show custom loading widget
      expect(find.text('Custom Loading...'), findsOneWidget);

      await tester.pumpAndSettle();

      // After loading, should show data
      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets('renders custom loading more widget', (WidgetTester tester) async {
      // First page
      mockFetcher.setData(
        PaginatedData<String>(
          items: ['Item 1', 'Item 2'],
          pageInfo: PageInfo(
            currentPage: 1,
            itemsPerPage: 20,
            hasNextPage: true,
            hasPreviousPage: false,
            nextCursor: 'page1',
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteScrollListView<String>(
              fetchData: mockFetcher.fetch,
              itemBuilder: (context, item) => ListTile(title: Text(item)),
              loadingMoreWidget: const Center(
                child: Text('Loading More...'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Setup second page
      mockFetcher.setData(
        PaginatedData<String>(
          items: ['Item 3', 'Item 4'],
          pageInfo: PageInfo(
            currentPage: 2,
            itemsPerPage: 20,
            hasNextPage: false,
            hasPreviousPage: true,
          ),
        ),
      );

      // Scroll to trigger pagination
      final scrollable = find.byType(Scrollable);
      await tester.drag(scrollable, const Offset(0, -500));
      await tester.pump();

      // Should show custom loading more widget
      expect(find.text('Loading More...'), findsOneWidget);
    });

    testWidgets('disables pull-to-refresh when configured',
        (WidgetTester tester) async {
      mockFetcher.setData(
        PaginatedData<String>(
          items: ['Item 1'],
          pageInfo: PageInfo(
            currentPage: 1,
            itemsPerPage: 20,
            hasNextPage: false,
            hasPreviousPage: false,
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteScrollListView<String>(
              fetchData: mockFetcher.fetch,
              itemBuilder: (context, item) => Text(item),
              enablePullToRefresh: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not have RefreshIndicator
      expect(find.byType(RefreshIndicator), findsNothing);
    });
  });

  group('InfiniteScrollState', () {
    test('creates initial state correctly', () {
      const state = InfiniteScrollState<String>();

      expect(state.items, isEmpty);
      expect(state.status, InfiniteScrollStatus.initialLoading);
      expect(state.pageInfo, null);
      expect(state.errorMessage, null);
      expect(state.hasNextPage, false);
    });

    test('copyWith updates fields correctly', () {
      const state = InfiniteScrollState<String>(
        items: ['Item 1'],
        status: InfiniteScrollStatus.loaded,
      );

      final updated = state.copyWith(
        items: ['Item 1', 'Item 2'],
        status: InfiniteScrollStatus.loadingMore,
      );

      expect(updated.items, ['Item 1', 'Item 2']);
      expect(updated.status, InfiniteScrollStatus.loadingMore);
    });

    test('calculates hasNextPage correctly', () {
      final state = InfiniteScrollState<String>(
        items: ['Item 1'],
        pageInfo: PageInfo(
          currentPage: 1,
          itemsPerPage: 20,
          hasNextPage: true,
          hasPreviousPage: false,
        ),
      );

      expect(state.hasNextPage, true);
    });

    test('calculates isLoading correctly', () {
      final initialLoading = InfiniteScrollState<String>(
        status: InfiniteScrollStatus.initialLoading,
      );
      expect(initialLoading.isLoading, true);

      final loadingMore = InfiniteScrollState<String>(
        status: InfiniteScrollStatus.loadingMore,
      );
      expect(loadingMore.isLoading, true);

      final loaded = InfiniteScrollState<String>(
        status: InfiniteScrollStatus.loaded,
      );
      expect(loaded.isLoading, false);
    });
  });

  group('InfiniteScrollStatus', () {
    test('has correct values', () {
      expect(InfiniteScrollStatus.initialLoading, isNotNull);
      expect(InfiniteScrollStatus.loaded, isNotNull);
      expect(InfiniteScrollStatus.loadingMore, isNotNull);
      expect(InfiniteScrollStatus.error, isNotNull);
      expect(InfiniteScrollStatus.reachedEnd, isNotNull);
    });
  });
}

/// Mock data fetcher for testing
class MockPaginatedDataFetcher {
  PaginatedData<String>? _data;
  Exception? _error;
  VoidCallback? _onFetch;

  void setData(PaginatedData<String> data, {VoidCallback? onFetch}) {
    _data = data;
    _error = null;
    _onFetch = onFetch;
  }

  void setError(Exception error) {
    _error = error;
    _data = null;
  }

  Future<PaginatedData<String>> fetch(String? cursor) async {
    _onFetch?.call();

    if (_error != null) {
      throw _error!;
    }

    if (_data != null) {
      await Future.delayed(const Duration(milliseconds: 100));
      return _data!;
    }

    throw Exception('No data set');
  }
}
