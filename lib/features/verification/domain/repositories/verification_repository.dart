import '../entities/verification_request.dart';
import '../enums/verification_type.dart';
import '../../../../features/social/domain/enums/verification_tier.dart';

/// Repository interface for verification operations
abstract class VerificationRepository {
  /// Get the current user's verification tier
  Future<VerificationTier> getVerificationTier();

  /// Submit an identity verification: a government ID document plus a selfie.
  ///
  /// Both are required in a single submission. The document alone proves the
  /// document is genuine; the selfie is what binds it to the person holding it.
  /// For the women-only gate that binding is the load-bearing part, so the
  /// provider must receive them together.
  ///
  /// [type] selects what is being asserted (see [VerificationType]).
  /// [documentFrontPath] and the optional [documentBackPath] are on-device file
  /// paths from the document capture step; [selfiePath] is the live photo.
  /// [country] is the ISO-3166 alpha-2 code of the issuing country.
  ///
  /// Throws if a file cannot be read or the provider rejects the submission.
  Future<VerificationRequest> submitIdentityVerification({
    required VerificationType type,
    required String documentFrontPath,
    String? documentBackPath,
    required String selfiePath,
    String country = 'GB',
  });

  /// Re-check a submission that came back still processing.
  ///
  /// [providerReference] is the reference returned by
  /// [submitIdentityVerification]. Safe to call repeatedly — the backend
  /// processes each result idempotently.
  Future<VerificationRequest> pollVerification({
    required VerificationType type,
    required String providerReference,
  });

  /// Get the status of a verification request
  Future<VerificationRequest> getVerificationStatus(String requestId);

  /// Get all verification requests for the current user
  Future<List<VerificationRequest>> getVerificationHistory();

  /// Check if the user has a pending verification
  Future<bool> hasPendingVerification(VerificationType type);

  /// Cancel a pending verification request
  Future<void> cancelVerification(String requestId);
}
