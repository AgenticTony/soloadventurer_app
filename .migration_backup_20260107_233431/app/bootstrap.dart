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
import 'package:soloadventurer/core/errors/exceptions.dart' as app_exceptions;
import 'package:soloadventurer/features/auth/presentation/providers/token_manager_provider.dart';
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

    AppStartTracker.endPhase('storage_init');

    // Start Supabase initialization phase
    AppStartTracker.startPhase('supabase_init');

    // Initialize auth based on feature flag
    if (AppConfig.useSupabaseAuth) {
      // Initialize Supabase (if configured)
      final supabaseUrl = AppConfig.supabaseUrl;
      final supabaseAnonKey = AppConfig.supabaseAnonKey;

      if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
        try {
          await Supabase.initialize(
            url: supabaseUrl,
            anonKey: supabaseAnonKey,
            debug: AppConfig.supabaseDebugMode,
          );
          debugPrint('✅ Supabase initialized successfully');
          debugPrint('🔗 Supabase URL: $supabaseUrl');
        } catch (e) {
          debugPrint('⚠️ Supabase initialization failed: $e');
          debugPrint('Note: App will continue but auth may not work properly');
        }
      } else {
        debugPrint('⚠️ Supabase credentials not found in .env file');
        if (supabaseUrl.isEmpty) {
          debugPrint('  Missing: SUPABASE_URL');
        }
        if (supabaseAnonKey.isEmpty) {
          debugPrint('  Missing: SUPABASE_ANON_KEY or SUPABASE_SERVICE_KEY');
        }
      }
    } else {
      // AWS Cognito initialization (legacy)
      debugPrint('ℹ️ Auth: Using AWS Cognito (legacy)');
      // Cognito initialization is handled by CognitoConfig class
      // which is loaded by the auth repository when needed
    }

    AppStartTracker.endPhase('supabase_init');

    // Start provider initialization phase
    AppStartTracker.startPhase('provider_init');

    // Create ProviderContainer for initialization with overrides and retry config
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      // Configure retry behavior for providers that fail during initialization
      // See: https://riverpod.dev/docs/concepts2/retry
      retry: _configureRetry,
    );

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

/// Configures automatic retry behavior for providers that fail during initialization.
///
/// This function implements custom retry logic with the following behavior:
/// - **Auth errors (AuthException, UnauthorizedException)**: No retry - authentication
///   failures should be immediately presented to the user.
/// - **Provider errors (ProviderException)**: No retry - prevents cascading failures
///   and infinite retry loops.
/// - **Client errors (4xx)**: No retry - these indicate invalid requests that won't
///   succeed with retries (BadRequestException, UnauthorizedException, ForbiddenException,
///   NotFoundException, ValidationException, etc.).
/// - **Network errors**: Retry with exponential backoff - handles temporary connectivity
///   issues (NetworkTimeoutException, NetworkConnectivityException).
/// - **Server errors (5xx)**: Retry with exponential backoff - handles temporary server
///   issues (ServerException).
/// - **Other errors**: No retry - unexpected errors should fail immediately.
///
/// The exponential backoff starts at 200ms and doubles with each retry (200ms, 400ms,
/// 800ms, 1.6s, 3.2s) up to a maximum of 3 retries.
///
/// See: https://riverpod.dev/docs/concepts2/retry
Duration? _configureRetry(int retryCount, Object error) {
  // Maximum number of retries for retryable errors
  const maxRetries = 3;

  // Don't retry ProviderException to avoid cascading failures
  if (error is ProviderException) {
    return null;
  }

  // At this point, error is not a ProviderException, so we can use it directly
  // In Riverpod 3.0, ProviderException wraps the original error, but we've already
  // returned null for ProviderException above, so this is the actual error

  // Don't retry authentication errors - they should be immediately visible to users
  if (error is app_exceptions.AuthException) {
    return null;
  }

  // Don't retry client errors (4xx) - these won't succeed with retries
  if (error is app_exceptions.UnauthorizedException ||
      error is app_exceptions.ForbiddenException ||
      error is app_exceptions.BadRequestException ||
      error is app_exceptions.NotFoundException ||
      error is app_exceptions.ValidationException ||
      error is app_exceptions.ConflictException) {
    return null;
  }

  // Retry network errors with exponential backoff
  // These include temporary connectivity issues
  if (error is app_exceptions.NetworkTimeoutException || error is app_exceptions.NetworkConnectivityException) {
    if (retryCount >= maxRetries) {
      return null;
    }
    // Exponential backoff: 200ms, 400ms, 800ms...
    return Duration(milliseconds: 200 * pow(2, retryCount).toInt());
  }

  // Retry server errors (5xx) with exponential backoff
  // These include temporary server issues
  if (error is app_exceptions.ServerException) {
    if (retryCount >= maxRetries) {
      return null;
    }
    // Exponential backoff: 200ms, 400ms, 800ms...
    return Duration(milliseconds: 200 * pow(2, retryCount).toInt());
  }

  // Don't retry other error types by default
  return null;
}
