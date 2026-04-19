// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing profile state and user interactions.
///
/// Riverpod 3.0 AsyncNotifier Migration:
/// - Converted from synchronous Notifier to AsyncNotifier
/// - build() is async and loads initial profile data
/// - Loading/error state handled by AsyncValue wrapper
/// - AsyncValue.guard() replaces manual try/catch + isLoading/error
/// - Methods set state = AsyncLoading() then AsyncValue.guard()

@ProviderFor(Profile)
const profileProvider = ProfileProvider._();

/// Notifier for managing profile state and user interactions.
///
/// Riverpod 3.0 AsyncNotifier Migration:
/// - Converted from synchronous Notifier to AsyncNotifier
/// - build() is async and loads initial profile data
/// - Loading/error state handled by AsyncValue wrapper
/// - AsyncValue.guard() replaces manual try/catch + isLoading/error
/// - Methods set state = AsyncLoading() then AsyncValue.guard()
final class ProfileProvider
    extends $AsyncNotifierProvider<Profile, ProfileState> {
  /// Notifier for managing profile state and user interactions.
  ///
  /// Riverpod 3.0 AsyncNotifier Migration:
  /// - Converted from synchronous Notifier to AsyncNotifier
  /// - build() is async and loads initial profile data
  /// - Loading/error state handled by AsyncValue wrapper
  /// - AsyncValue.guard() replaces manual try/catch + isLoading/error
  /// - Methods set state = AsyncLoading() then AsyncValue.guard()
  const ProfileProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'profileProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$profileHash();

  @$internal
  @override
  Profile create() => Profile();
}

String _$profileHash() => r'96136e7da90ba84564316c12b9ecaa6b70602653';

/// Notifier for managing profile state and user interactions.
///
/// Riverpod 3.0 AsyncNotifier Migration:
/// - Converted from synchronous Notifier to AsyncNotifier
/// - build() is async and loads initial profile data
/// - Loading/error state handled by AsyncValue wrapper
/// - AsyncValue.guard() replaces manual try/catch + isLoading/error
/// - Methods set state = AsyncLoading() then AsyncValue.guard()

abstract class _$Profile extends $AsyncNotifier<ProfileState> {
  FutureOr<ProfileState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<ProfileState>, ProfileState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<ProfileState>, ProfileState>,
        AsyncValue<ProfileState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
