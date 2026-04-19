// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meetup_checkin_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the meetup check-in remote data source backed by Supabase

@ProviderFor(meetupCheckinRemoteDataSource)
const meetupCheckinRemoteDataSourceProvider =
    MeetupCheckinRemoteDataSourceProvider._();

/// Provides the meetup check-in remote data source backed by Supabase

final class MeetupCheckinRemoteDataSourceProvider extends $FunctionalProvider<
        MeetupCheckinRemoteDataSource,
        MeetupCheckinRemoteDataSource,
        MeetupCheckinRemoteDataSource>
    with $Provider<MeetupCheckinRemoteDataSource> {
  /// Provides the meetup check-in remote data source backed by Supabase
  const MeetupCheckinRemoteDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'meetupCheckinRemoteDataSourceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$meetupCheckinRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<MeetupCheckinRemoteDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MeetupCheckinRemoteDataSource create(Ref ref) {
    return meetupCheckinRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MeetupCheckinRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<MeetupCheckinRemoteDataSource>(value),
    );
  }
}

String _$meetupCheckinRemoteDataSourceHash() =>
    r'dce53c71a7518e98ad9f4fad407905e714b5f9dc';

/// Provides the meetup check-in repository implementation

@ProviderFor(meetupCheckinRepository)
const meetupCheckinRepositoryProvider = MeetupCheckinRepositoryProvider._();

/// Provides the meetup check-in repository implementation

final class MeetupCheckinRepositoryProvider extends $FunctionalProvider<
    MeetupCheckinRepository,
    MeetupCheckinRepository,
    MeetupCheckinRepository> with $Provider<MeetupCheckinRepository> {
  /// Provides the meetup check-in repository implementation
  const MeetupCheckinRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'meetupCheckinRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$meetupCheckinRepositoryHash();

  @$internal
  @override
  $ProviderElement<MeetupCheckinRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MeetupCheckinRepository create(Ref ref) {
    return meetupCheckinRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MeetupCheckinRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MeetupCheckinRepository>(value),
    );
  }
}

String _$meetupCheckinRepositoryHash() =>
    r'09aa31b594f56e06c525f5d9e136fdf007df287e';

/// Provider for CreateMeetupCheckinUseCase

@ProviderFor(createMeetupCheckinUseCase)
const createMeetupCheckinUseCaseProvider =
    CreateMeetupCheckinUseCaseProvider._();

/// Provider for CreateMeetupCheckinUseCase

final class CreateMeetupCheckinUseCaseProvider extends $FunctionalProvider<
    CreateMeetupCheckinUseCase,
    CreateMeetupCheckinUseCase,
    CreateMeetupCheckinUseCase> with $Provider<CreateMeetupCheckinUseCase> {
  /// Provider for CreateMeetupCheckinUseCase
  const CreateMeetupCheckinUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'createMeetupCheckinUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$createMeetupCheckinUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateMeetupCheckinUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateMeetupCheckinUseCase create(Ref ref) {
    return createMeetupCheckinUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateMeetupCheckinUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateMeetupCheckinUseCase>(value),
    );
  }
}

String _$createMeetupCheckinUseCaseHash() =>
    r'e4fffb76cfb65b14659ed5e11e9ec9e51fbf59d2';

/// Provider for CheckInSafeUseCase

@ProviderFor(checkInSafeUseCase)
const checkInSafeUseCaseProvider = CheckInSafeUseCaseProvider._();

/// Provider for CheckInSafeUseCase

final class CheckInSafeUseCaseProvider extends $FunctionalProvider<
    CheckInSafeUseCase,
    CheckInSafeUseCase,
    CheckInSafeUseCase> with $Provider<CheckInSafeUseCase> {
  /// Provider for CheckInSafeUseCase
  const CheckInSafeUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'checkInSafeUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$checkInSafeUseCaseHash();

  @$internal
  @override
  $ProviderElement<CheckInSafeUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CheckInSafeUseCase create(Ref ref) {
    return checkInSafeUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckInSafeUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckInSafeUseCase>(value),
    );
  }
}

String _$checkInSafeUseCaseHash() =>
    r'e44ac308ea3460cb33133fd66007e51e35fc05a3';

/// Provider for TriggerSOSUseCase

