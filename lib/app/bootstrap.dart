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
