import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/chat_moderation/domain/enums/moderation_enums.dart';
import 'package:soloadventurer/features/chat_moderation/domain/entities/moderation_flag.dart';
import 'package:soloadventurer/features/chat_moderation/domain/services/message_moderation_service.dart';

void main() {
  group('ModerationResult', () {
    test('has all values', () {
      expect(ModerationResult.values.length, 3);
      expect(ModerationResult.values, contains(ModerationResult.clean));
      expect(ModerationResult.values, contains(ModerationResult.flagged));
      expect(ModerationResult.values, contains(ModerationResult.unknown));
    });

    test('fromString parses correctly', () {
      expect(ModerationResult.fromString('clean'), ModerationResult.clean);
      expect(ModerationResult.fromString('flagged'), ModerationResult.flagged);
      expect(ModerationResult.fromString('unknown'), ModerationResult.unknown);
    });

    test('fromString returns unknown for null/invalid', () {
      expect(ModerationResult.fromString(null), ModerationResult.unknown);
      expect(ModerationResult.fromString('invalid'), ModerationResult.unknown);
    });
  });

  group('ModerationSeverity', () {
    test('has all values', () {
      expect(ModerationSeverity.values.length, 3);
    });

    test('fromString parses correctly', () {
      expect(ModerationSeverity.fromString('low'), ModerationSeverity.low);
      expect(
          ModerationSeverity.fromString('medium'), ModerationSeverity.medium);
      expect(ModerationSeverity.fromString('high'), ModerationSeverity.high);
    });

    test('fromString returns low for null', () {
      expect(ModerationSeverity.fromString(null), ModerationSeverity.low);
    });
  });

  group('ModerationCategory', () {
    test('has all values', () {
      expect(ModerationCategory.values.length, 6);
    });

    test('labels are correct', () {
      expect(ModerationCategory.harassment.label, 'Harassment');
      expect(ModerationCategory.hateSpeech.label, 'Hate Speech');
      expect(ModerationCategory.sexual.label, 'Sexual Content');
      expect(ModerationCategory.violence.label, 'Violence');
      expect(ModerationCategory.spam.label, 'Spam');
      expect(ModerationCategory.other.label, 'Flagged Content');
    });

    test('fromString parses correctly', () {
      expect(ModerationCategory.fromString('harassment'),
          ModerationCategory.harassment);
      expect(ModerationCategory.fromString(null), ModerationCategory.other);
    });
  });

  group('ModerationFlag', () {
    test('default flag is unknown', () {
      final flag = ModerationFlag(
        messageId: 'msg1',
        scannedAt: DateTime.now(),
      );
      expect(flag.result, ModerationResult.unknown);
      expect(flag.severity, ModerationSeverity.low);
      expect(flag.confidence, 0);
    });

    test('shouldShowOverlay is true when flagged with high confidence', () {
      final flag = ModerationFlag(
        messageId: 'msg1',
        result: ModerationResult.flagged,
        confidence: 0.85,
        scannedAt: DateTime.now(),
      );
      expect(flag.shouldShowOverlay, isTrue);
    });

    test('shouldShowOverlay is false when confidence is low', () {
      final flag = ModerationFlag(
        messageId: 'msg1',
        result: ModerationResult.flagged,
        confidence: 0.3,
        scannedAt: DateTime.now(),
      );
      expect(flag.shouldShowOverlay, isFalse);
    });

    test('shouldShowOverlay is false when result is clean', () {
      final flag = ModerationFlag(
        messageId: 'msg1',
        result: ModerationResult.clean,
        confidence: 0.9,
        scannedAt: DateTime.now(),
      );
      expect(flag.shouldShowOverlay, isFalse);
    });

    test('shouldShowOverlay is false when result is unknown', () {
      final flag = ModerationFlag(
        messageId: 'msg1',
        result: ModerationResult.unknown,
        confidence: 0.9,
        scannedAt: DateTime.now(),
      );
      expect(flag.shouldShowOverlay, isFalse);
    });

    test('equality works correctly', () {
      final now = DateTime(2026, 1, 1);
      final flag1 = ModerationFlag(
        messageId: 'msg1',
        result: ModerationResult.flagged,
        confidence: 0.8,
        scannedAt: now,
      );
      final flag2 = ModerationFlag(
        messageId: 'msg1',
        result: ModerationResult.flagged,
        confidence: 0.8,
        scannedAt: now,
      );
      expect(flag1, equals(flag2));
    });

    test('timeout threshold is exactly 2 seconds', () {
      expect(MessageModerationService.timeoutDuration,
          const Duration(seconds: 2));
    });
  });
}
