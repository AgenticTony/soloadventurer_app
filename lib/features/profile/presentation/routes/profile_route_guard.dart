import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/error_view.dart';
import 'profile_route_analytics.dart';
import '../../domain/entities/profile_state.dart';
import '../../domain/providers/profile_provider.dart';
import 'package:soloadventurer/features/profile/presentation/state/profile_navigation_state.dart';

enum GuardAction { proceed, redirect, block }

class RouteGuardResult {
  final GuardAction action;
  final String? redirectPath;
  final String? errorMessage;

  const RouteGuardResult({
    required this.action,
    this.redirectPath,
    this.errorMessage,
  });

  static RouteGuardResult proceed() =>
      const RouteGuardResult(action: GuardAction.proceed);

  static RouteGuardResult redirect(String path) => RouteGuardResult(
        action: GuardAction.redirect,
        redirectPath: path,
      );

  static RouteGuardResult block(String message) => RouteGuardResult(
        action: GuardAction.block,
        errorMessage: message,
      );
}

class ProfileRouteGuard extends ConsumerWidget {
  final Widget child;
  final bool requiresProfile;
  final String routeName;

  const ProfileRouteGuard({
    super.key,
    required this.child,
    required this.requiresProfile,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      ProfileRouteAnalytics.trackRouteChange(
        RouteEvent(
          routeName: routeName,
          isError: true,
          errorMessage: state.error.toString(),
        ),
      );

      return ErrorView(
        error: state.error.toString(),
        onRetry: () => ref.refresh(profileProvider),
      );
    }

    final guardResult = _checkGuard(state);

    if (guardResult.action == GuardAction.block) {
      ProfileRouteAnalytics.trackRouteChange(
        RouteEvent(
          routeName: routeName,
          isError: true,
          errorMessage: guardResult.errorMessage,
        ),
      );

      return ErrorView(
        error: guardResult.errorMessage!,
        onRetry: () => ref.refresh(profileProvider),
      );
    }

    if (guardResult.action == GuardAction.redirect) {
      ProfileRouteAnalytics.trackRouteChange(
        RouteEvent(
          routeName: routeName,
          isError: false,
          parameters: {'redirect': guardResult.redirectPath},
        ),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(guardResult.redirectPath!);
      });
      return const SizedBox.shrink();
    }

    return child;
  }

  RouteGuardResult _checkGuard(ProfileState state) {
    if (requiresProfile && state.profile == null) {
      return RouteGuardResult.block('Profile is required to access this page');
    }
    return RouteGuardResult.proceed();
  }
}

/// Observer for profile route navigation
class ProfileRouteObserver extends NavigatorObserver {
  final ProfileNavigationState _navigationState;

  /// Creates a new [ProfileRouteObserver]
  ProfileRouteObserver(this._navigationState);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      _navigationState.history.add(route.settings.name!);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (_navigationState.history.isNotEmpty) {
      _navigationState.history.removeLast();
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute?.settings.name != null) {
      if (_navigationState.history.isNotEmpty) {
        _navigationState.history.removeLast();
      }
      _navigationState.history.add(newRoute!.settings.name!);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (route.settings.name != null) {
      _navigationState.history.remove(route.settings.name);
    }
  }
}
