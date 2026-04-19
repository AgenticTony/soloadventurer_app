import '../entities/verification_request.dart';
import '../enums/verification_type.dart';
import '../../../../features/social/domain/enums/verification_tier.dart';

/// Repository interface for verification operations
abstract class VerificationRepository {
  /// Get the current user's verification tier
  Future<VerificationTier> getVerificationTier();

  /// Submit a photo verification request
  Future<VerificationRequest> submitPhotoVerification(String imagePath);

  /// Submit a government ID verification request
  Future<VerificationRequest> submitIdVerification({
    required String frontImagePath,
    String? backImagePath,
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
