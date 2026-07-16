import 'package:supabase_flutter/supabase_flutter.dart';

import '../enums/moderation_enums.dart';

/// Persists a user's report of a chat message into the existing `reports`
/// table (`target_type = 'message'`).
///
/// **History (Story 0.7):** the previous `MessageModerationService` wrote to a
/// `message_reports` table that was never created — reports silently went
/// nowhere. The generic `reports` table (with live RLS: insert-own, read-own)
/// has supported `target_type = 'message'` since its first migration, so the
/// fix is a repoint, not a new table. Its background-scan half (`scanMessage` /
/// `getFlagStatus`, calling a `moderate-message` edge function that was also
/// never created) was deleted: FOUNDATIONS §9 places moderation-at-creation in
/// Phase C, and it will be rebuilt from that design, not from this scaffold.
///
/// A report is L0 signal — an input to the reward function (FOUNDATIONS §4:
/// `− block / report / flag`), so failures must surface, never be swallowed.
class MessageReportService {
  /// `reports.reason` carries a `CHECK (char_length BETWEEN 10 AND 1000)`.
  static const int minReasonLength = 10;
  static const int maxReasonLength = 1000;

  final SupabaseClient _client;

  MessageReportService(this._client);

  /// Files a report against a message. Throws on failure — reporting is a
  /// safety control, and the caller must be able to tell the user the truth
  /// about whether it worked.
  ///
  /// [messageId] must be the **server** id of the message row; a local-only
  /// id would produce a report pointing at nothing.
  Future<void> reportMessage({
    required String messageId,
    required String reporterId,
    required ModerationCategory category,
    String? note,
  }) async {
    final reason = _buildReason(category, note);

    await _client.from('reports').insert({
      'reporter_id': reporterId,
      'target_id': messageId,
      'target_type': 'message',
      'reason': reason,
      if (note != null && note.trim().isNotEmpty) 'details': note.trim(),
    });
  }

  /// Builds a reason string that always satisfies the DB length constraint,
  /// so a short user note cannot turn into an opaque constraint violation.
  static String _buildReason(ModerationCategory category, String? note) {
    final base = 'Chat message reported: ${category.label}';
    final trimmed = note?.trim() ?? '';
    final full = trimmed.isEmpty ? base : '$base — $trimmed';
    return full.length <= maxReasonLength
        ? full
        : full.substring(0, maxReasonLength);
  }
}
