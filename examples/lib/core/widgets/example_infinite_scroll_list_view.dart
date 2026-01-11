import 'package:flutter/material.dart';
import 'infinite_scroll_list_view.dart';
import '../models/paginated_data.dart';
import '../models/page_info.dart';

/// Example 1: Basic infinite scroll list with minimal configuration
class ExampleBasicInfiniteScroll extends StatelessWidget {
  const ExampleBasicInfiniteScroll({super.key});

  // Simulate fetching paginated data
  Future<PaginatedData<String>> _fetchData(String? cursor) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Parse cursor (page number)
    final page = cursor == null ? 1 : int.parse(cursor);
    final items = List.generate(
      20,
      (i) => 'Item ${(page - 1) * 20 + i + 1}',
    );

    return PaginatedData(
      items: items,
      pageInfo: PageInfo(
        currentPage: page,
        itemsPerPage: 20,
        totalItems: 100,
        totalPages: 5,
        hasNextPage: page < 5,
        hasPreviousPage: page > 1,
        nextCursor: page < 5 ? '$page' : null,
        previousCursor: page > 1 ? '${page - 2}' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 1: Basic')),
      body: InfiniteScrollListView<String>(
        fetchData: _fetchData,
        itemBuilder: (context, item) => ListTile(
          title: Text(item),
          leading: const CircleAvatar(child: Icon(Icons.list)),
        ),
      ),
    );
  }
}

/// Example 2: Infinite scroll with separators
class ExampleInfiniteScrollWithSeparators extends StatelessWidget {
  const ExampleInfiniteScrollWithSeparators({super.key});

  Future<PaginatedData<String>> _fetchData(String? cursor) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final page = cursor == null ? 1 : int.parse(cursor);
    final items = List.generate(
      20,
      (i) => 'Message ${(page - 1) * 20 + i + 1}',
    );

    return PaginatedData(
      items: items,
      pageInfo: PageInfo(
        currentPage: page,
        itemsPerPage: 20,
        totalItems: 100,
        totalPages: 5,
        hasNextPage: page < 5,
        hasPreviousPage: page > 1,
        nextCursor: page < 5 ? '$page' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 2: With Separators')),
      body: InfiniteScrollListView<String>.withSeparators(
        fetchData: _fetchData,
        itemBuilder: (context, item) => ListTile(
          title: Text(item),
          leading: const Icon(Icons.message),
        ),
        separatorBuilder: (context, index) => const Divider(height: 1),
      ),
    );
  }
}

/// Example 3: Infinite scroll with custom widgets
class ExampleInfiniteScrollCustomWidgets extends StatelessWidget {
  const ExampleInfiniteScrollCustomWidgets({super.key});

  Future<PaginatedData<String>> _fetchData(String? cursor) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final page = cursor == null ? 1 : int.parse(cursor);
    final items = List.generate(
      20,
      (i) => 'Product ${(page - 1) * 20 + i + 1}',
    );

