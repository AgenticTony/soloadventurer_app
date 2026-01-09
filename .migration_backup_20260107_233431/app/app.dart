import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/app/router/go_router_config.dart';
import 'package:soloadventurer/app/theme/app_theme.dart';
import 'package:soloadventurer/app/app_lifecycle_sync_manager.dart';
import 'package:soloadventurer/features/auth/presentation/widgets/token_refresh_overlay.dart';

/// The main application widget
class App extends ConsumerWidget {
  /// Creates a new [App] instance
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routerConfig = ref.watch(goRouterProvider);

    return AppLifecycleSyncManager(
      child: TokenRefreshOverlay(
        child: MaterialApp.router(
          title: 'SoloAdventurer',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          routerConfig: routerConfig,
        ),
      ),
    );
  }
}
