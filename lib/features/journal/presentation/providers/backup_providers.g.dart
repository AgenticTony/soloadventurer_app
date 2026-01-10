// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the backup service

@ProviderFor(backupService)
final backupServiceProvider = BackupServiceProvider._();

/// Provider for the backup service

final class BackupServiceProvider
    extends $FunctionalProvider<BackupService, BackupService, BackupService>
    with $Provider<BackupService> {
  /// Provider for the backup service
  BackupServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'backupServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$backupServiceHash();

  @$internal
  @override
  $ProviderElement<BackupService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackupService create(Ref ref) {
    return backupService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupService>(value),
    );
  }
}

String _$backupServiceHash() => r'c867b3873e1e36a2c7e9199d962c9d8dcae1b5aa';

/// Notifier for backup state management

@ProviderFor(BackupNotifier)
final backupProvider = BackupNotifierProvider._();

/// Notifier for backup state management
final class BackupNotifierProvider
    extends $NotifierProvider<BackupNotifier, BackupState> {
  /// Notifier for backup state management
  BackupNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'backupProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$backupNotifierHash();

  @$internal
  @override
  BackupNotifier create() => BackupNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupState>(value),
    );
  }
}

String _$backupNotifierHash() => r'5422444c8b1aa96fc047fdcec8f824b16f792176';

/// Notifier for backup state management

abstract class _$BackupNotifier extends $Notifier<BackupState> {
  BackupState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BackupState, BackupState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<BackupState, BackupState>, BackupState, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

/// Notifier for restore state management

@ProviderFor(RestoreNotifier)
final restoreProvider = RestoreNotifierProvider._();

/// Notifier for restore state management
final class RestoreNotifierProvider
    extends $NotifierProvider<RestoreNotifier, RestoreState> {
  /// Notifier for restore state management
  RestoreNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'restoreProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$restoreNotifierHash();

  @$internal
  @override
  RestoreNotifier create() => RestoreNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RestoreState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RestoreState>(value),
    );
  }
}

String _$restoreNotifierHash() => r'bdbb0117690108b867f392061be614659b0280ea';

/// Notifier for restore state management

abstract class _$RestoreNotifier extends $Notifier<RestoreState> {
  RestoreState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RestoreState, RestoreState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<RestoreState, RestoreState>,
        RestoreState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Provider for available backups list

@ProviderFor(availableBackups)
final availableBackupsProvider = AvailableBackupsProvider._();

/// Provider for available backups list

final class AvailableBackupsProvider extends $FunctionalProvider<
        AsyncValue<List<BackupInfo>>,
        List<BackupInfo>,
        FutureOr<List<BackupInfo>>>
    with $FutureModifier<List<BackupInfo>>, $FutureProvider<List<BackupInfo>> {
  /// Provider for available backups list
  AvailableBackupsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'availableBackupsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$availableBackupsHash();

  @$internal
  @override
  $FutureProviderElement<List<BackupInfo>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<BackupInfo>> create(Ref ref) {
    return availableBackups(ref);
  }
}

String _$availableBackupsHash() => r'515c7f5312cf9164537a8ed2d3f8e55f85771384';

/// Provider for estimated backup size

@ProviderFor(estimatedBackupSize)
final estimatedBackupSizeProvider = EstimatedBackupSizeFamily._();

/// Provider for estimated backup size

final class EstimatedBackupSizeProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Provider for estimated backup size
  EstimatedBackupSizeProvider._(
      {required EstimatedBackupSizeFamily super.from,
      required bool super.argument})
      : super(
          retry: null,
          name: r'estimatedBackupSizeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$estimatedBackupSizeHash();

  @override
  String toString() {
    return r'estimatedBackupSizeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as bool;
    return estimatedBackupSize(
      ref,
      includeMedia: argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EstimatedBackupSizeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$estimatedBackupSizeHash() =>
    r'4ed787ae06de3912eb33ae2922291e514c208c58';

/// Provider for estimated backup size

final class EstimatedBackupSizeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, bool> {
  EstimatedBackupSizeFamily._()
      : super(
          retry: null,
          name: r'estimatedBackupSizeProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for estimated backup size

  EstimatedBackupSizeProvider call({
    bool includeMedia = true,
  }) =>
      EstimatedBackupSizeProvider._(argument: includeMedia, from: this);

  @override
  String toString() => r'estimatedBackupSizeProvider';
}

/// Provider for backup directory path

@ProviderFor(backupDirectoryPath)
final backupDirectoryPathProvider = BackupDirectoryPathProvider._();

/// Provider for backup directory path

final class BackupDirectoryPathProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Provider for backup directory path
  BackupDirectoryPathProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'backupDirectoryPathProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$backupDirectoryPathHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return backupDirectoryPath(ref);
  }
}

String _$backupDirectoryPathHash() =>
    r'9fc1ccfb9e818df3861d99129cabb51b0684fee3';

/// Family provider for getting info about a specific backup

@ProviderFor(backupInfo)
final backupInfoProvider = BackupInfoFamily._();

/// Family provider for getting info about a specific backup

final class BackupInfoProvider extends $FunctionalProvider<
        AsyncValue<BackupInfo>, BackupInfo, FutureOr<BackupInfo>>
    with $FutureModifier<BackupInfo>, $FutureProvider<BackupInfo> {
  /// Family provider for getting info about a specific backup
  BackupInfoProvider._(
      {required BackupInfoFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'backupInfoProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$backupInfoHash();

  @override
  String toString() {
    return r'backupInfoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BackupInfo> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<BackupInfo> create(Ref ref) {
    final argument = this.argument as String;
    return backupInfo(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BackupInfoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$backupInfoHash() => r'02fde272061af61659bfa0a15483f20a5017d5aa';

/// Family provider for getting info about a specific backup

final class BackupInfoFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BackupInfo>, String> {
  BackupInfoFamily._()
      : super(
          retry: null,
          name: r'backupInfoProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Family provider for getting info about a specific backup

  BackupInfoProvider call(
    String backupPath,
  ) =>
      BackupInfoProvider._(argument: backupPath, from: this);

  @override
  String toString() => r'backupInfoProvider';
}
