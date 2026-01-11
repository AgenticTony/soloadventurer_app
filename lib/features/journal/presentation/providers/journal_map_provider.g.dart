// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_map_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the Supabase client instance

@ProviderFor(supabaseClient)
const supabaseClientProvider = SupabaseClientProvider._();

/// Provides the Supabase client instance

final class SupabaseClientProvider
    extends $FunctionalProvider<SupabaseClient, SupabaseClient, SupabaseClient>
    with $Provider<SupabaseClient> {
  /// Provides the Supabase client instance
  const SupabaseClientProvider._()
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

/// Provides the JournalRemoteDataSource implementation

@ProviderFor(journalRemoteDataSource)
const journalRemoteDataSourceProvider = JournalRemoteDataSourceProvider._();

/// Provides the JournalRemoteDataSource implementation

final class JournalRemoteDataSourceProvider extends $FunctionalProvider<
    JournalRemoteDataSourceImpl,
    JournalRemoteDataSourceImpl,
    JournalRemoteDataSourceImpl> with $Provider<JournalRemoteDataSourceImpl> {
  /// Provides the JournalRemoteDataSource implementation
  const JournalRemoteDataSourceProvider._()
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
  $ProviderElement<JournalRemoteDataSourceImpl> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  JournalRemoteDataSourceImpl create(Ref ref) {
    return journalRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JournalRemoteDataSourceImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JournalRemoteDataSourceImpl>(value),
    );
  }
}

String _$journalRemoteDataSourceHash() =>
    r'a583da8ccf8291df4517441458104a9fbe61bac6';

/// Provides the JournalRepository implementation for map operations

@ProviderFor(journalMapRepository)
const journalMapRepositoryProvider = JournalMapRepositoryProvider._();

/// Provides the JournalRepository implementation for map operations

final class JournalMapRepositoryProvider extends $FunctionalProvider<
    JournalRepository,
    JournalRepository,
    JournalRepository> with $Provider<JournalRepository> {
  /// Provides the JournalRepository implementation for map operations
  const JournalMapRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'journalMapRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$journalMapRepositoryHash();

  @$internal
  @override
  $ProviderElement<JournalRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  JournalRepository create(Ref ref) {
    return journalMapRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JournalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JournalRepository>(value),
    );
  }
}

String _$journalMapRepositoryHash() =>
    r'2036d9f85f63b7034814155cdc45be05d1468fdf';

/// Notifier for managing journal map state
/// MIGRATION: StateNotifier → Notifier pattern
/// - Constructor logic moved to build() method
/// - Dependencies accessed via ref.watch() in methods
/// - Automatic provider generation via @riverpod annotation

@ProviderFor(JournalMap)
const journalMapProvider = JournalMapProvider._();

/// Notifier for managing journal map state
/// MIGRATION: StateNotifier → Notifier pattern
/// - Constructor logic moved to build() method
/// - Dependencies accessed via ref.watch() in methods
/// - Automatic provider generation via @riverpod annotation
final class JournalMapProvider
    extends $NotifierProvider<JournalMap, JournalMapState> {
  /// Notifier for managing journal map state
  /// MIGRATION: StateNotifier → Notifier pattern
  /// - Constructor logic moved to build() method
  /// - Dependencies accessed via ref.watch() in methods
  /// - Automatic provider generation via @riverpod annotation
  const JournalMapProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'journalMapProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$journalMapHash();

  @$internal
  @override
  JournalMap create() => JournalMap();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JournalMapState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JournalMapState>(value),
    );
  }
}

String _$journalMapHash() => r'88540c6e5850e248f7ad1afcb7e2ada72578de52';

/// Notifier for managing journal map state
/// MIGRATION: StateNotifier → Notifier pattern
/// - Constructor logic moved to build() method
/// - Dependencies accessed via ref.watch() in methods
/// - Automatic provider generation via @riverpod annotation

abstract class _$JournalMap extends $Notifier<JournalMapState> {
  JournalMapState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<JournalMapState, JournalMapState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<JournalMapState, JournalMapState>,
        JournalMapState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

/// Provider for journal map state scoped to a trip
/// MIGRATION: StateNotifierProvider.family → Notifier with family parameter
/// Usage: ref.watch(journalTripMapProvider(tripId))

@ProviderFor(JournalTripMap)
const journalTripMapProvider = JournalTripMapFamily._();

/// Provider for journal map state scoped to a trip
/// MIGRATION: StateNotifierProvider.family → Notifier with family parameter
/// Usage: ref.watch(journalTripMapProvider(tripId))
final class JournalTripMapProvider
    extends $NotifierProvider<JournalTripMap, JournalMapState> {
  /// Provider for journal map state scoped to a trip
  /// MIGRATION: StateNotifierProvider.family → Notifier with family parameter
  /// Usage: ref.watch(journalTripMapProvider(tripId))
  const JournalTripMapProvider._(
      {required JournalTripMapFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'journalTripMapProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$journalTripMapHash();

  @override
  String toString() {
    return r'journalTripMapProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  JournalTripMap create() => JournalTripMap();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JournalMapState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JournalMapState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is JournalTripMapProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$journalTripMapHash() => r'b3d016153bc792569f9d4c0f34b7a2aedcaf468a';

/// Provider for journal map state scoped to a trip
/// MIGRATION: StateNotifierProvider.family → Notifier with family parameter
/// Usage: ref.watch(journalTripMapProvider(tripId))

final class JournalTripMapFamily extends $Family
    with
        $ClassFamilyOverride<JournalTripMap, JournalMapState, JournalMapState,
            JournalMapState, String> {
  const JournalTripMapFamily._()
      : super(
          retry: null,
          name: r'journalTripMapProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for journal map state scoped to a trip
  /// MIGRATION: StateNotifierProvider.family → Notifier with family parameter
  /// Usage: ref.watch(journalTripMapProvider(tripId))

  JournalTripMapProvider call(
    String tripId,
  ) =>
      JournalTripMapProvider._(argument: tripId, from: this);

  @override
  String toString() => r'journalTripMapProvider';
}

/// Provider for journal map state scoped to a trip
/// MIGRATION: StateNotifierProvider.family → Notifier with family parameter
/// Usage: ref.watch(journalTripMapProvider(tripId))

abstract class _$JournalTripMap extends $Notifier<JournalMapState> {
  late final _$args = ref.$arg as String;
  String get tripId => _$args;

  JournalMapState build(
    String tripId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<JournalMapState, JournalMapState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<JournalMapState, JournalMapState>,
        JournalMapState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
