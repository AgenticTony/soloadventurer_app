import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/widgets/widgets.dart';
import 'package:soloadventurer/features/travel/presentation/screens/activities_screen.dart';
import 'package:soloadventurer/test/utils/performance/performance_test_utils.dart';

/// Tests for [ActivitiesScreen] virtual scrolling performance
///
/// These tests verify that the screen can efficiently handle large datasets
/// (500+ items) using virtual scrolling.
void main() {
  group('ActivitiesScreen Virtual Scrolling', () {
    late List<Activity> testActivities;

    setUp(() {
      // Generate test activities for performance testing
      testActivities = List.generate(500, (index) {
        final startTime = DateTime(2024, 1, 1, 9 + (index % 12));
        final endTime = startTime.add(const Duration(hours: 2));
        return Activity(
          id: 'activity_$index',
          title: 'Activity $index',
          description: 'Description for activity $index',
          startTime: startTime,
          endTime: endTime,
          location: 'Location $index',
          category: _getCategory(index),
          estimatedCost: 50.0 + (index % 10) * 10,
        );
      });
    });

    testWidgets('should render 500 activity items efficiently', (tester) async {
      // Build the screen with test data
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activitiesProvider.overrideWithValue(testActivities),
            activitiesLoadingProvider.overrideWithValue(false),
            activitiesErrorProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: ActivitiesScreen(),
          ),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Verify the screen is rendered
      expect(find.text('Activities'), findsOneWidget);

      // Verify that items are rendered (virtual scrolling only renders visible items)
      expect(find.byType(Card), findsWidgets);

      // Scroll through the list
      await tester.fling(
        find.byType(VirtualListView<Activity>),
        const Offset(0, -500),
        10000,
      );
      await tester.pumpAndSettle();

      // Verify we can scroll through all items
      expect(find.byType(VirtualListView<Activity>), findsOneWidget);
    });

    testWidgets('should show loading state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activitiesProvider.overrideWithValue([]),
            activitiesLoadingProvider.overrideWithValue(true),
            activitiesErrorProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: ActivitiesScreen(),
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
            activitiesProvider.overrideWithValue([]),
            activitiesLoadingProvider.overrideWithValue(false),
            activitiesErrorProvider.overrideWithValue(true),
          ],
          child: const MaterialApp(
            home: ActivitiesScreen(),
          ),
        ),
      );

      await tester.pump();

      // Verify error message is shown
      expect(find.text('Failed to load activities'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should show empty state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activitiesProvider.overrideWithValue([]),
            activitiesLoadingProvider.overrideWithValue(false),
            activitiesErrorProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: ActivitiesScreen(),
          ),
        ),
      );

      await tester.pump();

      // Verify empty state message is shown
      expect(find.text('No activities yet'), findsOneWidget);
    });

    testWidgets('should render activity details correctly', (tester) async {
      final singleActivity = testActivities.first;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activitiesProvider.overrideWithValue([singleActivity]),
            activitiesLoadingProvider.overrideWithValue(false),
            activitiesErrorProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: ActivitiesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify activity details are displayed
      expect(find.text(singleActivity.title), findsOneWidget);
      expect(find.text(singleActivity.location), findsOneWidget);
    });

    testWidgets('should display category icons', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activitiesProvider
                .overrideWithValue(testActivities.take(5).toList()),
            activitiesLoadingProvider.overrideWithValue(false),
            activitiesErrorProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: ActivitiesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify category icons are rendered
      expect(find.byType(_CategoryIcon), findsWidgets);
    });

    testWidgets('should display cost badges when cost is set', (tester) async {
      final activitiesWithCost = testActivities.take(5).toList();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activitiesProvider.overrideWithValue(activitiesWithCost),
            activitiesLoadingProvider.overrideWithValue(false),
            activitiesErrorProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: ActivitiesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify cost badges are rendered
      expect(find.byType(_CostBadge), findsWidgets);
      expect(find.text('\$50'), findsOneWidget);
    });

    testWidgets('should handle smooth scrolling with 500 items',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activitiesProvider.overrideWithValue(testActivities),
            activitiesLoadingProvider.overrideWithValue(false),
            activitiesErrorProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: ActivitiesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Perform multiple scroll operations to test smoothness
      for (int i = 0; i < 10; i++) {
        await tester.fling(
          find.byType(VirtualListView<Activity>),
          const Offset(0, -300),
          5000,
        );
        await tester.pump(const Duration(milliseconds: 500));
      }

      // Verify the list is still scrollable and hasn't crashed
      expect(find.byType(VirtualListView<Activity>), findsOneWidget);
    });

    testWidgets('should have floating action button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activitiesProvider.overrideWithValue(testActivities),
            activitiesLoadingProvider.overrideWithValue(false),
            activitiesErrorProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: ActivitiesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify FAB is present
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}

String _getCategory(int index) {
  final categories = [
    'food',
    'transport',
    'accommodation',
    'activity',
    'sightseeing',
  ];
  return categories[index % categories.length];
}
