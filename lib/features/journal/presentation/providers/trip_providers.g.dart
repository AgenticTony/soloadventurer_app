// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the Supabase client instance

@ProviderFor(supabaseClient)
final supabaseClientProvider = SupabaseClientProvider._();

/// Provides the Supabase client instance

final class SupabaseClientProvider
    extends $FunctionalProvider<SupabaseClient, SupabaseClient, SupabaseClient>
    with $Provider<SupabaseClient> {
  /// Provides the Supabase client instance
  SupabaseClientProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'supabaseClientProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$supabaseClientHash();

  @$internal
  @override
  $ProviderElement<SupabaseClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SupabaseClient create(Ref ref) {
    return supabaseClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseClient>(value),
    );
  }
}

String _$supabaseClientHash() => r'834a58d6ae4b94e36f4e04a10d8a7684b929310e';

/// Provides the TripRemoteDataSource implementation

@ProviderFor(tripRemoteDataSource)
final tripRemoteDataSourceProvider = TripRemoteDataSourceProvider._();

/// Provides the TripRemoteDataSource implementation

final class TripRemoteDataSourceProvider extends $FunctionalProvider<
    TripRemoteDataSourceImpl,
    TripRemoteDataSourceImpl,
    TripRemoteDataSourceImpl> with $Provider<TripRemoteDataSourceImpl> {
  /// Provides the TripRemoteDataSource implementation
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
  $ProviderElement<TripRemoteDataSourceImpl> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TripRemoteDataSourceImpl create(Ref ref) {
    return tripRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TripRemoteDataSourceImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TripRemoteDataSourceImpl>(value),
    );
  }
}

String _$tripRemoteDataSourceHash() =>
    r'f6127fbe5dedb6e19109804c8da54f0eb9a6109a';

/// Provides the TripRepository implementation

@ProviderFor(tripRepository)
final tripRepositoryProvider = TripRepositoryProvider._();

/// Provides the TripRepository implementation

final class TripRepositoryProvider
    extends $FunctionalProvider<TripRepository, TripRepository, TripRepository>
    with $Provider<TripRepository> {
  /// Provides the TripRepository implementation
  TripRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tripRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tripRepositoryHash();

  @$internal
  @override
  $ProviderElement<TripRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TripRepository create(Ref ref) {
    return tripRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TripRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TripRepository>(value),
    );
  }
}

String _$tripRepositoryHash() => r'54e94780ba1de59dba8b2820832b0cad9a80fd2b';

/// Notifier for managing trip list state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier

@ProviderFor(TripList)
final tripListProvider = TripListProvider._();

/// Notifier for managing trip list state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
final class TripListProvider
    extends $NotifierProvider<TripList, TripListState> {
  /// Notifier for managing trip list state
  ///
  /// Migration from StateNotifier to Notifier (Riverpod 3.0)
  /// See: https://riverpod.dev/docs/migration/from_state_notifier
  TripListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tripListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tripListHash();

  @$internal
  @override
  TripList create() => TripList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TripListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TripListState>(value),
    );
  }
}

String _$tripListHash() => r'69f679be9ba358c86f1461423cc33e9b853b06ec';

/// Notifier for managing trip list state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier

abstract class _$TripList extends $Notifier<TripListState> {
  TripListState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TripListState, TripListState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TripListState, TripListState>,
        TripListState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Notifier for managing trip form state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier

@ProviderFor(TripForm)
final tripFormProvider = TripFormProvider._();

/// Notifier for managing trip form state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
final class TripFormProvider
    extends $NotifierProvider<TripForm, TripFormState> {
  /// Notifier for managing trip form state
  ///
  /// Migration from StateNotifier to Notifier (Riverpod 3.0)
  /// See: https://riverpod.dev/docs/migration/from_state_notifier
  TripFormProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tripFormProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tripFormHash();

  @$internal
  @override
  TripForm create() => TripForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TripFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TripFormState>(value),
    );
  }
}

String _$tripFormHash() => r'391fc76a05fb94d49c1fa38e4d6aefd1378431c9';

/// Notifier for managing trip form state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier

abstract class _$TripForm extends $Notifier<TripFormState> {
  TripFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TripFormState, TripFormState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TripFormState, TripFormState>,
        TripFormState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Notifier for managing trip detail state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
///
/// Family provider pattern: pass tripId as parameter
/// Usage: ref.watch(tripDetailProvider(tripId))

@ProviderFor(TripDetail)
final tripDetailProvider = TripDetailFamily._();

/// Notifier for managing trip detail state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
///
/// Family provider pattern: pass tripId as parameter
/// Usage: ref.watch(tripDetailProvider(tripId))
final class TripDetailProvider
    extends $NotifierProvider<TripDetail, TripDetailState> {
  /// Notifier for managing trip detail state
  ///
  /// Migration from StateNotifier to Notifier (Riverpod 3.0)
  /// See: https://riverpod.dev/docs/migration/from_state_notifier
  ///
  /// Family provider pattern: pass tripId as parameter
  /// Usage: ref.watch(tripDetailProvider(tripId))
  TripDetailProvider._(
      {required TripDetailFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'tripDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tripDetailHash();

  @override
  String toString() {
    return r'tripDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TripDetail create() => TripDetail();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TripDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TripDetailState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TripDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripDetailHash() => r'87daaeac335b49501206d61fe4671f5df9bd39ef';

/// Notifier for managing trip detail state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
///
/// Family provider pattern: pass tripId as parameter
/// Usage: ref.watch(tripDetailProvider(tripId))

final class TripDetailFamily extends $Family
    with
        $ClassFamilyOverride<TripDetail, TripDetailState, TripDetailState,
            TripDetailState, String> {
  TripDetailFamily._()
      : super(
          retry: null,
          name: r'tripDetailProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Notifier for managing trip detail state
  ///
  /// Migration from StateNotifier to Notifier (Riverpod 3.0)
  /// See: https://riverpod.dev/docs/migration/from_state_notifier
  ///
  /// Family provider pattern: pass tripId as parameter
  /// Usage: ref.watch(tripDetailProvider(tripId))

  TripDetailProvider call(
    String tripIdArg,
  ) =>
      TripDetailProvider._(argument: tripIdArg, from: this);

  @override
  String toString() => r'tripDetailProvider';
}

/// Notifier for managing trip detail state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
///
/// Family provider pattern: pass tripId as parameter
/// Usage: ref.watch(tripDetailProvider(tripId))

abstract class _$TripDetail extends $Notifier<TripDetailState> {
  late final _$args = ref.$arg as String;
  String get tripIdArg => _$args;

  TripDetailState build(
    String tripIdArg,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TripDetailState, TripDetailState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TripDetailState, TripDetailState>,
        TripDetailState,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
