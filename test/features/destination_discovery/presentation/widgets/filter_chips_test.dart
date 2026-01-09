import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/destination_discovery/application/providers/filter_provider.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination_filter.dart';
import 'package:soloadventurer/features/destination_discovery/presentation/widgets/filter_chips.dart';

void main() {
  group('FilterChips', () {
    late FilterNotifier filterNotifier;

    setUp(() {
      filterNotifier = FilterNotifier();
    });

    group('Rendering', () {
      testWidgets('renders budget level chips', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(),
              ),
            ),
          ),
        );

        expect(find.text('Budget'), findsOneWidget);
        expect(find.text('Moderate'), findsOneWidget);
        expect(find.text('Luxury'), findsOneWidget);
      });

      testWidgets('renders activity level chips', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(),
              ),
            ),
          ),
        );

        expect(find.text('Relaxed'), findsOneWidget);
        expect(find.text('Moderate'), findsOneWidget);
        expect(find.text('Adventurous'), findsOneWidget);
      });

      testWidgets('renders hidden gems chip', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(),
              ),
            ),
          ),
        );

        expect(find.text('Hidden Gems'), findsOneWidget);
      });

      testWidgets('renders budget icons', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.attach_money), findsOneWidget);
        expect(find.byIcon(Icons.money), findsOneWidget);
        expect(find.byIcon(Icons.trending_up), findsOneWidget);
      });

      testWidgets('renders activity icons', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.self_improvement), findsOneWidget);
        expect(find.byIcon(Icons.directions_walk), findsOneWidget);
        expect(find.byIcon(Icons.hiking), findsOneWidget);
      });

      testWidgets('renders hidden gem diamond icon',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.diamond), findsOneWidget);
      });

      testWidgets('shows Clear All chip when filters are active',
          (WidgetTester tester) async {
        // Set a filter to make filters active
        filterNotifier.updateBudgetLevel(BudgetLevel.budget);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(),
              ),
            ),
          ),
        );

        expect(find.text('Clear All'), findsOneWidget);
      });

      testWidgets('does not show Clear All chip when no filters are active',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(),
              ),
            ),
          ),
        );

        expect(find.text('Clear All'), findsNothing);
      });

      testWidgets('renders custom tags when provided', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(
                  customTags: ['Beach', 'Mountain'],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Beach'), findsOneWidget);
        expect(find.text('Mountain'), findsOneWidget);
      });
    });

    group('Visibility', () {
      testWidgets('hides budget chips when showBudgetChips is false',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(
                  showBudgetChips: false,
                ),
              ),
            ),
          ),
        );

        expect(find.text('Budget'), findsNothing);
        expect(find.text('Moderate'), findsNothing);
        expect(find.text('Luxury'), findsNothing);
      });

      testWidgets('hides activity chips when showActivityChips is false',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(
                  showActivityChips: false,
                ),
              ),
            ),
          ),
        );

        expect(find.text('Relaxed'), findsNothing);
        expect(find.text('Adventurous'), findsNothing);
      });

      testWidgets('hides hidden gems chip when showHiddenGemsChip is false',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(
                  showHiddenGemsChip: false,
                ),
              ),
            ),
          ),
        );

        expect(find.text('Hidden Gems'), findsNothing);
      });
    });

    group('Interactions', () {
      testWidgets('selects budget chip on tap', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Budget'));
        await tester.pump();

        expect(filterNotifier.state.budgetLevel, BudgetLevel.budget);
      });

      testWidgets('deselects budget chip when tapped again',
          (WidgetTester tester) async {
        filterNotifier.updateBudgetLevel(BudgetLevel.budget);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Budget'));
        await tester.pump();

        expect(filterNotifier.state.budgetLevel, isNull);
      });

      testWidgets('selects activity chip on tap', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Relaxed'));
        await tester.pump();

        expect(filterNotifier.state.activityLevel, ActivityLevel.relaxed);
      });

      testWidgets('toggles hidden gems chip on tap',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Hidden Gems'));
        await tester.pump();

        expect(filterNotifier.state.hiddenGemsOnly, isTrue);

        await tester.tap(find.text('Hidden Gems'));
        await tester.pump();

        expect(filterNotifier.state.hiddenGemsOnly, isFalse);
      });

      testWidgets('toggles custom tag on tap', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(
                  customTags: ['Beach', 'Mountain'],
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Beach'));
        await tester.pump();

        expect(filterNotifier.state.tags, contains('Beach'));

        await tester.tap(find.text('Beach'));
        await tester.pump();

        expect(filterNotifier.state.tags, isNot(contains('Beach')));
      });

      testWidgets('clears all filters when Clear All is tapped',
          (WidgetTester tester) async {
        filterNotifier
          ..updateBudgetLevel(BudgetLevel.budget)
          ..updateActivityLevel(ActivityLevel.relaxed)
          ..toggleHiddenGemsOnly();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Clear All'));
        await tester.pump();

        expect(filterNotifier.state.budgetLevel, isNull);
        expect(filterNotifier.state.activityLevel, isNull);
        expect(filterNotifier.state.hiddenGemsOnly, isFalse);
      });

      testWidgets('calls onFilterChanged callback when chip is tapped',
          (WidgetTester tester) async {
        var callbackCalled = false;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: FilterChips(
                  onFilterChanged: () => callbackCalled = true,
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Budget'));
        await tester.pump();

        expect(callbackCalled, isTrue);
      });
    });

    group('Visual Feedback', () {
      testWidgets('highlights selected budget chip',
          (WidgetTester tester) async {
        filterNotifier.updateBudgetLevel(BudgetLevel.budget);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(),
              ),
            ),
          ),
        );

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
        filterNotifier.updateActivityLevel(ActivityLevel.relaxed);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(),
              ),
            ),
          ),
        );

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
        filterNotifier.toggleHiddenGemsOnly();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(),
              ),
            ),
          ),
        );

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
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(),
              ),
            ),
          ),
        );

        final listView = tester.widget<ListView>(
          find.byType(ListView),
        );

        expect(listView.scrollDirection, Axis.horizontal);
      });

      testWidgets('uses custom padding when provided',
          (WidgetTester tester) async {
        const customPadding = EdgeInsets.all(20);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(
                  padding: customPadding,
                ),
              ),
            ),
          ),
        );

        final listView = tester.widget<ListView>(
          find.byType(ListView),
        );

        expect(listView.padding, customPadding);
      });

      testWidgets('uses custom height when provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(
                  height: 80,
                ),
              ),
            ),
          ),
        );

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
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(),
              ),
            ),
          ),
        );

        expect(find.byWidgetPredicate(
          (widget) =>
              widget is FilterChip &&
              widget.label is Text &&
              (widget.label as Text).data == 'Budget' &&
              widget.label != null,
        ), findsOneWidget);
      });

      testWidgets('hidden gems chip has proper label',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterChips(),
              ),
            ),
          ),
        );

        expect(find.text('Hidden Gems'), findsOneWidget);
      });
    });
  });
}
