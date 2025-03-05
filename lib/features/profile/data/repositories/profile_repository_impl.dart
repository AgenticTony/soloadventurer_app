import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:soloadventurer/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:soloadventurer/features/profile/data/models/profile_model.dart';
import 'package:soloadventurer/features/profile/domain/entities/profile.dart';
import 'package:soloadventurer/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;
  final ProfileLocalDataSource _localDataSource;

  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remoteDataSource,
    required ProfileLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Profile> createProfile(Profile profile) async {
    final model = ProfileModel.fromEntity(profile);
    final createdProfile = await _remoteDataSource.createProfile(model);
    await _localDataSource.createProfile(createdProfile);
    return createdProfile.toEntity();
  }

  @override
  Future<Profile> getProfile(String userId) async {
    try {
      final profile = await _remoteDataSource.getProfile(userId);
      await _localDataSource.cacheProfile(profile);
      return profile.toEntity();
    } on NetworkTimeoutException catch (_) {
      final cachedProfile = await _localDataSource.getCachedProfile(userId);
      return cachedProfile.toEntity();
    } on NetworkConnectivityException catch (_) {
      final cachedProfile = await _localDataSource.getCachedProfile(userId);
      return cachedProfile.toEntity();
    }
  }

  @override
  Future<Profile> getCurrentProfile() async {
    try {
      final profile = await _remoteDataSource.getCurrentProfile();
      await _localDataSource.cacheProfile(profile);
      return profile.toEntity();
    } on NetworkTimeoutException catch (_) {
      throw const CacheException(
          message: 'Failed to get current profile: Network timeout');
    } on NetworkConnectivityException catch (_) {
      throw const CacheException(
          message: 'Failed to get current profile: No network connection');
    }
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    final model = ProfileModel.fromEntity(profile);
    final updatedProfile = await _remoteDataSource.updateProfile(model);
    await _localDataSource.cacheProfile(updatedProfile);
    return updatedProfile.toEntity();
  }

  @override
  Future<Profile> updateProfileFields(
      String userId, Map<String, dynamic> fields) async {
    final updatedProfile =
        await _remoteDataSource.updateProfileFields(userId, fields);
    await _localDataSource.cacheProfile(updatedProfile);
    return updatedProfile.toEntity();
  }

  @override
  Future<void> deleteProfile(String userId) async {
    await _remoteDataSource.deleteProfile(userId);
    await _localDataSource.clearCachedProfile(userId);
  }

  @override
  Future<String> uploadAvatar(String userId, String filePath) async {
    final avatarUrl = await _remoteDataSource.uploadAvatar(userId, filePath);
    final cachedProfile = await _localDataSource.getCachedProfile(userId);
    await _localDataSource.cacheProfile(
      cachedProfile.copyWith(avatarUrl: avatarUrl),
    );
    return avatarUrl;
  }

  @override
  Future<void> removeAvatar(String userId) async {
    await _remoteDataSource.removeAvatar(userId);
    final cachedProfile = await _localDataSource.getCachedProfile(userId);
    await _localDataSource.cacheProfile(
      cachedProfile.copyWith(avatarUrl: null),
    );
  }

  @override
  Future<void> updatePreferences(
      String userId, Map<String, dynamic> preferences) async {
    await _remoteDataSource.updatePreferences(userId, preferences);
    final cachedProfile = await _localDataSource.getCachedProfile(userId);
    await _localDataSource.cacheProfile(
      cachedProfile.copyWith(preferences: preferences),
    );
  }

  @override
  Future<void> updateInterests(String userId, List<String> interests) async {
    await _remoteDataSource.updateInterests(userId, interests);
    final cachedProfile = await _localDataSource.getCachedProfile(userId);
    await _localDataSource.cacheProfile(
      cachedProfile.copyWith(interests: interests),
    );
  }

  @override
  Future<void> toggleProfileVisibility(String userId, bool isPublic) async {
    await _remoteDataSource.toggleProfileVisibility(userId, isPublic);
    final cachedProfile = await _localDataSource.getCachedProfile(userId);
    await _localDataSource.cacheProfile(
      cachedProfile.copyWith(isPublic: isPublic),
    );
  }

  @override
  Future<bool> profileExists(String userId) async {
    try {
      return await _remoteDataSource.profileExists(userId);
    } on NetworkTimeoutException catch (_) {
      final cachedProfile = await _localDataSource.getCachedProfile(userId);
      return cachedProfile.id == userId;
    } on NetworkConnectivityException catch (_) {
      final cachedProfile = await _localDataSource.getCachedProfile(userId);
      return cachedProfile.id == userId;
    }
  }
}
