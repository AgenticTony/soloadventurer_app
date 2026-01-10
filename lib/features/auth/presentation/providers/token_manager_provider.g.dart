// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_manager_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TokenManager)
final tokenManagerProvider = TokenManagerProvider._();

final class TokenManagerProvider
    extends $NotifierProvider<TokenManager, AsyncValue<TokenState>> {
  TokenManagerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tokenManagerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tokenManagerHash();

  @$internal
  @override
  TokenManager create() => TokenManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<TokenState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<TokenState>>(value),
    );
  }
}

String _$tokenManagerHash() => r'8f81e9dbcbfa9dae4a912694c6233ff9489ce54b';

abstract class _$TokenManager extends $Notifier<AsyncValue<TokenState>> {
  AsyncValue<TokenState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<TokenState>, AsyncValue<TokenState>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<TokenState>, AsyncValue<TokenState>>,
        AsyncValue<TokenState>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
