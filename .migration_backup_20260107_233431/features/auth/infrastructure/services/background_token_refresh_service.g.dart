// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_token_refresh_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Service responsible for managing background token refresh operations

@ProviderFor(BackgroundTokenRefreshService)
final backgroundTokenRefreshServiceProvider =
    BackgroundTokenRefreshServiceProvider._();

/// Service responsible for managing background token refresh operations
final class BackgroundTokenRefreshServiceProvider
    extends $AsyncNotifierProvider<BackgroundTokenRefreshService, void> {
  /// Service responsible for managing background token refresh operations
  BackgroundTokenRefreshServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'backgroundTokenRefreshServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$backgroundTokenRefreshServiceHash();

  @$internal
  @override
  BackgroundTokenRefreshService create() => BackgroundTokenRefreshService();
}

String _$backgroundTokenRefreshServiceHash() =>
    r'8fc70daf668509b088156916dea15d6abeb70ea6';

/// Service responsible for managing background token refresh operations

abstract class _$BackgroundTokenRefreshService extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, void>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
