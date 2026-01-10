import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration class for AWS Cognito settings
class CognitoConfig {
  static String get clientId => dotenv.env['COGNITO_CLIENT_ID'] ?? '';
  static String get userPoolId => dotenv.env['COGNITO_USER_POOL_ID'] ?? '';
  static String get clientSecret => dotenv.env['COGNITO_CLIENT_SECRET'] ?? '';
  static String get region => dotenv.env['COGNITO_REGION'] ?? '';
  static String get baseUrl => dotenv.env['COGNITO_BASE_URL'] ?? '';

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

  /// Throws an exception if any required configuration values are missing
  static void validateOrThrow() {
    if (!validate()) {
      throw Exception(
        'Missing required Cognito configuration. Please check your .env file.',
      );
    }
  }
}
