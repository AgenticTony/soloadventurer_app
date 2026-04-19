import '../../domain/entities/verification_request.dart';
import '../../domain/enums/verification_status.dart';
import '../../domain/enums/verification_type.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/verification_remote_data_source.dart';
import 'package:soloadventurer/features/social/domain/enums/verification_tier.dart';

/// Implementation of [VerificationRepository] using Supabase
class VerificationRepositoryImpl implements VerificationRepository {
  final VerificationRemoteDataSource _remoteDataSource;

  /// Creates a new [VerificationRepositoryImpl]
  VerificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<VerificationTier> getVerificationTier() async {
    final record = await _remoteDataSource.getVerificationRecord();
    if (record == null) return VerificationTier.unverified;

    final status = record['status'] as String?;
    if (status == null) return VerificationTier.unverified;

    final type = record['verification_type'] as String?;

    // ID verified takes precedence over photo verified
    if (status == 'verified' || status == 'approved') {
      if (type == 'government_id') return VerificationTier.idVerified;
      return VerificationTier.emailVerified;
    }

    return VerificationTier.unverified;
  }

  @override
  Future<VerificationRequest> submitPhotoVerification(String imagePath) async {
    // Upload the selfie image
    final imageUrl = await _remoteDataSource.uploadVerificationImage(
      imagePath,
      'selfie_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    // Create the verification record
    final record = await _remoteDataSource.createVerificationRecord(
      type: VerificationType.photo,
      status: VerificationStatus.processing,
      imageUrl: imageUrl,
    );

    // Simulate processing (in production, this would call an Edge Function)
    await _simulateVerificationProcessing(record['id'] as String);

    return _mapToVerificationRequest(record);
  }

  @override
  Future<VerificationRequest> submitIdVerification({
    required String frontImagePath,
    String? backImagePath,
  }) async {
    // Upload the ID images
    final frontUrl = await _remoteDataSource.uploadVerificationImage(
      frontImagePath,
      'id_front_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    String? backUrl;
    if (backImagePath != null) {
      backUrl = await _remoteDataSource.uploadVerificationImage(
        backImagePath,
        'id_back_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    }

    // Create the verification record
    final record = await _remoteDataSource.createVerificationRecord(
      type: VerificationType.governmentId,
      status: VerificationStatus.processing,
      documentFrontUrl: frontUrl,
      documentBackUrl: backUrl,
    );

    // Simulate processing
    await _simulateVerificationProcessing(record['id'] as String);

    return _mapToVerificationRequest(record);
  }

  @override
  Future<VerificationRequest> getVerificationStatus(String requestId) async {
    // For now, we fetch from history and find by ID
    final history = await _remoteDataSource.getVerificationHistory();
    final record = history.firstWhere(
      (r) => r['id'] == requestId,
      orElse: () => throw Exception('Verification request not found'),
    );
    return _mapToVerificationRequest(record);
  }

  @override
  Future<List<VerificationRequest>> getVerificationHistory() async {
    final records = await _remoteDataSource.getVerificationHistory();
    return records.map(_mapToVerificationRequest).toList();
  }

  @override
  Future<bool> hasPendingVerification(VerificationType type) async {
    final history = await _remoteDataSource.getVerificationHistory();
    return history.any((r) =>
        r['verification_type'] == type.value &&
        (r['status'] == 'pending' || r['status'] == 'processing'));
  }

  @override
  Future<void> cancelVerification(String requestId) async {
    await _remoteDataSource.updateVerificationRecord(
      recordId: requestId,
      status: VerificationStatus.failed,
      failureReason: 'Cancelled by user',
    );
  }

  /// Simulate verification processing.
  // TODO(SPRINT-7): Replace with Supabase Edge Function call for real AI face comparison.
  // The simulation always approves — production needs Onfido/Stripe Identity SDK.
  Future<void> _simulateVerificationProcessing(String recordId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Mark as verified (in production, AI would do the comparison)
    await _remoteDataSource.updateVerificationRecord(
      recordId: recordId,
      status: VerificationStatus.verified,
    );
  }

  /// Map a Supabase record to a VerificationRequest entity
  VerificationRequest _mapToVerificationRequest(Map<String, dynamic> record) {
    return VerificationRequest(
      id: record['id'] as String,
      userId: record['user_id'] as String,
      type: VerificationType.fromString(record['verification_type'] as String? ?? 'photo'),
      status: VerificationStatus.fromString(record['status'] as String? ?? 'pending'),
      imageUrl: record['selfie_url'] as String?,
      documentFrontUrl: record['document_front_url'] as String?,
      documentBackUrl: record['document_back_url'] as String?,
      providerRef: record['provider_ref'] as String?,
      failureReason: record['failure_reason'] as String?,
      createdAt: DateTime.parse(record['created_at'] as String),
      updatedAt: record['updated_at'] != null
          ? DateTime.parse(record['updated_at'] as String)
          : null,
      expiresAt: record['expires_at'] != null
          ? DateTime.parse(record['expires_at'] as String)
          : null,
    );
  }
}
