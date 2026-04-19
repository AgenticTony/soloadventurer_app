import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/services/media_upload_service.dart';
import '../models/upload_task.dart';

/// Implementation of [MediaUploadService] with background support
class MediaUploadServiceImpl extends MediaUploadService {
  final SupabaseClient _client;
  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();

  /// Upload queue
  final List<UploadTask> _queue = [];

  /// Active uploads being processed
  final Map<String, UploadTask> _activeUploads = {};

  /// Current configuration
  UploadConfig _config = UploadConfig.defaultConfig;

  /// Progress callbacks
  final List<UploadProgressCallback> _progressCallbacks = [];

  /// Status change callbacks
  final List<UploadStatusCallback> _statusCallbacks = [];

  /// Stream controllers for task progress
  final Map<String, StreamController<UploadTask>> _taskControllers = {};

  /// Stream controller for queue status
  StreamController<List<UploadTask>>? _queueController;

  /// Whether the service is currently processing uploads
  bool _isProcessing = false;

  /// Subscription key for persistence
  static const String _queueKey = 'media_upload_queue';

  /// Statistics
  int _totalUploads = 0;
  int _successfulUploads = 0;
  int _failedUploads = 0;
  int _totalBytesUploaded = 0;
  final Duration _totalUploadTime = Duration.zero;

  /// Task for background processing
  static const String _backgroundTaskId = 'com.soloadventurer.media.upload';

  /// Creates a new [MediaUploadServiceImpl]
  MediaUploadServiceImpl({
    required SupabaseClient client,
    required SharedPreferences prefs,
  })  : _client = client,
        _prefs = prefs;

  @override
  UploadConfig get config => _config;

  @override
  void updateConfig(UploadConfig config) {
    _config = config;
  }

  @override
  List<UploadTask> getTasks() {
    return List.unmodifiable(_queue);
  }

  @override
  List<UploadTask> getTasksForEntry(String entryId) {
    return _queue.where((task) => task.journalEntryId == entryId).toList();
  }

  @override
  UploadTask? getTask(String taskId) {
    for (final task in _queue) {
      if (task.id == taskId) return task;
    }
    return null;
  }

  @override
  Future<UploadTask> enqueueUpload({
    required File file,
    required MediaType mediaType,
    String? journalEntryId,
    UploadConfig? config,
    int? priority,
  }) async {
    final fileSize = await file.length();
    final taskId = _uuid.v4();

    final task = UploadTask(
      id: taskId,
      filePath: file.path,
      mediaType: mediaType,
      journalEntryId: journalEntryId,
      status: UploadStatus.queued,
      fileSize: fileSize,
      createdAt: DateTime.now(),
      priority: priority ?? _config.defaultPriority,
      compressBeforeUpload:
          config?.enableCompression ?? _config.enableCompression,
    );

    _queue.add(task);
    await _persistQueue();

    _notifyStatusChange(task);

    // Start processing if not already running
    if (!_isProcessing) {
      unawaited(startUploads());
    }

    return task;
  }

  @override
  Future<List<UploadTask>> enqueueMultipleUploads({
    required List<File> files,
    required List<MediaType> mediaTypes,
    String? journalEntryId,
    UploadConfig? config,
    int? priority,
  }) async {
    if (files.length != mediaTypes.length) {
      throw const InvalidImageException(
        message: 'Files and mediaTypes must have the same length',
        code: 'mismatched_lengths',
      );
    }

    final tasks = <UploadTask>[];
    for (int i = 0; i < files.length; i++) {
      final task = await enqueueUpload(
        file: files[i],
        mediaType: mediaTypes[i],
        journalEntryId: journalEntryId,
        config: config,
        priority: priority,
      );
      tasks.add(task);
    }

    return tasks;
  }

