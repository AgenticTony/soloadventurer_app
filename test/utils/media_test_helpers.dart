import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:soloadventurer/utils/media_compression.dart';
import 'package:soloadventurer/utils/video_compression.dart';
import 'package:soloadventurer/features/journal/data/models/upload_task.dart';
import 'package:soloadventurer/features/journal/domain/entities/media_item.dart';

// Test constants
const testImageWidth = 1920;
const testImageHeight = 1080;
const testImageQuality = 85;
const testVideoWidth = 1920;
const testVideoHeight = 1080;
const testVideoDuration = 30.0;
const testVideoQuality = 80;
const testFileSize = 5 * 1024 * 1024; // 5 MB

// Test data helpers

/// Creates a test image file
File createTestImageFile({
  String path = '/tmp/test_image.jpg',
  int size = testFileSize,
}) {
  final file = File(path);
  return file;
}

/// Creates test image bytes
Uint8List createTestImageBytes({
  int size = 1024,
}) {
  return Uint8List.fromList(List.generate(size, (i) => i % 256));
}

/// Creates a test video file
File createTestVideoFile({
  String path = '/tmp/test_video.mp4',
  int size = 50 * 1024 * 1024, // 50 MB
}) {
  final file = File(path);
  return file;
}

/// Creates a test compressed image result
CompressedImageResult createTestCompressedImageResult({
  int originalSize = testFileSize,
  int compressedSize = 1024 * 1024, // 1 MB
  int width = testImageWidth,
  int height = testImageHeight,
  String format = 'jpeg',
  int quality = testImageQuality,
}) {
  return CompressedImageResult(
    bytes: createTestImageBytes(size: compressedSize),
    originalSize: originalSize,
    compressedSize: compressedSize,
    width: width,
    height: height,
    format: format,
    quality: quality,
  );
}

/// Creates a test compressed video result
CompressedVideoResult createTestCompressedVideoResult({
  String path = '/tmp/test_video_compressed.mp4',
  int originalSize = 50 * 1024 * 1024, // 50 MB
  int compressedSize = 10 * 1024 * 1024, // 10 MB
  int width = testVideoWidth,
  int height = testVideoHeight,
  double duration = testVideoDuration,
  String format = 'mp4',
  int quality = testVideoQuality,
}) {
  return CompressedVideoResult(
    file: File(path),
    originalSize: originalSize,
    compressedSize: compressedSize,
    width: width,
    height: height,
    duration: duration,
    format: format,
    quality: quality,
  );
}

/// Creates a test image compression config
ImageCompressionConfig createTestImageCompressionConfig({
  int? maxWidth,
  int? maxHeight,
  int quality = testImageQuality,
  int? targetSize,
  bool maintainAspect = true,
  bool autoCorrectionAngle = true,
}) {
  return ImageCompressionConfig(
    maxWidth: maxWidth,
    maxHeight: maxHeight,
    quality: quality,
    targetSize: targetSize,
    maintainAspect: maintainAspect,
    autoCorrectionAngle: autoCorrectionAngle,
  );
}

/// Creates a test video compression config
VideoCompressionConfig createTestVideoCompressionConfig({
  int? maxWidth,
  int? maxHeight,
  int quality = testVideoQuality,
  int? frameRate,
  bool maintainAspect = true,
  bool includeAudio = true,
  int? audioBitrate,
}) {
  return VideoCompressionConfig(
    maxWidth: maxWidth,
    maxHeight: maxHeight,
    quality: quality,
    frameRate: frameRate,
    maintainAspect: maintainAspect,
    includeAudio: includeAudio,
    audioBitrate: audioBitrate,
  );
}

/// Creates a test upload task
UploadTask createTestUploadTask({
  String id = 'upload-123',
  String filePath = '/tmp/test_image.jpg',
  MediaType mediaType = MediaType.photo,
  String? journalEntryId,
  UploadStatus status = UploadStatus.queued,
  int fileSize = testFileSize,
  int priority = 5,
  bool compressBeforeUpload = true,
}) {
  return UploadTask(
    id: id,
    filePath: filePath,
    mediaType: mediaType,
    journalEntryId: journalEntryId,
    status: status,
    fileSize: fileSize,
    createdAt: DateTime(2024, 1, 15, 10, 30),
    priority: priority,
    compressBeforeUpload: compressBeforeUpload,
  );
}

