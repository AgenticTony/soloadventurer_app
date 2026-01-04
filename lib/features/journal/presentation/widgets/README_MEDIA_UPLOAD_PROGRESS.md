# Media Upload Progress Indicator

Comprehensive upload progress indicator widget for displaying media upload status with real-time updates, visual feedback, and user interaction support.

## Overview

The `MediaUploadProgressIndicator` widget provides a user-friendly way to track media upload progress in your travel journal app. It integrates seamlessly with the existing media upload service and supports various display modes to fit different UI contexts.

### Features

✅ **Multiple Display Modes**: Detailed, compact, and minimal views
✅ **Real-time Updates**: Stream-based progress tracking via Riverpod
✅ **Status Indicators**: Visual icons and colors for all upload states
✅ **User Actions**: Cancel, retry, resume, and pause controls
✅ **Error Display**: Clear error messages with retry options
✅ **Media Type Icons**: Photo and video indicators
✅ **File Information**: File name, size, and progress percentage
✅ **Callbacks**: Event handlers for completion, failure, and cancellation
✅ **Customizable**: Flexible configuration options
✅ **Material Design 3**: Full theme integration

## Installation

No additional dependencies required - uses existing project dependencies:
- `flutter_riverpod: ^2.5.1` - State management
- `flutter` - UI framework

## Quick Start

### Basic Usage

```dart
import 'package:soloadventurer/features/journal/presentation/widgets/media_upload_progress_indicator.dart';

// Display progress for a single upload task
MediaUploadProgressIndicator(
  taskId: 'upload-task-123',
)
```

### With Configuration

```dart
MediaUploadProgressIndicator(
  taskId: 'upload-task-123',
  config: UploadProgressConfig(
    showFileName: true,
    showFileSize: true,
    showMediaType: true,
    showActions: true,
    showErrors: true,
    displayMode: UploadProgressDisplayMode.detailed,
    progressHeight: 4.0,
    borderRadius: 8.0,
  ),
)
```

### With Callbacks

```dart
MediaUploadProgressIndicator(
  taskId: 'upload-task-123',
  onUploadComplete: () {
    print('Upload completed!');
    // Navigate away, show success message, etc.
  },
  onUploadFailed: (errorMessage) {
    print('Upload failed: $errorMessage');
    // Show error dialog, offer retry, etc.
  },
  onUploadCancelled: () {
    print('Upload was cancelled');
    // Update UI, clean up resources, etc.
  },
)
```

## Display Modes

### 1. Detailed Mode

Full-featured display with all information:

```dart
MediaUploadProgressIndicator(
  taskId: 'task-123',
  config: UploadProgressConfig(
    displayMode: UploadProgressDisplayMode.detailed,
  ),
)
```

**Features:**
- Media type icon
- File name
- File size
- Status text
- Progress bar with percentage
- Action buttons (cancel/retry)
- Error messages

**Best for:** Full-page upload views, detailed task inspection

### 2. Compact Mode

Smaller footprint for tight spaces:

```dart
MediaUploadProgressIndicator(
  taskId: 'task-123',
  config: UploadProgressConfig.compact(),
)
```

**Features:**
- Media type icon
- File name
- Status text
- Minimal action buttons
- No error messages (saves space)

**Best for:** List items, cards, constrained layouts

### 3. Minimal Mode

Just the progress bar:

```dart
MediaUploadProgressIndicator(
  taskId: 'task-123',
  config: UploadProgressConfig.minimal(),
)
```

**Features:**
- Progress bar only
- Percentage display
- Status-based coloring

**Best for:** Inline indicators, background uploads, minimal UI

## Configuration Options

### UploadProgressConfig

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `showFileName` | bool | true | Display the file name |
| `showFileSize` | bool | true | Display file size |
| `showMediaType` | bool | true | Show media type icon |
| `showActions` | bool | true | Show action buttons |
| `showErrors` | bool | true | Display error messages |
| `displayMode` | DisplayMode | detailed | How to display the indicator |
| `progressHeight` | double | 4.0 | Height of progress bar |
| `animateProgress` | bool | true | Animate progress changes |
| `borderRadius` | double | 8.0 | Corner radius for cards |

### Predefined Configs

```dart
// Detailed (default)
UploadProgressConfig()

// Compact
UploadProgressConfig.compact()

// Minimal
UploadProgressConfig.minimal()
```

## Upload States

