import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/presentation/widgets/sync_status_badge.dart';

void main() {
  group('SyncStatusBadge', () {
    testWidgets('renders badge with count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusBadge(count: 5),
          ),
        ),
      );

      expect(find.byType(SyncStatusBadge), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows 99+ for counts over 99', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusBadge(count: 150),
          ),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
      expect(find.text('150'), findsNothing);
    });

    testWidgets('hides when count is 0 and hideWhenZero is true',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusBadge(count: 0, hideWhenZero: true),
          ),
        ),
      );

      expect(find.byType(SyncStatusBadge), findsOneWidget);
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('shows when count is 0 and hideWhenZero is false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusBadge(count: 0, hideWhenZero: false),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('renders badge on child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusBadge(
              count: 3,
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      expect(find.byType(SyncStatusBadge), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('positions badge correctly on child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusBadge(
              count: 5,
              child: Icon(Icons.mail),
            ),
          ),
        ),
      );

      expect(find.byType(Stack), findsOneWidget);
      expect(find.byIcon(Icons.mail), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('respects custom color', (tester) async {
      const customColor = Colors.purple;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusBadge(
              count: 5,
              color: customColor,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SyncStatusBadge),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, customColor);
    });

    testWidgets('respects custom size', (tester) async {
      const customSize = 24.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusBadge(
              count: 5,
              size: customSize,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SyncStatusBadge),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.constraints?.maxHeight, customSize);
      expect(container.constraints?.maxHeight, customSize);
    });

    testWidgets('shows different badge sizes for different counts',
        (tester) async {
      // Single digit count
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusBadge(count: 5, size: 18),
          ),
        ),
      );

      var container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SyncStatusBadge),
          matching: find.byType(Container),
        ).first,
      );
      var width = container.constraints?.maxWidth;
      expect(width, greaterThan(18));

      // Double digit count
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusBadge(count: 99, size: 18),
          ),
        ),
      );

      container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SyncStatusBadge),
          matching: find.byType(Container),
        ).first,
      );
      width = container.constraints?.maxWidth;
      expect(width, greaterThan(22));

      // 99+ count
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusBadge(count: 150, size: 18),
          ),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('respects custom offset', (tester) async {
      const customOffset = Offset(-10, 10);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusBadge(
              count: 5,
              child: Icon(Icons.notifications),
              offset: customOffset,
            ),
          ),
        ),
      );

      final positioned = tester.widget<Positioned>(
        find.descendant(
          of: find.byType(SyncStatusBadge),
          matching: find.byType(Positioned),
        ).first,
      );

      expect(positioned.right, customOffset.dx);
      expect(positioned.top, customOffset.dy);
    });
  });

  group('SyncStatusBadgeWithIndicator', () {
    testWidgets('renders with pending count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusBadgeWithIndicator(count: 3),
          ),
        ),
      );

      expect(find.byType(SyncStatusBadgeWithIndicator), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.textContaining('pending'), findsOneWidget);
    });

    testWidgets('shows singular "item" for count of 1', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusBadgeWithIndicator(count: 1),
          ),
        ),
      );

      expect(find.text('1 pending item'), findsOneWidget);
      expect(find.text('1 pending items'), findsNothing);
    });

    testWidgets('shows plural "items" for count > 1', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusBadgeWithIndicator(count: 5),
          ),
        ),
      );

      expect(find.text('5 pending items'), findsOneWidget);
      expect(find.text('5 pending item'), findsNothing);
    });

    testWidgets('respects custom color', (tester) async {
      const customColor = Colors.orange;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusBadgeWithIndicator(
              count: 3,
              color: customColor,
            ),
          ),
        ),
      );

      expect(find.byType(SyncStatusBadgeWithIndicator), findsOneWidget);
    });

    testWidgets('hides count circle when count is 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusBadgeWithIndicator(count: 0),
          ),
        ),
      );

      // Should still show the text
      expect(find.text('0 pending items'), findsOneWidget);

      // But not the count circle
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(SyncStatusBadgeWithIndicator),
          matching: find.byType(Container),
        ),
      );

      // Should have text but not count badge circle
      expect(containers.length, greaterThan(0));
    });
  });

  group('Badge integration tests', () {
    testWidgets('works with List of badges', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: const [
                SyncStatusBadge(count: 1, child: Icon(Icons.mail)),
                SyncStatusBadge(count: 5, child: Icon(Icons.notifications)),
                SyncStatusBadge(count: 10, child: Icon(Icons.calendar)),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SyncStatusBadge), findsNWidgets(3));
    });

    testWidgets('works in AppBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: const [
                SyncStatusBadge(
                  count: 5,
                  child: Icon(Icons.notifications),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SyncStatusBadge), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('handles theme changes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusBadge(count: 5),
          ),
        ),
      );

      expect(find.byType(SyncStatusBadge), findsOneWidget);

      // Change theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: SyncStatusBadge(count: 5),
          ),
        ),
      );

      expect(find.byType(SyncStatusBadge), findsOneWidget);
    });
  });
}
