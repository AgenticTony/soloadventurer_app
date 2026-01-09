import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination.dart';
import 'package:soloadventurer/features/destination_discovery/presentation/widgets/destination_card.dart';

void main() {
  group('DestinationCard', () {
    // Test data
    late Destination testDestination;
    late Destination hiddenGemDestination;

    setUp(() {
      final now = DateTime.now();
      testDestination = Destination(
        id: '1',
        name: 'Tokyo',
        description: 'A vibrant city blending tradition and futurism.',
        latitude: 35.6762,
        longitude: 139.6503,
        countryCode: 'JP',
        region: 'Kanto',
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
        activityLevels: const [ActivityLevel.moderate, ActivityLevel.adventurous],
        tags: const ['urban', 'cultural', 'food'],
        images: const [
          'https://example.com/tokyo1.jpg',
          'https://example.com/tokyo2.jpg',
        ],
        coverImageUrl: 'https://example.com/tokyo-cover.jpg',
        popularActivities: const [],
        bestTimeToVisit: 'March to May',
        averageDailyCost: 100,
        createdAt: now,
        updatedAt: now,
      );

      hiddenGemDestination = Destination(
        id: '2',
        name: 'Hidden Valley',
        description: 'A secluded paradise off the beaten path.',
        latitude: 35.6762,
        longitude: 139.6503,
        countryCode: 'NP',
        safetyScore: 7.5,
        safetyInsights: [],
        soloSuitabilityScore: 8.0,
        soloSuitabilityFactors: const SoloSuitabilityFactors(
          safety: 7.5,
          nightlife: 6.0,
          walkability: 8.0,
          accommodation: 7.0,
          soloDining: 7.5,
          communication: 6.5,
          overall: 8.0,
        ),
        budgetLevel: BudgetLevel.budget,
        activityLevels: const [ActivityLevel.relaxed],
        tags: const ['nature', 'hidden'],
        images: const ['https://example.com/valley.jpg'],
        coverImageUrl: 'https://example.com/valley-cover.jpg',
        popularActivities: const [],
        createdAt: now,
        updatedAt: now,
        isHiddenGem: true,
      );
    });

    group('Rendering', () {
      testWidgets('renders destination name', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(destination: testDestination),
            ),
          ),
        );

        expect(find.text('Tokyo'), findsOneWidget);
      });

      testWidgets('renders truncated description (max 2 lines)',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(destination: testDestination),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(
          find.text('A vibrant city blending tradition and futurism.'),
        );
        expect(textWidget.maxLines, 2);
        expect(textWidget.overflow, TextOverflow.ellipsis);
      });

      testWidgets('renders country code', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(destination: testDestination),
            ),
          ),
        );

        expect(find.text('JP'), findsOneWidget);
      });

      testWidgets('renders safety score badge', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(destination: testDestination),
            ),
          ),
        );

        expect(find.text('8.5'), findsOneWidget);
        expect(find.text('Safety'), findsOneWidget);
      });

      testWidgets('renders solo suitability badge',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(destination: testDestination),
            ),
          ),
        );

        expect(find.text('9.0'), findsOneWidget);
        expect(find.text('Solo'), findsOneWidget);
      });

      testWidgets('renders budget indicator with icon',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(destination: testDestination),
            ),
          ),
        );

        expect(find.text('Moderate'), findsOneWidget);
        expect(find.byIcon(Icons.money), findsOneWidget);
      });

      testWidgets('renders budget indicator for budget level',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(destination: hiddenGemDestination),
            ),
          ),
        );

        expect(find.text('Budget-friendly'), findsOneWidget);
        expect(find.byIcon(Icons.attach_money), findsOneWidget);
      });

      testWidgets('renders budget indicator for expensive level',
          (WidgetTester tester) async {
        final expensiveDestination = Destination(
          id: '3',
          name: 'Luxury City',
          description: 'High-end destination',
          latitude: 35.6762,
          longitude: 139.6503,
          countryCode: 'US',
          safetyScore: 8.0,
          safetyInsights: [],
          soloSuitabilityScore: 8.0,
          soloSuitabilityFactors: const SoloSuitabilityFactors(
            safety: 8.0,
            nightlife: 8.0,
            walkability: 8.0,
            accommodation: 8.0,
            soloDining: 8.0,
            communication: 8.0,
            overall: 8.0,
          ),
          budgetLevel: BudgetLevel.expensive,
          activityLevels: const [],
          tags: const [],
          images: const [],
          popularActivities: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(destination: expensiveDestination),
            ),
          ),
        );

        expect(find.text('Luxury'), findsOneWidget);
        expect(find.byIcon(Icons.trending_up), findsOneWidget);
      });

      testWidgets('renders average daily cost when available',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(destination: testDestination),
            ),
          ),
        );

        expect(find.text('\$100/day'), findsOneWidget);
      });

      testWidgets('shows hidden gem badge when destination is hidden gem',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(destination: hiddenGemDestination),
            ),
          ),
        );

        expect(find.text('Hidden Gem'), findsOneWidget);
        expect(find.byIcon(Icons.diamond), findsOneWidget);
      });

      testWidgets('does not show hidden gem badge for regular destinations',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(destination: testDestination),
            ),
          ),
        );

        expect(find.text('Hidden Gem'), findsNothing);
      });

      testWidgets('renders bookmark button when onBookmarkTap is provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(
                destination: testDestination,
                onBookmarkTap: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
      });

      testWidgets('shows filled bookmark when isSaved is true',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(
                destination: testDestination,
                onBookmarkTap: () {},
                isSaved: true,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.bookmark), findsOneWidget);
        expect(find.byIcon(Icons.bookmark_border), findsNothing);
      });

      testWidgets('shows location icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(destination: testDestination),
            ),
          ),
        );

        expect(find.byIcon(Icons.location_on), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets('calls onTap when card is tapped',
          (WidgetTester tester) async {
        var tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(
                destination: testDestination,
                onTap: () => tapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(InkWell));
        expect(tapped, isTrue);
      });

      testWidgets('calls onBookmarkTap when bookmark button is tapped',
          (WidgetTester tester) async {
        var bookmarkTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(
                destination: testDestination,
                onBookmarkTap: () => bookmarkTapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.bookmark_border));
        expect(bookmarkTapped, isTrue);
      });

      testWidgets('does not render bookmark button when onBookmarkTap is null',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(destination: testDestination),
            ),
          ),
        );

        expect(find.byIcon(Icons.bookmark_border), findsNothing);
        expect(find.byIcon(Icons.bookmark), findsNothing);
      });
    });

    group('Image Handling', () {
      testWidgets('renders cover image when available',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(destination: testDestination),
            ),
          ),
        );

        expect(
          find.byType(CachedNetworkImage),
          findsOneWidget,
        );
      });

      testWidgets('uses first image from list when cover image is null',
          (WidgetTester tester) async {
        final destinationWithoutCover = testDestination.copyWith(
          coverImageUrl: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(destination: destinationWithoutCover),
            ),
          ),
        );

        expect(
          find.byType(CachedNetworkImage),
          findsOneWidget,
        );
      });

      testWidgets('shows placeholder icon when no images available',
          (WidgetTester tester) async {
        final destinationWithoutImages = testDestination.copyWith(
          coverImageUrl: null,
          images: const [],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(destination: destinationWithoutImages),
            ),
          ),
        );

        expect(find.byIcon(Icons.place), findsOneWidget);
        expect(find.byType(CachedNetworkImage), findsNothing);
      });
    });

    group('Customization', () {
      testWidgets('uses custom border radius', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(
                destination: testDestination,
                borderRadius: 20,
              ),
            ),
          ),
        );

        final card = tester.widget<Card>(find.byType(Card));
        final shape = card.shape as RoundedRectangleBorder;
        expect(
          shape.borderRadius,
          BorderRadius.circular(20),
        );
      });

      testWidgets('uses custom elevation', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(
                destination: testDestination,
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
              body: DestinationCard(
                destination: testDestination,
                trailing: const Text('Custom Trailing'),
              ),
            ),
          ),
        );

        expect(find.text('Custom Trailing'), findsOneWidget);
      });

      testWidgets('does not render trailing widget when not provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(destination: testDestination),
            ),
          ),
        );

        expect(find.text('Custom Trailing'), findsNothing);
      });
    });

    group('Layout', () {
      testWidgets('has proper card structure', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(destination: testDestination),
            ),
          ),
        );

        expect(find.byType(Card), findsOneWidget);
        expect(find.byType(InkWell), findsOneWidget);
        expect(find.byType(Column), findsWidgets);
      });

      testWidgets('description text has proper styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationCard(destination: testDestination),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(
          find.text('A vibrant city blending tradition and futurism.'),
        );
        expect(textWidget.style?.fontSize, isNotNull);
        expect(textWidget.style?.color, isNotNull);
      });
    });
  });
}
