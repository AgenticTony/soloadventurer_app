import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration class for Google Places API settings
///
/// This class provides access to Google Places API configuration
/// values loaded from environment variables via flutter_dotenv.
///
/// Required environment variable:
/// - GOOGLE_PLACES_API_KEY: Your Google Places API key from Google Cloud Console
///
/// To get an API key:
/// 1. Go to https://console.cloud.google.com/
/// 2. Create a new project or select existing one
/// 3. Enable "Places API" from the API library
/// 4. Create credentials (API Key) with appropriate restrictions
/// 5. Add the key to your .env file
class GooglePlacesConfig {
  /// Google Places API key for accessing the Places API
  ///
  /// This key is required for the google_places_flutter package
  /// to provide location autocomplete and place details.
  static String get apiKey => dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  /// Base URL for Google Places API (for reference, not used directly)
  ///
  /// The google_places_flutter package handles API calls internally.
  /// This is provided for reference or custom implementations.
  static const String baseUrl = 'https://maps.googleapis.com/maps/api/place';

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
