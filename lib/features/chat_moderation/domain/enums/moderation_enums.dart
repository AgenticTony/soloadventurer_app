/// Category a user assigns when reporting a chat message.
///
/// Stored (via its `name`) in `reports.details` and folded into the report
/// reason. `ModerationResult` / `ModerationSeverity` were deleted with the
/// background-scan half of this module (Story 0.7) — they described the output
/// of a `moderate-message` edge function that was never created. The Phase C
/// moderation-at-creation agent (FOUNDATIONS §9) defines its own types.
enum ModerationCategory {
  /// Harassment or bullying
  harassment,

  /// Hate speech
  hateSpeech,

  /// Sexual content
  sexual,

  /// Violence or threats
  violence,

  /// Spam or scams
  spam,

  /// Other / general
  other,
  ;

  /// Human-readable label
  String get label => switch (this) {
        harassment => 'Harassment',
        hateSpeech => 'Hate Speech',
        sexual => 'Sexual Content',
        violence => 'Violence',
        spam => 'Spam',
        other => 'Flagged Content',
      };
}
