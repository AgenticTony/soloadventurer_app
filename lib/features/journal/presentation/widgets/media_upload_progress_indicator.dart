import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/data/models/upload_task.dart';
import '../providers/media_upload_providers.dart';
import '../../domain/entities/media_item.dart';

/// Configuration for how the upload progress indicator is displayed
class UploadProgressConfig {
  /// Whether to show the file name
  final bool showFileName;

  /// Whether to show the file size
  final bool showFileSize;

  /// Whether to show the media type icon
  final bool showMediaType;

  /// Whether to show action buttons (cancel, retry, etc.)
  final bool showActions;

  /// Whether to show error messages
  final bool showErrors;

  /// Display mode for the indicator
  final UploadProgressDisplayMode displayMode;

  /// Height of the progress bar
  final double progressHeight;

  /// Whether to animate the progress bar
  final bool animateProgress;

  /// Border radius for rounded corners
  final double borderRadius;

  const UploadProgressConfig({
    this.showFileName = true,
    this.showFileSize = true,
    this.showMediaType = true,
    this.showActions = true,
    this.showErrors = true,
    this.displayMode = UploadProgressDisplayMode.detailed,
    this.progressHeight = 4.0,
    this.animateProgress = true,
    this.borderRadius = 8.0,
  });

  /// Compact configuration for tight spaces
  const UploadProgressConfig.compact({
    this.showFileName = true,
    this.showFileSize = false,
    this.showMediaType = false,
    this.showActions = true,
    this.showErrors = false,
    this.displayMode = UploadProgressDisplayMode.compact,
    this.progressHeight = 3.0,
    this.animateProgress = true,
    this.borderRadius = 4.0,
  });

  /// Minimal configuration for inline display
  const UploadProgressConfig.minimal({
    this.showFileName = false,
    this.showFileSize = false,
    this.showMediaType = false,
    this.showActions = false,
    this.showErrors = false,
    this.displayMode = UploadProgressDisplayMode.minimal,
    this.progressHeight = 2.0,
    this.animateProgress = true,
    this.borderRadius = 2.0,
  });
}

/// Display modes for the upload progress indicator
enum UploadProgressDisplayMode {
  /// Detailed view with all information
  detailed,

  /// Compact view for tight spaces
  compact,

  /// Minimal view with just the progress bar
  minimal,
}

/// A widget that displays upload progress for media items.
///
/// This widget shows real-time progress updates for media uploads
/// with visual indicators for different states (queued, uploading,
/// completed, failed, etc.).
///
/// Example usage:
/// ```dart
/// MediaUploadProgressIndicator(
///   taskId: 'upload-task-123',
///   config: UploadProgressConfig.detailed(),
/// )
/// ```
///
/// For displaying multiple tasks:
/// ```dart
/// MediaUploadProgressIndicator.queue(
///   entryId: 'journal-entry-456',
///   config: UploadProgressConfig.compact(),
/// )
/// ```
class MediaUploadProgressIndicator extends ConsumerStatefulWidget {
  /// The ID of the upload task to display
  final String? taskId;

  /// Configuration for how to display the progress
  final UploadProgressConfig config;

  /// Callback when upload completes successfully
  final VoidCallback? onUploadComplete;

  /// Callback when upload fails
  final ValueChanged<String?>? onUploadFailed;

  /// Callback when upload is cancelled
  final VoidCallback? onUploadCancelled;

  const MediaUploadProgressIndicator({
    super.key,
    this.taskId,
    this.config = const UploadProgressConfig(),
    this.onUploadComplete,
    this.onUploadFailed,
    this.onUploadCancelled,
  });

  /// Create a progress indicator for all tasks in a journal entry
  const MediaUploadProgressIndicator.queue({
    super.key,
    required String entryId,
    UploadProgressConfig config = const UploadProgressConfig(),
    this.onUploadComplete,
    this.onUploadFailed,
    this.onUploadCancelled,
  })  : taskId = entryId,
        config = config;