  @override
  Future<void> startUploads() async {
    if (_isProcessing) return;

    _isProcessing = true;

    // Sort queue by priority and creation time
    _queue.sort((a, b) {
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority);
      }
      return a.createdAt.compareTo(b.createdAt);
    });

    // Process up to max concurrent uploads
    final readyTasks = _queue.where((task) => task.isReady).take(
          _config.maxConcurrentUploads - _activeUploads.length,
        );

    for (final task in readyTasks) {
      _processUpload(task);
    }
  }

  @override
  Future<void> pauseUploads() async {
    for (final upload in _activeUploads.values) {
      final pausedTask = upload.copyWith(
        status: UploadStatus.paused,
      );
      _updateTask(pausedTask);
    }
    _activeUploads.clear();
    _isProcessing = false;
    await _persistQueue();
  }

  @override
  Future<void> resumeUploads() async {
    final pausedTasks = _queue.where(
      (task) => task.status == UploadStatus.paused,
    );

    for (final task in pausedTasks) {
      final resumedTask = task.copyWith(
        status: UploadStatus.queued,
      );
      _updateTask(resumedTask);
    }

    await startUploads();
  }

  @override
  Future<void> cancelUpload(String taskId) async {
    final task = getTask(taskId);
    if (task == null) return;

    // Cancel if active
    if (_activeUploads.containsKey(taskId)) {
      _activeUploads.remove(taskId);
    }

    final cancelledTask = task.copyWith(
      status: UploadStatus.cancelled,
      completedAt: DateTime.now(),
    );
    _updateTask(cancelledTask);
  }

  @override
  Future<void> cancelAllUploads() async {
    for (final task in _queue) {
      if (task.status == UploadStatus.queued || task.status == UploadStatus.pending || task.status == UploadStatus.uploading) {
        final cancelledTask = task.copyWith(
          status: UploadStatus.cancelled,
          completedAt: DateTime.now(),
        );
        _updateTask(cancelledTask);
      }
    }
    _activeUploads.clear();
    _isProcessing = false;
    await _persistQueue();
  }

  @override
  Future<void> retryUpload(String taskId) async {
    final task = getTask(taskId);
    if (task == null || !task.shouldRetry) return;

    final retriedTask = task.copyWith(
      status: UploadStatus.queued,
      retryCount: task.retryCount + 1,
      errorMessage: null,
      retryAt: null,
    );
    _updateTask(retriedTask);

    await startUploads();
  }

  @override
  Future<void> clearCompletedTasks() async {
    _queue.removeWhere((task) => task.status.isTerminal);
    await _persistQueue();
  }

  @override
  Future<void> clearAllTasks() async {
    _queue.clear();
    _activeUploads.clear();
    await _persistQueue();
  }

  @override
  Stream<UploadTask> getTaskProgress(String taskId) {
    _taskControllers.putIfAbsent(
      taskId,
      () => StreamController<UploadTask>.broadcast(),
    );
    return _taskControllers[taskId]!.stream;
  }

  @override
  Stream<List<UploadTask>> getQueueStatus() {
    _queueController ??= StreamController<List<UploadTask>>.broadcast();
    return _queueController!.stream;
  }

  @override
  void onProgressUpdate(UploadProgressCallback callback) {
    _progressCallbacks.add(callback);
  }

  @override
  void onStatusChange(UploadStatusCallback callback) {
    _statusCallbacks.add(callback);
  }

  @override
  void removeProgressCallback(UploadProgressCallback callback) {
    _progressCallbacks.remove(callback);
  }

  @override
  void removeStatusCallback(UploadStatusCallback callback) {
    _statusCallbacks.remove(callback);
  }

  @override
  UploadStatistics getStatistics() {
    final activeUploads = _activeUploads.length;
    final totalBytesToUpload = _queue.fold<int>(
      0,
      (sum, task) => sum + task.fileSize,
    );

    double averageSpeed = 0.0;
    if (_totalUploadTime.inSeconds > 0) {
      averageSpeed = _totalBytesUploaded / _totalUploadTime.inSeconds;
    }

    return UploadStatistics(
      totalUploads: _totalUploads,
      successfulUploads: _successfulUploads,
      failedUploads: _failedUploads,
      activeUploads: activeUploads,
      totalBytesUploaded: _totalBytesUploaded,
      totalBytesToUpload: totalBytesToUpload,
      averageSpeed: averageSpeed,
      totalUploadTime: _totalUploadTime,
    );
  }

  @override
  Future<void> initialize() async {
    await _loadQueue();

    // Register background task
    await Workmanager().registerPeriodicTask(
      _backgroundTaskId,
      'mediaUploadTask',
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: true,
      ),
    );

    // Resume pending uploads
    final pendingTasks = _queue.where(
      (task) =>
          task.status == UploadStatus.queued ||
          task.status == UploadStatus.failed,
    );

    if (pendingTasks.isNotEmpty) {
      unawaited(startUploads());
    }
  }

  @override
  Future<void> dispose() async {
    _isProcessing = false;

    // Close stream controllers
    for (final controller in _taskControllers.values) {
      await controller.close();
    }
    _taskControllers.clear();

    await _queueController?.close();

    // Cancel background task
    await Workmanager().cancelByUniqueName(_backgroundTaskId);
  }

  /// Process a single upload task
  Future<void> _processUpload(UploadTask task) async {
    if (_activeUploads.length >= _config.maxConcurrentUploads) {
      return;
    }

    _activeUploads[task.id] = task;

    final uploadingTask = task.copyWith(
      status: UploadStatus.uploading,
      startedAt: DateTime.now(),
    );
    _updateTask(uploadingTask);

    try {
      await _performUpload(uploadingTask);
    } catch (e, stack) {
      await _handleUploadError(task, e, stack);
    } finally {
      _activeUploads.remove(task.id);

      // Process next task if available
      final nextTask = _queue.firstWhere(
        (t) => t.isReady && !_activeUploads.containsKey(t.id),
        orElse: () => task,
      );

      if (nextTask.id != task.id) {
        unawaited(_processUpload(nextTask));
      } else if (_activeUploads.isEmpty) {
        _isProcessing = false;
      }
    }
  }

  /// Perform the actual upload
  Future<void> _performUpload(UploadTask task) async {
    final file = File(task.currentFilePath);

    if (!file.existsSync()) {
      throw const MediaUploadException(
        message: 'File does not exist',
        code: 'file_not_found',
      );
    }

    // Determine bucket based on media type
    final bucket =
        task.mediaType == MediaType.photo ? 'journal-photos' : 'journal-videos';

    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const UnauthorizedException(
        message: 'User not authenticated',
      );
    }

    // Generate unique storage path
    final ext = path.extension(task.filePath);
    final storagePath = '$userId/${DateTime.now().toIso8601String()}$_uuid$ext';

    // Upload file with progress tracking
    await _client.storage.from(bucket).upload(
          storagePath,
          file,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ),
        );

    // Mark as completed
    final completedTask = task.copyWith(
      status: UploadStatus.completed,
      progress: 100,
      storagePath: storagePath,
      completedAt: DateTime.now(),
    );
    _updateTask(completedTask);

    _totalUploads++;
    _successfulUploads++;
    _totalBytesUploaded += task.fileSize;

    // Update database record if associated with journal entry
    if (task.journalEntryId != null) {
      try {
        await _updateMediaItemInDatabase(
          task.journalEntryId!,
          storagePath,
          task.mediaType,
        );
      } catch (e) {
        // Log error but don't fail the upload
      }
    }
  }

  /// Handle upload errors with retry logic
  Future<void> _handleUploadError(
    UploadTask task,
    Object error,
    StackTrace stack,
  ) async {
    final shouldRetry = task.retryCount < task.maxRetries;

    if (shouldRetry) {
      // Calculate exponential backoff delay
      final delay = Duration(
        milliseconds:
            (_config.retryDelay.inMilliseconds * (1 << task.retryCount)).clamp(
          _config.retryDelay.inMilliseconds,
          _config.maxRetryDelay.inMilliseconds,
        ),
      );

      final retryTime = DateTime.now().add(delay);

      final failedTask = task.copyWith(
        status: UploadStatus.failed,
        errorMessage: error.toString(),
        retryAt: retryTime,
      );
      _updateTask(failedTask);

      // Schedule retry
      Timer(delay, () {
        final retryTask = getTask(task.id);
        if (retryTask != null && retryTask.shouldRetry) {
          unawaited(_processUpload(retryTask));
        }
      });
    } else {
      // Mark as permanent failure
      final failedTask = task.copyWith(
        status: UploadStatus.permanentFailure,
        errorMessage: error.toString(),
        completedAt: DateTime.now(),
      );
      _updateTask(failedTask);

      _totalUploads++;
      _failedUploads++;
    }
  }

  /// Update media item in database after successful upload
  Future<void> _updateMediaItemInDatabase(
    String entryId,
    String storagePath,
    MediaType mediaType,
  ) async {
    await _client.from('media_items').insert({
      'journal_entry_id': entryId,
      'media_type': mediaType.value,
      'storage_path': storagePath,
      'upload_status': 'completed',
      'upload_progress': 100,
      'sync_status': 'synced',
    });
  }

  /// Update a task in the queue
  void _updateTask(UploadTask updatedTask) {
    final index = _queue.indexWhere((t) => t.id == updatedTask.id);
    if (index >= 0) {
      _queue[index] = updatedTask;

      // Notify progress callbacks
      for (final callback in _progressCallbacks) {
        callback(updatedTask.id, updatedTask.progress);
      }

      // Notify status callbacks
      _notifyStatusChange(updatedTask);

      // Update task stream
      _taskControllers[updatedTask.id]?.add(updatedTask);

      // Update queue stream
      _queueController?.add(List.from(_queue));

      // Persist queue
      unawaited(_persistQueue());
    }
  }

  /// Notify status change callbacks
  void _notifyStatusChange(UploadTask task) {
    for (final callback in _statusCallbacks) {
      try {
        callback(task);
      } catch (e) {
      // intentional silent catch
      }
    }
  }

  /// Persist queue to storage
  Future<void> _persistQueue() async {
    try {
      final jsonList = _queue.map((task) => task.toJson()).toList();
      await _prefs.setString(_queueKey, jsonEncode(jsonList));
    } catch (e) {
    // intentional silent catch
    }
  }

  /// Load queue from storage
  Future<void> _loadQueue() async {
    try {
      final jsonString = _prefs.getString(_queueKey);
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List;
        final tasks = jsonList
            .map((json) => UploadTask.fromJson(json as Map<String, dynamic>))
            .toList();

        _queue.clear();
        _queue.addAll(tasks);
      }
    } catch (e) {
    // intentional silent catch
    }
  }
}

/// Exception for media upload errors
class MediaUploadException extends AppException {
  const MediaUploadException({
    required super.message,
    String? code,
  }) : super(code: code ?? 'media_upload_error');
}
