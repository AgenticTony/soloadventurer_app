import 'secure_keys.dart';

/// Configuration class for Viator Transactional API settings
class ViatorConfig {
  /// Viator API key.
  ///
  /// Priority: --dart-define > .env > empty string.
  static String get apiKey => SecureKeys.viatorApiKey;

  /// Base URL for Viator API
  static const String baseUrl = 'https://api.viator.com/v1';

  /// Validates that the Viator API key is present
  static bool validate() => apiKey.isNotEmpty;

  /// Returns user-friendly error message
  static String getErrorMessage() {
    return 'Viator is not configured. Please add your API key to the .env file.';
  }
}
