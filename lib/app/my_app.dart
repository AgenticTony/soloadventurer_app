import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/app/theme/app_theme.dart';
import 'package:soloadventurer/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:soloadventurer/features/profile/presentation/routes/profile_routes.dart';

/// The root widget of the application
class MyApp extends ConsumerWidget {
  /// Creates a new [MyApp] instance
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Solo Adventurer',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
      onGenerateRoute: ProfileRoutes.onGenerateRoute,
    );
  }
}
