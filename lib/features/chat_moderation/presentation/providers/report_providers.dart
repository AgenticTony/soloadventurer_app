import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/enums/moderation_enums.dart';
import '../../domain/services/message_report_service.dart';

/// Provider for the [MessageReportService].
final messageReportServiceProvider = Provider<MessageReportService>((ref) {
  return MessageReportService(Supabase.instance.client);
});

/// Message ids (server ids) the current user has reported this session.
///
/// Used to hide reported messages from the reporter's own view and to prevent
/// duplicate reports of the same message. Session-scoped by design: the report
/// itself is durable in the `reports` table.
class ReportedMessagesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  /// Reports [messageId] and, on success, hides it locally.
  ///
  /// Rethrows on failure — the UI must tell the user whether the report
  /// actually landed (Story 0.7: the old path swallowed errors while writing
  /// to a table that did not exist).
  Future<void> report({
    required String messageId,
    required String reporterId,
    required ModerationCategory category,
    String? note,
  }) async {
    if (state.contains(messageId)) return; // already reported this session

    await ref.read(messageReportServiceProvider).reportMessage(
          messageId: messageId,
          reporterId: reporterId,
          category: category,
          note: note,
        );

    state = {...state, messageId};
  }

  bool isReported(String messageId) => state.contains(messageId);
}

/// Provider exposing the set of reported (locally hidden) message ids.
final reportedMessagesProvider =
    NotifierProvider<ReportedMessagesNotifier, Set<String>>(
  ReportedMessagesNotifier.new,
);
