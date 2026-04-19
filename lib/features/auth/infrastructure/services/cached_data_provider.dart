import 'dart:async';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/offline_auth_manager.dart';

/// Result of a cached data operation
class CachedDataResult<T> {
  /// The data returned from the operation (if successful)
  final T? data;

  /// Whether the operation was successful
  final bool success;

  /// Error message if the operation failed
  final String? errorMessage;

  /// Whether the data is from cache (vs. live data)
  final bool isFromCache;

  /// Timestamp of when the data was cached
  final DateTime? cachedAt;

  /// Whether the cached data is considered fresh
  final bool isFresh;

  const CachedDataResult({
    this.data,
    required this.success,
    this.errorMessage,
    required this.isFromCache,
    this.cachedAt,
    required this.isFresh,
  });

  /// Creates a success result with cached data
  factory CachedDataResult.cached({
    required T data,
    DateTime? cachedAt,
    required bool isFresh,
  }) {
    return CachedDataResult(
      data: data,
      success: true,
      isFromCache: true,
      cachedAt: cachedAt,
      isFresh: isFresh,
    );
  }

  /// Creates a success result with live data
  factory CachedDataResult.live({
    required T data,
  }) {
    return CachedDataResult(
      data: data,
      success: true,
      isFromCache: false,
      cachedAt: null,
      isFresh: true,
    );
  }

  /// Creates a failure result
  factory CachedDataResult.failure({
    required String errorMessage,
  }) {
    return CachedDataResult(
      data: null,
      success: false,
      isFromCache: false,
      cachedAt: null,
      isFresh: false,
      errorMessage: errorMessage,
    );
  }

  /// Creates a no data available result
  factory CachedDataResult.noData() {
    return const CachedDataResult(
      data: null,
      success: true,
      isFromCache: false,
      cachedAt: null,
      isFresh: false,
    );
  }

  @override
  String toString() {
    return 'CachedDataResult{success: $success, isFromCache: $isFromCache, isFresh: $isFresh, hasData: ${data != null}, errorMessage: $errorMessage}';
  }
}

/// Read-only data access layer for offline mode using cached user data
///
/// This provider offers read-only access to cached data when the device is offline,
/// preventing write operations to ensure data consistency. It integrates with
/// [OfflineAuthManager] to determine the current offline state and uses
/// [AuthLocalDataSource] to access cached data.
///
/// The provider provides:
/// - Read-only access to cached user profile data
/// - Read-only access to cached trip data (when available)
/// - Automatic prevention of write operations when offline
/// - Data freshness tracking (24-hour threshold)
/// - Comprehensive error handling and logging
///
/// Example usage:
/// ```dart
/// final provider = CachedDataProvider(
///   offlineAuthManager: offlineAuthManager,
///   localDataSource: localDataSource,
/// );
///
/// // Get cached user profile (works offline)
/// final result = await provider.getCachedUserProfile();
/// if (result.success && result.data != null) {
///   print('User: ${result.data!.username}');
/// }
///
/// // Try to update user (will fail if offline)
/// try {
///   await provider.updateUserProfile(updatedUser);
/// } on OfflineException catch (e) {
///   print('Cannot update while offline: $e');
/// }
/// ```
class CachedDataProvider {
  /// Manager for offline authentication state
  final OfflineAuthManager _offlineAuthManager;

  /// Local data source for accessing cached data
  final AuthLocalDataSource _localDataSource;

  /// Maximum age for cached data to be considered fresh (24 hours)
  static const Duration _maxCacheAge = Duration(hours: 24);

  /// Creates a new [CachedDataProvider]
  CachedDataProvider({
    required OfflineAuthManager offlineAuthManager,
    required AuthLocalDataSource localDataSource,
  })  : _offlineAuthManager = offlineAuthManager,
        _localDataSource = localDataSource;

