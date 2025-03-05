import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/services/auth_service.dart';
import 'package:soloadventurer/services/secure_storage_service.dart';

/// A service for managing user sessions, including automatic token refreshing.
class SessionManager {
  final AuthService _authService = AuthService();
  final SecureStorageService _secureStorage = SecureStorageService();

  // Token refresh timer
  Timer? _refreshTimer;

  // Default token refresh interval (45 minutes)
  static const int _defaultRefreshIntervalMinutes = 45;

  // Singleton pattern
  static final SessionManager _instance = SessionManager._internal();

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  /// Initializes the session manager.
  Future<void> initialize() async {
    await _authService.initialize();

    if (_authService.isAuthenticated) {
      _scheduleTokenRefresh();
    }
  }

  /// Starts a user session after successful login.
  Future<void> startSession() async {
    _scheduleTokenRefresh();
  }

  /// Ends the current user session.
  Future<void> endSession() async {
    _cancelTokenRefresh();
    await _authService.signOut();
  }

  /// Schedules automatic token refreshing.
  void _scheduleTokenRefresh() {
    // Cancel any existing timer
    _cancelTokenRefresh();

    // Schedule token refresh
    _refreshTimer = Timer.periodic(
      const Duration(minutes: _defaultRefreshIntervalMinutes),
      (_) => _refreshTokenIfNeeded(),
    );

    debugPrint(
        'Token refresh scheduled every $_defaultRefreshIntervalMinutes minutes');
  }

  /// Cancels the token refresh timer.
  void _cancelTokenRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Refreshes the authentication token.
  Future<bool> _refreshTokenIfNeeded() async {
    if (!_shouldRefreshToken()) return false;

    try {
      return await _refreshToken();
    } catch (e) {
      // Token refresh failed, handle accordingly
      _clearSession();
      return false;
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final result = await _authService.refreshSession();
      _updateSession(result);
      return result;
    } catch (e) {
      _clearSession();
      rethrow;
    }
  }

  /// Checks if the current session is valid.
  Future<bool> isSessionValid() async {
    if (!_authService.isAuthenticated) {
      // Try to refresh the token if we have credentials but session is invalid
      final username = await _secureStorage.getUsername();
      if (username != null) {
        return await _refreshTokenIfNeeded();
      }
      return false;
    }
    return true;
  }

  /// Forces an immediate token refresh.
  Future<bool> forceTokenRefresh() async {
    return await _refreshTokenIfNeeded();
  }

  /// Gets the current authentication token.
  Future<String?> getAuthToken() async {
    // Check if session is valid first
    if (await isSessionValid()) {
      return _authService.token;
    }
    return null;
  }

  /// Gets the current user's username.
  String? get username => _authService.username;

  /// Checks if a user is currently authenticated.
  bool get isAuthenticated => _authService.isAuthenticated;

  void _updateSession(bool result) {
    // Implementation of _updateSession method
  }

  void _clearSession() {
    // Implementation of _clearSession method
  }

  bool _shouldRefreshToken() {
    // Implementation of _shouldRefreshToken method
    return false; // Placeholder return, actual implementation needed
  }
}
