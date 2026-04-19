import '../entities/privacy_settings.dart';
import '../entities/content_privacy_settings.dart';
import '../enums/verification_tier.dart';

/// Repository interface for privacy-related operations
abstract class PrivacyRepository {
  /// Get the current user's profile privacy settings
  Future<PrivacySettings> getProfilePrivacy();

  /// Update the current user's profile privacy settings
  Future<void> updateProfilePrivacy(PrivacySettings settings);

  /// Get the current user's content privacy settings
  Future<ContentPrivacySettings> getContentPrivacy();

  /// Update the current user's content privacy settings
  Future<void> updateContentPrivacy(ContentPrivacySettings settings);

  /// Get the current user's verification tier
  Future<VerificationTier> getVerificationTier();
}
