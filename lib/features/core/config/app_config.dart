import 'package:flutter/foundation.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration that combines all configuration aspects
/// while following security best practices
class AppConfig {
  // Environment-specific configuration
  static String get apiBaseUrl {
    if (kReleaseMode) {
      return dotenv.get('API_BASE_URL_PROD',
          fallback: 'https://api.soloadventurer.com/prod');
    } else if (kProfileMode) {
      return dotenv.get('API_BASE_URL_STAGING',
          fallback: 'https://api.soloadventurer.com/staging');
    } else {
      return dotenv.get('API_BASE_URL_DEV',
          fallback: 'https://api.soloadventurer.com/dev');
    }
  }

  // AWS Configuration - all sensitive values from environment variables
  static const awsConfig = _AwsConfig();

  // Feature flags
  static bool get enableDetailedLogs =>
      dotenv.get('ENABLE_DETAILED_LOGS', fallback: 'true') == 'true';
  static bool get enablePerformanceMonitoring =>
      dotenv.get('ENABLE_PERFORMANCE_MONITORING', fallback: 'true') == 'true';
  static bool get enableCrashReporting =>
      dotenv.get('ENABLE_CRASH_REPORTING', fallback: 'true') == 'true';
  static bool get enableAnalytics =>
      dotenv.get('ENABLE_ANALYTICS', fallback: 'false') == 'true';

  // Cache configuration
  static const cacheConfig = _CacheConfig();
}

/// AWS-specific configuration following AWS best practices
class _AwsConfig {
  const _AwsConfig();

  // Basic AWS Configuration
  String get userPoolId =>
      dotenv.get('AWS_USER_POOL_ID', fallback: 'us-east-1_XXXXXXXX');
  String get clientId =>
      dotenv.get('AWS_CLIENT_ID', fallback: 'XXXXXXXXXXXXXXXXXXXXXXXX');
  String get region => dotenv.get('AWS_REGION', fallback: 'us-east-1');
  String get identityPoolId => dotenv.get('AWS_IDENTITY_POOL_ID',
      fallback: 'us-east-1:XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX');

  // Derived AWS endpoints and ARNs
  String get jwksUrl =>
      'https://cognito-idp.$region.amazonaws.com/$userPoolId/.well-known/jwks.json';
  String get cognitoEndpoint => 'https://cognito-idp.$region.amazonaws.com';
  String get userPoolArn =>
      'arn:aws:cognito-idp:$region:198092179835:userpool/$userPoolId';

  // OAuth Configuration
  String get callbackUrl =>
      dotenv.get('OAUTH_CALLBACK_URL', fallback: 'soloadventurer://callback');
  String get signOutUrl =>
      dotenv.get('OAUTH_SIGN_OUT_URL', fallback: 'soloadventurer://signout');
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
  String get cloudWatchLogGroup => dotenv.get('AWS_CLOUDWATCH_LOG_GROUP',
      fallback: '/aws/cognito/userpools');
  String get cloudWatchLogStream =>
      dotenv.get('AWS_CLOUDWATCH_LOG_STREAM', fallback: 'default');

  // Cognito User Pool Instance
  CognitoUserPool get userPool {
    if (!isConfigured) {
      throw Exception(
          'AWS Cognito is not properly configured. Please check your .env file.');
    }
    return CognitoUserPool(
      userPoolId,
      clientId,
      endpoint: cognitoEndpoint,
    );
  }

  // Cognito Credentials for Identity Pool
  CognitoCredentials get credentials {
    if (!isConfigured) {
      throw Exception(
          'AWS Cognito is not properly configured. Please check your .env file.');
    }
    return CognitoCredentials(
      identityPoolId,
      userPool,
      region: region,
    );
  }

  // OAuth Configuration Map
  Map<String, dynamic> get oAuthConfig => {
        'redirectUri': callbackUrl,
        'signOutUri': signOutUrl,
        'scopes': scopes,
      };

  // Validation
  bool get isConfigured =>
      userPoolId != 'us-east-1_XXXXXXXX' &&
      clientId != 'XXXXXXXXXXXXXXXXXXXXXXXX' &&
      region.isNotEmpty;

  bool get isMonitoringConfigured =>
      cloudWatchLogGroup.isNotEmpty && cloudWatchLogStream.isNotEmpty;
}

/// Cache configuration
class _CacheConfig {
  const _CacheConfig();

  int get maxSizeMB =>
      int.parse(dotenv.get('CACHE_MAX_SIZE_MB', fallback: '100'));
  int get expirationDays =>
      int.parse(dotenv.get('CACHE_EXPIRATION_DAYS', fallback: '7'));
}
