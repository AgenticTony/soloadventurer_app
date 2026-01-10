import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/curated_list.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination.dart';
import 'package:soloadventurer/features/destination_discovery/presentation/widgets/curated_list_card.dart';

void main() {
  group('CuratedListCard', () {
    // Test data
    late CuratedList testCuratedList;
    late CuratedList hiddenGemsList;
    late CuratedList featuredList;

    setUp(() {
      final now = DateTime.now();
      final testDestination1 = Destination(
        id: '1',
        name: 'Tokyo',
        description: 'Vibrant city',
        latitude: 35.6762,
        longitude: 139.6503,
        countryCode: 'JP',
        safetyScore: 8.5,
        safetyInsights: [],
        soloSuitabilityScore: 9.0,
        soloSuitabilityFactors: const SoloSuitabilityFactors(
          safety: 8.5,
          nightlife: 9.0,
          walkability: 9.5,
          accommodation: 9.0,
          soloDining: 8.5,
          communication: 7.0,
          overall: 9.0,
        ),
        budgetLevel: BudgetLevel.moderate,
        activityLevels: const [],
        tags: const ['urban'],
        images: const ['https://example.com/tokyo.jpg'],
        popularActivities: const [],
        createdAt: now,
        updatedAt: now,
      );

      final testDestination2 = Destination(
        id: '2',
        name: 'Kyoto',
        description: 'Cultural city',
        latitude: 35.0116,
        longitude: 135.7681,
        countryCode: 'JP',
        safetyScore: 9.0,
        safetyInsights: [],
        soloSuitabilityScore: 8.5,
        soloSuitabilityFactors: const SoloSuitabilityFactors(
          safety: 9.0,
          nightlife: 7.0,
          walkability: 8.5,
          accommodation: 8.5,
          soloDining: 8.0,
          communication: 7.5,
          overall: 8.5,
        ),
        budgetLevel: BudgetLevel.moderate,
        activityLevels: const [],
        tags: const ['cultural'],
        images: const ['https://example.com/kyoto.jpg'],
        popularActivities: const [],
        createdAt: now,
        updatedAt: now,
      );

      testCuratedList = CuratedList(
        id: '1',
        name: 'Best of Japan',
        description: 'Explore the top destinations in Japan',
        type: CuratedListType.popularSolo,
        destinations: [testDestination1, testDestination2],
        coverImageUrl: 'https://example.com/japan-cover.jpg',
        images: const [
          'https://example.com/japan1.jpg',
          'https://example.com/japan2.jpg',
        ],
        destinationCount: 2,
        createdAt: now,
        updatedAt: now,
      );

      hiddenGemsList = CuratedList(
        id: '2',
        name: 'Hidden Gems of Asia',
        description: 'Undiscovered treasures',
        type: CuratedListType.hiddenGems,
        destinations: [testDestination1],
        destinationCount: 1,
        createdAt: now,
        updatedAt: now,
      );

      featuredList = CuratedList(
        id: '3',
        name: 'Featured Collection',
        description: 'Editor\'s picks',
        type: CuratedListType.custom,
        destinations: [testDestination1, testDestination2],
        destinationCount: 2,
        isFeatured: true,
        createdAt: now,
        updatedAt: now,
      );
    });

    group('Rendering', () {
      testWidgets('renders list name', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CuratedListCard(curatedList: testCuratedList),
            ),
          ),
        );

        expect(find.text('Best of Japan'), findsOneWidget);
      });

      testWidgets('renders truncated description (max 2 lines)',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CuratedListCard(curatedList: testCuratedList),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(
          find.text('Explore the top destinations in Japan'),
        );
        expect(textWidget.maxLines, 2);
        expect(textWidget.overflow, TextOverflow.ellipsis);
      });

      testWidgets('renders destination count', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CuratedListCard(curatedList: testCuratedList),
            ),
          ),
        );

        expect(find.text('2 Destinations'), findsOneWidget);
      });

      testWidgets('shows destination count icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CuratedListCard(curatedList: testCuratedList),
            ),
          ),
        );

        expect(find.byIcon(Icons.place), findsOneWidget);
      });

      testWidgets('renders type badge for popularSolo',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CuratedListCard(curatedList: testCuratedList),
            ),
          ),
        );

        expect(find.byIcon(Icons.trending_up), findsOneWidget);
      });

      testWidgets('shows hidden gem badge for hiddenGems type',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CuratedListCard(curatedList: hiddenGemsList),
            ),
          ),
        );

        expect(find.text('Hidden Gems'), findsOneWidget);
        expect(find.byIcon(Icons.diamond), findsOneWidget);
      });

      testWidgets('shows featured badge for featured lists',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CuratedListCard(curatedList: featuredList),
            ),
          ),
        );

        expect(find.byIcon(Icons.star), findsOneWidget);
      });

      testWidgets('renders preview destinations', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CuratedListCard(curatedList: testCuratedList),
            ),
          ),
        );

        expect(find.text('Tokyo'), findsOneWidget);
        expect(find.text('Kyoto'), findsOneWidget);
      });

      testWidgets('respects previewCount parameter',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CuratedListCard(
                curatedList: testCuratedList,
                previewCount: 1,
              ),
            ),
          ),
        );

        expect(find.text('Tokyo'), findsOneWidget);
        expect(find.text('Kyoto'), findsNothing);
      });
    });

    group('Image Handling', () {
      testWidgets('renders cover image when available',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CuratedListCard(curatedList: testCuratedList),
            ),
          ),
        );

        expect(find.byType(CachedNetworkImage), findsOneWidget);
      });

      testWidgets('uses first gallery image when cover image is null',
          (WidgetTester tester) async {
        final listWithoutCover = testCuratedList.copyWith(
          coverImageUrl: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CuratedListCard(curatedList: listWithoutCover),
            ),
          ),
        );

        expect(find.byType(CachedNetworkImage), findsOneWidget);
      });

      testWidgets('shows placeholder icon when no images available',
          (WidgetTester tester) async {
        final listWithoutImages = testCuratedList.copyWith(
          coverImageUrl: null,
          images: const [],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CuratedListCard(curatedList: listWithoutImages),
            ),
          ),
        );

        expect(find.byIcon(Icons.travel_explore), findsOneWidget);
        expect(find.byType(CachedNetworkImage), findsNothing);
      });
    });

    group('Interactions', () {
      testWidgets('calls onTap when card is tapped',
          (WidgetTester tester) async {
        var tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CuratedListCard(
                curatedList: testCuratedList,
                onTap: () => tapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(InkWell));
        expect(tapped, isTrue);
      });
    });

    group('Customization', () {
      testWidgets('uses custom border radius', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CuratedListCard(
                curatedList: testCuratedList,
                borderRadius: 20,
              ),
            ),
          ),
        );

        final card = tester.widget<Card>(find.byType(Card));
        final shape = card.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(20));
      });

      testWidgets('uses custom elevation', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CuratedListCard(
                curatedList: testCuratedList,
                elevation: 4,
              ),
            ),
          ),
        );

        final card = tester.widget<Card>(find.byType(Card));
        expect(card.elevation, 4);
      });

      testWidgets('renders trailing widget when provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CuratedListCard(
                curatedList: testCuratedList,
                trailing: const Text('Custom Trailing'),
              ),
            ),
          ),
        );

        expect(find.text('Custom Trailing'), findsOneWidget);
      });
    });

    group('Empty States', () {
      testWidgets('handles list with no destinations gracefully',
          (WidgetTester tester) async {
        final emptyList = testCuratedList.copyWith(
          destinations: [],
          destinationCount: 0,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CuratedListCard(curatedList: emptyList),
            ),
          ),
        );

        // Should not crash and show the card
        expect(find.byType(CuratedListCard), findsOneWidget);
        expect(find.text('0 Destinations'), findsOneWidget);
      });
    });

    group('Layout', () {
      testWidgets('has proper card structure', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CuratedListCard(curatedList: testCuratedList),
            ),
          ),
        );

        expect(find.byType(Card), findsOneWidget);
        expect(find.byType(InkWell), findsOneWidget);
        expect(find.byType(Column), findsWidgets);
      });
    });
  });
}
