// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safety_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for SafetyLocalDataSource

@ProviderFor(safetyLocalDataSource)
const safetyLocalDataSourceProvider = SafetyLocalDataSourceProvider._();

/// Provider for SafetyLocalDataSource

final class SafetyLocalDataSourceProvider extends $FunctionalProvider<
    SafetyLocalDataSource,
    SafetyLocalDataSource,
    SafetyLocalDataSource> with $Provider<SafetyLocalDataSource> {
  /// Provider for SafetyLocalDataSource
  const SafetyLocalDataSourceProvider._()
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
    r'79415e99fd9d58ba60962156fafdbc84ddc155a6';

/// Provider for SafetyRemoteDataSource
/// Uses mock implementation for now, should be replaced with real implementation

@ProviderFor(safetyRemoteDataSource)
const safetyRemoteDataSourceProvider = SafetyRemoteDataSourceProvider._();

/// Provider for SafetyRemoteDataSource
/// Uses mock implementation for now, should be replaced with real implementation

final class SafetyRemoteDataSourceProvider extends $FunctionalProvider<
    SafetyRemoteDataSource,
    SafetyRemoteDataSource,
    SafetyRemoteDataSource> with $Provider<SafetyRemoteDataSource> {
  /// Provider for SafetyRemoteDataSource
  /// Uses mock implementation for now, should be replaced with real implementation
  const SafetyRemoteDataSourceProvider._()
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
    r'8ccec52c4e2c1901ff90da3e4976d523f7bfb3b2';

/// Provider for SafetyRepository implementation

@ProviderFor(safetyRepository)
const safetyRepositoryProvider = SafetyRepositoryProvider._();

/// Provider for SafetyRepository implementation

final class SafetyRepositoryProvider extends $FunctionalProvider<
    SafetyRepository,
    SafetyRepository,
    SafetyRepository> with $Provider<SafetyRepository> {
  /// Provider for SafetyRepository implementation
  const SafetyRepositoryProvider._()
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

String _$safetyRepositoryHash() => r'148e97810d9d39ab7699de8fad18b3645c20d405';

/// Provider override for SafetyRepository interface

@ProviderFor(safetyRepositoryOverride)
const safetyRepositoryOverrideProvider = SafetyRepositoryOverrideProvider._();

/// Provider override for SafetyRepository interface

final class SafetyRepositoryOverrideProvider extends $FunctionalProvider<
    SafetyRepository,
    SafetyRepository,
    SafetyRepository> with $Provider<SafetyRepository> {
  /// Provider override for SafetyRepository interface
  const SafetyRepositoryOverrideProvider._()
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
    r'534dc8abaeac33619e8751dd1800128d4f5860ab';
