import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/presentation/widgets/sync_progress_indicator.dart';

void main() {
  group('SyncProgressBar', () {
    testWidgets('renders with progress value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressBar(progress: 0.5),
          ),
        ),
      );

      expect(find.byType(SyncProgressBar), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('renders indeterminate progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressBar(isIndeterminate: true),
          ),
        ),
      );

      expect(find.byType(SyncProgressBar), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows percentage when enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressBar(progress: 0.75, showPercentage: true),
          ),
        ),
      );

      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('does not show percentage when disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressBar(
              progress: 0.75,
              showPercentage: false,
            ),
          ),
        ),
      );

      expect(find.text('75%'), findsNothing);
    });

    testWidgets('shows custom label', (tester) async {
      const customLabel = 'Uploading data...';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressBar(
              progress: 0.5,
              label: customLabel,
            ),
          ),
        ),
      );

      expect(find.text(customLabel), findsOneWidget);
    });

    testWidgets('respects custom height', (tester) async {
      const customHeight = 8.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressBar(
              progress: 0.5,
              height: customHeight,
            ),
          ),
        ),
      );

      final progressBar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      expect(progressBar.minHeight, customHeight);
    });

    testWidgets('respects custom color', (tester) async {
      const customColor = Colors.purple;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressBar(
              progress: 0.5,
              color: customColor,
            ),
          ),
        ),
      );

      final progressBar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      expect(progressBar.color, customColor);
    });

    testWidgets('clamps progress between 0 and 1', (tester) async {
      // Test progress > 1
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressBar(progress: 1.5),
          ),
        ),
      );

      expect(find.byType(SyncProgressBar), findsOneWidget);

      // Test progress < 0
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressBar(progress: -0.5),
          ),
        ),
      );

      expect(find.byType(SyncProgressBar), findsOneWidget);
    });

    testWidgets('can disable animation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressBar(
              progress: 0.5,
              animate: false,
            ),
          ),
        ),
      );

      expect(find.byType(SyncProgressBar), findsOneWidget);
    });

    testWidgets('shows different progress values', (tester) async {
      final testValues = [0.0, 0.25, 0.5, 0.75, 1.0];

      for (final value in testValues) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SyncProgressBar(
                progress: value,
                showPercentage: true,
              ),
            ),
          ),
        );

        final expectedPercentage = '${(value * 100).toInt()}%';
        expect(find.text(expectedPercentage), findsOneWidget);
      }
    });
  });

  group('SyncCircularProgress', () {
    testWidgets('renders with progress value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncCircularProgress(progress: 0.5),
          ),
        ),
      );

      expect(find.byType(SyncCircularProgress), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('renders indeterminate progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncCircularProgress(isIndeterminate: true),
          ),
        ),
      );

      expect(find.byType(SyncCircularProgress), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('shows center widget when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncCircularProgress(
              progress: 0.5,
              center: Text('50%'),
            ),
          ),
        ),
      );

      expect(find.text('50%'), findsOneWidget);
      expect(find.byType(Stack), findsOneWidget);
    });

    testWidgets('respects custom size', (tester) async {
      const customSize = 60.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncCircularProgress(
              progress: 0.5,
              size: customSize,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(SyncCircularProgress),
          matching: find.byType(SizedBox),
        ).first,
      );

      expect(sizedBox.width, customSize);
      expect(sizedBox.height, customSize);
    });

    testWidgets('respects custom stroke width', (tester) async {
      const customStrokeWidth = 8.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncCircularProgress(
              progress: 0.5,
              strokeWidth: customStrokeWidth,
            ),
          ),
        ),
      );

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.descendant(
          of: find.byType(SyncCircularProgress),
          matching: find.byType(CircularProgressIndicator),
        ).first,
      );

      expect(progressIndicator.strokeWidth, customStrokeWidth);
    });

    testWidgets('respects custom color', (tester) async {
      const customColor = Colors.orange;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncCircularProgress(
              progress: 0.5,
              color: customColor,
            ),
          ),
        ),
      );

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.descendant(
          of: find.byType(SyncCircularProgress),
          matching: find.byType(CircularProgressIndicator),
        ).last,
      );

      expect(progressIndicator.color, customColor);
    });
  });

  group('SyncProgressCard', () {
    testWidgets('renders with basic parameters', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressCard(
              title: 'Syncing Data',
              progress: 0.5,
              processed: 5,
              total: 10,
            ),
          ),
        ),
      );

      expect(find.byType(SyncProgressCard), findsOneWidget);
      expect(find.text('Syncing Data'), findsOneWidget);
      expect(find.text('5 of 10 items'), findsOneWidget);
    });

    testWidgets('shows message when provided', (tester) async {
      const message = 'Uploading your changes...';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressCard(
              title: 'Syncing',
              message: message,
              progress: 0.5,
            ),
          ),
        ),
      );

      expect(find.text(message), findsOneWidget);
    });

    testWidgets('shows error when provided', (tester) async {
      const error = 'Network connection lost';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressCard(
              title: 'Sync Failed',
              error: error,
              processed: 5,
              total: 10,
            ),
          ),
        ),
      );

      expect(find.text(error), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.byType(SyncProgressBar), findsNothing);
    });

    testWidgets('shows indeterminate progress when specified', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressCard(
              title: 'Connecting',
              isIndeterminate: true,
            ),
          ),
        ),
      );

      expect(find.byType(SyncProgressBar), findsOneWidget);
    });

    testWidgets('respects custom color', (tester) async {
      const customColor = Colors.purple;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressCard(
              title: 'Syncing',
              progress: 0.5,
              color: customColor,
            ),
          ),
        ),
      );

      expect(find.byType(SyncProgressCard), findsOneWidget);
    });

    testWidgets('shows singular "item" for total of 1', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressCard(
              title: 'Syncing',
              progress: 1.0,
              processed: 1,
              total: 1,
            ),
          ),
        ),
      );

      expect(find.text('1 of 1 item'), findsOneWidget);
      expect(find.text('1 of 1 items'), findsNothing);
    });

    testWidgets('displays correctly without total count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressCard(
              title: 'Syncing',
              progress: 0.5,
            ),
          ),
        ),
      );

      expect(find.byType(SyncProgressCard), findsOneWidget);
      expect(find.byType(SyncProgressBar), findsOneWidget);
    });

    testWidgets('renders with Card styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressCard(
              title: 'Test',
              progress: 0.5,
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Padding), findsWidgets);
    });
  });

  group('Progress indicator integration tests', () {
    testWidgets('multiple progress bars work together', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                SyncProgressBar(progress: 0.25),
                SyncProgressBar(progress: 0.5),
                SyncProgressBar(progress: 0.75),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SyncProgressBar), findsNWidgets(3));
    });

    testWidgets('works in ListView', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: const [
                SyncProgressCard(
                  title: 'Task 1',
                  progress: 0.5,
                  processed: 5,
                  total: 10,
                ),
                SyncProgressCard(
                  title: 'Task 2',
                  progress: 0.75,
                  processed: 3,
                  total: 4,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SyncProgressCard), findsNWidgets(2));
    });

    testWidgets('handles theme changes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressBar(progress: 0.5),
          ),
        ),
      );

      expect(find.byType(SyncProgressBar), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: SyncProgressBar(progress: 0.5),
          ),
        ),
      );

      expect(find.byType(SyncProgressBar), findsOneWidget);
    });
  });
}