The indicator displays different UI based on the upload state:

| State | Icon | Color | Actions |
|-------|------|-------|---------|
| **Queued** | Schedule | Gray | Cancel |
| **Uploading** | Cloud Upload | Primary | Cancel |
| **Completed** | Check Circle | Green | None |
| **Failed** | Error | Red | Retry |
| **Permanent Failure** | Error | Red | Retry |
| **Paused** | Pause Circle | Orange | Resume |
| **Cancelled** | Cancel | Gray | None |

## Usage Patterns

### Pattern 1: Single Upload Monitoring

Track progress of a single upload:

```dart
class MyWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<MyWidget> {
  String? _taskId;

  Future<void> _startUpload() async {
    final file = File('/path/to/photo.jpg');

    final task = await ref.read(mediaUploadNotifierProvider.notifier).enqueueUpload(
      filePath: file.path,
      mediaType: MediaType.photo,
    );

    setState(() {
      _taskId = task.id;
    });

    // Start the upload
    await ref.read(mediaUploadNotifierProvider.notifier).startUploads();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _startUpload,
          child: Text('Upload Photo'),
        ),
        if (_taskId != null)
          MediaUploadProgressIndicator(
            taskId: _taskId!,
          ),
      ],
    );
  }
}
```

### Pattern 2: Multiple Uploads in List

Display multiple uploads in a scrollable list:

```dart
class UploadQueueScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(uploadTasksProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Upload Queue')),
      body: tasksAsync.when(
        data: (tasks) => ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return UploadTaskTile(
              task: tasks[index],
              onTap: () => _showTaskDetails(tasks[index]),
            );
          },
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
```

### Pattern 3: Journal Entry Integration

Monitor uploads while creating/editing a journal entry:

```dart
class CreateJournalEntryScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CreateJournalEntryScreen> createState() =>
      _CreateJournalEntryScreenState();
}

class _CreateJournalEntryScreenState
    extends ConsumerState<CreateJournalEntryScreen> {
  final List<String> _uploadTaskIds = [];

  Future<void> _addMedia() async {
    // Pick media files
    final files = await MediaPicker().pickMedia();

    // Enqueue uploads
    for (final file in files) {
      final task = await ref
          .read(mediaUploadNotifierProvider.notifier)
          .enqueueUpload(
            filePath: file.path,
            mediaType: file.mediaType,
          );

      setState(() {
        _uploadTaskIds.add(task.id);
      });
    }

    // Start uploads
    await ref.read(mediaUploadNotifierProvider.notifier).startUploads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Entry'),
        actions: [
          if (_uploadTaskIds.isNotEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Chip(
                  label: Text('${_uploadTaskIds.length} uploading'),
                  avatar: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Entry form fields...
          Expanded(child: JournalEntryForm()),

          // Upload progress indicators
          if (_uploadTaskIds.isNotEmpty)
            Container(
              constraints: BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _uploadTaskIds.length,
                itemBuilder: (context, index) {
                  return MediaUploadProgressIndicator(
                    key: ValueKey(_uploadTaskIds[index]),
                    taskId: _uploadTaskIds[index],
                    config: UploadProgressConfig.compact(),
                    onUploadComplete: () {
                      // Could enable save button when all uploads complete
                    },
                  );
                },
              ),
            ),

          // Add media button
          FloatingActionButton(
            onPressed: _addMedia,
            child: Icon(Icons.add_photo_alternate),
          ),
        ],
      ),
    );
  }
}
```

### Pattern 4: Inline Progress in Card

Show upload progress directly in a media card:

```dart
class MediaCard extends ConsumerWidget {
  final String taskId;

  const MediaCard({required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        children: [
          // Thumbnail or placeholder
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.grey[300],
              child: Icon(Icons.photo, size: 64),
            ),
          ),

          // Minimal progress indicator
          Padding(
            padding: EdgeInsets.all(8),
            child: MediaUploadProgressIndicator(
              taskId: taskId,
              config: UploadProgressConfig.minimal(),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Pattern 5: Background Upload Monitoring

Track background uploads from any screen:

```dart
class PersistentUploadIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(uploadStatisticsProvider);

    return statsAsync.when(
      data: (stats) {
        if (stats.activeUploads == 0) {
          return SizedBox.shrink();
        }

        return Positioned(
          bottom: 16,
          right: 16,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      value: stats.overallProgress,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('${stats.activeUploads} uploading'),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => SizedBox.shrink(),
      error: (_, __) => SizedBox.shrink(),
    );
  }
}
```

## Advanced Usage

### Custom Styling

Customize the appearance through theme configuration:

```dart
// In your app theme
ThemeData(
  // The indicator uses these theme colors:
  colorScheme: ColorScheme(
    primary: Colors.blue,      // Active uploads
    error: Colors.red,         // Failed uploads
    tertiary: Colors.orange,   // Paused uploads
    outline: Colors.grey,      // Queued/uploads
    // ... other colors
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: Colors.blue,
    linearTrackColor: Colors.grey[300],
  ),
)
```

### Conditional Display

Show the indicator only when uploads are active:

```dart
class ConditionalProgressIndicator extends ConsumerWidget {
  final String taskId;

