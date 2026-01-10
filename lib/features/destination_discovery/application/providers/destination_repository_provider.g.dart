// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the destination repository
///
/// This provider must be overridden in the main application to provide
/// the actual implementation of [DestinationRepository].
///
/// Riverpod 3.0: Uses @riverpod annotation with code generation.
/// The provider is defined here for shared use across all destination discovery providers.

@ProviderFor(destinationRepository)
final destinationRepositoryProvider = DestinationRepositoryProvider._();

/// Provider for the destination repository
///
/// This provider must be overridden in the main application to provide
/// the actual implementation of [DestinationRepository].
///
/// Riverpod 3.0: Uses @riverpod annotation with code generation.
/// The provider is defined here for shared use across all destination discovery providers.

final class DestinationRepositoryProvider extends $FunctionalProvider<
    DestinationRepository,
    DestinationRepository,
    DestinationRepository> with $Provider<DestinationRepository> {
  /// Provider for the destination repository
  ///
  /// This provider must be overridden in the main application to provide
  /// the actual implementation of [DestinationRepository].
  ///
  /// Riverpod 3.0: Uses @riverpod annotation with code generation.
  /// The provider is defined here for shared use across all destination discovery providers.
  DestinationRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'destinationRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$destinationRepositoryHash();

  @$internal
  @override
  $ProviderElement<DestinationRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DestinationRepository create(Ref ref) {
    return destinationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DestinationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DestinationRepository>(value),
    );
  }
}

String _$destinationRepositoryHash() =>
    r'becf6d6440f6a291a14ac797dc67906790e34d3b';
