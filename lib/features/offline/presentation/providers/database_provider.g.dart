// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for DatabaseService initialization and management
///
/// This provider ensures that the database is initialized before
/// any dependent services attempt to access it. It handles the
/// lazy initialization pattern and provides error recovery.

@ProviderFor(DatabaseNotifier)
const databaseProvider = DatabaseNotifierProvider._();

/// Provider for DatabaseService initialization and management
///
/// This provider ensures that the database is initialized before
/// any dependent services attempt to access it. It handles the
/// lazy initialization pattern and provides error recovery.
final class DatabaseNotifierProvider
    extends $AsyncNotifierProvider<DatabaseNotifier, DatabaseService> {
  /// Provider for DatabaseService initialization and management
  ///
  /// This provider ensures that the database is initialized before
  /// any dependent services attempt to access it. It handles the
  /// lazy initialization pattern and provides error recovery.
  const DatabaseNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'databaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$databaseNotifierHash();

  @$internal
  @override
  DatabaseNotifier create() => DatabaseNotifier();
}

String _$databaseNotifierHash() => r'3a26c02af2b43296cf1364058a216786773cf192';

/// Provider for DatabaseService initialization and management
///
/// This provider ensures that the database is initialized before
/// any dependent services attempt to access it. It handles the
/// lazy initialization pattern and provides error recovery.

abstract class _$DatabaseNotifier extends $AsyncNotifier<DatabaseService> {
  FutureOr<DatabaseService> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<DatabaseService>, DatabaseService>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<DatabaseService>, DatabaseService>,
        AsyncValue<DatabaseService>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

/// Simple provider that provides access to the DatabaseService
///
/// Note: This provider requires databaseNotifierProvider to be
/// initialized first. Use databaseNotifierProvider for most cases.

@ProviderFor(databaseService)
const databaseServiceProvider = DatabaseServiceProvider._();

/// Simple provider that provides access to the DatabaseService
///
/// Note: This provider requires databaseNotifierProvider to be
/// initialized first. Use databaseNotifierProvider for most cases.

final class DatabaseServiceProvider extends $FunctionalProvider<DatabaseService,
    DatabaseService, DatabaseService> with $Provider<DatabaseService> {
  /// Simple provider that provides access to the DatabaseService
  ///
  /// Note: This provider requires databaseNotifierProvider to be
  /// initialized first. Use databaseNotifierProvider for most cases.
  const DatabaseServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'databaseServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$databaseServiceHash();

  @$internal
  @override
  $ProviderElement<DatabaseService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DatabaseService create(Ref ref) {
    return databaseService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DatabaseService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DatabaseService>(value),
    );
  }
}

String _$databaseServiceHash() => r'85f3ec2d553fd4e12247ada5779873445695f013';
