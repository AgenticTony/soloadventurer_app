// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conflict_resolution_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing conflict resolution state and user interactions
///
/// Riverpod 3.0 AsyncNotifier Migration:
/// - Uses AsyncNotifier pattern with AsyncValue wrapper
/// - Loading/error states handled by AsyncValue, NOT manual state fields
/// - isResolving/errorMessage removed from state (AsyncValue handles them)
/// - Async methods use AsyncValue.guard() for loading/error handling
/// - UI reads state via ref.watch(conflictResolutionProvider)
/// - UI calls methods via ref.read(conflictResolutionProvider.notifier)

@ProviderFor(ConflictResolutionNotifier)
const conflictResolutionProvider = ConflictResolutionNotifierProvider._();

/// Notifier for managing conflict resolution state and user interactions
///
/// Riverpod 3.0 AsyncNotifier Migration:
/// - Uses AsyncNotifier pattern with AsyncValue wrapper
/// - Loading/error states handled by AsyncValue, NOT manual state fields
/// - isResolving/errorMessage removed from state (AsyncValue handles them)
/// - Async methods use AsyncValue.guard() for loading/error handling
/// - UI reads state via ref.watch(conflictResolutionProvider)
/// - UI calls methods via ref.read(conflictResolutionProvider.notifier)
final class ConflictResolutionNotifierProvider extends $AsyncNotifierProvider<
    ConflictResolutionNotifier, ConflictResolutionState> {
  /// Notifier for managing conflict resolution state and user interactions
  ///
  /// Riverpod 3.0 AsyncNotifier Migration:
  /// - Uses AsyncNotifier pattern with AsyncValue wrapper
  /// - Loading/error states handled by AsyncValue, NOT manual state fields
  /// - isResolving/errorMessage removed from state (AsyncValue handles them)
  /// - Async methods use AsyncValue.guard() for loading/error handling
  /// - UI reads state via ref.watch(conflictResolutionProvider)
  /// - UI calls methods via ref.read(conflictResolutionProvider.notifier)
  const ConflictResolutionNotifierProvider._()
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
}

String _$conflictResolutionNotifierHash() =>
    r'104b314bf695ed4a2b404fffb58b627c99e3ba82';

/// Notifier for managing conflict resolution state and user interactions
///
/// Riverpod 3.0 AsyncNotifier Migration:
/// - Uses AsyncNotifier pattern with AsyncValue wrapper
/// - Loading/error states handled by AsyncValue, NOT manual state fields
/// - isResolving/errorMessage removed from state (AsyncValue handles them)
/// - Async methods use AsyncValue.guard() for loading/error handling
/// - UI reads state via ref.watch(conflictResolutionProvider)
/// - UI calls methods via ref.read(conflictResolutionProvider.notifier)

abstract class _$ConflictResolutionNotifier
    extends $AsyncNotifier<ConflictResolutionState> {
  FutureOr<ConflictResolutionState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref
        as $Ref<AsyncValue<ConflictResolutionState>, ConflictResolutionState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<ConflictResolutionState>,
            ConflictResolutionState>,
        AsyncValue<ConflictResolutionState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
