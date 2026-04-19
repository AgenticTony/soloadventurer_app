// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for available activities

@ProviderFor(activities)
const activitiesProvider = ActivitiesProvider._();

/// Provider for available activities

final class ActivitiesProvider extends $FunctionalProvider<
        AsyncValue<List<Activity>>, List<Activity>, FutureOr<List<Activity>>>
    with $FutureModifier<List<Activity>>, $FutureProvider<List<Activity>> {
  /// Provider for available activities
  const ActivitiesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activitiesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activitiesHash();

  @$internal
  @override
  $FutureProviderElement<List<Activity>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Activity>> create(Ref ref) {
    return activities(ref);
  }
}

String _$activitiesHash() => r'029829c9231d9737afcefa733a0312f596e17d3a';

/// Provider for user's selected activities

@ProviderFor(userActivities)
const userActivitiesProvider = UserActivitiesProvider._();

/// Provider for user's selected activities

final class UserActivitiesProvider extends $FunctionalProvider<
        AsyncValue<List<Activity>>, List<Activity>, FutureOr<List<Activity>>>
    with $FutureModifier<List<Activity>>, $FutureProvider<List<Activity>> {
  /// Provider for user's selected activities
  const UserActivitiesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userActivitiesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userActivitiesHash();

  @$internal
  @override
  $FutureProviderElement<List<Activity>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Activity>> create(Ref ref) {
    return userActivities(ref);
  }
}

String _$userActivitiesHash() => r'4c21052811272f4a298eead38e6b8bf40270f4bf';

/// Notifier for managing user activities

@ProviderFor(UserActivityNotifier)
const userActivityProvider = UserActivityNotifierProvider._();

/// Notifier for managing user activities
final class UserActivityNotifierProvider
    extends $AsyncNotifierProvider<UserActivityNotifier, void> {
  /// Notifier for managing user activities
  const UserActivityNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userActivityProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userActivityNotifierHash();

  @$internal
  @override
  UserActivityNotifier create() => UserActivityNotifier();
}

String _$userActivityNotifierHash() =>
    r'886f8ecdd5f19299fca0141a3a099d508e63940e';

/// Notifier for managing user activities

abstract class _$UserActivityNotifier extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, void>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleValue(ref, null);
  }
}
