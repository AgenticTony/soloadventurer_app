import 'secure_keys.dart';

/// Configuration class for Google Places API settings
///
/// This class provides access to Google Places API configuration
/// values loaded via [SecureKeys] (--dart-define or .env fallback).
class GooglePlacesConfig {
  /// Google Places API key for accessing the Places API.
  ///
  /// Priority: --dart-define > .env > empty string.
  static String get apiKey => SecureKeys.googlePlacesApiKey;

  /// Base URL for Google Places API (New)
  static const String baseUrl = 'https://places.googleapis.com/v1';

  /// Validates that the Google Places API key is present and non-empty
  ///
  /// Returns true if the API key is configured, false otherwise.
  static bool validate() {
    return apiKey.isNotEmpty;
  }

  /// Throws an exception if the Google Places API key is missing
  ///
  /// Call this method during app initialization to ensure
  /// the required configuration is present.
  ///
  /// Throws [Exception] if the API key is not configured.
  static void validateOrThrow() {
    if (!validate()) {
      throw Exception(
        'Missing required Google Places API key. '
        'Please add GOOGLE_PLACES_API_KEY to your .env file. '
        'Get your API key from: https://console.cloud.google.com/',
      );
    }
  }

  /// Returns a user-friendly error message for display in the UI
  ///
  /// Use this when you want to show configuration errors to users
  /// instead of throwing an exception.
  static String getErrorMessage() {
    return 'Google Places is not configured. '
        'Please add your Google Places API key to the .env file.';
  }
}
