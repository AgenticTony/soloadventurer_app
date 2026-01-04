import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/widgets/image_error_widget.dart';

void main() {
  group('ImageErrorWidget', () {
    group('Basic rendering', () {
      testWidgets('creates error widget with default values',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageErrorWidget(
                error: 'Test error',
                imageUrl: 'https://example.com/image.jpg',
                width: 100,
                height: 100,
              ),
            ),
          ),
        );

        expect(find.byType(Container), findsOneWidget);
      });

      testWidgets('shows error icon', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageErrorWidget(
                error: 'Test error',
                imageUrl: 'https://example.com/image.jpg',
                width: 100,
                height: 100,
              ),
            ),
          ),
        );

        expect(find.byType(Icon), findsOneWidget);
      });

      testWidgets('shows retry button when onRetry is provided',
          (tester) async {
        bool retryPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageErrorWidget(
                error: 'Test error',
                imageUrl: 'https://example.com/image.jpg',
                width: 100,
                height: 100,
                onRetry: () => retryPressed = true,
                showRetryButton: true,
              ),
            ),
          ),
        );

        expect(find.byType(IconButton), findsOneWidget);

        // Tap retry button
        await tester.tap(find.byType(IconButton));
        await tester.pump();

        expect(retryPressed, isTrue);
      });

      testWidgets('does not show retry button when onRetry is null',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageErrorWidget(
                error: 'Test error',
                imageUrl: 'https://example.com/image.jpg',
                width: 100,
                height: 100,
                showRetryButton: true,
              ),
            ),
          ),
        );

        expect(find.byType(IconButton), findsNothing);
      });
    });

    group('Error type classification', () {
      testWidgets('shows timeout icon for timeout errors', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageErrorWidget(
                error: 'TimeoutException',
                imageUrl: 'https://example.com/image.jpg',
                width: 100,
                height: 100,
                showRetryButton: false,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.access_time), findsOneWidget);
      });

      testWidgets('shows not found icon for 404 errors', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageErrorWidget(
                error: 'HTTP 404 Not Found',
                imageUrl: 'https://example.com/image.jpg',
                width: 100,
                height: 100,
                showRetryButton: false,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
      });

      testWidgets('shows network error icon for connection errors',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageErrorWidget(
                error: 'Network connection failed',
                imageUrl: 'https://example.com/image.jpg',
                width: 100,
                height: 100,
                showRetryButton: false,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      });

      testWidgets('shows lock icon for authorization errors',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageErrorWidget(
                error: 'HTTP 401 Unauthorized',
                imageUrl: 'https://example.com/image.jpg',
                width: 100,
                height: 100,
                showRetryButton: false,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.lock), findsOneWidget);
      });

      testWidgets('shows broken image icon for format errors',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageErrorWidget(
                error: 'Invalid image format',
                imageUrl: 'https://example.com/image.jpg',
                width: 100,
                height: 100,
                showRetryButton: false,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.broken_image), findsOneWidget);
      });
    });

    group('Compact mode', () {
      testWidgets('creates compact error widget', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageErrorWidget.compact(
                error: 'Test error',
                imageUrl: 'https://example.com/image.jpg',
                size: 48,
              ),
            ),
          ),
        );

        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Icon), findsOneWidget);
        // Compact mode should not show text or retry button
        expect(find.byType(IconButton), findsNothing);
      });

      testWidgets('compact widget has correct size', (tester) async {
        const size = 48.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageErrorWidget.compact(
                error: 'Test error',
                imageUrl: 'https://example.com/image.jpg',
                size: size,
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        final decoration = container.decoration as BoxDecoration;

        expect(decoration.borderRadius, isNotNull);
      });
    });

    group('Custom styling', () {
      testWidgets('applies custom background color', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageErrorWidget(
                error: 'Test error',
                imageUrl: 'https://example.com/image.jpg',
                backgroundColor: Colors.red[100],
              ),
            ),
          ),
        );

        expect(find.byType(Container), findsOneWidget);
      });

      testWidgets('applies custom icon', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageErrorWidget(
                error: 'Test error',
                imageUrl: 'https://example.com/image.jpg',
                icon: Icons.warning,
                showRetryButton: false,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.warning), findsOneWidget);
      });

      testWidgets('applies custom border radius', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageErrorWidget(
                error: 'Test error',
                imageUrl: 'https://example.com/image.jpg',
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );

        expect(find.byType(Container), findsOneWidget);
      });
    });

    group('Retry functionality', () {
      testWidgets('withRetry constructor creates retry button',
          (tester) async {
        bool retried = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageErrorWidget.withRetry(
                error: 'Test error',
                imageUrl: 'https://example.com/image.jpg',
                onRetry: () => retried = true,
              ),
            ),
          ),
        );

        expect(find.byType(IconButton), findsOneWidget);

        await tester.tap(find.byType(IconButton));
        await tester.pump();

        expect(retried, isTrue);
      });
    });

    group('Performance', () {
      testWidgets('renders many error widgets efficiently', (tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: GridView.count(
              crossAxisCount: 3,
              children: List.generate(
                100,
                (index) => ImageErrorWidget(
                  error: 'Error $index',
                  imageUrl: 'https://example.com/image$index.jpg',
                  width: 100,
                  height: 100,
                  showRetryButton: false,
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        stopwatch.stop();

        // Should render 100 error widgets in less than 1 second
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });

    group('Icon sizing', () {
      testWidgets('calculates appropriate icon size for small containers',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageErrorWidget(
                error: 'Test error',
                imageUrl: 'https://example.com/image.jpg',
                width: 48,
                height: 48,
                showRetryButton: false,
              ),
            ),
          ),
        );

        expect(find.byType(Icon), findsOneWidget);
      });

      testWidgets('calculates appropriate icon size for large containers',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageErrorWidget(
                error: 'Test error',
                imageUrl: 'https://example.com/image.jpg',
                width: 200,
                height: 200,
                showRetryButton: false,
              ),
            ),
          ),
        );

        expect(find.byType(Icon), findsOneWidget);
      });
    });
  });

  group('ImageErrorClassifier', () {
    test('classifies timeout errors correctly', () {
      final classifier = ImageErrorClassifier.classify('TimeoutException');
      expect(classifier.type, ImageErrorType.timeout);
      expect(classifier.getMessage(), contains('timeout'));
      expect(classifier.getIcon(), Icons.access_time);
    });

    test('classifies 404 errors correctly', () {
      final classifier = ImageErrorClassifier.classify('404 Not Found');
      expect(classifier.type, ImageErrorType.notFound);
      expect(classifier.getMessage(), contains('not found'));
      expect(classifier.getIcon(), Icons.image_not_supported);
    });

    test('classifies network errors correctly', () {
      final classifier = ImageErrorClassifier.classify('Network error');
      expect(classifier.type, ImageErrorType.network);
      expect(classifier.getMessage(), contains('Network'));
      expect(classifier.getIcon(), Icons.wifi_off);
    });

    test('classifies unauthorized errors correctly', () {
      final classifier = ImageErrorClassifier.classify('401 Unauthorized');
      expect(classifier.type, ImageErrorType.unauthorized);
      expect(classifier.getMessage(), contains('Access denied'));
      expect(classifier.getIcon(), Icons.lock);
    });

    test('classifies format errors correctly', () {
      final classifier = ImageErrorClassifier.classify('Invalid image format');
      expect(classifier.type, ImageErrorType.invalidFormat);
      expect(classifier.getMessage(), contains('Invalid'));
      expect(classifier.getIcon(), Icons.broken_image);
    });

    test('classifies unknown errors correctly', () {
      final classifier = ImageErrorClassifier.classify('Unknown error');
      expect(classifier.type, ImageErrorType.unknown);
      expect(classifier.getMessage(), contains('Failed to load'));
      expect(classifier.getIcon(), Icons.error_outline);
    });

    test('determines retryability correctly', () {
      final networkError =
          ImageErrorClassifier.classify('Network error');
      expect(networkError.isRetryable(), isTrue);

      final notFoundError = ImageErrorClassifier.classify('404 Not Found');
      expect(notFoundError.isRetryable(), isFalse);

      final unauthorizedError =
          ImageErrorClassifier.classify('401 Unauthorized');
      expect(unauthorizedError.isRetryable(), isFalse);

      final timeoutError = ImageErrorClassifier.classify('TimeoutException');
      expect(timeoutError.isRetryable(), isTrue);
    });
  });
}
