import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/entities/reaction.dart';

void main() {
  group('ReactionType', () {
    test('has four values', () {
      expect(ReactionType.values.length, 4);
    });

    test('values are like, love, inspire, helpful', () {
      expect(ReactionType.values, [
        ReactionType.like,
        ReactionType.love,
        ReactionType.inspire,
        ReactionType.helpful,
      ]);
    });

    group('fromString', () {
      test('returns like for "like"', () {
        expect(ReactionType.fromString('like'), ReactionType.like);
      });

      test('returns love for "love"', () {
        expect(ReactionType.fromString('love'), ReactionType.love);
      });

      test('returns inspire for "inspire"', () {
        expect(ReactionType.fromString('inspire'), ReactionType.inspire);
      });

      test('returns helpful for "helpful"', () {
        expect(ReactionType.fromString('helpful'), ReactionType.helpful);
      });

      test('throws ArgumentError for unknown value', () {
        expect(() => ReactionType.fromString('unknown'), throwsArgumentError);
      });
    });
  });

  group('ReactionTargetType', () {
    test('has two values', () {
      expect(ReactionTargetType.values.length, 2);
    });

    test('values are journal and comment', () {
      expect(ReactionTargetType.values, [
        ReactionTargetType.journal,
        ReactionTargetType.comment,
      ]);
    });

    group('fromString', () {
      test('returns journal for "journal"', () {
        expect(
          ReactionTargetType.fromString('journal'),
          ReactionTargetType.journal,
        );
      });

      test('returns comment for "comment"', () {
        expect(
          ReactionTargetType.fromString('comment'),
          ReactionTargetType.comment,
        );
      });

      test('throws ArgumentError for unknown value', () {
        expect(
          () => ReactionTargetType.fromString('unknown'),
          throwsArgumentError,
        );
      });
    });
  });
}
