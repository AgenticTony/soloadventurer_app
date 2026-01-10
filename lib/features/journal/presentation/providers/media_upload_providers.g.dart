// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_upload_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for SharedPreferences

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// Provider for SharedPreferences

final class SharedPreferencesProvider extends $FunctionalProvider<
        AsyncValue<SharedPreferences>,
        SharedPreferences,
        FutureOr<SharedPreferences>>
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
  /// Provider for SharedPreferences
  SharedPreferencesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sharedPreferencesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<SharedPreferences> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferences> create(Ref ref) {
    return sharedPreferences(ref);
  }
}

String _$sharedPreferencesHash() => r'dc403fbb1d968c7d5ab4ae1721a29ffe173701c7';

/// Provider for MediaUploadService

@ProviderFor(mediaUploadService)
final mediaUploadServiceProvider = MediaUploadServiceProvider._();

/// Provider for MediaUploadService

final class MediaUploadServiceProvider extends $FunctionalProvider<
    MediaUploadService,
    MediaUploadService,
    MediaUploadService> with $Provider<MediaUploadService> {
  /// Provider for MediaUploadService
  MediaUploadServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'mediaUploadServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mediaUploadServiceHash();

  @$internal
  @override
  $ProviderElement<MediaUploadService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MediaUploadService create(Ref ref) {
    return mediaUploadService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaUploadService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaUploadService>(value),
    );
  }
}

String _$mediaUploadServiceHash() =>
    r'a0ff3d1acde00d9b228e43254c61922b27d226ac';

/// Provider for upload statistics

@ProviderFor(uploadStatistics)
final uploadStatisticsProvider = UploadStatisticsProvider._();

/// Provider for upload statistics

final class UploadStatisticsProvider extends $FunctionalProvider<
        AsyncValue<UploadStatistics>,
        UploadStatistics,
        FutureOr<UploadStatistics>>
    with $FutureModifier<UploadStatistics>, $FutureProvider<UploadStatistics> {
  /// Provider for upload statistics
  UploadStatisticsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'uploadStatisticsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$uploadStatisticsHash();

  @$internal
  @override
  $FutureProviderElement<UploadStatistics> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UploadStatistics> create(Ref ref) {
    return uploadStatistics(ref);
  }
}

String _$uploadStatisticsHash() => r'79c4c4817b0ba429e0636631d1aceed72e3c830c';

/// Provider for all upload tasks

@ProviderFor(uploadTasks)
final uploadTasksProvider = UploadTasksProvider._();

/// Provider for all upload tasks

final class UploadTasksProvider extends $FunctionalProvider<
        AsyncValue<List<UploadTask>>,
        List<UploadTask>,
        FutureOr<List<UploadTask>>>
    with $FutureModifier<List<UploadTask>>, $FutureProvider<List<UploadTask>> {
  /// Provider for all upload tasks
  UploadTasksProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'uploadTasksProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$uploadTasksHash();

  @$internal
  @override
  $FutureProviderElement<List<UploadTask>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<UploadTask>> create(Ref ref) {
    return uploadTasks(ref);
  }
}

String _$uploadTasksHash() => r'1e11d2889adce3ca8e7eba254fd54f6e75f1203d';

/// Provider for tasks of a specific journal entry

@ProviderFor(uploadTasksForEntry)
final uploadTasksForEntryProvider = UploadTasksForEntryFamily._();

/// Provider for tasks of a specific journal entry

