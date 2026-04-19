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

/// Action to take based on session validation
enum SessionValidationAction {
  /// Session is valid and can be used immediately
  valid,

  /// Session is expired but can be refreshed (expired < 24 hours ago)
  canRefresh,

  /// Session is expired and requires re-authentication (expired > 24 hours ago)
  reauthenticate,

  /// Session data is missing or corrupted
  invalid,
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

/// Result of session validation for restoration
///
/// This class provides detailed information about the session state
/// and what action should be taken to restore the user's session.
class SessionValidationResult {
  /// The action that should be taken based on validation
  final SessionValidationAction action;

  /// The session data (if available)
  final AuthSession? session;

  /// The error that caused validation to fail (if applicable)
  final AuthException? error;

  /// How long ago the token expired (null if not expired or no session)
  final Duration? timeSinceExpiration;

  const SessionValidationResult({
    required this.action,
    this.session,
    this.error,
    this.timeSinceExpiration,
  });

  /// Creates a result for a valid session
  factory SessionValidationResult.valid(AuthSession session) {
    return SessionValidationResult(
      action: SessionValidationAction.valid,
      session: session,
    );
  }

  /// Creates a result for a session that can be refreshed
  factory SessionValidationResult.canRefresh({
    required AuthSession session,
    required Duration timeSinceExpiration,
  }) {
    return SessionValidationResult(
      action: SessionValidationAction.canRefresh,
      session: session,
      timeSinceExpiration: timeSinceExpiration,
    );
  }

  /// Creates a result for a session that requires re-authentication
  factory SessionValidationResult.reauthenticate({
    required AuthSession session,
    required Duration timeSinceExpiration,
  }) {
    return SessionValidationResult(
      action: SessionValidationAction.reauthenticate,
      session: session,
      timeSinceExpiration: timeSinceExpiration,
    );
  }

  /// Creates a result for invalid/missing session data
  factory SessionValidationResult.invalid({AuthException? error}) {
    return SessionValidationResult(
      action: SessionValidationAction.invalid,
      error: error,
    );
  }

  @override
  String toString() {
    return 'SessionValidationResult{action: $action, hasSession: ${session != null}, '
        'timeSinceExpiration: $timeSinceExpiration}';
  }
}

/// Service for managing persistent session storage using secure storage
///
/// This service provides a unified API for session persistence operations:
/// - Saving sessions with expiration timestamps
/// - Loading and validating sessions on app startup
/// - Clearing sessions on logout
/// - Using flutter_secure_storage (via SecurityManager) for token storage
/// - Session caching for improved performance
///
/// The service acts as a wrapper around [AuthLocalDataSource] and provides
/// additional validation and error handling for session operations.
class PersistentSessionManager {
  /// Local data source for secure token storage
  final AuthLocalDataSource _localDataSource;

  /// Storage keys for session metadata
  static const String _currentSessionVersion = '1.0';

  /// Cache for loaded session to avoid repeated storage reads
  AuthSession? _cachedSession;

  /// Timestamp when cache was last updated
  DateTime? _cacheTimestamp;

