import 'package:flutter/foundation.dart';
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

/// Cache configuration
class _CacheConfig {
  const _CacheConfig();

  int get maxSizeMB =>
      int.parse(dotenv.get('CACHE_MAX_SIZE_MB', fallback: '100'));
  int get expirationDays =>
      int.parse(dotenv.get('CACHE_EXPIRATION_DAYS', fallback: '7'));
}
