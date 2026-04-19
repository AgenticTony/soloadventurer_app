import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/social/data/models/follow_model.dart';
import 'package:soloadventurer/features/social/domain/entities/follow.dart';

void main() {
  const tId = 'follow-123';
  const tFollowerId = 'user-abc';
  const tFollowingId = 'user-xyz';
  const tCreatedAt = '2026-04-01T12:00:00.000Z';
  const tUpdatedAt = '2026-04-01T12:30:00.000Z';

  group('FollowModel', () {
    group('fromJson', () {
      test('parses an accepted follow relationship', () {
        final json = {
          'id': tId,
          'follower_id': tFollowerId,
          'following_id': tFollowingId,
          'status': 'accepted',
          'created_at': tCreatedAt,
          'updated_at': tUpdatedAt,
        };

        final model = FollowModel.fromJson(json);

        expect(model.id, tId);
        expect(model.followerId, tFollowerId);
        expect(model.followingId, tFollowingId);
        expect(model.status, FollowStatus.accepted);
        expect(model.createdAt, DateTime.parse(tCreatedAt));
        expect(model.updatedAt, DateTime.parse(tUpdatedAt));
      });

      test('parses a pending follow relationship', () {
        final json = {
          'id': tId,
          'follower_id': tFollowerId,
          'following_id': tFollowingId,
          'status': 'pending',
          'created_at': tCreatedAt,
          'updated_at': tUpdatedAt,
        };

        final model = FollowModel.fromJson(json);

        expect(model.status, FollowStatus.pending);
      });

      test('defaults to pending when status is null', () {
        final json = {
          'id': tId,
          'follower_id': tFollowerId,
          'following_id': tFollowingId,
          'created_at': tCreatedAt,
          'updated_at': tUpdatedAt,
        };

        final model = FollowModel.fromJson(json);

        expect(model.status, FollowStatus.pending);
      });

      test('throws ValidationException on self-follow', () {
        final json = {
          'id': tId,
          'follower_id': tFollowerId,
          'following_id': tFollowerId,
          'status': 'accepted',
          'created_at': tCreatedAt,
          'updated_at': tUpdatedAt,
        };

        expect(
          () => FollowModel.fromJson(json),
          throwsA(isA<ValidationException>()),
        );
      });

      test('uses empty string when follower_id is null', () {
        final json = {
          'id': tId,
          'follower_id': null,
          'following_id': tFollowingId,
          'status': 'accepted',
          'created_at': tCreatedAt,
          'updated_at': tUpdatedAt,
        };

        final model = FollowModel.fromJson(json);

        expect(model.followerId, '');
      });

      test('uses empty string when following_id is null', () {
        final json = {
          'id': tId,
          'follower_id': tFollowerId,
          'following_id': null,
          'status': 'accepted',
          'created_at': tCreatedAt,
          'updated_at': tUpdatedAt,
        };

        final model = FollowModel.fromJson(json);

        expect(model.followingId, '');
      });
    });

    group('toJson', () {
      test('produces correct JSON map', () {
        final model = FollowModel(
          id: tId,
          followerId: tFollowerId,
          followingId: tFollowingId,
          status: FollowStatus.accepted,
          createdAt: DateTime.parse(tCreatedAt),
          updatedAt: DateTime.parse(tUpdatedAt),
        );

        final json = model.toJson();

        expect(json['id'], tId);
        expect(json['follower_id'], tFollowerId);
        expect(json['following_id'], tFollowingId);
        expect(json['status'], 'accepted');
        expect(json['created_at'], DateTime.parse(tCreatedAt).toIso8601String());
        expect(json['updated_at'], DateTime.parse(tUpdatedAt).toIso8601String());
      });

      test('serializes pending status correctly', () {
        final model = FollowModel(
          id: tId,
          followerId: tFollowerId,
          followingId: tFollowingId,
          status: FollowStatus.pending,
          createdAt: DateTime.parse(tCreatedAt),
          updatedAt: DateTime.parse(tUpdatedAt),
        );

        expect(model.toJson()['status'], 'pending');
      });
    });

    group('toEntity', () {
      test('converts to Follow entity with matching fields', () {
        final model = FollowModel(
          id: tId,
          followerId: tFollowerId,
          followingId: tFollowingId,
          status: FollowStatus.accepted,
          createdAt: DateTime.parse(tCreatedAt),
          updatedAt: DateTime.parse(tUpdatedAt),
        );

        final entity = model.toEntity();

        expect(entity, isA<Follow>());
        expect(entity.id, tId);
        expect(entity.followerId, tFollowerId);
        expect(entity.followingId, tFollowingId);
        expect(entity.status, FollowStatus.accepted);
        expect(entity.createdAt, DateTime.parse(tCreatedAt));
        expect(entity.updatedAt, DateTime.parse(tUpdatedAt));
      });
    });

    group('fromEntity', () {
      test('creates model from a Follow entity', () {
        final entity = Follow(
          id: tId,
          followerId: tFollowerId,
          followingId: tFollowingId,
          status: FollowStatus.pending,
          createdAt: DateTime.parse(tCreatedAt),
          updatedAt: DateTime.parse(tUpdatedAt),
        );

        final model = FollowModel.fromEntity(entity);

        expect(model.id, tId);
        expect(model.followerId, tFollowerId);
        expect(model.followingId, tFollowingId);
        expect(model.status, FollowStatus.pending);
      });
    });

    group('copyWith', () {
      test('copies with new status', () {
        final original = FollowModel(
          id: tId,
          followerId: tFollowerId,
          followingId: tFollowingId,
          status: FollowStatus.pending,
          createdAt: DateTime.parse(tCreatedAt),
          updatedAt: DateTime.parse(tUpdatedAt),
        );

        final copied = original.copyWith(status: FollowStatus.accepted);

        expect(copied.id, tId);
        expect(copied.followerId, tFollowerId);
        expect(copied.followingId, tFollowingId);
        expect(copied.status, FollowStatus.accepted);
        expect(copied.createdAt, DateTime.parse(tCreatedAt));
        expect(copied.updatedAt, DateTime.parse(tUpdatedAt));
      });

      test('retains original values when no arguments provided', () {
        final original = FollowModel(
          id: tId,
          followerId: tFollowerId,
          followingId: tFollowingId,
          status: FollowStatus.pending,
          createdAt: DateTime.parse(tCreatedAt),
          updatedAt: DateTime.parse(tUpdatedAt),
        );

        final copied = original.copyWith();

        expect(copied.id, original.id);
        expect(copied.followerId, original.followerId);
        expect(copied.followingId, original.followingId);
        expect(copied.status, original.status);
      });
    });

    group('FollowStatus', () {
      test('has exactly 2 values', () {
        expect(FollowStatus.values, hasLength(2));
      });

      test('fromString parses accepted', () {
        expect(FollowStatus.fromString('accepted'), FollowStatus.accepted);
      });

      test('fromString parses pending', () {
        expect(FollowStatus.fromString('pending'), FollowStatus.pending);
      });

      test('fromString throws on unknown value', () {
        expect(() => FollowStatus.fromString('blocked'), throwsArgumentError);
      });
    });
  });
}