  @override
  ConsumerState<MediaUploadProgressIndicator> createState() =>
      _MediaUploadProgressIndicatorState();
}

class _MediaUploadProgressIndicatorState
    extends ConsumerState<MediaUploadProgressIndicator> {
  UploadTask? _previousTask;

  @override
  Widget build(BuildContext context) {
    // If no taskId provided, return empty widget
    if (widget.taskId == null) {
      return const SizedBox.shrink();
    }

    // Watch the task progress stream
    final taskStream =
        widget.config.displayMode == UploadProgressDisplayMode.minimal
            ? ref.watch(uploadTaskProgressProvider(widget.taskId!))
            : ref.watch(uploadTaskProgressProvider(widget.taskId!));

    return taskStream.when(
      data: (task) {
        // Check for status changes and trigger callbacks
        _checkStatusChanges(task);

        // Build appropriate UI based on display mode
        switch (widget.config.displayMode) {
          case UploadProgressDisplayMode.detailed:
            return _buildDetailedIndicator(context, task);
          case UploadProgressDisplayMode.compact:
            return _buildCompactIndicator(context, task);
          case UploadProgressDisplayMode.minimal:
            return _buildMinimalIndicator(context, task);
        }
      },
      loading: () => _buildLoadingIndicator(context),
      error: (_, __) => _buildErrorIndicator(context),
    );
  }

  void _checkStatusChanges(UploadTask task) {
    if (_previousTask != null) {
      // Check for completion
      if (_previousTask!.status != UploadStatus.completed &&
          task.status == UploadStatus.completed) {
        widget.onUploadComplete?.call();
      }

      // Check for failure
      if (_previousTask!.status != UploadStatus.failed &&
          task.status != UploadStatus.permanentFailure &&
          (task.status == UploadStatus.failed ||
              task.status == UploadStatus.permanentFailure)) {
        widget.onUploadFailed?.call(task.errorMessage);
      }

      // Check for cancellation
      if (_previousTask!.status != UploadStatus.cancelled &&
          task.status == UploadStatus.cancelled) {
        widget.onUploadCancelled?.call();
      }
    }
    _previousTask = task;
  }

  Widget _buildDetailedIndicator(BuildContext context, UploadTask task) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.config.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with icon and title
            Row(
              children: [
                if (widget.config.showMediaType) ...[
                  _buildMediaTypeIcon(task.mediaType, colorScheme),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.config.showFileName)
                        Text(
                          _getFileName(task.filePath),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (widget.config.showFileSize) ...[
                        const SizedBox(height: 2),
                        Text(
                          _formatFileSize(task.fileSize),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildStatusIcon(task.status, colorScheme),
              ],
            ),

            const SizedBox(height: 12),

            // Progress bar
            _buildProgressBar(task, colorScheme),

            const SizedBox(height: 8),

            // Status row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusText(task, theme, colorScheme),
                if (widget.config.showActions && _canShowActions(task.status))
                  _buildActionButton(task, colorScheme),
              ],
            ),

            // Error message
            if (widget.config.showErrors &&
                task.errorMessage != null &&
                (task.status == UploadStatus.failed ||
                    task.status == UploadStatus.permanentFailure)) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactIndicator(BuildContext context, UploadTask task) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(widget.config.borderRadius),
      ),
      child: Row(
        children: [
          if (widget.config.showMediaType)
            _buildMediaTypeIcon(task.mediaType, colorScheme),
          if (widget.config.showFileName) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getFileName(task.filePath),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  _buildStatusText(task, theme, colorScheme),
                ],
              ),
            ),
          ],
          const SizedBox(width: 12),
          if (widget.config.showActions && _canShowActions(task.status))
            _buildActionButton(task, colorScheme),
        ],
      ),
    );
  }

  Widget _buildMinimalIndicator(BuildContext context, UploadTask task) {
    final colorScheme = Theme.of(context).colorScheme;

    return _buildProgressBar(task, colorScheme);
  }

  Widget _buildProgressBar(UploadTask task, ColorScheme colorScheme) {
    final progress = task.progress / 100.0;
    final backgroundColor = colorScheme.surfaceContainerHighest;

    Color getProgressColor() {
      switch (task.status) {
        case UploadStatus.completed:
          return colorScheme.primary;
        case UploadStatus.failed:
        case UploadStatus.permanentFailure:
          return colorScheme.error;
        case UploadStatus.paused:
          return colorScheme.tertiary;
        default:
          return colorScheme.primary;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: task.status == UploadStatus.queued ? null : progress,
          backgroundColor: backgroundColor,
          valueColor: AlwaysStoppedAnimation<Color>(getProgressColor()),
          minHeight: widget.config.progressHeight,
          borderRadius: BorderRadius.circular(widget.config.progressHeight / 2),
        ),
        if (task.status == UploadStatus.uploading ||
            task.status == UploadStatus.completed) ...[
          const SizedBox(height: 4),
          Text(
            '${task.progress}%',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMediaTypeIcon(MediaType mediaType, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        mediaType == MediaType.photo ? Icons.photo_library : Icons.videocam,
        color: colorScheme.onPrimaryContainer,
        size: 24,
      ),
    );
  }

  Widget _buildStatusIcon(UploadStatus status, ColorScheme colorScheme) {
    IconData icon;
    Color color;

    switch (status) {
      case UploadStatus.completed:
        icon = Icons.check_circle;
        color = colorScheme.primary;
        break;
      case UploadStatus.failed:
      case UploadStatus.permanentFailure:
        icon = Icons.error;
        color = colorScheme.error;
        break;
      case UploadStatus.paused:
        icon = Icons.pause_circle;
        color = colorScheme.tertiary;
        break;
      case UploadStatus.cancelled:
        icon = Icons.cancel;
        color = colorScheme.outline;
        break;
      case UploadStatus.queued:
        icon = Icons.schedule;
        color = colorScheme.outline;
        break;
      case UploadStatus.uploading:
        icon = Icons.cloud_upload;
        color = colorScheme.primary;
        break;
    }

    return Icon(icon, color: color, size: 24);
  }

  Widget _buildStatusText(
    UploadTask task,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    String text;
    Color? color;

    switch (task.status) {
      case UploadStatus.queued:
        text = 'Queued';
        color = colorScheme.outline;
        break;
      case UploadStatus.uploading:
        text = 'Uploading ${task.progress}%';
        color = colorScheme.primary;
        break;
      case UploadStatus.completed:
        text = 'Completed';
        color = colorScheme.primary;
        break;
      case UploadStatus.failed:
        text = 'Failed (Retry ${task.retryCount}/${task.maxRetries})';
        color = colorScheme.error;
        break;
      case UploadStatus.permanentFailure:
        text = 'Failed permanently';
        color = colorScheme.error;
        break;
      case UploadStatus.paused:
        text = 'Paused';
        color = colorScheme.tertiary;
        break;
      case UploadStatus.cancelled:
        text = 'Cancelled';
        color = colorScheme.outline;
        break;
    }

    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(color: color),
    );
  }

  Widget? _buildActionButton(UploadTask task, ColorScheme colorScheme) {
    if (task.status == UploadStatus.uploading ||
        task.status == UploadStatus.queued) {
      return IconButton(
        icon: const Icon(Icons.close),
        color: colorScheme.error,
        onPressed: () {
          ref.read(mediaUploadNotifierProvider.notifier).cancelUpload(task.id);
        },
        tooltip: 'Cancel upload',
      );
    }

    if (task.status == UploadStatus.failed ||
        task.status == UploadStatus.permanentFailure) {
      return IconButton(
        icon: const Icon(Icons.refresh),
        color: colorScheme.primary,
        onPressed: () {
          ref.read(mediaUploadNotifierProvider.notifier).retryUpload(task.id);
        },
        tooltip: 'Retry upload',
      );
    }

    if (task.status == UploadStatus.paused) {
      return IconButton(
        icon: const Icon(Icons.play_arrow),
        color: colorScheme.primary,
        onPressed: () {
          ref.read(mediaUploadNotifierProvider.notifier).resumeUploads();
        },
        tooltip: 'Resume upload',
      );
    }

    return null;
  }

  bool _canShowActions(UploadStatus status) {
    return status == UploadStatus.uploading ||
        status == UploadStatus.queued ||
        status == UploadStatus.failed ||
        status == UploadStatus.permanentFailure ||
        status == UploadStatus.paused;
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorIndicator(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Unable to load upload status',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }

  String _getFileName(String filePath) {
    return filePath.split('/').last;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
}

/// A tile widget for displaying an upload task in a list
class UploadTaskTile extends ConsumerWidget {
  /// The upload task to display
  final UploadTask task;

  /// Configuration for display
  final UploadProgressConfig config;

  /// Callback when tile is tapped
  final VoidCallback? onTap;

  const UploadTaskTile({
    super.key,
    required this.task,
    this.config = const UploadProgressConfig.compact(),
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Media type icon
              _buildMediaTypeIcon(task.mediaType, colorScheme),
              const SizedBox(width: 12),

              // Task details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getFileName(task.filePath),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _formatFileSize(task.fileSize),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusText(task, theme, colorScheme),
                      ],
                    ),
                    if (task.status == UploadStatus.uploading ||
                        task.status == UploadStatus.queued) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: task.status == UploadStatus.queued
                            ? null
                            : task.progress / 100.0,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        minHeight: 3,
                      ),
                    ],
                  ],
                ),
              ),

              // Status icon
              const SizedBox(width: 8),
              _buildStatusIcon(task.status, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaTypeIcon(MediaType mediaType, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        mediaType == MediaType.photo ? Icons.photo_library : Icons.videocam,
        color: colorScheme.onPrimaryContainer,
        size: 20,
      ),
    );
  }

  Widget _buildStatusIcon(UploadStatus status, ColorScheme colorScheme) {
    IconData icon;
    Color color;

    switch (status) {
      case UploadStatus.completed:
        icon = Icons.check_circle;
        color = colorScheme.primary;
        break;
      case UploadStatus.failed:
      case UploadStatus.permanentFailure:
        icon = Icons.error;
        color = colorScheme.error;
        break;
      case UploadStatus.paused:
        icon = Icons.pause_circle;
        color = colorScheme.tertiary;
        break;
      case UploadStatus.cancelled:
        icon = Icons.cancel;
        color = colorScheme.outline;
        break;
      case UploadStatus.queued:
        icon = Icons.schedule;
        color = colorScheme.outline;
        break;
      case UploadStatus.uploading:
        icon = Icons.cloud_upload;
        color = colorScheme.primary;
        break;
    }

    return Icon(icon, color: color, size: 24);
  }

  Widget _buildStatusText(
    UploadTask task,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    String text;
    Color? color;

    switch (task.status) {
      case UploadStatus.queued:
        text = 'Queued';
        color = colorScheme.outline;
        break;
      case UploadStatus.uploading:
        text = '${task.progress}%';
        color = colorScheme.primary;
        break;
      case UploadStatus.completed:
        text = 'Done';
        color = colorScheme.primary;
        break;
      case UploadStatus.failed:
        text = 'Retry ${task.retryCount}/${task.maxRetries}';
        color = colorScheme.error;
        break;
      case UploadStatus.permanentFailure:
        text = 'Failed';
        color = colorScheme.error;
        break;
      case UploadStatus.paused:
        text = 'Paused';
        color = colorScheme.tertiary;
        break;
      case UploadStatus.cancelled:
        text = 'Cancelled';
        color = colorScheme.outline;
        break;
    }

    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(color: color),
    );
  }

  String _getFileName(String filePath) {
    return filePath.split('/').last;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
}
