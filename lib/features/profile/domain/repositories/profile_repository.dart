import '../entities/profile.dart';

/// Repository interface for profile-related operations
abstract class ProfileRepository {
  /// Create a new profile
  Future<Profile> createProfile(Profile profile);

  /// Get the profile for the given user ID
  Future<Profile> getProfile(String userId);

  /// Get the current user's profile
  Future<Profile> getCurrentProfile();

  /// Update the profile with the given data
  Future<Profile> updateProfile(Profile profile);

  /// Update specific profile fields
  Future<Profile> updateProfileFields(
      String userId, Map<String, dynamic> fields);

  /// Delete the profile for the given user ID
  Future<void> deleteProfile(String userId);

  /// Update profile avatar
  Future<String> uploadAvatar(String userId, String filePath);

  /// Remove profile avatar
  Future<void> removeAvatar(String userId);

  /// Update profile preferences
  Future<void> updatePreferences(
      String userId, Map<String, dynamic> preferences);

  /// Update profile interests
  Future<void> updateInterests(String userId, List<String> interests);

  /// Toggle profile visibility
  Future<void> toggleProfileVisibility(String userId, bool isPublic);

  /// Check if profile exists
  Future<bool> profileExists(String userId);
}
