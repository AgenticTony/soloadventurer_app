// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing profile state and user interactions
///
/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier to @riverpod Notifier
/// - Dependencies injected via ref.watch() in build() method
/// - Removed _ref field (use ref directly in methods)
/// - Initialization logic moved from constructor to build() method
///
/// Maps domain state to presentation state and handles user profile operations.

@ProviderFor(Profile)
const profileProvider = ProfileProvider._();

/// Notifier for managing profile state and user interactions
///
/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier to @riverpod Notifier
/// - Dependencies injected via ref.watch() in build() method
/// - Removed _ref field (use ref directly in methods)
/// - Initialization logic moved from constructor to build() method
///
/// Maps domain state to presentation state and handles user profile operations.
final class ProfileProvider extends $NotifierProvider<Profile, ProfileState> {
  /// Notifier for managing profile state and user interactions
  ///
  /// Riverpod 3.0 Migration Notes:
  /// - Converted from StateNotifier to @riverpod Notifier
  /// - Dependencies injected via ref.watch() in build() method
  /// - Removed _ref field (use ref directly in methods)
  /// - Initialization logic moved from constructor to build() method
  ///
  /// Maps domain state to presentation state and handles user profile operations.
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileState>(value),
    );
  }
}

String _$profileHash() => r'0a4b24d32b89b963688b8ef30138efc2f8fea2f5';

/// Notifier for managing profile state and user interactions
///
/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier to @riverpod Notifier
/// - Dependencies injected via ref.watch() in build() method
/// - Removed _ref field (use ref directly in methods)
/// - Initialization logic moved from constructor to build() method
///
/// Maps domain state to presentation state and handles user profile operations.

abstract class _$Profile extends $Notifier<ProfileState> {
  ProfileState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ProfileState, ProfileState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ProfileState, ProfileState>,
        ProfileState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
