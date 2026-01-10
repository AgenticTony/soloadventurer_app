// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_blacklist_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages token blacklisting and rotation according to AWS Cognito best practices

@ProviderFor(TokenBlacklistManager)
final tokenBlacklistManagerProvider = TokenBlacklistManagerProvider._();

/// Manages token blacklisting and rotation according to AWS Cognito best practices
final class TokenBlacklistManagerProvider
    extends $NotifierProvider<TokenBlacklistManager, void> {
  /// Manages token blacklisting and rotation according to AWS Cognito best practices
  TokenBlacklistManagerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tokenBlacklistManagerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tokenBlacklistManagerHash();

  @$internal
  @override
  TokenBlacklistManager create() => TokenBlacklistManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$tokenBlacklistManagerHash() =>
    r'7c139ca9d5fbf309d300b68e2156cad10b81c6b0';

/// Manages token blacklisting and rotation according to AWS Cognito best practices

abstract class _$TokenBlacklistManager extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<void, void>, void, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
