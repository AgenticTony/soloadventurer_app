import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:soloadventurer/app/app.dart';
import 'package:soloadventurer/core/config/app_config.dart';
import 'package:soloadventurer/core/config/image_cache_config.dart';
import 'package:soloadventurer/core/monitoring/app_logger.dart';
import 'package:soloadventurer/core/monitoring/performance/app_start_tracker.dart';
import 'package:soloadventurer/core/errors/error_handler.dart';
import 'package:soloadventurer/features/auth/domain/services/token_manager.dart';
import 'package:soloadventurer/app/providers/core_service_providers.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database_service.dart';
import 'package:soloadventurer/features/matching/presentation/providers/matching_provider.dart';
import 'package:soloadventurer/features/matching/data/datasources/matching_remote_data_source_impl.dart';
import 'package:soloadventurer/features/matching/data/datasources/matching_local_data_source_impl.dart';
import 'package:soloadventurer/features/matching/data/repositories/matching_repository_impl.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_entry_providers.dart';
import 'package:soloadventurer/features/journal/data/datasources/journal_remote_data_source_impl.dart';
import 'package:soloadventurer/features/journal/data/repositories/journal_repository_impl.dart';
import 'package:soloadventurer/core/services/push_notification_service.dart';
import 'package:soloadventurer/core/services/analytics_service.dart';
import 'package:soloadventurer/core/services/posthog_analytics_service.dart';
import 'package:soloadventurer/core/services/consent_gated_analytics_service.dart';
import 'package:soloadventurer/app/providers/analytics_provider.dart';
import 'package:soloadventurer/app/providers/analytics_consent_provider.dart';
import 'package:soloadventurer/app/router/go_router_config.dart';

