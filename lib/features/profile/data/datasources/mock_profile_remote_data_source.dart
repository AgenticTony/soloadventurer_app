import '../models/profile_model.dart';

class MockProfileRemoteDataSource implements ProfileRemoteDataSource {
  ProfileModel? _mockProfile;

  void setMockProfile(ProfileModel profile) {
    _mockProfile = profile;
  }

  @override
  Future<ProfileModel> createProfile(ProfileModel profile) async {
    _mockProfile = profile;
    return profile;
  }

  @override
  Future<ProfileModel> getProfile(String userId) async {
    if (_mockProfile == null) {
      throw Exception('Mock profile not set');
    }
    return _mockProfile!;
  }

  @override
  Future<ProfileModel> getCurrentProfile() async {
    if (_mockProfile == null) {
      throw Exception('Mock profile not set');
    }
    return _mockProfile!;
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    _mockProfile = profile;
    return profile;
  }

  @override
  Future<ProfileModel> updateProfileFields(
      String userId, Map<String, dynamic> fields) async {
    if (_mockProfile == null) {
      throw Exception('Mock profile not set');
    }
    final updatedProfile = ProfileModel(
      id: _mockProfile!.id,
      userId: _mockProfile!.userId,
      displayName:
          fields['displayName'] as String? ?? _mockProfile!.displayName,
      bio: fields['bio'] as String? ?? _mockProfile!.bio,
      avatarUrl: fields['avatarUrl'] as String? ?? _mockProfile!.avatarUrl,
      createdAt: _mockProfile!.createdAt,
      updatedAt: DateTime.now(),
      preferences: fields['preferences'] as Map<String, dynamic>? ??
          _mockProfile!.preferences,
      interests:
          fields['interests'] as List<String>? ?? _mockProfile!.interests,
      isPublic: fields['isPublic'] as bool? ?? _mockProfile!.isPublic,
    );
    _mockProfile = updatedProfile;
    return updatedProfile;
  }

  @override
  Future<void> deleteProfile(String userId) async {
    _mockProfile = null;
  }

  @override
  Future<String> uploadAvatar(String userId, String filePath) async {
    if (_mockProfile == null) {
      throw Exception('Mock profile not set');
    }
    final updatedProfile = ProfileModel(
      id: _mockProfile!.id,
      userId: _mockProfile!.userId,
      displayName: _mockProfile!.displayName,
      bio: _mockProfile!.bio,
      avatarUrl: filePath,
      createdAt: _mockProfile!.createdAt,
      updatedAt: DateTime.now(),
      preferences: _mockProfile!.preferences,
      interests: _mockProfile!.interests,
      isPublic: _mockProfile!.isPublic,
    );
    _mockProfile = updatedProfile;
    return filePath;
  }

  @override
  Future<void> removeAvatar(String userId) async {
    if (_mockProfile == null) {
      throw Exception('Mock profile not set');
    }
    final updatedProfile = ProfileModel(
      id: _mockProfile!.id,
      userId: _mockProfile!.userId,
      displayName: _mockProfile!.displayName,
      bio: _mockProfile!.bio,
      avatarUrl: null,
      createdAt: _mockProfile!.createdAt,
      updatedAt: DateTime.now(),
      preferences: _mockProfile!.preferences,
      interests: _mockProfile!.interests,
      isPublic: _mockProfile!.isPublic,
    );
    _mockProfile = updatedProfile;
  }

  @override
  Future<void> updatePreferences(
      String userId, Map<String, dynamic> preferences) async {
    if (_mockProfile == null) {
      throw Exception('Mock profile not set');
    }
    final updatedProfile = ProfileModel(
      id: _mockProfile!.id,
      userId: _mockProfile!.userId,
      displayName: _mockProfile!.displayName,
      bio: _mockProfile!.bio,
      avatarUrl: _mockProfile!.avatarUrl,
      createdAt: _mockProfile!.createdAt,
      updatedAt: DateTime.now(),
      preferences: preferences,
      interests: _mockProfile!.interests,
      isPublic: _mockProfile!.isPublic,
    );
    _mockProfile = updatedProfile;
  }

  @override
  Future<void> updateInterests(String userId, List<String> interests) async {
    if (_mockProfile == null) {
      throw Exception('Mock profile not set');
    }
    final updatedProfile = ProfileModel(
      id: _mockProfile!.id,
      userId: _mockProfile!.userId,
      displayName: _mockProfile!.displayName,
      bio: _mockProfile!.bio,
      avatarUrl: _mockProfile!.avatarUrl,
      createdAt: _mockProfile!.createdAt,
      updatedAt: DateTime.now(),
      preferences: _mockProfile!.preferences,
      interests: interests,
      isPublic: _mockProfile!.isPublic,
    );
    _mockProfile = updatedProfile;
  }

  @override
  Future<void> toggleProfileVisibility(String userId, bool isPublic) async {
    if (_mockProfile == null) {
      throw Exception('Mock profile not set');
    }
    final updatedProfile = ProfileModel(
      id: _mockProfile!.id,
      userId: _mockProfile!.userId,
      displayName: _mockProfile!.displayName,
      bio: _mockProfile!.bio,
      avatarUrl: _mockProfile!.avatarUrl,
      createdAt: _mockProfile!.createdAt,
      updatedAt: DateTime.now(),
      preferences: _mockProfile!.preferences,
      interests: _mockProfile!.interests,
      isPublic: isPublic,
    );
    _mockProfile = updatedProfile;
  }

  @override
  Future<bool> profileExists(String userId) async {
    return _mockProfile != null;
  }
}