  /// Gets the cached user profile
  ///
  /// Returns a [CachedDataResult] with the cached user profile if available.
  /// If offline and cached data exists, returns the cached data.
  /// If online and cached data is fresh, may return cached data.
  /// If no cached data is available, returns a result with no data.
  ///
  /// The result includes:
  /// - The user profile data (if available)
  /// - Whether the data is from cache
  /// - When the data was cached
  /// - Whether the cached data is considered fresh
  ///
  /// Example:
  /// ```dart
  /// final result = await provider.getCachedUserProfile();
  /// if (result.success && result.data != null) {
  ///   final user = result.data!;
  ///   print('User: ${user.username}');
  ///   if (result.isFromCache) {
  ///     print('Data from cache, fresh: ${result.isFresh}');
  ///   }
  /// }
  /// ```
  Future<CachedDataResult<User>> getCachedUserProfile() async {

    try {
      // Get cached user data
      final userData = await _localDataSource.getUserData();

      if (userData == null) {
        return CachedDataResult<User>.noData();
      }

      // Parse user data
      final user = _parseUserData(userData);

      if (user == null) {
        return CachedDataResult<User>.failure(
          errorMessage: 'Failed to parse cached user data',
        );
      }

      // Get cache timestamp
      DateTime? cachedAt;
      final cachedAtStr = userData['cached_at'];
      if (cachedAtStr != null && cachedAtStr is String) {
        try {
          cachedAt = DateTime.parse(cachedAtStr);
        } catch (e) {
        // intentional silent catch
        }
      }

      // Determine if cache is fresh
      final isFresh = cachedAt != null &&
          DateTime.now().difference(cachedAt) < _maxCacheAge;

      return CachedDataResult<User>.cached(
        data: user,
        cachedAt: cachedAt,
        isFresh: isFresh,
      );
    } catch (e) {

      return CachedDataResult<User>.failure(
        errorMessage: 'Failed to get cached user profile: ${e.toString()}',
      );
    }
  }

  /// Gets cached trip data
  ///
  /// Returns a [CachedDataResult] with cached trip data if available.
  /// Note: Trip caching is not yet fully implemented, so this method
  /// currently returns no data. This method is a placeholder for future
  /// trip caching functionality.
  ///
  /// When implemented, it will:
  /// - Return cached trips when offline
  /// - Support freshness tracking
  /// - Provide metadata about cache status
  ///
  /// Example:
  /// ```dart
  /// final result = await provider.getCachedTrips();
  /// if (result.success && result.data != null) {
  ///   final trips = result.data!;
  ///   print('Found ${trips.length} cached trips');
  /// }
  /// ```
  Future<CachedDataResult<List<Map<String, dynamic>>>> getCachedTrips() async {

    try {
      // Check if we're offline
      final isOffline = await _offlineAuthManager.isCurrentlyOffline();

      if (!isOffline) {
        return CachedDataResult<List<Map<String, dynamic>>>.noData();
      }

      // TODO: Implement trip caching
      // For now, return no data since trip caching is not yet implemented

      return CachedDataResult<List<Map<String, dynamic>>>.noData();
    } catch (e) {

      return CachedDataResult<List<Map<String, dynamic>>>.failure(
        errorMessage: 'Failed to get cached trips: ${e.toString()}',
      );
    }
  }

