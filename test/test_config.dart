import 'package:flutter/foundation.dart';

/// Configuration for integration tests
///
/// **WARNING:** This file contains test credentials and should NEVER
/// be used in production builds. All constants are guarded by [kDebugMode].
class TestConfig {
  TestConfig._();

  static bool get _debugGuard {
    if (kReleaseMode) {
      throw StateError(
        'TestConfig must not be used in release builds. '
        'This indicates a misconfigured build.',
      );
    }
    return true;
  }

  /// The base URL for the API in test mode
  static String get apiBaseUrl {
    assert(_debugGuard);
    return 'https://api-test.soloadventurer.com';
  }

  /// Test user credentials
  static String get testEmail {
    assert(_debugGuard);
    return 'test@example.com';
  }

  static String get testPassword {
    assert(_debugGuard);
    return 'password123';
  }

  static String get testName => 'Test User';

  /// Simulated network delay for mock repositories
  static Duration get stepDelay {
    assert(_debugGuard);
    return const Duration(milliseconds: 10);
  }

  /// Generate a unique test email address
  static String generateTestEmail() {
    assert(_debugGuard);
    return 'test_${DateTime.now().millisecondsSinceEpoch}@example.com';
  }

  /// API endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String userEndpoint = '/auth/user';

  /// Storage keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
}
