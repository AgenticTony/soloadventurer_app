import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/app/router/app_router.dart';
import 'package:soloadventurer/app/theme/app_theme.dart';
import 'package:soloadventurer/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:soloadventurer/features/profile/presentation/routes/profile_route_guard.dart';
import 'package:soloadventurer/features/profile/presentation/routes/profile_routes.dart';
import 'package:soloadventurer/features/profile/presentation/providers/profile_providers.dart';

/// Main application widget
class MyApp extends StatelessWidget {
  /// Creates a new [MyApp]
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final navigationHistory = ref.watch(profileNavigationHistoryProvider);

        return MaterialApp(
          title: 'SoloAdventurer',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          onGenerateRoute: AppRouter.generateRoute,
          initialRoute: '/',
          navigatorObservers: [
            ProfileRouteObserver(navigationHistory),
          ],
          onGenerateInitialRoutes: (String initialRoute) {
            if (initialRoute != '/') {
              final uri = Uri.parse(initialRoute);
              final profileParams = ProfileRoutes.parseProfileDeepLink(uri);
              if (profileParams != null) {
                return [
                  MaterialPageRoute(
                    builder: (_) => const AuthWrapper(),
                  ),
                  ...AppRouter.generateInitialProfileRoutes(profileParams),
                ];
              }
            }
            return [
              MaterialPageRoute(
                builder: (_) => const AuthWrapper(),
              ),
            ];
          },
        );
      },
    );
  }
}