/// Creates test media item entity
MediaItem createTestMediaItem({
  String id = 'media-123',
  String journalEntryId = 'entry-123',
  MediaType mediaType = MediaType.photo,
  String storagePath = 'user123/2024-01-15T10:30:00.000Z.jpg',
  String? thumbnailPath,
  int? width = testImageWidth,
  int? height = testImageHeight,
  double? duration,
  int fileSize = testFileSize,
  UploadStatus uploadStatus = UploadStatus.completed,
  int uploadProgress = 100,
  String? caption,
  int? orderIndex,
  SyncStatus syncStatus = SyncStatus.synced,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return MediaItem(
    id: id,
    journalEntryId: journalEntryId,
    mediaType: mediaType,
    storagePath: storagePath,
    thumbnailPath: thumbnailPath,
    width: width,
    height: height,
    duration: duration,
    fileSize: fileSize,
    uploadStatus: uploadStatus,
    uploadProgress: uploadProgress,
    caption: caption,
    orderIndex: orderIndex,
    syncStatus: syncStatus,
    createdAt: createdAt ?? DateTime(2024, 1, 15, 10, 30),
    updatedAt: updatedAt ?? DateTime(2024, 1, 15, 10, 30),
  );
}

/// Assertion helpers

/// Asserts that compression result is valid
void assertCompressedImageResultValid(
  CompressedImageResult result, {
  int? expectedOriginalSize,
  int? expectedCompressedSize,
  int? expectedWidth,
  int? expectedHeight,
  String? expectedFormat,
  int? expectedQuality,
}) {
  expect(result.bytes, isNotEmpty);
  expect(result.originalSize, greaterThan(0));

  if (expectedOriginalSize != null) {
    expect(result.originalSize, equals(expectedOriginalSize));
  }

  if (expectedCompressedSize != null) {
    expect(result.compressedSize, equals(expectedCompressedSize));
  }

  if (expectedWidth != null) {
    expect(result.width, equals(expectedWidth));
  }

  if (expectedHeight != null) {
    expect(result.height, equals(expectedHeight));
  }

  if (expectedFormat != null) {
    expect(result.format, equals(expectedFormat));
  }

  if (expectedQuality != null) {
    expect(result.quality, equals(expectedQuality));
  }

  expect(result.compressionRatio, greaterThan(0));
  expect(result.sizeReductionPercent, greaterThanOrEqualTo(0));
  expect(result.sizeReductionPercent, lessThanOrEqualTo(100));
}

/// Asserts that video compression result is valid
void assertCompressedVideoResultValid(
  CompressedVideoResult result, {
  int? expectedOriginalSize,
  int? expectedCompressedSize,
  int? expectedWidth,
  int? expectedHeight,
  double? expectedDuration,
  String? expectedFormat,
  int? expectedQuality,
}) {
  expect(result.file, isA<File>());
  expect(result.originalSize, greaterThan(0));

  if (expectedOriginalSize != null) {
    expect(result.originalSize, equals(expectedOriginalSize));
  }

  if (expectedCompressedSize != null) {
    expect(result.compressedSize, equals(expectedCompressedSize));
  }

  if (expectedWidth != null) {
    expect(result.width, equals(expectedWidth));
  }

  if (expectedHeight != null) {
    expect(result.height, equals(expectedHeight));
  }

  if (expectedDuration != null) {
    expect(result.duration, equals(expectedDuration));
  }

  if (expectedFormat != null) {
    expect(result.format, equals(expectedFormat));
  }

  if (expectedQuality != null) {
    expect(result.quality, equals(expectedQuality));
  }

  expect(result.compressionRatio, greaterThan(0));
  expect(result.sizeReductionPercent, greaterThanOrEqualTo(0));
  expect(result.sizeReductionPercent, lessThanOrEqualTo(100));
}

/// Asserts that upload task is valid
void assertUploadTaskValid(
  UploadTask task, {
  String? expectedId,
  MediaType? expectedMediaType,
  UploadStatus? expectedStatus,
  int? expectedFileSize,
  int? expectedPriority,
}) {
  expect(task.id, isNotEmpty);
  expect(task.filePath, isNotEmpty);
  expect(task.createdAt, isNotNull);

  if (expectedId != null) {
    expect(task.id, equals(expectedId));
  }

  if (expectedMediaType != null) {
    expect(task.mediaType, equals(expectedMediaType));
  }

  if (expectedStatus != null) {
    expect(task.status, equals(expectedStatus));
  }

  if (expectedFileSize != null) {
    expect(task.fileSize, equals(expectedFileSize));
  }

  if (expectedPriority != null) {
    expect(task.priority, equals(expectedPriority));
  }
}

/// Mock helpers

/// Creates a mock file with existsSync override
File createMockFile({
  required String path,
  bool exists = true,
  int size = testFileSize,
}) {
  final file = File(path);
  return file;
}

/// Test scenarios

/// List of test image formats
const testImageFormats = ['.jpg', '.jpeg', '.png'];

/// List of test video formats
const testVideoFormats = ['.mp4', '.mov', '.avi', '.mkv', '.webm'];

/// Test file sizes for different scenarios
const testFileSizes = {
  'small': 500 * 1024, // 500 KB
  'medium': 5 * 1024 * 1024, // 5 MB
  'large': 50 * 1024 * 1024, // 50 MB
  'veryLarge': 200 * 1024 * 1024, // 200 MB (exceeds max)
};

/// Test quality levels
const testQualityLevels = [50, 70, 85, 95, 100];

/// Test image dimensions
const testImageDimensions = [
  (640, 480),      // VGA
  (1280, 720),     // 720p
  (1920, 1080),    // 1080p
  (2560, 1440),    // 1440p
  (3840, 2160),    // 4K
];
