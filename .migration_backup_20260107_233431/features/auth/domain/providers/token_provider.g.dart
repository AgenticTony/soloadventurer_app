// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Token provider that manages token lifecycle

@ProviderFor(TokenNotifier)
final tokenProvider = TokenNotifierProvider._();

/// Token provider that manages token lifecycle
final class TokenNotifierProvider
    extends $NotifierProvider<TokenNotifier, AsyncValue<AuthSession?>> {
  /// Token provider that manages token lifecycle
  TokenNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tokenProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tokenNotifierHash();

  @$internal
  @override
  TokenNotifier create() => TokenNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<AuthSession?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<AuthSession?>>(value),
    );
  }
}

String _$tokenNotifierHash() => r'052076401dd52632dc9f284b852edecd5f0347cb';

/// Token provider that manages token lifecycle

abstract class _$TokenNotifier extends $Notifier<AsyncValue<AuthSession?>> {
  AsyncValue<AuthSession?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<AuthSession?>, AsyncValue<AuthSession?>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<AuthSession?>, AsyncValue<AuthSession?>>,
        AsyncValue<AuthSession?>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Provider for the current access token

@ProviderFor(accessToken)
final accessTokenProvider = AccessTokenProvider._();

/// Provider for the current access token

final class AccessTokenProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Provider for the current access token
  AccessTokenProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'accessTokenProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$accessTokenHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return accessToken(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$accessTokenHash() => r'0b570bfcb30cc1cbf232647bc0d0af0b19a8a608';

/// Provider for token validity

@ProviderFor(hasValidTokens)
final hasValidTokensProvider = HasValidTokensProvider._();

/// Provider for token validity

final class HasValidTokensProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider for token validity
  HasValidTokensProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'hasValidTokensProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$hasValidTokensHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasValidTokens(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasValidTokensHash() => r'91cc2e0e1c6d950372f018a4dc09785894e118d8';
