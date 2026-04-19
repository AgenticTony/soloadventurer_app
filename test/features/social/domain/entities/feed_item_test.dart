import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/entities/feed_item.dart';

void main() {
  final tCreatedAt = DateTime(2026, 2, 1);

  FeedItem createFeedItem({
    String id = 'feed-1',
    String actorId = 'actor-1',
    String actorUsername = 'traveler',
    String? actorAvatar,
    FeedVerb verb = FeedVerb.posted,
    String objectId = 'obj-1',
    String objectType = 'journal',
    DateTime? createdAt,
  }) {
    return FeedItem(
      id: id,
      actorId: actorId,
      actorUsername: actorUsername,
      actorAvatar: actorAvatar,
      verb: verb,
      objectId: objectId,
      objectType: objectType,
      createdAt: createdAt ?? tCreatedAt,
    );
  }

  group('FeedVerb', () {
    test('has four values', () {
      expect(FeedVerb.values.length, 4);
    });

    test('values are posted, followed, reacted, commented', () {
      expect(FeedVerb.values, [
        FeedVerb.posted,
        FeedVerb.followed,
        FeedVerb.reacted,
        FeedVerb.commented,
      ]);
    });

    group('fromString', () {
      test('returns posted for "posted"', () {
        expect(FeedVerb.fromString('posted'), FeedVerb.posted);
      });

      test('returns followed for "followed"', () {
        expect(FeedVerb.fromString('followed'), FeedVerb.followed);
      });

      test('returns reacted for "reacted"', () {
        expect(FeedVerb.fromString('reacted'), FeedVerb.reacted);
      });

      test('returns commented for "commented"', () {
        expect(FeedVerb.fromString('commented'), FeedVerb.commented);
      });

      test('is case-insensitive', () {
        expect(FeedVerb.fromString('Posted'), FeedVerb.posted);
        expect(FeedVerb.fromString('FOLLOWED'), FeedVerb.followed);
      });

      test('throws ArgumentError for unknown value', () {
        expect(() => FeedVerb.fromString('unknown'), throwsArgumentError);
      });
    });

    group('FeedVerbExtension', () {
      test('value returns correct string for each verb', () {
        expect(FeedVerb.posted.value, 'posted');
        expect(FeedVerb.followed.value, 'followed');
        expect(FeedVerb.reacted.value, 'reacted');
        expect(FeedVerb.commented.value, 'commented');
      });
    });
  });

  group('FeedItem', () {
    test('constructs with required fields', () {
      final item = createFeedItem();

      expect(item.id, 'feed-1');
      expect(item.actorId, 'actor-1');
      expect(item.actorUsername, 'traveler');
      expect(item.actorAvatar, isNull);
      expect(item.verb, FeedVerb.posted);
      expect(item.objectId, 'obj-1');
      expect(item.objectType, 'journal');
      expect(item.createdAt, tCreatedAt);
    });

    test('constructs with optional actorAvatar', () {
      final item = createFeedItem(
        actorAvatar: 'https://example.com/avatar.jpg',
      );

      expect(item.actorAvatar, 'https://example.com/avatar.jpg');
    });

    group('copyWith', () {
      test('copies all fields when specified', () {
        final original = createFeedItem();
        final newDate = DateTime(2026, 3, 1);
        final copied = original.copyWith(
          id: 'feed-2',
          actorId: 'actor-2',
          actorUsername: 'explorer',
          actorAvatar: 'https://example.com/pic.jpg',
          verb: FeedVerb.commented,
          objectId: 'obj-2',
          objectType: 'trip',
          createdAt: newDate,
        );

        expect(copied.id, 'feed-2');
        expect(copied.actorId, 'actor-2');
        expect(copied.actorUsername, 'explorer');
        expect(copied.actorAvatar, 'https://example.com/pic.jpg');
        expect(copied.verb, FeedVerb.commented);
        expect(copied.objectId, 'obj-2');
        expect(copied.objectType, 'trip');
        expect(copied.createdAt, newDate);
      });

      test('retains original values when no arguments given', () {
        final original = createFeedItem();
        final copied = original.copyWith();

        expect(copied.id, original.id);
        expect(copied.actorId, original.actorId);
        expect(copied.actorUsername, original.actorUsername);
        expect(copied.actorAvatar, original.actorAvatar);
        expect(copied.verb, original.verb);
        expect(copied.objectId, original.objectId);
        expect(copied.objectType, original.objectType);
        expect(copied.createdAt, original.createdAt);
      });
    });

    group('equality', () {
      test('equal when all props match', () {
        final a = createFeedItem();
        final b = createFeedItem();
        expect(a, equals(b));
      });

      test('not equal when id differs', () {
        final a = createFeedItem(id: 'a');
        final b = createFeedItem(id: 'b');
        expect(a, isNot(equals(b)));
      });

      test('not equal when verb differs', () {
        final a = createFeedItem(verb: FeedVerb.posted);
        final b = createFeedItem(verb: FeedVerb.reacted);
        expect(a, isNot(equals(b)));
      });

      test('not equal when actorAvatar differs', () {
        final a = createFeedItem();
        final b = createFeedItem(actorAvatar: 'https://example.com/pic.jpg');
        expect(a, isNot(equals(b)));
      });

      test('not equal when createdAt differs', () {
        final a = createFeedItem(createdAt: DateTime(2026, 1, 1));
        final b = createFeedItem(createdAt: DateTime(2026, 2, 1));
        expect(a, isNot(equals(b)));
      });
    });
  });
}
