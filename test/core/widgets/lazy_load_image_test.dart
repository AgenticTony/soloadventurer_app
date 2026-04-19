import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/widgets/widgets.dart';

void main() {
  group('LazyLoadImage', () {
    testWidgets('renders placeholder when widget is first built',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyLoadImage(
              imageUrl: 'https://example.com/test.jpg',
              placeholder: (context, url) => _TestPlaceholder(),
            ),
          ),
        ),
      );

      expect(find.byType(_TestPlaceholder), findsOneWidget);
    });

    testWidgets('renders with custom width and height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyLoadImage(
              imageUrl: 'https://example.com/test.jpg',
              width: 200,
              height: 300,
              placeholder: (context, url) => _TestPlaceholder(),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(LazyLoadImage),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.constraints?.minWidth, 200);
      expect(container.constraints?.minHeight, 300);
    });

    testWidgets('renders with border radius', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyLoadImage(
              imageUrl: 'https://example.com/test.jpg',
              borderRadius: BorderRadius.all(Radius.circular(16)),
              placeholder: (context, url) => _TestPlaceholder(),
            ),
          ),
        ),
      );

      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('photo convenience constructor creates square image',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyLoadImageExtensions.optimized(
              imageUrl: 'https://example.com/test.jpg',
              size: 100,),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(LazyLoadImage),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.constraints?.minWidth, 100);
      expect(container.constraints?.minHeight, 100);
    });

    testWidgets('card convenience constructor creates rectangular image',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyLoadImageExtensions.optimizedCard(
              imageUrl: 'https://example.com/test.jpg',
              height: 200,),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(LazyLoadImage),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.constraints?.minHeight, 200);
    });

    testWidgets('thumbnail convenience constructor creates small image',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyLoadImageExtensions.optimizedThumbnail(
              imageUrl: 'https://example.com/test.jpg',
              size: 48,),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(LazyLoadImage),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.constraints?.minWidth, 48);
      expect(container.constraints?.minHeight, 48);
    });

    testWidgets('renders multiple images in a list', (tester) async {
      final imageUrls = List.generate(
        10,
        (index) => 'https://example.com/image$index.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return LazyLoadImage(
                  key: ValueKey('image_$index'),
                  imageUrl: imageUrls[index],
                  height: 100,
                  placeholder: (context, url) => const _TestPlaceholder(),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(LazyLoadImage), findsNWidgets(10));
      expect(find.byType(_TestPlaceholder), findsNWidgets(10));
    });

    testWidgets('renders multiple images in a grid', (tester) async {
      final imageUrls = List.generate(
        9,
        (index) => 'https://example.com/image$index.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return LazyLoadImageExtensions.optimized(
                  key: ValueKey('photo_$index'),
                  imageUrl: imageUrls[index],
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(LazyLoadImage), findsNWidgets(9));
      expect(find.byType(_TestPlaceholder), findsNWidgets(9));
    });

    testWidgets('uses default placeholder when none provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyLoadImage(
              imageUrl: 'https://example.com/test.jpg',
            ),
          ),
        ),
      );

      // Should render a container with grey background
      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });

    testWidgets('uses custom placeholder when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyLoadImage(
              imageUrl: 'https://example.com/test.jpg',
              placeholder: (context, url) => const _TestPlaceholder(),
            ),
          ),
        ),
      );

      expect(find.byType(_TestPlaceholder), findsOneWidget);
    });

    testWidgets('respects visibility threshold', (tester) async {
      const visibilityThreshold = 0.5;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 1000), // Push image off-screen
                  LazyLoadImage(
                    imageUrl: 'https://example.com/test.jpg',
                    visibilityThreshold: visibilityThreshold,
                    placeholder: (context, url) => _TestPlaceholder(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Image should not load yet (0% visible)
      expect(find.byType(_TestPlaceholder), findsOneWidget);
    });

    testWidgets('works with ValueKey in list', (tester) async {
      final photos = List.generate(
        5,
        (index) =>
            {'id': 'photo_$index', 'url': 'https://example.com/$index.jpg'},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return LazyLoadImageExtensions.optimized(
                  key: ValueKey(photos[index]['id']),
                  imageUrl: photos[index]['url'] as String,
                );
              },
            ),
          ),
        ),
      );

      // All images should render with unique keys
      expect(find.byType(LazyLoadImage), findsNWidgets(5));
    });

    group('Performance', () {
      testWidgets('efficiently renders 100 images without loading',
          (tester) async {
        final imageUrls = List.generate(
          100,
          (index) => 'https://example.com/image$index.jpg',
        );

        final start = DateTime.now();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    height: 100,
                    child: LazyLoadImage(
                      key: ValueKey('image_$index'),
                      imageUrl: imageUrls[index],
                      placeholder: (context, url) => const _TestPlaceholder(),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        final end = DateTime.now();
        final duration = end.difference(start);

        // Should render quickly (< 1 second) since images aren't loaded yet
        expect(duration.inMilliseconds, lessThan(1000));

        // All placeholders should be rendered
        expect(find.byType(_TestPlaceholder), findsNWidgets(100));
      });

      testWidgets('memory efficient with 500 images', (tester) async {
        // Note: Actual memory measurement requires integration tests
        // This is a basic smoke test to ensure it doesn't crash

        final imageUrls = List.generate(
          500,
          (index) => 'https://example.com/image$index.jpg',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    height: 100,
                    child: LazyLoadImage(
                      key: ValueKey('image_$index'),
                      imageUrl: imageUrls[index],
                      placeholder: (context, url) => const _TestPlaceholder(),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        // Should not crash with 500 images
        expect(find.byType(LazyLoadImage), findsNWidgets(500));
      });
    });

    group('Error Handling', () {
      testWidgets('handles error widget parameter', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LazyLoadImage(
                imageUrl: 'https://example.com/test.jpg',
                errorWidget: (context, url, error) => const _TestErrorWidget(),
                placeholder: (context, url) => const _TestPlaceholder(),
              ),
            ),
          ),
        );

        // Should build without errors
        expect(find.byType(LazyLoadImage), findsOneWidget);
      });
    });
  });
}

/// Test placeholder widget
class _TestPlaceholder extends StatelessWidget {
  const _TestPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: const Center(child: Text('Loading...')),
    );
  }
}

/// Test error widget
class _TestErrorWidget extends StatelessWidget {
  const _TestErrorWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red[100],
      child: const Center(child: Text('Error')),
    );
  }
}
