import 'package:flutter/foundation.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';

/// Application configuration that combines all configuration aspects
/// while following security best practices
class AppConfig {
  // Environment-specific configuration
  static String get apiBaseUrl {
    if (kReleaseMode) {
      return const String.fromEnvironment('API_BASE_URL_PROD',
          defaultValue: 'https://api.soloadventurer.com/prod');
    } else if (kProfileMode) {
      return const String.fromEnvironment('API_BASE_URL_STAGING',
          defaultValue: 'https://api.soloadventurer.com/staging');
    } else {
      return const String.fromEnvironment('API_BASE_URL_DEV',
          defaultValue: 'https://api.soloadventurer.com/dev');
    }
  }

  // AWS Configuration - all sensitive values from environment variables
  static const awsConfig = _AwsConfig();

  // Feature flags
  static bool get enableDetailedLogs => !kReleaseMode;
  static bool get enablePerformanceMonitoring => true;
  static bool get enableCrashReporting => true;
  static bool get enableAnalytics => kReleaseMode || kProfileMode;

  // Cache configuration
  static const cacheConfig = _CacheConfig();
}

/// AWS-specific configuration following AWS best practices
class _AwsConfig {
  const _AwsConfig();

  // Basic AWS Configuration
  String get userPoolId => const String.fromEnvironment('AWS_USER_POOL_ID');
  String get clientId => const String.fromEnvironment('AWS_CLIENT_ID');
  String get region =>
      const String.fromEnvironment('AWS_REGION', defaultValue: 'us-east-1');
  String get identityPoolId =>
      const String.fromEnvironment('AWS_IDENTITY_POOL_ID', defaultValue: '');

  // Derived AWS endpoints and ARNs
  String get jwksUrl =>
      'https://cognito-idp.$region.amazonaws.com/$userPoolId/.well-known/jwks.json';
  String get cognitoEndpoint => 'https://cognito-idp.$region.amazonaws.com';
  String get userPoolArn =>
      'arn:aws:cognito-idp:$region:198092179835:userpool/$userPoolId';

  // OAuth Configuration
  static const String callbackUrl = 'soloadventurer://callback';
  static const String signOutUrl = 'soloadventurer://signout';
  static const List<String> scopes = [
    'phone',
    'openid',
    'email',
    'profile',
    'aws.cognito.signin.user.admin'
  ];

  // Authentication Configuration
  static const List<String> explicitAuthFlows = [
    'ALLOW_USER_SRP_AUTH',
    'ALLOW_REFRESH_TOKEN_AUTH',
    'ALLOW_USER_PASSWORD_AUTH',
  ];

  // Token and Session Configuration
  static const int authSessionDuration = 3;
  static const int accessTokenDuration = 60;
  static const int idTokenDuration = 60;
  static const int refreshTokenDuration = 5;
  static const int maxFailedAttempts = 5;

  // CloudWatch configuration
  String get cloudWatchLogGroup =>
      const String.fromEnvironment('AWS_CLOUDWATCH_LOG_GROUP');
  String get cloudWatchLogStream =>
      const String.fromEnvironment('AWS_CLOUDWATCH_LOG_STREAM');

  // Cognito User Pool Instance
  CognitoUserPool get userPool => CognitoUserPool(
        userPoolId,
        clientId,
        endpoint: cognitoEndpoint,
      );

  // Cognito Credentials for Identity Pool
  CognitoCredentials get credentials => CognitoCredentials(
        identityPoolId,
        userPool,
        region: region,
      );

  // OAuth Configuration Map
  Map<String, dynamic> get oAuthConfig => {
        'redirectUri': callbackUrl,
        'signOutUri': signOutUrl,
        'scopes': scopes,
      };

  // Validation
  bool get isConfigured =>
      userPoolId.isNotEmpty && clientId.isNotEmpty && region.isNotEmpty;

  bool get isMonitoringConfigured =>
      cloudWatchLogGroup.isNotEmpty && cloudWatchLogStream.isNotEmpty;
}

/// Cache configuration
class _CacheConfig {
  const _CacheConfig();

  int get maxSizeMB => 100;
  int get expirationDays => 7;
}
