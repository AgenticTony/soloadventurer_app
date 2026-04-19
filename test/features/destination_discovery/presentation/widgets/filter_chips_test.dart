import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/destination_discovery/application/providers/filter_provider.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination_filter.dart';
import 'package:soloadventurer/features/destination_discovery/presentation/widgets/filter_chips.dart';

void main() {
  group('FilterChips', () {
    Widget buildTestWidget({
      DestinationFilter? initialFilter,
      List<String>? customTags,
      bool showBudgetChips = true,
      bool showActivityChips = true,
      bool showHiddenGemsChip = true,
      VoidCallback? onFilterChanged,
      EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      double? height,
    }) {
      return ProviderScope(
        overrides: [
          filterProvider.overrideWith(
            () => _TestFilter(initialFilter ?? DestinationFilter()),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: FilterChips(
              customTags: customTags,
              showBudgetChips: showBudgetChips,
              showActivityChips: showActivityChips,
              showHiddenGemsChip: showHiddenGemsChip,
              onFilterChanged: onFilterChanged,
              padding: padding,
              height: height ?? 50,
            ),
          ),
        ),
      );
    }

    group('Rendering', () {
      testWidgets('renders budget level chips', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Budget'), findsOneWidget);
        expect(find.text('Mid-Range'), findsOneWidget);
        expect(find.text('Luxury'), findsOneWidget);
      });

      testWidgets('renders activity level chips', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Relaxed'), findsOneWidget);
        expect(find.text('Moderate'), findsOneWidget);
        expect(find.text('Active'), findsOneWidget);
      });

      testWidgets('renders hidden gems chip', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Scroll to ensure hidden gems chip is visible
        await tester.drag(find.byType(ListView), const Offset(-300, 0));
        await tester.pumpAndSettle();
        expect(find.text('Hidden Gems'), findsOneWidget);
      });

      testWidgets('renders budget icons', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.attach_money), findsOneWidget);
        expect(find.byIcon(Icons.money), findsOneWidget);
        expect(find.byIcon(Icons.diamond), findsOneWidget);
      });

      testWidgets('renders activity icons', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.self_improvement), findsOneWidget);
        expect(find.byIcon(Icons.hiking), findsOneWidget);
        expect(find.byIcon(Icons.terrain), findsOneWidget);
      });

      testWidgets('renders hidden gem diamond icon',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Both hidden gems chip and luxury chip use diamond icon
        expect(find.byIcon(Icons.diamond), findsWidgets);
      });

      testWidgets('shows Clear All chip when filters are active',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialFilter: DestinationFilter(budgetLevel: FilterBudgetLevel.budget),
        ));
        await tester.pumpAndSettle();

        await tester.drag(find.byType(ListView), const Offset(-500, 0));
        await tester.pumpAndSettle();
        expect(find.text('Clear All'), findsOneWidget);
      });

      testWidgets('does not show Clear All chip when no filters are active',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Clear All'), findsNothing);
      });

      testWidgets('renders custom tags when provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget(
          customTags: ['Beach', 'Mountain'],
        ));
        await tester.pumpAndSettle();

        await tester.drag(find.byType(ListView), const Offset(-500, 0));
        await tester.pumpAndSettle();
        expect(find.text('Beach'), findsOneWidget);
        expect(find.text('Mountain'), findsOneWidget);
      });
    });

    group('Visibility', () {
      testWidgets('hides budget chips when showBudgetChips is false',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget(showBudgetChips: false));
        await tester.pumpAndSettle();

        expect(find.text('Budget'), findsNothing);
        expect(find.text('Mid-Range'), findsNothing);
        expect(find.text('Luxury'), findsNothing);
      });

      testWidgets('hides activity chips when showActivityChips is false',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget(showActivityChips: false));
        await tester.pumpAndSettle();

        expect(find.text('Relaxed'), findsNothing);
        expect(find.text('Active'), findsNothing);
      });

      testWidgets('hides hidden gems chip when showHiddenGemsChip is false',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget(showHiddenGemsChip: false));
        await tester.pumpAndSettle();

        expect(find.text('Hidden Gems'), findsNothing);
      });
    });

    group('Interactions', () {
      testWidgets('selects budget chip on tap', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Budget'));
        await tester.pump();

        // Verify the chip is now selected
        final filterChip = tester.widget<FilterChip>(
          find.ancestor(
            of: find.text('Budget'),
            matching: find.byType(FilterChip),
          ),
        );
        expect(filterChip.selected, isTrue);
      });

      testWidgets('deselects budget chip when tapped again',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialFilter: DestinationFilter(budgetLevel: FilterBudgetLevel.budget),
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Budget'));
        await tester.pump();

        final filterChip = tester.widget<FilterChip>(
          find.ancestor(
            of: find.text('Budget'),
            matching: find.byType(FilterChip),
          ),
        );
        expect(filterChip.selected, isFalse);
      });

      testWidgets('selects activity chip on tap', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Relaxed'));
        await tester.pump();

        final filterChip = tester.widget<FilterChip>(
          find.ancestor(
            of: find.text('Relaxed'),
            matching: find.byType(FilterChip),
          ),
        );
        expect(filterChip.selected, isTrue);
      });

      testWidgets('toggles hidden gems chip on tap',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.drag(find.byType(ListView), const Offset(-300, 0));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Hidden Gems'));
        await tester.pump();

        final filterChip = tester.widget<FilterChip>(
          find.ancestor(
            of: find.text('Hidden Gems'),
            matching: find.byType(FilterChip),
          ),
        );
        expect(filterChip.selected, isTrue);

        await tester.drag(find.byType(ListView), const Offset(-300, 0));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Hidden Gems'));
        await tester.pump();

        final updatedChip = tester.widget<FilterChip>(
          find.ancestor(
            of: find.text('Hidden Gems'),
            matching: find.byType(FilterChip),
          ),
        );
        expect(updatedChip.selected, isFalse);
      });

      testWidgets('toggles custom tag on tap', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget(
          customTags: ['Beach', 'Mountain'],
        ));
        await tester.pumpAndSettle();

        await tester.drag(find.byType(ListView), const Offset(-500, 0));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Beach'));
        await tester.pump();

        final filterChip = tester.widget<FilterChip>(
          find.ancestor(
            of: find.text('Beach'),
            matching: find.byType(FilterChip),
          ),
        );
        expect(filterChip.selected, isTrue);

        await tester.tap(find.text('Beach'));
        await tester.pump();

        final updatedChip = tester.widget<FilterChip>(
          find.ancestor(
            of: find.text('Beach'),
            matching: find.byType(FilterChip),
          ),
        );
        expect(updatedChip.selected, isFalse);
      });

      testWidgets('clears all filters when Clear All is tapped',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialFilter: DestinationFilter(
            budgetLevel: FilterBudgetLevel.budget,
            activityLevel: FilterActivityLevel.relaxed,
            hiddenGemsOnly: true,
          ),
        ));
        await tester.pumpAndSettle();

        await tester.drag(find.byType(ListView), const Offset(-500, 0));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Clear All'));
        await tester.pump();

        // Chips should now be deselected
        expect(find.text('Clear All'), findsNothing);
      });

      testWidgets('calls onFilterChanged callback when chip is tapped',
          (WidgetTester tester) async {
        var callbackCalled = false;

        await tester.pumpWidget(buildTestWidget(
          onFilterChanged: () => callbackCalled = true,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Budget'));
        await tester.pump();

        expect(callbackCalled, isTrue);
      });
    });

    group('Visual Feedback', () {
      testWidgets('highlights selected budget chip',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialFilter: DestinationFilter(budgetLevel: FilterBudgetLevel.budget),
        ));
        await tester.pumpAndSettle();

        final filterChip = tester.widget<FilterChip>(
          find.ancestor(
            of: find.text('Budget'),
            matching: find.byType(FilterChip),
          ),
        );

        expect(filterChip.selected, isTrue);
      });

      testWidgets('highlights selected activity chip',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialFilter:
              DestinationFilter(activityLevel: FilterActivityLevel.relaxed),
        ));
        await tester.pumpAndSettle();

        final filterChip = tester.widget<FilterChip>(
          find.ancestor(
            of: find.text('Relaxed'),
            matching: find.byType(FilterChip),
          ),
        );

        expect(filterChip.selected, isTrue);
      });

      testWidgets('highlights selected hidden gem chip',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialFilter: DestinationFilter(hiddenGemsOnly: true),
        ));
        await tester.pumpAndSettle();

        await tester.drag(find.byType(ListView), const Offset(-300, 0));
        await tester.pumpAndSettle();
        final filterChip = tester.widget<FilterChip>(
          find.ancestor(
            of: find.text('Hidden Gems'),
            matching: find.byType(FilterChip),
          ),
        );

        expect(filterChip.selected, isTrue);
      });
    });

    group('Layout', () {
      testWidgets('renders as horizontal scrollable list',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        final listView = tester.widget<ListView>(
          find.byType(ListView),
        );

        expect(listView.scrollDirection, Axis.horizontal);
      });

      testWidgets('uses custom padding when provided',
          (WidgetTester tester) async {
        const customPadding = EdgeInsets.all(20);

        await tester.pumpWidget(buildTestWidget(padding: customPadding));
        await tester.pumpAndSettle();

        final listView = tester.widget<ListView>(
          find.byType(ListView),
        );

        expect(listView.padding, customPadding);
      });

      testWidgets('uses custom height when provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget(height: 80));
        await tester.pumpAndSettle();

        final sizedBox = tester.widget<SizedBox>(
          find.descendant(
            of: find.byType(FilterChips),
            matching: find.byType(SizedBox).first,
          ),
        );

        expect(sizedBox.height, 80);
      });
    });

    group('Accessibility', () {
      testWidgets('budget chips have proper labels',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(
            find.byWidgetPredicate(
              (widget) =>
                  widget is FilterChip &&
                  widget.label is Row,
            ),
            findsWidgets);
      });

      testWidgets('hidden gems chip has proper label',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.drag(find.byType(ListView), const Offset(-300, 0));
        await tester.pumpAndSettle();
        expect(find.text('Hidden Gems'), findsOneWidget);
      });
    });
  });
}

/// A test-only Filter subclass that allows injecting initial state
class _TestFilter extends Filter {
  final DestinationFilter _initialFilter;

  _TestFilter(this._initialFilter);

  @override
  DestinationFilter build() {
    return _initialFilter;
  }
}
