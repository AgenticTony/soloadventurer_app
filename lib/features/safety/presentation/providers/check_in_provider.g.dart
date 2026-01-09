// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$checkInNotifierHash() => r'973c682ad5755e9c70bae01201ffda32126b75e8';

/// Notifier for managing check-in state
/// Handles check-in creation, completion, scheduling, and cancellation
///
/// Riverpod 2 Compliant:
/// - Uses AutoDisposeNotifier (auto-disposes when unused)
/// - NO getters in state - all derived values are fields
/// - UI reads STATE only via ref.watch()
/// - UI calls methods via ref.read(provider.notifier)
///
/// Copied from [CheckInNotifier].
@ProviderFor(CheckInNotifier)
final checkInNotifierProvider =
    AutoDisposeNotifierProvider<CheckInNotifier, CheckInState>.internal(
  CheckInNotifier.new,
  name: r'checkInNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$checkInNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CheckInNotifier = AutoDisposeNotifier<CheckInState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
