import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:soloadventurer/features/chat_moderation/domain/enums/moderation_enums.dart';
import 'package:soloadventurer/features/chat_moderation/domain/services/message_report_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockPostgrestQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockInsertBuilder extends Mock
    implements PostgrestFilterBuilder<dynamic> {}

void main() {
  late MockSupabaseClient client;
  late MockPostgrestQueryBuilder queryBuilder;
  late MockInsertBuilder insertBuilder;
  late MessageReportService service;

  setUp(() {
    client = MockSupabaseClient();
    queryBuilder = MockPostgrestQueryBuilder();
    insertBuilder = MockInsertBuilder();
    service = MessageReportService(client);

    // Builders implement Future, so mocktail requires thenAnswer over thenReturn.
    when(() => client.from(any())).thenAnswer((_) => queryBuilder);
    when(() => queryBuilder.insert(any())).thenAnswer((_) => insertBuilder);
    // Awaiting a PostgrestFilterBuilder drives its Future interface.
    when(() =>
            insertBuilder.then<dynamic>(any(), onError: any(named: 'onError')))
        .thenAnswer((invocation) {
      final onValue = invocation.positionalArguments.first as FutureOr<dynamic>
          Function(dynamic);
      return Future<dynamic>.sync(() => onValue(null));
    });
  });

  group('MessageReportService.reportMessage', () {
    test('writes to the reports table — not the phantom message_reports',
        () async {
      await service.reportMessage(
        messageId: 'msg-1',
        reporterId: 'user-a',
        category: ModerationCategory.harassment,
      );

      // Story 0.7: the old service targeted 'message_reports', which no
      // migration creates. This assertion fails on any wrong table name.
      verify(() => client.from('reports')).called(1);
      verifyNever(() => client.from('message_reports'));
    });

    test('payload has the reports shape: reporter, target, type, reason',
        () async {
      await service.reportMessage(
        messageId: 'msg-1',
        reporterId: 'user-a',
        category: ModerationCategory.spam,
      );

      final captured = verify(() => queryBuilder.insert(captureAny()))
          .captured
          .single as Map<String, dynamic>;
      expect(captured['reporter_id'], 'user-a');
      expect(captured['target_id'], 'msg-1');
      expect(captured['target_type'], 'message');
      expect(captured['reason'], 'Chat message reported: Spam');
      expect(captured.containsKey('details'), isFalse,
          reason: 'no note given — details must be omitted, not null');
    });

    test('a user note is folded into reason and stored as details', () async {
      await service.reportMessage(
        messageId: 'msg-1',
        reporterId: 'user-a',
        category: ModerationCategory.violence,
        note: '  threatened me  ',
      );

      final captured = verify(() => queryBuilder.insert(captureAny()))
          .captured
          .single as Map<String, dynamic>;
      expect(captured['reason'],
          'Chat message reported: Violence — threatened me');
      expect(captured['details'], 'threatened me');
    });

    test('reason always satisfies the 10..1000 char DB constraint', () async {
      // Shortest possible input: every category label still yields >= 10.
      for (final category in ModerationCategory.values) {
        await service.reportMessage(
          messageId: 'msg-1',
          reporterId: 'user-a',
          category: category,
        );
      }
      final reasons = verify(() => queryBuilder.insert(captureAny()))
          .captured
          .map((c) => (c as Map<String, dynamic>)['reason'] as String);
      for (final reason in reasons) {
        expect(reason.length,
            greaterThanOrEqualTo(MessageReportService.minReasonLength));
        expect(reason.length,
            lessThanOrEqualTo(MessageReportService.maxReasonLength));
      }
    });

    test('an oversized note is truncated to the 1000-char reason limit',
        () async {
      await service.reportMessage(
        messageId: 'msg-1',
        reporterId: 'user-a',
        category: ModerationCategory.other,
        note: 'x' * 2000,
      );

      final captured = verify(() => queryBuilder.insert(captureAny()))
          .captured
          .single as Map<String, dynamic>;
      expect((captured['reason'] as String).length,
          MessageReportService.maxReasonLength);
    });

    test('failures propagate — reporting must never fail silently', () async {
      // Story 0.7: the old implementation swallowed exceptions ("best-effort")
      // while writing to a table that did not exist, so every report failed
      // silently. The contract now is: throw, and let the UI tell the truth.
      when(() => client.from('reports')).thenThrow(
        const PostgrestException(message: 'insert denied'),
      );

      expect(
        () => service.reportMessage(
          messageId: 'msg-1',
          reporterId: 'user-a',
          category: ModerationCategory.harassment,
        ),
        throwsA(isA<PostgrestException>()),
      );
    });
  });
}
