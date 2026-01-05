// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_manager_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncManagerHash() => r'41b9f28455eb6223a49c513f5494f6420ac03355';

/// Provider for the SyncManager that properly provides the userId callback
///
/// This provider creates a SyncManagerImpl with a getCurrentUserId callback
/// that reads from the auth state. This allows the sync manager to access
/// the current user ID without requiring a ProviderContainer at construction time.
///
/// Copied from [syncManager].
@ProviderFor(syncManager)
final syncManagerProvider = Provider<SyncManager>.internal(
  syncManager,
  name: r'syncManagerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$syncManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncManagerRef = ProviderRef<SyncManager>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
