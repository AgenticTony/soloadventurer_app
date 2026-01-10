import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:soloadventurer/features/journal/domain/entities/media_item.dart';
import 'package:soloadventurer/utils/media_compression.dart';
import 'package:soloadventurer/utils/video_compression.dart';

/// Result of picking media from the device
class PickedMediaFile {
  /// The file that was picked
  final File file;

  /// Type of media
  final MediaType mediaType;

  /// Original file name
  final String fileName;

  /// File size in bytes (compressed if compression enabled)
  final int fileSize;

  /// MIME type
  final String? mimeType;

  /// Width of media (if available)
  final int? width;

  /// Height of media (if available)
  final int? height;

  /// Duration for videos in seconds (if available)
  final int? duration;

  const PickedMediaFile({
    required this.file,
    required this.mediaType,
    required this.fileName,
    required this.fileSize,
    this.mimeType,
    this.width,
    this.height,
    this.duration,
  });

  /// Whether this file is a video
  bool get isVideo => mediaType == MediaType.video;

  /// Whether this file is a photo
  bool get isPhoto => mediaType == MediaType.photo;

  /// Format file size for display
  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  @override
  String toString() =>
      'PickedMediaFile($mediaType, $fileName, $formattedFileSize)';
}

/// Configuration for media picker behavior
class MediaPickerConfig {
  /// Maximum number of media items that can be selected
  final int? maxItems;

  /// Maximum file size in bytes (null = no limit)
  final int? maxFileSize;

  /// Whether to allow multiple selection
  final bool allowMultiple;

  /// Whether to compress images after picking
  final bool compressImages;

  /// Image compression configuration
  final ImageCompressionConfig? imageCompressionConfig;

  /// Whether to compress videos after picking
  final bool compressVideos;

  /// Video compression configuration
  final VideoCompressionConfig? videoCompressionConfig;

  /// Quality preset for compression
  final MediaQuality quality;

  const MediaPickerConfig({
    this.maxItems,
    this.maxFileSize = 100 * 1024 * 1024, // 100 MB default
    this.allowMultiple = true,
    this.compressImages = true,
    this.imageCompressionConfig,
    this.compressVideos = true,
    this.videoCompressionConfig,
    this.quality = MediaQuality.optimized,
  });

  /// Create configuration optimized for travel journal
  factory MediaPickerConfig.forTravelJournal() {
    return const MediaPickerConfig(
      maxItems: 20,
      maxFileSize: 100 * 1024 * 1024, // 100 MB
      allowMultiple: true,
      compressImages: true,
      imageCompressionConfig: ImageCompressionConfig.optimizedForTravel,
      compressVideos: true,
      videoCompressionConfig: VideoCompressionConfig.optimizedForTravel,
      quality: MediaQuality.optimized,
    );
  }

  /// Create configuration for high quality media
  factory MediaPickerConfig.highQuality() {
    return const MediaPickerConfig(
      maxItems: 10,
      maxFileSize: 200 * 1024 * 1024, // 200 MB
      allowMultiple: true,
      compressImages: true,
      imageCompressionConfig: ImageCompressionConfig.highQuality,
      compressVideos: true,
      videoCompressionConfig: VideoCompressionConfig.highQuality,
      quality: MediaQuality.high,
    );
  }

  /// Create configuration for minimal quality/size
  factory MediaPickerConfig.aggressive() {
    return const MediaPickerConfig(
      maxItems: 50,
      maxFileSize: 50 * 1024 * 1024, // 50 MB
      allowMultiple: true,
      compressImages: true,
      imageCompressionConfig: ImageCompressionConfig.aggressive,
      compressVideos: true,
      videoCompressionConfig: VideoCompressionConfig.aggressive,
      quality: MediaQuality.aggressive,
    );
  }
}

/// Quality presets for media compression
enum MediaQuality {
  /// Optimized for travel (good balance)
  optimized,

  /// High quality (minimal compression)
  high,

  /// Aggressive compression (smallest size)
  aggressive,
}

/// A media picker widget for selecting photos and videos
///
/// This widget provides a user-friendly interface for:
/// - Picking photos from gallery
/// - Taking photos with camera
/// - Picking videos from gallery
/// - Recording videos with camera
/// - Multiple media selection
/// - Automatic compression
class MediaPicker extends ConsumerStatefulWidget {
  /// Callback when media is picked
  final ValueChanged<List<PickedMediaFile>>? onMediaPicked;

