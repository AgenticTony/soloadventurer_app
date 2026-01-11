import 'package:flutter/material.dart';
import 'package:soloadventurer/core/widgets/widgets.dart';

/// Example usage of VirtualListView widget
///
/// This file demonstrates various ways to use the VirtualListView widget
/// for efficient rendering of large lists.
class ExampleVirtualListView extends StatelessWidget {
  const ExampleVirtualListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Example 1: Simple list with 500 items
    final items = List.generate(500, (i) => 'Item $i');

    return Scaffold(
      appBar: AppBar(title: const Text('VirtualListView Examples')),
      body: VirtualListView<String>(
        itemCount: items.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(items[index]),
              subtitle: Text('Index: $index'),
            ),
          );
        },
      ),
    );
  }
}

/// Example with separators
class ExampleVirtualListWithSeparators extends StatelessWidget {
  const ExampleVirtualListWithSeparators({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(100, (i) => 'Item $i');

    return Scaffold(
      appBar: AppBar(title: const Text('With Separators')),
      body: VirtualListView<String>(
        itemCount: items.length,
        padding: const EdgeInsets.all(16),
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index]),
            trailing: const Icon(Icons.arrow_forward),
          );
        },
      ),
    );
  }
}

/// Example with loading, error, and empty states
class ExampleVirtualListWithStates extends StatelessWidget {
  const ExampleVirtualListWithStates({
    super.key,
    required this.isLoading,
    required this.hasError,
    required this.isEmpty,
  });

  final bool isLoading;
  final bool hasError;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    final items = isEmpty ? <String>[] : List.generate(100, (i) => 'Item $i');

    return Scaffold(
      appBar: AppBar(title: const Text('With States')),
      body: VirtualListView<String>(
        itemCount: items.length,
        isLoading: isLoading,
        hasError: hasError,
        loadingWidget: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading items...'),
            ],
          ),
        ),
        errorWidget: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text('Failed to load items'),
            ],
          ),
        ),
        emptyWidget: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text('No items found'),
            ],
          ),
        ),
        itemBuilder: (context, index) {
          return ListTile(title: Text(items[index]));
        },
      ),
    );
  }
}

/// Example with header and footer
class ExampleVirtualListWithHeaderFooter extends StatelessWidget {
  const ExampleVirtualListWithHeaderFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(50, (i) => 'Item $i');

    return Scaffold(
      appBar: AppBar(title: const Text('With Header/Footer')),
      body: VirtualListView<String>(
        itemCount: items.length,
        header: const Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Trip Items',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(),
          ],
        ),
        footer: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Total items displayed',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index]),
            subtitle: Text('Subtitle for ${items[index]}'),
          );
        },
      ),
    );
  }
}

/// Example with fixed item extent
class ExampleVirtualListWithFixedExtent extends StatelessWidget {
  const ExampleVirtualListWithFixedExtent({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(500, (i) => 'Item $i');

    return Scaffold(
      appBar: AppBar(title: const Text('Fixed Item Extent')),
      body: VirtualListView<String>(
        itemCount: items.length,
        itemExtent: 80.0, // Fixed height for better performance
        itemBuilder: (context, index) {
          return Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('${index + 1}', style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 16),
                Expanded(child: Text(items[index])),
                const Icon(Icons.chevron_right),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Example horizontal list
class ExampleVirtualListHorizontal extends StatelessWidget {
  const ExampleVirtualListHorizontal({super.key});

  @override
  Widget build(BuildContext context) {
    final colors =
        List.generate(20, (i) => Colors.primaries[i % Colors.primaries.length]);

    return Scaffold(
      appBar: AppBar(title: const Text('Horizontal List')),
      body: VirtualListView.horizontal<Color>(
        itemCount: colors.length,
        itemExtent: 120.0, // Width for horizontal items
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: colors[index],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Color $index',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