  /// Cache validity duration (5 minutes)
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  /// Creates a new [PersistentSessionManager]
  PersistentSessionManager({
    required AuthLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  /// Saves a session with tokens and expiration timestamp to secure storage
  ///
  /// This method saves the access token, ID token, refresh token, and expiration
  /// timestamp to secure storage. It also stores a session version for future
  /// migration purposes. The session is also cached for faster subsequent access.
  ///
  /// Throws [AuthException] if saving fails.
  Future<void> saveSession(AuthSession session) async {
    try {
      if (kDebugMode) {
      }

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

      // Update cache
      _cachedSession = session;
      _cacheTimestamp = DateTime.now();

      if (kDebugMode) {
      }
    } catch (e) {
      if (kDebugMode) {
      }
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
  /// - Uses cache if available and valid
  ///
  /// Returns null if no valid session exists.
  /// Throws [AuthException] if loading fails.
  Future<AuthSession?> loadSession() async {
    try {
      // Check if we have a valid cached session
      if (_isCacheValid()) {
        if (kDebugMode) {
        }
        return _cachedSession;
      }

      if (kDebugMode) {
      }

      // Get all session components
      final accessToken = await _localDataSource.getAuthToken();
      final idToken = await _localDataSource.getIdToken();
      final refreshToken = await _localDataSource.getRefreshToken();
      final expiresAt = await _localDataSource.getTokenExpiration();

      if (kDebugMode) {
      }

      // Validate we have all required data
      if (accessToken == null || refreshToken == null || expiresAt == null) {
        if (kDebugMode) {
        }
        return null;
      }

      // Construct session
      final session = AuthSession(
        accessToken: accessToken,
        idToken: idToken ?? '',
        refreshToken: refreshToken,
        expiresAt: expiresAt,
      );

      // Update cache
      _cachedSession = session;
      _cacheTimestamp = DateTime.now();

      if (kDebugMode) {
      }
      return session;
    } catch (e) {
      if (kDebugMode) {
      }
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

      // Load the session
      final session = await loadSession();

      if (session == null) {
        return SessionOperationResult.validated(isValid: false);
      }

      // Check if token is expired
      final isExpired = DateTime.now().isAfter(session.expiresAt);

      if (isExpired) {
        return SessionOperationResult.validated(
          isValid: false,
          session: session,
        );
      }

      // Calculate time until expiration
      session.expiresAt.difference(DateTime.now());

      return SessionOperationResult.validated(
        isValid: true,
        session: session,
      );
    } catch (e) {
      return SessionOperationResult.failure(
        AuthException(
          'Failed to validate session: ${e.toString()}',
          code: 'SESSION_VALIDATION_FAILED',
        ),
      );
    }
  }

  /// Validates a session for restoration and determines the required action
  ///
  /// This method validates the stored session and determines what action
  /// should be taken to restore the user's session:
  ///
  /// - **valid**: Session is not expired, can be used immediately
  /// - **canRefresh**: Session expired less than 24 hours ago, can be refreshed
  /// - **reauthenticate**: Session expired more than 24 hours ago, user must re-authenticate
  /// - **invalid**: Session data is missing or corrupted
  ///
  /// Returns a [SessionValidationResult] with the action and session data.
  Future<SessionValidationResult> validateSessionForRestoration() async {
    try {

      // Load the session
      final session = await loadSession();

      // Handle missing or corrupted session data
      if (session == null) {
        return SessionValidationResult.invalid(
          error: const AuthException(
            'No valid session found in storage',
            code: 'NO_SESSION',
          ),
        );
      }

      // Check if token is expired
      final now = DateTime.now();
      final isExpired = now.isAfter(session.expiresAt);

      if (!isExpired) {
        // Session is valid
        session.expiresAt.difference(now);
        return SessionValidationResult.valid(session);
      }

      // Token is expired, calculate how long ago
      final timeSinceExpiration = now.difference(session.expiresAt);

      // Determine if we can refresh or need re-authentication
      // AWS Cognito refresh tokens are typically valid for 30 days,
      // but we use 24 hours as a safety threshold
      const refreshThreshold = Duration(hours: 24);

      if (timeSinceExpiration <= refreshThreshold) {
        return SessionValidationResult.canRefresh(
          session: session,
          timeSinceExpiration: timeSinceExpiration,
        );
      } else {
        return SessionValidationResult.reauthenticate(
          session: session,
          timeSinceExpiration: timeSinceExpiration,
        );
      }
    } catch (e) {
      return SessionValidationResult.invalid(
        error: AuthException(
          'Failed to validate session: ${e.toString()}',
          code: 'SESSION_VALIDATION_FAILED',
        ),
      );
    }
  }

  /// Clears the current session from secure storage
  ///
  /// This method removes all tokens and session data from secure storage.
  /// It also clears the session cache. It should be called on logout.
  ///
  /// Throws [AuthException] if clearing fails.
  Future<void> clearSession() async {
    try {
      if (kDebugMode) {
      }

      await _localDataSource.clearAuthData();

      // Clear cache
      _cachedSession = null;
      _cacheTimestamp = null;

      if (kDebugMode) {
      }
    } catch (e) {
      if (kDebugMode) {
      }
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
      return hasSession;
    } catch (e) {
      return false;
    }
  }

  /// Gets the token expiration timestamp from storage
  ///
  /// Returns null if no expiration timestamp is stored.
  Future<DateTime?> getTokenExpiration() async {
    try {
      final expiration = await _localDataSource.getTokenExpiration();
      return expiration;
    } catch (e) {
      return null;
    }
  }

  /// Checks if the stored token is expired
  ///
  /// Returns true if the token is expired or if there's no token.
  Future<bool> isTokenExpired() async {
    try {
      final isExpired = await _localDataSource.isTokenExpired();
      return isExpired;
    } catch (e) {
      return true; // Assume expired on error
    }
  }


  /// Checks if the cached session is still valid
  ///
  /// A cached session is valid if:
  /// - A cached session exists
  /// - The cache timestamp is not too old (< 5 minutes)
  /// - The session itself is not expired
  bool _isCacheValid() {
    if (_cachedSession == null || _cacheTimestamp == null) {
      return false;
    }

    // Check if cache is too old
    final cacheAge = DateTime.now().difference(_cacheTimestamp!);
    if (cacheAge > _cacheValidDuration) {
      if (kDebugMode) {
      }
      return false;
    }

    // Check if session is expired
    final isExpired = DateTime.now().isAfter(_cachedSession!.expiresAt);
    if (isExpired) {
      if (kDebugMode) {
      }
      return false;
    }

    return true;
  }

  /// Clears the session cache
  ///
  /// This method clears the in-memory cache without touching secure storage.
  /// Use this when you need to force a reload from storage.
  void clearCache() {
    if (kDebugMode) {
    }
    _cachedSession = null;
    _cacheTimestamp = null;
  }

  /// Gets the current access token from storage
  ///
  /// Returns null if no access token is stored.
  Future<String?> getAccessToken() async {
    try {
      final token = await _localDataSource.getAuthToken();
      if (token != null && kDebugMode) {
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
      }
      return null;
    }
  }

  /// Gets the current ID token from storage
  ///
  /// Returns null if no ID token is stored.
  Future<String?> getIdToken() async {
    try {
      final token = await _localDataSource.getIdToken();
      if (token != null && kDebugMode) {
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
      }
      return null;
    }
  }

  /// Gets the current refresh token from storage
  ///
  /// Returns null if no refresh token is stored.
  Future<String?> getRefreshToken() async {
    try {
      final token = await _localDataSource.getRefreshToken();
      if (token != null && kDebugMode) {
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
      }
      return null;
    }
  }
}
