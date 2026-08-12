import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/verification_request.dart';
import '../../domain/enums/verification_type.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/verification_remote_data_source.dart';
import 'package:soloadventurer/features/social/domain/enums/verification_tier.dart';

/// Implementation of [VerificationRepository] using Supabase + Shufti Pro.
///
/// The verification flow:
///   1. The Flutter app runs the Shufti SDK (onsite document capture + selfie).
///   2. The SDK returns a Shufti `reference`.
///   3. This repository calls the `verify-with-shuftipro` edge function with
///      that reference.
///   4. The edge function fetches the result from Shufti, verifies the
///      signature, writes to `verification_records`, and sets
///      `profiles.gender_verified = true` for approved female verifications.
///
/// The Shufti SDK call itself happens in the presentation layer (the SDK
/// provides its own UI). This repository handles the backend confirmation.
class VerificationRepositoryImpl implements VerificationRepository {
  final VerificationRemoteDataSource _remoteDataSource;

  /// Creates a new [VerificationRepositoryImpl]
  VerificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<VerificationTier> getVerificationTier() async {
    // Check the Shufti verification_records table for a gender/identity approval
    final record = await _remoteDataSource.getVerificationRecord();
    if (record != null) {
      final status = record['status'] as String?;
      if (status == 'approved') {
        return VerificationTier.idVerified;
      }
    }

    // Fall back to the legacy user_verification table
    final tierRecord = await _remoteDataSource.getVerificationTierRecord();
    if (tierRecord != null) {
      final tier = tierRecord['tier'] as String?;
      if (tier == 'id_verified') return VerificationTier.idVerified;
      if (tier == 'email') return VerificationTier.emailVerified;
    }

    return VerificationTier.unverified;
  }

  /// Submit a Shufti verification with document images.
  ///
  /// The Flutter app captures photos via `image_picker`, converts them to
  /// base64, and passes them here. The edge function forwards them to Shufti
  /// which runs OCR + face match and returns the result.
  ///
  /// For approved female gender verifications, the edge function sets
  /// `profiles.gender_verified = true` (unlocking women-only mode).
  Future<VerificationRequest> submitShuftiVerification({
    required VerificationType type,
    required String documentFrontBase64,
    required String selfieBase64,
    String? documentBackBase64,
    String country = 'GB',
  }) async {
    final dbType = _remoteDataSource.dbVerificationType(type);

    final result = await _remoteDataSource.submitShuftiVerification(
      verificationType: dbType,
      documentFrontBase64: documentFrontBase64,
      selfieBase64: selfieBase64,
      documentBackBase64: documentBackBase64,
      country: country,
    );

    final success = result['success'] as bool? ?? false;
    if (!success) {
      throw Exception(result['error'] ?? 'Verification failed');
    }

    final status = result['status'] as String? ?? 'pending';
    final shuftiReference = result['shufti_reference'] as String? ?? '';

    // Fetch the record the edge function created
    final record = await _remoteDataSource.getVerificationRecord(
      verificationType: dbType,
    );

    if (record == null) {
      return VerificationRequest(
        id: result['verification_id'] as String? ?? shuftiReference,
        userId: Supabase.instance.client.auth.currentUser?.id ?? '',
        type: type,
        status: VerificationRemoteDataSource.mapStatus(status),
        providerRef: shuftiReference,
        createdAt: DateTime.now(),
      );
    }

    return _mapToVerificationRequest(record, type);
  }

  /// Poll the status of an existing Shufti verification.
  ///
  /// Used when the initial submit returned "pending" (Shufti is still
  /// processing). Call this every ~3 seconds until status is terminal.
  Future<VerificationRequest> pollShuftiVerification({
    required VerificationType type,
    required String shuftiReference,
  }) async {
    final dbType = _remoteDataSource.dbVerificationType(type);

    final result = await _remoteDataSource.pollShuftiVerification(
      verificationType: dbType,
      shuftiReference: shuftiReference,
    );

    final success = result['success'] as bool? ?? false;
    if (!success) {
      throw Exception(result['error'] ?? 'Verification failed');
    }

    final record = await _remoteDataSource.getVerificationRecord(
      verificationType: dbType,
    );

    if (record == null) {
      return VerificationRequest(
        id: result['verification_id'] as String? ?? shuftiReference,
        userId: Supabase.instance.client.auth.currentUser?.id ?? '',
        type: type,
        status: VerificationRemoteDataSource.mapStatus(
          result['status'] as String?,
        ),
        providerRef: shuftiReference,
        createdAt: DateTime.now(),
      );
    }

    return _mapToVerificationRequest(record, type);
  }

  @override
  Future<VerificationRequest> submitPhotoVerification(String imagePath) async {
    // Photo verification now goes through Shufti's face verification service.
    // The SDK call happens in the presentation layer; this method is kept
    // for backward compatibility but delegates to confirmShuftiVerification.
    //
    // In practice, the presentation layer should call the Shufti SDK directly
    // and then call confirmShuftiVerification. This method is a fallback.
    throw UnimplementedError(
      'Photo verification now uses the Shufti SDK. Call confirmShuftiVerification '
      'with the SDK reference instead.',
    );
  }

  @override
  Future<VerificationRequest> submitIdVerification({
    required String frontImagePath,
    String? backImagePath,
  }) async {
    // ID verification now goes through Shufti's document verification service.
    // Same as submitPhotoVerification — the SDK handles capture.
    throw UnimplementedError(
      'ID verification now uses the Shufti SDK. Call confirmShuftiVerification '
      'with the SDK reference instead.',
    );
  }

  @override
  Future<VerificationRequest> getVerificationStatus(String requestId) async {
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
    return records.map((r) => _mapToVerificationRequest(r)).toList();
  }

  @override
  Future<bool> hasPendingVerification(VerificationType type) async {
    final dbType = _remoteDataSource.dbVerificationType(type);
    final history = await _remoteDataSource.getVerificationHistory();
    return history.any((r) =>
        r['verification_type'] == dbType &&
        (r['status'] == 'pending' || r['status'] == 'in_review'));
  }

  @override
  Future<void> cancelVerification(String requestId) async {
    await _remoteDataSource.updateVerificationRecord(
      recordId: requestId,
      status: 'declined',
      failureReason: 'Cancelled by user',
    );
  }

  /// Map a Supabase verification_records row to a VerificationRequest entity.
  VerificationRequest _mapToVerificationRequest(
    Map<String, dynamic> record, [
    VerificationType? fallbackType,
  ]) {
    final dbType = record['verification_type'] as String?;
    final type = dbType == 'gender'
        ? VerificationType.governmentId
        : dbType == 'identity'
            ? VerificationType.photo
            : fallbackType ?? VerificationType.photo;

    return VerificationRequest(
      id: record['id'] as String,
      userId: record['user_id'] as String,
      type: type,
      status: VerificationRemoteDataSource.mapStatus(
        record['status'] as String?,
      ),
      providerRef: record['provider_reference'] as String?,
      failureReason: record['review_notes'] as String?,
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
