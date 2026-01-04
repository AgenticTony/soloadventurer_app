import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';

/// Result of a session operation
enum SessionOperationStatus {
  /// Session was successfully saved
  saved,

  /// Session was successfully loaded
  loaded,

  /// Session was successfully cleared
  cleared,

  /// Session was validated
  validated,

  /// Operation failed
  failed,
}

/// Result of a session operation
class SessionOperationResult {
  /// The status of the operation
  final SessionOperationStatus status;

  /// The session data (for load and validate operations)
  final AuthSession? session;

  /// Whether the session is valid (for validate operations)
  final bool isValid;

  /// The error that caused the operation to fail
  final AuthException? error;

  const SessionOperationResult({
    required this.status,
    this.session,
    this.isValid = false,
    this.error,
  });

  /// Creates a success result for save operations
  factory SessionOperationResult.saved() {
    return const SessionOperationResult(
      status: SessionOperationStatus.saved,
    );
  }

  /// Creates a success result for load operations
  factory SessionOperationResult.loaded(AuthSession session) {
    return SessionOperationResult(
      status: SessionOperationStatus.loaded,
      session: session,
      isValid: true,
    );
  }

  /// Creates a success result for clear operations
  factory SessionOperationResult.cleared() {
    return const SessionOperationResult(
      status: SessionOperationStatus.cleared,
    );
  }

  /// Creates a success result for validate operations
  factory SessionOperationResult.validated({
    required bool isValid,
    AuthSession? session,
  }) {
    return SessionOperationResult(
      status: SessionOperationStatus.validated,
      isValid: isValid,
      session: session,
    );
  }

  /// Creates a failure result
  factory SessionOperationResult.failure(AuthException error) {
    return SessionOperationResult(
      status: SessionOperationStatus.failed,
      error: error,
    );
  }

  @override
  String toString() {
    return 'SessionOperationResult{status: $status, isValid: $isValid, hasSession: ${session != null}}';
  }
}

/// Service for managing persistent session storage using secure storage
///
/// This service provides a unified API for session persistence operations:
/// - Saving sessions with expiration timestamps
/// - Loading and validating sessions on app startup
/// - Clearing sessions on logout
/// - Using flutter_secure_storage (via SecurityManager) for token storage
///
/// The service acts as a wrapper around [AuthLocalDataSource] and provides
/// additional validation and error handling for session operations.
class PersistentSessionManager {
  /// Local data source for secure token storage
  final AuthLocalDataSource _localDataSource;

  /// Storage keys for session metadata
  static const String _sessionVersionKey = 'session_version';
  static const String _currentSessionVersion = '1.0';

