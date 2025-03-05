import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/app/router/app_router.dart';
import 'package:soloadventurer/app/theme/app_theme.dart';
import 'package:soloadventurer/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:soloadventurer/features/auth/presentation/screens/login_screen.dart';
import 'package:soloadventurer/features/auth/presentation/screens/signup_screen.dart';
import 'package:soloadventurer/features/home/presentation/screens/home_screen.dart';
import 'package:soloadventurer/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:soloadventurer/features/profile/presentation/screens/profile_screen.dart';
import 'package:soloadventurer/features/profile/presentation/screens/profile_settings_screen.dart';
import 'package:soloadventurer/features/profile/presentation/routes/profile_route_guard.dart';
import 'package:soloadventurer/features/profile/presentation/providers/profile_providers.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_navigation_provider.dart';

/// Provider for the profile route observer
final profileRouteObserverProvider = Provider<ProfileRouteObserver>((ref) {
  final notifier = ref.watch(profileNavigationHistoryProvider.notifier);
  return ProfileRouteObserver(notifier);
});

/// The main application widget
class App extends ConsumerWidget {
  /// Creates a new [App] instance
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigatorKey = ref.watch(navigatorKeyProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'SoloAdventurer',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: '/',
      navigatorObservers: [
        NavigatorObserver(),
      ],
    );
  }
}
