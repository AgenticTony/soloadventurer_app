import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/core/storage/secure_storage.dart';
import '../models/profile_model.dart';

/// Interface for local profile data operations
abstract class ProfileLocalDataSource {
  /// Create and cache a new profile
  Future<void> createProfile(ProfileModel profile);

  /// Get cached profile by user ID
  Future<ProfileModel> getCachedProfile(String userId);

  /// Cache profile data
  Future<void> cacheProfile(ProfileModel profile);

  /// Clear cached profile data
  Future<void> clearCachedProfile(String userId);

  /// Cache profile preferences
  Future<void> cachePreferences(
      String userId, Map<String, dynamic> preferences);

  /// Get cached profile preferences
  Future<Map<String, dynamic>?> getCachedPreferences(String userId);

  /// Cache profile interests
  Future<void> cacheInterests(String userId, List<String> interests);

  /// Get cached profile interests
  Future<List<String>?> getCachedInterests(String userId);

  /// Check if cache is expired
  Future<bool> isCacheExpired();
}

/// Implementation of [ProfileLocalDataSource] using secure storage
class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SecureStorage _storage;
  final SharedPreferences _sharedPreferences;
  static const String _profileKey = 'cached_profile';
  static const String _preferencesKeyPrefix = 'profile_preferences_';
  static const String _interestsKeyPrefix = 'profile_interests_';
  static const String _lastUpdateKey = 'profile_last_update';
  static const String _cachedProfilePrefix = 'CACHED_PROFILE_';

  /// Cache expiration duration (24 hours)
  static const Duration cacheExpiration = Duration(hours: 24);

  /// Creates a new [ProfileLocalDataSourceImpl] with the given storage
  ProfileLocalDataSourceImpl({
    required SecureStorage storage,
    required SharedPreferences sharedPreferences,
  })  : _storage = storage,
        _sharedPreferences = sharedPreferences;

  @override
  Future<void> createProfile(ProfileModel profile) async {
    final String key = _cachedProfilePrefix + profile.userId;
    await _sharedPreferences.setString(
      key,
      jsonEncode(profile.toJson()),
    );
  }

  @override
  Future<ProfileModel> getCachedProfile(String userId) async {
    if (await isCacheExpired()) {
      await clearCachedProfile(userId);
      throw const CacheException(message: 'Cache expired');
    }

    final String key = _cachedProfilePrefix + userId;
    final String? jsonString = _sharedPreferences.getString(key);
    if (jsonString != null) {
      try {
        return ProfileModel.fromJson(jsonDecode(jsonString));
      } catch (e) {
        await clearCachedProfile(userId);
        throw const CacheException(message: 'Invalid cache data');
      }
    }
    throw const CacheException(message: 'No cached data found');
  }

  @override
  Future<void> cacheProfile(ProfileModel profile) async {
    final String key = _cachedProfilePrefix + profile.userId;
    await _sharedPreferences.setString(
      key,
      jsonEncode(profile.toJson()),
    );
    await _storage.write(_lastUpdateKey, DateTime.now().toIso8601String());
  }

  @override
  Future<void> clearCachedProfile(String userId) async {
    final String key = _cachedProfilePrefix + userId;
    await _sharedPreferences.remove(key);
    await _storage.delete(_lastUpdateKey);
  }

  @override
  Future<void> cachePreferences(
      String userId, Map<String, dynamic> preferences) async {
    await _storage.write(
      _getPreferencesKey(userId),
      jsonEncode(preferences),
    );
  }

  @override
  Future<Map<String, dynamic>?> getCachedPreferences(String userId) async {
    if (await isCacheExpired()) {
      await clearCachedProfile(userId);
      return null;
    }

    final jsonString = await _storage.read(_getPreferencesKey(userId));
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheInterests(String userId, List<String> interests) async {
    await _storage.write(
      _getInterestsKey(userId),
      jsonEncode(interests),
    );
  }

  @override
  Future<List<String>?> getCachedInterests(String userId) async {
    if (await isCacheExpired()) {
      await clearCachedProfile(userId);
      return null;
    }

    final jsonString = await _storage.read(_getInterestsKey(userId));
    if (jsonString == null) return null;

    try {
      return (jsonDecode(jsonString) as List<dynamic>).cast<String>();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isCacheExpired() async {
    final lastUpdate = await _storage.read(_lastUpdateKey);
    if (lastUpdate == null) return true;

    final lastUpdateTime = DateTime.parse(lastUpdate);
    final now = DateTime.now();
    return now.difference(lastUpdateTime) > cacheExpiration;
  }

  String _getPreferencesKey(String userId) => '$_preferencesKeyPrefix$userId';
  String _getInterestsKey(String userId) => '$_interestsKeyPrefix$userId';
}