@ProviderFor(triggerSOSUseCase)
const triggerSOSUseCaseProvider = TriggerSOSUseCaseProvider._();

/// Provider for TriggerSOSUseCase

final class TriggerSOSUseCaseProvider extends $FunctionalProvider<
    TriggerSOSUseCase,
    TriggerSOSUseCase,
    TriggerSOSUseCase> with $Provider<TriggerSOSUseCase> {
  /// Provider for TriggerSOSUseCase
  const TriggerSOSUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'triggerSOSUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$triggerSOSUseCaseHash();

  @$internal
  @override
  $ProviderElement<TriggerSOSUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TriggerSOSUseCase create(Ref ref) {
    return triggerSOSUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TriggerSOSUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TriggerSOSUseCase>(value),
    );
  }
}

String _$triggerSOSUseCaseHash() => r'5720af3e717ee839a8104251db1454c9c7683abc';

/// Provider for CancelMeetupCheckinUseCase

@ProviderFor(cancelMeetupCheckinUseCase)
const cancelMeetupCheckinUseCaseProvider =
    CancelMeetupCheckinUseCaseProvider._();

/// Provider for CancelMeetupCheckinUseCase

final class CancelMeetupCheckinUseCaseProvider extends $FunctionalProvider<
    CancelMeetupCheckinUseCase,
    CancelMeetupCheckinUseCase,
    CancelMeetupCheckinUseCase> with $Provider<CancelMeetupCheckinUseCase> {
  /// Provider for CancelMeetupCheckinUseCase
  const CancelMeetupCheckinUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cancelMeetupCheckinUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cancelMeetupCheckinUseCaseHash();

  @$internal
  @override
  $ProviderElement<CancelMeetupCheckinUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CancelMeetupCheckinUseCase create(Ref ref) {
    return cancelMeetupCheckinUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CancelMeetupCheckinUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CancelMeetupCheckinUseCase>(value),
    );
  }
}

String _$cancelMeetupCheckinUseCaseHash() =>
    r'4f85b243077e7880649779b9727e950e47b85f7e';

/// Provider for GetActiveCheckinsUseCase

@ProviderFor(getActiveCheckinsUseCase)
const getActiveCheckinsUseCaseProvider = GetActiveCheckinsUseCaseProvider._();

/// Provider for GetActiveCheckinsUseCase

final class GetActiveCheckinsUseCaseProvider extends $FunctionalProvider<
    GetActiveCheckinsUseCase,
    GetActiveCheckinsUseCase,
    GetActiveCheckinsUseCase> with $Provider<GetActiveCheckinsUseCase> {
  /// Provider for GetActiveCheckinsUseCase
  const GetActiveCheckinsUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getActiveCheckinsUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getActiveCheckinsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetActiveCheckinsUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetActiveCheckinsUseCase create(Ref ref) {
    return getActiveCheckinsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetActiveCheckinsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetActiveCheckinsUseCase>(value),
    );
  }
}

String _$getActiveCheckinsUseCaseHash() =>
    r'17ec7483859a8f38ae1a810dead464bfe2f9894a';

/// Manages the list of active meetup check-ins with real-time updates

@ProviderFor(ActiveCheckinsNotifier)
const activeCheckinsProvider = ActiveCheckinsNotifierProvider._();

/// Manages the list of active meetup check-ins with real-time updates
final class ActiveCheckinsNotifierProvider extends $AsyncNotifierProvider<
    ActiveCheckinsNotifier, List<MeetupCheckin>> {
  /// Manages the list of active meetup check-ins with real-time updates
  const ActiveCheckinsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeCheckinsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeCheckinsNotifierHash();

  @$internal
  @override
  ActiveCheckinsNotifier create() => ActiveCheckinsNotifier();
}

String _$activeCheckinsNotifierHash() =>
    r'918ab1222210dd97674be36a2012d94750bbda3f';

/// Manages the list of active meetup check-ins with real-time updates

abstract class _$ActiveCheckinsNotifier
    extends $AsyncNotifier<List<MeetupCheckin>> {
  FutureOr<List<MeetupCheckin>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<MeetupCheckin>>, List<MeetupCheckin>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<MeetupCheckin>>, List<MeetupCheckin>>,
        AsyncValue<List<MeetupCheckin>>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
