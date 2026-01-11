// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_domain_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the AppDatabase

@ProviderFor(appDatabase)
const appDatabaseProvider = AppDatabaseProvider._();

/// Provider for the AppDatabase

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// Provider for the AppDatabase
  const AppDatabaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appDatabaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'ce844862e38d714cf6ce7ffb7730dcbaca6dd188';

/// Provider for the ItineraryDao

@ProviderFor(itineraryDao)
const itineraryDaoProvider = ItineraryDaoProvider._();

/// Provider for the ItineraryDao

final class ItineraryDaoProvider
    extends $FunctionalProvider<ItineraryDao, ItineraryDao, ItineraryDao>
    with $Provider<ItineraryDao> {
  /// Provider for the ItineraryDao
  const ItineraryDaoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'itineraryDaoProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$itineraryDaoHash();

  @$internal
  @override
  $ProviderElement<ItineraryDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ItineraryDao create(Ref ref) {
    return itineraryDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ItineraryDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ItineraryDao>(value),
    );
  }
}

String _$itineraryDaoHash() => r'496946c4379d739d1c1ef867c19f487220e7c8fd';

/// Provider for the ItineraryRepository

@ProviderFor(itineraryRepository)
const itineraryRepositoryProvider = ItineraryRepositoryProvider._();

/// Provider for the ItineraryRepository

final class ItineraryRepositoryProvider extends $FunctionalProvider<
    ItineraryRepository,
    ItineraryRepository,
    ItineraryRepository> with $Provider<ItineraryRepository> {
  /// Provider for the ItineraryRepository
  const ItineraryRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'itineraryRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$itineraryRepositoryHash();

  @$internal
  @override
  $ProviderElement<ItineraryRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ItineraryRepository create(Ref ref) {
    return itineraryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ItineraryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ItineraryRepository>(value),
    );
  }
}

String _$itineraryRepositoryHash() =>
    r'914c6f87fa7fd9f27c37c8f328ece862165b8eef';

/// Provider for GetItinerary use case

@ProviderFor(getItinerary)
const getItineraryProvider = GetItineraryProvider._();

/// Provider for GetItinerary use case

final class GetItineraryProvider
    extends $FunctionalProvider<GetItinerary, GetItinerary, GetItinerary>
    with $Provider<GetItinerary> {
  /// Provider for GetItinerary use case
  const GetItineraryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getItineraryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getItineraryHash();

  @$internal
  @override
  $ProviderElement<GetItinerary> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetItinerary create(Ref ref) {
    return getItinerary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetItinerary value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetItinerary>(value),
    );
  }
}

String _$getItineraryHash() => r'dba056e5d8ddea88dedcb4dc4052ca2c29a02d6a';

/// Provider for GetItineraries use case

@ProviderFor(getItineraries)
const getItinerariesProvider = GetItinerariesProvider._();

/// Provider for GetItineraries use case

final class GetItinerariesProvider
    extends $FunctionalProvider<GetItineraries, GetItineraries, GetItineraries>
    with $Provider<GetItineraries> {
  /// Provider for GetItineraries use case
  const GetItinerariesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getItinerariesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getItinerariesHash();

  @$internal
  @override
  $ProviderElement<GetItineraries> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetItineraries create(Ref ref) {
    return getItineraries(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetItineraries value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetItineraries>(value),
    );
  }
}

String _$getItinerariesHash() => r'8ebc8f454ba27a4d31620c64d558e2a5ba72ca3b';

/// Provider for CreateItinerary use case

@ProviderFor(createItinerary)
const createItineraryProvider = CreateItineraryProvider._();

/// Provider for CreateItinerary use case

final class CreateItineraryProvider extends $FunctionalProvider<CreateItinerary,
    CreateItinerary, CreateItinerary> with $Provider<CreateItinerary> {
  /// Provider for CreateItinerary use case
  const CreateItineraryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'createItineraryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$createItineraryHash();

  @$internal
  @override
  $ProviderElement<CreateItinerary> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateItinerary create(Ref ref) {
    return createItinerary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateItinerary value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateItinerary>(value),
    );
  }
}

String _$createItineraryHash() => r'7cad32c131ff97045128821e41cc7486c72c206c';

/// Provider for AddItineraryItem use case

@ProviderFor(addItineraryItem)
const addItineraryItemProvider = AddItineraryItemProvider._();

/// Provider for AddItineraryItem use case

final class AddItineraryItemProvider extends $FunctionalProvider<
    AddItineraryItem,
    AddItineraryItem,
    AddItineraryItem> with $Provider<AddItineraryItem> {
  /// Provider for AddItineraryItem use case
  const AddItineraryItemProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'addItineraryItemProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$addItineraryItemHash();

  @$internal
  @override
  $ProviderElement<AddItineraryItem> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AddItineraryItem create(Ref ref) {
    return addItineraryItem(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddItineraryItem value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddItineraryItem>(value),
    );
  }
}

