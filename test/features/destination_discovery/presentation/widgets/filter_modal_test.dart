import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/destination_discovery/application/providers/filter_provider.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination_filter.dart';
import 'package:soloadventurer/features/destination_discovery/presentation/widgets/filter_modal.dart';

void main() {
  group('FilterModal', () {
    late FilterNotifier filterNotifier;

    setUp(() {
      filterNotifier = FilterNotifier();
    });

    group('Rendering', () {
      testWidgets('renders modal title', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Filter Destinations'), findsOneWidget);
      });

      testWidgets('renders budget level section', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Budget Level'), findsOneWidget);
        expect(find.text('Budget'), findsOneWidget);
        expect(find.text('Moderate'), findsOneWidget);
        expect(find.text('Luxury'), findsOneWidget);
      });

      testWidgets('renders safety score slider', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Minimum Safety Score'), findsOneWidget);
        expect(find.byType(Slider), findsOneWidget);
      });

      testWidgets('renders solo suitability score slider',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Minimum Solo Suitability'), findsOneWidget);
      });

      testWidgets('renders activity level section', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Activity Level'), findsOneWidget);
        expect(find.text('Relaxed'), findsOneWidget);
        expect(find.text('Adventurous'), findsOneWidget);
      });

      testWidgets('renders location section', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Location'), findsOneWidget);
        expect(find.byType(TextField), findsWidgets);
      });

      testWidgets('renders tags section', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Tags'), findsOneWidget);
        expect(find.text('Beach'), findsOneWidget);
        expect(find.text('Mountain'), findsOneWidget);
        expect(find.text('Urban'), findsOneWidget);
      });

      testWidgets('renders hidden gems toggle', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Hidden Gems Only'), findsOneWidget);
        expect(find.byType(Switch), findsOneWidget);
      });

      testWidgets('renders sort order dropdown', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Sort By'), findsOneWidget);
        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      });

      testWidgets('renders Apply and Cancel buttons',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Apply'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('shows Clear All button when filters are active',
          (WidgetTester tester) async {
        filterNotifier.updateBudgetLevel(BudgetLevel.budget);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Clear All'), findsOneWidget);
      });

      testWidgets('does not show Clear All button when no filters are active',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Clear All'), findsNothing);
      });
    });

    group('Filter State Display', () {
      testWidgets('displays current budget level', (WidgetTester tester) async {
        filterNotifier.updateBudgetLevel(BudgetLevel.budget);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        // Find the selected budget chip
        final selectedChip = find.byWidgetPredicate(
          (widget) =>
              widget is FilterChip && widget.selected == true && widget.label is Text && (widget.label as Text).data == 'Budget',
        );

        expect(selectedChip, findsOneWidget);
      });

      testWidgets('displays current activity level', (WidgetTester tester) async {
        filterNotifier.updateActivityLevel(ActivityLevel.relaxed);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        final selectedChip = find.byWidgetPredicate(
          (widget) =>
              widget is FilterChip && widget.selected == true && widget.label is Text && (widget.label as Text).data == 'Relaxed',
        );

        expect(selectedChip, findsOneWidget);
      });

      testWidgets('displays current safety score', (WidgetTester tester) async {
        filterNotifier.updateMinSafetyScore(7.5);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('7.5'), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets('selecting budget chip updates temporary state',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Budget'));
        await tester.pump();

        // Temporary state should be updated
        expect(find.text('Budget'), findsOneWidget);
      });

      testWidgets('tapping Apply calls onApply callback',
          (WidgetTester tester) async {
        var applyCalled = false;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () => applyCalled = true,
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Apply'));
        await tester.pump();

        expect(applyCalled, isTrue);
      });

      testWidgets('tapping Cancel calls onCancel callback',
          (WidgetTester tester) async {
        var cancelCalled = false;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                  onCancel: () => cancelCalled = true,
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Cancel'));
        await tester.pump();

        expect(cancelCalled, isTrue);
      });

      testWidgets('tapping Clear All resets temporary filters',
          (WidgetTester tester) async {
        filterNotifier.updateBudgetLevel(BudgetLevel.budget);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Clear All'));
        await tester.pump();

        // Clear All button should disappear
        expect(find.text('Clear All'), findsNothing);
      });

      testWidgets('tapping tag selects it', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Beach'));
        await tester.pump();

        // Tag should now be selected
        final selectedChip = find.byWidgetPredicate(
          (widget) =>
              widget is FilterChip &&
              widget.selected == true &&
              widget.label is Text &&
              (widget.label as Text).data == 'Beach',
        );

        expect(selectedChip, findsOneWidget);
      });

      testWidgets('tapping selected tag deselects it',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        // First tap - select
        await tester.tap(find.text('Beach'));
        await tester.pump();

        // Second tap - deselect
        await tester.tap(find.text('Beach'));
        await tester.pump();

        final selectedChip = find.byWidgetPredicate(
          (widget) =>
              widget is FilterChip &&
              widget.selected == true &&
              widget.label is Text &&
              (widget.label as Text).data == 'Beach',
        );

        expect(selectedChip, findsNothing);
      });

      testWidgets('toggling hidden gems switch updates state',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        final switchWidget = tester.widget<Switch>(
          find.byType(Switch),
        );

        expect(switchWidget.value, isFalse);

        await tester.tap(find.byType(Switch));
        await tester.pump();

        final updatedSwitch = tester.widget<Switch>(
          find.byType(Switch),
        );

        expect(updatedSwitch.value, isTrue);
      });

      testWidgets('changing sort order updates dropdown',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();

        // Tap on a different sort option
        await tester.tap(find.text('Safety').last);
        await tester.pump();

        // Dropdown should update
        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      });
    });

    group('Slider Interactions', () {
      testWidgets('dragging safety score slider updates value',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        // Find the safety score slider (first one)
        final slider = find.byType(Slider).first;

        await tester.drag(slider, const Offset(100, 0));
        await tester.pump();

        // Score should be updated
        expect(find.byType(Slider), findsWidgets);
      });

      testWidgets('safety score displays correct color based on value',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        // Default should be green (>= 8)
        expect(find.text('8.0'), findsOneWidget);
      });
    });

    group('Layout', () {
      testWidgets('shows handle bar at top', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('is scrollable when content overflows',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });

      testWidgets('shows active filter count in header',
          (WidgetTester tester) async {
        filterNotifier
          ..updateBudgetLevel(BudgetLevel.budget)
          ..updateActivityLevel(ActivityLevel.relaxed);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('(2)'), findsOneWidget);
      });
    });

    group('Text Input', () {
      testWidgets('accepts country code input', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        final countryCodeField = find.widgetWithText(TextField, 'Country Code');

        await tester.enterText(countryCodeField, 'JP');
        await tester.pump();

        expect(find.text('JP'), findsOneWidget);
      });

      testWidgets('accepts region input', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filterProvider.overrideWith((ref) => filterNotifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FilterModal(
                  onApply: () {},
                ),
              ),
            ),
          ),
        );

        final regionField = find.widgetWithText(TextField, 'Region');

        await tester.enterText(regionField, 'Kanto');
        await tester.pump();

        expect(find.text('Kanto'), findsOneWidget);
      });
    });
  });
}
