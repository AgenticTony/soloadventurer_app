import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration class
///
/// Provides centralized access to environment-based configuration
/// and feature flags. Configuration values are loaded from:
///
/// 1. **Compile-time constants** via `--dart-define` (highest priority)
/// 2. **Environment variables** via `.env` files
/// 3. **Default values** (fallback)
///
/// ## Environment Configuration
///
/// Set the environment at compile time:
/// ```bash
/// flutter run --dart-define=ENV=production
/// flutter run --dart-define=ENV=staging
/// flutter run --dart-define=ENV=development  # default
/// ```
///
/// ## Auth Provider Selection
///
/// Choose the auth provider at compile time:
/// ```bash
/// flutter run --dart-define=AUTH_PROVIDER=supabase  # default
/// flutter run --dart-define=AUTH_PROVIDER=cognito    # legacy
/// ```
///
/// ## Security Features
///
/// Enable SSL pinning in production:
/// ```bash
/// flutter run --dart-define=ENABLE_SSL_PINNING=true
/// ```
///
/// See: [https://docs.flutter.dev/deployment/environment#compile-time-constants](https://docs.flutter.dev/deployment/environment)
class AppConfig {
  // ============================================================
  // ENVIRONMENT CONFIGURATION
  // ============================================================

  /// Current application environment
  ///
  /// Defaults to 'development' if not specified via compile-time constant.
  /// Valid values: 'development', 'staging', 'production'
  ///
  /// Set via: `flutter run --dart-define=ENV=production`
  static String get environment =>
      const String.fromEnvironment('ENV', defaultValue: 'development');

  /// Whether the app is running in production environment
  static bool get isProduction => environment == 'production';

  /// Whether the app is running in staging environment
  static bool get isStaging => environment == 'staging';

  /// Whether the app is running in development environment
  static bool get isDevelopment => environment == 'development';

  // ============================================================
  // AUTH PROVIDER SELECTION
  // ============================================================

  /// Which authentication provider to use
  ///
  /// - 'supabase': Use Supabase Auth (new, recommended)
  /// - 'cognito': Use AWS Cognito (legacy, being phased out)
  ///
  /// Set via: `flutter run --dart-define=AUTH_PROVIDER=supabase`
  static String get authProvider =>
      const String.fromEnvironment('AUTH_PROVIDER', defaultValue: 'supabase');

  /// Whether to use Supabase for authentication
  static bool get useSupabaseAuth => authProvider == 'supabase';

  /// Whether to use AWS Cognito for authentication (legacy)
  static bool get useCognitoAuth => authProvider == 'cognito';

  // ============================================================
  // SECURITY FEATURES
  // ============================================================

  /// Whether SSL certificate pinning is enabled
  ///
  /// SSL pinning provides additional security by validating
  /// that the app is connecting to the expected server.
  /// Disabled by default. Enable in production only.
  ///
  /// Set via: `flutter run --dart-define=ENABLE_SSL_PINNING=true`
  static bool get enableSSLPinning =>
      const String.fromEnvironment('ENABLE_SSL_PINNING', defaultValue: 'false') ==
          'true';

  // ============================================================
  // SUPABASE CONFIGURATION
  // ============================================================

  /// Supabase project URL from environment variables
  ///
  /// Required when `useSupabaseAuth` is true.
  /// Set in `.env` file: `SUPABASE_URL=https://your-project.supabase.co`
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  /// Supabase anonymous key from environment variables
  ///
  /// Required when `useSupabaseAuth` is true.
  /// Set in `.env` file: `SUPABASE_ANON_KEY=your-anon-key`
  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? dotenv.env['SUPABASE_SERVICE_KEY'] ?? '';

  /// Whether Supabase debug mode is enabled
  ///
  /// Automatically disabled in production, enabled in other environments.
  static bool get supabaseDebugMode => !isProduction;

  // ============================================================
  // DEBUG CONFIGURATION
  // ============================================================

  /// Whether debug mode is enabled
  ///
  /// Enables additional logging and diagnostic output.
  ///
  /// Set via: `flutter run --dart-define=DEBUG=true`
  static bool get debugMode =>
      const String.fromEnvironment('DEBUG', defaultValue: 'false') == 'true' ||
          kDebugMode;

  // ============================================================
  // VALIDATION
  // ============================================================

  /// Validates that all required configuration for the selected auth provider is present
  ///
  /// Returns true if configuration is valid, false otherwise.
  static bool validate() {
    if (useSupabaseAuth) {
      return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
    }
    // Cognito validation is handled by CognitoConfig class
    return true;
  }

  /// Throws an exception if required configuration is missing
  ///
  /// Call this during app initialization to fail fast if
  /// required configuration is not present.
  static void validateOrThrow() {
    if (!validate()) {
      if (useSupabaseAuth) {
        final missing = <String>[];
        if (supabaseUrl.isEmpty) missing.add('SUPABASE_URL');
        if (supabaseAnonKey.isEmpty) missing.add('SUPABASE_ANON_KEY');
        throw Exception(
          'Missing required Supabase configuration: ${missing.join(', ')}. '
          'Please add these to your .env file.',
        );
      }
    }
  }

  /// Returns a summary of the current configuration for debugging
  ///
  /// This method is safe to call in production - sensitive values are redacted.
  static String getConfigurationSummary() {
    return '''
AppConfig Summary:
  Environment: $environment
  Auth Provider: $authProvider
  SSL Pinning: $enableSSLPinning
  Debug Mode: $debugMode
  Supabase: ${useSupabaseAuth ? 'Enabled (URL: ${_redactUrl(supabaseUrl)})' : 'Disabled'}
  Cognito: ${useCognitoAuth ? 'Enabled' : 'Disabled'}''';
  }

  /// Redacts sensitive information from URLs for logging
  static String _redactUrl(String url) {
    if (url.isEmpty) return 'not configured';
    try {
      final uri = Uri.parse(url);
      return '${uri.scheme}://${uri.host}/***';
    } catch (_) {
      return '***';
    }
  }
}
