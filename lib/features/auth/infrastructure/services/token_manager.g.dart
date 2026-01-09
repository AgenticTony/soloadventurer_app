// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tokenManagerHash() => r'e6cf8ad909444a80325358fa9dc0e542b876b907';

/// Manages authentication tokens and their lifecycle according to AWS Cognito specifications
///
/// Copied from [TokenManager].
@ProviderFor(TokenManager)
final tokenManagerProvider =
    NotifierProvider<TokenManager, FeatureAvailability>.internal(
  TokenManager.new,
  name: r'tokenManagerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tokenManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TokenManager = Notifier<FeatureAvailability>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
