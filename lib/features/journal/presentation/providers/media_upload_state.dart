part of 'media_upload_providers.dart';

/// State for media upload operations
class MediaUploadState {
  /// Whether the service is initialized
  final bool isInitialized;

  /// Current upload tasks
  final List<UploadTask> tasks;

  /// Whether uploads are currently active
  final bool isUploading;

  /// Error message if any
  final String? error;

  const MediaUploadState({
    this.isInitialized = false,
    this.tasks = const [],
    this.isUploading = false,
    this.error,
  });

  /// Copy with method
  MediaUploadState copyWith({
    bool? isInitialized,
    List<UploadTask>? tasks,
    bool? isUploading,
    String? error,
  }) {
    return MediaUploadState(
      isInitialized: isInitialized ?? this.isInitialized,
      tasks: tasks ?? this.tasks,
      isUploading: isUploading ?? this.isUploading,
      error: error,
    );
  }

  /// Initial state
  const MediaUploadState.initial()
      : isInitialized = false,
        tasks = const [],
        isUploading = false,
        error = null;
}
