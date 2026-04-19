/// Status of a verification request
enum VerificationStatus {
  /// Verification is pending submission
  pending,

  /// Verification is being processed
  processing,

  /// Verification was successful
  verified,

  /// Verification failed
  failed,

  /// Verification has expired and needs to be redone
  expired;

  /// Parse a [VerificationStatus] from a string value
  static VerificationStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return VerificationStatus.pending;
      case 'processing':
        return VerificationStatus.processing;
      case 'verified':
      case 'approved':
        return VerificationStatus.verified;
      case 'failed':
      case 'rejected':
        return VerificationStatus.failed;
      case 'expired':
        return VerificationStatus.expired;
      default:
        throw ArgumentError('Unknown VerificationStatus: $value');
    }
  }
}

/// Extension for serialization
extension VerificationStatusExtension on VerificationStatus {
  /// String representation for API serialization
  String get value {
    switch (this) {
      case VerificationStatus.pending:
        return 'pending';
      case VerificationStatus.processing:
        return 'processing';
      case VerificationStatus.verified:
        return 'verified';
      case VerificationStatus.failed:
        return 'failed';
      case VerificationStatus.expired:
        return 'expired';
    }
  }

  /// Whether this status represents a terminal state
  bool get isTerminal =>
      this == VerificationStatus.verified ||
      this == VerificationStatus.failed ||
      this == VerificationStatus.expired;

  /// Whether this status allows the user to retry
  bool get canRetry =>
      this == VerificationStatus.failed || this == VerificationStatus.expired;
}