final class UploadTasksForEntryProvider extends $FunctionalProvider<
        AsyncValue<List<UploadTask>>,
        List<UploadTask>,
        FutureOr<List<UploadTask>>>
    with $FutureModifier<List<UploadTask>>, $FutureProvider<List<UploadTask>> {
  /// Provider for tasks of a specific journal entry
  UploadTasksForEntryProvider._(
      {required UploadTasksForEntryFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'uploadTasksForEntryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$uploadTasksForEntryHash();

  @override
  String toString() {
    return r'uploadTasksForEntryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<UploadTask>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<UploadTask>> create(Ref ref) {
    final argument = this.argument as String;
    return uploadTasksForEntry(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UploadTasksForEntryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$uploadTasksForEntryHash() =>
    r'6894a7426cb213a161bccd901f218b94c6969323';

/// Provider for tasks of a specific journal entry

final class UploadTasksForEntryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<UploadTask>>, String> {
  UploadTasksForEntryFamily._()
      : super(
          retry: null,
          name: r'uploadTasksForEntryProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for tasks of a specific journal entry

  UploadTasksForEntryProvider call(
    String entryId,
  ) =>
      UploadTasksForEntryProvider._(argument: entryId, from: this);

  @override
  String toString() => r'uploadTasksForEntryProvider';
}

/// Provider for a specific upload task

@ProviderFor(uploadTask)
final uploadTaskProvider = UploadTaskFamily._();

/// Provider for a specific upload task

final class UploadTaskProvider extends $FunctionalProvider<
        AsyncValue<UploadTask?>, UploadTask?, FutureOr<UploadTask?>>
    with $FutureModifier<UploadTask?>, $FutureProvider<UploadTask?> {
  /// Provider for a specific upload task
  UploadTaskProvider._(
      {required UploadTaskFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'uploadTaskProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$uploadTaskHash();

  @override
  String toString() {
    return r'uploadTaskProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<UploadTask?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UploadTask?> create(Ref ref) {
    final argument = this.argument as String;
    return uploadTask(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UploadTaskProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$uploadTaskHash() => r'f326dd7476915fff1a03f30d8be1bcf5292349a2';

/// Provider for a specific upload task

final class UploadTaskFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<UploadTask?>, String> {
  UploadTaskFamily._()
      : super(
          retry: null,
          name: r'uploadTaskProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for a specific upload task

  UploadTaskProvider call(
    String taskId,
  ) =>
      UploadTaskProvider._(argument: taskId, from: this);

  @override
  String toString() => r'uploadTaskProvider';
}

/// Provider for upload queue status stream

@ProviderFor(uploadQueueStatus)
final uploadQueueStatusProvider = UploadQueueStatusProvider._();

/// Provider for upload queue status stream

final class UploadQueueStatusProvider extends $FunctionalProvider<
        AsyncValue<List<UploadTask>>,
        List<UploadTask>,
        Stream<List<UploadTask>>>
    with $FutureModifier<List<UploadTask>>, $StreamProvider<List<UploadTask>> {
  /// Provider for upload queue status stream
  UploadQueueStatusProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'uploadQueueStatusProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$uploadQueueStatusHash();

  @$internal
  @override
  $StreamProviderElement<List<UploadTask>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<UploadTask>> create(Ref ref) {
    return uploadQueueStatus(ref);
  }
}

String _$uploadQueueStatusHash() => r'70762d138b10892c1af730c83c9b48aada7e2f9c';

/// Provider for upload progress of a specific task

@ProviderFor(uploadTaskProgress)
final uploadTaskProgressProvider = UploadTaskProgressFamily._();

/// Provider for upload progress of a specific task

final class UploadTaskProgressProvider extends $FunctionalProvider<
        AsyncValue<UploadTask>, UploadTask, Stream<UploadTask>>
    with $FutureModifier<UploadTask>, $StreamProvider<UploadTask> {
  /// Provider for upload progress of a specific task
  UploadTaskProgressProvider._(
      {required UploadTaskProgressFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'uploadTaskProgressProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$uploadTaskProgressHash();

  @override
  String toString() {
    return r'uploadTaskProgressProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<UploadTask> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<UploadTask> create(Ref ref) {
    final argument = this.argument as String;
    return uploadTaskProgress(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UploadTaskProgressProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$uploadTaskProgressHash() =>
    r'7a174b914fc86de046506e24f7b0d0cd266f1e0a';

/// Provider for upload progress of a specific task

final class UploadTaskProgressFamily extends $Family
    with $FunctionalFamilyOverride<Stream<UploadTask>, String> {
  UploadTaskProgressFamily._()
      : super(
          retry: null,
          name: r'uploadTaskProgressProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for upload progress of a specific task

  UploadTaskProgressProvider call(
    String taskId,
  ) =>
      UploadTaskProgressProvider._(argument: taskId, from: this);

  @override
  String toString() => r'uploadTaskProgressProvider';
}

/// Notifier for managing media uploads

@ProviderFor(MediaUploadNotifier)
final mediaUploadProvider = MediaUploadNotifierProvider._();

/// Notifier for managing media uploads
final class MediaUploadNotifierProvider
    extends $AsyncNotifierProvider<MediaUploadNotifier, void> {
  /// Notifier for managing media uploads
  MediaUploadNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'mediaUploadProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mediaUploadNotifierHash();

  @$internal
  @override
  MediaUploadNotifier create() => MediaUploadNotifier();
}

String _$mediaUploadNotifierHash() =>
    r'60ab1125fbfdf1b3aa4100e90da7d160acca9c30';

/// Notifier for managing media uploads

abstract class _$MediaUploadNotifier extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, void>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
