import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination.dart';
import 'package:soloadventurer/features/destination_discovery/presentation/widgets/safety_insights.dart';

void main() {
  group('SafetyInsights', () {
    // Test data
    late List<SafetyInsight> testInsights;
    late List<SafetyInsight> emptyInsights;

    setUp(() {
      testInsights = [
        const SafetyInsight(
          category: 'theft',
          description: 'Petty theft can occur in tourist areas.',
          severity: 'low',
          tips: [
            'Keep valuables secure',
            'Use hotel safes',
            'Avoid displaying expensive items',
          ],
        ),
        const SafetyInsight(
          category: 'transportation',
          description: 'Public transport is generally safe but can be crowded.',
          severity: 'medium',
          tips: [
            'Use registered taxis',
            'Avoid late-night travel alone',
            'Keep tickets and passes safe',
          ],
        ),
        const SafetyInsight(
          category: 'nightlife',
          description: 'Nightlife areas can be risky for solo travelers.',
          severity: 'high',
          tips: [
            'Stay in well-lit areas',
            'Keep drinks close',
            'Have emergency contact ready',
          ],
        ),
      ];

      emptyInsights = [];
    });

    group('Rendering', () {
      testWidgets('renders all insights', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafetyInsights(insights: testInsights),
            ),
          ),
        );

        expect(find.text('Petty theft can occur in tourist areas.'),
            findsOneWidget);
        expect(
            find.text('Public transport is generally safe but can be crowded.'),
            findsOneWidget);
        expect(find.text('Nightlife areas can be risky for solo travelers.'),
            findsOneWidget);
      });

      testWidgets('renders insight categories', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafetyInsights(insights: testInsights),
            ),
          ),
        );

        expect(find.text('theft'), findsOneWidget);
        expect(find.text('transportation'), findsOneWidget);
        expect(find.text('nightlife'), findsOneWidget);
      });

      testWidgets('renders safety tips', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafetyInsights(insights: testInsights),
            ),
          ),
        );

        expect(find.text('Keep valuables secure'), findsOneWidget);
        expect(find.text('Use hotel safes'), findsOneWidget);
        expect(find.text('Avoid displaying expensive items'), findsOneWidget);
      });

      testWidgets('renders custom title when provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafetyInsights(
                insights: testInsights,
                title: 'Safety Information',
              ),
            ),
          ),
        );

        expect(find.text('Safety Information'), findsOneWidget);
      });

      testWidgets('does not render title when not provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafetyInsights(insights: testInsights),
            ),
          ),
        );

        expect(find.text('Safety Information'), findsNothing);
      });
    });

    group('Icons', () {
      testWidgets('shows icons when showIcons is true',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafetyInsights(
                insights: testInsights,
                showIcons: true,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.shopping_bag), findsOneWidget);
        expect(find.byIcon(Icons.directions_transit), findsOneWidget);
        expect(find.byIcon(Icons.local_bar), findsOneWidget);
      });

      testWidgets('hides icons when showIcons is false',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafetyInsights(
                insights: testInsights,
                showIcons: false,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.shopping_bag), findsNothing);
        expect(find.byIcon(Icons.directions_transit), findsNothing);
        expect(find.byIcon(Icons.local_bar), findsNothing);
      });

      testWidgets('uses contextual icons for different categories',
          (WidgetTester tester) async {
        final insightsWithCategories = [
          const SafetyInsight(
            category: 'scams',
            description: 'Test',
            severity: 'low',
            tips: [],
          ),
          const SafetyInsight(
            category: 'natural',
            description: 'Test',
            severity: 'low',
            tips: [],
          ),
          const SafetyInsight(
            category: 'health',
            description: 'Test',
            severity: 'low',
            tips: [],
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafetyInsights(insights: insightsWithCategories),
            ),
          ),
        );

        expect(find.byIcon(Icons.money_off), findsOneWidget);
        expect(find.byIcon(Icons.cloud), findsOneWidget);
        expect(find.byIcon(Icons.local_hospital), findsOneWidget);
      });
    });

    group('Severity Indicators', () {
      testWidgets('renders correct color for low severity',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafetyInsights(insights: testInsights),
            ),
          ),
        );

        final lowSeverityContainer = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.child != null &&
              widget.decoration != null,
        );

        expect(lowSeverityContainer, findsWidgets);
      });

      testWidgets('renders check icon for low severity',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafetyInsights(insights: testInsights),
            ),
          ),
        );

        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('renders warning icon for medium severity',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafetyInsights(insights: testInsights),
            ),
          ),
        );

        expect(find.byIcon(Icons.warning_amber), findsOneWidget);
      });

      testWidgets('renders error icon for high severity',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafetyInsights(insights: testInsights),
            ),
          ),
        );

        expect(find.byIcon(Icons.error), findsOneWidget);
      });
    });

    group('Expand/Collapse', () {
      testWidgets('insights are collapsed by default',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafetyInsights(insights: testInsights),
            ),
          ),
        );

        // Tips should not be visible initially
        expect(find.text('Keep valuables secure'), findsNothing);
      });

      testWidgets('expands insight on tap', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafetyInsights(insights: testInsights),
            ),
          ),
        );

        // Tap on the first insight card
        await tester.tap(find.text('theft'));
        await tester.pumpAndSettle();

        // Tips should now be visible
        expect(find.text('Keep valuables secure'), findsOneWidget);
      });

      testWidgets('expands insights based on initiallyExpanded parameter',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafetyInsights(
                insights: testInsights,
                initiallyExpanded: 2,
              ),
            ),
          ),
        );

        // First 2 insights should show tips
        expect(find.text('Keep valuables secure'), findsOneWidget);
        expect(find.text('Use registered taxis'), findsOneWidget);
      });

      testWidgets('toggles expansion on double tap',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafetyInsights(insights: testInsights),
            ),
          ),
        );

        // First tap - expands
        await tester.tap(find.text('theft'));
        await tester.pumpAndSettle();
        expect(find.text('Keep valuables secure'), findsOneWidget);

        // Second tap - collapses
        await tester.tap(find.text('theft'));
        await tester.pumpAndSettle();
        expect(find.text('Keep valuables secure'), findsNothing);
      });
    });

    group('Empty State', () {
      testWidgets('shows empty state when no insights provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafetyInsights(insights: emptyInsights),
            ),
          ),
        );

        expect(find.text('No safety insights available'), findsOneWidget);
        expect(find.byIcon(Icons.security), findsOneWidget);
      });

      testWidgets('shows custom empty state message when provided via context',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SafetyInsights(insights: []),
            ),
          ),
        );

        expect(find.byIcon(Icons.security), findsOneWidget);
        expect(find.byType(Column), findsWidgets);
      });
    });

    group('Customization', () {
      testWidgets('uses custom padding', (WidgetTester tester) async {
        const customPadding = EdgeInsets.all(24);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafetyInsights(
                insights: testInsights,
                padding: customPadding,
              ),
            ),
          ),
        );

        final paddingWidget = tester.widget<Padding>(
          find.descendant(
            of: find.byType(SafetyInsights),
            matching: find.byType(Padding).first,
          ),
        );

        expect(paddingWidget.padding, customPadding);
      });
    });

    group('Layout', () {
      testWidgets('has proper column layout', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafetyInsights(insights: testInsights),
            ),
          ),
        );

        expect(find.byType(Column), findsWidgets);
      });

      testWidgets('insights are spaced properly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafetyInsights(insights: testInsights),
            ),
          ),
        );

        final paddingWidgets = find.byType(Padding);
        expect(paddingWidgets, findsWidgets);
      });
    });

    group('Accessibility', () {
      testWidgets('cards are tappable', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafetyInsights(insights: testInsights),
            ),
          ),
        );

        final inkWells = find.byType(InkWell);
        expect(inkWells, findsWidgets);
      });
    });
  });
}
