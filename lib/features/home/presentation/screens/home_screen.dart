import 'package:flutter/material.dart'
    show StatelessWidget, BuildContext, Widget, Navigator;
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_provider.dart';
import 'package:soloadventurer/features/profile/presentation/routes/profile_routes.dart';
import 'package:flutter/foundation.dart';

/// Home screen of the app
class HomeScreen extends StatelessWidget {
  /// Creates a new [HomeScreen]
  const HomeScreen({super.key});

  /// Route name for navigation
  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return material.Scaffold(
      appBar: material.AppBar(
        title: const material.Text('SoloAdventurer'),
        actions: [
          material.IconButton(
            icon: const material.Icon(material.Icons.person),
            onPressed: () => ProfileRoutes.navigateToProfile(context),
            tooltip: 'Profile',
          ),
          Consumer(
            builder: (context, ref, _) {
              return material.IconButton(
                icon: const material.Icon(material.Icons.logout),
                onPressed: () async {
                  debugPrint('Logout button pressed');
                  await ref.read(authProvider.notifier).signOut();
                  debugPrint('Sign out completed');

                  if (context.mounted) {
                    // Clear the entire navigation stack and push login screen
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false, // This removes all routes
                    );
                  }
                },
                tooltip: 'Sign Out',
              );
            },
          ),
        ],
      ),
      body: const material.Center(
        child: material.Text(
          'Welcome to SoloAdventurer!',
          key: material.Key('home_screen_title'),
          style: material.TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
