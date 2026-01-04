# Background Media Upload Service

Comprehensive background upload service with queue management for photos and videos in the travel journal feature.

## Overview

The media upload service provides a robust solution for uploading media files in the background with:
- **Queue Management**: Organize and prioritize uploads
- **Background Processing**: Continue uploads even when app is in background
- **Retry Logic**: Automatic retry with exponential backoff
- **Progress Tracking**: Real-time progress updates for each upload
- **Offline Support**: Persist queue state across app restarts
- **Concurrent Uploads**: Control number of simultaneous uploads
- **Compression Integration**: Automatic compression before upload

## Architecture

```
┌─────────────────────────────────────────────────────┐
│           MediaUploadService (Interface)            │
├─────────────────────────────────────────────────────┤
│  - enqueueUpload()                                  │
│  - startUploads()                                   │
│  - pauseUploads()                                   │
│  - retryUpload()                                    │
│  - getStatistics()                                  │
│  - onProgressUpdate()                               │
└─────────────────────────────────────────────────────┘
                         ▲
                         │
                         │ implements
                         │
┌─────────────────────────────────────────────────────┐
│      MediaUploadServiceImpl (Implementation)        │
├─────────────────────────────────────────────────────┤
│  - _queue: List<UploadTask>                         │
│  - _activeUploads: Map<String, UploadTask>          │
│  - _config: UploadConfig                            │
│  - Workmanager integration                          │
│  - SharedPreferences for persistence               │
└─────────────────────────────────────────────────────┘
```

## Files

- **`upload_task.dart`**: Model for upload tasks with status tracking
- **`media_upload_service.dart`**: Service interface and types
- **`media_upload_service_impl.dart`**: Implementation with background support
- **`media_upload_providers.dart`**: Riverpod providers for state management

## Installation

The service requires these dependencies (already in `pubspec.yaml`):

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.3
  shared_preferences: ^2.2.2
  supabase_flutter: ^2.0.0
  uuid: ^4.3.3
  workmanager: ^0.5.2
  flutter_image_compress: ^2.3.0
```

## Quick Start

### 1. Initialize the Service

```dart
final ref = ProviderContainer();
final service = ref.read(mediaUploadServiceProvider);
await service.initialize();
```

### 2. Enqueue a Single Upload

```dart
final file = File('/path/to/photo.jpg');
final task = await service.enqueueUpload(
  file: file,
  mediaType: MediaType.photo,
  journalEntryId: 'entry-123',
  priority: 1, // Higher priority = earlier upload
);

print('Upload task ID: ${task.id}');
print('Status: ${task.status}');
```

### 3. Monitor Progress

```dart
service.onProgressUpdate((taskId, progress) {
  print('Task $taskId: $progress%');
});

service.onStatusChange((task) {
  print('Task ${task.id} status: ${task.status}');
  if (task.status == UploadStatus.completed) {
    print('Upload complete! Storage path: ${task.storagePath}');
  }
});
```

### 4. Use with Riverpod

```dart
class MediaUploadWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(mediaUploadNotifierProvider);

    ElevatedButton(
      onPressed: () async {
        await notifier.enqueueUpload(
          filePath: '/path/to/photo.jpg',
          mediaType: MediaType.photo,
          journalEntryId: 'entry-123',
        );
        await notifier.startUploads();
      },
      child: Text('Upload Photo'),
    );
  }
}
```

## Upload Task Model

### Status States

```dart
enum UploadStatus {
  queued,           // Waiting in queue
  uploading,        // Currently uploading
  completed,        // Upload successful
  failed,           // Upload failed (will retry)
  permanentFailure, // Failed permanently
  paused,           // Upload paused
  cancelled,        // Upload cancelled
}
```

### Task Properties

```dart
class UploadTask {
  final String id;                    // Unique task ID
  final String filePath;              // Local file path
  final MediaType mediaType;          // photo or video
  final String? journalEntryId;       // Associated entry
  final UploadStatus status;          // Current status
  final int progress;                 // 0-100
  final int retryCount;               // Number of retries
  final int maxRetries;               // Max retry attempts
  final String? errorMessage;         // Error message if failed
  final String? storagePath;          // Storage path after upload
  final int fileSize;                 // File size in bytes
  final DateTime createdAt;           // Task creation time
  final DateTime? startedAt;          // Upload start time
  final DateTime? completedAt;        // Completion time
  final DateTime? retryAt;            // Next retry time
  final int priority;                 // Upload priority
  final bool compressBeforeUpload;    // Whether to compress
  final String? compressedFilePath;   // Compressed file path
}
```

## Configuration

### Upload Config

```dart
final config = UploadConfig(
  maxConcurrentUploads: 3,     // Max simultaneous uploads
  maxRetries: 3,               // Max retry attempts
  retryDelay: Duration(seconds: 5), // Base retry delay
  maxRetryDelay: Duration(minutes: 5), // Max retry delay
  uploadTimeout: Duration(minutes: 5), // Upload timeout
  enableCompression: true,     // Compress before upload
  chunkSize: 1024 * 1024,      // 1 MB chunks
  defaultPriority: 0,          // Default upload priority
);

