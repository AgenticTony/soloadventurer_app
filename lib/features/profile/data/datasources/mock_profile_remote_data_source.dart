import 'package:soloadventurer/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:soloadventurer/features/profile/data/models/profile_model.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';

/// Mock implementation of [ProfileRemoteDataSource] for testing
class MockProfileRemoteDataSource implements ProfileRemoteDataSource {
  ProfileModel? _mockProfile;

  MockProfileRemoteDataSource() {
    _mockProfile = null;
  }

  void setMockProfile(ProfileModel profile) {
    _mockProfile = profile;
  }

  @override
  Future<ProfileModel> createProfile(ProfileModel profile) async {
    try {
      _mockProfile = profile;
      return profile;
    } catch (e) {
      throw ServerException(message: 'Failed to create profile');
    }
  }

  @override
  Future<ProfileModel> getCurrentProfile() async {
    try {
      if (_mockProfile == null) {
        throw const NotFoundException(message: 'No current profile');
      }
      return _mockProfile!;
    } catch (e) {
      throw ServerException(message: 'Failed to get current profile');
    }
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    try {
      _mockProfile = profile;
      return profile;
    } catch (e) {
      throw ServerException(message: 'Failed to update profile');
    }
  }

  @override
  Future<ProfileModel> getProfile(String userId) async {
    if (_mockProfile == null) {
      throw const NotFoundException(message: 'Profile not found');
    }
    return _mockProfile!;
  }

  @override
  Future<ProfileModel> updateProfileFields(
      String userId, Map<String, dynamic> fields) async {
    if (_mockProfile == null) {
      throw const NotFoundException(message: 'Profile not found');
    }
    _mockProfile = _mockProfile!.copyWith(
      displayName:
          fields['displayName'] as String? ?? _mockProfile!.displayName,
      bio: fields['bio'] as String? ?? _mockProfile!.bio,
      isPublic: fields['isPublic'] as bool? ?? _mockProfile!.isPublic,
    );
    return _mockProfile!;
  }

  @override
  Future<void> deleteProfile(String userId) async {
    _mockProfile = null;
  }

  @override
  Future<String> uploadAvatar(String userId, String filePath) async {
    if (_mockProfile == null) {
      throw const NotFoundException(message: 'Profile not found');
    }
    final updatedProfile = _mockProfile!.copyWith(
      avatarUrl: filePath,
    );
    _mockProfile = updatedProfile;
    return filePath;
  }

  @override
  Future<void> removeAvatar(String userId) async {
    if (_mockProfile == null) {
      throw const NotFoundException(message: 'Profile not found');
    }
    final updatedProfile = _mockProfile!.copyWith(
      avatarUrl: null,
    );
    _mockProfile = updatedProfile;
  }

  @override
  Future<void> updatePreferences(
      String userId, Map<String, dynamic> preferences) async {
    if (_mockProfile == null) {
      throw const NotFoundException(message: 'Profile not found');
    }
    final updatedProfile = _mockProfile!.copyWith(
      preferences: preferences,
    );
    _mockProfile = updatedProfile;
  }

  @override
  Future<void> updateInterests(String userId, List<String> interests) async {
    if (_mockProfile == null) {
      throw const NotFoundException(message: 'Profile not found');
    }
    final updatedProfile = _mockProfile!.copyWith(
      interests: interests,
    );
    _mockProfile = updatedProfile;
  }

  @override
  Future<void> toggleProfileVisibility(String userId, bool isPublic) async {
    if (_mockProfile == null) {
      throw const NotFoundException(message: 'Profile not found');
    }
    final updatedProfile = _mockProfile!.copyWith(
      isPublic: isPublic,
    );
    _mockProfile = updatedProfile;
  }

  @override
  Future<bool> profileExists(String userId) async {
    return _mockProfile != null && _mockProfile!.userId == userId;
  }
}
