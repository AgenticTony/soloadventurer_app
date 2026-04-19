import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/enums/verification_status.dart';
import '../../domain/enums/verification_type.dart';

/// Remote data source for verification operations via Supabase
class VerificationRemoteDataSource {
  /// Creates a new [VerificationRemoteDataSource]
  VerificationRemoteDataSource();

  /// Get the Supabase client
  SupabaseClient get _client => Supabase.instance.client;

  /// Get the current user's verification record from user_verification table
  Future<Map<String, dynamic>?> getVerificationRecord() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _client
        .from('user_verification')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    return response;
  }

  /// Create a new verification record
  Future<Map<String, dynamic>> createVerificationRecord({
    required VerificationType type,
    required VerificationStatus status,
    String? imageUrl,
    String? documentFrontUrl,
    String? documentBackUrl,
    String? providerRef,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final data = <String, dynamic>{
      'user_id': userId,
      'verification_type': type.value,
      'status': status.value,
      if (imageUrl != null) 'selfie_url': imageUrl,
      if (documentFrontUrl != null) 'document_front_url': documentFrontUrl,
      if (documentBackUrl != null) 'document_back_url': documentBackUrl,
      if (providerRef != null) 'provider_ref': providerRef,
    };

    final response = await _client
        .from('user_verification')
        .upsert(data)
        .select()
        .single();

    return response;
  }

  /// Update an existing verification record
  Future<Map<String, dynamic>> updateVerificationRecord({
    required String recordId,
    VerificationStatus? status,
    String? imageUrl,
    String? documentFrontUrl,
    String? documentBackUrl,
    String? providerRef,
    String? failureReason,
  }) async {
    final data = <String, dynamic>{
      if (status != null) 'status': status.value,
      if (imageUrl != null) 'selfie_url': imageUrl,
      if (documentFrontUrl != null) 'document_front_url': documentFrontUrl,
      if (documentBackUrl != null) 'document_back_url': documentBackUrl,
      if (providerRef != null) 'provider_ref': providerRef,
      if (failureReason != null) 'failure_reason': failureReason,
    };

    final response = await _client
        .from('user_verification')
        .update(data)
        .eq('id', recordId)
        .select()
        .single();

    return response;
  }

  /// Get verification history for the current user
  Future<List<Map<String, dynamic>>> getVerificationHistory() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _client
        .from('user_verification')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Upload a verification image to Supabase Storage
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

  /// Delete a verification record
  Future<void> deleteVerificationRecord(String recordId) async {
    await _client
        .from('user_verification')
        .delete()
        .eq('id', recordId);
  }
}
