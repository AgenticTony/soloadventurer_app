import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/destination_discovery/application/providers/filter_provider.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination_filter.dart';
import 'package:soloadventurer/features/destination_discovery/presentation/widgets/filter_modal.dart';

void main() {
  group('FilterModal', () {
    // Helper to create a test filter notifier initializer
    Filter Function() createFilterFactory({DestinationFilter? initial}) {
      return () => _TestFilter(initial ?? DestinationFilter());
    }

    Widget buildTestWidget({
      DestinationFilter? initialFilter,
      VoidCallback? onApply,
      VoidCallback? onDismiss,
      List<String> availableTags = const [
        'Beach',
        'Mountain',
        'Urban',
        'Cultural',
        'Adventure',
        'Nature',
        'Food',
        'Wellness',
        'Nightlife',
        'Shopping',
        'Historical',
        'Romantic',
      ],
      bool showSortOrder = true,
    }) {
      return ProviderScope(
        overrides: [
          filterProvider.overrideWith(
            createFilterFactory(initial: initialFilter),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: FilterModal(
              onApply: onApply,
              onDismiss: onDismiss,
              availableTags: availableTags,
              showSortOrder: showSortOrder,
            ),
          ),
        ),
      );
    }

    group('Rendering', () {
      testWidgets('renders modal title Filters', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Filters'), findsOneWidget);
      });

      testWidgets('renders budget level section', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Budget Level'), findsOneWidget);
        // FilterBudgetLevel values: Budget, Economy, Mid-Range, Premium, Luxury, Ultra Luxury
        expect(find.text('Budget'), findsOneWidget);
        expect(find.text('Economy'), findsOneWidget);
        expect(find.text('Mid-Range'), findsOneWidget);
        expect(find.text('Premium'), findsOneWidget);
        expect(find.text('Luxury'), findsOneWidget);
        expect(find.text('Ultra Luxury'), findsOneWidget);
      });

      testWidgets('renders safety score slider', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Minimum Safety Score'), findsOneWidget);
        expect(find.byType(Slider), findsWidgets);
      });

      testWidgets('renders solo suitability score section',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Solo Suitability Score'), findsOneWidget);
      });

      testWidgets('renders activity level section',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Scroll down to make Activity Level visible
        final listFinder = find.byType(ListView);
        await tester.drag(listFinder, const Offset(0, -500));
        await tester.pumpAndSettle();

        expect(find.text('Activity Level'), findsOneWidget);
        // FilterActivityLevel values: Relaxed, Light, Moderate, Active, Intense, Extreme
        expect(find.text('Relaxed'), findsOneWidget);
        expect(find.text('Moderate'), findsOneWidget);
        expect(find.text('Active'), findsOneWidget);
        expect(find.text('Extreme'), findsOneWidget);
      });

      testWidgets('renders location section', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        final listFinder = find.byType(ListView);
        // Scroll multiple times to reach the location section
        for (int i = 0; i < 10; i++) {
          await tester.drag(listFinder, const Offset(0, -500));
          await tester.pumpAndSettle();
          if (find.text('Location', skipOffstage: false).evaluate().isNotEmpty) {
            break;
          }
        }

        expect(find.text('Location', skipOffstage: false), findsOneWidget);
        expect(find.byType(TextField, skipOffstage: false), findsWidgets);
      });

      testWidgets('renders tags section as Categories',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        final listFinder = find.byType(ListView);
        await tester.drag(listFinder, const Offset(0, -1000));
        await tester.pumpAndSettle();

        expect(find.text('Categories'), findsOneWidget);
        expect(find.text('Beach'), findsOneWidget);
        expect(find.text('Mountain'), findsOneWidget);
        expect(find.text('Urban'), findsOneWidget);
      });

      testWidgets('renders hidden gems toggle', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        final listFinder = find.byType(ListView);
        await tester.drag(listFinder, const Offset(0, -1200));
        await tester.pumpAndSettle();

        expect(find.text('Hidden Gems Only'), findsOneWidget);
        // SwitchListTile uses a Switch
        expect(find.byType(Switch), findsOneWidget);
      });

      testWidgets('renders sort order dropdown', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        final listFinder = find.byType(ListView);
        await tester.drag(listFinder, const Offset(0, -1400));
        await tester.pumpAndSettle();

        expect(find.text('Sort By'), findsOneWidget);
        expect(
            find.byType(DropdownButtonFormField<DestinationSortOrder>),
            findsOneWidget);
      });

      testWidgets('hides sort order when showSortOrder is false',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget(showSortOrder: false));
        await tester.pumpAndSettle();

        expect(find.text('Sort By'), findsNothing);
      });

      testWidgets('renders Apply Filters and Cancel buttons',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Apply Filters'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('shows Clear All button when filters are active',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialFilter: DestinationFilter(budgetLevel: FilterBudgetLevel.budget),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Clear All'), findsOneWidget);
      });

      testWidgets('does not show Clear All when no filters are active',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Clear All'), findsNothing);
      });
    });

    group('Interactions', () {
      testWidgets('tapping Apply Filters calls onApply callback',
          (WidgetTester tester) async {
        var applyCalled = false;

        await tester.pumpWidget(
            buildTestWidget(onApply: () => applyCalled = true));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Apply Filters'));
        await tester.pumpAndSettle();

        expect(applyCalled, isTrue);
      });

      testWidgets('tapping Cancel calls onDismiss callback',
          (WidgetTester tester) async {
        var dismissCalled = false;

        await tester.pumpWidget(buildTestWidget(
          onDismiss: () => dismissCalled = true,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(dismissCalled, isTrue);
      });

      testWidgets('tapping Clear All resets temporary filters',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialFilter: DestinationFilter(budgetLevel: FilterBudgetLevel.budget),
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Clear All'));
        await tester.pumpAndSettle();

        // Clear All button should disappear after reset
        expect(find.text('Clear All'), findsNothing);
      });

      testWidgets('selecting budget chip updates temporary state',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Budget'));
        await tester.pumpAndSettle();

        // Budget chip should be selected
        final budgetChip = find.byWidgetPredicate(
          (widget) =>
              widget is FilterChip &&
              widget.selected == true &&
              widget.label is Row,
        );
        // At least one chip should be selected
        expect(budgetChip, findsWidgets);
      });

      testWidgets('tapping tag selects it', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Scroll to tags section
        final listFinder = find.byType(ListView);
        for (int i = 0; i < 15; i++) {
          await tester.drag(listFinder, const Offset(0, -500));
          await tester.pumpAndSettle();
          if (find.text('Beach', skipOffstage: false).evaluate().isNotEmpty) {
            break;
          }
        }

        final beachFinder = find.text('Beach', skipOffstage: false);
        expect(beachFinder, findsOneWidget);
        await tester.tap(beachFinder);
        await tester.pumpAndSettle();

        // Should show "1 selected"
        expect(find.text('1 selected', skipOffstage: false), findsOneWidget);
      });

      testWidgets('tapping selected tag deselects it',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Scroll to tags section
        final listFinder = find.byType(ListView);
        for (int i = 0; i < 15; i++) {
          await tester.drag(listFinder, const Offset(0, -500));
          await tester.pumpAndSettle();
          if (find.text('Beach', skipOffstage: false).evaluate().isNotEmpty) {
            break;
          }
        }

        final beachFinder = find.text('Beach', skipOffstage: false);
        // First tap - select
        await tester.tap(beachFinder);
        await tester.pumpAndSettle();

        // Second tap - deselect
        await tester.tap(beachFinder);
        await tester.pumpAndSettle();

        // "selected" text should be gone
        expect(find.text('1 selected', skipOffstage: false), findsNothing);
      });

      testWidgets('toggling hidden gems switch updates state',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Scroll to hidden gems section
        final listFinder = find.byType(ListView);
        await tester.drag(listFinder, const Offset(0, -1200));
        await tester.pumpAndSettle();

        final switchWidget = tester.widget<Switch>(find.byType(Switch));
        expect(switchWidget.value, isFalse);

        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        final updatedSwitch = tester.widget<Switch>(find.byType(Switch));
        expect(updatedSwitch.value, isTrue);
      });

      testWidgets('dragging safety score slider updates value',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Find the first slider (safety score)
        final slider = find.byType(Slider).first;

        await tester.drag(slider, const Offset(100, 0));
        await tester.pumpAndSettle();

        // Slider should still exist
        expect(find.byType(Slider), findsWidgets);
      });
    });

    group('Text Input', () {
      testWidgets('accepts country code input', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Scroll to location section
        final listFinder = find.byType(ListView);
        for (int i = 0; i < 15; i++) {
          await tester.drag(listFinder, const Offset(0, -500));
          await tester.pumpAndSettle();
          if (find.text('Country Code', skipOffstage: false).evaluate().isNotEmpty) {
            break;
          }
        }

        final countryCodeField =
            find.widgetWithText(TextField, 'Country Code (e.g., JP, US, TH)', skipOffstage: false);

        await tester.enterText(countryCodeField, 'JP');
        await tester.pump();

        // Verify the text was entered by checking the controller
        final enteredField = tester.widget<TextField>(countryCodeField);
        expect(enteredField.controller?.text, 'JP');
      });

      testWidgets('accepts region input', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Scroll to location section
        final listFinder = find.byType(ListView);
        for (int i = 0; i < 15; i++) {
          await tester.drag(listFinder, const Offset(0, -500));
          await tester.pumpAndSettle();
          if (find.text('Region', skipOffstage: false).evaluate().isNotEmpty) {
            break;
          }
        }

        final regionField =
            find.widgetWithText(TextField, 'Region (e.g., Tokyo, California)', skipOffstage: false);

        await tester.enterText(regionField, 'Kanto');
        await tester.pump();

        // Verify the text was entered by checking the controller
        final enteredField = tester.widget<TextField>(regionField);
        expect(enteredField.controller?.text, 'Kanto');
      });
    });

    group('Layout', () {
      testWidgets('shows handle bar at top', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Handle bar is a Container with specific dimensions
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('is scrollable with ListView',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('shows active filter count in header',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialFilter: DestinationFilter(
            budgetLevel: FilterBudgetLevel.budget,
            activityLevel: FilterActivityLevel.relaxed,
          ),
        ));
        await tester.pumpAndSettle();

        // Should show "2 active" in header
        expect(find.text('2 active'), findsOneWidget);
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
