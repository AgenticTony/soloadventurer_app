import 'dart:convert';
import 'package:soloadventurer/core/storage/secure_storage.dart';
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

  Future<void> setAuthToken(String token);
  Future<void> setIdToken(String idToken);
  Future<void> setRefreshToken(String refreshToken);
  Future<void> setTokenExpiration(DateTime expiration);
  Future<void> clearSession();
}

/// Implementation of [AuthLocalDataSource] using [SecureStorage] and SharedPreferences
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorage _secureStorage;
  static const _userKey = 'user_data';
  static const _authTokenKey = 'auth_token';
  static const _idTokenKey = 'id_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _tokenExpirationKey = 'token_expiration';

  /// Creates a new [AuthLocalDataSourceImpl] with the given secure storage and shared preferences
  AuthLocalDataSourceImpl(this._secureStorage);

  @override
  Future<void> cacheUser(User user) async {
    if (user is! UserModel) {
      throw ArgumentError('User must be a UserModel instance');
    }
    await _secureStorage.write(_userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<User?> getCachedUser() async {
    final data = await _secureStorage.read(_userKey);
    if (data != null) {
      return UserModel.fromJson(jsonDecode(data));
    }
    return null;
  }

  @override
  Future<void> clearCache() async {
    await _secureStorage.deleteAll();
  }

  @override
  Future<void> saveAuthData(
    String token,
    String refreshToken, {
    DateTime? expiresAt,
    String? idToken,
  }) async {
    await _secureStorage.write(_authTokenKey, token);
    await _secureStorage.write(_refreshTokenKey, refreshToken);

    if (idToken != null) {
      await _secureStorage.write(_idTokenKey, idToken);
    }

    if (expiresAt != null) {
      await _secureStorage.write(
          _tokenExpirationKey, expiresAt.toIso8601String());
    }
  }

  @override
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(_authTokenKey);
  }

  @override
  Future<String?> getIdToken() async {
    return await _secureStorage.read(_idTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(_refreshTokenKey);
  }

  @override
  Future<bool> isTokenExpired() async {
    final expirationStr = await _secureStorage.read(_tokenExpirationKey);
    if (expirationStr == null) return true;

    final expiration = DateTime.parse(expirationStr);
    return DateTime.now().isAfter(expiration);
  }

  @override
  Future<DateTime?> getTokenExpiration() async {
    final expiration = await _secureStorage.read(_tokenExpirationKey);
    if (expiration == null) return null;

    return DateTime.parse(expiration);
  }

  @override
  Future<void> clearAuthData() async {
    await _secureStorage.delete(_authTokenKey);
    await _secureStorage.delete(_idTokenKey);
    await _secureStorage.delete(_refreshTokenKey);
    await _secureStorage.delete(_tokenExpirationKey);
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
    await _secureStorage.write(_authTokenKey, token);
  }

  @override
  Future<void> cacheIdToken(String token) async {
    await _secureStorage.write(_idTokenKey, token);
  }

  @override
  Future<void> cacheRefreshToken(String token) async {
    await _secureStorage.write(_refreshTokenKey, token);
  }

  @override
  Future<void> cacheUserData(Map<String, dynamic> userData) async {
    await _secureStorage.write(_userKey, jsonEncode(userData));
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    final data = await _secureStorage.read(_userKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  @override
  Future<void> setAuthToken(String token) async {
    await _secureStorage.write(_authTokenKey, token);
  }

  @override
  Future<void> setIdToken(String idToken) async {
    await _secureStorage.write(_idTokenKey, idToken);
  }

  @override
  Future<void> setRefreshToken(String refreshToken) async {
    await _secureStorage.write(_refreshTokenKey, refreshToken);
  }

  @override
  Future<void> setTokenExpiration(DateTime expiration) async {
    await _secureStorage.write(
        _tokenExpirationKey, expiration.millisecondsSinceEpoch.toString());
  }

  @override
  Future<void> clearSession() async {
    await Future.wait([
      _secureStorage.delete(_authTokenKey),
      _secureStorage.delete(_idTokenKey),
      _secureStorage.delete(_refreshTokenKey),
      _secureStorage.delete(_tokenExpirationKey),
    ]);
  }
}
