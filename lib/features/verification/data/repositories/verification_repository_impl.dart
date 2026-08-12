import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/verification_request.dart';
import '../../domain/enums/verification_type.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/verification_remote_data_source.dart';
import 'package:soloadventurer/features/social/domain/enums/verification_tier.dart';

/// Thrown when a captured verification image cannot be read from disk.
class VerificationImageException implements Exception {
  /// Human-readable description of what went wrong.
  final String message;

  /// Creates a new [VerificationImageException].
  VerificationImageException(this.message);

  @override
  String toString() => 'VerificationImageException: $message';
}

/// Implementation of [VerificationRepository] using Supabase + Shufti Pro.
///
/// The verification flow:
///   1. The app captures the ID document and a selfie via `image_picker`.
///   2. This repository base64-encodes both and calls the
///      `verify-with-shuftipro` edge function (Mode C).
///   3. The edge function submits them to Shufti, verifies the response
///      signature, writes to `verification_records`, and sets
///      `profiles.gender_verified = true` for approved verifications.
///
/// The app never holds Shufti credentials — the edge function talks to Shufti
/// server-to-server (FOUNDATIONS §2.4). The Flutter SDK was rejected because
/// its `dio ^4.0.4` pin conflicts with this project's `dio ^5.4.1`.
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

  @override
  Future<VerificationRequest> submitIdentityVerification({
    required VerificationType type,
    required String documentFrontPath,
    String? documentBackPath,
    required String selfiePath,
    String country = 'GB',
  }) async {
    final dbType = _remoteDataSource.dbVerificationType(type);

    final result = await _remoteDataSource.submitShuftiVerification(
      verificationType: dbType,
      documentFrontBase64: await _encodeImage(documentFrontPath),
      selfieBase64: await _encodeImage(selfiePath),
      documentBackBase64: documentBackPath == null
          ? null
          : await _encodeImage(documentBackPath),
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
        id: result['verification_id'] as String? ?? '',
        userId: Supabase.instance.client.auth.currentUser?.id ?? '',
        type: type,
        status: VerificationRemoteDataSource.mapStatus(status),
        providerRef: shuftiReference,
        createdAt: DateTime.now(),
      );
    }

    return _mapToVerificationRequest(record, type);
  }

  @override
  Future<VerificationRequest> pollVerification({
    required VerificationType type,
    required String providerReference,
  }) async {
    final dbType = _remoteDataSource.dbVerificationType(type);

    final result = await _remoteDataSource.pollShuftiVerification(
      verificationType: dbType,
      shuftiReference: providerReference,
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
        id: '',
        userId: Supabase.instance.client.auth.currentUser?.id ?? '',
        type: type,
        status: VerificationRemoteDataSource.mapStatus(
          result['status'] as String?,
        ),
        providerRef: providerReference,
        createdAt: DateTime.now(),
      );
    }

    return _mapToVerificationRequest(record, type);
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

  /// Read an on-device image and base64-encode it for the edge function.
  ///
  /// Throws [VerificationImageException] if the file is missing or empty, so a
  /// bad capture surfaces as a clear message rather than a provider-side
  /// rejection several seconds later.
  Future<String> _encodeImage(String path) async {
    final file = File(path);

    if (!await file.exists()) {
      throw VerificationImageException('Image file not found: $path');
    }

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw VerificationImageException('Image file is empty: $path');
    }

    return base64Encode(bytes);
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
