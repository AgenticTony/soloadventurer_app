import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import 'package:soloadventurer/app/my_app.dart';
import 'package:soloadventurer/core/monitoring/performance/app_start_tracker.dart';
import 'package:soloadventurer/core/errors/error_handler.dart';
import 'package:soloadventurer/core/providers/core_providers.dart';

/// Bootstrap is responsible for app initialization and configuration
/// before the app is run.
Future<void> bootstrap() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Track app start time
  AppStartTracker.trackAppStart();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize service locator
  await setupServiceLocator();

  // Initialize error handling
  ErrorHandler.initialize();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Run the app in a zone to catch errors
  runZonedGuarded(
    () => runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const MyApp(),
      ),
    ),
    (error, stackTrace) {
      // Report any errors not caught by the Flutter framework
      ErrorHandler.reportError(
        'Uncaught exception',
        error,
        stackTrace,
      );
    },
  );
}

/// This function will be called when the app is run in debug mode
/// to set up any debug-specific configurations.
void setupDebugConfiguration() {
  // Enable additional logging in debug mode
  // Configure development-specific settings
}
