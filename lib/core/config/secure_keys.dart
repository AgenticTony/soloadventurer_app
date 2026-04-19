import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Secure API key management.
///
/// Reads sensitive API keys from compile-time `--dart-define` arguments,
/// with fallback to flutter_dotenv for development. This prevents API keys
/// from being bundled in the app binary or checked into source control.
///
/// ## Usage
///
/// ### Compile-time injection (recommended for production)
/// ```bash
/// flutter run \
///   --dart-define=GOOGLE_PLACES_API_KEY=your_key \
///   --dart-define=VIATOR_API_KEY=your_key
/// ```
///
/// ### Runtime fallback (development only)
/// Keys fall back to `flutter_dotenv` values from `.env` when not provided
/// via `--dart-define`. This allows local development without passing flags.
class SecureKeys {
  SecureKeys._();

  /// Google Places API key.
  ///
  /// Priority: --dart-define > .env > empty string.
  /// Returns empty string if not configured — callers should handle gracefully.
  static String get googlePlacesApiKey {
    const dartDefine = String.fromEnvironment('GOOGLE_PLACES_API_KEY');
    if (dartDefine.isNotEmpty) return dartDefine;
    return _envFallback('GOOGLE_PLACES_API_KEY');
  }

  /// Viator Transactional API key.
  ///
  /// Priority: --dart-define > .env > empty string.
  static String get viatorApiKey {
    const dartDefine = String.fromEnvironment('VIATOR_API_KEY');
    if (dartDefine.isNotEmpty) return dartDefine;
    return _envFallback('VIATOR_API_KEY');
  }

  /// Safe fallback to flutter_dotenv. Returns empty string if dotenv
  /// is not initialized (e.g., in unit tests or before app bootstrap).
  static String _envFallback(String key) {
    try {
      return dotenv.env[key] ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Whether the Google Places API key is configured.
  static bool get hasGooglePlacesKey => googlePlacesApiKey.isNotEmpty;

  /// Whether the Viator API key is configured.
  static bool get hasViatorKey => viatorApiKey.isNotEmpty;

  /// Validate all required keys and return a list of missing ones.
  ///
  /// Returns an empty list if all keys are present.
  static List<String> missingKeys() {
    final missing = <String>[];
    if (!hasGooglePlacesKey) missing.add('GOOGLE_PLACES_API_KEY');
    if (!hasViatorKey) missing.add('VIATOR_API_KEY');
    return missing;
  }

  /// Check if all keys are configured.
  static bool get allKeysPresent => missingKeys().isEmpty;

  /// Get a user-friendly message about missing keys.
  static String missingKeysMessage() {
    final missing = missingKeys();
    if (missing.isEmpty) return 'All API keys are configured.';
    return 'Missing API keys: ${missing.join(', ')}. '
        'Please provide them via --dart-define or .env file.';
  }
}
