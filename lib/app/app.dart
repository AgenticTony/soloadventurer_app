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
import 'package:soloadventurer/features/auth/presentation/state/auth_navigation_state.dart';

/// Global navigator key provider
final globalNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

/// Provider for the profile route observer
final profileRouteObserverProvider = Provider<ProfileRouteObserver>((ref) {
  final notifier = ref.watch(profileNavigationHistoryProvider.notifier);
  return ProfileRouteObserver(notifier);
});

/// Widget that handles navigation state changes
class NavigationHandler extends ConsumerWidget {
  final Widget child;

  const NavigationHandler({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthNavigationState>(
      authNavigationProvider,
      (previous, current) {
        final request = current.currentRequest;
        if (request == null || request.handled) {
          print('[Navigation] No pending navigation request');
          return;
        }

        final navigator = Navigator.of(context);
        if (!navigator.mounted) {
          print('[Navigation] Navigator not mounted, skipping navigation');
          return;
        }
        
        try {
          if (request.isBack) {
            print('[Navigation] Handling back navigation');
            if (navigator.canPop()) {
              navigator.pop();
            } else {
              print('[Navigation] Cannot pop - no routes to pop');
              return;
            }
          } else {
            print('[Navigation] Handling navigation to ${request.route}');
            navigator.pushNamed(
              request.route,
              arguments: request.arguments,
            );
          }

          // Mark the request as handled only if navigation was successful
          ref.read(authNavigationProvider.notifier).markCurrentRequestHandled();
        } catch (e) {
          print('[Navigation] Error during navigation: $e');
          // Don't mark as handled if navigation failed
        }
      },
    );

    return child;
  }
}

/// The main application widget
class App extends ConsumerWidget {
  /// Creates a new [App] instance
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigatorKey = ref.watch(globalNavigatorKeyProvider);

    return NavigationHandler(
      child: MaterialApp(
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
      ),
    );
  }
}
