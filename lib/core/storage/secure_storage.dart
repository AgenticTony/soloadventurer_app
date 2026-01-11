import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage.g.dart';

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
          aOptions: AndroidOptions(),
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

/// A simple wrapper around FlutterSecureStorage for secure data storage
class SecureStorage {
  final FlutterSecureStorage _storage;

  /// Creates a new [SecureStorage] instance
  SecureStorage() : _storage = const FlutterSecureStorage();

  /// Deletes a value from storage
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Reads a value from storage
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// Writes a value to storage
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Deletes all values from storage
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// Checks if a key exists in storage
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }
}

/// Provider for SecureStorage
@riverpod
SecureStorage secureStorage(Ref ref) {
  return SecureStorage();
}
