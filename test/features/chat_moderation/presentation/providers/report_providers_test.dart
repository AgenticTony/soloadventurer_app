import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:soloadventurer/features/chat_moderation/domain/enums/moderation_enums.dart';
import 'package:soloadventurer/features/chat_moderation/domain/services/message_report_service.dart';
import 'package:soloadventurer/features/chat_moderation/presentation/providers/report_providers.dart';

class MockMessageReportService extends Mock implements MessageReportService {}

void main() {
  late MockMessageReportService service;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(ModerationCategory.other);
  });

  setUp(() {
    service = MockMessageReportService();
    container = ProviderContainer(
      overrides: [
        messageReportServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<void> report(String messageId) =>
      container.read(reportedMessagesProvider.notifier).report(
            messageId: messageId,
            reporterId: 'user-a',
            category: ModerationCategory.harassment,
          );

  void stubSuccess() {
    when(() => service.reportMessage(
          messageId: any(named: 'messageId'),
          reporterId: any(named: 'reporterId'),
          category: any(named: 'category'),
          note: any(named: 'note'),
        )).thenAnswer((_) async {});
  }

  group('ReportedMessagesNotifier', () {
    test('starts with nothing reported', () {
      expect(container.read(reportedMessagesProvider), isEmpty);
    });

    test('a successful report hides the message', () async {
      stubSuccess();

      await report('msg-1');

      expect(container.read(reportedMessagesProvider), {'msg-1'});
      expect(
        container.read(reportedMessagesProvider.notifier).isReported('msg-1'),
        isTrue,
      );
    });

    test('reporting the same message twice files only one report', () async {
      stubSuccess();

      await report('msg-1');
      await report('msg-1');

      verify(() => service.reportMessage(
            messageId: 'msg-1',
            reporterId: any(named: 'reporterId'),
            category: any(named: 'category'),
            note: any(named: 'note'),
          )).called(1);
    });

    test('distinct messages are reported independently', () async {
      stubSuccess();

      await report('msg-1');
      await report('msg-2');

      expect(container.read(reportedMessagesProvider), {'msg-1', 'msg-2'});
    });

    test('a failed report rethrows and does NOT hide the message', () async {
      // Story 0.7: the old path swallowed errors while writing to a phantom
      // table. Hiding the message on failure would recreate that lie in the
      // UI — the message must stay visible and the error must surface.
      when(() => service.reportMessage(
            messageId: any(named: 'messageId'),
            reporterId: any(named: 'reporterId'),
            category: any(named: 'category'),
            note: any(named: 'note'),
          )).thenThrow(Exception('network down'));

      await expectLater(report('msg-1'), throwsException);
      expect(container.read(reportedMessagesProvider), isEmpty);
      expect(
        container.read(reportedMessagesProvider.notifier).isReported('msg-1'),
        isFalse,
      );
    });

    test('a failure does not poison later attempts', () async {
      when(() => service.reportMessage(
            messageId: any(named: 'messageId'),
            reporterId: any(named: 'reporterId'),
            category: any(named: 'category'),
            note: any(named: 'note'),
          )).thenThrow(Exception('network down'));
      await expectLater(report('msg-1'), throwsException);

      stubSuccess();
      await report('msg-1');

      expect(container.read(reportedMessagesProvider), {'msg-1'});
    });
  });
}
