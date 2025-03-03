import 'package:flutter/foundation.dart';

/// Environment configuration for the application
///
/// This class provides access to environment-specific configuration values
/// such as API endpoints, feature flags, and other environment-dependent settings.
class Env {
  /// Base URL for API requests
  String get apiBaseUrl {
    if (kReleaseMode) {
      return 'https://hxs3jfwke3.execute-api.us-east-1.amazonaws.com/prod';
    } else if (kProfileMode) {
      return 'https://hxs3jfwke3.execute-api.us-east-1.amazonaws.com/staging';
    } else {
      return 'https://hxs3jfwke3.execute-api.us-east-1.amazonaws.com/dev';
    }
  }

  /// AWS Cognito User Pool ID
  String get cognitoUserPoolId => 'us-east-1_vNhmt3a4G';

  /// AWS Cognito Client ID
  String get cognitoClientId => '1g38ds6cnuf9cbtdatbbfom6hq';

  /// AWS Cognito Identity Pool ID
  String get cognitoIdentityPoolId => '';

  /// AWS Region
  String get awsRegion => 'us-east-1';

  /// Whether to enable detailed logging
  bool get enableDetailedLogs => !kReleaseMode;

  /// Whether to enable performance monitoring
  bool get enablePerformanceMonitoring => true;

  /// Whether to enable crash reporting
  bool get enableCrashReporting => true;

  /// Whether to enable analytics
  bool get enableAnalytics => kReleaseMode || kProfileMode;

  /// Maximum cache size in MB
  int get maxCacheSizeMB => 100;

  /// Cache expiration time in days
  int get cacheExpirationDays => 7;
}
