import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/destination_discovery/presentation/widgets/solo_suitability_badge.dart';

void main() {
  group('SoloSuitabilityBadge', () {
    group('Rendering', () {
      testWidgets('renders score text with one decimal place',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SoloSuitabilityBadge(score: 9.0),
            ),
          ),
        );

        expect(find.text('9.0'), findsOneWidget);
      });

      testWidgets('renders default label', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SoloSuitabilityBadge(score: 9.0),
            ),
          ),
        );

        expect(find.text('Solo'), findsOneWidget);
      });

      testWidgets('renders custom label', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SoloSuitabilityBadge(
                score: 9.0,
                label: 'Solo Friendly',
              ),
            ),
          ),
        );

        expect(find.text('Solo Friendly'), findsOneWidget);
      });

      testWidgets('hides label when showLabel is false',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SoloSuitabilityBadge(
                score: 9.0,
                showLabel: false,
              ),
            ),
          ),
        );

        expect(find.text('Solo'), findsNothing);
        expect(find.text('9.0'), findsOneWidget);
      });

      testWidgets('renders icon for high suitability (>= 8)',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SoloSuitabilityBadge(score: 8.5),
            ),
          ),
        );

        expect(find.byIcon(Icons.person), findsOneWidget);
      });

      testWidgets('renders icon for medium suitability (>= 6)',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SoloSuitabilityBadge(score: 7.0),
            ),
          ),
        );

        expect(find.byIcon(Icons.hiking), findsOneWidget);
      });

      testWidgets('renders icon for low suitability (< 6)',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SoloSuitabilityBadge(score: 5.0),
            ),
          ),
        );

        expect(find.byIcon(Icons.travel_explore), findsOneWidget);
      });

      testWidgets('renders blue color for high suitability (>= 8)',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SoloSuitabilityBadge(score: 8.5),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(SoloSuitabilityBadge),
            matching: find.byType(Container).first,
          ),
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, Colors.blue.shade700.withValues(alpha: 0.1));
        expect(decoration.border?.top.color, Colors.blue.shade700);
      });

      testWidgets('renders light blue color for medium suitability (>= 6)',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SoloSuitabilityBadge(score: 7.0),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(SoloSuitabilityBadge),
            matching: find.byType(Container).first,
          ),
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, Colors.lightBlue.withValues(alpha: 0.1));
        expect(decoration.border?.top.color, Colors.lightBlue);
      });

      testWidgets('renders grey color for low suitability (< 6)',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SoloSuitabilityBadge(score: 5.0),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(SoloSuitabilityBadge),
            matching: find.byType(Container).first,
          ),
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, Colors.grey.shade600.withValues(alpha: 0.1));
        expect(decoration.border?.top.color, Colors.grey.shade600);
      });
    });

    group('Accessibility', () {
      testWidgets('includes semantics label', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SoloSuitabilityBadge(score: 9.0),
            ),
          ),
        );

        final semantics =
            tester.getSemantics(find.byType(SoloSuitabilityBadge));
        expect(
          semantics.label,
          startsWith('Solo suitability score: 9.0 out of 10, excellent for solo travelers'),
        );
      });

      testWidgets('includes semantics value', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SoloSuitabilityBadge(score: 8.3),
            ),
          ),
        );

        final semantics =
            tester.getSemantics(find.byType(SoloSuitabilityBadge));
        expect(semantics.value, '8.3');
      });

      testWidgets('includes semantics hint', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SoloSuitabilityBadge(score: 9.0),
            ),
          ),
        );

        final semantics =
            tester.getSemantics(find.byType(SoloSuitabilityBadge));
        expect(semantics.hint, 'Solo travel suitability rating from 1 to 10');
      });

      testWidgets('uses custom label in semantics',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SoloSuitabilityBadge(
                score: 9.0,
                label: 'Rating',
              ),
            ),
          ),
        );

        final semantics =
            tester.getSemantics(find.byType(SoloSuitabilityBadge));
        expect(
          semantics.label,
          startsWith('Rating suitability score: 9.0 out of 10, excellent for solo travelers'),
        );
      });

      testWidgets('correct accessibility label for good suitability',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SoloSuitabilityBadge(score: 7.5),
            ),
          ),
        );

        final semantics =
            tester.getSemantics(find.byType(SoloSuitabilityBadge));
        expect(
          semantics.label,
          startsWith('Solo suitability score: 7.5 out of 10, good for solo travelers'),
        );
      });

      testWidgets('correct accessibility label for challenging suitability',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SoloSuitabilityBadge(score: 5.0),
            ),
          ),
        );

        final semantics =
            tester.getSemantics(find.byType(SoloSuitabilityBadge));
        expect(
          semantics.label,
          startsWith('Solo suitability score: 5.0 out of 10, challenging for solo travelers'),
        );
      });
    });

    group('Edge Cases', () {
      testWidgets('handles minimum score (1.0)', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SoloSuitabilityBadge(score: 1.0),
            ),
          ),
        );

        expect(find.text('1.0'), findsOneWidget);
        expect(find.byIcon(Icons.travel_explore), findsOneWidget);
      });

      testWidgets('handles maximum score (10.0)', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SoloSuitabilityBadge(score: 10.0),
            ),
          ),
        );

        expect(find.text('10.0'), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
      });

      testWidgets('handles boundary score (8.0)', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SoloSuitabilityBadge(score: 8.0),
            ),
          ),
        );

        expect(find.byIcon(Icons.person), findsOneWidget);
      });

      testWidgets('handles boundary score (6.0)', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SoloSuitabilityBadge(score: 6.0),
            ),
          ),
        );

        expect(find.byIcon(Icons.hiking), findsOneWidget);
      });

      testWidgets('handles decimal scores correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SoloSuitabilityBadge(score: 8.67),
            ),
          ),
        );

        expect(find.text('8.7'), findsOneWidget);
      });
    });

    group('Customization', () {
      testWidgets('uses custom padding', (WidgetTester tester) async {
        const customPadding = EdgeInsets.all(20);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SoloSuitabilityBadge(
                score: 9.0,
                padding: customPadding,
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(SoloSuitabilityBadge),
            matching: find.byType(Container).first,
          ),
        );

        expect(container.padding, customPadding);
      });

      testWidgets('uses custom border radius', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SoloSuitabilityBadge(
                score: 9.0,
                borderRadius: 20,
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(SoloSuitabilityBadge),
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
              body: SoloSuitabilityBadge(
                score: 9.0,
                iconSize: 24,
              ),
            ),
          ),
        );

        final icon = tester.widget<Icon>(
          find.descendant(
            of: find.byType(SoloSuitabilityBadge),
            matching: find.byType(Icon),
          ),
        );

        expect(icon.size, 24);
      });
    });
  });
}
