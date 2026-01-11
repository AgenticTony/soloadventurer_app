import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/app/app.dart';
import 'package:soloadventurer/core/config/app_config.dart';
import 'package:soloadventurer/core/config/image_cache_config.dart';
import 'package:soloadventurer/core/monitoring/performance/app_start_tracker.dart';
import 'package:soloadventurer/core/errors/error_handler.dart';
import 'package:soloadventurer/features/auth/domain/services/token_manager.dart';
import 'package:soloadventurer/app/providers/core_service_providers.dart';

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

    // Load environment variables from .env file
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

    // End framework initialization phase
    AppStartTracker.endPhase('framework_init');

    // Start error handling setup phase
    AppStartTracker.startPhase('error_handling_init');

    // Initialize error handling
    ErrorHandler().initialize();

    AppStartTracker.endPhase('error_handling_init');

    // Start storage initialization phase
    AppStartTracker.startPhase('storage_init');

    // Initialize SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();

    // Initialize image cache configuration for memory efficiency
    // This configures cached_network_image to handle 500+ photos efficiently
    await ImageCacheConfig.initialize();

    // Start auth initialization phase
    AppStartTracker.startPhase('auth_init');

    // Initialize auth based on feature flag
    if (AppConfig.useSupabaseAuth) {
      // Supabase auth initialization
      final supabaseUrl = AppConfig.supabaseUrl;
      final supabaseAnonKey = AppConfig.supabaseAnonKey;
      if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseAnonKey,
          debug: true,
        );
        debugPrint('✅ Supabase initialized successfully');
      } else {
        debugPrint('⚠️ Supabase auth enabled but credentials missing');
        debugPrint('  Set SUPABASE_URL and SUPABASE_ANON_KEY in .env');
      }
    } else {
      // AWS Cognito initialization
      debugPrint('ℹ️ Auth: Using AWS Cognito');
      // Cognito initialization is handled by CognitoConfig class
      // which is loaded by the auth repository when needed
    }

    AppStartTracker.endPhase('auth_init');

    // Start provider initialization phase
    AppStartTracker.startPhase('provider_init');

    // Create ProviderContainer for initialization with overrides
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
    );

    // Initialize TokenManager (domain service with FeatureAvailability state)
    await container.read(tokenManagerProvider.notifier).initialize();

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
    ErrorHandler().handleException(
      error,
      stackTrace: stackTrace,
      context: {'source': 'bootstrap_uncaught'},
    );
  });
}

/// Logger for provider state changes
///
/// This observer logs provider lifecycle events for debugging purposes.
/// Temporarily disabled for Riverpod 3.0 migration - needs API update
///
/// TODO: Update to Riverpod 3.0 ProviderObserver API
// final class ProviderLogger extends ProviderObserver {
//   @override
//   void didAddProvider(
//     RiverpodProviderBase provider,
//     Object? value,
//   ) {
//     debugPrint('''
// {
//   "event": "didAddProvider",
//   "provider": "$provider",
//   "value": "$value"
// }''');
//   }
//
//   @override
//   void didUpdateProvider(
//     RiverpodProviderBase provider,
//     Object? previousValue,
//     Object? newValue,
//   ) {
//     debugPrint('''
// {
//   "event": "didUpdateProvider",
//   "provider": "$provider",
//   "previousValue": "$previousValue",
//   "newValue": "$newValue"
// }''');
//   }
//
//   @override
//   void didDisposeProvider(
//     RiverpodProviderBase provider,
//   ) {
//     debugPrint('''
// {
//   "event": "didDisposeProvider",
//   "provider": "$provider"
// }''');
//   }
//
//   @override
//   void providerDidFail(
//     RiverpodProviderBase provider,
//     Object error,
//     StackTrace stackTrace,
//   ) {
//     debugPrint('''
// {
//   "event": "providerDidFail",
//   "provider": "$provider",
//   "error": "$error",
//   "stackTrace": "$stackTrace"
// }''');
//   }
// }

/// This function will be called when the app is run in debug mode
/// to set up any debug-specific configurations.
void setupDebugConfiguration() {
  // Enable additional logging in debug mode
  // Configure development-specific settings
}
