// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_navigation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for GoRouterService (kept for DI compatibility)

@ProviderFor(goRouterService)
final goRouterServiceProvider = GoRouterServiceProvider._();

/// Provider for GoRouterService (kept for DI compatibility)

final class GoRouterServiceProvider extends $FunctionalProvider<GoRouterService,
    GoRouterService, GoRouterService> with $Provider<GoRouterService> {
  /// Provider for GoRouterService (kept for DI compatibility)
  GoRouterServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'goRouterServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$goRouterServiceHash();

  @$internal
  @override
  $ProviderElement<GoRouterService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouterService create(Ref ref) {
    return goRouterService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouterService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouterService>(value),
    );
  }
}

String _$goRouterServiceHash() => r'6ab5412fbcc62d52c815dea1ca5fa448f139bf18';

/// Notifier for handling auth-related navigation
///
/// This notifier provides convenience methods for navigating to various
/// screens in the app. With go_router, auth redirects are handled automatically,
/// so this class focuses on programmatic navigation from UI elements.
///
/// With go_router, most auth navigation is handled automatically by the
/// router's redirect logic. This provider now serves as a convenience
/// layer for programmatic navigation from UI elements and providers.

@ProviderFor(AuthNavigationNotifier)
final authNavigationProvider = AuthNavigationNotifierProvider._();

/// Notifier for handling auth-related navigation
///
/// This notifier provides convenience methods for navigating to various
/// screens in the app. With go_router, auth redirects are handled automatically,
/// so this class focuses on programmatic navigation from UI elements.
///
/// With go_router, most auth navigation is handled automatically by the
/// router's redirect logic. This provider now serves as a convenience
/// layer for programmatic navigation from UI elements and providers.
final class AuthNavigationNotifierProvider
    extends $NotifierProvider<AuthNavigationNotifier, AuthNavigationState> {
  /// Notifier for handling auth-related navigation
  ///
  /// This notifier provides convenience methods for navigating to various
  /// screens in the app. With go_router, auth redirects are handled automatically,
  /// so this class focuses on programmatic navigation from UI elements.
  ///
  /// With go_router, most auth navigation is handled automatically by the
  /// router's redirect logic. This provider now serves as a convenience
  /// layer for programmatic navigation from UI elements and providers.
  AuthNavigationNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authNavigationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authNavigationNotifierHash();

  @$internal
  @override
  AuthNavigationNotifier create() => AuthNavigationNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthNavigationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthNavigationState>(value),
    );
  }
}

String _$authNavigationNotifierHash() =>
    r'479582ce5f5f7e92bdb7c898573f73612711240f';

/// Notifier for handling auth-related navigation
///
/// This notifier provides convenience methods for navigating to various
/// screens in the app. With go_router, auth redirects are handled automatically,
/// so this class focuses on programmatic navigation from UI elements.
///
/// With go_router, most auth navigation is handled automatically by the
/// router's redirect logic. This provider now serves as a convenience
/// layer for programmatic navigation from UI elements and providers.

abstract class _$AuthNavigationNotifier extends $Notifier<AuthNavigationState> {
  AuthNavigationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AuthNavigationState, AuthNavigationState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AuthNavigationState, AuthNavigationState>,
        AuthNavigationState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
