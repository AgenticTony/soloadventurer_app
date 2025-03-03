import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';

/// Interface for local authentication data source
abstract class AuthLocalDataSource {
  /// Get the current user from local storage
  Future<User?> getUser();

  /// Save the user to local storage
  Future<void> saveUser(User user);

  /// Clear the user from local storage
  Future<void> clearUser();

  /// Get the access token from local storage
  Future<String?> getAccessToken();

  /// Save the access token to local storage
  Future<void> saveAccessToken(String token);

  /// Get the refresh token from local storage
  Future<String?> getRefreshToken();

  /// Save the refresh token to local storage
  Future<void> saveRefreshToken(String token);

  /// Clear all authentication data from local storage
  Future<void> clearAuthData();
}

/// Implementation of [AuthLocalDataSource] using secure storage
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;

  /// Key for storing the user in secure storage
  static const String _userKey = 'user';

  /// Key for storing the access token in secure storage
  static const String _accessTokenKey = 'access_token';

  /// Key for storing the refresh token in secure storage
  static const String _refreshTokenKey = 'refresh_token';

  /// Creates a new [AuthLocalDataSourceImpl] with the given [FlutterSecureStorage]
  AuthLocalDataSourceImpl({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<User?> getUser() async {
    final userJson = await _secureStorage.read(key: _userKey);
    if (userJson == null) return null;

    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User(
        id: userMap['id'] as String,
        email: userMap['email'] as String,
        username: userMap['username'] as String,
        createdAt: DateTime.parse(userMap['created_at'] as String),
        lastLoginAt: userMap['last_login_at'] != null
            ? DateTime.parse(userMap['last_login_at'] as String)
            : null,
      );
    } catch (e) {
      // If there's an error parsing the user, clear it and return null
      await clearUser();
      return null;
    }
  }

  @override
  Future<void> saveUser(User user) async {
    final userMap = {
      'id': user.id,
      'email': user.email,
      'username': user.username,
      'created_at': user.createdAt.toIso8601String(),
      'last_login_at': user.lastLoginAt?.toIso8601String(),
    };

    await _secureStorage.write(
      key: _userKey,
      value: jsonEncode(userMap),
    );
  }

  @override
  Future<void> clearUser() async {
    await _secureStorage.delete(key: _userKey);
  }

  @override
  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: _accessTokenKey);
  }

  @override
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: _accessTokenKey, value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  @override
  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: _userKey);
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }
}
