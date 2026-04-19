import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/core/utils/json_helpers.dart';
import '../models/privacy_settings_model.dart';
import '../models/content_privacy_settings_model.dart';
import '../../domain/enums/profile_visibility.dart';
import '../../domain/enums/content_audience.dart';
import '../../domain/enums/comment_permission.dart';
import '../../domain/enums/verification_tier.dart';

/// Abstract interface for privacy remote data operations
abstract class PrivacyRemoteDataSource {
  /// Fetch profile privacy settings for the current user
  Future<PrivacySettingsModel> getProfilePrivacy();

  /// Update profile privacy settings
  Future<void> updateProfilePrivacy(PrivacySettingsModel model);

  /// Fetch content privacy settings for the current user
  Future<ContentPrivacySettingsModel> getContentPrivacy();

  /// Update content privacy settings
  Future<void> updateContentPrivacy(ContentPrivacySettingsModel model);

  /// Fetch the current user's verification tier
  Future<VerificationTier> getVerificationTier();
}

/// Supabase implementation of [PrivacyRemoteDataSource]
class PrivacyRemoteDataSourceImpl implements PrivacyRemoteDataSource {
  final SupabaseClient _client;

  /// Creates a new [PrivacyRemoteDataSourceImpl]
  PrivacyRemoteDataSourceImpl({required SupabaseClient client}) : _client = client;

  /// Get the current user's ID, throwing if not authenticated
  String get _currentUserId {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const UnauthorizedException(
        message: 'User must be authenticated for privacy operations',
      );
    }
    return userId;
  }

  @override
  Future<PrivacySettingsModel> getProfilePrivacy() async {
    try {
      final response = await _client
          .from('profile_privacy_settings')
          .select()
          .eq('user_id', _currentUserId)
          .maybeSingle();

      if (response == null) {
        // Return defaults if no settings row exists yet
        return PrivacySettingsModel(
          userId: _currentUserId,
          visibility: ProfileVisibility.community,
          verifiedOnly: false,
          showLocation: true,
          discoverableByDestination: true,
        );
      }
      return PrivacySettingsModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get profile privacy: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get profile privacy: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> updateProfilePrivacy(PrivacySettingsModel model) async {
    try {
      await _client
          .from('profile_privacy_settings')
          .upsert(model.toJson(), onConflict: 'user_id');
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to update profile privacy: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update profile privacy: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ContentPrivacySettingsModel> getContentPrivacy() async {
    try {
      final response = await _client
          .from('content_privacy_settings')
          .select()
          .eq('user_id', _currentUserId)
          .maybeSingle();

      if (response == null) {
        // Return defaults if no settings row exists yet
        return ContentPrivacySettingsModel(
          userId: _currentUserId,
          defaultPostAudience: ContentAudience.followers,
          allowCommentsFrom: CommentPermission.followers,
          allowReshares: false,
          includeInDestinationFeed: false,
        );
      }
      return ContentPrivacySettingsModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get content privacy: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get content privacy: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> updateContentPrivacy(ContentPrivacySettingsModel model) async {
    try {
      await _client
          .from('content_privacy_settings')
          .upsert(model.toJson(), onConflict: 'user_id');
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to update content privacy: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update content privacy: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<VerificationTier> getVerificationTier() async {
    try {
      final response = await _client
          .from('user_verification')
          .select('tier')
          .eq('user_id', _currentUserId)
          .maybeSingle();

      if (response == null) {
        return VerificationTier.unverified;
      }
      return VerificationTier.fromString(
        response['tier'] as String? ?? 'unverified',
      );
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get verification tier: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get verification tier: $e',
        statusCode: 500,
      );
    }
  }
}
