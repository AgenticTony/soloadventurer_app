import '../entities/profile.dart';
import 'package:soloadventurer/features/offline/data/repositories/offline_aware_repository.dart';

/// Repository interface for profile-related operations with offline-first support
abstract class ProfileRepository {
  /// Create a new profile
  ///
  /// Returns a [RepositoryOperationResult] indicating whether the operation
  /// was executed immediately or queued for sync.
  Future<RepositoryOperationResult<Profile>> createProfile(Profile profile);

  /// Get the profile for the given user ID
  ///
  /// This will read from local cache first, and fetch from remote if needed.
  Future<Profile> getProfile(String userId);

  /// Get the current user's profile
  ///
  /// This will read from local cache first, and fetch from remote if needed.
  Future<Profile> getCurrentProfile();

  /// Update the profile with the given data
  ///
  /// Returns a [RepositoryOperationResult] indicating whether the operation
  /// was executed immediately or queued for sync.
  Future<RepositoryOperationResult<Profile>> updateProfile(Profile profile);

  /// Update specific profile fields
  ///
  /// Returns a [RepositoryOperationResult] indicating whether the operation
  /// was executed immediately or queued for sync.
  Future<RepositoryOperationResult<Profile>> updateProfileFields(
      String userId, Map<String, dynamic> fields);

  /// Delete the profile for the given user ID
  ///
  /// Returns a [RepositoryOperationResult] indicating whether the operation
  /// was executed immediately or queued for sync.
  Future<RepositoryOperationResult<void>> deleteProfile(String userId);

  /// Update profile avatar
  ///
  /// Returns the new avatar URL.
  /// Returns a [RepositoryOperationResult] indicating whether the operation
  /// was executed immediately or queued for sync.
  Future<RepositoryOperationResult<String>> uploadAvatar(
      String userId, String filePath);

  /// Remove profile avatar
  ///
  /// Returns a [RepositoryOperationResult] indicating whether the operation
  /// was executed immediately or queued for sync.
  Future<RepositoryOperationResult<void>> removeAvatar(String userId);

  /// Update profile preferences
  ///
  /// Returns a [RepositoryOperationResult] indicating whether the operation
  /// was executed immediately or queued for sync.
  Future<RepositoryOperationResult<void>> updatePreferences(
      String userId, Map<String, dynamic> preferences);

  /// Update profile interests
  ///
  /// Returns a [RepositoryOperationResult] indicating whether the operation
  /// was executed immediately or queued for sync.
  Future<RepositoryOperationResult<void>> updateInterests(
      String userId, List<String> interests);

  /// Toggle profile visibility
  ///
  /// Returns a [RepositoryOperationResult] indicating whether the operation
  /// was executed immediately or queued for sync.
  Future<RepositoryOperationResult<void>> toggleProfileVisibility(
      String userId, bool isPublic);

  /// Check if profile exists
  ///
  /// This will check local cache first, and verify with remote if online.
  Future<bool> profileExists(String userId);
}
