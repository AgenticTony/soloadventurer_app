import 'dart:async';
import '../entities/moderation_flag.dart';
import '../enums/moderation_enums.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for scanning messages for inappropriate content.
///
/// **Architecture:** Message delivers immediately → this service scans
/// in the background → if flagged, the recipient sees an overlay.
///
/// **Fallback:** Hard 2-second timeout. If the Edge Function doesn't
/// respond, the message is treated as clean. Never block message delivery.
class MessageModerationService {
  /// Maximum time to wait for moderation response
  static const timeoutDuration = Duration(seconds: 2);

  /// Scans a message for inappropriate content.
  ///
  /// Returns a [ModerationFlag] indicating whether the message is clean,
  /// flagged, or unknown (timeout/error).
  ///
  /// This method NEVER throws — errors result in a clean/unknown result.
  Future<ModerationFlag> scanMessage({
    required String messageId,
    required String content,
    required String senderId,
    required String chatId,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Call the Supabase Edge Function for moderation
      // The Edge Function uses OpenAI moderation API
      final response = await Supabase.instance.client.functions.invoke(
        'moderate-message',
        body: {
          'message_id': messageId,
          'content': content,
          'sender_id': senderId,
          'chat_id': chatId,
        },
      ).timeout(timeoutDuration);

      stopwatch.stop();

      final data = response as Map<String, dynamic>?;

      if (data == null) {
        return ModerationFlag(
          messageId: messageId,
          result: ModerationResult.unknown,
          scannedAt: DateTime.now(),
        );
      }

      final flagged = data['flagged'] as bool? ?? false;

      if (!flagged) {
        return ModerationFlag(
          messageId: messageId,
          result: ModerationResult.clean,
          scannedAt: DateTime.now(),
        );
      }

      return ModerationFlag(
        messageId: messageId,
        result: ModerationResult.flagged,
        severity: ModerationSeverity.fromString(
          data['severity'] as String?,
        ),
        category: ModerationCategory.fromString(
          data['category'] as String?,
        ),
        confidence: (data['confidence'] as num?)?.toDouble() ?? 0.5,
        reason: data['reason'] as String?,
        scannedAt: DateTime.now(),
      );
    } on TimeoutException {
      // Hard timeout — treat as clean
      return ModerationFlag(
        messageId: messageId,
        result: ModerationResult.unknown,
        scannedAt: DateTime.now(),
      );
    } on Exception {
      // Any error — treat as clean, never block
      return ModerationFlag(
        messageId: messageId,
        result: ModerationResult.unknown,
        scannedAt: DateTime.now(),
      );
    }
  }

  /// Report a message for inappropriate content.
  ///
  /// Creates a report record in Supabase for admin review.
  Future<void> reportMessage({
    required String messageId,
    required String reporterId,
    required String reason,
    ModerationCategory? category,
  }) async {
    try {
      await Supabase.instance.client.from('message_reports').insert({
        'message_id': messageId,
        'reporter_id': reporterId,
        'reason': reason,
        'category': category?.name,
        'created_at': DateTime.now().toIso8601String(),
      });
    } on Exception {
      // Don't throw — reporting is best-effort
    }
  }

  /// Get the moderation status for a specific message.
  ///
  /// Used by the recipient's UI to check if a message was flagged.
  Future<ModerationFlag?> getFlagStatus(String messageId) async {
    try {
      final response = await Supabase.instance.client
          .from('message_moderation')
          .select()
          .eq('message_id', messageId)
          .maybeSingle();

      if (response == null) return null;

      return ModerationFlag(
        messageId: messageId,
        result: ModerationResult.fromString(
          response['result'] as String?,
        ),
        severity: ModerationSeverity.fromString(
          response['severity'] as String?,
        ),
        category: ModerationCategory.fromString(
          response['category'] as String?,
        ),
        confidence:
            (response['confidence'] as num?)?.toDouble() ?? 0,
        reason: response['reason'] as String?,
        scannedAt: DateTime.parse(
          response['scanned_at'] as String? ??
              DateTime.now().toIso8601String(),
        ),
      );
    } on Exception {
      return null;
    }
  }
}
