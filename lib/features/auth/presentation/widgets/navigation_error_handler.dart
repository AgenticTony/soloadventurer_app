import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_navigation_provider.dart';

/// A widget that handles navigation errors
class NavigationErrorHandler extends ConsumerWidget {
  /// The child widget to display
  final Widget child;

  /// Creates a new [NavigationErrorHandler]
  const NavigationErrorHandler({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(authNavigationProvider);

    // Show error if there is one
    if (navigationState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(navigationState.error!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ref.read(authNavigationProvider.notifier).clearError();
              },
            ),
          ),
        );

        // Clear the error
        ref.read(authNavigationProvider.notifier).clearError();
      });
    }

    // Show loading indicator if navigating
    if (navigationState.isNavigating) {
      return Stack(
        children: [
          child,
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      );
    }

    return child;
  }
}
