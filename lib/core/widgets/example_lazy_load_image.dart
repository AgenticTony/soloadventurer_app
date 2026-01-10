import 'package:flutter/material.dart';
import 'package:soloadventurer/core/widgets/widgets.dart';

/// Example implementations demonstrating various use cases of [LazyLoadImage]
///
/// These examples show how to use the LazyLoadImage widget in different
/// scenarios and configurations.
///
/// ## Examples Included
///
/// 1. [ExampleBasicLazyLoadImage] - Basic usage with URL
/// 2. [ExamplePhotoGrid] - Photo grid with square images
/// 3. [ExampleCardImage] - Card layout with rectangular images
/// 4. [ExampleThumbnailList] - List with small thumbnails
/// 5. [ExampleCustomPlaceholder] - Custom placeholder widget
/// 6. [ExampleCustomErrorWidget] - Custom error handling
/// 7. [ExampleWithBorderRadius] - Rounded corners
/// 8. [ExampleWithThumbnail] - Thumbnail loading first
/// 9. [ExampleCustomVisibility] - Custom visibility threshold
/// 10. [ExampleNoAnimation] - Disable fade-in animation

/// Example 1: Basic lazy loading image
///
/// Demonstrates the simplest usage of LazyLoadImage with just a URL.
class ExampleBasicLazyLoadImage extends StatelessWidget {
  const ExampleBasicLazyLoadImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Lazy Load Image')),
      body: const Center(
        child: LazyLoadImage(
          imageUrl: 'https://picsum.photos/400/400',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}

/// Example 2: Photo grid with square images
///
/// Demonstrates using LazyLoadImage.photo() for a photo gallery grid.
class ExamplePhotoGrid extends StatelessWidget {
  const ExamplePhotoGrid({super.key});

  // Simulated photo URLs
  static const List<String> _photos = [
    'https://picsum.photos/200/200?random=1',
    'https://picsum.photos/200/200?random=2',
    'https://picsum.photos/200/200?random=3',
    'https://picsum.photos/200/200?random=4',
    'https://picsum.photos/200/200?random=5',
    'https://picsum.photos/200/200?random=6',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo Grid')),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          return LazyLoadImage.photo(
            key: ValueKey('photo_$index'),
            imageUrl: _photos[index],
            placeholder: (context, url) => Container(
              color: Colors.grey[300],
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}

/// Example 3: Card layout with rectangular images
///
/// Demonstrates using LazyLoadImage.card() for card-based layouts.
class ExampleCardImage extends StatelessWidget {
  const ExampleCardImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card Image')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LazyLoadImage.card(
                  imageUrl: 'https://picsum.photos/600/400?random=10',
                  height: 200.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Beautiful Destination',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        'This is a sample card with a lazy-loaded cover image.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 4: List with small thumbnails
///
/// Demonstrates using LazyLoadImage.thumbnail() for list items.
class ExampleThumbnailList extends StatelessWidget {
  const ExampleThumbnailList({super.key});

  static const List<Map<String, String>> _items = [
    {
      'title': 'Trip to Paris',
      'image': 'https://picsum.photos/100/100?random=20'
    },
    {
      'title': 'Tokyo Adventure',
      'image': 'https://picsum.photos/100/100?random=21'
    },
    {
      'title': 'New York City',
      'image': 'https://picsum.photos/100/100?random=22'
    },
    {
      'title': 'Sydney Harbour',
      'image': 'https://picsum.photos/100/100?random=23'
    },
    {'title': 'Dubai Trip', 'image': 'https://picsum.photos/100/100?random=24'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thumbnail List')),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return ListTile(
            leading: LazyLoadImage.thumbnail(
              key: ValueKey('thumb_$index'),
              imageUrl: item['image']!,
            ),
            title: Text(item['title']!),
            subtitle: const Text('Tap to view details'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Handle navigation
            },
          );
        },
      ),
    );
  }
}

/// Example 5: Custom placeholder widget
///
/// Demonstrates providing a custom placeholder with branded styling.
class ExampleCustomPlaceholder extends StatelessWidget {
  const ExampleCustomPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Placeholder')),
      body: Center(
        child: LazyLoadImage(
          imageUrl: 'https://picsum.photos/400/400?random=30',
          width: 300,
          height: 300,
          placeholder: (context, url) => Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade100,
                  Colors.purple.shade100,
                ],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading beautiful photo...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Example 6: Custom error widget
///
/// Demonstrates providing a custom error widget with retry option.
class ExampleCustomErrorWidget extends StatelessWidget {
  const ExampleCustomErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Error Widget')),
      body: Center(
        child: LazyLoadImage(
          // Intentionally using invalid URL to trigger error
          imageUrl: 'https://invalid-url-that-does-not-exist.com/image.jpg',
          width: 300,
          height: 300,
          placeholder: (context, url) => Container(
            width: 300,
            height: 300,
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            width: 300,
            height: 300,
            color: Colors.red.shade50,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Failed to load image'),
                  SizedBox(height: 8),
                  Text(
                    'Tap to retry',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Example 7: Image with border radius
///
/// Demonstrates using borderRadius parameter for rounded corners.
class ExampleWithBorderRadius extends StatelessWidget {
  const ExampleWithBorderRadius({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('With Border Radius')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Small Border Radius'),
            const SizedBox(height: 8),
            LazyLoadImage.photo(
              imageUrl: 'https://picsum.photos/200/200?random=40',
              borderRadius: BorderRadius.circular(8.0),
            ),
            const SizedBox(height: 24),
            const Text('Large Border Radius'),
            const SizedBox(height: 8),
            LazyLoadImage.photo(
              imageUrl: 'https://picsum.photos/200/200?random=41',
              borderRadius: BorderRadius.circular(32.0),
            ),
            const SizedBox(height: 24),
            const Text('Circular'),
            const SizedBox(height: 8),
            LazyLoadImage.photo(
              imageUrl: 'https://picsum.photos/200/200?random=42',
              borderRadius: BorderRadius.circular(100.0),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 8: Image with thumbnail loading
///
/// Demonstrates loading a small thumbnail first, then the full image.
class ExampleWithThumbnail extends StatelessWidget {
  const ExampleWithThumbnail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('With Thumbnail')),
      body: Center(
        child: LazyLoadImage(
          imageUrl: 'https://picsum.photos/800/800?random=50',
          thumbnailUrl: 'https://picsum.photos/200/200?random=50',
          width: 300,
          height: 300,
          placeholder: (context, url) => Container(
            width: 300,
            height: 300,
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}

/// Example 9: Custom visibility threshold
///
/// Demonstrates adjusting when images start loading.
class ExampleCustomVisibility extends StatelessWidget {
  const ExampleCustomVisibility({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Visibility')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          Text('Load when 10% visible'),
          SizedBox(height: 8),
          LazyLoadImage(
            imageUrl: 'https://picsum.photos/600/200?random=60',
            height: 150,
            visibilityThreshold: 0.1,
          ),
          SizedBox(height: 24),
          Text('Load when 50% visible'),
          SizedBox(height: 8),
          LazyLoadImage(
            imageUrl: 'https://picsum.photos/600/200?random=61',
            height: 150,
            visibilityThreshold: 0.5,
          ),
          SizedBox(height: 24),
          Text('Load when 100% visible'),
          SizedBox(height: 8),
          LazyLoadImage(
            imageUrl: 'https://picsum.photos/600/200?random=62',
            height: 150,
            visibilityThreshold: 1.0,
          ),
        ],
      ),
    );
  }
}

/// Example 10: No fade-in animation
///
/// Demonstrates disabling the fade-in animation.
class ExampleNoAnimation extends StatelessWidget {
  const ExampleNoAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('No Animation')),
      body: const Center(
        child: LazyLoadImage(
          imageUrl: 'https://picsum.photos/400/400?random=70',
          width: 300,
          height: 300,
          fadeInDuration: Duration.zero, // No fade-in
        ),
      ),
    );
  }
}

/// Example app showcasing all LazyLoadImage implementations
class ExampleLazyLoadImageApp extends StatelessWidget {
  const ExampleLazyLoadImageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LazyLoadImage Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExampleLazyLoadImageHome(),
    );
  }
}

/// Home screen with navigation to all examples
class ExampleLazyLoadImageHome extends StatelessWidget {
  const ExampleLazyLoadImageHome({super.key});

  static final List<Map<String, dynamic>> _examples = [
    {'title': 'Basic Lazy Load', 'widget': const ExampleBasicLazyLoadImage()},
    {'title': 'Photo Grid', 'widget': const ExamplePhotoGrid()},
    {'title': 'Card Image', 'widget': const ExampleCardImage()},
    {'title': 'Thumbnail List', 'widget': const ExampleThumbnailList()},
    {'title': 'Custom Placeholder', 'widget': const ExampleCustomPlaceholder()},
    {
      'title': 'Custom Error Widget',
      'widget': const ExampleCustomErrorWidget()
    },
    {'title': 'Border Radius', 'widget': const ExampleWithBorderRadius()},
    {'title': 'Thumbnail Loading', 'widget': const ExampleWithThumbnail()},
    {'title': 'Custom Visibility', 'widget': const ExampleCustomVisibility()},
    {'title': 'No Animation', 'widget': const ExampleNoAnimation()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LazyLoadImage Examples'),
      ),
      body: ListView.builder(
        itemCount: _examples.length,
        itemBuilder: (context, index) {
          final example = _examples[index];
          return ListTile(
            title: Text(example['title'] as String),
            subtitle: Text('Example ${index + 1}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => example['widget'] as Widget,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Run the examples:
// void main() => runApp(const ExampleLazyLoadImageApp());
