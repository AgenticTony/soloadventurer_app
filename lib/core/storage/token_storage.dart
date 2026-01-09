import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Centralized token storage using flutter_secure_storage 9.2.4 (latest stable)
///
/// Features:
/// - Encrypted storage on both Android and iOS
/// - Android: Uses EncryptedSharedPreferences (AES encryption)
/// - iOS: Uses Keychain with first_unlock_this_device accessibility
class TokenStorage {
  // Singleton instance
  static final TokenStorage _instance = TokenStorage._internal();
  factory TokenStorage() => _instance;
  TokenStorage._internal();

  // Storage instance with platform-specific options
  // NOTE: 9.2.4 does NOT support sharedPreferencesName or preferencesKeyPrefix
  // Those are 10.0.0-beta features only
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
        // resetOnError: true, // Uncomment if you want to reset on decryption errors
        ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      // accountName is supported in 9.2.4
      accountName: 'SoloAdventurer',
    ),
  );

  // Storage Keys
  static const _accessTokenKey = 'sa_access_token';
  static const _refreshTokenKey = 'sa_refresh_token';
  static const _tokenExpiryKey = 'sa_token_expiry';
  static const _userIdKey = 'sa_user_id';

  /// Save authentication tokens
  ///
  /// Stores access token, refresh token, and optional expiry time
  /// All values are encrypted at rest
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    DateTime? expiry,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      if (expiry != null)
        _storage.write(key: _tokenExpiryKey, value: expiry.toIso8601String()),
    ]);
  }

  /// Get access token
  ///
  /// Returns null if no token is stored
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Get refresh token
  ///
  /// Returns null if no token is stored
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Get token expiry time
  ///
  /// Returns null if no expiry is stored
  Future<DateTime?> getTokenExpiry() async {
    final expiryStr = await _storage.read(key: _tokenExpiryKey);
    if (expiryStr == null) return null;
    return DateTime.tryParse(expiryStr);
  }

  /// Check if tokens exist in storage
  Future<bool> hasTokens() async {
    final token = await _storage.read(key: _accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Check if the stored token is expired
  ///
  /// Returns true if:
  /// - No expiry time is stored
  /// - Current time is after expiry time
  Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry);
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  /// Get stored user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Clear all authentication tokens (logout)
  ///
  /// Removes access token, refresh token, expiry, and user ID
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _tokenExpiryKey),
      _storage.delete(key: _userIdKey),
    ]);
  }

  /// Clear ALL secure storage (full reset)
  ///
  /// Use with caution - removes everything from secure storage
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Check if storage contains a specific key
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  /// Read all keys (for debugging only - don't use in production)
  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }
}
