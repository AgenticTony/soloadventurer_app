import 'dart:convert';
import 'package:soloadventurer/core/security/security_manager.dart';
import 'package:soloadventurer/core/security/encryption_service.dart';
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
  Future<void> saveAuthData(String token, String refreshToken,
      {DateTime? expiresAt});

  /// Retrieves the stored authentication token
  Future<String?> getAuthToken();

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
  Future<void> cacheRefreshToken(String token);
  Future<void> cacheUserData(Map<String, dynamic> userData);
  Future<Map<String, dynamic>?> getUserData();
}

/// Implementation of [AuthLocalDataSource] using [SecurityManager]
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecurityManager _securityManager;
  final EncryptionService _encryptionService;
  static const _userKey = 'user_data';
  static const _authTokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _tokenExpirationKey = 'token_expiration';

  /// Creates a new [AuthLocalDataSourceImpl] with the given security manager
  AuthLocalDataSourceImpl(this._securityManager, this._encryptionService);

  @override
  Future<void> cacheUser(User user) async {
    if (user is! UserModel) {
      throw ArgumentError('User must be a UserModel instance');
    }
    final encryptedData =
        await _encryptionService.encrypt(jsonEncode(user.toJson()));
    await _securityManager.write(_userKey, encryptedData);
  }

  @override
  Future<User?> getCachedUser() async {
    final encryptedData = await _securityManager.read(_userKey);
    if (encryptedData != null) {
      final decryptedData = await _encryptionService.decrypt(encryptedData);
      return UserModel.fromJson(jsonDecode(decryptedData));
    }
    return null;
  }

  @override
  Future<void> clearCache() async {
    await _securityManager.deleteAll();
  }

  @override
  Future<void> saveAuthData(String token, String refreshToken,
      {DateTime? expiresAt}) async {
    final encryptedToken = await _encryptionService.encrypt(token);
    final encryptedRefreshToken =
        await _encryptionService.encrypt(refreshToken);
    await _securityManager.write(_authTokenKey, encryptedToken);
    await _securityManager.write(_refreshTokenKey, encryptedRefreshToken);

    if (expiresAt != null) {
      final encryptedExpiration =
          await _encryptionService.encrypt(expiresAt.toIso8601String());
      await _securityManager.write(_tokenExpirationKey, encryptedExpiration);
    }
  }

  @override
  Future<String?> getAuthToken() async {
    final encryptedToken = await _securityManager.read(_authTokenKey);
    if (encryptedToken == null) return null;
    return await _encryptionService.decrypt(encryptedToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    final encryptedToken = await _securityManager.read(_refreshTokenKey);
    if (encryptedToken == null) return null;
    return await _encryptionService.decrypt(encryptedToken);
  }

  @override
  Future<bool> isTokenExpired() async {
    final expirationStr = await _securityManager.read(_tokenExpirationKey);
    if (expirationStr == null) return true;

    final decryptedExpiration = await _encryptionService.decrypt(expirationStr);
    final expiration = DateTime.parse(decryptedExpiration);
    return DateTime.now().isAfter(expiration);
  }

  @override
  Future<DateTime?> getTokenExpiration() async {
    final encryptedExpiration =
        await _securityManager.read(_tokenExpirationKey);
    if (encryptedExpiration == null) return null;

    final decryptedExpiration =
        await _encryptionService.decrypt(encryptedExpiration);
    return DateTime.parse(decryptedExpiration);
  }

  @override
  Future<void> clearAuthData() async {
    await _securityManager.delete(_authTokenKey);
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
    final encrypted = await _encryptionService.encrypt(token);
    await _securityManager.write('auth_token', encrypted);
  }

  @override
  Future<void> cacheRefreshToken(String token) async {
    final encrypted = await _encryptionService.encrypt(token);
    await _securityManager.write('refresh_token', encrypted);
  }

  @override
  Future<void> cacheUserData(Map<String, dynamic> userData) async {
    final encrypted = await _encryptionService.encrypt(userData.toString());
    await _securityManager.write('user_data', encrypted);
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    final encrypted = await _securityManager.read('user_data');
    if (encrypted == null) return null;
    final decrypted = await _encryptionService.decrypt(encrypted);
    // Convert string back to map
    return Map<String, dynamic>.from(decrypted as Map);
  }
}
