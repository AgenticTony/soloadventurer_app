import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/core/infrastructure/api/dio_api_service.dart';
import 'package:soloadventurer/features/core/infrastructure/graphql/graphql_queries.dart';
import 'package:soloadventurer/features/offline/data/repositories/offline_aware_repository.dart';
import 'package:soloadventurer/features/offline/domain/entities/sync_operation.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_queue_service.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/user_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';
import 'package:soloadventurer/features/profile/data/models/local_user_profile_model.dart';
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
///
/// Type parameters:
/// - Entity: Profile (domain entity)
/// - Model: LocalUserProfileModel (local data model)
/// - CreateModel: Map<String, dynamic> (for GraphQL create operations)
/// - UpdateModel: Map<String, dynamic> (for GraphQL update operations)
///
/// Note: We use Map<String, dynamic> for CreateModel and UpdateModel since
/// GraphQL mutations receive JSON-like maps, not model instances.
class ProfileRepositoryImpl extends OfflineAwareRepository<
    Profile,
    LocalUserProfileModel,
    LocalUserProfileModel,
    LocalUserProfileModel> implements ProfileRepository {
  /// Data Access Object for local user profile database operations
  final UserDao _userDao;

  /// API service for remote GraphQL operations
  final DioApiService _apiService;

  /// Sync queue service for queuing offline operations
  final SyncQueueService _syncQueueService;

  /// Supabase client for Storage operations (avatar upload)
  final SupabaseClient _supabaseClient;

  /// UUID generator for temporary IDs
  final Uuid _uuid = const Uuid();

  /// Creates a new [ProfileRepositoryImpl]
  ///
  /// Dependencies are injected via constructor parameters.
  ProfileRepositoryImpl({
    required UserDao userDao,
    required DioApiService apiService,
    required SupabaseClient supabaseClient,
    required super.syncQueueService,
    required super.connectivityService,
    super.config,
  })  : _userDao = userDao,
        _apiService = apiService,
        _supabaseClient = supabaseClient,
        _syncQueueService = syncQueueService;

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
      return localUser != null
          ? LocalUserProfileModel.fromDatabase(localUser)
          : null;
    } catch (e) {
      debugPrint('❌ userProfile: Error reading from local: ${e.toString()}');
      throw const CacheException(
          message: 'Failed to read user profile from local cache');
    }
  }

  @override
  Future<LocalUserProfileModel> writeToLocal(
      LocalUserProfileModel model) async {
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
      throw const CacheException(
          message: 'Failed to write user profile to local cache');
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
      throw const CacheException(
          message: 'Failed to delete user profile from local cache');
    }
  }

  @override
  Future<List<LocalUserProfileModel>> readAllFromLocal({String? userId}) async {
    try {
      // User profiles are singleton per user, so we return just the user's profile
      if (userId != null) {
        final user = await _userDao.getUserById(userId);
        return user != null ? [LocalUserProfileModel.fromDatabase(user)] : [];
      } else {
        // Return all users (admin scenario)
        final users = await _userDao.getAllUsers();
        return users.map((u) => LocalUserProfileModel.fromDatabase(u)).toList();
      }
    } catch (e) {
      debugPrint(
          '❌ userProfile: Error reading all from local: ${e.toString()}');
      throw const CacheException(
          message: 'Failed to read user profiles from local cache');
    }
  }

  @override
  Future<Profile> executeRemoteCreate(LocalUserProfileModel model) async {
    try {
      final response = await _apiService.dio.post(
        '/graphql',
        data: {
          'query': GraphQLQueries.createUserProfile,
          'variables': model.toJson(),
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
      throw const ServerException(
          message: 'Failed to create user profile on server');
    }
  }

  @override
  Future<Profile> executeRemoteUpdate(
      String id, LocalUserProfileModel model) async {
    try {
      final variables = {...model.toJson(), 'userId': id};

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
      throw const ServerException(
          message: 'Failed to update user profile on server');
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
      throw const ServerException(
          message: 'Failed to delete user profile on server');
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
      throw const ServerException(
          message: 'Failed to fetch user profile from server');
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
      throw const ServerException(
          message: 'Failed to fetch user profile from server');
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
      debugPrint(
          '❌ userProfile: Error fetching current profile: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw const ServerException(
          message: 'Failed to fetch current user profile');
    }
  }

  @override
  Future<RepositoryOperationResult<Profile>> createProfile(Profile profile) {
    final model = entityToModel(profile);
    return create(model);
  }

  @override
  Future<RepositoryOperationResult<Profile>> updateProfile(Profile profile) {
    final model = entityToModel(profile);
    return update(profile.userId, model);
  }

  @override
  Future<RepositoryOperationResult<Profile>> updateProfileFields(
      String userId, Map<String, dynamic> fields) async {
    // Get the current profile, update it with the fields, then save
    final currentProfile = await getProfile(userId);
    final updatedProfile = _applyFieldsToProfile(currentProfile, fields);
    final model = entityToModel(updatedProfile);
    return update(userId, model);
  }

  @override
  Future<RepositoryOperationResult<void>> deleteProfile(String userId) {
    return delete(userId);
  }

  @override
  Future<RepositoryOperationResult<String>> uploadAvatar(
      String userId, String filePath) async {
    try {
      // ============================================================
      // AVATAR UPLOAD IMPLEMENTATION
      // ============================================================
      // Official Supabase Storage Documentation:
      // https://supabase.com/docs/reference/dart/storage-from-upload
      //
      // Storage bucket name: 'avatars'
      // - Files are stored at: {userId}/{filename}
      // - Public URLs are automatically generated
      // ============================================================

      final isConnected = await isOnline;

      if (!isConnected) {
        // Offline: Queue for sync when connection is available
        final localProfile = await readFromLocal(userId);
        if (localProfile != null) {
          // Update local with pending avatar path
          final updated = localProfile.copyWith(avatarUrl: filePath);
          await writeToLocal(updated);
        }

        await _syncQueueService.enqueueOperation(
          entityType: entityType,
          entityId: userId,
          operation: SyncOperationType.update,
          data: {'avatarFilePath': filePath},
          priority: config.defaultSyncPriority,
          maxRetries: config.maxSyncRetries,
        );

        return RepositoryOperationResult.queued(filePath);
      }

      // Online: Upload file to Supabase Storage
      final file = File(filePath);

      if (!file.existsSync()) {
        throw const ServerException(
          message: 'Avatar file does not exist',
          code: 'FILE_NOT_FOUND',
        );
      }

      // Get file extension for proper MIME type handling
      final ext = path.extension(filePath);
      final fileName = 'avatar_$userId${DateTime.now().millisecondsSinceEpoch}$ext';
      final storagePath = '$userId/$fileName';

      // Upload to Supabase Storage 'avatars' bucket
      debugPrint('📤 userProfile: Uploading avatar to: avatars/$storagePath');

      await _supabaseClient.storage.from('avatars').upload(
            storagePath,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true, // Allow overwriting existing avatar
            ),
          );

      // Get public URL for the uploaded avatar
      final avatarUrl = _supabaseClient.storage
          .from('avatars')
          .getPublicUrl(storagePath);

      debugPrint('✅ userProfile: Avatar uploaded successfully: $avatarUrl');

      // Update profile with new avatar URL
      final fields = {'avatarUrl': avatarUrl};

      final updateResponse = await _apiService.dio.post(
        '/graphql',
        data: {
          'query': GraphQLQueries.updateUserProfile,
          'variables': {
            'userId': userId,
            ...fields,
          },
        },
      );

      if (updateResponse.data['errors'] != null) {
        throw ServerException(
          message: updateResponse.data['errors'][0]['message'],
        );
      }

      // Update local cache
      await _userDao.updateAvatar(userId, avatarUrl);

      return RepositoryOperationResult.immediate(avatarUrl);
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

        // Queue the operation for sync
        await _syncQueueService.enqueueOperation(
          entityType: entityType,
          entityId: userId,
          operation: SyncOperationType.update,
          data: fields,
          priority: config.defaultSyncPriority,
          maxRetries: config.maxSyncRetries,
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
        final preferencesJson = jsonEncode(preferences);
        await _userDao.updatePreferences(userId, preferencesJson);

        return const RepositoryOperationResult.immediate(null);
      } else {
        // Offline: Queue for sync
        final localProfile = await readFromLocal(userId);
        if (localProfile != null) {
          final updated = localProfile.copyWith(preferences: preferences);
          await writeToLocal(updated);
        }

        await _syncQueueService.enqueueOperation(
          entityType: entityType,
          entityId: userId,
          operation: SyncOperationType.update,
          data: fields,
          priority: config.defaultSyncPriority,
          maxRetries: config.maxSyncRetries,
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
        final interestsJson = jsonEncode(interests);
        await _userDao.updateInterests(userId, interestsJson);

        return const RepositoryOperationResult.immediate(null);
      } else {
        // Offline: Queue for sync
        final localProfile = await readFromLocal(userId);
        if (localProfile != null) {
          final updated = localProfile.copyWith(interests: interests);
          await writeToLocal(updated);
        }

        await _syncQueueService.enqueueOperation(
          entityType: entityType,
          entityId: userId,
          operation: SyncOperationType.update,
          data: fields,
          priority: config.defaultSyncPriority,
          maxRetries: config.maxSyncRetries,
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

        await _syncQueueService.enqueueOperation(
          entityType: entityType,
          entityId: userId,
          operation: SyncOperationType.update,
          data: fields,
          priority: config.defaultSyncPriority,
          maxRetries: config.maxSyncRetries,
        );

        return const RepositoryOperationResult.queued(null);
      }
    } catch (e) {
      debugPrint('❌ userProfile: Error toggling visibility: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw const ServerException(
          message: 'Failed to toggle profile visibility');
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
      debugPrint(
          '❌ userProfile: Error checking profile existence: ${e.toString()}');
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
  Map<String, dynamic> modelToJson(LocalUserProfileModel model) {
    return model.toJson();
  }

  /// Apply field updates to a profile
  Profile _applyFieldsToProfile(Profile profile, Map<String, dynamic> fields) {
    return profile.copyWith(
      username: fields['username'] as String? ?? profile.username,
      email: fields['email'] as String? ?? profile.email,
      displayName: fields['displayName'] as String? ?? profile.displayName,
      bio: fields['bio'] as String?,
      avatarUrl: fields['avatarUrl'] as String?,
      isPublic: fields['isPublic'] as bool? ?? profile.isPublic,
      interests: fields['interests'] as List<String>? ?? profile.interests,
      preferences:
          fields['preferences'] as Map<String, dynamic>? ?? profile.preferences,
    );
  }
}
