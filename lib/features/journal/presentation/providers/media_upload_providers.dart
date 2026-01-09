import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/media_upload_service_impl.dart';
import '../../domain/services/media_upload_service.dart';

part 'media_upload_providers.g.dart';

/// Provider for SharedPreferences
@riverpod
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) async {
  return await SharedPreferences.getInstance();
}

/// Provider for MediaUploadService
@riverpod
MediaUploadService mediaUploadService(MediaUploadServiceRef ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);

  // We need to handle the async nature of SharedPreferences
  // In production, you'd want to handle this more gracefully
  return prefsAsync.when(
    data: (prefs) {
      final client = Supabase.instance.client;
      return MediaUploadServiceImpl(
        client: client,
        prefs: prefs,
      );
    },
    loading: () => throw Exception('SharedPreferences not initialized'),
    error: (_, __) => throw Exception('Failed to initialize SharedPreferences'),
  );
}

/// Provider for upload statistics
@riverpod
Future<UploadStatistics> uploadStatistics(UploadStatisticsRef ref) async {
  final service = ref.watch(mediaUploadServiceProvider);
  return service.getStatistics();
}

/// Provider for all upload tasks
@riverpod
Future<List<UploadTask>> uploadTasks(UploadTasksRef ref) async {
  final service = ref.watch(mediaUploadServiceProvider);
  return service.getTasks();
}

/// Provider for tasks of a specific journal entry
@riverpod
Future<List<UploadTask>> uploadTasksForEntry(
  UploadTasksForEntryRef ref,
  String entryId,
) async {
  final service = ref.watch(mediaUploadServiceProvider);
  return service.getTasksForEntry(entryId);
}

/// Provider for a specific upload task
@riverpod
Future<UploadTask?> uploadTask(UploadTaskRef ref, String taskId) async {
  final service = ref.watch(mediaUploadServiceProvider);
  return service.getTask(taskId);
}

/// Provider for upload queue status stream
@riverpod
Stream<List<UploadTask>> uploadQueueStatus(UploadQueueStatusRef ref) async* {
  final service = ref.watch(mediaUploadServiceProvider);
  yield* service.getQueueStatus();
}

/// Provider for upload progress of a specific task
@riverpod
Stream<UploadTask> uploadTaskProgress(
  UploadTaskProgressRef ref,
  String taskId,
) async* {
  final service = ref.watch(mediaUploadServiceProvider);
  yield* service.getTaskProgress(taskId);
}

/// Notifier for managing media uploads
@riverpod
class MediaUploadNotifier extends _$MediaUploadNotifier {
  MediaUploadService? _service;

  @override
  FutureOr<void> build() async {
    _service = ref.watch(mediaUploadServiceProvider);
    await _service!.initialize();
  }

  /// Enqueue a single upload
  Future<UploadTask> enqueueUpload({
    required String filePath,
    required MediaType mediaType,
    String? journalEntryId,
    int? priority,
  }) async {
    if (_service == null) {
      throw Exception('MediaUploadService not initialized');
    }

    final file = File(filePath);

    return await _service!.enqueueUpload(
      file: file,
      mediaType: mediaType,
      journalEntryId: journalEntryId,
      priority: priority,
    );
  }

  /// Enqueue multiple uploads
  Future<List<UploadTask>> enqueueMultipleUploads({
    required List<String> filePaths,
    required List<MediaType> mediaTypes,
    String? journalEntryId,
    int? priority,
  }) async {
    if (_service == null) {
      throw Exception('MediaUploadService not initialized');
    }

    final files = filePaths.map((path) => File(path)).toList();

    return await _service!.enqueueMultipleUploads(
      files: files,
      mediaTypes: mediaTypes,
      journalEntryId: journalEntryId,
      priority: priority,
    );
  }

  /// Start processing uploads
  Future<void> startUploads() async {
    await _service?.startUploads();
  }

  /// Pause uploads
  Future<void> pauseUploads() async {
    await _service?.pauseUploads();
  }

  /// Resume uploads
  Future<void> resumeUploads() async {
    await _service?.resumeUploads();
  }

  /// Cancel a specific upload
  Future<void> cancelUpload(String taskId) async {
    await _service?.cancelUpload(taskId);
  }

  /// Cancel all uploads
  Future<void> cancelAllUploads() async {
    await _service?.cancelAllUploads();
  }

  /// Retry a failed upload
  Future<void> retryUpload(String taskId) async {
    await _service?.retryUpload(taskId);
  }

  /// Clear completed tasks
  Future<void> clearCompleted() async {
    await _service?.clearCompletedTasks();
  }

  /// Clear all tasks
  Future<void> clearAll() async {
    await _service?.clearAllTasks();
  }

  /// Update upload configuration
  void updateConfig(UploadConfig config) {
    _service?.updateConfig(config);
  }

  /// Dispose the service
  Future<void> dispose() async {
    await _service?.dispose();
  }
}
