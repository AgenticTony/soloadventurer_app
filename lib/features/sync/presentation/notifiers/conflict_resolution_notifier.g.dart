// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conflict_resolution_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing conflict resolution state and user interactions
///
/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier<AsyncValue<T>> to AsyncNotifier<T>
/// - build() method returns ConflictResolutionState directly (not wrapped in AsyncValue)
/// - AsyncValue wrapping is handled automatically by the framework
/// - mounted checks removed (handled automatically by Riverpod 3.0)
/// - Dependencies injected via ref.watch() in build() method
///
/// Handles the complete flow of conflict resolution:
/// 1. Receives conflict detection events
/// 2. Shows resolution UI to user
/// 3. Processes user's resolution choice
/// 4. Applies resolution to local data store
/// 5. Queues sync operations for remote update
/// 6. Updates UI state

@ProviderFor(ConflictResolutionNotifier)
final conflictResolutionProvider = ConflictResolutionNotifierProvider._();

/// Notifier for managing conflict resolution state and user interactions
///
/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier<AsyncValue<T>> to AsyncNotifier<T>
/// - build() method returns ConflictResolutionState directly (not wrapped in AsyncValue)
/// - AsyncValue wrapping is handled automatically by the framework
/// - mounted checks removed (handled automatically by Riverpod 3.0)
/// - Dependencies injected via ref.watch() in build() method
///
/// Handles the complete flow of conflict resolution:
/// 1. Receives conflict detection events
/// 2. Shows resolution UI to user
/// 3. Processes user's resolution choice
/// 4. Applies resolution to local data store
/// 5. Queues sync operations for remote update
/// 6. Updates UI state
final class ConflictResolutionNotifierProvider extends $NotifierProvider<
    ConflictResolutionNotifier, ConflictResolutionState> {
  /// Notifier for managing conflict resolution state and user interactions
  ///
  /// Riverpod 3.0 Migration Notes:
  /// - Converted from StateNotifier<AsyncValue<T>> to AsyncNotifier<T>
  /// - build() method returns ConflictResolutionState directly (not wrapped in AsyncValue)
  /// - AsyncValue wrapping is handled automatically by the framework
  /// - mounted checks removed (handled automatically by Riverpod 3.0)
  /// - Dependencies injected via ref.watch() in build() method
  ///
  /// Handles the complete flow of conflict resolution:
  /// 1. Receives conflict detection events
  /// 2. Shows resolution UI to user
  /// 3. Processes user's resolution choice
  /// 4. Applies resolution to local data store
  /// 5. Queues sync operations for remote update
  /// 6. Updates UI state
  ConflictResolutionNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'conflictResolutionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$conflictResolutionNotifierHash();

  @$internal
  @override
  ConflictResolutionNotifier create() => ConflictResolutionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConflictResolutionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConflictResolutionState>(value),
    );
  }
}

String _$conflictResolutionNotifierHash() =>
    r'863e9736c7a038e1abda487c2c32b44ab2805848';

/// Notifier for managing conflict resolution state and user interactions
///
/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier<AsyncValue<T>> to AsyncNotifier<T>
/// - build() method returns ConflictResolutionState directly (not wrapped in AsyncValue)
/// - AsyncValue wrapping is handled automatically by the framework
/// - mounted checks removed (handled automatically by Riverpod 3.0)
/// - Dependencies injected via ref.watch() in build() method
///
/// Handles the complete flow of conflict resolution:
/// 1. Receives conflict detection events
/// 2. Shows resolution UI to user
/// 3. Processes user's resolution choice
/// 4. Applies resolution to local data store
/// 5. Queues sync operations for remote update
/// 6. Updates UI state

abstract class _$ConflictResolutionNotifier
    extends $Notifier<ConflictResolutionState> {
  ConflictResolutionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<ConflictResolutionState, ConflictResolutionState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ConflictResolutionState, ConflictResolutionState>,
        ConflictResolutionState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
