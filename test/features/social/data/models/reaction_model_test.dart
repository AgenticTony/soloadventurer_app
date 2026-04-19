import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/data/models/reaction_model.dart';
import 'package:soloadventurer/features/social/domain/entities/reaction.dart';

void main() {
  const tId = 'reaction-123';
  const tUserId = 'user-abc';
  const tTargetId = 'journal-xyz';
  const tCreatedAt = '2026-04-01T12:00:00.000Z';

  group('ReactionModel', () {
    group('fromJson', () {
      test('parses a valid journal-like reaction JSON', () {
        final json = {
          'id': tId,
          'user_id': tUserId,
          'target_id': tTargetId,
          'target_type': 'journal',
          'reaction': 'like',
          'created_at': tCreatedAt,
        };

        final model = ReactionModel.fromJson(json);

        expect(model.id, tId);
        expect(model.userId, tUserId);
        expect(model.targetId, tTargetId);
        expect(model.targetType, ReactionTargetType.journal);
        expect(model.reaction, ReactionType.like);
        expect(model.createdAt, DateTime.parse(tCreatedAt));
      });

      test('parses all reaction types', () {
        for (final reaction in ['like', 'love', 'inspire', 'helpful']) {
          final json = {
            'id': tId,
            'user_id': tUserId,
            'target_id': tTargetId,
            'target_type': 'comment',
            'reaction': reaction,
            'created_at': tCreatedAt,
          };

          final model = ReactionModel.fromJson(json);
          expect(model.reaction, ReactionType.fromString(reaction));
        }
      });

      test('parses comment target type', () {
        final json = {
          'id': tId,
          'user_id': tUserId,
          'target_id': tTargetId,
          'target_type': 'comment',
          'reaction': 'love',
          'created_at': tCreatedAt,
        };

        final model = ReactionModel.fromJson(json);
        expect(model.targetType, ReactionTargetType.comment);
      });

      test('throws on invalid reaction type', () {
        final json = {
          'id': tId,
          'user_id': tUserId,
          'target_id': tTargetId,
          'target_type': 'journal',
          'reaction': 'invalid',
          'created_at': tCreatedAt,
        };

        expect(() => ReactionModel.fromJson(json), throwsArgumentError);
      });

      test('throws on invalid target type', () {
        final json = {
          'id': tId,
          'user_id': tUserId,
          'target_id': tTargetId,
          'target_type': 'invalid',
          'reaction': 'like',
          'created_at': tCreatedAt,
        };

        expect(() => ReactionModel.fromJson(json), throwsArgumentError);
      });
    });

    group('toJson', () {
      test('produces correct JSON map', () {
        final model = ReactionModel(
          id: tId,
          userId: tUserId,
          targetId: tTargetId,
          targetType: ReactionTargetType.journal,
          reaction: ReactionType.like,
          createdAt: DateTime.parse(tCreatedAt),
        );

        final json = model.toJson();

        expect(json['user_id'], tUserId);
        expect(json['target_id'], tTargetId);
        expect(json['target_type'], 'journal');
        expect(json['reaction'], 'like');
      });

      test('does not include id or created_at in output', () {
        final model = ReactionModel(
          id: tId,
          userId: tUserId,
          targetId: tTargetId,
          targetType: ReactionTargetType.comment,
          reaction: ReactionType.inspire,
          createdAt: DateTime.parse(tCreatedAt),
        );

        final json = model.toJson();

        expect(json.containsKey('id'), isFalse);
        expect(json.containsKey('created_at'), isFalse);
      });

      test('serializes all reaction types correctly', () {
        final reactions = {
          ReactionType.like: 'like',
          ReactionType.love: 'love',
          ReactionType.inspire: 'inspire',
          ReactionType.helpful: 'helpful',
        };

        reactions.forEach((reaction, expected) {
          final model = ReactionModel(
            id: tId,
            userId: tUserId,
            targetId: tTargetId,
            targetType: ReactionTargetType.journal,
            reaction: reaction,
            createdAt: DateTime.parse(tCreatedAt),
          );

          expect(model.toJson()['reaction'], expected);
        });
      });
    });
  });
}
