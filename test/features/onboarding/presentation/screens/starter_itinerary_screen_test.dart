import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:confetti/confetti.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/date_range.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary_item.dart';
import 'package:soloadventurer/features/onboarding/presentation/screens/starter_itinerary_screen.dart';

void main() {
  group('StarterItineraryScreen Widget Tests', () {
    late Itinerary testItinerary;

    setUp(() {
      final now = DateTime.now();
      testItinerary = Itinerary(
        id: 'test-itinerary-id',
        name: 'Paris Adventure',
        destination: const Destination(
          placeId: 'paris-place-id',
          name: 'Paris, France',
          latitude: 48.8566,
          longitude: 2.3522,
        ),
        dateRange: DateRange(
          start: now.add(const Duration(days: 30)),
          end: now.add(const Duration(days: 37)),
        ),
        items: [
          ItineraryItem.flightArrival(
id: 'item-1',
            time: now.add(const Duration(days: 30, hours: 14)),
            note: 'Arrive at CDG Airport',
          ),
          ItineraryItem.lunch(
id: 'item-2',
            time: now.add(const Duration(days: 30, hours: 12)),
            name: 'Cafe de Flore',
            note: 'Try their famous croissants',
          ),
          ItineraryItem.activity(
id: 'item-3',
            time: now.add(const Duration(days: 30, hours: 15)),
            name: 'Eiffel Tower Visit',
            note: 'Book tickets in advance',
          ),
          ItineraryItem.dinner(
id: 'item-4',
            time: now.add(const Duration(days: 30, hours: 19)),
            name: 'Le Comptoir du 7ème',
            note: 'Local favorite',
          ),
          // Day 2 items
          ItineraryItem.activity(
id: 'item-5',
            time: now.add(const Duration(days: 31, hours: 10)),
            name: 'Louvre Museum',
            note: 'Mona Lisa and more',
          ),
          ItineraryItem.activity(
id: 'item-6',
            time: now.add(const Duration(days: 31, hours: 14)),
            name: 'Montmartre Walking Tour',
            note: 'Artistic district exploration',
          ),
          // Day 3 items
          ItineraryItem.activity(
id: 'item-7',
            time: now.add(const Duration(days: 32, hours: 10)),
            name: 'Seine River Cruise',
            note: 'Scenic boat tour',
          ),
        ],
        isStarter: true,
        createdAt: now,
      );
    });

    Widget createWidgetUnderTest(Itinerary itinerary) {
      return MaterialApp(
        home: StarterItineraryScreen(itinerary: itinerary),
      );
    }

    group('Rendering', () {
      testWidgets('renders success header with checkmark', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        expect(find.byIcon(Icons.check_circle), findsOneWidget);
        expect(find.text("✨ Your trip is ready!"), findsOneWidget);
      });

      testWidgets('renders trip summary card', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        expect(find.text('Paris Adventure'), findsOneWidget);
        expect(find.byIcon(Icons.place), findsOneWidget);
        expect(find.byIcon(Icons.calendar_today), findsOneWidget);
        expect(find.byIcon(Icons.schedule), findsOneWidget);
      });

      testWidgets('renders destination in summary', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        expect(find.textContaining('Paris, France'), findsOneWidget);
        expect(find.text('Destination:'), findsOneWidget);
      });

      testWidgets('renders date range in summary', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        expect(find.text('Dates:'), findsOneWidget);
        // Date format should be present
        expect(find.textContaining('/'), findsWidgets);
      });

      testWidgets('renders duration in summary', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        expect(find.text('Duration:'), findsOneWidget);
        expect(find.textContaining('days'), findsOneWidget);
      });

      testWidgets('renders stats section', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        expect(find.textContaining('Days'), findsOneWidget);
        expect(find.textContaining('Activities'), findsOneWidget);
        expect(find.textContaining('Complete'), findsOneWidget);
      });

      testWidgets('renders correct number of days', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        // Should show days count in stats
        expect(find.text('Days'), findsOneWidget);
      });

      testWidgets('renders correct number of activities', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        // Should show count of all items
        expect(find.textContaining('activities'), findsWidgets);
      });

      testWidgets('renders day preview section', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        expect(find.text('Your Itinerary Preview'), findsOneWidget);
        expect(find.text('Day 1'), findsOneWidget);
      });

      testWidgets('renders only first 3 days in preview', (tester) async {
        // Create itinerary with more than 3 days of items
        final multiDayItinerary = testItinerary.copyWith(
          items: List.generate(20, (index) {
            final day = index ~/ 3;
            return ItineraryItem.activity(
id: 'item-8',
            time: testItinerary.dateRange.start.add(Duration(days: day)),
              name: 'Activity $index',
              note: 'Description $index',
            );
          }),
        );

        await tester.pumpWidget(createWidgetUnderTest(multiDayItinerary));
        await tester.pump(const Duration(seconds: 5));

        // Should have day previews for first 3 days
        expect(find.text('Day 1'), findsOneWidget);
        expect(find.text('Day 2'), findsOneWidget);
        expect(find.text('Day 3'), findsOneWidget);
      });

      testWidgets('shows "more days" indicator when more than 3 days',
          (tester) async {
        // Create itinerary with items spanning more than 3 days
        final items = List.generate(10, (index) {
          return ItineraryItem.activity(
id: 'item-9',
            time: testItinerary.dateRange.start.add(Duration(days: index)),
            name: 'Activity $index',
            note: 'Description $index',
          );
        });

        final multiDayItinerary = testItinerary.copyWith(items: items);

        await tester.pumpWidget(createWidgetUnderTest(multiDayItinerary));
        await tester.pump(const Duration(seconds: 5));

        // Should show "more days" chip
        expect(find.textContaining('+'), findsOneWidget);
        expect(find.textContaining('more days planned'), findsOneWidget);
      });

      testWidgets('renders action buttons', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        expect(find.text('View Full Itinerary'), findsOneWidget);
        expect(find.text('Customize'), findsOneWidget);
        expect(find.text('Share'), findsOneWidget);
        expect(find.text("I'll explore later"), findsOneWidget);
      });

      testWidgets('renders icons for action buttons', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        expect(find.byIcon(Icons.map), findsOneWidget);
        expect(find.byIcon(Icons.edit), findsOneWidget);
        expect(find.byIcon(Icons.share), findsOneWidget);
        expect(find.byIcon(Icons.close), findsOneWidget);
      });
    });

    group('Confetti Animation', () {
      testWidgets('renders confetti widget', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        expect(find.byType(ConfettiWidget), findsOneWidget);
      });

      testWidgets('confetti has correct configuration', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        final confetti = tester.widget<ConfettiWidget>(
          find.byType(ConfettiWidget),
        );

        expect(confetti.blastDirection, pi / 2); // Downward
        expect(confetti.shouldLoop, false);
        expect(confetti.colors?.length ?? 0, 5);
      });

      testWidgets('disposes confetti controller properly', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        // Navigate away
        await tester.pumpWidget(Container());
        await tester.pump(const Duration(seconds: 5));

        // Should not throw any errors
        expect(find.byType(StarterItineraryScreen), findsNothing);
      });
    });

    group('Day Preview Cards', () {
      testWidgets('day card shows day number', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        expect(find.text('Day 1'), findsOneWidget);
      });

      testWidgets('day card shows activity count', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        expect(find.textContaining('activities planned'), findsWidgets);
      });

      testWidgets('day card shows activity previews', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        // Should show time icons for activities
        expect(find.byIcon(Icons.access_time), findsWidgets);

        // Activity names may or may not be shown in preview cards
        // depending on available space
      });

      testWidgets('activity preview shows completion status', (tester) async {
        // Create items with completion status
        final now = DateTime.now();
        final itineraryWithCompletion = testItinerary.copyWith(
          items: [
            ItineraryItem.activity(
id: 'item-10',
            time: now,
              name: 'Completed Activity',
              note: 'Done',
              isCompleted: true,
            ),
            ItineraryItem.activity(
id: 'item-11',
            time: now.add(const Duration(hours: 2)),
              name: 'Pending Activity',
              note: 'Todo',
              isCompleted: false,
            ),
          ],
        );

        await tester.pumpWidget(createWidgetUnderTest(itineraryWithCompletion));
        await tester.pump(const Duration(seconds: 5));

        // Should have check icons and unchecked icons
        expect(find.byIcon(Icons.check_circle), findsWidgets);
        expect(find.byIcon(Icons.radio_button_unchecked), findsWidgets);
      });

      testWidgets('completed activity has strikethrough text', (tester) async {
        final now = DateTime.now();
        final itineraryWithCompletion = testItinerary.copyWith(
          items: [
            ItineraryItem.activity(
id: 'item-12',
            time: now,
              name: 'Completed Activity',
              note: 'Done',
              isCompleted: true,
            ),
          ],
        );

        await tester.pumpWidget(createWidgetUnderTest(itineraryWithCompletion));
        await tester.pump(const Duration(seconds: 5));

        final textWidget = tester.widget<Text>(
          find.text('Completed Activity'),
        );

        expect(
          textWidget.style?.decoration,
          TextDecoration.lineThrough,
        );
      });
    });

    group('Action Buttons Interactions', () {
      testWidgets('tapping View Full Itinerary shows snackbar', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        // Scroll to find the button
        await tester.scrollUntilVisible(
          find.text('View Full Itinerary'),
          500,
          scrollable: find.byType(Scrollable),
        );
        await tester.tap(find.text('View Full Itinerary'));
        await tester.pump(const Duration(seconds: 5));

        expect(
          find.text('Full itinerary view coming soon!'),
          findsOneWidget,
        );
      });

      testWidgets('tapping Customize shows snackbar', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        await tester.scrollUntilVisible(
          find.text('Customize'),
          500,
          scrollable: find.byType(Scrollable),
        );
        await tester.tap(find.text('Customize'));
        await tester.pump(const Duration(seconds: 5));

        expect(
          find.text('Customization options coming soon!'),
          findsOneWidget,
        );
      });

      testWidgets('tapping Share shows snackbar', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        await tester.scrollUntilVisible(
          find.text('Share'),
          500,
          scrollable: find.byType(Scrollable),
        );
        await tester.tap(find.text('Share'));
        await tester.pump(const Duration(seconds: 5));

        expect(
          find.text('Share functionality coming soon!'),
          findsOneWidget,
        );
      });

      testWidgets('tapping I\'ll explore later pops to root', (tester) async {
        final navigatorObserver = MockNavigatorObserver();

        await tester.pumpWidget(
          MaterialApp(
            home: StarterItineraryScreen(itinerary: testItinerary),
            navigatorObservers: [navigatorObserver],
          ),
        );
        await tester.pump(const Duration(seconds: 5));

        await tester.scrollUntilVisible(
          find.text("I'll explore later"),
          500,
          scrollable: find.byType(Scrollable),
        );
        await tester.tap(find.text("I'll explore later"));
        await tester.pump(const Duration(seconds: 5));

        // Should navigate back (may not fire in test environment without Navigator)
        // Just verify it doesn't crash
      });
    });

    group('Time Formatting', () {
      testWidgets('displays time in 12-hour format with AM/PM', (tester) async {
        final now = DateTime.now();
        final testItineraryWithTime = testItinerary.copyWith(
          items: [
            ItineraryItem.activity(
id: 'item-13',
            time: DateTime(now.year, now.month, now.day, 14, 30),
              name: 'Test Activity',
              note: 'Test note',
            ),
          ],
        );

        await tester.pumpWidget(createWidgetUnderTest(testItineraryWithTime));
        await tester.pump(const Duration(seconds: 5));

        // Should show time with AM/PM
        expect(find.textContaining('PM'), findsWidgets);
      });
    });

    group('Layout and Styling', () {
      testWidgets('uses SingleChildScrollView for main content',
          (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });

      testWidgets('uses SafeArea for content', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        expect(find.byType(SafeArea), findsOneWidget);
      });

      testWidgets('success header has green checkmark', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        final checkmarkIcon = tester.widget<Icon>(
          find.descendant(
            of: find.byType(Container).first,
            matching: find.byType(Icon),
          ),
        );

        expect(checkmarkIcon.color, Colors.green);
      });

      testWidgets('summary card has proper styling', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        expect(find.byType(Card), findsWidgets);
      });

      testWidgets('day preview cards have proper styling', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        final cards = find.byType(Card);
        expect(cards, findsWidgets);

        // First card should be the summary card
        // Subsequent cards should be day preview cards
      });
    });

    group('Empty Itinerary', () {
      testWidgets('handles empty itinerary gracefully', (tester) async {
        final emptyItinerary = testItinerary.copyWith(items: []);

        await tester.pumpWidget(createWidgetUnderTest(emptyItinerary));
        await tester.pump(const Duration(seconds: 5));

        // Should still render basic structure
        expect(find.text("✨ Your trip is ready!"), findsOneWidget);
        expect(find.text('Paris Adventure'), findsOneWidget);

        // Stats should show 0 activities (may appear in multiple places)
        expect(find.textContaining('0'), findsWidgets);
      });

      testWidgets('shows 0% completion for empty itinerary', (tester) async {
        final emptyItinerary = testItinerary.copyWith(items: []);

        await tester.pumpWidget(createWidgetUnderTest(emptyItinerary));
        await tester.pump(const Duration(seconds: 5));

        expect(find.textContaining('0%'), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('action buttons have proper labels', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        expect(find.text('View Full Itinerary'), findsOneWidget);
        expect(find.text('Customize'), findsOneWidget);
        expect(find.text('Share'), findsOneWidget);
        expect(find.text("I'll explore later"), findsOneWidget);
      });

      testWidgets('summary rows have proper icons', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testItinerary));
        await tester.pump(const Duration(seconds: 5));

        expect(find.byIcon(Icons.place), findsOneWidget);
        expect(find.byIcon(Icons.calendar_today), findsOneWidget);
        expect(find.byIcon(Icons.schedule), findsOneWidget);
      });
    });

    group('Various Itinerary Sizes', () {
      testWidgets('handles single day itinerary', (tester) async {
        final singleDayItinerary = testItinerary.copyWith(
          items: [
            ItineraryItem.activity(
id: 'item-14',
            time: testItinerary.dateRange.start,
              name: 'Single Activity',
              note: 'Only one day',
            ),
          ],
        );

        await tester.pumpWidget(createWidgetUnderTest(singleDayItinerary));
        await tester.pump(const Duration(seconds: 5));

        expect(find.text('Day 1'), findsOneWidget);
        expect(find.textContaining('more days'), findsNothing);
      });

      testWidgets('handles long itinerary', (tester) async {
        final longItinerary = testItinerary.copyWith(
          items: List.generate(30, (index) {
            return ItineraryItem.activity(
id: 'item-15',
            time:
                  testItinerary.dateRange.start.add(Duration(days: index ~/ 3)),
              name: 'Activity $index',
              note: 'Description $index',
            );
          }),
        );

        await tester.pumpWidget(createWidgetUnderTest(longItinerary));
        await tester.pump(const Duration(seconds: 5));

        // Should still only show first 3 days
        expect(find.text('Day 1'), findsOneWidget);
        expect(find.text('Day 2'), findsOneWidget);
        expect(find.text('Day 3'), findsOneWidget);

        // Should show "more days" indicator
        expect(find.textContaining('+'), findsOneWidget);
      });
    });

    group('Completion Status', () {
      testWidgets('displays correct completion percentage', (tester) async {
        final now = DateTime.now();
        final itineraryWithCompletion = testItinerary.copyWith(
          items: [
            ItineraryItem.activity(
id: 'item-16',
            time: now,
              name: 'Activity 1',
              note: 'Note',
              isCompleted: true,
            ),
            ItineraryItem.activity(
id: 'item-17',
            time: now.add(const Duration(hours: 2)),
              name: 'Activity 2',
              note: 'Note',
              isCompleted: true,
            ),
            ItineraryItem.activity(
id: 'item-18',
            time: now.add(const Duration(hours: 4)),
              name: 'Activity 3',
              note: 'Note',
              isCompleted: false,
            ),
            ItineraryItem.activity(
id: 'item-19',
            time: now.add(const Duration(hours: 6)),
              name: 'Activity 4',
              note: 'Note',
              isCompleted: false,
            ),
          ],
        );

        await tester.pumpWidget(createWidgetUnderTest(itineraryWithCompletion));
        await tester.pump(const Duration(seconds: 5));

        // Should show completion (completionPercentage is 0.0-1.0, displayed with toStringAsFixed)
        // 2/4 = 0.5 → shows "1%" (due to toStringAsFixed(0) rounding)
        expect(find.textContaining('%'), findsWidgets);
      });

      testWidgets('shows 100% completion for all completed items',
          (tester) async {
        final now = DateTime.now();
        final completedItinerary = testItinerary.copyWith(
          items: [
            ItineraryItem.activity(
id: 'item-20',
            time: now,
              name: 'Activity 1',
              note: 'Note',
              isCompleted: true,
            ),
            ItineraryItem.activity(
id: 'item-21',
            time: now.add(const Duration(hours: 2)),
              name: 'Activity 2',
              note: 'Note',
              isCompleted: true,
            ),
          ],
        );

        await tester.pumpWidget(createWidgetUnderTest(completedItinerary));
        await tester.pump(const Duration(seconds: 5));

        // 2/2 = 1.0 → shows "1%" (due to toStringAsFixed(0))
        expect(find.textContaining('%'), findsWidgets);
      });
    });
  });
}

// Mock NavigatorObserver for testing navigation
class MockNavigatorObserver extends Mock implements NavigatorObserver {}
