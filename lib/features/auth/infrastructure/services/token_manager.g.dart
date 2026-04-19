// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages authentication tokens and their lifecycle according to AWS Cognito specifications

@ProviderFor(TokenManager)
const tokenManagerProvider = TokenManagerProvider._();

/// Manages authentication tokens and their lifecycle according to AWS Cognito specifications
final class TokenManagerProvider
    extends $NotifierProvider<TokenManager, FeatureAvailability> {
  /// Manages authentication tokens and their lifecycle according to AWS Cognito specifications
  const TokenManagerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tokenManagerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tokenManagerHash();

  @$internal
  @override
  TokenManager create() => TokenManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeatureAvailability value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeatureAvailability>(value),
    );
  }
}

String _$tokenManagerHash() => r'0469cd80ddcb24395b26ebecec3538bcf5cd1712';

/// Manages authentication tokens and their lifecycle according to AWS Cognito specifications

abstract class _$TokenManager extends $Notifier<FeatureAvailability> {
  FeatureAvailability build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<FeatureAvailability, FeatureAvailability>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<FeatureAvailability, FeatureAvailability>,
        FeatureAvailability,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
