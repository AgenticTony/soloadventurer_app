import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination.dart';
import 'package:soloadventurer/features/destination_discovery/presentation/widgets/activity_list.dart';

void main() {
  group('ActivityList', () {
    // Test data
    late List<Activity> testActivities;
    late List<Activity> emptyActivities;

    setUp(() {
      testActivities = [
        Activity(
          id: '1',
          name: 'Hiking',
          description: 'Explore scenic mountain trails',
          category: 'outdoor',
          soloFriendly: true,
          costLevel: 'free',
        ),
        Activity(
          id: '2',
          name: 'Food Tour',
          description: 'Taste local cuisine',
          category: 'food',
          soloFriendly: true,
          costLevel: 'medium',
        ),
        Activity(
          id: '3',
          name: 'Museum Visit',
          description: 'Discover cultural history',
          category: 'cultural',
          soloFriendly: true,
          costLevel: 'low',
          imageUrl: 'https://example.com/museum.jpg',
        ),
      ];

      emptyActivities = [];
    });

    group('Rendering', () {
      testWidgets('renders all activities', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(activities: testActivities),
            ),
          ),
        );

        expect(find.text('Hiking'), findsOneWidget);
        expect(find.text('Food Tour'), findsOneWidget);
        expect(find.text('Museum Visit'), findsOneWidget);
      });

      testWidgets('renders activity descriptions when showDescription is true',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(
                activities: testActivities,
                showDescription: true,
              ),
            ),
          ),
        );

        expect(find.text('Explore scenic mountain trails'), findsOneWidget);
        expect(find.text('Taste local cuisine'), findsOneWidget);
      });

      testWidgets('hides activity descriptions when showDescription is false',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(
                activities: testActivities,
                showDescription: false,
              ),
            ),
          ),
        );

        expect(find.text('Explore scenic mountain trails'), findsNothing);
      });

      testWidgets('renders category badges when showCategory is true',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(
                activities: testActivities,
                showCategory: true,
              ),
            ),
          ),
        );

        expect(find.text('outdoor'), findsOneWidget);
        expect(find.text('food'), findsOneWidget);
        expect(find.text('cultural'), findsOneWidget);
      });

      testWidgets('hides category badges when showCategory is false',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(
                activities: testActivities,
                showCategory: false,
              ),
            ),
          ),
        );

        expect(find.text('outdoor'), findsNothing);
      });

      testWidgets('renders cost level badges when showCostLevel is true',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(
                activities: testActivities,
                showCostLevel: true,
              ),
            ),
          ),
        );

        expect(find.text('Free'), findsOneWidget);
        expect(find.text('\$'), findsOneWidget);
        expect(find.text('\$\$'), findsOneWidget);
      });

      testWidgets('hides cost level badges when showCostLevel is false',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(
                activities: testActivities,
                showCostLevel: false,
              ),
            ),
          ),
        );

        expect(find.text('Free'), findsNothing);
      });

      testWidgets('renders solo-friendly indicator', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(activities: testActivities),
            ),
          ),
        );

        expect(find.byIcon(Icons.person), findsWidgets);
        expect(find.text('Solo Friendly'), findsWidgets);
      });

      testWidgets('renders custom title when provided', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(
                activities: testActivities,
                title: 'Popular Activities',
              ),
            ),
          ),
        );

        expect(find.text('Popular Activities'), findsOneWidget);
      });

      testWidgets('renders activity images when available',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(activities: testActivities),
            ),
          ),
        );

        expect(find.byType(CachedNetworkImage), findsOneWidget);
      });

      testWidgets('uses category icon when no image available',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(activities: testActivities),
            ),
          ),
        );

        // Hiking and Food Tour don't have images, should show category icons
        expect(find.byIcon(Icons.hiking), findsOneWidget);
        expect(find.byIcon(Icons.restaurant), findsOneWidget);
      });
    });

    group('Layouts', () {
      testWidgets('renders list layout by default', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(
                activities: testActivities,
                layout: ActivityListLayout.list,
              ),
            ),
          ),
        );

        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('renders grid layout when specified', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(
                activities: testActivities,
                layout: ActivityListLayout.grid,
              ),
            ),
          ),
        );

        expect(find.byType(GridView), findsOneWidget);
      });

      testWidgets('uses custom grid cross axis count', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(
                activities: testActivities,
                layout: ActivityListLayout.grid,
                gridCrossAxisCount: 3,
              ),
            ),
          ),
        );

        final gridView = tester.widget<GridView>(
          find.byType(GridView),
        );

        // The delegate should be a SliverGridDelegateWithFixedCrossAxisCount
        expect(gridView.gridDelegate, isA<SliverGridDelegateWithFixedCrossAxisCount>());
      });

      testWidgets('renders horizontal layout when specified',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(
                activities: testActivities,
                layout: ActivityListLayout.horizontal,
              ),
            ),
          ),
        );

        final listView = tester.widget<ListView>(
          find.byType(ListView),
        );

        expect(listView.scrollDirection, Axis.horizontal);
      });

      testWidgets('uses custom height for horizontal layout',
          (WidgetTester tester) async {
        const customHeight = 150.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(
                activities: testActivities,
                layout: ActivityListLayout.horizontal,
                horizontalItemHeight: customHeight,
              ),
            ),
          ),
        );

        final sizedBox = tester.widget<SizedBox>(
          find.descendant(
            of: find.byType(ActivityList),
            matching: find.byType(SizedBox).first,
          ),
        );

        expect(sizedBox.height, customHeight);
      });
    });

    group('Interactions', () {
      testWidgets('calls onActivityTap when activity is tapped',
          (WidgetTester tester) async {
        Activity? tappedActivity;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(
                activities: testActivities,
                onActivityTap: (activity) => tappedActivity = activity,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Hiking'));
        expect(tappedActivity?.name, 'Hiking');
      });

      testWidgets('does not call onActivityTap when callback is null',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(activities: testActivities),
            ),
          ),
        );

        // Should not throw
        await tester.tap(find.text('Hiking'));
        await tester.pump();
      });
    });

    group('Empty State', () {
      testWidgets('shows empty state when no activities provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(activities: emptyActivities),
            ),
          ),
        );

        expect(find.text('No activities available'), findsOneWidget);
        expect(find.byIcon(Icons.hiking), findsOneWidget);
      });

      testWidgets('shows custom empty state elements',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(activities: emptyActivities),
            ),
          ),
        );

        expect(find.byType(Column), findsWidgets);
      });
    });

    group('Customization', () {
      testWidgets('uses custom padding', (WidgetTester tester) async {
        const customPadding = EdgeInsets.all(24);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(
                activities: testActivities,
                padding: customPadding,
              ),
            ),
          ),
        );

        final paddingWidget = tester.widget<Padding>(
          find.descendant(
            of: find.byType(ActivityList),
            matching: find.byType(Padding).first,
          ),
        );

        expect(paddingWidget.padding, customPadding);
      });

      testWidgets('uses custom item spacing', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(
                activities: testActivities,
                itemSpacing: 20,
              ),
            ),
          ),
        );

        // Should use custom spacing in list
        expect(find.byType(ListView), findsOneWidget);
      });
    });

    group('Category Icons', () {
      testWidgets('shows correct icon for outdoor activities',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(activities: testActivities),
            ),
          ),
        );

        expect(find.byIcon(Icons.hiking), findsOneWidget);
      });

      testWidgets('shows correct icon for food activities',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(activities: testActivities),
            ),
          ),
        );

        expect(find.byIcon(Icons.restaurant), findsOneWidget);
      });

      testWidgets('shows correct icon for cultural activities',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(activities: testActivities),
            ),
          ),
        );

        expect(find.byIcon(Icons.museum), findsOneWidget);
      });

      testWidgets('shows default icon for unknown categories',
          (WidgetTester tester) async {
        final unknownCategoryActivity = Activity(
          id: '4',
          name: 'Unknown Activity',
          category: 'unknown',
          soloFriendly: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(activities: [unknownCategoryActivity]),
            ),
          ),
        );

        expect(find.byIcon(Icons.event), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('activities have semantic labels', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityList(activities: testActivities),
            ),
          ),
        );

        expect(find.byType(Semantics), findsWidgets);
      });
    });
  });
}
