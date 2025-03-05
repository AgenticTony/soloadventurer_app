import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_providers.dart';
import '../state/profile_state.dart';
import '../widgets/error_view.dart';
import 'profile_route_analytics.dart';
import 'package:soloadventurer/features/profile/presentation/state/profile_navigation_state.dart';

enum GuardAction { proceed, redirect, block }

/// Result of a guard check
class GuardResult {
  final GuardAction action;
  final String? redirectPath;
  final String? errorMessage;

  const GuardResult({
    required this.action,
    this.redirectPath,
    this.errorMessage,
  });

  static const GuardResult proceed = GuardResult(action: GuardAction.proceed);
}

/// Base class for profile route guards
abstract class ProfileRouteGuard extends ConsumerWidget {
  final Widget child;
  final String redirectPath;

  const ProfileRouteGuard({
    super.key,
    required this.child,
    required this.redirectPath,
  });

  /// Check if the route should be guarded
  Future<GuardResult> checkGuard(ProfileState state);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileUIProvider('current'));

    if (state.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.hasError) {
      return ErrorView(
        error: state.error.toString(),
        onRetry: () => ref.refresh(profileUIProvider('current')),
      );
    }

    return FutureBuilder<GuardResult>(
      future: checkGuard(state),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return ErrorView(
            error: snapshot.error.toString(),
            onRetry: () => ref.refresh(profileUIProvider('current')),
          );
        }

        final guardResult = snapshot.data ?? GuardResult.proceed;

        switch (guardResult.action) {
          case GuardAction.proceed:
            // TODO: Implement analytics tracking
            return child;
          case GuardAction.redirect:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed(
                guardResult.redirectPath ?? redirectPath,
              );
            });
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          case GuardAction.block:
            return ErrorView(
              error: guardResult.errorMessage!,
              onRetry: () => ref.refresh(profileUIProvider('current')),
            );
        }
      },
    );
  }
}

/// Observer for profile route navigation
class ProfileRouteObserver extends NavigatorObserver {
  final ProfileNavigationNotifier _navigationNotifier;

  /// Creates a new [ProfileRouteObserver]
  ProfileRouteObserver(this._navigationNotifier);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      _navigationNotifier.addRoute(route.settings.name!);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _navigationNotifier.removeLastRoute();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute?.settings.name != null) {
      _navigationNotifier.removeLastRoute();
      _navigationNotifier.addRoute(newRoute!.settings.name!);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (route.settings.name != null) {
      // Since we can't directly remove a specific route from the middle of the history,
      // we'll need to rebuild the history without the removed route
      final currentState = _navigationNotifier.state;
      final newHistory =
          currentState.history.where((r) => r != route.settings.name).toList();
      _navigationNotifier.state = ProfileNavigationState(history: newHistory);
    }
  }
}
