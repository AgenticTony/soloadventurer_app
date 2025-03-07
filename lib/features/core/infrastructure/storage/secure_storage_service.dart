import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A service for securely storing sensitive data
class SecureStorageService {
  final FlutterSecureStorage _storage;

  // Keys for stored values
  static const String _usernameKey = 'username';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _accessTokenKey = 'accessToken';
  static const String _idTokenKey = 'idToken';

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Store the username
  Future<void> storeUsername(String username) async {
    await _storage.write(key: _usernameKey, value: username);
  }

  /// Get the stored username
  Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  /// Store the refresh token
  Future<void> storeRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Get the stored refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Store the access token
  Future<void> storeAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Get the stored access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Store the ID token
  Future<void> storeIdToken(String token) async {
    await _storage.write(key: _idTokenKey, value: token);
  }

  /// Get the stored ID token
  Future<String?> getIdToken() async {
    return await _storage.read(key: _idTokenKey);
  }

  /// Clear all stored values
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Clear specific stored value
  Future<void> clear(String key) async {
    await _storage.delete(key: key);
  }
}
