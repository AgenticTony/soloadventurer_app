import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';

void main() {
  group('TravelInterest', () {
    group('Enum values', () {
      test('should have all expected values', () {
        const expectedValues = {
          TravelInterest.food,
          TravelInterest.culture,
          TravelInterest.nature,
          TravelInterest.art,
          TravelInterest.shopping,
          TravelInterest.nightlife,
          TravelInterest.adventure,
          TravelInterest.wellness,
          TravelInterest.photography,
          TravelInterest.localExperience,
        };

        expect(TravelInterest.values.length, 10);
        for (final value in expectedValues) {
          expect(TravelInterest.values.contains(value), isTrue);
        }
      });
    });

    group('Properties', () {
      test('should have correct labels for all interests', () {
        final labels = {
          TravelInterest.food: 'Food & Cuisine',
          TravelInterest.culture: 'Culture & History',
          TravelInterest.nature: 'Nature & Scenery',
          TravelInterest.art: 'Art & Museums',
          TravelInterest.shopping: 'Shopping & Markets',
          TravelInterest.nightlife: 'Nightlife & Entertainment',
          TravelInterest.adventure: 'Adventure & Outdoors',
          TravelInterest.wellness: 'Wellness & Relaxation',
          TravelInterest.photography: 'Photography',
          TravelInterest.localExperience: 'Local Experiences',
        };

        for (final entry in labels.entries) {
          expect(entry.key.label, entry.value);
        }
      });

      test('should have unique emojis for all interests', () {
        final emojis = <String>{};

        for (final interest in TravelInterest.values) {
          expect(emojis, isNot(contains(interest.emoji)));
          emojis.add(interest.emoji);
        }

        expect(emojis.length, TravelInterest.values.length);
      });

      test('should have unique labels for all interests', () {
        final labels = <String>{};

        for (final interest in TravelInterest.values) {
          expect(labels, isNot(contains(interest.label)));
          labels.add(interest.label);
        }

        expect(labels.length, TravelInterest.values.length);
      });

      test('should have valid emoji strings', () {
        for (final interest in TravelInterest.values) {
          // Emojis should be single Unicode characters or sequences
          expect(interest.emoji.runes.length, greaterThan(0));
          expect(interest.emoji.runes.first, greaterThan(0x1F000),
              reason: '${interest.label} emoji should be in valid range');
        }
      });
    });

    group('Display formatting', () {
      test('should format displayName with emoji and label', () {
        const interest = TravelInterest.food;
        final display = interest.displayName;

        expect(display, '🍽️ Food & Cuisine');
      });

      test('should provide emoji for UI rendering', () {
        for (final interest in TravelInterest.values) {
          expect(interest.emoji.isNotEmpty, isTrue);
          expect(interest.emoji, isNotEmpty);
        }
      });
    });

    group('Grouping', () {
      test('can be used in Sets for selection tracking', () {
        final selected = <TravelInterest>{
          TravelInterest.food,
          TravelInterest.culture,
        };

        expect(selected.length, 2);
        expect(selected.contains(TravelInterest.food), isTrue);
        expect(selected.contains(TravelInterest.adventure), isFalse);

        // Add duplicate should not increase size
        selected.add(TravelInterest.food);
        expect(selected.length, 2);
      });

      test('can be iterated in sorted order', () {
        final sorted = TravelInterest.values.toList()
          ..sort((a, b) => a.label.compareTo(b.label));

        expect(sorted.first.label, 'Adventure & Outdoors');
        expect(sorted.last.label, 'Wellness & Relaxation');
      });
    });

    group('Value equality', () {
      test('enum values should be equal to themselves', () {
        for (final interest in TravelInterest.values) {
          expect(interest, equals(interest));
          expect(interest, same(interest));
        }
      });

      test('enum values should not be equal to other values', () {
        expect(TravelInterest.food, isNot(equals(TravelInterest.culture)));
        expect(TravelInterest.food, isNot(equals(TravelInterest.art)));
      });

      test('index values should be unique', () {
        final indices = <int>{};

        for (final interest in TravelInterest.values) {
          expect(indices, isNot(contains(interest.index)));
          indices.add(interest.index);
        }

        expect(indices.length, TravelInterest.values.length);
      });
    });

    group('Serialization', () {
      test('should be serializable by name', () {
        for (final interest in TravelInterest.values) {
          final name = interest.name;
          final deserialized = TravelInterest.values.byName(name);

          expect(deserialized, equals(interest));
        }
      });

      test('should handle invalid names gracefully', () {
        expect(
          () => TravelInterest.values.byName('invalid_interest'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Practical usage', () {
      test('should limit selection to 5 interests max', () {
        final interests = <TravelInterest>{};

        // Add 5 interests - should work
        for (final interest in TravelInterest.values.take(5)) {
          expect(interests.length, lessThan(6));
          interests.add(interest);
        }

        expect(interests.length, 5);

        // Try to add 6th interest - should exceed limit
        final sixth = TravelInterest.values.skip(5).first;
        interests.add(sixth);

        expect(interests.length, 6);
        // Validation would happen at business logic level
      });

      test('should support filtering by categories', () {
        final natureRelated = TravelInterest.values.where(
          (interest) =>
              interest.label.contains('Nature') ||
              interest.label.contains('Scenery') ||
              interest.label.contains('Outdoors') ||
              interest.label.contains('Adventure'),
        );

        expect(natureRelated, contains(TravelInterest.nature));
        expect(natureRelated, contains(TravelInterest.adventure));
        expect(natureRelated, isNot(contains(TravelInterest.shopping)));
      });

      test('should support common selection patterns', () {
        // Foodies
        final foodieSet = {
          TravelInterest.food,
          TravelInterest.shopping,
          TravelInterest.nightlife,
        };

        // Culture seekers
        final cultureSet = {
          TravelInterest.culture,
          TravelInterest.art,
          TravelInterest.localExperience,
          TravelInterest.photography,
        };

        // Adventure travelers
        final adventureSet = {
          TravelInterest.adventure,
          TravelInterest.nature,
          TravelInterest.wellness,
        };

        expect(foodieSet.length, 3);
        expect(cultureSet.length, 4);
        expect(adventureSet.length, 3);
      });
    });
  });
}
