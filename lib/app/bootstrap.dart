import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/app/app.dart';
import 'package:soloadventurer/core/config/app_config.dart';
import 'package:soloadventurer/core/monitoring/performance/app_start_tracker.dart';
import 'package:soloadventurer/core/errors/error_handler.dart';
import 'package:soloadventurer/core/config/image_cache_config.dart';
import 'package:soloadventurer/core/services/thumbnail_service.dart';
import 'package:soloadventurer/core/services/memory_monitor.dart';
import 'package:soloadventurer/core/services/data_unload_strategy.dart';
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

    // Start framework initialization phase
    AppStartTracker.startPhase('framework_init');

    // Load environment variables with fallback
    // Try environment-specific .env file first, then fall back to .env
    try {
      await dotenv.load(fileName: '.env.${AppConfig.environment}');
    } catch (e) {
      debugPrint('Warning: Failed to load .env.${AppConfig.environment} file.');
      // Fall back to default .env file
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
    }

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // End framework initialization phase
    AppStartTracker.endPhase('framework_init');

    // Start error handling setup phase
    AppStartTracker.startPhase('error_handling_init');

    // Initialize error handling
    ErrorHandler.initialize();

    AppStartTracker.endPhase('error_handling_init');

    // Start storage initialization phase
    AppStartTracker.startPhase('storage_init');

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

    // Initialize data unload strategy for automatic off-screen data unloading
    // Works with MemoryMonitor to free memory when pressure is high
    await _initializeDataUnloadStrategy();

    // Create ProviderContainer for initialization
    final container = ProviderContainer();

    // Initialize TokenManager
    await container.read(tokenManagerProvider.notifier).initializeToken();

    AppStartTracker.endPhase('provider_init');

    // Log startup performance report
    AppStartTracker.logStartupReport();

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
///
/// This observer logs provider lifecycle events for debugging purposes.
/// It uses the Riverpod 3.0 ProviderObserverContext API.
///
/// See: https://riverpod.dev/docs/3.0_migration
final class ProviderLogger extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderObserverContext context,
    Object? value,
  ) {
    debugPrint('''
{
  "event": "didAddProvider",
  "provider": "${context.provider}",
  "value": "$value"
}''');
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    debugPrint('''
{
  "event": "didUpdateProvider",
  "provider": "${context.provider}",
  "previousValue": "$previousValue",
  "newValue": "$newValue",
  "mutation": "${context.mutation}"
}''');
  }

  @override
  void didDisposeProvider(
    ProviderObserverContext context,
  ) {
    debugPrint('''
{
  "event": "didDisposeProvider",
  "provider": "${context.provider}"
}''');
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    // Skip ProviderException to avoid double-logging
    // Riverpod 3.0 wraps all provider failures in ProviderException
    if (error is ProviderException) {
      return;
    }

    debugPrint('''
{
  "event": "providerDidFail",
  "provider": "${context.provider}",
  "error": "$error",
  "stackTrace": "$stackTrace"
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

/// Initialize data unload strategy for automatic off-screen data management
///
/// This sets up intelligent data unloading that responds to memory pressure
/// by automatically unloading off-screen data when memory is high.
Future<void> _initializeDataUnloadStrategy() async {
  await DataUnloadStrategy.initialize(
    config: const DataUnloadConfig(
      autoUnloadOnWarning: true,   // Unload data at warning level (150 MB)
      autoUnloadOnCritical: true,  // Aggressively unload at critical level (180 MB)
      targetFreePercentageWarning: 0.1,    // Free 10% at warning
      targetFreePercentageCritical: 0.3,   // Free 30% at critical
      maxUnloadDuration: Duration(milliseconds: 100), // Don't block UI
      prioritizeByPriority: true,   // Unload low priority data first
      prioritizeByVisibility: true, // Unload off-screen data first
      enableDebugLogging: true,     // Log unload operations in debug
    ),
  );

  debugPrint('✅ Data unload strategy initialized');
  debugPrint('   Auto-unload on warning: true (10% target)');
  debugPrint('   Auto-unload on critical: true (30% target)');
  debugPrint('   Priority-based: true');
  debugPrint('   Visibility-aware: true');
}