  /// Updates the user profile
  ///
  /// This method will throw an [OfflineException] if the device is currently
  /// offline, preventing write operations when offline to ensure data consistency.
  ///
  /// When online, this method would update the user profile on the server
  /// and cache the updated data locally. (Note: Server update not yet implemented)
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await provider.updateUserProfile(updatedUser);
  ///   print('Profile updated successfully');
  /// } on OfflineException catch (e) {
  ///   print('Cannot update while offline: $e');
  /// } catch (e) {
  ///   print('Update failed: $e');
  /// }
  /// ```
  Future<void> updateUserProfile(User user) async {

    // Check if offline
    final isOffline = await _offlineAuthManager.isCurrentlyOffline();

    if (isOffline) {

      throw const NetworkConnectivityException(
        message: 'Cannot update user profile while offline',
      );
    }

    try {
      // TODO: Implement server update
      // For now, just cache the updated user data locally

      final userData = {
        'id': user.id,
        'email': user.email,
        'username': user.username,
        'created_at': user.createdAt.toIso8601String(),
        'last_login_at': user.lastLoginAt?.toIso8601String(),
        'cached_at': DateTime.now().toIso8601String(),
      };

      await _localDataSource.cacheUserData(userData);

    } catch (e) {

      throw AuthException(
        'Failed to update user profile: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Creates a new trip
  ///
  /// This method will throw an [OfflineException] if the device is currently
  /// offline, preventing trip creation when offline to ensure data consistency.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await provider.createTrip(tripData);
  ///   print('Trip created successfully');
  /// } on OfflineException catch (e) {
  ///   print('Cannot create trip while offline: $e');
  /// }
  /// ```
  Future<void> createTrip(Map<String, dynamic> tripData) async {

    // Check if offline
    final isOffline = await _offlineAuthManager.isCurrentlyOffline();

    if (isOffline) {

      throw const NetworkConnectivityException(
        message: 'Cannot create trip while offline',
      );
    }

    try {
      // TODO: Implement trip creation

      throw UnimplementedError('Trip creation not yet implemented');
    } catch (e) {

      rethrow;
    }
  }

  /// Updates an existing trip
  ///
  /// This method will throw an [OfflineException] if the device is currently
  /// offline, preventing trip updates when offline to ensure data consistency.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await provider.updateTrip(tripId, tripData);
  ///   print('Trip updated successfully');
  /// } on OfflineException catch (e) {
  ///   print('Cannot update trip while offline: $e');
  /// }
  /// ```
  Future<void> updateTrip(String tripId, Map<String, dynamic> tripData) async {

    // Check if offline
    final isOffline = await _offlineAuthManager.isCurrentlyOffline();

    if (isOffline) {

      throw const NetworkConnectivityException(
        message: 'Cannot update trip while offline',
      );
    }

    try {
      // TODO: Implement trip update

      throw UnimplementedError('Trip update not yet implemented');
    } catch (e) {

      rethrow;
    }
  }

  /// Deletes a trip
  ///
  /// This method will throw an [OfflineException] if the device is currently
  /// offline, preventing trip deletion when offline to ensure data consistency.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await provider.deleteTrip(tripId);
  ///   print('Trip deleted successfully');
  /// } on OfflineException catch (e) {
  ///   print('Cannot delete trip while offline: $e');
  /// }
  /// ```
  Future<void> deleteTrip(String tripId) async {

    // Check if offline
    final isOffline = await _offlineAuthManager.isCurrentlyOffline();

    if (isOffline) {

      throw const NetworkConnectivityException(
        message: 'Cannot delete trip while offline',
      );
    }

    try {
      // TODO: Implement trip deletion

      throw UnimplementedError('Trip deletion not yet implemented');
    } catch (e) {

      rethrow;
    }
  }

  /// Checks if the device is currently offline
  ///
  /// Returns true if offline, false if online.
  /// This is a convenience method for UI components that need to know
  /// the current offline state.
  ///
  /// Example:
  /// ```dart
  /// final isOffline = await provider.isOffline();
  /// if (isOffline) {
  ///   print('Currently offline - showing cached data');
  /// } else {
  ///   print('Online - can fetch fresh data');
  /// }
  /// ```
  Future<bool> isOffline() async {
    return await _offlineAuthManager.isCurrentlyOffline();
  }

  /// Gets information about cached data
  ///
  /// Returns a map with metadata about cached data, including:
  /// - hasUserData: Whether user data is cached
  /// - hasTripData: Whether trip data is cached
  /// - userCacheAge: Age of user cache in hours (if available)
  /// - isUserCacheFresh: Whether user cache is considered fresh
  ///
  /// Example:
  /// ```dart
  /// final info = await provider.getCachedDataInfo();
  /// print('Has cached user data: ${info['hasUserData']}');
  /// print('User cache fresh: ${info['isUserCacheFresh']}');
  /// ```
  Future<Map<String, dynamic>> getCachedDataInfo() async {

    try {
      final cachedDataInfo = await _offlineAuthManager.getCachedDataInfo();

      final userData = await _localDataSource.getUserData();
      DateTime? cachedAt;

      if (userData != null) {
        final cachedAtStr = userData['cached_at'];
        if (cachedAtStr != null && cachedAtStr is String) {
          try {
            cachedAt = DateTime.parse(cachedAtStr);
          } catch (e) {
          // intentional silent catch
          }
        }
      }

      final userCacheAge = cachedAt != null
          ? DateTime.now().difference(cachedAt).inHours.toDouble()
          : null;

      return {
        'hasUserData': userData != null,
        'hasTripData': false, // Trip caching not yet implemented
        'userCacheAge': userCacheAge,
        'isUserCacheFresh': cachedDataInfo.isFresh,
        'userCachedAt': cachedAt?.toIso8601String(),
      };
    } catch (e) {

      return {
        'hasUserData': false,
        'hasTripData': false,
        'userCacheAge': null,
        'isUserCacheFresh': false,
        'userCachedAt': null,
        'error': e.toString(),
      };
    }
  }

  /// Parses user data from a map into a User entity
  ///
  /// Returns null if parsing fails.
  User? _parseUserData(Map<String, dynamic> userData) {
    try {
      return User(
        id: userData['id'] as String? ?? '',
        email: userData['email'] as String? ?? '',
        username: userData['username'] as String? ?? '',
        createdAt: userData['created_at'] != null
            ? DateTime.parse(userData['created_at'] as String)
            : DateTime.now(),
        lastLoginAt: userData['last_login_at'] != null
            ? DateTime.parse(userData['last_login_at'] as String)
            : null,
      );
    } catch (e) {
      return null;
    }
  }
}
