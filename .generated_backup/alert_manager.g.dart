// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cloudWatchClientHash() => r'6f4d1e1c3bcbdcb35f78e221f908d9332b0d9a54';

/// Provider for CloudWatch client
///
/// Copied from [cloudWatchClient].
@ProviderFor(cloudWatchClient)
final cloudWatchClientProvider = AutoDisposeProvider<CloudWatch>.internal(
  cloudWatchClient,
  name: r'cloudWatchClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cloudWatchClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CloudWatchClientRef = AutoDisposeProviderRef<CloudWatch>;
String _$alertManagerHash() => r'78c9bfa1782f76a4535c8507950f116db1e10691';

/// Manager responsible for handling security alerts and notifications
///
/// Copied from [AlertManager].
@ProviderFor(AlertManager)
final alertManagerProvider =
    AutoDisposeAsyncNotifierProvider<AlertManager, void>.internal(
  AlertManager.new,
  name: r'alertManagerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$alertManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AlertManager = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