service.updateConfig(config);
```

### Predefined Configs

```dart
// Default configuration
UploadConfig.defaultConfig

// For slow networks
UploadConfig.slowNetworkConfig
```

## API Reference

### Queue Management

#### `enqueueUpload()`
Add a single file to the upload queue.

```dart
Future<UploadTask> enqueueUpload({
  required File file,
  required MediaType mediaType,
  String? journalEntryId,
  UploadConfig? config,
  int? priority,
})
```

#### `enqueueMultipleUploads()`
Add multiple files at once.

```dart
Future<List<UploadTask>> enqueueMultipleUploads({
  required List<File> files,
  required List<MediaType> mediaTypes,
  String? journalEntryId,
  UploadConfig? config,
  int? priority,
})
```

#### `startUploads()`
Start processing the upload queue.

```dart
Future<void> startUploads()
```

#### `pauseUploads()`
Pause all active uploads.

```dart
Future<void> pauseUploads()
```

#### `resumeUploads()`
Resume paused uploads.

```dart
Future<void> resumeUploads()
```

### Task Management

#### `cancelUpload()`
Cancel a specific upload task.

```dart
Future<void> cancelUpload(String taskId)
```

#### `cancelAllUploads()`
Cancel all uploads.

```dart
Future<void> cancelAllUploads()
```

#### `retryUpload()`
Manually retry a failed upload.

```dart
Future<void> retryUpload(String taskId)
```

#### `clearCompletedTasks()`
Remove completed or permanently failed tasks.

```dart
Future<void> clearCompletedTasks()
```

#### `clearAllTasks()`
Clear all tasks from the queue.

```dart
Future<void> clearAllTasks()
```

### Query Methods

#### `getTasks()`
Get all upload tasks.

```dart
List<UploadTask> getTasks()
```

#### `getTasksForEntry()`
Get tasks for a specific journal entry.

```dart
List<UploadTask> getTasksForEntry(String entryId)
```

#### `getTask()`
Get a specific task by ID.

```dart
UploadTask? getTask(String taskId)
```

### Progress Monitoring

#### `getTaskProgress()`
Stream progress updates for a specific task.

```dart
Stream<UploadTask> getTaskProgress(String taskId)
```

#### `getQueueStatus()`
Stream the entire upload queue status.

```dart
Stream<List<UploadTask>> getQueueStatus()
```

#### `onProgressUpdate()`
Register a callback for progress updates.

```dart
void onProgressUpdate(UploadProgressCallback callback)
```

#### `onStatusChange()`
Register a callback for status changes.

```dart
void onStatusChange(UploadStatusCallback callback)
```

### Statistics

#### `getStatistics()`
Get upload statistics.

```dart
UploadStatistics getStatistics()

class UploadStatistics {
  final int totalUploads;           // Total uploads attempted
  final int successfulUploads;      // Successful uploads
  final int failedUploads;          // Failed uploads
  final int activeUploads;          // Currently active
  final int totalBytesUploaded;     // Bytes uploaded
  final int totalBytesToUpload;     // Bytes to upload
  final double averageSpeed;        // Avg speed (bytes/sec)
  final Duration totalUploadTime;   // Total time spent

  double get successRate;           // Success rate (0.0-1.0)
  double get overallProgress;       // Overall progress (0.0-1.0)
}
```

## Riverpod Integration

### Providers

```dart
// Service provider
final mediaUploadServiceProvider = ...;

// Statistics provider
final uploadStatisticsProvider = ...;

// All tasks provider
final uploadTasksProvider = ...;

// Tasks for entry provider
final uploadTasksForEntryProvider = ...;

// Single task provider
final uploadTaskProvider = ...;

// Queue status stream provider
final uploadQueueStatusProvider = ...;

// Task progress stream provider
final uploadTaskProgressProvider = ...;

