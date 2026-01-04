import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/media_upload_progress_indicator.dart';
import 'package:soloadventurer/features/journal/presentation/providers/media_upload_providers.dart';
import 'package:soloadventurer/features/journal/domain/entities/media_item.dart';

/// Example screen demonstrating the MediaUploadProgressIndicator widget
class MediaUploadProgressExampleScreen extends ConsumerStatefulWidget {
  const MediaUploadProgressExampleScreen({super.key});

  @override
  ConsumerState<MediaUploadProgressExampleScreen> createState() =>
      _MediaUploadProgressExampleScreenState();
}

class _MediaUploadProgressExampleScreenState
    extends ConsumerState<MediaUploadProgressExampleScreen> {
  String? _selectedTaskId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Progress Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Example 1: Detailed single task indicator
          _buildSection(
            'Detailed Progress Indicator',
            'Shows all information about a single upload task',
            _buildDetailedExample(),
          ),

          const SizedBox(height: 24),

          // Example 2: Compact progress indicator
          _buildSection(
            'Compact Progress Indicator',
            'Smaller view for tight spaces',
            _buildCompactExample(),
          ),

          const SizedBox(height: 24),

          // Example 3: Minimal progress indicator
          _buildSection(
            'Minimal Progress Indicator',
            'Just the progress bar, perfect for inline display',
            _buildMinimalExample(),
          ),

          const SizedBox(height: 24),

          // Example 4: Queue progress for journal entry
          _buildSection(
            'Queue Progress',
            'Monitor all uploads for a journal entry',
            _buildQueueExample(),
          ),

          const SizedBox(height: 24),

          // Example 5: Task list
          _buildSection(
            'Upload Task List',
            'List view of all upload tasks',
            _buildTaskListExample(),
          ),

          const SizedBox(height: 24),

          // Example 6: With callbacks
          _buildSection(
            'With Callbacks',
            'Handle upload completion, failure, and cancellation',
            _buildCallbackExample(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String description, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildDetailedExample() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Single Task (Detailed)'),
            const SizedBox(height: 16),
            const MediaUploadProgressIndicator(
              taskId: 'example-task-1',
              config: UploadProgressConfig(
                showFileName: true,
                showFileSize: true,
                showMediaType: true,
                showActions: true,
                showErrors: true,
                displayMode: UploadProgressDisplayMode.detailed,
              ),
            ),
            const SizedBox(height: 16),
            _buildCreateTaskButton('Create Detailed Task'),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactExample() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Single Task (Compact)'),
            const SizedBox(height: 16),
            MediaUploadProgressIndicator(
              taskId: 'example-task-2',
              config: UploadProgressConfig.compact(),
            ),
            const SizedBox(height: 16),
            _buildCreateTaskButton('Create Compact Task'),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalExample() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Minimal Progress Bar'),
            const SizedBox(height: 16),
            const MediaUploadProgressIndicator(
              taskId: 'example-task-3',
              config: UploadProgressConfig.minimal(),
            ),
            const SizedBox(height: 16),
            _buildCreateTaskButton('Create Minimal Task'),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueExample() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('All Uploads for Entry'),
            const SizedBox(height: 8),
            Text(
              'Use this to monitor all uploads for a specific journal entry',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            // Note: This would use entryId instead of taskId
            const MediaUploadProgressIndicator(
              taskId: 'entry-123', // In real usage, this would be entryId
              config: UploadProgressConfig.compact(),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _simulateMultipleUploads(),
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Multiple Photos'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskListExample() {
    final tasksAsync = ref.watch(uploadTasksProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Queue (${tasksAsync.when(
                data: (tasks) => tasks.length.toString(),
                loading: () => '...',
                error: (_, __) => '?',
              )})',
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: tasksAsync.when(
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return const Center(
                      child: Text('No upload tasks'),
                    );
                  }
                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return UploadTaskTile(
                        task: tasks[index],
                        onTap: () {
                          setState(() {
                            _selectedTaskId = tasks[index].id;
                          });
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => Center(
                  child: Text('Error: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallbackExample() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('With Event Callbacks'),
            const SizedBox(height: 8),
            Text(
              'Demonstrates handling completion, failure, and cancellation events',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            MediaUploadProgressIndicator(
              taskId: 'example-task-callbacks',
              config: const UploadProgressConfig(
                showFileName: true,
                showFileSize: true,
                showActions: true,
                showErrors: true,
              ),
              onUploadComplete: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Upload completed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              onUploadFailed: (errorMessage) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Upload failed: $errorMessage'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              onUploadCancelled: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🚫 Upload was cancelled'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildCreateTaskButton('Create Task with Callbacks'),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateTaskButton(String label) {
    return ElevatedButton.icon(
      onPressed: () => _simulateSingleUpload(),
      icon: const Icon(Icons.upload_file),
      label: Text(label),
    );
  }

  Future<void> _simulateSingleUpload() async {
    // In a real app, you would:
    // 1. Pick a file using MediaPicker
    // 2. Enqueue the upload
    // 3. Get the task ID
    // 4. Use that task ID in the progress indicator

    // For this example, we'll just show a dialog
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Simulate Upload'),
          content: const Text(
            'In a real implementation, this would:\n\n'
            '1. Pick a file using MediaPicker\n'
            '2. Enqueue the upload with MediaUploadService\n'
            '3. Get the returned task ID\n'
            '4. Use the task ID in this widget',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _simulateMultipleUploads() async {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Simulate Multiple Uploads'),
          content: const Text(
            'In a real implementation, this would:\n\n'
            '1. Pick multiple files using MediaPicker\n'
            '2. Enqueue all uploads with the same journalEntryId\n'
            '3. Monitor all uploads using the entry ID',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

/// Example of integrating upload progress into journal entry creation
class JournalEntryWithUploadExample extends ConsumerStatefulWidget {
  const JournalEntryWithUploadExample({super.key});

  @override
  ConsumerState<JournalEntryWithUploadExample> createState() =>
      _JournalEntryWithUploadExampleState();
}

class _JournalEntryWithUploadExampleState
    extends ConsumerState<JournalEntryWithUploadExample> {
  final List<String> _uploadTaskIds = [];
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Journal Entry'),
        actions: [
          if (_uploadTaskIds.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Chip(
                  label: Text('${_uploadTaskIds.length} uploading'),
                  avatar: const CircularProgressIndicator(
                    strokeWidth: 2,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          IconButton(
            onPressed: _isSaving ? null : _saveEntry,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
          ),
        ],
      ),
      body: Column(
        children: [
          // Journal entry content fields would go here
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Write your journal entry...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              maxLines: null,
              expands: true,
            ),
          ),

          // Upload progress section
          if (_uploadTaskIds.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _uploadTaskIds.length,
                itemBuilder: (context, index) {
                  return MediaUploadProgressIndicator(
                    key: ValueKey(_uploadTaskIds[index]),
                    taskId: _uploadTaskIds[index],
                    config: UploadProgressConfig.compact(),
                    onUploadComplete: () {
                      // Could update UI to show completion
                      setState(() {
                        // Upload completed
                      });
                    },
                    onUploadFailed: (error) {
                      // Could show error notification
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Upload failed: $error')),
                      );
                    },
                  );
                },
              ),
            ),

          // Media picker button
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _pickAndUploadMedia,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Photos/Videos'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadMedia() async {
    // In a real implementation:
    // 1. Use MediaPicker to select files
    // 2. For each file, enqueue upload
    // 3. Collect task IDs
    // 4. Add to _uploadTaskIds list

    // Example:
    // final files = await MediaPicker.pickMedia();
    // for (final file in files) {
    //   final task = await ref
    //       .read(mediaUploadNotifierProvider.notifier)
    //       .enqueueUpload(
    //         filePath: file.path,
    //         mediaType: file.type,
    //       );
    //   setState(() {
    //     _uploadTaskIds.add(task.id);
    //   });
    // }
  }

  Future<void> _saveEntry() async {
    setState(() {
      _isSaving = true;
    });

    // Wait for uploads to complete (optional)
    // Or save entry and let uploads continue in background

    // In a real implementation:
    // 1. Create journal entry with media item references
    // 2. Update media items with entry ID
    // 3. Navigate away

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      Navigator.pop(context);
    }
  }
}

/// Main function to run examples
void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        home: MediaUploadProgressExampleScreen(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
