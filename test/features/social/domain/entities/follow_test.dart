import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/entities/follow.dart';

void main() {
  final tCreatedAt = DateTime(2026, 1, 5);
  final tUpdatedAt = DateTime(2026, 1, 6);

  Follow createFollow({
    String id = 'follow-1',
    String followerId = 'user-1',
    String followingId = 'user-2',
    FollowStatus status = FollowStatus.accepted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Follow(
      id: id,
      followerId: followerId,
      followingId: followingId,
      status: status,
      createdAt: createdAt ?? tCreatedAt,
      updatedAt: updatedAt ?? tUpdatedAt,
    );
  }

  group('FollowStatus', () {
    test('has two values', () {
      expect(FollowStatus.values.length, 2);
    });

    test('values are pending and accepted', () {
      expect(FollowStatus.values, [
        FollowStatus.pending,
        FollowStatus.accepted,
      ]);
    });

    group('fromString', () {
      test('returns pending for "pending"', () {
        expect(FollowStatus.fromString('pending'), FollowStatus.pending);
      });

      test('returns accepted for "accepted"', () {
        expect(FollowStatus.fromString('accepted'), FollowStatus.accepted);
      });

      test('is case-insensitive', () {
        expect(FollowStatus.fromString('Pending'), FollowStatus.pending);
        expect(FollowStatus.fromString('ACCEPTED'), FollowStatus.accepted);
      });

      test('throws ArgumentError for unknown value', () {
        expect(() => FollowStatus.fromString('unknown'), throwsArgumentError);
      });
    });
  });

  group('Follow', () {
    test('constructs with required fields', () {
      final follow = createFollow();

      expect(follow.id, 'follow-1');
      expect(follow.followerId, 'user-1');
      expect(follow.followingId, 'user-2');
      expect(follow.status, FollowStatus.accepted);
      expect(follow.createdAt, tCreatedAt);
      expect(follow.updatedAt, tUpdatedAt);
    });

    test('constructs with pending status', () {
      final follow = createFollow(status: FollowStatus.pending);

      expect(follow.status, FollowStatus.pending);
    });

    group('copyWith', () {
      test('copies all fields when specified', () {
        final original = createFollow();
        final newCreatedAt = DateTime(2026, 3, 1);
        final newUpdatedAt = DateTime(2026, 3, 2);
        final copied = original.copyWith(
          id: 'follow-2',
          followerId: 'user-10',
          followingId: 'user-20',
          status: FollowStatus.pending,
          createdAt: newCreatedAt,
          updatedAt: newUpdatedAt,
        );

        expect(copied.id, 'follow-2');
        expect(copied.followerId, 'user-10');
        expect(copied.followingId, 'user-20');
        expect(copied.status, FollowStatus.pending);
        expect(copied.createdAt, newCreatedAt);
        expect(copied.updatedAt, newUpdatedAt);
      });

      test('retains original values when no arguments given', () {
        final original = createFollow();
        final copied = original.copyWith();

        expect(copied.id, original.id);
        expect(copied.followerId, original.followerId);
        expect(copied.followingId, original.followingId);
        expect(copied.status, original.status);
        expect(copied.createdAt, original.createdAt);
        expect(copied.updatedAt, original.updatedAt);
      });
    });

    group('equality', () {
      test('equal when all props match', () {
        final a = createFollow();
        final b = createFollow();
        expect(a, equals(b));
      });

      test('not equal when id differs', () {
        final a = createFollow(id: 'a');
        final b = createFollow(id: 'b');
        expect(a, isNot(equals(b)));
      });

      test('not equal when followerId differs', () {
        final a = createFollow(followerId: 'user-1');
        final b = createFollow(followerId: 'user-9');
        expect(a, isNot(equals(b)));
      });

      test('not equal when status differs', () {
        final a = createFollow(status: FollowStatus.pending);
        final b = createFollow(status: FollowStatus.accepted);
        expect(a, isNot(equals(b)));
      });

      test('not equal when createdAt differs', () {
        final a = createFollow(createdAt: DateTime(2026, 1, 1));
        final b = createFollow(createdAt: DateTime(2026, 2, 1));
        expect(a, isNot(equals(b)));
      });
    });
  });
}
