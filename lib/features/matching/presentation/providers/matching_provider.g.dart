// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matching_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the matching repository
///
/// This will be overridden in the app's provider scope
/// with the actual implementation.

@ProviderFor(matchingRepository)
const matchingRepositoryProvider = MatchingRepositoryProvider._();

/// Provider for the matching repository
///
/// This will be overridden in the app's provider scope
/// with the actual implementation.

final class MatchingRepositoryProvider extends $FunctionalProvider<
    MatchingRepository,
    MatchingRepository,
    MatchingRepository> with $Provider<MatchingRepository> {
  /// Provider for the matching repository
  ///
  /// This will be overridden in the app's provider scope
  /// with the actual implementation.
  const MatchingRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'matchingRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$matchingRepositoryHash();

  @$internal
  @override
  $ProviderElement<MatchingRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MatchingRepository create(Ref ref) {
    return matchingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MatchingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MatchingRepository>(value),
    );
  }
}

String _$matchingRepositoryHash() =>
    r'e61f091c54eac6b4b3626eb3abc7582b121f939e';
