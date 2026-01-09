import 'package:flutter/material.dart';
import 'package:soloadventurer/core/widgets/widgets.dart';

/// Examples demonstrating optimized placeholders and error handling for LazyLoadImage.
///
/// This file contains 8 complete examples showing:
/// 1. Shimmer placeholder (modern, animated)
/// 2. Skeleton placeholder (performant, simple)
/// 3. Color placeholder (theme-aware, subtle)
/// 4. Blurred placeholder (progressive loading)
/// 5. Enhanced error handling with retry
/// 6. Compact error widgets for thumbnails
/// 7. Optimized convenience constructors
/// 8. Progressive blur-up loading effect
///
/// Run this example app to see all the different placeholder and error states in action.
void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Optimized Placeholders Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Optimized Placeholders'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ExampleCard(
            title: '1. Shimmer Placeholder',
            subtitle: 'Modern animated gradient effect',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Example1ShimmerPlaceholder(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ExampleCard(
            title: '2. Skeleton Placeholder',
            subtitle: 'Performant solid color with icon',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Example2SkeletonPlaceholder(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ExampleCard(
            title: '3. Color Placeholder',
            subtitle: 'Theme-aware color with icon',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Example3ColorPlaceholder(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ExampleCard(
            title: '4. Blurred Placeholder',
            subtitle: 'Progressive blur-up loading',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Example4BlurredPlaceholder(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ExampleCard(
            title: '5. Enhanced Error Handling',
            subtitle: 'Retry button with offline detection',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const Example5EnhancedErrorHandling(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ExampleCard(
            title: '6. Compact Error Widgets',
            subtitle: 'Small error indicators for thumbnails',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Example6CompactErrorWidgets(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ExampleCard(
            title: '7. Optimized Constructors',
            subtitle: 'Convenience methods with best defaults',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Example7OptimizedConstructors(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ExampleCard(
            title: '8. Progressive Loading',
            subtitle: 'Blur-up effect with thumbnails',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Example8ProgressiveLoading(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExampleCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

/// Example 1: Shimmer Placeholder
///
/// Demonstrates the modern shimmer animation with gradient effect.
class Example1ShimmerPlaceholder extends StatelessWidget {
  const Example1ShimmerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shimmer Placeholder')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _ImageCard(
            title: 'Shimmer Placeholder',
            child: LazyLoadImage(
              imageUrl: 'https://via.placeholder.com/150',
              placeholderType: PlaceholderType.shimmer,
              width: 150,
              height: 150,
            ),
          ),
          _ImageCard(
            title: 'Custom Colors',
            child: LazyLoadImage(
              imageUrl: 'https://via.placeholder.com/150',
              placeholderType: PlaceholderType.shimmer,
              placeholderColor: Colors.blue[100],
              width: 150,
              height: 150,
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 2: Skeleton Placeholder
///
/// Demonstrates the performant skeleton placeholder with icon.
class Example2SkeletonPlaceholder extends StatelessWidget {
  const Example2SkeletonPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skeleton Placeholder')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ImageCard(
            title: 'Skeleton with Icon',
            child: LazyLoadImage(
              imageUrl: 'https://via.placeholder.com/150',
              placeholderType: PlaceholderType.skeleton,
              width: 150,
              height: 150,
            ),
          ),
          const SizedBox(height: 16),
          _ImageCard(
            title: 'Custom Color',
            child: LazyLoadImage(
              imageUrl: 'https://via.placeholder.com/150',
              placeholderType: PlaceholderType.skeleton,
              placeholderColor: Colors.green[100],
              width: 150,
              height: 150,
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 3: Color Placeholder
///
/// Demonstrates theme-aware color placeholder with icon.
class Example3ColorPlaceholder extends StatelessWidget {
  const Example3ColorPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Color Placeholder')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _ImageCard(
            title: 'Theme Color',
            child: LazyLoadImage(
              imageUrl: 'https://via.placeholder.com/150',
              placeholderType: PlaceholderType.color,
              width: 150,
              height: 150,
            ),
          ),
          _ImageCard(
            title: 'Custom Icon',
            child: LazyLoadImage(
              imageUrl: 'https://via.placeholder.com/150',
              placeholderType: PlaceholderType.color,
              placeholderColor: Colors.orange[50],
              width: 150,
              height: 150,
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 4: Blurred Placeholder
///
/// Demonstrates progressive loading with blurred thumbnail.
class Example4BlurredPlaceholder extends StatelessWidget {
  const Example4BlurredPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blurred Placeholder')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _ImageCard(
            title: 'With Thumbnail',
            child: LazyLoadImage(
              imageUrl: 'https://via.placeholder.com/300',
              thumbnailUrl: 'https://via.placeholder.com/100',
              placeholderType: PlaceholderType.blurred,
              width: 150,
              height: 150,
            ),
          ),
          _ImageCard(
            title: 'No Thumbnail (Fallback)',
            child: LazyLoadImage(
              imageUrl: 'https://via.placeholder.com/300',
              placeholderType: PlaceholderType.blurred,
              width: 150,
              height: 150,
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 5: Enhanced Error Handling
///
/// Demonstrates retry functionality with offline detection.
class Example5EnhancedErrorHandling extends StatefulWidget {
  const Example5EnhancedErrorHandling({super.key});

  @override
  State<Example5EnhancedErrorHandling> createState() =>
      _Example5EnhancedErrorHandlingState();
}

class _Example5EnhancedErrorHandlingState
    extends State<Example5EnhancedErrorHandling> {
  int _retryCount = 0;

  void _handleRetry() {
    setState(() {
      _retryCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Error Handling'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Retries: $_retryCount'),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Invalid URLs (shows error states)'),
          const SizedBox(height: 16),
          _ImageCard(
            title: 'Network Error',
            child: LazyLoadImage(
              imageUrl: 'https://invalid-url-that-will-fail.com/image.jpg',
              useEnhancedErrorHandling: true,
              onRetry: _handleRetry,
              width: 200,
              height: 200,
            ),
          ),
          const SizedBox(height: 16),
          _ImageCard(
            title: '404 Not Found',
            child: LazyLoadImage(
              imageUrl: 'https://httpstat.us/404',
              useEnhancedErrorHandling: true,
              onRetry: _handleRetry,
              width: 200,
              height: 200,
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 6: Compact Error Widgets
///
/// Demonstrates compact error widgets for small thumbnails.
class Example6CompactErrorWidgets extends StatelessWidget {
  const Example6CompactErrorWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compact Error Widgets')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('List items with error states'),
          const SizedBox(height: 16),
          _ListTile(
            title: 'Item 1',
            imageUrl: 'https://invalid-url.com/1.jpg',
          ),
          _ListTile(
            title: 'Item 2',
            imageUrl: 'https://invalid-url.com/2.jpg',
          ),
          _ListTile(
            title: 'Item 3',
            imageUrl: 'https://invalid-url.com/3.jpg',
          ),
          _ListTile(
            title: 'Item 4',
            imageUrl: 'https://invalid-url.com/4.jpg',
          ),
        ],
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  final String title;
  final String imageUrl;

  const _ListTile({required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: LazyLoadImage.optimizedThumbnail(
          imageUrl: imageUrl,
          size: 48,
        ),
        title: Text(title),
        subtitle: const Text('Failed to load thumbnail'),
      ),
    );
  }
}

/// Example 7: Optimized Constructors
///
/// Demonstrates convenience constructors with best defaults.
class Example7OptimizedConstructors extends StatelessWidget {
  const Example7OptimizedConstructors({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Optimized Constructors')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _ImageCard(
            title: 'LazyLoadImage.optimized',
            subtitle: 'Shimmer + Retry',
            child: LazyLoadImage.optimized(
              imageUrl: 'https://via.placeholder.com/150',
              size: 150,
              onRetry: () {},
            ),
          ),
          _ImageCard(
            title: 'LazyLoadImage.optimizedCard',
            subtitle: 'Skeleton + Retry',
            child: LazyLoadImage.optimizedCard(
              imageUrl: 'https://via.placeholder.com/300x200',
              height: 150,
              onRetry: () {},
            ),
          ),
          _ImageCard(
            title: 'LazyLoadImage.optimizedThumbnail',
            subtitle: 'Color + Compact',
            child: LazyLoadImage.optimizedThumbnail(
              imageUrl: 'https://via.placeholder.com/48',
              size: 100,
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 8: Progressive Loading
///
/// Demonstrates blur-up effect with thumbnails.
class Example8ProgressiveLoading extends StatelessWidget {
  const Example8ProgressiveLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progressive Loading')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _ImageCard(
            title: 'Blur-up Effect',
            subtitle: 'Low res → High res',
            child: LazyLoadImage.progressive(
              imageUrl: 'https://via.placeholder.com/300',
              thumbnailUrl: 'https://via.placeholder.com/100',
              size: 150,
              onRetry: () {},
            ),
          ),
          _ImageCard(
            title: 'Custom Placeholder',
            subtitle: 'Blurred with fallback',
            child: LazyLoadImage(
              imageUrl: 'https://via.placeholder.com/300',
              thumbnailUrl: 'https://via.placeholder.com/100',
              placeholderType: PlaceholderType.blurred,
              useEnhancedErrorHandling: true,
              width: 150,
              height: 150,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _ImageCard({
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Center(
            child: child,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}
