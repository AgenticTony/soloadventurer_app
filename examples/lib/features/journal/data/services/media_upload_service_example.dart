import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/media_upload_providers.dart';
import 'package:soloadventurer/utils/media_compression.dart';
import 'package:soloadventurer/features/journal/domain/entities/media_item.dart'; // For UploadStatus and MediaType

/// Example screen demonstrating media upload service usage
class MediaUploadExampleScreen extends ConsumerStatefulWidget {
  const MediaUploadExampleScreen({super.key});

  @override
  ConsumerState<MediaUploadExampleScreen> createState() =>
      _MediaUploadExampleScreenState();
}

class _MediaUploadExampleScreenState
    extends ConsumerState<MediaUploadExampleScreen> {
  @override
  void initState() {
    super.initState();
    _initializeUploadService();
  }

  Future<void> _initializeUploadService() async {
    // Service is automatically initialized when provider is first read
    ref.read(mediaUploadNotifierProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    final queueAsync = ref.watch(uploadQueueStatusProvider);
    final statsAsync = ref.watch(uploadStatisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Upload Example'),
      ),
      body: Column(
        children: [
          // Statistics Section
          _buildStatisticsSection(statsAsync),

          // Upload Queue Section
          Expanded(
            child: _buildQueueSection(queueAsync),
          ),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(AsyncValue<UploadStatistics> statsAsync) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: statsAsync.when(
        data: (stats) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Statistics',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text('Total Uploads: ${stats.totalUploads}'),
              Text('Successful: ${stats.successfulUploads}'),
              Text('Failed: ${stats.failedUploads}'),
              Text('Active: ${stats.activeUploads}'),
              Text(
                  'Success Rate: ${(stats.successRate * 100).toStringAsFixed(1)}%'),
              Text(
                  'Overall Progress: ${(stats.overallProgress * 100).toStringAsFixed(1)}%'),
              if (stats.totalBytesUploaded > 0)
                Text('Uploaded: ${_formatBytes(stats.totalBytesUploaded)}'),
            ],
          ),
        ),
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error: $err'),
        ),
      ),
    );
  }

  Widget _buildQueueSection(AsyncValue<List<UploadTask>> queueAsync) {
    return queueAsync.when(
      data: (queue) {
        if (queue.isEmpty) {
          return const Center(
            child: Text('No uploads in queue'),
          );
        }

        return ListView.builder(
          itemCount: queue.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final task = queue[index];
            return _buildTaskTile(task);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, stack) => Center(
        child: Text('Error: $err'),
      ),
    );
  }

  Widget _buildTaskTile(UploadTask task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _buildTaskIcon(task),
        title: Text(
          task.filePath.split('/').last,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${task.status.toValue()}'),
            Text('Size: ${_formatBytes(task.fileSize)}'),
            if (task.retryCount > 0)
              Text(
                'Retries: ${task.retryCount}/${task.maxRetries}',
                style: const TextStyle(color: Colors.orange),
              ),
            if (task.errorMessage != null)
              Text(
                task.errorMessage!,
                style: const TextStyle(color: Colors.red),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (task.status == UploadStatus.uploading ||
                task.status == UploadStatus.queued)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(
                  value: task.progress / 100,
                  backgroundColor: Colors.grey[200],
                ),
              ),
          ],
        ),
        trailing: _buildTaskActions(task),
      ),
    );
  }

  Widget? _buildTaskIcon(UploadTask task) {
    switch (task.status) {
      case UploadStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
      case UploadStatus.failed:
      case UploadStatus.permanentFailure:
        return const Icon(Icons.error, color: Colors.red);
      case UploadStatus.uploading:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case UploadStatus.paused:
        return const Icon(Icons.pause_circle, color: Colors.orange);
      case UploadStatus.cancelled:
        return const Icon(Icons.cancel, color: Colors.grey);
      case UploadStatus.queued:
        return const Icon(Icons.schedule, color: Colors.blue);
    }
    return null;
  }

  Widget? _buildTaskActions(UploadTask task) {
    final notifier = ref.read(mediaUploadNotifierProvider.notifier);

    switch (task.status) {
      case UploadStatus.queued:
      case UploadStatus.uploading:
        return IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: () => notifier.cancelUpload(task.id),
        );
      case UploadStatus.failed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => notifier.retryUpload(task.id),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => notifier.cancelUpload(task.id),
            ),
          ],
        );
      case UploadStatus.paused:
        return IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () => notifier.resumeUploads(),
        );
      default:
        return null;
    }
  }

  Widget _buildActionButtons() {
    final notifier = ref.read(mediaUploadNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () => _enqueueExampleUpload(),
            icon: const Icon(Icons.add),
            label: const Text('Enqueue Upload'),
          ),
          ElevatedButton.icon(
            onPressed: () => notifier.startUploads(),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Uploads'),
          ),
          ElevatedButton.icon(
            onPressed: () => notifier.pauseUploads(),
            icon: const Icon(Icons.pause),
            label: const Text('Pause'),
          ),
          ElevatedButton.icon(
            onPressed: () => notifier.resumeUploads(),
            icon: const Icon(Icons.play_circle),
            label: const Text('Resume'),
          ),
          ElevatedButton.icon(
            onPressed: () => notifier.clearCompleted(),
            icon: const Icon(Icons.cleaning_services),
            label: const Text('Clear Completed'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await notifier.clearAll();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Queue cleared')),
                );
              }
            },
            icon: const Icon(Icons.delete_sweep),
            label: const Text('Clear All'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enqueueExampleUpload() async {
    final notifier = ref.read(mediaUploadNotifierProvider.notifier);

    // Example: Simulate uploading a file
    // In a real app, you would get this from MediaPicker
    final exampleFile = File('/path/to/example/photo.jpg');

    // Check if file exists (just for demo)
    if (!await exampleFile.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Example file not found. Use MediaPicker to select real files.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      final task = await notifier.enqueueUpload(
        filePath: exampleFile.path,
        mediaType: MediaType.photo,
        journalEntryId: 'example-entry-123',
        priority: 1,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Enqueued upload: ${task.id}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error enqueuing upload: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Example of using media upload with MediaPicker
class MediaPickerUploadExample extends ConsumerWidget {
  const MediaPickerUploadExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        // In a real app, you would use the MediaPicker widget
        // For this example, we'll just show the code pattern

        /*
        final picker = MediaPicker(
          onMediaSelected: (files) async {
            final notifier = ref.read(mediaUploadNotifierProvider.notifier);

            // Enqueue all selected files
            for (final file in files) {
              await notifier.enqueueUpload(
                filePath: file.path,
                mediaType: file.type, // photo or video
                journalEntryId: 'entry-id',
              );
            }

            // Start uploads
            await notifier.startUploads();

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${files.length} files enqueued for upload')),
              );
            }
          },
        );

        // Show picker
        showModalBottomSheet(
          context: context,
          builder: (context) => picker,
        );
        */

        // For now, just show a message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Integrate with MediaPicker component'),
            ),
          );
        }
      },
      child: const Text('Pick and Upload Media'),
    );
  }
}

