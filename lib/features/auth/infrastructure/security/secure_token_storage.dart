import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';

/// A secure storage implementation for authentication tokens
/// with additional encryption layer for defense in depth
class SecureTokenStorage {
  static const String _accessTokenKey = 'auth_access_token';
  static const String _idTokenKey = 'auth_id_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _expiresAtKey = 'auth_expires_at';
  static const String _encryptionKeyKey = 'auth_encryption_key';

  final FlutterSecureStorage _secureStorage;
  final LoggingService _logger;

  // Encryption components
  enc.Encrypter? _encrypter;
  enc.IV? _iv;

  /// Creates a new [SecureTokenStorage]
  SecureTokenStorage({
    required FlutterSecureStorage secureStorage,
    required LoggingService logger,
  })  : _secureStorage = secureStorage,
        _logger = logger;

  /// Initialize the encryption components
  /// This should be called before any other methods
  Future<void> initialize() async {
    try {
      // Generate or load a random IV — stored in SecureStorage so it persists
      // across app restarts. A new IV is generated on first run.
      String? storedIv = await _secureStorage.read(key: '_iv_key');
      if (storedIv != null) {
        _iv = enc.IV.fromBase64(storedIv);
      } else {
        // Generate a cryptographically random IV
        final random = Random.secure();
        final ivBytes = Uint8List.fromList(
          List.generate(16, (_) => random.nextInt(256)),
        );
        _iv = enc.IV(ivBytes);
        await _secureStorage.write(key: '_iv_key', value: _iv!.base64);
      }

      // Check if we have an existing encryption key
      String? storedKey = await _secureStorage.read(key: _encryptionKeyKey);

      if (storedKey == null) {
        // Generate a new encryption key
        final key = enc.Key.fromSecureRandom(32);
        await _secureStorage.write(
          key: _encryptionKeyKey,
          value: base64Encode(key.bytes),
        );
        _encrypter = enc.Encrypter(enc.AES(key));
        _logger.logAuthEvent(
          event: 'encryption_key_generated',
          status: 'success',
          metadata: {
            'message': 'Generated new encryption key for token storage'
          },
        );
      } else {
        // Use existing encryption key
        final keyBytes = base64Decode(storedKey);
        final key = enc.Key(Uint8List.fromList(keyBytes));
        _encrypter = enc.Encrypter(enc.AES(key));
        _logger.logAuthEvent(
          event: 'encryption_key_loaded',
          status: 'success',
          metadata: {
            'message': 'Using existing encryption key for token storage'
          },
        );
      }
    } catch (e, stackTrace) {
      _logger.logError(
        feature: 'SecureTokenStorage',
        error: 'Failed to initialize secure token storage: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Saves an authentication session securely
  Future<void> saveSession(AuthSession session) async {
    if (_encrypter == null || _iv == null) {
      await initialize();
    }

    try {
      // Encrypt tokens before storing
      final encryptedAccessToken =
          _encrypter!.encrypt(session.accessToken, iv: _iv!);
      final encryptedIdToken = _encrypter!.encrypt(session.idToken, iv: _iv!);
      final encryptedRefreshToken =
          _encrypter!.encrypt(session.refreshToken, iv: _iv!);

      // Store encrypted tokens
      await _secureStorage.write(
        key: _accessTokenKey,
        value: encryptedAccessToken.base64,
      );

      await _secureStorage.write(
        key: _idTokenKey,
        value: encryptedIdToken.base64,
      );

      await _secureStorage.write(
        key: _refreshTokenKey,
        value: encryptedRefreshToken.base64,
      );

      // Store expiration timestamp
      await _secureStorage.write(
        key: _expiresAtKey,
        value: session.expiresAt.millisecondsSinceEpoch.toString(),
      );

      _logger.logAuthEvent(
        event: 'session_saved',
        status: 'success',
        metadata: {'message': 'Saved encrypted session tokens'},
      );
    } catch (e, stackTrace) {
      _logger.logError(
        feature: 'SecureTokenStorage',
        error: 'Failed to save session tokens: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Retrieves the stored authentication session
  Future<AuthSession?> getSession() async {
    if (_encrypter == null || _iv == null) {
      await initialize();
    }

    try {
      // Read encrypted tokens
      final encryptedAccessToken =
          await _secureStorage.read(key: _accessTokenKey);
      final encryptedIdToken = await _secureStorage.read(key: _idTokenKey);
      final encryptedRefreshToken =
          await _secureStorage.read(key: _refreshTokenKey);
      final expiresAtString = await _secureStorage.read(key: _expiresAtKey);

      // Check if all required values exist
      if (encryptedAccessToken == null ||
          encryptedIdToken == null ||
          encryptedRefreshToken == null ||
          expiresAtString == null) {
        _logger.logAuthEvent(
          event: 'session_not_found',
          status: 'info',
          metadata: {'message': 'No complete session found in secure storage'},
        );
        return null;
      }

      // Decrypt tokens
      final accessToken = _encrypter!.decrypt64(encryptedAccessToken, iv: _iv!);
      final idToken = _encrypter!.decrypt64(encryptedIdToken, iv: _iv!);
      final refreshToken =
          _encrypter!.decrypt64(encryptedRefreshToken, iv: _iv!);

      // Parse expiration timestamp
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        int.parse(expiresAtString),
      );

      _logger.logAuthEvent(
        event: 'session_retrieved',
        status: 'success',
        metadata: {'message': 'Retrieved and decrypted session tokens'},
      );

      return AuthSession(
        accessToken: accessToken,
        idToken: idToken,
        refreshToken: refreshToken,
        expiresAt: expiresAt,
      );
    } catch (e, stackTrace) {
      _logger.logError(
        feature: 'SecureTokenStorage',
        error: 'Failed to retrieve session tokens: $e',
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Clears all stored session data
  Future<void> clearSession() async {
    try {
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _idTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _expiresAtKey);

      _logger.logAuthEvent(
        event: 'session_cleared',
        status: 'success',
        metadata: {'message': 'Cleared session tokens from secure storage'},
      );
    } catch (e, stackTrace) {
      _logger.logError(
        feature: 'SecureTokenStorage',
        error: 'Failed to clear session tokens: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Rotates the encryption key
  /// This should be called periodically for enhanced security
  Future<void> rotateEncryptionKey() async {
    try {
      // Get current session
      final currentSession = await getSession();

      // Generate new encryption key
      final newKey = enc.Key.fromSecureRandom(32);
      final newEncrypter = enc.Encrypter(enc.AES(newKey));

      // Store new key
      await _secureStorage.write(
        key: _encryptionKeyKey,
        value: base64Encode(newKey.bytes),
      );

      // Update encrypter
      _encrypter = newEncrypter;

      // Re-encrypt and save session if it exists
      if (currentSession != null) {
        await saveSession(currentSession);
      }

      _logger.logAuthEvent(
        event: 'encryption_key_rotated',
        status: 'success',
        metadata: {'message': 'Rotated encryption key for token storage'},
      );
    } catch (e, stackTrace) {
      _logger.logError(
        feature: 'SecureTokenStorage',
        error: 'Failed to rotate encryption key: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