  const ConditionalProgressIndicator({required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(uploadTaskProvider(taskId));

    return taskAsync.when(
      data: (task) {
        // Only show if upload is not complete
        if (task?.status == UploadStatus.completed) {
          return SizedBox.shrink();
        }

        return MediaUploadProgressIndicator(taskId: taskId);
      },
      loading: () => CircularProgressIndicator(),
      error: (_, __) => SizedBox.shrink(),
    );
  }
}
```

### Upload Task Tile

Use the `UploadTaskTile` widget for list displays:

```dart
ListView.builder(
  itemCount: tasks.length,
  itemBuilder: (context, index) {
    return UploadTaskTile(
      task: tasks[index],
      config: UploadProgressConfig.compact(),
      onTap: () {
        // Navigate to task details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailScreen(taskId: tasks[index].id),
          ),
        );
      },
    );
  },
)
```

## API Reference

### MediaUploadProgressIndicator

#### Constructor

```dart
MediaUploadProgressIndicator({
  Key? key,
  required String? taskId,                    // Upload task ID to monitor
  UploadProgressConfig config,                 // Display configuration
  VoidCallback? onUploadComplete,              // Called when upload completes
  ValueChanged<String?>? onUploadFailed,       // Called when upload fails
  VoidCallback? onUploadCancelled,             // Called when upload is cancelled
})
```

#### Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `taskId` | String? | Yes | ID of the upload task to monitor |
| `config` | UploadProgressConfig | No | Display configuration (defaults to detailed) |
| `onUploadComplete` | VoidCallback | No | Callback when upload completes successfully |
| `onUploadFailed` | ValueChanged<String?> | No | Callback when upload fails (includes error message) |
| `onUploadCancelled` | VoidCallback | No | Callback when upload is cancelled |

### UploadTaskTile

#### Constructor

```dart
UploadTaskTile({
  Key? key,
  required UploadTask task,                    // Upload task to display
  UploadProgressConfig config,                 // Display configuration
  VoidCallback? onTap,                         // Callback when tile is tapped
})
```

#### Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `task` | UploadTask | Yes | The upload task to display |
| `config` | UploadProgressConfig | No | Display configuration (defaults to compact) |
| `onTap` | VoidCallback | No | Callback when the tile is tapped |

## Integration with Existing Components

### MediaPicker Integration

```dart
final files = await MediaPicker().pickMedia();

