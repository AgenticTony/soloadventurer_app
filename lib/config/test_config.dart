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
}
