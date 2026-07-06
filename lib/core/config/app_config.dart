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
      const String.fromEnvironment('ENABLE_SSL_PINNING',
          defaultValue: 'false') ==
      'true';

  // ============================================================
  // SUPABASE CONFIGURATION
  // ============================================================

  /// Supabase project URL from environment variables
  ///
  /// Set in `.env` file: `SUPABASE_URL=https://your-project.supabase.co`
  static String get supabaseUrl => _envFallback('SUPABASE_URL');

  /// Supabase anonymous key from environment variables
  ///
  /// Set in `.env` file: `SUPABASE_ANON_KEY=your-anon-key`
  static String get supabaseAnonKey {
    final key = _envFallback('SUPABASE_ANON_KEY');
    if (key.isEmpty) {
      throw StateError(
        'SUPABASE_ANON_KEY is not configured. '
        'Provide it via --dart-define or .env file.',
      );
    }
    return key;
  }

  /// Safely reads from dotenv, returning empty string if not initialized
  static String _envFallback(String key) {
    try {
      return dotenv.env[key] ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Whether Supabase debug mode is enabled
  ///
  /// Automatically disabled in production, enabled in other environments.
  static bool get supabaseDebugMode => !isProduction;

  // ============================================================
  // API CONFIGURATION
  // ============================================================

  /// Base URL for API requests
  ///
  /// Defaults to environment-specific URLs if not set via .env file.
  /// Set in `.env` file: `API_BASE_URL=https://api.example.com`
  static String get apiBaseUrl {
    if (kReleaseMode) {
      final url = _envFallback('API_BASE_URL_PROD');
      return url.isNotEmpty ? url : 'https://api.soloadventurer.com/prod';
    } else if (kProfileMode) {
      final url = _envFallback('API_BASE_URL_STAGING');
      return url.isNotEmpty ? url : 'https://api.soloadventurer.com/staging';
    } else {
      final url = _envFallback('API_BASE_URL_DEV');
      return url.isNotEmpty ? url : 'https://api.soloadventurer.com/dev';
    }
  }

  // ============================================================
  // ANALYTICS CONFIGURATION (PostHog — see docs/analytics-v0.1.md)
  // ============================================================

  /// PostHog project API key. Empty string when unset (analytics stays off).
  ///
  /// Set in `.env`: `POSTHOG_API_KEY=phc_...`
  static String get posthogApiKey => _envFallback('POSTHOG_API_KEY');

  /// PostHog ingestion host. Defaults to **EU Cloud** for GDPR data residency.
  ///
  /// Set in `.env`: `POSTHOG_HOST=https://eu.i.posthog.com`
  static String get posthogHost {
    final host = _envFallback('POSTHOG_HOST');
    return host.isNotEmpty ? host : 'https://eu.i.posthog.com';
  }

  /// Whether product analytics should be wired at all.
  ///
  /// Only when a key is configured. Consent is enforced separately at runtime
  /// via the opt-in gate (SDK starts opted-out; nothing is sent until consent).
  static bool get analyticsEnabled => posthogApiKey.isNotEmpty;

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
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }

  /// Throws an exception if required configuration is missing
  ///
  /// Call this during app initialization to fail fast if
  /// required configuration is not present.
  static void validateOrThrow() {
    if (!validate()) {
      final missing = <String>[];
      if (supabaseUrl.isEmpty) missing.add('SUPABASE_URL');
      if (supabaseAnonKey.isEmpty) missing.add('SUPABASE_ANON_KEY');
      throw Exception(
        'Missing required Supabase configuration: ${missing.join(', ')}. '
        'Please add these to your .env file.',
      );
    }
  }

  /// Returns a summary of the current configuration for debugging
  ///
  /// This method is safe to call in production - sensitive values are redacted.
  static String getConfigurationSummary() {
    return '''
AppConfig Summary:
  Environment: $environment
  SSL Pinning: $enableSSLPinning
  Debug Mode: $debugMode
  Supabase: Enabled (URL: ${_redactUrl(supabaseUrl)})''';
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
