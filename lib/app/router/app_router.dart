import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_provider.dart';
import 'package:soloadventurer/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:soloadventurer/features/auth/presentation/screens/login_screen.dart';
import 'package:soloadventurer/features/auth/presentation/screens/signup_screen.dart';
import 'package:soloadventurer/features/home/presentation/screens/home_screen.dart';
import 'package:soloadventurer/features/profile/presentation/routes/profile_routes.dart';

/// App router for handling navigation
class AppRouter {
  /// Generate routes for the app
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Check if it's a profile route
    final profileRoute = ProfileRoutes.onGenerateRoute(settings);
    if (profileRoute != null) return profileRoute;

    // Handle profile deep links
    if (settings.name?.startsWith('/profile/') ?? false) {
      final uri = Uri.parse(settings.name!);
      final params = ProfileRoutes.parseProfileDeepLink(uri);
      if (params != null) {
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              const Placeholder(), // TODO: Replace with actual profile screen
        );
      }
    }

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const AuthWrapper(),
        );
      case LoginScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case SignUpScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
        );
      case HomeScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      // Add more routes here as needed
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  /// Get all app routes
  static Map<String, WidgetBuilder> get routes {
    return {
      '/': (context) => const AuthWrapper(),
      LoginScreen.routeName: (context) => const LoginScreen(),
      SignUpScreen.routeName: (context) => const SignUpScreen(),
      HomeScreen.routeName: (context) => const HomeScreen(),
      ...ProfileRoutes.routes,
    };
  }

  /// Generate initial routes for profile deep links
  static List<MaterialPageRoute> generateInitialProfileRoutes(
      ProfileDeepLinkParams params) {
    return ProfileRoutes.generateProfileRoutes(params);
  }
}

/// Placeholder home screen
class HomeScreen extends StatelessWidget {
  /// Creates a new [HomeScreen]
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SoloAdventurer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => ProfileRoutes.navigateToProfile(context),
            tooltip: 'Profile',
          ),
          Consumer(
            builder: (context, ref, _) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  ref.read(authProvider.notifier).signOut();
                },
                tooltip: 'Sign Out',
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to SoloAdventurer!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
