import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A service for securely storing sensitive information like tokens and credentials.
class SecureStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _usernameKey = 'username';
  static const String _userIdKey = 'user_id';

  final FlutterSecureStorage _secureStorage;

  // Singleton pattern
  static final SecureStorageService _instance =
      SecureStorageService._internal();

  factory SecureStorageService() {
    return _instance;
  }

  SecureStorageService._internal()
      : _secureStorage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );

  /// Stores the authentication token securely.
  Future<void> storeAuthToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Retrieves the stored authentication token.
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Stores the refresh token securely.
  Future<void> storeRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  /// Retrieves the stored refresh token.
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// Stores the username securely.
  Future<void> storeUsername(String username) async {
    await _secureStorage.write(key: _usernameKey, value: username);
  }

  /// Retrieves the stored username.
  Future<String?> getUsername() async {
    return await _secureStorage.read(key: _usernameKey);
  }

  /// Stores the user ID securely.
  Future<void> storeUserId(String userId) async {
    await _secureStorage.write(key: _userIdKey, value: userId);
  }

  /// Retrieves the stored user ID.
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  /// Stores a custom value securely.
  Future<void> storeValue(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// Retrieves a custom stored value.
  Future<String?> getValue(String key) async {
    return await _secureStorage.read(key: key);
  }

  /// Deletes a specific stored value.
  Future<void> deleteValue(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// Clears all authentication related data.
  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _usernameKey);
    await _secureStorage.delete(key: _userIdKey);
  }

  /// Clears all stored data.
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}
