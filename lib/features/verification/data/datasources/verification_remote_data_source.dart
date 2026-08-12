import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/enums/verification_status.dart';
import '../../domain/enums/verification_type.dart';

/// Remote data source for verification operations via Supabase.
///
/// Talks to the `verification_records` table (gender/age/identity verifications
/// from Shufti Pro) and the `verify-with-shuftipro` edge function.
///
/// The older `user_verification` table (email/id_verified tier) is read-only
/// here via [getVerificationTierRecord] for backward compatibility.
class VerificationRemoteDataSource {
  /// Creates a new [VerificationRemoteDataSource]
  VerificationRemoteDataSource();

  /// Get the Supabase client
  SupabaseClient get _client => Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // verification_records table (Shufti Pro — gender/age/identity)
  // ---------------------------------------------------------------------------

  /// Get the current user's latest verification record from verification_records.
  Future<Map<String, dynamic>?> getVerificationRecord({
    String? verificationType,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    var query = _client
        .from('verification_records')
        .select()
        .eq('user_id', userId);

    if (verificationType != null) {
      query = query.eq('verification_type', verificationType);
    }

    final response = await query
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return response;
  }

  /// Create a new verification record in verification_records.
  Future<Map<String, dynamic>> createVerificationRecord({
    required String verificationType,
    String status = 'pending',
    String? providerReference,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final data = <String, dynamic>{
      'user_id': userId,
      'verification_type': verificationType,
      'status': status,
      if (providerReference != null) 'provider_reference': providerReference,
    };

    final response = await _client
        .from('verification_records')
        .insert(data)
        .select()
        .single();

    return response;
  }

  /// Update an existing verification record.
  Future<Map<String, dynamic>> updateVerificationRecord({
    required String recordId,
    String? status,
    String? providerReference,
    String? failureReason,
  }) async {
    final data = <String, dynamic>{
      if (status != null) 'status': status,
      if (providerReference != null) 'provider_reference': providerReference,
      if (failureReason != null) 'review_notes': failureReason,
    };

    final response = await _client
        .from('verification_records')
        .update(data)
        .eq('id', recordId)
        .select()
        .single();

    return response;
  }

  /// Get verification history for the current user.
  Future<List<Map<String, dynamic>>> getVerificationHistory() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _client
        .from('verification_records')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // ---------------------------------------------------------------------------
  // Edge Function call (verify-with-shuftipro)
  // ---------------------------------------------------------------------------

  /// Call the verify-with-shuftipro edge function to submit a verification
  /// with document images (Mode C). The edge function forwards them to Shufti,
  /// which runs OCR + face match + liveness and returns the result synchronously.
  ///
  /// [documentFrontBase64] — base64-encoded front of the ID document
  /// [selfieBase64] — base64-encoded selfie/live photo
  /// [documentBackBase64] — optional base64-encoded back of the ID
  ///
  /// Returns the function's JSON response with status + verified_gender.
  Future<Map<String, dynamic>> submitShuftiVerification({
    required String verificationType,
    required String documentFrontBase64,
    required String selfieBase64,
    String? documentBackBase64,
    String country = 'GB',
  }) async {
    final response = await _client.functions.invoke(
      'verify-with-shuftipro',
      body: {
        'verification_type': verificationType,
        'document_front': documentFrontBase64,
        'selfie': selfieBase64,
        if (documentBackBase64 != null) 'document_back': documentBackBase64,
        'country': country,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  /// Call the verify-with-shuftipro edge function to poll the status of an
  /// existing Shufti verification (Mode A). Used when the initial submit
  /// returned "pending" and we need to check again later.
  Future<Map<String, dynamic>> pollShuftiVerification({
    required String verificationType,
    required String shuftiReference,
  }) async {
    final response = await _client.functions.invoke(
      'verify-with-shuftipro',
      body: {
        'verification_type': verificationType,
        'shufti_reference': shuftiReference,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // user_verification table (legacy tier — email/id_verified)
  // ---------------------------------------------------------------------------

  /// Get the current user's tier record from user_verification (legacy).
  Future<Map<String, dynamic>?> getVerificationTierRecord() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _client
        .from('user_verification')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    return response;
  }

  // ---------------------------------------------------------------------------
  // Storage
  // ---------------------------------------------------------------------------

  /// Upload a verification image to Supabase Storage.
  Future<String> uploadVerificationImage(String filePath, String fileName) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final storagePath = 'verifications/$userId/$fileName';

    final file = File(filePath);
    await _client.storage
        .from('verification-images')
        .upload(storagePath, file, fileOptions: const FileOptions(upsert: true));

    final url = _client.storage
        .from('verification-images')
        .getPublicUrl(storagePath);

    return url;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Map domain VerificationType to the DB verification_type value.
  /// For women-only mode, governmentId maps to 'gender' (that's what we verify).
  String dbVerificationType(VerificationType type) {
    switch (type) {
      case VerificationType.governmentId:
        return 'gender'; // ID verification for women-only mode = gender check
      case VerificationType.photo:
        return 'identity'; // photo/selfie = identity check
    }
  }

  /// Map DB status to domain VerificationStatus.
  static VerificationStatus mapStatus(String? dbStatus) {
    if (dbStatus == null) return VerificationStatus.pending;
    return VerificationStatus.fromString(dbStatus);
  }
}