/// Bootstrap is responsible for app initialization and configuration
/// before the app is run.
Future<void> bootstrap() async {
  // Run everything in a zone to ensure consistent error handling
  runZonedGuarded(() async {
    // Initialize Flutter bindings first
    WidgetsFlutterBinding.ensureInitialized();

    // Silence all debugPrint in release builds globally.
    // Individual debugPrint calls don't need kDebugMode guards
    // when this is installed — the guard is centralized here.
    AppLogger.installGlobalGuard();

    // Track app start time
    AppStartTracker.trackAppStart();

    // Start framework initialization phase
    AppStartTracker.startPhase('framework_init');

    // Load environment variables from .env file
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Warning: Failed to load .env file. Using default values.');
      }
      // Load example environment file as fallback
      try {
        await dotenv.load(fileName: '.env.example');
      } catch (e) {
        if (kDebugMode) {
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
    ErrorHandler().initialize();

    AppStartTracker.endPhase('error_handling_init');

    // Parallelize independent initialization tasks for faster startup.
    // Database, SharedPreferences, Supabase, and Firebase are all independent.
    AppStartTracker.startPhase('parallel_init');

    final results = await Future.wait([
      // Database initialization
      (() async {
        try {
          final service = DatabaseService();
          final initialized = await service.initialize();
          if (initialized) {
            if (kDebugMode) {
              debugPrint('✅ Database initialized successfully');
            }
            return service;
          }
          if (kDebugMode) {
            debugPrint('⚠️ Database initialization returned false');
          }
          return null;
        } catch (e, stackTrace) {
          if (kDebugMode) {
            debugPrint('❌ Database initialization failed: $e');
            debugPrint('Stack trace: $stackTrace');
          }
          return null;
        }
      })(),

      // SharedPreferences initialization
      (() async => SharedPreferences.getInstance())(),

      // Image cache configuration
      (() async => ImageCacheConfig.initialize())(),

      // Supabase initialization
      (() async {
        final supabaseUrl = AppConfig.supabaseUrl;
        final supabaseAnonKey = AppConfig.supabaseAnonKey;
        if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
          await Supabase.initialize(
            url: supabaseUrl,
            anonKey: supabaseAnonKey,
            debug: kDebugMode,
          );
          if (kDebugMode) {
            debugPrint('✅ Supabase initialized successfully');
          }
        } else {
          if (kDebugMode) {
            debugPrint('⚠️ Supabase credentials missing');
            debugPrint('  Set SUPABASE_URL and SUPABASE_ANON_KEY in .env');
          }
        }
      })(),

      // Firebase initialization
      (() async {
        try {
          await Firebase.initializeApp();
          if (kDebugMode) {
            debugPrint('✅ Firebase initialized successfully');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ Firebase initialization failed: $e');
          }
        }
      })(),
    ]);

    final databaseService = results[0] as DatabaseService?;
    final sharedPreferences = results[1] as SharedPreferences;

    // Analytics (PostHog) — opt-in and consent-gated (GDPR). Nothing is
    // collected until the user consents. See docs/analytics-v0.1.md.
    final analyticsConsent = readPersistedAnalyticsConsent(sharedPreferences);
    AnalyticsService analyticsService;
    if (AppConfig.analyticsEnabled) {
      try {
        await PostHogAnalyticsService.setup(
          apiKey: AppConfig.posthogApiKey,
          host: AppConfig.posthogHost,
        );
        analyticsService = ConsentGatedAnalyticsService(
          const PostHogAnalyticsService(),
          consentGranted: analyticsConsent,
          onConsentChanged: PostHogAnalyticsService.setOptedIn,
        );
        // Match the SDK opt-in state to persisted consent on cold start.
        if (analyticsConsent) {
          await PostHogAnalyticsService.setOptedIn(true);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ PostHog init failed, falling back to no-op: $e');
        }
        analyticsService = DebugAnalyticsService();
      }
    } else {
      analyticsService = DebugAnalyticsService();
    }

    AppStartTracker.endPhase('parallel_init');

    // Start provider initialization phase
    AppStartTracker.startPhase('provider_init');

    // Create ProviderContainer for initialization with overrides
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        // Analytics: consent-gated PostHog (or no-op) + prefs for the consent controller.
        analyticsServiceProvider.overrideWithValue(analyticsService),
        analyticsConsentPrefsProvider.overrideWithValue(sharedPreferences),
        if (databaseService != null)
          databaseServiceProvider.overrideWithValue(databaseService),
        // Wire MatchingRepository with real Supabase implementation
        matchingRepositoryProvider.overrideWithValue(
          MatchingRepositoryImpl(
            remoteDataSource: MatchingRemoteDataSourceImpl(
              client: Supabase.instance.client,
            ),
            localDataSource: MatchingLocalDataSourceImpl(),
            isOnline: true, // Default to online; connectivity updates handled by repository
          ),
        ),
        // Wire JournalRepository with real Supabase implementation
        journalRepositoryProvider.overrideWithValue(
          JournalRepositoryImpl(
            remoteDataSource: JournalRemoteDataSourceImpl(
              client: Supabase.instance.client,
            ),
          ),
        ),
      ],
    );

    // Initialize TokenManager (domain service with FeatureAvailability state)
    await container.read(tokenManagerProvider.notifier).initialize();

    // Initialize push notifications
    try {
      final pushService = container.read(pushNotificationServiceProvider);
      await pushService.initialize();
      if (kDebugMode) {
        debugPrint('✅ Push notification service initialized');
      }

      // On token refresh, re-register with Supabase if user is authenticated
      pushService.onTokenRefresh = (token) {
        try {
          final client = Supabase.instance.client;
          final userId = client.auth.currentUser?.id;
          if (userId == null) return;

          final remoteDataSource = MatchingRemoteDataSourceImpl(client: client);
          remoteDataSource.registerNotificationToken(
            token: token,
            platform: Platform.operatingSystem,
          );
          if (kDebugMode) {
            debugPrint('✅ Refreshed push token registered');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ Failed to register refreshed push token: $e');
          }
        }
      };

      // Handle notification tap → navigate to chat screen
      pushService.onNotificationTap = (data) {
        final type = data['type'];
        if (type == 'new_message') {
          final chatId = data['chatId'] ?? '';
          final connectionId = data['connectionId'] ?? '';
          if (connectionId.isNotEmpty) {
            final context = goRouterNavigatorKey.currentContext;
            if (context != null) {
              goRouterNavigatorKey.currentState?.context;
              // Use the router directly to navigate
              final router = container.read(goRouterProvider);
              router.go('/chat/$connectionId', extra: {'chatId': chatId});
            }
          }
        }
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Push notification init failed: $e');
      }
    }

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
/// Updated for Riverpod 3.0 API.
///
/// To enable this observer, uncomment the class and add it to the
/// ProviderContainer/ProviderScope observers parameter.
final class ProviderLogger extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderObserverContext context,
    Object? value,
  ) {
    if (kDebugMode) {
      debugPrint('''
{
  "event": "didAddProvider",
  "provider": "${context.provider}",
  "value": "$value"
}''');
    }
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    if (kDebugMode) {
      debugPrint('''
{
  "event": "didUpdateProvider",
  "provider": "${context.provider}",
  "previousValue": "$previousValue",
  "newValue": "$newValue"
}''');
    }
  }

  @override
  void didDisposeProvider(
    ProviderObserverContext context,
  ) {
    if (kDebugMode) {
      debugPrint('''
{
  "event": "didDisposeProvider",
  "provider": "${context.provider}"
}''');
    }
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    if (kDebugMode) {
      debugPrint('''
{
  "event": "providerDidFail",
  "provider": "${context.provider}",
  "error": "$error",
  "stackTrace": "$stackTrace"
}''');
    }
  }
}

/// This function will be called when the app is run in debug mode
/// to set up any debug-specific configurations.
void setupDebugConfiguration() {
  // Enable additional logging in debug mode
  // Configure development-specific settings
}
