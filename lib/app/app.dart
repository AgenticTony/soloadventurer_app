import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/app/router/go_router_config.dart';
import 'package:soloadventurer/app/theme/app_theme.dart';
import 'package:soloadventurer/app/app_lifecycle_sync_manager.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_navigation_provider.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_navigation_state.dart';
import 'package:soloadventurer/features/auth/presentation/widgets/token_refresh_overlay.dart';
import 'package:soloadventurer/features/auth/presentation/widgets/token_refresh_notification_listener.dart';

/// Widget that handles navigation state changes via go_router
class NavigationHandler extends ConsumerWidget {
  final Widget child;

  const NavigationHandler({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for navigation requests from authNavigationProvider
    ref.listen<AuthNavigationState>(
      authNavigationProvider,
      (previous, current) {
        final request = current.currentRequest;
        if (request == null || request.handled) {
          debugPrint('[Navigation] No pending navigation request');
          return;
        }

        // Get the go_router instance
        final router = ref.read(goRouterProvider);

        try {
          if (request.isBack) {
            debugPrint('[Navigation] Handling back navigation');
            if (router.canPop()) {
              router.pop();
            } else {
              debugPrint('[Navigation] Cannot pop - no routes to pop');
              return;
            }
          } else {
            debugPrint('[Navigation] Handling navigation to ${request.route}');
            // Use go_router's go() method for navigation
            router.go(request.route, extra: request.arguments);
          }

          // Mark the request as handled only if navigation was successful
          ref.read(authNavigationProvider.notifier).markCurrentRequestHandled();
        } catch (e) {
          debugPrint('[Navigation] Error during navigation: $e');
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
    final router = ref.watch(goRouterProvider);

    return AppLifecycleSyncManager(
      child: NavigationHandler(
        child: TokenRefreshNotificationListener(
          child: TokenRefreshOverlay(
            child: MaterialApp.router(
              title: 'SoloAdventurer',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.system,
              debugShowCheckedModeBanner: false,
              routerConfig: router,
            ),
          ),
        ),
      ),
    );
  }
}
