import 'dart:convert';
import 'package:soloadventurer/core/security/security_manager.dart';
import 'package:soloadventurer/features/auth/data/models/user_model.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';

/// Interface for local data storage operations related to authentication
abstract class AuthLocalDataSource {
  /// Caches the user data locally
  Future<void> cacheUser(User user);

  /// Retrieves the cached user data
  Future<User?> getCachedUser();

  /// Clears all cached data
  Future<void> clearCache();

  /// Saves authentication tokens and expiration
  Future<void> saveAuthData(
    String token,
    String refreshToken, {
    DateTime? expiresAt,
    String? idToken,
  });

  /// Retrieves the stored authentication token
  Future<String?> getAuthToken();

  /// Retrieves the stored ID token
  Future<String?> getIdToken();

  /// Retrieves the stored refresh token
  Future<String?> getRefreshToken();

  /// Checks if the current token is expired
  Future<bool> isTokenExpired();

  /// Gets the token expiration date
  Future<DateTime?> getTokenExpiration();

  /// Clears only authentication data (tokens and expiration) but keeps user data
  Future<void> clearAuthData();

  /// Checks if there is a valid session (has tokens and not expired)
  Future<bool> hasValidSession();

  Future<void> cacheAuthToken(String token);
  Future<void> cacheIdToken(String token);
  Future<void> cacheRefreshToken(String token);
  Future<void> cacheUserData(Map<String, dynamic> userData);
  Future<Map<String, dynamic>?> getUserData();
}

/// Implementation of [AuthLocalDataSource] using [SecurityManager]
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecurityManager _securityManager;
  static const _userKey = 'user_data';
  static const _authTokenKey = 'auth_token';
  static const _idTokenKey = 'id_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _tokenExpirationKey = 'token_expiration';

  /// Creates a new [AuthLocalDataSourceImpl] with the given security manager
  AuthLocalDataSourceImpl(this._securityManager);

  @override
  Future<void> cacheUser(User user) async {
    if (user is! UserModel) {
      throw ArgumentError('User must be a UserModel instance');
    }
    await _securityManager.write(_userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<User?> getCachedUser() async {
    final data = await _securityManager.read(_userKey);
    if (data != null) {
      return UserModel.fromJson(jsonDecode(data));
    }
    return null;
  }

  @override
  Future<void> clearCache() async {
    await _securityManager.deleteAll();
  }

  @override
  Future<void> saveAuthData(
    String token,
    String refreshToken, {
    DateTime? expiresAt,
    String? idToken,
  }) async {
    await _securityManager.write(_authTokenKey, token);
    await _securityManager.write(_refreshTokenKey, refreshToken);

    if (idToken != null) {
      await _securityManager.write(_idTokenKey, idToken);
    }

    if (expiresAt != null) {
      await _securityManager.write(
          _tokenExpirationKey, expiresAt.toIso8601String());
    }
  }

  @override
  Future<String?> getAuthToken() async {
    return await _securityManager.read(_authTokenKey);
  }

  @override
  Future<String?> getIdToken() async {
    return await _securityManager.read(_idTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _securityManager.read(_refreshTokenKey);
  }

  @override
  Future<bool> isTokenExpired() async {
    final expirationStr = await _securityManager.read(_tokenExpirationKey);
    if (expirationStr == null) return true;

    final expiration = DateTime.parse(expirationStr);
    return DateTime.now().isAfter(expiration);
  }

  @override
  Future<DateTime?> getTokenExpiration() async {
    final expiration = await _securityManager.read(_tokenExpirationKey);
    if (expiration == null) return null;

    return DateTime.parse(expiration);
  }

  @override
  Future<void> clearAuthData() async {
    await _securityManager.delete(_authTokenKey);
    await _securityManager.delete(_idTokenKey);
    await _securityManager.delete(_refreshTokenKey);
    await _securityManager.delete(_tokenExpirationKey);
  }

  @override
  Future<bool> hasValidSession() async {
    final token = await getAuthToken();
    if (token == null) return false;

    final isExpired = await isTokenExpired();
    return !isExpired;
  }

  @override
  Future<void> cacheAuthToken(String token) async {
    await _securityManager.write(_authTokenKey, token);
  }

  @override
  Future<void> cacheIdToken(String token) async {
    await _securityManager.write(_idTokenKey, token);
  }

  @override
  Future<void> cacheRefreshToken(String token) async {
    await _securityManager.write(_refreshTokenKey, token);
  }

  @override
  Future<void> cacheUserData(Map<String, dynamic> userData) async {
    await _securityManager.write(_userKey, jsonEncode(userData));
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    final data = await _securityManager.read(_userKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }
}
