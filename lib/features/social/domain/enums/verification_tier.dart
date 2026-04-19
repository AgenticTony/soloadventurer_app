/// Verification tier for user accounts
enum VerificationTier {
  /// No verification completed
  unverified,

  /// Email address verified
  emailVerified,

  /// Government ID verified
  idVerified;

  /// Parse a [VerificationTier] from a string value
  static VerificationTier fromString(String value) {
    switch (value.toLowerCase()) {
      case 'unverified':
        return VerificationTier.unverified;
      case 'email':
      case 'email_verified':
        return VerificationTier.emailVerified;
      case 'id_verified':
        return VerificationTier.idVerified;
      default:
        throw ArgumentError('Unknown VerificationTier: $value');
    }
  }
}

/// Extension for serialization
extension VerificationTierExtension on VerificationTier {
  /// String representation for API serialization
  String get value {
    switch (this) {
      case VerificationTier.unverified:
        return 'unverified';
      case VerificationTier.emailVerified:
        return 'email';
      case VerificationTier.idVerified:
        return 'id_verified';
    }
  }
}
