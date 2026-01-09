// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$securityManagerHash() => r'd696a60ffb495a551429352522a5ce858c9af2f1';

/// Manages security-related features like rate limiting and device tracking
///
/// Copied from [SecurityManager].
@ProviderFor(SecurityManager)
final securityManagerProvider =
    AutoDisposeNotifierProvider<SecurityManager, SecurityManager>.internal(
  SecurityManager.new,
  name: r'securityManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$securityManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SecurityManager = AutoDisposeNotifier<SecurityManager>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
