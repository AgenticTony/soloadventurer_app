/// Type of verification being performed
enum VerificationType {
  /// Photo/selfie verification
  photo,

  /// Government ID verification
  governmentId;

  /// Parse a [VerificationType] from a string value
  static VerificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'photo':
      case 'selfie':
        return VerificationType.photo;
      case 'government_id':
      case 'id':
      case 'governmentid':
        return VerificationType.governmentId;
      default:
        throw ArgumentError('Unknown VerificationType: $value');
    }
  }
}

/// Extension for serialization
extension VerificationTypeExtension on VerificationType {
  /// String representation for API serialization
  String get value {
    switch (this) {
      case VerificationType.photo:
        return 'photo';
      case VerificationType.governmentId:
        return 'government_id';
    }
  }

  /// Human-readable label
  String get label {
    switch (this) {
      case VerificationType.photo:
        return 'Photo Verification';
      case VerificationType.governmentId:
        return 'ID Verification';
    }
  }
}
