import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration class for AWS Cognito settings
class CognitoConfig {
  // Static getters for direct class access
  static String get clientId => dotenv.env['COGNITO_CLIENT_ID'] ?? '';
  static String get userPoolId => dotenv.env['COGNITO_USER_POOL_ID'] ?? '';
  static String get clientSecret => dotenv.env['COGNITO_CLIENT_SECRET'] ?? '';
  static String get region => dotenv.env['COGNITO_REGION'] ?? '';
  static String get baseUrl => dotenv.env['COGNITO_BASE_URL'] ?? '';

  // Instance getters for when used as AppConfig.awsConfig
  String get clientIdValue => clientId;
  String get userPoolIdValue => userPoolId;
  String get clientSecretValue => clientSecret;
  String get regionValue => region;
  String get baseUrlValue => baseUrl;

  /// Get the Cognito endpoint URL
  String get cognitoEndpoint => 'https://cognito-idp.$regionValue.amazonaws.com';

  /// Get the CognitoUserPool instance
  ///
  /// Throws an exception if configuration is not valid.
  CognitoUserPool get userPool {
    if (!_isConfigured) {
      throw Exception(
        'AWS Cognito is not properly configured. Please check your .env file.',
      );
    }
    return CognitoUserPool(
      userPoolIdValue,
      clientIdValue,
      endpoint: cognitoEndpoint,
    );
  }

  /// Validates that all required configuration values are present
  static bool validate() {
    final requiredValues = [
      clientId,
      userPoolId,
      clientSecret,
      region,
      baseUrl,
    ];

    return requiredValues.every((value) => value.isNotEmpty);
  }

  /// Validates that all required configuration values are present (instance method)
  bool get isValid => validate();

  /// Throws an exception if any required configuration values are missing
  static void validateOrThrow() {
    if (!validate()) {
      throw Exception(
        'Missing required Cognito configuration. Please check your .env file.',
      );
    }
  }

  /// Check if Cognito is properly configured (private helper)
  bool get _isConfigured =>
      userPoolIdValue.isNotEmpty &&
      clientIdValue.isNotEmpty &&
      regionValue.isNotEmpty;
}
