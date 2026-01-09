import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/place_activity.dart';

void main() {
  group('PlaceActivity', () {
    group('Factory Constructor', () {
      test('creates PlaceActivity with all required fields', () {
        const placeActivity = PlaceActivity(
          id: 'test-id',
          name: 'Test Place',
          category: RecommendationCategory.attraction,
        );

        expect(placeActivity.id, 'test-id');
        expect(placeActivity.name, 'Test Place');
        expect(placeActivity.category, RecommendationCategory.attraction);
      });

      test('creates PlaceActivity with all optional fields', () {
        final now = DateTime.now();
        const placeActivity = PlaceActivity(
          id: 'test-id',
          name: 'Test Place',
          category: RecommendationCategory.restaurant,
          description: 'A great restaurant',
          location: '123 Main St',
          latitude: 40.7128,
          longitude: -74.0060,
          rating: 4.5,
          reviewCount: 1000,
          priceLevel: '\$\$',
          cost: 50.0,
          estimatedDuration: Duration(hours: 2),
          images: ['image1.jpg', 'image2.jpg'],
          tags: ['solo_friendly', 'indoor'],
          localTips: ['Try the pasta'],
          bookingUrl: 'https://example.com/book',
          requiresBooking: true,
          openingHours: '9:00 AM - 5:00 PM',
        );

        expect(placeActivity.id, 'test-id');
        expect(placeActivity.name, 'Test Place');
        expect(placeActivity.category, RecommendationCategory.restaurant);
        expect(placeActivity.description, 'A great restaurant');
        expect(placeActivity.location, '123 Main St');
        expect(placeActivity.latitude, 40.7128);
        expect(placeActivity.longitude, -74.0060);
        expect(placeActivity.rating, 4.5);
        expect(placeActivity.reviewCount, 1000);
        expect(placeActivity.priceLevel, '\$\$');
        expect(placeActivity.cost, 50.0);
        expect(placeActivity.estimatedDuration, const Duration(hours: 2));
        expect(placeActivity.images, ['image1.jpg', 'image2.jpg']);
        expect(placeActivity.tags, ['solo_friendly', 'indoor']);
        expect(placeActivity.localTips, ['Try the pasta']);
        expect(placeActivity.bookingUrl, 'https://example.com/book');
        expect(placeActivity.requiresBooking, true);
        expect(placeActivity.openingHours, '9:00 AM - 5:00 PM');
      });

      test('uses default values for optional numeric fields', () {
        const placeActivity = PlaceActivity(
          id: 'test-id',
          name: 'Test Place',
          category: RecommendationCategory.attraction,
        );

        expect(placeActivity.rating, 0.0);
        expect(placeActivity.reviewCount, 0);
      });

      test('uses default values for optional list fields', () {
        const placeActivity = PlaceActivity(
          id: 'test-id',
          name: 'Test Place',
          category: RecommendationCategory.attraction,
        );

        expect(placeActivity.images, isEmpty);
        expect(placeActivity.tags, isEmpty);
        expect(placeActivity.localTips, isEmpty);
      });

      test('uses default values for optional boolean fields', () {
        const placeActivity = PlaceActivity(
          id: 'test-id',
          name: 'Test Place',
          category: RecommendationCategory.attraction,
        );

        expect(placeActivity.requiresBooking, false);
      });
    });

    group('JSON Serialization', () {
      test('serializes to JSON correctly', () {
        const placeActivity = PlaceActivity(
          id: 'test-id',
          name: 'Test Place',
          category: RecommendationCategory.attraction,
          rating: 4.5,
        );

        final json = placeActivity.toJson();

        expect(json['id'], 'test-id');
        expect(json['name'], 'Test Place');
        expect(json['category'], RecommendationCategory.attraction.index);
        expect(json['rating'], 4.5);
      });

      test('deserializes from JSON correctly', () {
        final json = {
          'id': 'test-id',
          'name': 'Test Place',
          'category': RecommendationCategory.attraction.index,
          'rating': 4.5,
        };

        final placeActivity = PlaceActivity.fromJson(json);

        expect(placeActivity.id, 'test-id');
        expect(placeActivity.name, 'Test Place');
        expect(placeActivity.category, RecommendationCategory.attraction);
        expect(placeActivity.rating, 4.5);
      });

      test('round-trips through JSON serialization', () {
        const original = PlaceActivity(
          id: 'test-id',
          name: 'Test Place',
          category: RecommendationCategory.food,
          description: 'Test description',
          rating: 4.8,
          reviewCount: 500,
        );

        final json = original.toJson();
        final deserialized = PlaceActivity.fromJson(json);

        expect(deserialized.id, original.id);
        expect(deserialized.name, original.name);
        expect(deserialized.category, original.category);
        expect(deserialized.description, original.description);
        expect(deserialized.rating, original.rating);
        expect(deserialized.reviewCount, original.reviewCount);
      });
    });

    group('Computed Properties', () {
      test('isIndoor returns true when tags contain indoor', () {
        const placeActivity = PlaceActivity(
          id: 'test-id',
          name: 'Test Place',
          category: RecommendationCategory.attraction,
          tags: ['indoor'],
        );

        expect(placeActivity.isIndoor, true);
      });

      test('isIndoor returns true when category is culture', () {
        const placeActivity = PlaceActivity(
          id: 'test-id',
          name: 'Museum',
          category: RecommendationCategory.culture,
        );

        expect(placeActivity.isIndoor, true);
      });

      test('isIndoor returns true when category is entertainment', () {
        const placeActivity = PlaceActivity(
          id: 'test-id',
          name: 'Theater',
          category: RecommendationCategory.entertainment,
        );

        expect(placeActivity.isIndoor, true);
      });

      test('isIndoor returns false for outdoor activities', () {
        const placeActivity = PlaceActivity(
          id: 'test-id',
          name: 'Hiking Trail',
          category: RecommendationCategory.adventure,
          tags: ['outdoor'],
        );

        expect(placeActivity.isIndoor, false);
      });

      test('isOutdoor returns true when tags contain outdoor', () {
        const placeActivity = PlaceActivity(
          id: 'test-id',
          name: 'Test Place',
          category: RecommendationCategory.attraction,
          tags: ['outdoor'],
        );

        expect(placeActivity.isOutdoor, true);
      });

      test('isOutdoor returns true when category is adventure', () {
        const placeActivity = PlaceActivity(
          id: 'test-id',
          name: 'Rock Climbing',
          category: RecommendationCategory.adventure,
        );

        expect(placeActivity.isOutdoor, true);
      });

      test('isOutdoor returns false for indoor activities', () {
        const placeActivity = PlaceActivity(
          id: 'test-id',
          name: 'Museum',
          category: RecommendationCategory.culture,
          tags: ['indoor'],
        );

        expect(placeActivity.isOutdoor, false);
      });

      test(
          'isMajorTouristAttraction returns true for high-rated places with many reviews',
          () {
        const placeActivity = PlaceActivity(
          id: 'test-id',
          name: 'Famous Landmark',
          category: RecommendationCategory.attraction,
          rating: 4.7,
          reviewCount: 2000,
        );

        expect(placeActivity.isMajorTouristAttraction, true);
      });

      test('isMajorTouristAttraction returns false for low-rated places', () {
        const placeActivity = PlaceActivity(
          id: 'test-id',
          name: 'Small Shop',
          category: RecommendationCategory.shopping,
          rating: 4.0,
          reviewCount: 2000,
        );

        expect(placeActivity.isMajorTouristAttraction, false);
      });

      test('isMajorTouristAttraction returns false for places with few reviews',
          () {
        const placeActivity = PlaceActivity(
          id: 'test-id',
          name: 'New Place',
          category: RecommendationCategory.attraction,
          rating: 4.8,
          reviewCount: 100,
        );

        expect(placeActivity.isMajorTouristAttraction, false);
      });

      test('categoryDisplayName returns correct display name for food', () {
        const placeActivity = PlaceActivity(
          id: 'test-id',
          name: 'Restaurant',
          category: RecommendationCategory.food,
        );

        expect(placeActivity.categoryDisplayName, 'Food & Dining');
      });

      test(
          'categoryDisplayName returns correct display name for all categories',
          () {
        expect(
          const PlaceActivity(
            id: '1',
            name: 'Test',
            category: RecommendationCategory.food,
          ).categoryDisplayName,
          'Food & Dining',
        );

        expect(
          const PlaceActivity(
            id: '2',
            name: 'Test',
            category: RecommendationCategory.attraction,
          ).categoryDisplayName,
          'Attraction',
        );

        expect(
          const PlaceActivity(
            id: '3',
            name: 'Test',
            category: RecommendationCategory.activity,
          ).categoryDisplayName,
          'Activity',
        );

        expect(
          const PlaceActivity(
            id: '4',
            name: 'Test',
            category: RecommendationCategory.entertainment,
          ).categoryDisplayName,
          'Entertainment',
        );

        expect(
          const PlaceActivity(
            id: '5',
            name: 'Test',
            category: RecommendationCategory.shopping,
          ).categoryDisplayName,
          'Shopping',
        );

        expect(
          const PlaceActivity(
            id: '6',
            name: 'Test',
            category: RecommendationCategory.wellness,
          ).categoryDisplayName,
          'Wellness',
        );

        expect(
          const PlaceActivity(
            id: '7',
            name: 'Test',
            category: RecommendationCategory.culture,
          ).categoryDisplayName,
          'Culture',
        );

        expect(
          const PlaceActivity(
            id: '8',
            name: 'Test',
            category: RecommendationCategory.adventure,
          ).categoryDisplayName,
          'Adventure',
        );
      });
    });

    group('Methods', () {
      test('isOpenDuring returns true when openingHours is null', () {
        const placeActivity = PlaceActivity(
          id: 'test-id',
          name: 'Test Place',
          category: RecommendationCategory.attraction,
        );

        final dateRange = DateTimeRange(
          start: DateTime(2026, 1, 1),
          end: DateTime(2026, 1, 7),
        );

        expect(placeActivity.isOpenDuring(dateRange), true);
      });

      test('isOpenDuring returns true when openingHours is set', () {
        const placeActivity = PlaceActivity(
          id: 'test-id',
          name: 'Test Place',
          category: RecommendationCategory.attraction,
          openingHours: '9:00 AM - 5:00 PM',
        );

        final dateRange = DateTimeRange(
          start: DateTime(2026, 1, 1),
          end: DateTime(2026, 1, 7),
        );

        expect(placeActivity.isOpenDuring(dateRange), true);
      });
    });
  });

  group('DateTimeRange', () {
    test('creates DateTimeRange with start and end', () {
      final start = DateTime(2026, 1, 1);
      final end = DateTime(2026, 1, 7);

      final dateRange = DateTimeRange(start: start, end: end);

      expect(dateRange.start, start);
      expect(dateRange.end, end);
    });

    test('duration returns correct duration', () {
      final dateRange = DateTimeRange(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 8),
      );

      expect(dateRange.duration, const Duration(days: 7));
    });

    test('duration handles partial days', () {
      final dateRange = DateTimeRange(
        start: DateTime(2026, 1, 1, 10, 0),
        end: DateTime(2026, 1, 1, 14, 0),
      );

      expect(dateRange.duration, const Duration(hours: 4));
    });
  });

  group('RecommendationCategory enum', () {
    test('has all expected categories', () {
      expect(RecommendationCategory.values.length, 8);

      expect(
          RecommendationCategory.values, contains(RecommendationCategory.food));
      expect(RecommendationCategory.values,
          contains(RecommendationCategory.attraction));
      expect(RecommendationCategory.values,
          contains(RecommendationCategory.activity));
      expect(RecommendationCategory.values,
          contains(RecommendationCategory.entertainment));
      expect(RecommendationCategory.values,
          contains(RecommendationCategory.shopping));
      expect(RecommendationCategory.values,
          contains(RecommendationCategory.wellness));
      expect(RecommendationCategory.values,
          contains(RecommendationCategory.culture));
      expect(RecommendationCategory.values,
          contains(RecommendationCategory.adventure));
    });
  });
}
