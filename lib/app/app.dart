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

/// Provider for the profile route observer
final profileRouteObserverProvider = Provider<ProfileRouteObserver>((ref) {
  final notifier = ref.watch(profileNavigationHistoryProvider.notifier);
  return ProfileRouteObserver(notifier);
});

/// Global navigator key
final navigatorKey = GlobalKey<NavigatorState>();

/// Widget that handles navigation state changes
class NavigationHandler extends ConsumerStatefulWidget {
  final Widget child;

  const NavigationHandler({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<NavigationHandler> createState() => _NavigationHandlerState();
}

class _NavigationHandlerState extends ConsumerState<NavigationHandler> {
  @override
  Widget build(BuildContext context) {
    ref.listen<AuthNavigationState>(
      authNavigationProvider,
      (previous, current) {
        final request = current.currentRequest;
        if (request == null || request.handled) {
          debugPrint('[Navigation] No pending navigation request');
          return;
        }

        final navigatorState = navigatorKey.currentState;
        if (navigatorState == null) {
          debugPrint(
              '[Navigation] Navigator not available, skipping navigation');
          return;
        }

        try {
          if (request.isBack) {
            debugPrint('[Navigation] Handling back navigation');
            if (navigatorState.canPop()) {
              navigatorState.pop();
            } else {
              debugPrint('[Navigation] Cannot pop - no routes to pop');
              return;
            }
          } else {
            debugPrint('[Navigation] Handling navigation to ${request.route}');
            navigatorState.pushNamed(
              request.route,
              arguments: request.arguments,
            );
          }

          // Mark the request as handled only if navigation was successful
          ref.read(authNavigationProvider.notifier).markCurrentRequestHandled();
        } catch (e) {
          debugPrint('[Navigation] Error during navigation: $e');
          // Don't mark as handled if navigation failed
        }
      },
    );

    return widget.child;
  }
}

/// The main application widget
class App extends ConsumerWidget {
  /// Creates a new [App] instance
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        ref.watch(profileRouteObserverProvider),
      ],
      builder: (context, child) {
        if (child == null) return const SizedBox();
        return NavigationHandler(child: child);
      },
    );
  }
}
