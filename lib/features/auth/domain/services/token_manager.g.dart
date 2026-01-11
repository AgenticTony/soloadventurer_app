// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages authentication tokens and their lifecycle according to AWS Cognito specifications
///
/// This provider must be kept alive to prevent disposal during async operations.
/// It's initialized in bootstrap.dart before the app runs.

@ProviderFor(TokenManager)
const tokenManagerProvider = TokenManagerProvider._();

/// Manages authentication tokens and their lifecycle according to AWS Cognito specifications
///
/// This provider must be kept alive to prevent disposal during async operations.
/// It's initialized in bootstrap.dart before the app runs.
final class TokenManagerProvider
    extends $NotifierProvider<TokenManager, FeatureAvailability> {
  /// Manages authentication tokens and their lifecycle according to AWS Cognito specifications
  ///
  /// This provider must be kept alive to prevent disposal during async operations.
  /// It's initialized in bootstrap.dart before the app runs.
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

String _$tokenManagerHash() => r'1860ed64a0a44c8ac637e0a25a44cc316f5e48c8';

/// Manages authentication tokens and their lifecycle according to AWS Cognito specifications
///
/// This provider must be kept alive to prevent disposal during async operations.
/// It's initialized in bootstrap.dart before the app runs.

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
