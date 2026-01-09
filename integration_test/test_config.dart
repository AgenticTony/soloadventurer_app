/// Configuration for integration tests
class TestConfig {
  /// The base URL for the API in test mode
  static const String apiBaseUrl = 'https://api-test.soloadventurer.com';

  /// Test user credentials
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'password123';
  static const String testName = 'Test User';

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

  /// Timing configurations for tests
  static const Duration stepDelay = Duration(milliseconds: 100);
  static const Duration defaultUiDelay = Duration(milliseconds: 300);
  static const Duration maxWaitTime = Duration(seconds: 30);
  static const bool verboseLogging = false;

  /// Valid test passwords
  static const List<String> validPasswords = [
    'password123',
    'Test@1234',
    'SecurePass!2024',
    'TravelSafe2024',
  ];

  /// Generates a random test email address
  static String generateTestEmail() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'test$timestamp@example.com';
  }

  /// Generates a random test user ID
  static String generateTestUserId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'user_$timestamp';
  }
}