// Notifier for managing uploads
final mediaUploadNotifierProvider = ...;
```

### Usage in Widget

```dart
class UploadScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  @override
  void initState() {
    super.initState();

    // Listen to queue status
    ref.listen(uploadQueueStatusProvider, (previous, next) {
      final queue = next.value ?? [];
      final uploading = queue.where((t) => t.status == UploadStatus.uploading).length;
      final completed = queue.where((t) => t.status == UploadStatus.completed).length;

      print('Active uploads: $uploading, Completed: $completed');
    });
  }

  @override
  Widget build(BuildContext context) {
    final queueAsync = ref.watch(uploadQueueStatusProvider);

    return queueAsync.when(
      data: (queue) => ListView.builder(
        itemCount: queue.length,
        itemBuilder: (context, index) {
          final task = queue[index];
          return UploadTaskTile(task: task);
        },
      ),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}

class UploadTaskTile extends ConsumerWidget {
  final UploadTask task;

  const UploadTaskTile({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(task.filePath),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status: ${task.status.toValue()}'),
          if (task.status == UploadStatus.uploading)
            LinearProgressIndicator(value: task.progress / 100),
        ],
      ),
      trailing: _buildTrailing(context, ref),
    );
  }

  Widget? _buildTrailing(BuildContext context, WidgetRef ref) {
    switch (task.status) {
      case UploadStatus.uploading:
      case UploadStatus.queued:
        return IconButton(
          icon: Icon(Icons.cancel),
          onPressed: () {
            ref.read(mediaUploadNotifierProvider.notifier)
                .cancelUpload(task.id);
          },
        );
      case UploadStatus.failed:
        return IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {
            ref.read(mediaUploadNotifierProvider.notifier)
                .retryUpload(task.id);
          },
        );
      default:
        return Icon(Icons.check_circle, color: Colors.green);
    }
  }
}
```

## Background Processing

The service uses `workmanager` for background uploads. Background tasks run every 15 minutes when:
- Network is available
- Battery is not low
- Storage is not low

### Background Task Configuration

```dart
await Workmanager().registerPeriodicTask(
  'com.soloadventurer.media.upload',
  'mediaUploadTask',
  frequency: Duration(minutes: 15),
  constraints: WorkManagerConstraints(
    networkType: NetworkType.connected,
    requiresBatteryNotLow: true,
    requiresCharging: false,
    requiresDeviceIdle: false,
    requiresStorageNotLow: true,
  ),
);
```

## Error Handling

### Retry Logic

- Exponential backoff: 5s, 10s, 20s, 40s, ...
- Max retry delay: 5 minutes
- Default max retries: 3

### Error Types

```dart
// Network errors (will retry)
NetworkTimeoutException
NetworkConnectivityException

// Server errors (will retry)
ServerException

// Client errors (permanent failure)
UnauthorizedException
ForbiddenException
NotFoundException
BadRequestException

// File errors (permanent failure)
MediaUploadException
InvalidImageException
```

## Persistence

Upload queue is persisted using `SharedPreferences`:
- Queue saved on every state change
- Automatically restored on app restart
- Failed uploads retained for retry

## Compression Integration

The service integrates with existing compression utilities:

```dart
// Automatic compression for photos
MediaCompression.compressImage(file)

// Automatic compression for videos
VideoCompression.compressVideo(file)
```

## Best Practices

1. **Enqueue uploads before navigating away**
   ```dart
   await service.enqueueUpload(file: file, mediaType: MediaType.photo);
   await service.startUploads(); // Start immediately
   ```

2. **Monitor progress for user feedback**
   ```dart
   service.onProgressUpdate((taskId, progress) {
     // Update UI
   });
   ```

3. **Handle errors gracefully**
   ```dart
   service.onStatusChange((task) {
     if (task.status == UploadStatus.permanentFailure) {
       // Show error message to user
       showError(task.errorMessage ?? 'Upload failed');
     }
   });
   ```

4. **Clean up completed tasks periodically**
   ```dart
   await service.clearCompletedTasks();
   ```

5. **Adjust config based on network conditions**
   ```dart
   final isSlowNetwork = await checkNetworkSpeed();
   final config = isSlowNetwork
       ? UploadConfig.slowNetworkConfig
       : UploadConfig.defaultConfig;
   service.updateConfig(config);
   ```

## Troubleshooting

### Uploads not starting
- Check network connectivity
- Verify Supabase authentication
- Ensure service is initialized: `await service.initialize()`

### Uploads stuck in "queued" state
- Call `startUploads()` to begin processing
- Check if max concurrent uploads reached
- Verify background permissions (Android)

### Uploads failing repeatedly
- Check file size (max 10MB for photos, 100MB for videos)
- Verify storage bucket RLS policies
- Check available storage space

### Background uploads not working
- Verify Workmanager setup
- Check battery optimization settings (Android)
- Ensure background refresh enabled (iOS)

## Testing

```dart
// Mock service for testing
class MockMediaUploadService implements MediaUploadService {
  final _tasks = <UploadTask>[];

  @override
  Future<UploadTask> enqueueUpload({
    required File file,
    required MediaType mediaType,
    String? journalEntryId,
    UploadConfig? config,
    int? priority,
  }) async {
    final task = UploadTask(
      id: 'test-123',
      filePath: file.path,
      mediaType: mediaType,
      journalEntryId: journalEntryId,
      status: UploadStatus.queued,
      fileSize: await file.length(),
      createdAt: DateTime.now(),
      priority: priority ?? 0,
    );
    _tasks.add(task);
    return task;
  }

  // Implement other methods...
}
```

## Future Enhancements

- [ ] Thumbnail generation during upload
- [ ] Batch upload optimization
- [ ] Upload priority adjustment on the fly
- [ ] WiFi-only upload option
- [ ] Upload scheduling
- [ ] Upload history and logs
- [ ] Advanced error recovery
- [ ] Background task customization

## Related Components

- **MediaCompression**: Image compression utility
- **VideoCompression**: Video compression utility
- **MediaPicker**: Media selection component
- **JournalRepository**: Database operations
- **Supabase Storage**: Cloud storage backend
