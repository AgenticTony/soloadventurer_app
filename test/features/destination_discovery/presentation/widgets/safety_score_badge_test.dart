import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/destination_discovery/presentation/widgets/safety_score_badge.dart';

void main() {
  group('SafetyScoreBadge', () {
    group('Rendering', () {
      testWidgets('renders score text with one decimal place',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(score: 8.5),
            ),
          ),
        );

        expect(find.text('8.5'), findsOneWidget);
      });

      testWidgets('renders default label', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(score: 8.5),
            ),
          ),
        );

        expect(find.text('Safety'), findsOneWidget);
      });

      testWidgets('renders custom label', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(
                score: 8.5,
                label: 'Rating',
              ),
            ),
          ),
        );

        expect(find.text('Rating'), findsOneWidget);
      });

      testWidgets('hides label when showLabel is false',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(
                score: 8.5,
                showLabel: false,
              ),
            ),
          ),
        );

        expect(find.text('Safety'), findsNothing);
        expect(find.text('8.5'), findsOneWidget);
      });

      testWidgets('renders icon for high safety (>= 8)',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(score: 8.0),
            ),
          ),
        );

        expect(find.byIcon(Icons.security), findsOneWidget);
      });

      testWidgets('renders icon for medium safety (>= 6)',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(score: 7.0),
            ),
          ),
        );

        expect(find.byIcon(Icons.warning_amber), findsOneWidget);
      });

      testWidgets('renders icon for low safety (< 6)',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(score: 5.0),
            ),
          ),
        );

        expect(find.byIcon(Icons.dangerous), findsOneWidget);
      });

      testWidgets('renders green color for high safety (>= 8)',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(score: 8.5),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(SafetyScoreBadge),
            matching: find.byType(Container).first,
          ),
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, Colors.green.withValues(alpha: 0.1));
        expect(decoration.border?.top.color, Colors.green);
      });

      testWidgets('renders orange color for medium safety (>= 6)',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(score: 7.0),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(SafetyScoreBadge),
            matching: find.byType(Container).first,
          ),
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, Colors.orange.withValues(alpha: 0.1));
        expect(decoration.border?.top.color, Colors.orange);
      });

      testWidgets('renders red color for low safety (< 6)',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(score: 5.0),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(SafetyScoreBadge),
            matching: find.byType(Container).first,
          ),
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, Colors.red.withValues(alpha: 0.1));
        expect(decoration.border?.top.color, Colors.red);
      });
    });

    group('Accessibility', () {
      testWidgets('includes semantics label', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(score: 8.5),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(SafetyScoreBadge));
        expect(
          semantics.label,
          startsWith('Safety score: 8.5 out of 10, high safety'),
        );
      });

      testWidgets('includes semantics value', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(score: 7.3),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(SafetyScoreBadge));
        expect(semantics.value, '7.3');
      });

      testWidgets('includes semantics hint', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(score: 8.5),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(SafetyScoreBadge));
        expect(semantics.hint, 'Safety rating from 1 to 10');
      });

      testWidgets('uses custom label in semantics',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(
                score: 8.5,
                label: 'Rating',
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(SafetyScoreBadge));
        expect(
          semantics.label,
          startsWith('Rating score: 8.5 out of 10, high safety'),
        );
      });

      testWidgets('correct accessibility label for medium safety',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(score: 6.5),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(SafetyScoreBadge));
        expect(
          semantics.label,
          startsWith('Safety score: 6.5 out of 10, medium safety'),
        );
      });

      testWidgets('correct accessibility label for low safety',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(score: 4.0),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(SafetyScoreBadge));
        expect(
          semantics.label,
          startsWith('Safety score: 4.0 out of 10, low safety'),
        );
      });
    });

    group('Edge Cases', () {
      testWidgets('handles minimum score (1.0)', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(score: 1.0),
            ),
          ),
        );

        expect(find.text('1.0'), findsOneWidget);
        expect(find.byIcon(Icons.dangerous), findsOneWidget);
      });

      testWidgets('handles maximum score (10.0)', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(score: 10.0),
            ),
          ),
        );

        expect(find.text('10.0'), findsOneWidget);
        expect(find.byIcon(Icons.security), findsOneWidget);
      });

      testWidgets('handles boundary score (8.0)', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(score: 8.0),
            ),
          ),
        );

        expect(find.byIcon(Icons.security), findsOneWidget);
      });

      testWidgets('handles boundary score (6.0)', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(score: 6.0),
            ),
          ),
        );

        expect(find.byIcon(Icons.warning_amber), findsOneWidget);
      });

      testWidgets('handles decimal scores correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(score: 7.67),
            ),
          ),
        );

        expect(find.text('7.7'), findsOneWidget);
      });
    });

    group('Customization', () {
      testWidgets('uses custom padding', (WidgetTester tester) async {
        const customPadding = EdgeInsets.all(20);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(
                score: 8.5,
                padding: customPadding,
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(SafetyScoreBadge),
            matching: find.byType(Container).first,
          ),
        );

        expect(container.padding, customPadding);
      });

      testWidgets('uses custom border radius', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(
                score: 8.5,
                borderRadius: 20,
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(SafetyScoreBadge),
            matching: find.byType(Container).first,
          ),
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.borderRadius, BorderRadius.circular(20));
      });

      testWidgets('uses custom icon size', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyScoreBadge(
                score: 8.5,
                iconSize: 24,
              ),
            ),
          ),
        );

        final icon = tester.widget<Icon>(
          find.descendant(
            of: find.byType(SafetyScoreBadge),
            matching: find.byType(Icon),
          ),
        );

        expect(icon.size, 24);
      });
    });
  });
}