    return PaginatedData(
      items: items,
      pageInfo: PageInfo(
        currentPage: page,
        itemsPerPage: 20,
        totalItems: 100,
        totalPages: 5,
        hasNextPage: page < 5,
        hasPreviousPage: page > 1,
        nextCursor: page < 5 ? '$page' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 3: Custom Widgets')),
      body: InfiniteScrollListView<String>(
        fetchData: _fetchData,
        itemBuilder: (context, item) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(item),
            leading: const CircleAvatar(child: Icon(Icons.shopping_cart)),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        ),
        // Custom initial loading widget
        initialLoadingWidget: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading products...'),
            ],
          ),
        ),
        // Custom loading more widget
        loadingMoreWidget: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Loading more products...'),
            ],
          ),
        ),
        // Custom error widget
        errorWidget: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load products',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text('Please check your connection'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        // Custom empty widget
        emptyWidget: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_basket_outlined,
                  size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No products found', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Try adjusting your filters'),
            ],
          ),
        ),
        // Custom end of list widget
        endOfListWidget: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              SizedBox(width: 8),
              Text('All products loaded', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Example 4: Infinite scroll with header and footer
class ExampleInfiniteScrollWithHeaderFooter extends StatelessWidget {
  const ExampleInfiniteScrollWithHeaderFooter({super.key});

  Future<PaginatedData<String>> _fetchData(String? cursor) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final page = cursor == null ? 1 : int.parse(cursor);
    final items = List.generate(
      20,
      (i) => 'Notification ${(page - 1) * 20 + i + 1}',
    );

    return PaginatedData(
      items: items,
      pageInfo: PageInfo(
        currentPage: page,
        itemsPerPage: 20,
        totalItems: 100,
        totalPages: 5,
        hasNextPage: page < 5,
        hasPreviousPage: page > 1,
        nextCursor: page < 5 ? '$page' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 4: Header & Footer')),
      body: InfiniteScrollListView<String>(
        fetchData: _fetchData,
        itemBuilder: (context, item) => ListTile(
          title: Text(item),
          leading: const Icon(Icons.notifications),
          trailing: const Icon(Icons.chevron_right),
        ),
        separatorBuilder: (context, index) => const Divider(height: 1),
        // Header at the top
        header: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border:
                const Border(bottom: BorderSide(color: Colors.grey, width: 1)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pull down to refresh your notifications',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        // Footer at the bottom (after loading indicator)
        footer: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: const Border(top: BorderSide(color: Colors.grey, width: 1)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Showing notifications from the last 30 days'),
            ],
          ),
        ),
      ),
    );
  }
}

/// Example 5: Infinite scroll with custom preload threshold
class ExampleInfiniteScrollPreloadThreshold extends StatelessWidget {
  const ExampleInfiniteScrollPreloadThreshold({super.key});

  Future<PaginatedData<String>> _fetchData(String? cursor) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final page = cursor == null ? 1 : int.parse(cursor);
    final items = List.generate(
      20,
      (i) => 'Article ${(page - 1) * 20 + i + 1}',
    );

    return PaginatedData(
      items: items,
      pageInfo: PageInfo(
        currentPage: page,
        itemsPerPage: 20,
        totalItems: 100,
        totalPages: 5,
        hasNextPage: page < 5,
        hasPreviousPage: page > 1,
        nextCursor: page < 5 ? '$page' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 5: Preload Threshold')),
      body: InfiniteScrollListView<String>(
        fetchData: _fetchData,
        itemBuilder: (context, item) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Article preview text goes here...'),
              ],
            ),
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        // Load next page 300px before reaching end (default is 500px)
        // This makes pagination feel faster
        preloadThreshold: 300.0,
      ),
    );
  }
}

/// Example 6: Infinite scroll with custom scroll controller
class ExampleInfiniteScrollWithController extends StatefulWidget {
  const ExampleInfiniteScrollWithController({super.key});

  @override
  State<ExampleInfiniteScrollWithController> createState() =>
      _ExampleInfiniteScrollWithControllerState();
}

class _ExampleInfiniteScrollWithControllerState
    extends State<ExampleInfiniteScrollWithController> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<PaginatedData<String>> _fetchData(String? cursor) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final page = cursor == null ? 1 : int.parse(cursor);
    final items = List.generate(
      20,
      (i) => 'Comment ${(page - 1) * 20 + i + 1}',
    );

    return PaginatedData(
      items: items,
      pageInfo: PageInfo(
        currentPage: page,
        itemsPerPage: 20,
        totalItems: 100,
        totalPages: 5,
        hasNextPage: page < 5,
        hasPreviousPage: page > 1,
        nextCursor: page < 5 ? '$page' : null,
      ),
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 6: Custom Controller')),
      body: InfiniteScrollListView<String>(
        fetchData: _fetchData,
        itemBuilder: (context, item) => ListTile(
          title: Text(item),
          leading: const CircleAvatar(child: Icon(Icons.person)),
        ),
        separatorBuilder: (context, index) => const Divider(height: 1),
        controller: _scrollController,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scrollToTop,
        child: const Icon(Icons.arrow_upward),
      ),
    );
  }
}

/// Example 7: Infinite scroll with error handling
class ExampleInfiniteScrollWithErrorHandling extends StatelessWidget {
  const ExampleInfiniteScrollWithErrorHandling({super.key});

