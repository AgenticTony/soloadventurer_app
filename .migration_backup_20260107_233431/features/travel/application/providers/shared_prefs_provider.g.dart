// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_prefs_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for SharedPreferences instance

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// Provider for SharedPreferences instance

final class SharedPreferencesProvider extends $FunctionalProvider<
    SharedPreferences,
    SharedPreferences,
    SharedPreferences> with $Provider<SharedPreferences> {
  /// Provider for SharedPreferences instance
  SharedPreferencesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sharedPreferencesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return sharedPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$sharedPreferencesHash() => r'7c7c124b5fb6071d7607773ddcdb122401f3eb48';

/// Override this provider during app initialization with:
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// ProviderContainer(
///   overrides: [
///     sharedPreferencesProvider.overrideWithValue(prefs),
///   ],
///   child: MyApp(),
/// );
/// ```
/// Provider for travel operation repository

@ProviderFor(travelOperationRepository)
final travelOperationRepositoryProvider = TravelOperationRepositoryProvider._();

/// Override this provider during app initialization with:
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// ProviderContainer(
///   overrides: [
///     sharedPreferencesProvider.overrideWithValue(prefs),
///   ],
///   child: MyApp(),
/// );
/// ```
/// Provider for travel operation repository

final class TravelOperationRepositoryProvider extends $FunctionalProvider<
    TravelOperationRepository,
    TravelOperationRepository,
    TravelOperationRepository> with $Provider<TravelOperationRepository> {
  /// Override this provider during app initialization with:
  /// ```dart
  /// final prefs = await SharedPreferences.getInstance();
  /// ProviderContainer(
  ///   overrides: [
  ///     sharedPreferencesProvider.overrideWithValue(prefs),
  ///   ],
  ///   child: MyApp(),
  /// );
  /// ```
  /// Provider for travel operation repository
  TravelOperationRepositoryProvider._()
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
    r'60bf54651e9b6aea65742b1beaed446dc08f5a55';

/// Provider for pending operations

@ProviderFor(pendingOperations)
final pendingOperationsProvider = PendingOperationsProvider._();

/// Provider for pending operations

final class PendingOperationsProvider extends $FunctionalProvider<
        AsyncValue<List<BaseTravelOperation>>,
        List<BaseTravelOperation>,
        FutureOr<List<BaseTravelOperation>>>
    with
        $FutureModifier<List<BaseTravelOperation>>,
        $FutureProvider<List<BaseTravelOperation>> {
  /// Provider for pending operations
  PendingOperationsProvider._()
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

/// Notifier for managing travel operations

@ProviderFor(TravelOperationNotifier)
final travelOperationProvider = TravelOperationNotifierProvider._();

/// Notifier for managing travel operations
final class TravelOperationNotifierProvider
    extends $NotifierProvider<TravelOperationNotifier, AsyncValue<void>> {
  /// Notifier for managing travel operations
  TravelOperationNotifierProvider._()
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
  String debugGetCreateSourceHash() => _$travelOperationNotifierHash();

  @$internal
  @override
  TravelOperationNotifier create() => TravelOperationNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$travelOperationNotifierHash() =>
    r'9132c38f04cd5bbbd76cf32a78ffb0dbd033d1da';

/// Notifier for managing travel operations

abstract class _$TravelOperationNotifier extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
