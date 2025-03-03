import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/core/providers/core_providers.dart';
import 'package:soloadventurer/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:soloadventurer/features/auth/presentation/screens/login_screen.dart';
import 'package:soloadventurer/features/auth/presentation/screens/signup_screen.dart';
import 'package:soloadventurer/features/home/presentation/screens/home_screen.dart';
import 'package:soloadventurer/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:soloadventurer/features/profile/presentation/screens/profile_screen.dart';
import 'package:soloadventurer/features/profile/presentation/screens/profile_settings_screen.dart';

/// The main application widget
class App extends ConsumerStatefulWidget {
  /// Creates a new [App] instance
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late Future<SharedPreferences> _prefsFuture;

  @override
  void initState() {
    super.initState();
    _prefsFuture = SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: _prefsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            ),
          );
        }

        return ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) => snapshot.data!),
          ],
          child: MaterialApp(
            title: 'SoloAdventurer',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => const AuthWrapper(),
              LoginScreen.routeName: (context) => const LoginScreen(),
              SignUpScreen.routeName: (context) => const SignUpScreen(),
              HomeScreen.routeName: (context) => const HomeScreen(),
              EditProfileScreen.routeName: (context) =>
                  const EditProfileScreen(),
              ProfileScreen.routeName: (context) => const ProfileScreen(),
              ProfileSettingsScreen.routeName: (context) =>
                  const ProfileSettingsScreen(),
            },
          ),
        );
      },
    );
  }
}
