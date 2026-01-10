// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safety_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for SafetyLocalDataSource

@ProviderFor(safetyLocalDataSource)
final safetyLocalDataSourceProvider = SafetyLocalDataSourceProvider._();

/// Provider for SafetyLocalDataSource

final class SafetyLocalDataSourceProvider extends $FunctionalProvider<
    SafetyLocalDataSource,
    SafetyLocalDataSource,
    SafetyLocalDataSource> with $Provider<SafetyLocalDataSource> {
  /// Provider for SafetyLocalDataSource
  SafetyLocalDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'safetyLocalDataSourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$safetyLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<SafetyLocalDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SafetyLocalDataSource create(Ref ref) {
    return safetyLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SafetyLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SafetyLocalDataSource>(value),
    );
  }
}

String _$safetyLocalDataSourceHash() =>
    r'b2f4d063bf9b05e7a081ba1f0beab38a31f4b599';

/// Provider for SafetyRemoteDataSource
/// Uses mock implementation for now, should be replaced with real implementation

@ProviderFor(safetyRemoteDataSource)
final safetyRemoteDataSourceProvider = SafetyRemoteDataSourceProvider._();

/// Provider for SafetyRemoteDataSource
/// Uses mock implementation for now, should be replaced with real implementation

final class SafetyRemoteDataSourceProvider extends $FunctionalProvider<
    SafetyRemoteDataSource,
    SafetyRemoteDataSource,
    SafetyRemoteDataSource> with $Provider<SafetyRemoteDataSource> {
  /// Provider for SafetyRemoteDataSource
  /// Uses mock implementation for now, should be replaced with real implementation
  SafetyRemoteDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'safetyRemoteDataSourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$safetyRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<SafetyRemoteDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SafetyRemoteDataSource create(Ref ref) {
    return safetyRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SafetyRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SafetyRemoteDataSource>(value),
    );
  }
}

String _$safetyRemoteDataSourceHash() =>
    r'f4fd7b20bcf5aaedea42c60f5d85f2e93522d842';

/// Provider for SafetyRepository implementation

@ProviderFor(safetyRepository)
final safetyRepositoryProvider = SafetyRepositoryProvider._();

/// Provider for SafetyRepository implementation

final class SafetyRepositoryProvider extends $FunctionalProvider<
    SafetyRepository,
    SafetyRepository,
    SafetyRepository> with $Provider<SafetyRepository> {
  /// Provider for SafetyRepository implementation
  SafetyRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'safetyRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$safetyRepositoryHash();

  @$internal
  @override
  $ProviderElement<SafetyRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SafetyRepository create(Ref ref) {
    return safetyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SafetyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SafetyRepository>(value),
    );
  }
}

String _$safetyRepositoryHash() => r'e1a315acdacc7114f4d12a4fc64196288a5925f3';

/// Provider override for SafetyRepository interface

@ProviderFor(safetyRepositoryOverride)
final safetyRepositoryOverrideProvider = SafetyRepositoryOverrideProvider._();

/// Provider override for SafetyRepository interface

final class SafetyRepositoryOverrideProvider extends $FunctionalProvider<
    SafetyRepository,
    SafetyRepository,
    SafetyRepository> with $Provider<SafetyRepository> {
  /// Provider override for SafetyRepository interface
  SafetyRepositoryOverrideProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'safetyRepositoryOverrideProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$safetyRepositoryOverrideHash();

  @$internal
  @override
  $ProviderElement<SafetyRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SafetyRepository create(Ref ref) {
    return safetyRepositoryOverride(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SafetyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SafetyRepository>(value),
    );
  }
}

String _$safetyRepositoryOverrideHash() =>
    r'37da08e4b3b89d25fdfd236ae654390847db14e3';
