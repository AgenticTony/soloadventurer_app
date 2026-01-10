// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_service_example.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the sync service
///
/// This should be added to your dependency injection setup

@ProviderFor(syncService)
final syncServiceProvider = SyncServiceProvider._();

/// Provider for the sync service
///
/// This should be added to your dependency injection setup

final class SyncServiceProvider
    extends $FunctionalProvider<SyncService, SyncService, SyncService>
    with $Provider<SyncService> {
  /// Provider for the sync service
  ///
  /// This should be added to your dependency injection setup
  SyncServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'syncServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$syncServiceHash();

  @$internal
  @override
  $ProviderElement<SyncService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncService create(Ref ref) {
    return syncService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncService>(value),
    );
  }
}

String _$syncServiceHash() => r'b52ef9c9456bf3fbf51e8e3e9d193c4f4b59dd96';

/// Provider for sync service state

@ProviderFor(SyncServiceNotifier)
final syncServiceProvider = SyncServiceNotifierProvider._();

/// Provider for sync service state
final class SyncServiceNotifierProvider
    extends $NotifierProvider<SyncServiceNotifier, SyncState> {
  /// Provider for sync service state
  SyncServiceNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'syncServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$syncServiceNotifierHash();

  @$internal
  @override
  SyncServiceNotifier create() => SyncServiceNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncState>(value),
    );
  }
}

String _$syncServiceNotifierHash() =>
    r'3ac3506ba00621514b50d3f2cc69d59f8f747b46';

/// Provider for sync service state

abstract class _$SyncServiceNotifier extends $Notifier<SyncState> {
  SyncState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SyncState, SyncState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SyncState, SyncState>, SyncState, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(journalLocalDataSource)
final journalLocalDataSourceProvider = JournalLocalDataSourceProvider._();

final class JournalLocalDataSourceProvider extends $FunctionalProvider<
    JournalLocalDataSource,
    JournalLocalDataSource,
    JournalLocalDataSource> with $Provider<JournalLocalDataSource> {
  JournalLocalDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'journalLocalDataSourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$journalLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<JournalLocalDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  JournalLocalDataSource create(Ref ref) {
    return journalLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JournalLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JournalLocalDataSource>(value),
    );
  }
}

String _$journalLocalDataSourceHash() =>
    r'e3ded1de39244a04e6b9e1e09d403dd99b3d0151';

@ProviderFor(journalRemoteDataSource)
final journalRemoteDataSourceProvider = JournalRemoteDataSourceProvider._();

final class JournalRemoteDataSourceProvider extends $FunctionalProvider<
    JournalRemoteDataSource,
    JournalRemoteDataSource,
    JournalRemoteDataSource> with $Provider<JournalRemoteDataSource> {
  JournalRemoteDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'journalRemoteDataSourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$journalRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<JournalRemoteDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  JournalRemoteDataSource create(Ref ref) {
    return journalRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JournalRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JournalRemoteDataSource>(value),
    );
  }
}

String _$journalRemoteDataSourceHash() =>
    r'7e2c5ad8aa69f63744cb7c32214143f0b5219d6a';

@ProviderFor(tripLocalDataSource)
final tripLocalDataSourceProvider = TripLocalDataSourceProvider._();

final class TripLocalDataSourceProvider extends $FunctionalProvider<
    TripLocalDataSource,
    TripLocalDataSource,
    TripLocalDataSource> with $Provider<TripLocalDataSource> {
  TripLocalDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tripLocalDataSourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tripLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<TripLocalDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TripLocalDataSource create(Ref ref) {
    return tripLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TripLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TripLocalDataSource>(value),
    );
  }
}

String _$tripLocalDataSourceHash() =>
    r'442ea7e0fbc3d84f6718dcb7df5ecb479640ef02';

@ProviderFor(tripRemoteDataSource)
final tripRemoteDataSourceProvider = TripRemoteDataSourceProvider._();

final class TripRemoteDataSourceProvider extends $FunctionalProvider<
    TripRemoteDataSource,
    TripRemoteDataSource,
    TripRemoteDataSource> with $Provider<TripRemoteDataSource> {
  TripRemoteDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tripRemoteDataSourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tripRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<TripRemoteDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TripRemoteDataSource create(Ref ref) {
    return tripRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TripRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TripRemoteDataSource>(value),
    );
  }
}

String _$tripRemoteDataSourceHash() =>
    r'6bdc040faae11f9dde79a496167d4044e48ba370';

@ProviderFor(tagLocalDataSource)
final tagLocalDataSourceProvider = TagLocalDataSourceProvider._();

final class TagLocalDataSourceProvider extends $FunctionalProvider<
    TagLocalDataSource,
    TagLocalDataSource,
    TagLocalDataSource> with $Provider<TagLocalDataSource> {
  TagLocalDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tagLocalDataSourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tagLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<TagLocalDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TagLocalDataSource create(Ref ref) {
    return tagLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TagLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TagLocalDataSource>(value),
    );
  }
}

String _$tagLocalDataSourceHash() =>
    r'b84095d44d2bbe6ba3c0fbc2d99ea51fccab2c31';

@ProviderFor(tagRemoteDataSource)
final tagRemoteDataSourceProvider = TagRemoteDataSourceProvider._();

final class TagRemoteDataSourceProvider extends $FunctionalProvider<
    TagRemoteDataSource,
    TagRemoteDataSource,
    TagRemoteDataSource> with $Provider<TagRemoteDataSource> {
  TagRemoteDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tagRemoteDataSourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tagRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<TagRemoteDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TagRemoteDataSource create(Ref ref) {
    return tagRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TagRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TagRemoteDataSource>(value),
    );
  }
}

String _$tagRemoteDataSourceHash() =>
    r'a3f706eced1944b8352b00521965b2bf529eebd2';