  /// Configuration for picker behavior
  final MediaPickerConfig config;

  /// Whether to show as a button (true) or inline options (false)
  final bool showAsButton;

  /// Button text when showAsButton is true
  final String buttonText;

  /// Button icon when showAsButton is true
  final IconData? buttonIcon;

  /// Whether the picker is enabled
  final bool enabled;

  /// Custom button style
  final ButtonStyle? buttonStyle;

  const MediaPicker({
    super.key,
    this.onMediaPicked,
    this.config = const MediaPickerConfig.forTravelJournal(),
    this.showAsButton = true,
    this.buttonText = 'Add Media',
    this.buttonIcon,
    this.enabled = true,
    this.buttonStyle,
  });

  @override
  ConsumerState<MediaPicker> createState() => _MediaPickerState();
}

class _MediaPickerState extends ConsumerState<MediaPicker> {
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;
  bool _isCompressing = false;

  Future<void> _pickImageFromGallery() async {
    if (_isPicking) return;
    _setPicking(true);

    try {
      final List<XFile> files = await _picker.pickMultiImage(
        imageQuality: widget.config.compressImages ? 100 : null,
      );

      if (files.isNotEmpty) {
        await _processPickedFiles(files);
      }
    } catch (e) {
      _showError('Failed to pick images: $e');
    } finally {
      _setPicking(false);
    }
  }