/// Example of monitoring a specific upload
class SingleUploadMonitorExample extends ConsumerStatefulWidget {
  final String taskId;

  const SingleUploadMonitorExample({super.key, required this.taskId});

  @override
  ConsumerState<SingleUploadMonitorExample> createState() =>
      _SingleUploadMonitorExampleState();
}

class _SingleUploadMonitorExampleState
    extends ConsumerState<SingleUploadMonitorExample> {
  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(uploadTaskProvider(widget.taskId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Monitor'),
      ),
      body: taskAsync.when(
        data: (task) {
          if (task == null) {
            return const Center(child: Text('Task not found'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Task ID: ${task.id}'),
                Text('Status: ${task.status.toValue()}'),
                Text('Progress: ${task.progress}%'),
                if (task.status == UploadStatus.uploading ||
                    task.status == UploadStatus.queued)
                  LinearProgressIndicator(value: task.progress / 100),
                if (task.errorMessage != null)
                  Text('Error: ${task.errorMessage}'),
                if (task.storagePath != null)
                  Text('Storage: ${task.storagePath}'),
                const SizedBox(height: 20),
                _buildTaskActions(task),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildTaskActions(UploadTask task) {
    final notifier = ref.read(mediaUploadNotifierProvider.notifier);

    if (task.status == UploadStatus.failed) {
      return ElevatedButton(
        onPressed: () => notifier.retryUpload(task.id),
        child: const Text('Retry Upload'),
      );
    }

    if (task.status == UploadStatus.uploading) {
      return ElevatedButton(
        onPressed: () => notifier.cancelUpload(task.id),
        child: const Text('Cancel Upload'),
      );
    }

    return const SizedBox.shrink();
  }
}

/// Example usage in a real journal entry creation flow
class JournalEntryUploadFlowExample extends ConsumerWidget {
  const JournalEntryUploadFlowExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final notifier = ref.read(mediaUploadNotifierProvider.notifier);

        // Assume user just created a journal entry and selected photos
        const entryId = 'new-entry-id';
        final selectedPhotos = [
          File('/path/to/photo1.jpg'),
          File('/path/to/photo2.jpg'),
        ];

        try {
          // Enqueue all photos
          for (final photo in selectedPhotos) {
            await notifier.enqueueUpload(
              filePath: photo.path,
              mediaType: MediaType.photo,
              journalEntryId: entryId,
              priority: 1,
            );
          }

          // Start uploading immediately
          await notifier.startUploads();

          if (context.mounted) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '${selectedPhotos.length} photos uploading in background'),
                action: SnackBarAction(
                  label: 'View',
                  onPressed: () {
                    // Navigate to upload queue screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MediaUploadExampleScreen(),
                      ),
                    );
                  },
                ),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error starting uploads: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: const Text('Create Entry with Photos'),
    );
  }
}
