/// Result of a message moderation scan.
enum ModerationResult {
  /// Message is clean, no action needed
  clean,

  /// Message may be inappropriate — show overlay to recipient
  flagged,

  /// Moderation scan timed out or failed — treat as clean
  unknown,
  ;

  static ModerationResult fromString(String? value) {
    if (value == null) return unknown;
    return ModerationResult.values.firstWhere(
      (r) => r.name == value.toLowerCase(),
      orElse: () => unknown,
    );
  }
}

/// Severity level for flagged messages.
enum ModerationSeverity {
  /// Potentially inappropriate but low confidence
  low,

  /// Likely inappropriate
  medium,

  /// High confidence inappropriate or explicit content
  high,
  ;

  static ModerationSeverity fromString(String? value) {
    if (value == null) return low;
    return ModerationSeverity.values.firstWhere(
      (s) => s.name == value.toLowerCase(),
      orElse: () => low,
    );
  }
}

/// Category of moderation flag.
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

  static ModerationCategory fromString(String? value) {
    if (value == null) return other;
    return ModerationCategory.values.firstWhere(
      (c) => c.name == value.toLowerCase(),
      orElse: () => other,
    );
  }

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