  Future<PaginatedData<String>> _fetchData(String? cursor) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate error on second page
    if (cursor != null && int.parse(cursor) == 1) {
      throw Exception('Network error: Failed to load page 2');
    }

    final page = cursor == null ? 1 : int.parse(cursor);
    final items = List.generate(
      20,
      (i) => 'Task ${(page - 1) * 20 + i + 1}',
    );

    return PaginatedData(
      items: items,
      pageInfo: PageInfo(
        currentPage: page,
        itemsPerPage: 20,
        totalItems: 100,
        totalPages: 5,
        hasNextPage: page < 5,
        hasPreviousPage: page > 1,
        nextCursor: page < 5 ? '$page' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 7: Error Handling')),
      body: InfiniteScrollListView<String>(
        fetchData: _fetchData,
        itemBuilder: (context, item) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: CheckboxListTile(
            title: Text(item),
            value: false,
            onChanged: (value) {},
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        padding: const EdgeInsets.all(8),
        // Custom error widget
        errorWidget: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 48, color: Colors.orange),
                const SizedBox(height: 16),
                const Text(
                  'Connection Error',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Failed to load tasks. Check your connection.'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Example 8: Infinite scroll without pull-to-refresh
class ExampleInfiniteScrollNoRefresh extends StatelessWidget {
  const ExampleInfiniteScrollNoRefresh({super.key});

  Future<PaginatedData<String>> _fetchData(String? cursor) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final page = cursor == null ? 1 : int.parse(cursor);
    final items = List.generate(
      20,
      (i) => 'Item ${(page - 1) * 20 + i + 1}',
    );

    return PaginatedData(
      items: items,
      pageInfo: PageInfo(
        currentPage: page,
        itemsPerPage: 20,
        totalItems: 100,
        totalPages: 5,
        hasNextPage: page < 5,
        hasPreviousPage: page > 1,
        nextCursor: page < 5 ? '$page' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 8: No Refresh')),
      body: InfiniteScrollListView<String>(
        fetchData: _fetchData,
        itemBuilder: (context, item) => ListTile(
          title: Text(item),
          leading: const CircleAvatar(child: Text('📝')),
        ),
        // Disable pull-to-refresh
        enablePullToRefresh: false,
      ),
    );
  }
}

/// Main example app with navigation to all examples
class InfiniteScrollExamplesApp extends StatelessWidget {
  const InfiniteScrollExamplesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinite Scroll Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const InfiniteScrollExamplesHome(),
    );
  }
}

class InfiniteScrollExamplesHome extends StatelessWidget {
  const InfiniteScrollExamplesHome({super.key});

  static final List<Map<String, dynamic>> _examples = [
    {
      'title': 'Basic Infinite Scroll',
      'description': 'Minimal configuration with default widgets',
      'widget': const ExampleBasicInfiniteScroll(),
    },
    {
      'title': 'With Separators',
      'description': 'List with dividers between items',
      'widget': const ExampleInfiniteScrollWithSeparators(),
    },
    {
      'title': 'Custom Widgets',
      'description': 'Custom loading, error, and empty states',
      'widget': const ExampleInfiniteScrollCustomWidgets(),
    },
    {
      'title': 'Header & Footer',
      'description': 'Add widgets at top and bottom',
      'widget': const ExampleInfiniteScrollWithHeaderFooter(),
    },
    {
      'title': 'Preload Threshold',
      'description': 'Adjust when next page loads',
      'widget': const ExampleInfiniteScrollPreloadThreshold(),
    },
    {
      'title': 'Custom Controller',
      'description': 'Use custom scroll controller',
      'widget': const ExampleInfiniteScrollWithController(),
    },
    {
      'title': 'Error Handling',
      'description': 'Simulated error with custom error widget',
      'widget': const ExampleInfiniteScrollWithErrorHandling(),
    },
    {
      'title': 'No Pull-to-Refresh',
      'description': 'Disable pull-to-refresh gesture',
      'widget': const ExampleInfiniteScrollNoRefresh(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InfiniteScrollListView Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: _examples.length,
        itemBuilder: (context, index) {
          final example = _examples[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(example['title']),
              subtitle: Text(example['description']),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => example['widget'] as Widget,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Run the examples app
void main() {
  runApp(const InfiniteScrollExamplesApp());
}
