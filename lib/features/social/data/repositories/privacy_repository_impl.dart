import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import '../../domain/entities/privacy_settings.dart';
import '../../domain/entities/content_privacy_settings.dart';
import '../../domain/enums/verification_tier.dart';
import '../../domain/repositories/privacy_repository.dart';
import '../datasources/privacy_remote_data_source.dart';
import '../models/privacy_settings_model.dart';
import '../models/content_privacy_settings_model.dart';

/// Implementation of [PrivacyRepository] using Supabase
class PrivacyRepositoryImpl implements PrivacyRepository {
  final PrivacyRemoteDataSource _remoteDataSource;

  /// Creates a new [PrivacyRepositoryImpl]
  PrivacyRepositoryImpl({required PrivacyRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  /// Get the current authenticated user's ID
  String get _currentUserId {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      throw const UnauthorizedException(
        message: 'User must be authenticated for privacy operations',
      );
    }
    return userId;
  }

  @override
  Future<PrivacySettings> getProfilePrivacy() async {
    final model = await _remoteDataSource.getProfilePrivacy();
    return model.toEntity();
  }

  @override
  Future<void> updateProfilePrivacy(PrivacySettings settings) async {
    final model = PrivacySettingsModel.fromEntity(_currentUserId, settings);
    await _remoteDataSource.updateProfilePrivacy(model);
  }

  @override
  Future<ContentPrivacySettings> getContentPrivacy() async {
    final model = await _remoteDataSource.getContentPrivacy();
    return model.toEntity();
  }

  @override
  Future<void> updateContentPrivacy(ContentPrivacySettings settings) async {
    final model =
        ContentPrivacySettingsModel.fromEntity(_currentUserId, settings);
    await _remoteDataSource.updateContentPrivacy(model);
  }

  @override
  Future<VerificationTier> getVerificationTier() async {
    // Trigger auth check
    _currentUserId;
    return _remoteDataSource.getVerificationTier();
  }
}
