// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connectivityServiceHash() =>
    r'5b7e4948cef2ab1c6394bec82a52f9b8b8c94263';

/// Provider for the connectivity service implementation
///
/// Copied from [connectivityService].
@ProviderFor(connectivityService)
final connectivityServiceProvider =
    AutoDisposeProvider<ConnectivityService>.internal(
  connectivityService,
  name: r'connectivityServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectivityServiceRef = AutoDisposeProviderRef<ConnectivityService>;
String _$networkStatusNotifierHash() =>
    r'9e5d0d4958a6e4fe31c8dbcf4fc4c90ba35c0993';

/// Provider that exposes the current network status
///
/// Copied from [NetworkStatusNotifier].
@ProviderFor(NetworkStatusNotifier)
final networkStatusNotifierProvider = AutoDisposeAsyncNotifierProvider<
    NetworkStatusNotifier, NetworkStatus>.internal(
  NetworkStatusNotifier.new,
  name: r'networkStatusNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$networkStatusNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NetworkStatusNotifier = AutoDisposeAsyncNotifier<NetworkStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
