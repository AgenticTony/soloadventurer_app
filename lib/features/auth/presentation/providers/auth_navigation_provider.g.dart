// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_navigation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$navigatorKeyHash() => r'8b4dbfb31d887f8bbb1a13b7214b897e71dac1f7';

/// Global navigator key for handling navigation from providers
///
/// Copied from [navigatorKey].
@ProviderFor(navigatorKey)
final navigatorKeyProvider =
    AutoDisposeProvider<GlobalKey<NavigatorState>>.internal(
  navigatorKey,
  name: r'navigatorKeyProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$navigatorKeyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NavigatorKeyRef = AutoDisposeProviderRef<GlobalKey<NavigatorState>>;
String _$authNavigationHash() => r'e94fb3deb043d0d619efc61e1383ecc654ce0a65';

/// Provider for handling auth-related navigation state
///
/// Uses Riverpod 3.0 @riverpod annotation with Notifier pattern.
/// Monitors auth state changes and handles navigation accordingly.
///
/// Copied from [AuthNavigation].
@ProviderFor(AuthNavigation)
final authNavigationProvider =
    AutoDisposeNotifierProvider<AuthNavigation, AuthNavigationState>.internal(
  AuthNavigation.new,
  name: r'authNavigationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authNavigationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthNavigation = AutoDisposeNotifier<AuthNavigationState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