for (final file in files) {
  final task = await ref
      .read(mediaUploadNotifierProvider.notifier)
      .enqueueUpload(
        filePath: file.path,
        mediaType: file.mediaType,
      );

  // Display progress
  showUploadProgress(task.id);
}
```

### Journal Entry Creation

```dart
// In CreateJournalEntryScreen
Future<void> _attachMedia() async {
  final files = await MediaPicker().pickMedia();

  for (final file in files) {
    final task = await ref
        .read(mediaUploadNotifierProvider.notifier)
        .enqueueUpload(
          filePath: file.path,
          mediaType: file.mediaType,
          journalEntryId: widget.entryId, // Associate with entry
        );

    setState(() {
      _uploadTaskIds.add(task.id);
    });
  }
}
```

### Background Uploads

```dart
// Initialize background uploads
@override
void initState() {
  super.initState();

  // Start processing any queued uploads
  Future.microtask(() {
    ref.read(mediaUploadNotifierProvider.notifier).startUploads();
  });
}
```

## Best Practices

### 1. Memory Management

```dart
@override
void dispose() {
  // Clean up streams if needed
  super.dispose();
}
```

### 2. Error Handling

```dart
MediaUploadProgressIndicator(
  taskId: taskId,
  onUploadFailed: (errorMessage) {
    // Show user-friendly error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Upload failed. Please try again.'),
        action: SnackBarAction(
          label: 'RETRY',
          onPressed: () => retryUpload(taskId),
        ),
      ),
    );
  },
)
```

### 3. Upload Completion

```dart
MediaUploadProgressIndicator(
  taskId: taskId,
  onUploadComplete: () {
    // Refresh UI to show uploaded media
    ref.invalidate(journalEntryProvider);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Photo uploaded successfully!')),
    );
  },
)
```

### 4. Batch Uploads

```dart
Future<void> _uploadMultiplePhotos(List<File> photos) async {
  final tasks = await Future.wait(
    photos.map((photo) =>
        ref.read(mediaUploadNotifierProvider.notifier).enqueueUpload(
              filePath: photo.path,
              mediaType: MediaType.photo,
            )),
  );

  // Start all uploads
  await ref.read(mediaUploadNotifierProvider.notifier).startUploads();

  // Track all task IDs
  setState(() {
    _uploadTaskIds.addAll(tasks.map((t) => t.id));
  });
}
```

## Troubleshooting

### Progress Not Updating

**Problem**: Progress bar doesn't move or update.

**Solutions**:
1. Verify the task ID is correct
2. Ensure `uploadTaskProgressProvider` is being watched
3. Check that the upload service is initialized
4. Confirm `startUploads()` was called

```dart
// Ensure service is initialized
await ref.read(mediaUploadNotifierProvider.notifier).initialize();

// Start the uploads
await ref.read(mediaUploadNotifierProvider.notifier).startUploads();
```

### Upload Stuck in Queued State

**Problem**: Upload remains in "queued" status.

**Solutions**:
1. Check network connectivity
2. Verify Supabase authentication
3. Ensure `startUploads()` was called
4. Check for maximum concurrent uploads limit

```dart
final service = ref.read(mediaUploadServiceProvider);
final stats = await service.getStatistics();
print('Active uploads: ${stats.activeUploads}');
print('Max concurrent: ${service.config.maxConcurrentUploads}');
```

### Widget Not Rebuilding

**Problem**: Widget doesn't update when upload state changes.

**Solutions**:
1. Ensure you're using `watch` instead of `read` for providers
2. Verify the task ID is not changing unnecessarily
3. Check that the widget is still in the tree

```dart
// Correct - using watch
final taskStream = ref.watch(uploadTaskProgressProvider(taskId));

// Incorrect - using read (won't rebuild)
final taskStream = ref.read(uploadTaskProgressProvider(taskId));
```

## Testing

### Unit Tests

```dart
testWidgets('MediaUploadProgressIndicator displays progress',
    (WidgetTester tester) async {
  // Build widget
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        uploadTaskProgressProvider('test-id')
            .overrideWith((ref) => Stream.value(mockTask)),
      ],
      child: MaterialApp(
        home: MediaUploadProgressIndicator(taskId: 'test-id'),
      ),
    ),
  );

  // Verify progress is displayed
  expect(find.text('50%'), findsOneWidget);
});
```

### Mock Data

```dart
final mockTask = UploadTask(
  id: 'test-123',
  filePath: '/path/to/photo.jpg',
  mediaType: MediaType.photo,
  status: UploadStatus.uploading,
  progress: 50,
  fileSize: 1024 * 1024,
  createdAt: DateTime.now(),
);
```

## Related Components

- **MediaUploadService**: Background upload queue management
- **MediaPicker**: File selection component
- **MediaCompression**: Image/video compression utilities
- **JournalRepository**: Database operations for journal entries

## Future Enhancements

Potential improvements for future versions:

- [ ] Thumbnail preview during upload
- [ ] Upload speed indicator (bytes/sec)
- [ ] Estimated time remaining
- [ ] Drag-and-drop reordering for upload queue
- [ ] Batch action buttons (cancel all, retry all)
- [ ] Upload history view
- [ ] WiFi-only upload toggle
- [ ] Upload scheduling
- [ ] Advanced retry configuration
- [ ] Upload analytics and statistics

## Contributing

When contributing to this component:

1. Follow existing code patterns and style
2. Update this README with any new features
3. Add examples to the example file
4. Ensure all display modes work correctly
5. Test with various upload states
6. Verify Material Design 3 compliance

## License

This component is part of the SoloAdventurer project.
