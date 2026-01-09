import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/core/infrastructure/api/dio_api_service.dart';
import 'package:soloadventurer/features/core/infrastructure/graphql/graphql_queries.dart';
import 'package:soloadventurer/features/profile/data/models/local_user_profile_model.dart';
import 'package:soloadventurer/features/offline/data/repositories/offline_aware_repository.dart';
import 'package:soloadventurer/core/services/connectivity_service.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_queue_service.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/user_dao.dart';
import 'package:soloadventurer/features/profile/data/models/profile_model.dart';
import 'package:soloadventurer/features/profile/domain/entities/profile.dart';
import 'package:soloadventurer/features/profile/domain/repositories/profile_repository.dart';
import 'package:uuid/uuid.dart';

/// Offline-aware implementation of [ProfileRepository]
///
/// This repository extends [OfflineAwareRepository] to provide offline-first
/// user profile data management. It handles:
/// - Reading from local database first
/// - Writing to local database immediately
/// - Queueing mutations for sync when offline
/// - Syncing with server when online
class ProfileRepositoryImpl extends OfflineAwareRepository<Profile,
    LocalUserProfileModel, Map<String, dynamic>, Map<String, dynamic>> implements ProfileRepository {
  /// Data Access Object for local user profile database operations
  final UserDao _userDao;

  /// API service for remote GraphQL operations
  final DioApiService _apiService;

  /// UUID generator for temporary IDs
  final Uuid _uuid = const Uuid();

  /// Creates a new [ProfileRepositoryImpl]
  ///
  /// Dependencies are injected via constructor parameters.
  ProfileRepositoryImpl({
    required UserDao userDao,
    required DioApiService apiService,
    required super.connectivityService,
    required super.syncQueueService,
    super.config,
  })  : _userDao = userDao,
        _apiService = apiService;

  // ==============================================================================
  // OFFLINE-AWARE BASE REPOSITORY ABSTRACT METHODS
  // ==============================================================================

  @override
  String get entityType => 'userProfile';

  @override
  LocalUserProfileModel entityToModel(Profile entity) {
    return LocalUserProfileModel.fromDomainEntity(entity);
  }

  @override
  Profile modelToEntity(LocalUserProfileModel model) {
    return model.toDomainEntity();
  }

  @override
  String getEntityId(Profile entity) {
    return entity.userId;
  }

  @override
  String getModelId(LocalUserProfileModel model) {
    return model.id;
  }

  @override
  Future<LocalUserProfileModel?> readFromLocal(String id) async {
    try {
      final localUser = await _userDao.getUserById(id);
      return localUser != null ? LocalUserProfileModel.fromDatabase(localUser) : null;
    } catch (e) {
      debugPrint('❌ userProfile: Error reading from local: ${e.toString()}');
      throw const CacheException(message: 'Failed to read user profile from local cache');
    }
  }

  @override
  Future<LocalUserProfileModel> writeToLocal(LocalUserProfileModel model) async {
    try {
      // Convert model to LocalUser database entity
      final localUser = model.toDatabaseEntity();

      // Check if user exists
      final existing = await _userDao.getUserById(model.id);

      if (existing != null) {
        // Update existing user
        await _userDao.updateUser(localUser);
        debugPrint('📝 userProfile: Updated in local database: ${model.id}');
      } else {
        // Insert new user
        final companion = _localUserToCompanion(localUser);
        await _userDao.insertUser(companion);
        debugPrint('📝 userProfile: Inserted in local database: ${model.id}');
      }

      return model;
    } catch (e) {
      debugPrint('❌ userProfile: Error writing to local: ${e.toString()}');
      throw const CacheException(message: 'Failed to write user profile to local cache');
    }
  }

  @override
  Future<void> deleteFromLocal(String id) async {
    try {
      // For users, we do a hard delete (not soft delete)
      await _userDao.deleteUserById(id);
      debugPrint('📝 userProfile: Deleted in local database: $id');
    } catch (e) {
      debugPrint('❌ userProfile: Error deleting from local: ${e.toString()}');
      throw const CacheException(message: 'Failed to delete user profile from local cache');
    }
  }

  @override
  Future<List<LocalUserProfileModel>> readAllFromLocal({String? userId}) async {
    try {
      // User profiles are singleton per user, so we return just the user's profile
      if (userId != null) {
        final user = await _userDao.getUserById(userId);
        return user != null
            ? [LocalUserProfileModel.fromDatabase(user)]
            : [];
      } else {
        // Return all users (admin scenario)
        final users = await _userDao.getAllUsers();
        return users.map((u) => LocalUserProfileModel.fromDatabase(u)).toList();
      }
    } catch (e) {
      debugPrint('❌ userProfile: Error reading all from local: ${e.toString()}');
      throw const CacheException(message: 'Failed to read user profiles from local cache');
    }
  }

  @override
  Future<Profile> executeRemoteCreate(Map<String, dynamic> model) async {
    try {
      final response = await _apiService.dio.post(
        '/graphql',
        data: {
          'query': GraphQLQueries.createUserProfile,
          'variables': model,
        },
      );

      if (response.data['errors'] != null) {
        throw ServerException(
          message: response.data['errors'][0]['message'],
        );
      }

      final profileData = response.data['data']['createUserProfile'];
      return _profileDataToEntity(profileData);
    } catch (e) {
      debugPrint('❌ userProfile: Error in remote create: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw const ServerException(message: 'Failed to create user profile on server');
    }
  }

  @override
  Future<Profile> executeRemoteUpdate(String id, Map<String, dynamic> model) async {
    try {
      final variables = {...model, 'userId': id};

      final response = await _apiService.dio.post(
        '/graphql',
        data: {
          'query': GraphQLQueries.updateUserProfile,
          'variables': variables,
        },
      );

      if (response.data['errors'] != null) {
        throw ServerException(
          message: response.data['errors'][0]['message'],
        );
      }

      final profileData = response.data['data']['updateUserProfile'];
      return _profileDataToEntity(profileData);
    } catch (e) {
      debugPrint('❌ userProfile: Error in remote update: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw const ServerException(message: 'Failed to update user profile on server');
    }
  }

  @override
  Future<void> executeRemoteDelete(String id) async {
    try {
      final response = await _apiService.dio.post(
        '/graphql',
        data: {
          'query': GraphQLQueries.deleteUserProfile,
          'variables': {'userId': id},
        },
      );

      if (response.data['errors'] != null) {
        throw ServerException(
          message: response.data['errors'][0]['message'],
        );
      }

      final result = response.data['data']['deleteUserProfile'];
      if (result['success'] != true) {
        throw const ServerException(
          message: 'Failed to delete user profile on server',
        );
      }

      debugPrint('🌐 userProfile: Deleted on remote API: $id');
    } catch (e) {
      debugPrint('❌ userProfile: Error in remote delete: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw const ServerException(message: 'Failed to delete user profile on server');
    }
  }

  @override
  Future<Profile> executeRemoteFetch(String id) async {
    try {
      final response = await _apiService.dio.post(
        '/graphql',
        data: {
          'query': GraphQLQueries.getUserProfile,
          'variables': {'userId': id},
        },
      );

      if (response.data['errors'] != null) {
        throw ServerException(
          message: response.data['errors'][0]['message'],
        );
      }

      final profileData = response.data['data']['getUserProfile'];
      return _profileDataToEntity(profileData);
    } catch (e) {
      debugPrint('❌ userProfile: Error in remote fetch: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw const ServerException(message: 'Failed to fetch user profile from server');
    }
  }

  @override
  Future<List<Profile>> executeRemoteFetchAll({String? userId}) async {
    // For user profiles, we only fetch single user profiles
    // This method is not commonly used for profiles
    if (userId == null) {
      throw const ServerException(
        message: 'userId is required for fetching user profiles',
      );
    }

    try {
      final profile = await executeRemoteFetch(userId);
      return [profile];
    } catch (e) {
      debugPrint('❌ userProfile: Error in remote fetch all: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw const ServerException(message: 'Failed to fetch user profile from server');
    }
  }

  // ==============================================================================
  // PROFILE REPOSITORY INTERFACE METHODS
  // ==============================================================================

  @override
  Future<Profile> getProfile(String userId) {
    return getById(userId);
  }

  @override
  Future<Profile> getCurrentProfile() async {
    // For the current profile, we need to get the authenticated user's ID
    // This is a simplified implementation - in production, get current user from auth service
    try {
      // Try to fetch from server (will use cached user ID from auth)
      final response = await _apiService.dio.post(
        '/graphql',
        data: {
          'query': GraphQLQueries.getCurrentUserProfile,
        },
      );

      if (response.data['errors'] != null) {
        throw ServerException(
          message: response.data['errors'][0]['message'],
        );
      }

      final profileData = response.data['data']['getCurrentUserProfile'];
      final profile = _profileDataToEntity(profileData);

      // Cache locally
      final model = entityToModel(profile);
      try {
        await writeToLocal(model);
      } catch (e) {
        debugPrint('⚠️ userProfile: Failed to cache current profile: $e');
      }

      return profile;
    } catch (e) {
      debugPrint('❌ userProfile: Error fetching current profile: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw const ServerException(message: 'Failed to fetch current user profile');
    }
  }

  @override
  Future<RepositoryOperationResult<Profile>> createProfile(Profile profile) {
    final profileData = _profileToJson(profile);
    return create(profileData);
  }

  @override
  Future<RepositoryOperationResult<Profile>> updateProfile(Profile profile) {
    final profileData = _profileToJson(profile);
    return update(profile.userId, profileData);
  }

  @override
  Future<RepositoryOperationResult<Profile>> updateProfileFields(
      String userId, Map<String, dynamic> fields) {
    return update(userId, fields);
  }

  @override
  Future<RepositoryOperationResult<void>> deleteProfile(String userId) {
    return delete(userId);
  }

  @override
  Future<RepositoryOperationResult<String>> uploadAvatar(
      String userId, String filePath) async {
    try {
      // This is a special case - we need to upload the file first
      // Avatar upload is typically done via a separate file upload endpoint
      // For now, we'll update the avatarUrl field directly

      // In a real implementation, you would:
      // 1. Upload the file to a storage service (S3, etc.)
      // 2. Get the URL back
      // 3. Update the profile with the new URL

      // For this implementation, we'll simulate the upload by updating the avatarUrl
      // In production, replace this with actual file upload logic

      throw UnimplementedError(
        'Avatar upload requires file storage service integration',
      );
    } catch (e) {
      debugPrint('❌ userProfile: Error uploading avatar: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw const ServerException(message: 'Failed to upload avatar');
    }
  }

  @override
  Future<RepositoryOperationResult<void>> removeAvatar(String userId) async {
    try {
      // Remove avatar by setting avatarUrl to null
      final isConnected = await isOnline;

      final fields = {'avatarUrl': null};

      if (isConnected) {
        // Online: Execute remote operation immediately
        final response = await _apiService.dio.post(
          '/graphql',
          data: {
            'query': GraphQLQueries.updateUserProfile,
            'variables': {
              'userId': userId,
              ...fields,
            },
          },
        );

        if (response.data['errors'] != null) {
          throw ServerException(
            message: response.data['errors'][0]['message'],
          );
        }

        // Update local cache
        await _userDao.updateAvatar(userId, null);

        return const RepositoryOperationResult.immediate(null);
      } else {
        // Offline: Queue for sync
        final localProfile = await readFromLocal(userId);
        if (localProfile != null) {
          final updated = localProfile.copyWith(avatarUrl: null);
          await writeToLocal(updated);
        }

        await _queueOperation(
          entityType: entityType,
          entityId: userId,
          operation: SyncOperationType.update,
          data: fields,
        );

        return const RepositoryOperationResult.queued(null);
      }
    } catch (e) {
      debugPrint('❌ userProfile: Error removing avatar: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw const ServerException(message: 'Failed to remove avatar');
    }
  }

  @override
  Future<RepositoryOperationResult<void>> updatePreferences(
      String userId, Map<String, dynamic> preferences) async {
    try {
      final isConnected = await isOnline;

      final fields = {'preferences': preferences};

      if (isConnected) {
        // Online: Execute remote operation immediately
        final response = await _apiService.dio.post(
          '/graphql',
          data: {
            'query': GraphQLQueries.updateUserPreferences,
            'variables': {
              'userId': userId,
              'preferences': preferences,
            },
          },
        );

        if (response.data['errors'] != null) {
          throw ServerException(
            message: response.data['errors'][0]['message'],
          );
        }

        // Update local cache
        final preferencesJson = const JsonEncoder().convert(preferences);
        await _userDao.updatePreferences(userId, preferencesJson);

        return const RepositoryOperationResult.immediate(null);
      } else {
        // Offline: Queue for sync
        final localProfile = await readFromLocal(userId);
        if (localProfile != null) {
          final updated = localProfile.copyWith(preferences: preferences);
          await writeToLocal(updated);
        }

        await _queueOperation(
          entityType: entityType,
          entityId: userId,
          operation: SyncOperationType.update,
          data: fields,
        );

        return const RepositoryOperationResult.queued(null);
      }
    } catch (e) {
      debugPrint('❌ userProfile: Error updating preferences: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw const ServerException(message: 'Failed to update preferences');
    }
  }

  @override
  Future<RepositoryOperationResult<void>> updateInterests(
      String userId, List<String> interests) async {
    try {
      final isConnected = await isOnline;

      final fields = {'interests': interests};

      if (isConnected) {
        // Online: Execute remote operation immediately
        final response = await _apiService.dio.post(
          '/graphql',
          data: {
            'query': GraphQLQueries.updateUserInterests,
            'variables': {
              'userId': userId,
              'interests': interests,
            },
          },
        );

        if (response.data['errors'] != null) {
          throw ServerException(
            message: response.data['errors'][0]['message'],
          );
        }

        // Update local cache
        final interestsJson = const JsonEncoder().convert(interests);
        await _userDao.updateInterests(userId, interestsJson);

        return const RepositoryOperationResult.immediate(null);
      } else {
        // Offline: Queue for sync
        final localProfile = await readFromLocal(userId);
        if (localProfile != null) {
          final updated = localProfile.copyWith(interests: interests);
          await writeToLocal(updated);
        }

        await _queueOperation(
          entityType: entityType,
          entityId: userId,
          operation: SyncOperationType.update,
          data: fields,
        );

        return const RepositoryOperationResult.queued(null);
      }
    } catch (e) {
      debugPrint('❌ userProfile: Error updating interests: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw const ServerException(message: 'Failed to update interests');
    }
  }

  @override
  Future<RepositoryOperationResult<void>> toggleProfileVisibility(
      String userId, bool isPublic) async {
    try {
      final isConnected = await isOnline;

      final fields = {'isPublic': isPublic};

      if (isConnected) {
        // Online: Execute remote operation immediately
        final response = await _apiService.dio.post(
          '/graphql',
          data: {
            'query': GraphQLQueries.toggleProfileVisibility,
            'variables': {
              'userId': userId,
              'isPublic': isPublic,
            },
          },
        );

        if (response.data['errors'] != null) {
          throw ServerException(
            message: response.data['errors'][0]['message'],
          );
        }

        // Update local cache
        await _userDao.toggleProfileVisibility(userId, isPublic);

        return const RepositoryOperationResult.immediate(null);
      } else {
        // Offline: Queue for sync
        final localProfile = await readFromLocal(userId);
        if (localProfile != null) {
          final updated = localProfile.copyWith(isPublic: isPublic);
          await writeToLocal(updated);
        }

        await _queueOperation(
          entityType: entityType,
          entityId: userId,
          operation: SyncOperationType.update,
          data: fields,
        );

        return const RepositoryOperationResult.queued(null);
      }
    } catch (e) {
      debugPrint('❌ userProfile: Error toggling visibility: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw const ServerException(message: 'Failed to toggle profile visibility');
    }
  }

  @override
  Future<bool> profileExists(String userId) async {
    try {
      // Check local cache first
      final localExists = await _userDao.userExists(userId);
      if (localExists) {
        return true;
      }

      // Check remote if online
      final isConnected = await isOnline;
      if (!isConnected) {
        return false;
      }

      // Try to fetch from remote to verify existence
      try {
        await executeRemoteFetch(userId);
        return true;
      } on ServerException catch (e) {
        if (e.message.contains('not found')) {
          return false;
        }
        rethrow;
      }
    } catch (e) {
      debugPrint('❌ userProfile: Error checking profile existence: ${e.toString()}');
      return false;
    }
  }

  // ==============================================================================
  // HELPER METHODS - Local database conversion
  // ==============================================================================

  /// Convert [LocalUserProfileModel] to [LocalUser] database entity
  LocalUser _modelToLocalUser(LocalUserProfileModel model) {
    return model.toDatabaseEntity();
  }

  /// Convert [LocalUser] to [UsersCompanion] for database operations
  UsersCompanion _localUserToCompanion(LocalUser user) {
    return UsersCompanion(
      id: Value(user.id),
      email: Value(user.email),
      username: Value(user.username),
      displayName: Value(user.displayName),
      bio: Value(user.bio),
      avatarUrl: Value(user.avatarUrl),
      isPublic: Value(user.isPublic),
      interests: Value(user.interests),
      preferences: Value(user.preferences),
      createdAt: Value(user.createdAt),
      updatedAt: Value(user.updatedAt),
      lastLoginAt: Value(user.lastLoginAt),
      isSynced: Value(user.isSynced),
      hasPendingChanges: Value(user.hasPendingChanges),
      version: Value(user.version),
      lastSyncedAt: Value(user.lastSyncedAt),
    );
  }

  /// Convert [Profile] domain entity to JSON for GraphQL mutations
  Map<String, dynamic> _profileToJson(Profile profile) {
    return {
      'userId': profile.userId,
      'username': profile.username,
      'email': profile.email,
      'displayName': profile.displayName,
      'bio': profile.bio,
      'avatarUrl': profile.avatarUrl,
      'isPublic': profile.isPublic,
      'interests': profile.interests,
      'preferences': profile.preferences,
    };
  }

  /// Convert profile data from GraphQL response to domain entity
  Profile _profileDataToEntity(Map<String, dynamic> data) {
    return Profile(
      id: data['id'] as String? ?? data['userId'] as String,
      userId: data['userId'] as String,
      username: data['username'] as String,
      email: data['email'] as String,
      displayName: data['displayName'] as String,
      bio: data['bio'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      isPublic: data['isPublic'] as bool? ?? false,
      interests: (data['interests'] as List<dynamic>?)?.cast<String>() ?? [],
      preferences: (data['preferences'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }

  @override
  Map<String, dynamic> _modelToJson(LocalUserProfileModel model) {
    return model.toJson();
  }
}
