// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for Supabase client

@ProviderFor(tagSupabaseClient)
final tagSupabaseClientProvider = TagSupabaseClientProvider._();

/// Provider for Supabase client

final class TagSupabaseClientProvider
    extends $FunctionalProvider<SupabaseClient, SupabaseClient, SupabaseClient>
    with $Provider<SupabaseClient> {
  /// Provider for Supabase client
  TagSupabaseClientProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tagSupabaseClientProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tagSupabaseClientHash();

  @$internal
  @override
  $ProviderElement<SupabaseClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SupabaseClient create(Ref ref) {
    return tagSupabaseClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseClient>(value),
    );
  }
}

String _$tagSupabaseClientHash() => r'a8e848c86657267e44b53742ac981fb1555669e5';

/// Provides the TagRemoteDataSource implementation

@ProviderFor(tagRemoteDataSource)
final tagRemoteDataSourceProvider = TagRemoteDataSourceProvider._();

/// Provides the TagRemoteDataSource implementation

final class TagRemoteDataSourceProvider extends $FunctionalProvider<
    TagRemoteDataSourceImpl,
    TagRemoteDataSourceImpl,
    TagRemoteDataSourceImpl> with $Provider<TagRemoteDataSourceImpl> {
  /// Provides the TagRemoteDataSource implementation
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
  $ProviderElement<TagRemoteDataSourceImpl> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TagRemoteDataSourceImpl create(Ref ref) {
    return tagRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TagRemoteDataSourceImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TagRemoteDataSourceImpl>(value),
    );
  }
}

String _$tagRemoteDataSourceHash() =>
    r'6dc52eaf47aabc3855be1d442638a5f712cfa14c';

/// Provides the TagRepository implementation

@ProviderFor(tagRepository)
final tagRepositoryProvider = TagRepositoryProvider._();

/// Provides the TagRepository implementation

final class TagRepositoryProvider
    extends $FunctionalProvider<TagRepository, TagRepository, TagRepository>
    with $Provider<TagRepository> {
  /// Provides the TagRepository implementation
  TagRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tagRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tagRepositoryHash();

  @$internal
  @override
  $ProviderElement<TagRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TagRepository create(Ref ref) {
    return tagRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TagRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TagRepository>(value),
    );
  }
}

String _$tagRepositoryHash() => r'01bfa3e939bb8a30a2ac2163464cef7068b4ce9a';

/// Notifier for managing tag list state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier

@ProviderFor(TagList)
final tagListProvider = TagListProvider._();

/// Notifier for managing tag list state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
final class TagListProvider extends $NotifierProvider<TagList, TagListState> {
  /// Notifier for managing tag list state
  ///
  /// Migration from StateNotifier to Notifier (Riverpod 3.0)
  /// See: https://riverpod.dev/docs/migration/from_state_notifier
  TagListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tagListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tagListHash();

  @$internal
  @override
  TagList create() => TagList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TagListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TagListState>(value),
    );
  }
}

String _$tagListHash() => r'213a8c42d0ac3943cf4df660712aed71e6422db9';

/// Notifier for managing tag list state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier

abstract class _$TagList extends $Notifier<TagListState> {
  TagListState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TagListState, TagListState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TagListState, TagListState>,
        TagListState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Notifier for managing tag creation/editing state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier

@ProviderFor(TagForm)
final tagFormProvider = TagFormProvider._();

/// Notifier for managing tag creation/editing state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
final class TagFormProvider extends $NotifierProvider<TagForm, TagFormState> {
  /// Notifier for managing tag creation/editing state
  ///
  /// Migration from StateNotifier to Notifier (Riverpod 3.0)
  /// See: https://riverpod.dev/docs/migration/from_state_notifier
  TagFormProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tagFormProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tagFormHash();

  @$internal
  @override
  TagForm create() => TagForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TagFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TagFormState>(value),
    );
  }
}

String _$tagFormHash() => r'a74ee8215f0dfd7d076cd62f7b59a219f22c414e';

/// Notifier for managing tag creation/editing state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier

abstract class _$TagForm extends $Notifier<TagFormState> {
  TagFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TagFormState, TagFormState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TagFormState, TagFormState>,
        TagFormState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Notifier for managing entry tags
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier

@ProviderFor(EntryTags)
final entryTagsProvider = EntryTagsProvider._();

/// Notifier for managing entry tags
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
final class EntryTagsProvider
    extends $NotifierProvider<EntryTags, EntryTagsState> {
  /// Notifier for managing entry tags
  ///
  /// Migration from StateNotifier to Notifier (Riverpod 3.0)
  /// See: https://riverpod.dev/docs/migration/from_state_notifier
  EntryTagsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'entryTagsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$entryTagsHash();

  @$internal
  @override
  EntryTags create() => EntryTags();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EntryTagsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EntryTagsState>(value),
    );
  }
}

String _$entryTagsHash() => r'dbb7c16f4eeda89430ca6199312f7c605dde8561';

/// Notifier for managing entry tags
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier

abstract class _$EntryTags extends $Notifier<EntryTagsState> {
  EntryTagsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<EntryTagsState, EntryTagsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<EntryTagsState, EntryTagsState>,
        EntryTagsState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
