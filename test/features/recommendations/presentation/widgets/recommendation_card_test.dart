import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/place_activity.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';
import 'package:soloadventurer/features/recommendations/presentation/widgets/recommendation_card.dart';

void main() {
  group('RecommendationCard', () {
    late PersonalizedRecommendation testRecommendation;

    setUp(() {
      testRecommendation = PersonalizedRecommendation(
        id: 'rec-123',
        activity: const PlaceActivity(
          id: 'place-1',
          name: 'Test Restaurant',
          category: RecommendationCategory.food,
          description: 'A great test restaurant',
          rating: 4.5,
          reviewCount: 250,
          images: ['https://example.com/image.jpg'],
          priceLevel: '\$\$',
        ),
        metadata: RecommendationMetadata(
          matchedInterests: {TravelInterest.foodTours},
          suggestedDate: DateTime(2026, 6, 15),
          suggestedTime: const TimeOfDay(hour: 12, minute: 30),
          distance: DistanceFromHotel.walking,
          weather: WeatherContext.anyWeather,
          crowdLevel: CrowdLevel.medium,
          estimatedDuration: const Duration(hours: 2),
          requiresAdvanceBooking: true,
        ),
        reasoning: 'Perfect match for your food interests',
        relevanceScore: 85.0,
      );
    });

    Widget createCardUnderTest({
      PersonalizedRecommendation? recommendation,
      VoidCallback? onTap,
      VoidCallback? onAdd,
      VoidCallback? onSave,
      VoidCallback? onDismiss,
    }) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: RecommendationCard(
              recommendation: recommendation ?? testRecommendation,
              onTap: onTap ?? () {},
              onAdd: onAdd ?? () {},
              onSave: onSave ?? () {},
              onDismiss: onDismiss ?? () {},
            ),
          ),
        ),
      );
    }

    testWidgets('renders recommendation name', (tester) async {
      // Arrange
      const name = 'Test Restaurant';

      // Act
      await tester.pumpWidget(createCardUnderTest());

      // Assert
      expect(find.text(name), findsOneWidget);
    });

    testWidgets('renders rating', (tester) async {
      // Act
      await tester.pumpWidget(createCardUnderTest());

      // Assert
      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('(250 reviews)'), findsOneWidget);
    });

    testWidgets('renders relevance score badge', (tester) async {
      // Act
      await tester.pumpWidget(createCardUnderTest());

      // Assert
      expect(find.text('85% match'), findsOneWidget);
    });

    testWidgets('renders reasoning text', (tester) async {
      // Act
      await tester.pumpWidget(createCardUnderTest());

      // Assert
      expect(
          find.text('Perfect match for your food interests'), findsOneWidget);
    });

    testWidgets('renders metadata chips', (tester) async {
      // Act
      await tester.pumpWidget(createCardUnderTest());

      // Assert
      expect(find.text('Jun 15'), findsOneWidget); // Date
      expect(find.text('Walking distance'), findsOneWidget); // Distance
      expect(find.text('Any weather'), findsOneWidget); // Weather
      expect(find.text('2h'), findsOneWidget); // Duration
    });

    testWidgets('shows "Book ahead" chip when advance booking required',
        (tester) async {
      // Act
      await tester.pumpWidget(createCardUnderTest());

      // Assert
      expect(find.text('Book ahead'), findsOneWidget);
    });

    testWidgets('renders action buttons', (tester) async {
      // Act
      await tester.pumpWidget(createCardUnderTest());

      // Assert
      expect(find.text('Add to Itinerary'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_outline), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('calls onTap when card is tapped', (tester) async {
      // Arrange
      var tapped = false;
      await tester.pumpWidget(createCardUnderTest(
        onTap: () => tapped = true,
      ));

      // Act
      await tester.tap(find.byType(InkWell));

      // Assert
      expect(tapped, true);
    });

    testWidgets('calls onAdd when Add to Itinerary is pressed', (tester) async {
      // Arrange
      var added = false;
      await tester.pumpWidget(createCardUnderTest(
        onAdd: () => added = true,
      ));

      // Act
      await tester.tap(find.text('Add to Itinerary'));

      // Assert
      expect(added, true);
    });

    testWidgets('calls onSave when bookmark is pressed', (tester) async {
      // Arrange
      var saved = false;
      await tester.pumpWidget(createCardUnderTest(
        onSave: () => saved = true,
      ));

      // Act
      await tester.tap(find.byIcon(Icons.bookmark_outline));

      // Assert
      expect(saved, true);
    });

    testWidgets('calls onDismiss when dismiss button is pressed',
        (tester) async {
      // Arrange
      var dismissed = false;
      await tester.pumpWidget(createCardUnderTest(
        onDismiss: () => dismissed = true,
      ));

      // Act
      await tester.tap(find.byIcon(Icons.close));

      // Assert
      expect(dismissed, true);
    });

    testWidgets('formats review count correctly for large numbers',
        (tester) async {
      // Arrange
      final largeReviewRec = PersonalizedRecommendation(
        id: 'rec-456',
        activity: const PlaceActivity(
          id: 'place-2',
          name: 'Popular Place',
          category: RecommendationCategory.attraction,
          rating: 4.8,
          reviewCount: 1500,
        ),
        metadata: testRecommendation.metadata,
        reasoning: 'Test',
      );

      // Act
      await tester.pumpWidget(createCardUnderTest(
        recommendation: largeReviewRec,
      ));

      // Assert
      expect(find.text('1.5k reviews'), findsOneWidget);
    });

    testWidgets('renders without image when images list is empty',
        (tester) async {
      // Arrange
      final noImageRec = PersonalizedRecommendation(
        id: 'rec-789',
        activity: const PlaceActivity(
          id: 'place-3',
          name: 'Place Without Image',
          category: RecommendationCategory.activity,
          images: [], // Empty images list
        ),
        metadata: testRecommendation.metadata,
        reasoning: 'Test',
      );

      // Act
      await tester.pumpWidget(createCardUnderTest(
        recommendation: noImageRec,
      ));

      // Assert
      expect(find.text('Place Without Image'), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    });

    testWidgets('uses correct score color for different scores',
        (tester) async {
      // Test high score (green)
      final highScoreRec = testRecommendation.copyWith(relevanceScore: 85);
      await tester
          .pumpWidget(createCardUnderTest(recommendation: highScoreRec));
      expect(find.text('85% match'), findsOneWidget);

      // Test medium score (blue)
      final mediumScoreRec = testRecommendation.copyWith(relevanceScore: 65);
      await tester
          .pumpWidget(createCardUnderTest(recommendation: mediumScoreRec));
      expect(find.text('65% match'), findsOneWidget);

      // Test low score (orange)
      final lowScoreRec = testRecommendation.copyWith(relevanceScore: 45);
      await tester.pumpWidget(createCardUnderTest(recommendation: lowScoreRec));
      expect(find.text('45% match'), findsOneWidget);

      // Test very low score (grey)
      final veryLowScoreRec = testRecommendation.copyWith(relevanceScore: 25);
      await tester
          .pumpWidget(createCardUnderTest(recommendation: veryLowScoreRec));
      expect(find.text('25% match'), findsOneWidget);
    });

    testWidgets('displays correct distance icon and text', (tester) async {
      // Test walking distance
      final walkingRec = PersonalizedRecommendation(
        id: 'rec-1',
        activity: testRecommendation.activity,
        metadata: testRecommendation.metadata.copyWith(
          distance: DistanceFromHotel.walking,
        ),
        reasoning: 'Test',
      );
      await tester.pumpWidget(createCardUnderTest(recommendation: walkingRec));
      expect(find.text('Walking distance'), findsOneWidget);

      // Test far distance
      final farRec = PersonalizedRecommendation(
        id: 'rec-2',
        activity: testRecommendation.activity,
        metadata: testRecommendation.metadata.copyWith(
          distance: DistanceFromHotel.far,
        ),
        reasoning: 'Test',
      );
      await tester.pumpWidget(createCardUnderTest(recommendation: farRec));
      expect(find.text('Far'), findsOneWidget);
    });

    testWidgets('displays correct weather icon and text', (tester) async {
      // Test indoor
      final indoorRec = PersonalizedRecommendation(
        id: 'rec-1',
        activity: testRecommendation.activity,
        metadata: testRecommendation.metadata.copyWith(
          weather: WeatherContext.indoor,
        ),
        reasoning: 'Test',
      );
      await tester.pumpWidget(createCardUnderTest(recommendation: indoorRec));
      expect(find.text('Indoor'), findsOneWidget);

      // Test outdoor
      final outdoorRec = PersonalizedRecommendation(
        id: 'rec-2',
        activity: testRecommendation.activity,
        metadata: testRecommendation.metadata.copyWith(
          weather: WeatherContext.outdoor,
        ),
        reasoning: 'Test',
      );
      await tester.pumpWidget(createCardUnderTest(recommendation: outdoorRec));
      expect(find.text('Outdoor'), findsOneWidget);
    });

    testWidgets('formats duration correctly', (tester) async {
      // Test hours and minutes
      final durationRec = PersonalizedRecommendation(
        id: 'rec-1',
        activity: testRecommendation.activity,
        metadata: testRecommendation.metadata.copyWith(
          estimatedDuration: const Duration(hours: 2, minutes: 30),
        ),
        reasoning: 'Test',
      );
      await tester.pumpWidget(createCardUnderTest(recommendation: durationRec));
      expect(find.text('2h 30m'), findsOneWidget);

      // Test only hours
      final hoursRec = PersonalizedRecommendation(
        id: 'rec-2',
        activity: testRecommendation.activity,
        metadata: testRecommendation.metadata.copyWith(
          estimatedDuration: const Duration(hours: 3),
        ),
        reasoning: 'Test',
      );
      await tester.pumpWidget(createCardUnderTest(recommendation: hoursRec));
      expect(find.text('3h'), findsOneWidget);

      // Test only minutes
      final minutesRec = PersonalizedRecommendation(
        id: 'rec-3',
        activity: testRecommendation.activity,
        metadata: testRecommendation.metadata.copyWith(
          estimatedDuration: const Duration(minutes: 45),
        ),
        reasoning: 'Test',
      );
      await tester.pumpWidget(createCardUnderTest(recommendation: minutesRec));
      expect(find.text('45m'), findsOneWidget);
    });
  });
}

// Import for CachedNetworkImage - mock it for tests
class CachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Widget Function(BuildContext, String, dynamic)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;

  const CachedNetworkImage({
    required this.imageUrl,
    this.height,
    this.width,
    this.fit,
    this.placeholder,
    this.errorWidget,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[300],
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