String _$addItineraryItemHash() => r'9349e663256d5b1eac20e076389a3f4b6d8f3642';

/// Provider for UpdateItineraryItem use case

@ProviderFor(updateItineraryItem)
const updateItineraryItemProvider = UpdateItineraryItemProvider._();

/// Provider for UpdateItineraryItem use case

final class UpdateItineraryItemProvider extends $FunctionalProvider<
    UpdateItineraryItem,
    UpdateItineraryItem,
    UpdateItineraryItem> with $Provider<UpdateItineraryItem> {
  /// Provider for UpdateItineraryItem use case
  const UpdateItineraryItemProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'updateItineraryItemProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$updateItineraryItemHash();

  @$internal
  @override
  $ProviderElement<UpdateItineraryItem> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateItineraryItem create(Ref ref) {
    return updateItineraryItem(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateItineraryItem value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateItineraryItem>(value),
    );
  }
}

String _$updateItineraryItemHash() =>
    r'94e9ef875a8655098e2368c7b3ef8cfcc191312d';

/// Provider for RemoveItineraryItem use case

@ProviderFor(removeItineraryItem)
const removeItineraryItemProvider = RemoveItineraryItemProvider._();

/// Provider for RemoveItineraryItem use case

final class RemoveItineraryItemProvider extends $FunctionalProvider<
    RemoveItineraryItem,
    RemoveItineraryItem,
    RemoveItineraryItem> with $Provider<RemoveItineraryItem> {
  /// Provider for RemoveItineraryItem use case
  const RemoveItineraryItemProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'removeItineraryItemProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$removeItineraryItemHash();

  @$internal
  @override
  $ProviderElement<RemoveItineraryItem> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RemoveItineraryItem create(Ref ref) {
    return removeItineraryItem(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoveItineraryItem value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoveItineraryItem>(value),
    );
  }
}

String _$removeItineraryItemHash() =>
    r'9d1f5e5afbb4faffa1ffc08b1048823a46c34232';

/// Provider for ReorderItineraryItems use case

@ProviderFor(reorderItineraryItems)
const reorderItineraryItemsProvider = ReorderItineraryItemsProvider._();

/// Provider for ReorderItineraryItems use case

final class ReorderItineraryItemsProvider extends $FunctionalProvider<
    ReorderItineraryItems,
    ReorderItineraryItems,
    ReorderItineraryItems> with $Provider<ReorderItineraryItems> {
  /// Provider for ReorderItineraryItems use case
  const ReorderItineraryItemsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'reorderItineraryItemsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$reorderItineraryItemsHash();

  @$internal
  @override
  $ProviderElement<ReorderItineraryItems> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReorderItineraryItems create(Ref ref) {
    return reorderItineraryItems(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReorderItineraryItems value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReorderItineraryItems>(value),
    );
  }
}

String _$reorderItineraryItemsHash() =>
    r'40dd56eb94da4165d9f4a5f60b5ce5a9c51c6da2';

/// Provider for ToggleItemCompletion use case

@ProviderFor(toggleItemCompletion)
const toggleItemCompletionProvider = ToggleItemCompletionProvider._();

/// Provider for ToggleItemCompletion use case

final class ToggleItemCompletionProvider extends $FunctionalProvider<
    ToggleItemCompletion,
    ToggleItemCompletion,
    ToggleItemCompletion> with $Provider<ToggleItemCompletion> {
  /// Provider for ToggleItemCompletion use case
  const ToggleItemCompletionProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'toggleItemCompletionProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$toggleItemCompletionHash();

  @$internal
  @override
  $ProviderElement<ToggleItemCompletion> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ToggleItemCompletion create(Ref ref) {
    return toggleItemCompletion(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ToggleItemCompletion value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ToggleItemCompletion>(value),
    );
  }
}

String _$toggleItemCompletionHash() =>
    r'cacecf340e0ba89dbc505d8ab55bd65e14b1b8bc';

/// Provider for GetItemsForDay use case

@ProviderFor(getItemsForDay)
const getItemsForDayProvider = GetItemsForDayProvider._();

/// Provider for GetItemsForDay use case

final class GetItemsForDayProvider
    extends $FunctionalProvider<GetItemsForDay, GetItemsForDay, GetItemsForDay>
    with $Provider<GetItemsForDay> {
  /// Provider for GetItemsForDay use case
  const GetItemsForDayProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getItemsForDayProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getItemsForDayHash();

  @$internal
  @override
  $ProviderElement<GetItemsForDay> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetItemsForDay create(Ref ref) {
    return getItemsForDay(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetItemsForDay value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetItemsForDay>(value),
    );
  }
}

String _$getItemsForDayHash() => r'625179f354e0304a1f33b2c853d039e247d505cc';
