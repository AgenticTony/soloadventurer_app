import 'package:equatable/equatable.dart';
import '../enums/moderation_enums.dart';

/// Represents a moderation scan result for a message.
class ModerationFlag extends Equatable {
  /// ID of the message that was flagged
  final String messageId;

  /// Result of the scan
  final ModerationResult result;

  /// Severity if flagged
  final ModerationSeverity severity;

  /// Category of the flag
  final ModerationCategory category;

  /// AI confidence score (0.0 - 1.0)
  final double confidence;

  /// Reason text from the AI model
  final String? reason;

  /// When the scan was performed
  final DateTime scannedAt;

  /// Creates a new [ModerationFlag]
  const ModerationFlag({
    required this.messageId,
    this.result = ModerationResult.unknown,
    this.severity = ModerationSeverity.low,
    this.category = ModerationCategory.other,
    this.confidence = 0,
    this.reason,
    required this.scannedAt,
  });

  /// Whether this flag indicates the message should be shown with a warning
  bool get shouldShowOverlay =>
      result == ModerationResult.flagged &&
      confidence >= 0.6;

  @override
  List<Object?> get props => [
        messageId, result, severity, category,
        confidence, reason, scannedAt,
      ];
}
