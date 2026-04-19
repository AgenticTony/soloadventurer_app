// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_operation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier to @riverpod Notifier
/// - Dependencies injected via ref.watch() in build() method
/// - Keeps `AsyncValue<void>` state pattern (synchronous Notifier with AsyncValue state)
/// - Initialization logic moved from constructor to build() method
///
/// Provider for the travel operation repository

@ProviderFor(travelOperationRepository)
const travelOperationRepositoryProvider = TravelOperationRepositoryProvider._();

/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier to @riverpod Notifier
/// - Dependencies injected via ref.watch() in build() method
/// - Keeps `AsyncValue<void>` state pattern (synchronous Notifier with AsyncValue state)
/// - Initialization logic moved from constructor to build() method
///
/// Provider for the travel operation repository

final class TravelOperationRepositoryProvider extends $FunctionalProvider<
    TravelOperationRepository,
    TravelOperationRepository,
    TravelOperationRepository> with $Provider<TravelOperationRepository> {
  /// Riverpod 3.0 Migration Notes:
  /// - Converted from StateNotifier to @riverpod Notifier
  /// - Dependencies injected via ref.watch() in build() method
  /// - Keeps `AsyncValue<void>` state pattern (synchronous Notifier with AsyncValue state)
  /// - Initialization logic moved from constructor to build() method
  ///
  /// Provider for the travel operation repository
  const TravelOperationRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'travelOperationRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$travelOperationRepositoryHash();

  @$internal
  @override
  $ProviderElement<TravelOperationRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TravelOperationRepository create(Ref ref) {
    return travelOperationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TravelOperationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TravelOperationRepository>(value),
    );
  }
}

String _$travelOperationRepositoryHash() =>
    r'6318ee50665a4c2aae8b61e401560e0e7197a90f';

/// Provider for pending operations
///
/// Riverpod 3.0: Uses @riverpod annotation for FutureProvider

@ProviderFor(pendingOperations)
const pendingOperationsProvider = PendingOperationsProvider._();

/// Provider for pending operations
///
/// Riverpod 3.0: Uses @riverpod annotation for FutureProvider

final class PendingOperationsProvider extends $FunctionalProvider<
        AsyncValue<List<BaseTravelOperation>>,
        List<BaseTravelOperation>,
        FutureOr<List<BaseTravelOperation>>>
    with
        $FutureModifier<List<BaseTravelOperation>>,
        $FutureProvider<List<BaseTravelOperation>> {
  /// Provider for pending operations
  ///
  /// Riverpod 3.0: Uses @riverpod annotation for FutureProvider
  const PendingOperationsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pendingOperationsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pendingOperationsHash();

  @$internal
  @override
  $FutureProviderElement<List<BaseTravelOperation>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<BaseTravelOperation>> create(Ref ref) {
    return pendingOperations(ref);
  }
}

String _$pendingOperationsHash() => r'285db1be87dc0a53f0642f5a4215faad86710987';

/// Provider for managing travel operation state
///
/// Riverpod 3.0: Uses @riverpod annotation with Notifier pattern.
/// Keeps `AsyncValue<void>` state for tracking operation status.
///
/// Usage:
/// ```dart
/// final operationState = ref.watch(travelOperationNotifierProvider);
/// final operationNotifier = ref.read(travelOperationNotifierProvider.notifier);
///
/// // Add operation
/// await operationNotifier.addOperation(operation);
///
/// // Process operation
/// await operationNotifier.processOperation(operationId);
/// ```

@ProviderFor(TravelOperation)
const travelOperationProvider = TravelOperationProvider._();

/// Provider for managing travel operation state
///
/// Riverpod 3.0: Uses @riverpod annotation with Notifier pattern.
/// Keeps `AsyncValue<void>` state for tracking operation status.
///
/// Usage:
/// ```dart
/// final operationState = ref.watch(travelOperationNotifierProvider);
/// final operationNotifier = ref.read(travelOperationNotifierProvider.notifier);
///
/// // Add operation
/// await operationNotifier.addOperation(operation);
///
/// // Process operation
/// await operationNotifier.processOperation(operationId);
/// ```
final class TravelOperationProvider
    extends $NotifierProvider<TravelOperation, AsyncValue<void>> {
  /// Provider for managing travel operation state
  ///
  /// Riverpod 3.0: Uses @riverpod annotation with Notifier pattern.
  /// Keeps `AsyncValue<void>` state for tracking operation status.
  ///
  /// Usage:
  /// ```dart
  /// final operationState = ref.watch(travelOperationNotifierProvider);
  /// final operationNotifier = ref.read(travelOperationNotifierProvider.notifier);
  ///
  /// // Add operation
  /// await operationNotifier.addOperation(operation);
  ///
  /// // Process operation
  /// await operationNotifier.processOperation(operationId);
  /// ```
  const TravelOperationProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'travelOperationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$travelOperationHash();

  @$internal
  @override
  TravelOperation create() => TravelOperation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$travelOperationHash() => r'4268f9401556dab2efec2727acb8dff54a3fd731';

/// Provider for managing travel operation state
///
/// Riverpod 3.0: Uses @riverpod annotation with Notifier pattern.
/// Keeps `AsyncValue<void>` state for tracking operation status.
///
/// Usage:
/// ```dart
/// final operationState = ref.watch(travelOperationNotifierProvider);
/// final operationNotifier = ref.read(travelOperationNotifierProvider.notifier);
///
/// // Add operation
/// await operationNotifier.addOperation(operation);
///
/// // Process operation
/// await operationNotifier.processOperation(operationId);
/// ```

abstract class _$TravelOperation extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
