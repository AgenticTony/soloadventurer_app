import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import 'package:soloadventurer/app/app.dart';
import 'package:soloadventurer/core/monitoring/performance/app_start_tracker.dart';
import 'package:soloadventurer/core/errors/error_handler.dart';
import 'package:soloadventurer/core/config/image_cache_config.dart';
import 'package:soloadventurer/core/services/thumbnail_service.dart';
import 'package:soloadventurer/core/services/memory_monitor.dart';
import '../features/auth/domain/services/token_manager.dart';

/// Bootstrap is responsible for app initialization and configuration
/// before the app is run.
Future<void> bootstrap() async {
  // Run everything in a zone to ensure consistent error handling
  runZonedGuarded(() async {
    // Initialize Flutter bindings first
    WidgetsFlutterBinding.ensureInitialized();

    // Track app start time
    AppStartTracker.trackAppStart();

    // Load environment variables with fallback
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint('Warning: Failed to load .env file. Using default values.');
      // Load example environment file as fallback
      try {
        await dotenv.load(fileName: '.env.example');
      } catch (e) {
        debugPrint(
            'Warning: Failed to load .env.example file. Using hardcoded defaults.');
      }
    }

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize service locator first
    await setupServiceLocator(isTest: false);

    // Initialize error handling
    ErrorHandler.initialize();

    // Initialize SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();

    // Initialize image cache configuration for memory efficiency
    // This configures cached_network_image to handle 500+ photos efficiently
    await ImageCacheConfig.initialize();

    // Initialize thumbnail service for generating and caching photo thumbnails
    // This reduces memory footprint by 95%: 50KB thumbnails vs 1MB full images
    await ThumbnailService.initialize();

    // Initialize memory monitoring with automatic cache management
    // Monitors memory usage in real-time and clears caches when thresholds are exceeded
    await _initializeMemoryMonitoring();

    // Create ProviderContainer for initialization
    final container = ProviderContainer();

    // Initialize TokenManager
    await container.read(tokenManagerProvider.notifier).initialize();

    // Run the app with proper provider initialization
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const App(),
      ),
    );
  }, (error, stackTrace) {
    // Report any errors not caught by the Flutter framework
    ErrorHandler.reportError(
      'Uncaught exception',
      error,
      stackTrace,
    );
  });
}

/// Logger for provider state changes
class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    debugPrint('''
{
  "provider": "${provider.name ?? provider.runtimeType}",
  "newValue": "$newValue"
}''');
  }
}

/// This function will be called when the app is run in debug mode
/// to set up any debug-specific configurations.
void setupDebugConfiguration() {
  // Enable additional logging in debug mode
  // Configure development-specific settings
}

/// Initialize memory monitoring with automatic cache management
///
/// This sets up real-time memory tracking and automatic cache clearing
/// when memory usage exceeds configured thresholds.
Future<void> _initializeMemoryMonitoring() async {
  await MemoryMonitor.initialize(
    config: const MemoryMonitorConfig(
      warningThresholdBytes: 150 * 1024 * 1024,  // 150 MB warning
      criticalThresholdBytes: 180 * 1024 * 1024, // 180 MB critical
      monitoringInterval: Duration(seconds: 5),
    ),
    onAlert: (alert) async {
      debugPrint('🚨 Memory Alert [${alert.level.name}]: ${alert.message}');

      // Automatic cache management based on alert level
      if (alert.level == MemoryAlertLevel.warning) {
        debugPrint('⚠️  Memory warning - Clearing image cache');
        await ImageCacheConfig.clearMemoryCache();
      } else if (alert.level == MemoryAlertLevel.critical) {
        debugPrint('❌ Memory critical - Clearing all caches');
        await ImageCacheConfig.clearAllCaches();
        await ThumbnailService.clearCache();

        // Clear memory monitor history to free up memory
        MemoryMonitor.clearHistory();

        debugPrint('✅ All caches cleared due to critical memory usage');
      }
    },
  );

  debugPrint('✅ Memory monitoring initialized');
  debugPrint('   Warning threshold: 150 MB');
  debugPrint('   Critical threshold: 180 MB');
  debugPrint('   Monitoring interval: 5 seconds');
}
