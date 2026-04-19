import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/travel/presentation/screens/activities_screen.dart';

/// Tests for [ActivitiesScreen] widget rendering and interactions
void main() {
  group('ActivitiesScreen', () {
    Future<void> pumpActivitiesScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ActivitiesScreen(),
        ),
      );
      // Flush the Future.delayed(500ms) from _fetchActivities
      await tester.pump(const Duration(seconds: 1));
    }

    testWidgets('renders app bar with title', (tester) async {
      await pumpActivitiesScreen(tester);

      expect(find.text('Activities'), findsOneWidget);
    });

    testWidgets('renders filter button', (tester) async {
      await pumpActivitiesScreen(tester);

      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('renders floating action button', (tester) async {
      await pumpActivitiesScreen(tester);

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('tapping filter button does not crash', (tester) async {
      await pumpActivitiesScreen(tester);

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pump();

      expect(find.byType(ActivitiesScreen), findsOneWidget);
    });

    testWidgets('tapping FAB does not crash', (tester) async {
      await pumpActivitiesScreen(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(find.byType(ActivitiesScreen), findsOneWidget);
    });

    testWidgets('renders screen widget', (tester) async {
      await pumpActivitiesScreen(tester);

      expect(find.byType(ActivitiesScreen), findsOneWidget);
    });
  });

  group('Activity model', () {
    test('creates activity with required fields', () {
      final activity = Activity(
        id: 'activity_1',
        title: 'Visit Museum',
        startTime: DateTime(2026, 1, 4, 10, 0),
        endTime: DateTime(2026, 1, 4, 12, 0),
        location: 'Paris, France',
        category: 'sightseeing',
      );

      expect(activity.id, 'activity_1');
      expect(activity.title, 'Visit Museum');
      expect(activity.location, 'Paris, France');
      expect(activity.category, 'sightseeing');
    });

    test('creates activity with optional fields', () {
      final activity = Activity(
        id: 'activity_1',
        title: 'Visit Museum',
        description: 'A wonderful museum tour',
        startTime: DateTime(2026, 1, 4, 10, 0),
        endTime: DateTime(2026, 1, 4, 12, 0),
        location: 'Paris, France',
        category: 'sightseeing',
        estimatedCost: 25.0,
      );

      expect(activity.description, 'A wonderful museum tour');
      expect(activity.estimatedCost, 25.0);
    });
  });
}
