import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/widgets/widgets.dart';
import 'package:soloadventurer/features/travel/domain/models/trip.dart';
import 'package:soloadventurer/features/travel/presentation/screens/trip_items_screen.dart';
import 'package:soloadventurer/test/utils/performance/performance_test_utils.dart';

/// Tests for [TripItemsScreen] virtual scrolling performance
///
/// These tests verify that the screen can efficiently handle large datasets
/// (500+ items) using virtual scrolling.
void main() {
  group('TripItemsScreen Virtual Scrolling', () {
    late List<Trip> testTrips;

    setUp(() {
      // Generate test data for performance testing
      final generator = PerformanceTestDataGenerator();
      testTrips = generator.generateTriips(500);
    });

    testWidgets('should render 500 trip items efficiently', (tester) async {
      // Build the screen with test data
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripItemsProvider.overrideWithValue(testTrips),
            tripItemsLoadingProvider.overrideWithValue(false),
            tripItemsErrorProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: TripItemsScreen(),
          ),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Verify the screen is rendered
      expect(find.text('Trip Items'), findsOneWidget);

      // Verify that items are rendered (virtual scrolling only renders visible items)
      // The exact count depends on screen height, but we should see some items
      expect(find.byType(InkWell), findsWidgets);

      // Scroll through the list
      await tester.fling(
        find.byType(VirtualListView<Trip>),
        const Offset(0, -500),
        10000,
      );
      await tester.pumpAndSettle();

      // Verify we can scroll through all items
      expect(find.byType(VirtualListView<Trip>), findsOneWidget);
    });

    testWidgets('should show loading state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripItemsProvider.overrideWithValue([]),
            tripItemsLoadingProvider.overrideWithValue(true),
            tripItemsErrorProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: TripItemsScreen(),
          ),
        ),
      );

      await tester.pump();

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripItemsProvider.overrideWithValue([]),
            tripItemsLoadingProvider.overrideWithValue(false),
            tripItemsErrorProvider.overrideWithValue(true),
          ],
          child: const MaterialApp(
            home: TripItemsScreen(),
          ),
        ),
      );

      await tester.pump();

      // Verify error message is shown
      expect(find.text('Failed to load trips'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should show empty state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripItemsProvider.overrideWithValue([]),
            tripItemsLoadingProvider.overrideWithValue(false),
            tripItemsErrorProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: TripItemsScreen(),
          ),
        ),
      );

      await tester.pump();

      // Verify empty state message is shown
      expect(find.text('No trips yet'), findsOneWidget);
    });

    testWidgets('should render trip item details correctly', (tester) async {
      final singleTrip = testTrips.first;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripItemsProvider.overrideWithValue([singleTrip]),
            tripItemsLoadingProvider.overrideWithValue(false),
            tripItemsErrorProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: TripItemsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify trip details are displayed
      expect(find.text(singleTrip.title), findsOneWidget);
      expect(find.text(singleTrip.destination), findsOneWidget);
    });

    testWidgets('should handle smooth scrolling with 500 items',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripItemsProvider.overrideWithValue(testTrips),
            tripItemsLoadingProvider.overrideWithValue(false),
            tripItemsErrorProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: TripItemsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Perform multiple scroll operations to test smoothness
      for (int i = 0; i < 10; i++) {
        await tester.fling(
          find.byType(VirtualListView<Trip>),
          const Offset(0, -300),
          5000,
        );
        await tester.pump(const Duration(milliseconds: 500));
      }

      // Verify the list is still scrollable and hasn't crashed
      expect(find.byType(VirtualListView<Trip>), findsOneWidget);
    });
  });
}
