// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_navigation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for handling auth-related navigation state
///
/// Uses Riverpod 3.0 @riverpod annotation with Notifier pattern.
/// Monitors auth state changes and handles navigation accordingly.

@ProviderFor(AuthNavigation)
const authNavigationProvider = AuthNavigationProvider._();

/// Provider for handling auth-related navigation state
///
/// Uses Riverpod 3.0 @riverpod annotation with Notifier pattern.
/// Monitors auth state changes and handles navigation accordingly.
final class AuthNavigationProvider
    extends $NotifierProvider<AuthNavigation, AuthNavigationState> {
  /// Provider for handling auth-related navigation state
  ///
  /// Uses Riverpod 3.0 @riverpod annotation with Notifier pattern.
  /// Monitors auth state changes and handles navigation accordingly.
  const AuthNavigationProvider._()
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
  String debugGetCreateSourceHash() => _$authNavigationHash();

  @$internal
  @override
  AuthNavigation create() => AuthNavigation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthNavigationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthNavigationState>(value),
    );
  }
}

String _$authNavigationHash() => r'7153f8550d7b9e77a5041b71ef552e877549f203';

/// Provider for handling auth-related navigation state
///
/// Uses Riverpod 3.0 @riverpod annotation with Notifier pattern.
/// Monitors auth state changes and handles navigation accordingly.

abstract class _$AuthNavigation extends $Notifier<AuthNavigationState> {
  AuthNavigationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AuthNavigationState, AuthNavigationState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AuthNavigationState, AuthNavigationState>,
        AuthNavigationState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

/// Global navigator key for handling navigation from providers

@ProviderFor(navigatorKey)
const navigatorKeyProvider = NavigatorKeyProvider._();

/// Global navigator key for handling navigation from providers

final class NavigatorKeyProvider extends $FunctionalProvider<
    GlobalKey<NavigatorState>,
    GlobalKey<NavigatorState>,
    GlobalKey<NavigatorState>> with $Provider<GlobalKey<NavigatorState>> {
  /// Global navigator key for handling navigation from providers
  const NavigatorKeyProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'navigatorKeyProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$navigatorKeyHash();

  @$internal
  @override
  $ProviderElement<GlobalKey<NavigatorState>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GlobalKey<NavigatorState> create(Ref ref) {
    return navigatorKey(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GlobalKey<NavigatorState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GlobalKey<NavigatorState>>(value),
    );
  }
}

String _$navigatorKeyHash() => r'6e9d7249fe86101ea2092a8617d10993370d5975';