  /// Creates a new [PersistentSessionManager]
  PersistentSessionManager({
    required AuthLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  /// Saves a session with tokens and expiration timestamp to secure storage
  ///
  /// This method saves the access token, ID token, refresh token, and expiration
  /// timestamp to secure storage. It also stores a session version for future
  /// migration purposes.
  ///
  /// Throws [AuthException] if saving fails.
  Future<void> saveSession(AuthSession session) async {
    try {
      debugPrint('PersistentSessionManager: Saving session');
      debugPrint('  - Access token: ${_maskToken(session.accessToken)}');
      debugPrint('  - ID token: ${_maskToken(session.idToken)}');
      debugPrint('  - Refresh token: ${_maskToken(session.refreshToken)}');
      debugPrint('  - Expires at: ${session.expiresAt.toIso8601String()}');

      // Save tokens and expiration to secure storage
      await _localDataSource.saveAuthData(
        session.accessToken,
        session.refreshToken,
        expiresAt: session.expiresAt,
        idToken: session.idToken,
      );

      // Save session version for migration purposes
      await _localDataSource.cacheUserData({
        'version': _currentSessionVersion,
        'saved_at': DateTime.now().toIso8601String(),
      });

      debugPrint('PersistentSessionManager: Session saved successfully');
    } catch (e) {
      debugPrint('PersistentSessionManager: Failed to save session: $e');
      throw AuthException(
        'Failed to save session: ${e.toString()}',
        code: 'SESSION_SAVE_FAILED',
      );
    }
  }

  /// Loads and validates a session from secure storage
  ///
  /// This method retrieves the stored tokens and validates them:
  /// - Checks if all required tokens are present
  /// - Validates the expiration timestamp
  /// - Returns the session if valid, null otherwise
  ///
  /// Returns null if no valid session exists.
  /// Throws [AuthException] if loading fails.
  Future<AuthSession?> loadSession() async {
    try {
      debugPrint('PersistentSessionManager: Loading session from storage');

      // Get all session components
      final accessToken = await _localDataSource.getAuthToken();
      final idToken = await _localDataSource.getIdToken();
      final refreshToken = await _localDataSource.getRefreshToken();
      final expiresAt = await _localDataSource.getTokenExpiration();

      debugPrint('PersistentSessionManager: Retrieved data:');
      debugPrint('  - Has access token: ${accessToken != null}');
      debugPrint('  - Has ID token: ${idToken != null}');
      debugPrint('  - Has refresh token: ${refreshToken != null}');
      debugPrint('  - Expires at: ${expiresAt?.toIso8601String() ?? "null"}');

      // Validate we have all required data
      if (accessToken == null || refreshToken == null || expiresAt == null) {
        debugPrint('PersistentSessionManager: Missing required session data');
        return null;
      }

      // Construct session
      final session = AuthSession(
        accessToken: accessToken,
        idToken: idToken ?? '',
        refreshToken: refreshToken,
        expiresAt: expiresAt,
      );

      debugPrint('PersistentSessionManager: Session loaded successfully');
      return session;
    } catch (e) {
      debugPrint('PersistentSessionManager: Failed to load session: $e');
      throw AuthException(
        'Failed to load session: ${e.toString()}',
        code: 'SESSION_LOAD_FAILED',
      );
    }
  }

  /// Validates a session and returns whether it's still valid
  ///
  /// A session is considered valid if:
  /// - The token has not expired
  /// - All required tokens are present
  ///
  /// Returns a [SessionOperationResult] with validation status and session data.
  Future<SessionOperationResult> validateSession() async {
    try {
      debugPrint('PersistentSessionManager: Validating session');

      // Load the session
      final session = await loadSession();

      if (session == null) {
        debugPrint('PersistentSessionManager: No session found');
        return SessionOperationResult.validated(isValid: false);
      }

      // Check if token is expired
      final isExpired = DateTime.now().isAfter(session.expiresAt);

      if (isExpired) {
        debugPrint('PersistentSessionManager: Session expired at ${session.expiresAt.toIso8601String()}');
        debugPrint('PersistentSessionManager: Current time: ${DateTime.now().toIso8601String()}');
        return SessionOperationResult.validated(
          isValid: false,
          session: session,
        );
      }

      // Calculate time until expiration
      final timeUntilExpiration = session.expiresAt.difference(DateTime.now());
      debugPrint('PersistentSessionManager: Session is valid');
      debugPrint('  - Expires in: ${timeUntilExpiration.inMinutes} minutes');

      return SessionOperationResult.validated(
        isValid: true,
        session: session,
      );
    } catch (e) {
      debugPrint('PersistentSessionManager: Failed to validate session: $e');
      return SessionOperationResult.failure(
        AuthException(
          'Failed to validate session: ${e.toString()}',
          code: 'SESSION_VALIDATION_FAILED',
        ),
      );
    }
  }

  /// Clears the current session from secure storage
  ///
  /// This method removes all tokens and session data from secure storage.
  /// It should be called on logout.
  ///
  /// Throws [AuthException] if clearing fails.
  Future<void> clearSession() async {
    try {
      debugPrint('PersistentSessionManager: Clearing session');

      await _localDataSource.clearAuthData();

      debugPrint('PersistentSessionManager: Session cleared successfully');
    } catch (e) {
      debugPrint('PersistentSessionManager: Failed to clear session: $e');
      throw AuthException(
        'Failed to clear session: ${e.toString()}',
        code: 'SESSION_CLEAR_FAILED',
      );
    }
  }

  /// Checks if a valid session exists in storage
  ///
  /// This is a convenience method that returns a boolean indicating
  /// whether a valid session exists without loading the full session data.
  Future<bool> hasValidSession() async {
    try {
      final hasSession = await _localDataSource.hasValidSession();
      debugPrint('PersistentSessionManager: Has valid session: $hasSession');
      return hasSession;
    } catch (e) {
      debugPrint('PersistentSessionManager: Error checking session validity: $e');
      return false;
    }
  }

  /// Gets the token expiration timestamp from storage
  ///
  /// Returns null if no expiration timestamp is stored.
  Future<DateTime?> getTokenExpiration() async {
    try {
      final expiration = await _localDataSource.getTokenExpiration();
      debugPrint('PersistentSessionManager: Token expiration: ${expiration?.toIso8601String() ?? "null"}');
      return expiration;
    } catch (e) {
      debugPrint('PersistentSessionManager: Failed to get token expiration: $e');
      return null;
    }
  }

  /// Checks if the stored token is expired
  ///
  /// Returns true if the token is expired or if there's no token.
  Future<bool> isTokenExpired() async {
    try {
      final isExpired = await _localDataSource.isTokenExpired();
      debugPrint('PersistentSessionManager: Is token expired: $isExpired');
      return isExpired;
    } catch (e) {
      debugPrint('PersistentSessionManager: Error checking token expiration: $e');
      return true; // Assume expired on error
    }
  }

  /// Masks a token for safe logging (shows first 8 and last 4 characters)
  String _maskToken(String token) {
    if (token.length <= 12) {
      return '****';
    }
    final start = token.substring(0, 8);
    final end = token.substring(token.length - 4);
    return '$start...$end (${token.length} chars)';
  }

  /// Gets the current access token from storage
  ///
  /// Returns null if no access token is stored.
  Future<String?> getAccessToken() async {
    try {
      final token = await _localDataSource.getAuthToken();
      if (token != null) {
        debugPrint('PersistentSessionManager: Retrieved access token: ${_maskToken(token)}');
      }
      return token;
    } catch (e) {
      debugPrint('PersistentSessionManager: Failed to get access token: $e');
      return null;
    }
  }

  /// Gets the current ID token from storage
  ///
  /// Returns null if no ID token is stored.
  Future<String?> getIdToken() async {
    try {
      final token = await _localDataSource.getIdToken();
      if (token != null) {
        debugPrint('PersistentSessionManager: Retrieved ID token: ${_maskToken(token)}');
      }
      return token;
    } catch (e) {
      debugPrint('PersistentSessionManager: Failed to get ID token: $e');
      return null;
    }
  }

  /// Gets the current refresh token from storage
  ///
  /// Returns null if no refresh token is stored.
  Future<String?> getRefreshToken() async {
    try {
      final token = await _localDataSource.getRefreshToken();
      if (token != null) {
        debugPrint('PersistentSessionManager: Retrieved refresh token: ${_maskToken(token)}');
      }
      return token;
    } catch (e) {
      debugPrint('PersistentSessionManager: Failed to get refresh token: $e');
      return null;
    }
  }
}
