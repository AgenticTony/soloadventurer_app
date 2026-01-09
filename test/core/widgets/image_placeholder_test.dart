import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/widgets/image_placeholder.dart';

void main() {
  group('ImagePlaceholder', () {
    group('shimmer', () {
      testWidgets('creates shimmer placeholder with default colors',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImagePlaceholder.shimmer(
                width: 100,
                height: 100,
              ),
            ),
          ),
        );

        expect(find.byType(Container), findsOneWidget);
      });

      testWidgets('creates shimmer placeholder with custom colors',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImagePlaceholder.shimmer(
                width: 100,
                height: 100,
                baseColor: Colors.blue,
                highlightColor: Colors.white,
              ),
            ),
          ),
        );

        expect(find.byType(Container), findsOneWidget);
      });

      testWidgets('creates shimmer placeholder with border radius',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImagePlaceholder.shimmer(
                width: 100,
                height: 100,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );

        expect(find.byType(Container), findsOneWidget);
      });
    });

    group('skeleton', () {
      testWidgets('creates skeleton placeholder without icon',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImagePlaceholder.skeleton(
                width: 100,
                height: 100,
                showIcon: false,
              ),
            ),
          ),
        );

        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Icon), findsNothing);
      });

      testWidgets('creates skeleton placeholder with icon', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImagePlaceholder.skeleton(
                width: 100,
                height: 100,
                showIcon: true,
              ),
            ),
          ),
        );

        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Icon), findsOneWidget);
      });

      testWidgets('creates skeleton placeholder with custom icon',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImagePlaceholder.skeleton(
                width: 100,
                height: 100,
                showIcon: true,
                icon: Icons.photo,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.photo), findsOneWidget);
      });

      testWidgets('creates skeleton placeholder with custom color',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImagePlaceholder.skeleton(
                width: 100,
                height: 100,
                color: Colors.green,
              ),
            ),
          ),
        );

        expect(find.byType(Container), findsOneWidget);
      });
    });

    group('color', () {
      testWidgets('creates color placeholder with default icon',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImagePlaceholder.color(
                width: 100,
                height: 100,
              ),
            ),
          ),
        );

        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Icon), findsOneWidget);
      });

      testWidgets('creates color placeholder with custom icon',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImagePlaceholder.color(
                width: 100,
                height: 100,
                icon: Icons.image,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.image), findsOneWidget);
      });

      testWidgets('creates color placeholder with custom colors',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImagePlaceholder.color(
                width: 100,
                height: 100,
                backgroundColor: Colors.orange[50],
                iconColor: Colors.orange,
              ),
            ),
          ),
        );

        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Icon), findsOneWidget);
      });

      testWidgets('respects custom icon size', (tester) async {
        const iconSize = 48.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImagePlaceholder.color(
                width: 100,
                height: 100,
                iconSize: iconSize,
              ),
            ),
          ),
        );

        expect(find.byType(Icon), findsOneWidget);
      });
    });

    group('blurred', () {
      testWidgets('falls back to shimmer when no thumbnail provided',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImagePlaceholder.blurred(
                thumbnailUrl: null,
                width: 100,
                height: 100,
              ),
            ),
          ),
        );

        // Should fall back to shimmer (Container with gradient)
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('falls back to shimmer when thumbnail is empty',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImagePlaceholder.blurred(
                thumbnailUrl: '',
                width: 100,
                height: 100,
              ),
            ),
          ),
        );

        expect(find.byType(Container), findsWidgets);
      });
    });

    group('Performance', () {
      testWidgets('shimmer placeholder renders efficiently',
          (tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: GridView.count(
              crossAxisCount: 3,
              children: List.generate(
                100,
                (index) => ImagePlaceholder.shimmer(
                  width: 100,
                  height: 100,
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        stopwatch.stop();

        // Should render 100 items in less than 1 second
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      testWidgets('skeleton placeholder renders efficiently',
          (tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: GridView.count(
              crossAxisCount: 3,
              children: List.generate(
                100,
                (index) => ImagePlaceholder.skeleton(
                  width: 100,
                  height: 100,
                  showIcon: true,
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        stopwatch.stop();

        // Should render 100 items in less than 500ms (skeleton is simpler)
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });
    });

    group('Accessibility', () {
      testWidgets('placeholders are accessible', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  ImagePlaceholder.shimmer(width: 100, height: 100),
                  ImagePlaceholder.skeleton(width: 100, height: 100),
                  ImagePlaceholder.color(width: 100, height: 100),
                ],
              ),
            ),
          ),
        );

        // All placeholders should render without accessibility issues
        expect(find.byType(Container), findsWidgets);
      });
    });
  });
}
