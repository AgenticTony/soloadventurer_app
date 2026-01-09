// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Profile UI state notifier (presentation layer)
/// Manages UI-specific state for profile screens

@ProviderFor(ProfileNotifier)
final profileProvider = ProfileNotifierFamily._();

/// Profile UI state notifier (presentation layer)
/// Manages UI-specific state for profile screens
final class ProfileNotifierProvider
    extends $NotifierProvider<ProfileNotifier, ProfileState> {
  /// Profile UI state notifier (presentation layer)
  /// Manages UI-specific state for profile screens
  ProfileNotifierProvider._(
      {required ProfileNotifierFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'profileProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$profileNotifierHash();

  @override
  String toString() {
    return r'profileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProfileNotifier create() => ProfileNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileNotifierHash() => r'82f3ac201d672621037e4d6385d1d699b5522ee5';

/// Profile UI state notifier (presentation layer)
/// Manages UI-specific state for profile screens

final class ProfileNotifierFamily extends $Family
    with
        $ClassFamilyOverride<ProfileNotifier, ProfileState, ProfileState,
            ProfileState, String> {
  ProfileNotifierFamily._()
      : super(
          retry: null,
          name: r'profileProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Profile UI state notifier (presentation layer)
  /// Manages UI-specific state for profile screens

  ProfileNotifierProvider call(
    String userId,
  ) =>
      ProfileNotifierProvider._(argument: userId, from: this);

  @override
  String toString() => r'profileProvider';
}

/// Profile UI state notifier (presentation layer)
/// Manages UI-specific state for profile screens

abstract class _$ProfileNotifier extends $Notifier<ProfileState> {
  late final _$args = ref.$arg as String;
  String get userId => _$args;

  ProfileState build(
    String userId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ProfileState, ProfileState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ProfileState, ProfileState>,
        ProfileState,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