  Future<void> _takePhoto() async {
    if (_isPicking) return;
    _setPicking(true);

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: widget.config.compressImages ? 100 : null,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        await _processPickedFiles([photo]);
      }
    } catch (e) {
      _showError('Failed to take photo: $e');
    } finally {
      _setPicking(false);
    }
  }

  Future<void> _pickVideoFromGallery() async {
    if (_isPicking) return;
    _setPicking(true);

    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (video != null) {
        await _processPickedFiles([video]);
      }
    } catch (e) {
      _showError('Failed to pick video: $e');
    } finally {
      _setPicking(false);
    }
  }

  Future<void> _recordVideo() async {
    if (_isPicking) return;
    _setPicking(true);

    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (video != null) {
        await _processPickedFiles([video]);
      }
    } catch (e) {
      _showError('Failed to record video: $e');
    } finally {
      _setPicking(false);
    }
  }

  Future<void> _processPickedFiles(List<XFile> files) async {
    if (files.isEmpty) return;

    // Check max items limit
    if (widget.config.maxItems != null &&
        files.length > widget.config.maxItems!) {
      _showError(
          'You can only select ${widget.config.maxItems} items at a time');
      return;
    }

    List<PickedMediaFile> pickedFiles = [];

    for (final file in files) {
      // Validate file size
      final fileSize = await file.length();
      if (widget.config.maxFileSize != null &&
          fileSize > widget.config.maxFileSize!) {
        _showError(
          'File ${file.name} exceeds maximum size of '
          '${_formatBytes(widget.config.maxFileSize!)}',
        );
        continue;
      }

      // Determine media type
      final mimeType = file.mimeType ?? '';
      final mediaType =
          mimeType.startsWith('video') ? MediaType.video : MediaType.photo;

      pickedFiles.add(PickedMediaFile(
        file: File(file.path),
        mediaType: mediaType,
        fileName: file.name,
        fileSize: fileSize,
        mimeType: file.mimeType,
      ));
    }

    if (pickedFiles.isEmpty) return;

    // Compress if enabled
    if (widget.config.compressImages || widget.config.compressVideos) {
      _setCompressing(true);
      try {
        final compressedFiles = await _compressMedia(pickedFiles);
        if (widget.onMediaPicked != null) {
          widget.onMediaPicked!(compressedFiles);
        }
      } catch (e) {
        _showError('Compression failed: $e');
        // Return uncompressed files on error
        if (widget.onMediaPicked != null) {
          widget.onMediaPicked!(pickedFiles);
        }
      } finally {
        _setCompressing(false);
      }
    } else {
      if (widget.onMediaPicked != null) {
        widget.onMediaPicked!(pickedFiles);
      }
    }
  }

  Future<List<PickedMediaFile>> _compressMedia(
    List<PickedMediaFile> files,
  ) async {
    List<PickedMediaFile> compressedFiles = [];
    const imageCompressor = MediaCompression();
    const videoCompressor = VideoCompression();

    for (final file in files) {
      if (file.isPhoto && widget.config.compressImages) {
        try {
          final result = await imageCompressor.compressImage(
            file.file,
            config: widget.config.imageCompressionConfig ??
                ImageCompressionConfig.optimizedForTravel,
          );

          // Write compressed bytes to a temporary file
          final tempDir = Directory.systemTemp;
          final tempFile = File('${tempDir.path}/${file.fileName}');
          await tempFile.writeAsBytes(result.bytes);

          compressedFiles.add(PickedMediaFile(
            file: tempFile,
            mediaType: file.mediaType,
            fileName: file.fileName,
            fileSize: result.compressedSize,
            mimeType: file.mimeType,
            width: result.width,
            height: result.height,
          ));
        } catch (e) {
          // Keep original on compression error
          compressedFiles.add(file);
        }
      } else if (file.isVideo && widget.config.compressVideos) {
        try {
          final result = await videoCompressor.compressVideo(
            file.file,
            config: widget.config.videoCompressionConfig ??
                VideoCompressionConfig.optimizedForTravel,
          );
          compressedFiles.add(PickedMediaFile(
            file: result.file,
            mediaType: file.mediaType,
            fileName: file.fileName,
            fileSize: result.compressedSize,
            mimeType: file.mimeType,
            width: result.width,
            height: result.height,
            duration: result.duration,
          ));
        } catch (e) {
          // Keep original on compression error
          compressedFiles.add(file);
        }
      } else {
        compressedFiles.add(file);
      }
    }

    return compressedFiles;
  }

  void _setPicking(bool value) {
    setState(() {
      _isPicking = value;
    });
  }

  void _setCompressing(bool value) {
    setState(() {
      _isCompressing = value;
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  void _showPickerOptions() {
    if (!widget.enabled) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.photo_library,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add Media',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Photo options
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select photos from your device'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImageFromGallery();
              },
            ),

            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              subtitle: const Text('Use camera to take a photo'),
              onTap: () {
                Navigator.of(context).pop();
                _takePhoto();
              },
            ),

            const Divider(height: 1),

            // Video options
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Choose Video'),
              subtitle: const Text('Select videos from your device'),
              onTap: () {
                Navigator.of(context).pop();
                _pickVideoFromGallery();
              },
            ),

            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Record Video'),
              subtitle: const Text('Record a new video'),
              onTap: () {
                Navigator.of(context).pop();
                _recordVideo();
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isPicking || _isCompressing;

    if (widget.showAsButton) {
      return ElevatedButton.icon(
        icon: isBusy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Icon(widget.buttonIcon ?? Icons.add_photo_alternate),
        label: Text(isBusy ? 'Processing...' : widget.buttonText),
        style: widget.buttonStyle,
        onPressed: isBusy || !widget.enabled ? null : _showPickerOptions,
      );
    }

    // Inline mode
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: Icon(
            Icons.add_photo_alternate,
            color: widget.enabled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).disabledColor,
          ),
          title: const Text('Add Photos'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          enabled: widget.enabled && !isBusy,
          onTap: _pickImageFromGallery,
        ),
        ListTile(
          leading: Icon(
            Icons.camera_alt,
            color: widget.enabled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).disabledColor,
          ),
          title: const Text('Take Photo'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          enabled: widget.enabled && !isBusy,
          onTap: _takePhoto,
        ),
        ListTile(
          leading: Icon(
            Icons.video_library,
            color: widget.enabled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).disabledColor,
          ),
          title: const Text('Add Video'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          enabled: widget.enabled && !isBusy,
          onTap: _pickVideoFromGallery,
        ),
        ListTile(
          leading: Icon(
            Icons.videocam,
            color: widget.enabled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).disabledColor,
          ),
          title: const Text('Record Video'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          enabled: widget.enabled && !isBusy,
          onTap: _recordVideo,
        ),
      ],
    );
  }
}
