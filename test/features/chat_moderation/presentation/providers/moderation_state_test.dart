import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/chat_moderation/presentation/providers/moderation_providers.dart';
import 'package:soloadventurer/features/chat_moderation/domain/enums/moderation_enums.dart';
import 'package:soloadventurer/features/chat_moderation/domain/entities/moderation_flag.dart';

void main() {
  group('ModerationState', () {
    test('default state has no flags', () {
      const state = ModerationState();
      expect(state.flags, isEmpty);
      expect(state.revealedMessageIds, isEmpty);
      expect(state.deletedMessageIds, isEmpty);
    });

    test('isFlagged returns false when no flag exists', () {
      const state = ModerationState();
      expect(state.isFlagged('msg1'), isFalse);
    });

    test('isFlagged returns true for flagged message with high confidence', () {
      final flag = ModerationFlag(
        messageId: 'msg1',
        result: ModerationResult.flagged,
        confidence: 0.8,
        scannedAt: DateTime.now(),
      );
      final state = ModerationState(flags: {'msg1': flag});
      expect(state.isFlagged('msg1'), isTrue);
    });

    test('isFlagged returns false for clean message', () {
      final flag = ModerationFlag(
        messageId: 'msg1',
        result: ModerationResult.clean,
        confidence: 0.8,
        scannedAt: DateTime.now(),
      );
      final state = ModerationState(flags: {'msg1': flag});
      expect(state.isFlagged('msg1'), isFalse);
    });

    test('isRevealed tracks revealed messages', () {
      const state = ModerationState(revealedMessageIds: {'msg1'});
      expect(state.isRevealed('msg1'), isTrue);
      expect(state.isRevealed('msg2'), isFalse);
    });

    test('isDeleted tracks deleted messages', () {
      const state = ModerationState(deletedMessageIds: {'msg1'});
      expect(state.isDeleted('msg1'), isTrue);
      expect(state.isDeleted('msg2'), isFalse);
    });

    test('copyWith updates specified fields', () {
      const original = ModerationState();
      final updated = original.copyWith(
        revealedMessageIds: {'msg1'},
        deletedMessageIds: {'msg2'},
      );
      expect(updated.revealedMessageIds, contains('msg1'));
      expect(updated.deletedMessageIds, contains('msg2'));
      expect(updated.flags, isEmpty); // preserved
    });
  });
}
