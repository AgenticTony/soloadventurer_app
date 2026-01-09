import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';
import 'package:soloadventurer/features/onboarding/presentation/widgets/travel_interest_chip.dart';

void main() {
  group('TravelInterestChip Widget Tests', () {
    group('TravelInterestChip', () {
      testWidgets('renders with emoji and label', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TravelInterestChip(
                interest: TravelInterest.food,
                isSelected: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Emoji appears twice (in label and avatar)
        expect(find.text('🍽️'), findsNWidgets(2));
        expect(find.text('Food & Cuisine'), findsOneWidget);
      });

      testWidgets('shows selected state when isSelected is true',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TravelInterestChip(
                interest: TravelInterest.food,
                isSelected: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final filterChip = tester.widget<FilterChip>(
          find.byType(FilterChip),
        );
        expect(filterChip.selected, isTrue);
      });

      testWidgets('shows unselected state when isSelected is false',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TravelInterestChip(
                interest: TravelInterest.food,
                isSelected: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final filterChip = tester.widget<FilterChip>(
          find.byType(FilterChip),
        );
        expect(filterChip.selected, isFalse);
      });

      testWidgets('calls onToggle callback when tapped', (tester) async {
        var callbackCalled = false;
        TravelInterest? tappedInterest;
        bool? selectedState;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TravelInterestChip(
                interest: TravelInterest.food,
                isSelected: false,
                onToggle: (interest, selected) {
                  callbackCalled = true;
                  tappedInterest = interest;
                  selectedState = selected;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FilterChip));
        await tester.pumpAndSettle();

        expect(callbackCalled, isTrue);
        expect(tappedInterest, TravelInterest.food);
        expect(selectedState, isTrue);
      });

      testWidgets('does not call onToggle when disabled', (tester) async {
        var callbackCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TravelInterestChip(
                interest: TravelInterest.food,
                isSelected: false,
                enabled: false,
                onToggle: (interest, selected) {
                  callbackCalled = true;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FilterChip));
        await tester.pumpAndSettle();

        expect(callbackCalled, isFalse);
      });

      testWidgets('shows custom icon when provided', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TravelInterestChip(
                interest: TravelInterest.food,
                isSelected: true,
                customIcon: Icons.restaurant,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.restaurant), findsOneWidget);
      });

      testWidgets(
          'uses filled style when filledWhenSelected is true and selected',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TravelInterestChip(
                interest: TravelInterest.food,
                isSelected: true,
                filledWhenSelected: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final filterChip = tester.widget<FilterChip>(
          find.byType(FilterChip),
        );
        expect(filterChip.elevation, 2); // Selected chips have elevation
      });

      testWidgets('respects custom visual density', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TravelInterestChip(
                interest: TravelInterest.food,
                isSelected: false,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final filterChip = tester.widget<FilterChip>(
          find.byType(FilterChip),
        );
        expect(filterChip.visualDensity, VisualDensity.compact);
      });

      testWidgets('renders all 10 travel interests correctly', (tester) async {
        for (final interest in TravelInterest.values) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: TravelInterestChip(
                  interest: interest,
                  isSelected: false,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text(interest.label), findsOneWidget);
          // Emoji appears twice (in label and avatar)
          expect(find.text(interest.emoji), findsNWidgets(2));

          // Clean up for next iteration
          await tester.pumpWidget(Container());
        }
      });
    });

    group('TravelInterestChipCompact', () {
      testWidgets('renders with emoji and label', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TravelInterestChipCompact(
                interest: TravelInterest.food,
                isSelected: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Compact chip only shows emoji once
        expect(find.text('🍽️'), findsOneWidget);
        expect(find.text('Food & Cuisine'), findsOneWidget);
      });

      testWidgets('shows selected state with background color', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TravelInterestChipCompact(
                interest: TravelInterest.food,
                isSelected: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(TravelInterestChipCompact),
                matching: find.byType(Container),
              )
              .first,
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, isNotNull);
        expect(decoration.borderRadius, isNotNull);
      });

      testWidgets('calls onToggle callback when tapped', (tester) async {
        var callbackCalled = false;
        TravelInterest? tappedInterest;
        bool? selectedState;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TravelInterestChipCompact(
                interest: TravelInterest.culture,
                isSelected: false,
                onToggle: (interest, selected) {
                  callbackCalled = true;
                  tappedInterest = interest;
                  selectedState = selected;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(GestureDetector));
        await tester.pumpAndSettle();

        expect(callbackCalled, isTrue);
        expect(tappedInterest, TravelInterest.culture);
        expect(selectedState, isTrue);
      });

      testWidgets('does not call onToggle when disabled', (tester) async {
        var callbackCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TravelInterestChipCompact(
                interest: TravelInterest.food,
                isSelected: false,
                enabled: false,
                onToggle: (interest, selected) {
                  callbackCalled = true;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(GestureDetector));
        await tester.pumpAndSettle();

        expect(callbackCalled, isFalse);
      });

      testWidgets('hides emoji when showEmoji is false', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TravelInterestChipCompact(
                interest: TravelInterest.food,
                isSelected: false,
                showEmoji: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('🍽️'), findsNothing);
        expect(find.text('Food & Cuisine'), findsOneWidget);
      });

      testWidgets('has smaller dimensions than regular chip', (tester) async {
        // Regular chip
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TravelInterestChip(
                interest: TravelInterest.food,
                isSelected: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final regularChipSize = tester.getSize(find.byType(TravelInterestChip));

        // Compact chip
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TravelInterestChipCompact(
                interest: TravelInterest.food,
                isSelected: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final compactChipSize =
            tester.getSize(find.byType(TravelInterestChipCompact));

        // Compact chip should be smaller
        expect(compactChipSize.height, lessThan(regularChipSize.height));
      });
    });

    group('TravelInterestGrid', () {
      testWidgets('renders all available interests', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                child: TravelInterestGrid(
                  availableInterests: TravelInterest.values.toSet(),
                  selectedInterests: const {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(TravelInterestChip), findsNWidgets(10));
      });

      testWidgets('marks selected interests', (tester) async {
        final selectedInterests = {TravelInterest.food, TravelInterest.culture};

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                child: TravelInterestGrid(
                  availableInterests: TravelInterest.values.toSet(),
                  selectedInterests: selectedInterests,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final chips = find.byType(FilterChip);
        expect(chips, findsWidgets);

        int selectedCount = 0;
        for (int i = 0; i < 10; i++) {
          final chip = tester.widget<FilterChip>(chips.at(i));
          if (chip.selected) selectedCount++;
        }

        expect(selectedCount, 2);
      });

      testWidgets('calls onToggle when chip is tapped', (tester) async {
        var callbackCalled = false;
        TravelInterest? tappedInterest;
        bool? selectedState;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                child: TravelInterestGrid(
                  availableInterests: TravelInterest.values.toSet(),
                  selectedInterests: const {},
                  onToggle: (interest, selected) {
                    callbackCalled = true;
                    tappedInterest = interest;
                    selectedState = selected;
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FilterChip).first);
        await tester.pumpAndSettle();

        expect(callbackCalled, isTrue);
        expect(tappedInterest, isNotNull);
        expect(selectedState, isTrue);
      });

      testWidgets('uses 2 columns by default', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                child: TravelInterestGrid(
                  availableInterests: TravelInterest.values.toSet(),
                  selectedInterests: const {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final gridView = tester.widget<GridView>(find.byType(GridView));
        final delegate =
            gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

        expect(delegate.crossAxisCount, 2);
      });

      testWidgets('respects custom crossAxisCount', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                child: TravelInterestGrid(
                  availableInterests: TravelInterest.values.toSet(),
                  selectedInterests: const {},
                  crossAxisCount: 3,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final gridView = tester.widget<GridView>(find.byType(GridView));
        final delegate =
            gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

        expect(delegate.crossAxisCount, 3);
      });

      testWidgets('uses compact chips when useCompactChips is true',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                child: TravelInterestGrid(
                  availableInterests: TravelInterest.values.toSet(),
                  selectedInterests: const {},
                  useCompactChips: true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(TravelInterestChipCompact), findsNWidgets(10));
        expect(find.byType(TravelInterestChip), findsNothing);
      });

      testWidgets('uses regular chips when useCompactChips is false',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                child: TravelInterestGrid(
                  availableInterests: TravelInterest.values.toSet(),
                  selectedInterests: const {},
                  useCompactChips: false,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(TravelInterestChip), findsNWidgets(10));
        expect(find.byType(TravelInterestChipCompact), findsNothing);
      });

      testWidgets('disables all chips when enabled is false', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                child: TravelInterestGrid(
                  availableInterests: TravelInterest.values.toSet(),
                  selectedInterests: const {},
                  enabled: false,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final chips = find.byType(FilterChip);
        expect(chips, findsWidgets);

        for (int i = 0; i < 10; i++) {
          final chip = tester.widget<FilterChip>(chips.at(i));
          expect(chip.onSelected, isNull);
        }
      });

      testWidgets('respects custom spacing', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                child: TravelInterestGrid(
                  availableInterests: TravelInterest.values.toSet(),
                  selectedInterests: const {},
                  spacing: 16,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final gridView = tester.widget<GridView>(find.byType(GridView));
        final delegate =
            gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

        expect(delegate.crossAxisSpacing, 16);
        expect(delegate.mainAxisSpacing, 16);
      });

      testWidgets('renders subset of interests when not all available',
          (tester) async {
        final subset = {
          TravelInterest.food,
          TravelInterest.culture,
          TravelInterest.art
        };

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                child: TravelInterestGrid(
                  availableInterests: subset,
                  selectedInterests: const {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(TravelInterestChip), findsNWidgets(3));
      });
    });

    group('Visual Styling and Accessibility', () {
      testWidgets('chip has proper border radius', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TravelInterestChip(
                interest: TravelInterest.food,
                isSelected: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final filterChip = tester.widget<FilterChip>(find.byType(FilterChip));
        expect(filterChip.shape, isA<RoundedRectangleBorder>());
      });

      testWidgets('selected chip has different border color', (tester) async {
        // Unselected
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TravelInterestChip(
                interest: TravelInterest.food,
                isSelected: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final unselectedChip =
            tester.widget<FilterChip>(find.byType(FilterChip));
        final unselectedBorder =
            (unselectedChip.shape as RoundedRectangleBorder).side;
        final unselectedColor = unselectedBorder.color;

        // Selected
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TravelInterestChip(
                interest: TravelInterest.food,
                isSelected: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final selectedChip = tester.widget<FilterChip>(find.byType(FilterChip));
        final selectedBorder =
            (selectedChip.shape as RoundedRectangleBorder).side;
        final selectedColor = selectedBorder.color;

        // Border colors should be different for selected vs unselected
        expect(selectedColor, isNotNull);
        expect(unselectedBorder.color, isNotNull);
        // Selected chip has a more prominent border color (primary color)
        expect(
          (selectedColor.a * 255.0).round().clamp(0, 255),
          greaterThan((unselectedBorder.color.a * 255.0).round().clamp(0, 255)),
        );
      });

      testWidgets('chip has proper semantic label', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TravelInterestChip(
                interest: TravelInterest.food,
                isSelected: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Food & Cuisine'), findsOneWidget);
      });
    });

    group('Animation and Transitions', () {
      testWidgets('compact chip animates on selection change', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TravelInterestChipCompact(
                interest: TravelInterest.food,
                isSelected: false,
              ),
            ),
          ),
        );
        await tester.pump();

        final containerBefore = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(TravelInterestChipCompact),
                matching: find.byType(Container),
              )
              .first,
        );

        // Change to selected
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TravelInterestChipCompact(
                interest: TravelInterest.food,
                isSelected: true,
              ),
            ),
          ),
        );

        // Pump for animation duration
        await tester.pump(const Duration(milliseconds: 50));

        final containerAfter = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(TravelInterestChipCompact),
                matching: find.byType(Container),
              )
              .first,
        );

        final decorationBefore = containerBefore.decoration as BoxDecoration;
        final decorationAfter = containerAfter.decoration as BoxDecoration;

        expect(decorationAfter.color, isNot(equals(decorationBefore.color)));
      });
    });
  });
}
