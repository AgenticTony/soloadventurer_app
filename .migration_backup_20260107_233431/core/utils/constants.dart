/// Constants used throughout the app
class AppConstants {
  /// Private constructor to prevent instantiation
  AppConstants._();

  /// API related constants
  static const String apiVersion = 'v1';

  /// Storage related constants
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user';

  /// Timeout durations
  static const int connectionTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;

  /// Pagination defaults
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
