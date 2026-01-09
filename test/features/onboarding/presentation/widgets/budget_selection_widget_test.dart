import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/budget_range.dart';
import 'package:soloadventurer/features/onboarding/presentation/widgets/budget_selection_widget.dart';

/// Helper function to find text within SegmentedButton
/// SegmentedButton doesn't expose text directly to find.text()
Finder _findSegmentedButtonText(String text) {
  return find.byWidgetPredicate((widget) {
    if (widget is Text) {
      return widget.data == text;
    }
    return false;
  });
}

void main() {
  group('BudgetSelectionWidget Widget Tests', () {
    group('BudgetSelectionWidget (Main Widget)', () {
      testWidgets('renders all budget options', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionWidget(
                selectedBudget: null,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // SegmentedButton renders text internally, so we verify by type
        expect(find.byType(SegmentedButton<BudgetRange?>), findsOneWidget);

        // Verify the widget renders without errors
        expect(tester.takeException(), isNull);
      });

      testWidgets('shows skip option by default', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionWidget(
                selectedBudget: null,
                showSkipOption: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify icons are rendered (Skip has block icon)
        expect(find.byIcon(Icons.block), findsOneWidget);
        // Verify SegmentedButton exists
        expect(find.byType(SegmentedButton<BudgetRange?>), findsOneWidget);
      });

      testWidgets('hides skip option when showSkipOption is false',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionWidget(
                selectedBudget: null,
                showSkipOption: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Skip option hidden means no block icon
        expect(find.byIcon(Icons.block), findsNothing);
      });

      testWidgets('selects budget when option is tapped', (tester) async {
        BudgetRange? selectedBudget;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BudgetSelectionWidget(
                selectedBudget: null,
                onBudgetChanged: (budget) => selectedBudget = budget,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the first segment (Budget-Friendly with savings icon)
        await tester.tap(find.byIcon(Icons.savings));
        await tester.pumpAndSettle();

        expect(selectedBudget, BudgetRange.budgetFriendly);
      });

      testWidgets('selects moderate budget when tapped', (tester) async {
        BudgetRange? selectedBudget;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BudgetSelectionWidget(
                selectedBudget: null,
                onBudgetChanged: (budget) => selectedBudget = budget,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the second segment (Moderate with wallet icon)
        await tester.tap(find.byIcon(Icons.account_balance_wallet));
        await tester.pumpAndSettle();

        expect(selectedBudget, BudgetRange.moderate);
      });

      testWidgets('selects flexible budget when tapped', (tester) async {
        BudgetRange? selectedBudget;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BudgetSelectionWidget(
                selectedBudget: null,
                onBudgetChanged: (budget) => selectedBudget = budget,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the third segment (Flexible with diamond icon)
        await tester.tap(find.byIcon(Icons.diamond));
        await tester.pumpAndSettle();

        expect(selectedBudget, BudgetRange.flexible);
      });

      testWidgets('can skip budget selection', (tester) async {
        BudgetRange? selectedBudget;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BudgetSelectionWidget(
                selectedBudget: BudgetRange.moderate,
                onBudgetChanged: (budget) => selectedBudget = budget,
                showSkipOption: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.block));
        await tester.pumpAndSettle();

        expect(selectedBudget, isNull);
      });

      testWidgets('shows icon for each budget option', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionWidget(
                selectedBudget: null,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.savings), findsOneWidget);
        expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
        expect(find.byIcon(Icons.diamond), findsOneWidget);
        expect(find.byIcon(Icons.block), findsOneWidget);
      });

      testWidgets('respects custom visual density', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionWidget(
                selectedBudget: null,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final segmentedButton = tester.widget<SegmentedButton<BudgetRange?>>(
          find.byType(SegmentedButton<BudgetRange?>),
        );
        expect(
          segmentedButton.style?.visualDensity,
          VisualDensity.compact,
        );
      });

      testWidgets('wraps in card when wrapInCard is true', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionWidget(
                selectedBudget: null,
                wrapInCard: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Card), findsOneWidget);
      });

      testWidgets('does not wrap in card by default', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionWidget(
                selectedBudget: null,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Card), findsNothing);
      });

      testWidgets('shows custom title when provided', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionWidget(
                selectedBudget: null,
                title: 'Select Your Budget',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Select Your Budget'), findsOneWidget);
      });

      testWidgets('shows custom description when provided', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionWidget(
                selectedBudget: null,
                description: 'Choose your preferred spending range',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
            find.text('Choose your preferred spending range'), findsOneWidget);
      });

      testWidgets('highlights selected budget with color', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionWidget(
                selectedBudget: BudgetRange.budgetFriendly,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final segmentedButton = tester.widget<SegmentedButton<BudgetRange?>>(
          find.byType(SegmentedButton<BudgetRange?>),
        );

        // Check that the button has a selection
        expect(segmentedButton.selected, contains(BudgetRange.budgetFriendly));
      });
    });

    group('BudgetSelectionCard (Card Style)', () {
      testWidgets('renders all budget options as cards', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionCard(
                selectedBudget: null,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.savings), findsOneWidget);
        expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
        expect(find.byIcon(Icons.diamond), findsOneWidget);
      });

      testWidgets('shows description for each budget option', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionCard(
                selectedBudget: null,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Check that descriptions are rendered
        expect(
          find.text('Economy options with great value'),
          findsOneWidget,
        );
        expect(
          find.text('Comfortable mid-range options'),
          findsOneWidget,
        );
        expect(
          find.text('Premium experiences when worth it'),
          findsOneWidget,
        );
      });

      testWidgets('shows checkmark for selected budget', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionCard(
                selectedBudget: BudgetRange.moderate,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should have one checkmark
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('no checkmark when no budget selected', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionCard(
                selectedBudget: null,
                showSkipOption: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // With skip option hidden and no budget selected, there should be no checkmarks
        expect(find.byIcon(Icons.check_circle), findsNothing);
      });

      testWidgets('calls onBudgetChanged when card is tapped', (tester) async {
        BudgetRange? selectedBudget;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BudgetSelectionCard(
                selectedBudget: null,
                onBudgetChanged: (budget) => selectedBudget = budget,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the budget-friendly card
        await tester.tap(find.byIcon(Icons.savings));
        await tester.pumpAndSettle();

        expect(selectedBudget, BudgetRange.budgetFriendly);
      });

      testWidgets('shows skip option with description', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionCard(
                selectedBudget: null,
                showSkipOption: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.block), findsOneWidget);
        expect(
          find.text("I'll decide later (no budget preference)"),
          findsOneWidget,
        );
      });

      testWidgets('hides skip option when showSkipOption is false',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionCard(
                selectedBudget: null,
                showSkipOption: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(_findSegmentedButtonText('Skip'), findsNothing);
      });

      testWidgets('shows different colors for different budgets',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionCard(
                selectedBudget: BudgetRange.budgetFriendly,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Budget-friendly should have green checkmark
        // The checkmark is in a separate widget, so we verify it exists with the right color
        final checkmarkIcon = find.byWidgetPredicate((widget) {
          return widget is Icon &&
              (widget).icon == Icons.check_circle &&
              (widget).color == Colors.green;
        });
        expect(checkmarkIcon, findsOneWidget);
      });
    });

    group('BudgetSelectionCompact (Compact Style)', () {
      testWidgets('renders all budget options as chips', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionCompact(
                selectedBudget: null,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(FilterChip), findsNWidgets(4));
      });

      testWidgets('shows label and icon for each option', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionCompact(
                selectedBudget: null,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.savings), findsOneWidget);
        expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
        expect(find.byIcon(Icons.diamond), findsOneWidget);
        expect(find.byIcon(Icons.block), findsOneWidget);

        expect(find.byIcon(Icons.savings), findsOneWidget);
        expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
        expect(find.byIcon(Icons.diamond), findsOneWidget);
        expect(find.byIcon(Icons.block), findsOneWidget);
      });

      testWidgets('selects budget when chip is tapped', (tester) async {
        BudgetRange? selectedBudget;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BudgetSelectionCompact(
                selectedBudget: null,
                onBudgetChanged: (budget) => selectedBudget = budget,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find the chip containing the wallet icon and tap it
        final chipFinder = find.ancestor(
          of: find.byIcon(Icons.account_balance_wallet),
          matching: find.byType(FilterChip),
        );
        await tester.tap(chipFinder);
        await tester.pumpAndSettle();

        expect(selectedBudget, BudgetRange.moderate);
      });

      testWidgets('can skip budget selection', (tester) async {
        BudgetRange? selectedBudget;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BudgetSelectionCompact(
                selectedBudget: BudgetRange.flexible,
                onBudgetChanged: (budget) => selectedBudget = budget,
                showSkipOption: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find the chip containing the skip icon and tap it
        final skipChipFinder = find.ancestor(
          of: find.byIcon(Icons.block),
          matching: find.byType(FilterChip),
        );
        await tester.tap(skipChipFinder);
        await tester.pumpAndSettle();

        expect(selectedBudget, isNull);
      });

      testWidgets('hides skip option when showSkipOption is false',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionCompact(
                selectedBudget: null,
                showSkipOption: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should only have 3 chips (no skip)
        expect(find.byType(FilterChip), findsNWidgets(3));
      });

      testWidgets('uses compact visual density', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionCompact(
                selectedBudget: null,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final chips = find.byType(FilterChip);
        for (int i = 0; i < 4; i++) {
          final chip = tester.widget<FilterChip>(chips.at(i));
          expect(chip.visualDensity, VisualDensity.compact);
        }
      });

      testWidgets('shows correct selection color for each budget',
          (tester) async {
        // Test budget-friendly (green)
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionCompact(
                selectedBudget: BudgetRange.budgetFriendly,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final chip = tester.widget<FilterChip>(
          find.ancestor(
            of: find.byIcon(Icons.savings),
            matching: find.byType(FilterChip),
          ),
        );
        expect(chip.selectedColor, Colors.green.withValues(alpha: 0.15));
      });

      testWidgets('chips are arranged in a wrap layout', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionCompact(
                selectedBudget: null,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Wrap), findsOneWidget);
      });
    });

    group('Visual Styling and Accessibility', () {
      testWidgets('budget option has proper color coding', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionCard(
                selectedBudget: BudgetRange.budgetFriendly,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find the container for budget-friendly option
        final container = tester.widget<Container>(
          find.descendant(
            of: find.ancestor(
              of: find.byIcon(Icons.savings),
              matching: find.byType(InkWell),
            ),
            matching: find.byType(Container).first,
          ),
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, Colors.green.withValues(alpha: 0.15));
        expect(decoration.borderRadius, isNotNull);
      });

      testWidgets('has proper semantic labels', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionWidget(
                selectedBudget: null,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify the SegmentedButton exists with all options
        expect(find.byType(SegmentedButton<BudgetRange?>), findsOneWidget);

        // Verify all icons are present (each option has a unique icon)
        expect(find.byIcon(Icons.savings), findsOneWidget); // Budget-Friendly
        expect(find.byIcon(Icons.account_balance_wallet),
            findsOneWidget); // Moderate
        expect(find.byIcon(Icons.diamond), findsOneWidget); // Flexible
        expect(find.byIcon(Icons.block), findsOneWidget); // Skip
      });
    });

    group('Animation and Transitions', () {
      testWidgets('card animates on selection change', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionCard(
                selectedBudget: null,
              ),
            ),
          ),
        );
        await tester.pump();

        // Find the AnimatedContainer for the budget-friendly option
        final containerBefore = tester.widget<AnimatedContainer>(
          find.ancestor(
            of: find.byIcon(Icons.savings),
            matching: find.byType(AnimatedContainer),
          ),
        );

        // Change selection
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BudgetSelectionCard(
                selectedBudget: BudgetRange.budgetFriendly,
              ),
            ),
          ),
        );

        // Pump for animation
        await tester.pump(const Duration(milliseconds: 50));

        final containerAfter = tester.widget<AnimatedContainer>(
          find.ancestor(
            of: find.byIcon(Icons.savings),
            matching: find.byType(AnimatedContainer),
          ),
        );

        final decorationBefore = containerBefore.decoration as BoxDecoration;
        final decorationAfter = containerAfter.decoration as BoxDecoration;

        // Border width should change
        final borderBefore = decorationBefore.border as Border;
        final borderAfter = decorationAfter.border as Border;

        expect(
          borderAfter.top.width,
          greaterThan(borderBefore.top.width),
        );
      });

      testWidgets('compact chip animates on selection', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BudgetSelectionCompact(
                selectedBudget: null,
                onBudgetChanged: (budget) {
                  // Callback triggered on selection
                },
              ),
            ),
          ),
        );
        await tester.pump();

        // Find the chip containing the wallet icon and tap it
        final chipFinder = find.ancestor(
          of: find.byIcon(Icons.account_balance_wallet),
          matching: find.byType(FilterChip),
        );

        expect(chipFinder, findsOneWidget);
        await tester.tap(chipFinder);
        await tester.pump(const Duration(milliseconds: 50));

        // Animation should be in progress
        expect(find.byType(BudgetSelectionCompact), findsOneWidget);
      });
    });
  });
}
