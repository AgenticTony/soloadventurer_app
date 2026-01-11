import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/journal/data/datasources/journal_remote_data_source.dart';
import 'package:soloadventurer/features/journal/data/models/journal_entry_model.dart';
import 'package:soloadventurer/features/journal/data/models/media_item_model.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';
import 'package:soloadventurer/features/journal/domain/entities/media_item.dart';
import 'package:soloadventurer/features/journal/domain/entities/shared_link.dart';

// Mock classes
class MockJournalRemoteDataSource extends Mock
    implements JournalRemoteDataSource {}

// Test constants
const testUserId = 'user-123';
const testEntryId = 'entry-123';
const testTripId = 'trip-123';
const testMediaId = 'media-123';
const testTagId = 'tag-123';

// Test data
DateTime get testDateTime => DateTime(2024, 1, 15, 10, 30);

/// Creates a test journal entry model
JournalEntryModel createTestJournalEntryModel({
  String id = testEntryId,
  String userId = testUserId,
  String? tripId,
  String title = 'Test Entry Title',
  String content = 'This is test content for the journal entry.',
  String? mood = 'happy',
  String? locationName = 'Paris, France',
  double? latitude = 48.8566,
  double? longitude = 2.3522,
  bool isFavorite = false,
  SyncStatus syncStatus = SyncStatus.synced,
}) {
  final now = testDateTime;
  return JournalEntryModel(
    id: id,
    userId: userId,
    tripId: tripId,
    title: title,
    content: content,
    mood: mood,
    locationName: locationName,
    latitude: latitude,
    longitude: longitude,
    locationAccuracy: 10.0,
    entryDate: now,
    weatherData: {'temperature': 20, 'condition': 'sunny'},
    isFavorite: isFavorite,
    syncStatus: syncStatus,
    lastSyncedAt: now,
    createdAt: now,
    updatedAt: now,
  );
}

/// Creates a test journal entry entity
JournalEntry createTestJournalEntry({
  String id = testEntryId,
  String userId = testUserId,
  String? tripId,
  String title = 'Test Entry Title',
  String content = 'This is test content for the journal entry.',
}) {
  final model = createTestJournalEntryModel(
    id: id,
    userId: userId,
    tripId: tripId,
    title: title,
    content: content,
  );
  return model.toEntity();
}

/// Creates a test media item model
MediaItemModel createTestMediaItemModel({
  String id = testMediaId,
  String userId = testUserId,
  String journalEntryId = testEntryId,
  MediaType mediaType = MediaType.image,
  String storagePath = '/media/photo.jpg',
  String? originalFilename = 'photo.jpg',
  int? fileSize = 1024000,
  String? mimeType = 'image/jpeg',
  int? width = 1920,
  int? height = 1080,
  UploadStatus uploadStatus = UploadStatus.completed,
  int uploadProgress = 100,
}) {
  final now = testDateTime;
  return MediaItemModel(
    id: id,
    userId: userId,
    journalEntryId: journalEntryId,
    mediaType: mediaType,
    storagePath: storagePath,
    originalFilename: originalFilename,
    fileSize: fileSize,
    mimeType: mimeType,
    width: width,
    height: height,
    duration: null,
    thumbnailPath: '/media/thumb_photo.jpg',
    caption: 'Test caption',
    uploadStatus: uploadStatus,
    uploadProgress: uploadProgress,
    exifData: {'camera': 'Canon', 'iso': 100},
    isCover: false,
    orderIndex: 0,
    syncStatus: SyncStatus.synced,
    lastSyncedAt: now,
    createdAt: now,
    updatedAt: now,
  );
}

/// Creates a test media item entity
MediaItem createTestMediaItem({
  String id = testMediaId,
  String userId = testUserId,
  String journalEntryId = testEntryId,
}) {
  final model = createTestMediaItemModel(
    id: id,
    userId: userId,
    journalEntryId: journalEntryId,
  );
  return model.toEntity();
}

/// Creates a list of test journal entries
List<JournalEntryModel> createTestJournalEntryList({int count = 3}) {
  return List.generate(
    count,
    (index) => createTestJournalEntryModel(
      id: 'entry-${index + 1}',
      title: 'Test Entry ${index + 1}',
      content: 'Content for entry ${index + 1}',
    ),
  );
}

/// Creates a list of test media items
List<MediaItemModel> createTestMediaItemList({int count = 3}) {
  return List.generate(
    count,
    (index) => createTestMediaItemModel(
      id: 'media-${index + 1}',
      journalEntryId: testEntryId,
      storagePath: '/media/photo${index + 1}.jpg',
      orderIndex: index,
    ),
  );
}

/// Creates a test JSON map for journal entry (Supabase format)
Map<String, dynamic> createTestJournalEntryJson({
  String id = testEntryId,
  String userId = testUserId,
  String? tripId,
  String title = 'Test Entry Title',
  String content = 'This is test content.',
}) {
  final now = testDateTime;
  return {
    'id': id,
    'user_id': userId,
    'trip_id': tripId,
    'title': title,
    'content': content,
    'mood': 'happy',
    'location_name': 'Paris, France',
    'latitude': 48.8566,
    'longitude': 2.3522,
    'location_accuracy': 10.0,
    'entry_date': now.toIso8601String(),
    'weather_data': {'temperature': 20, 'condition': 'sunny'},
    'is_favorite': false,
    'sync_status': 'synced',
    'last_synced_at': now.toIso8601String(),
    'created_at': now.toIso8601String(),
    'updated_at': now.toIso8601String(),
  };
}

/// Creates a test JSON map for media item (Supabase format)
Map<String, dynamic> createTestMediaItemJson({
  String id = testMediaId,
  String userId = testUserId,
  String journalEntryId = testEntryId,
}) {
  final now = testDateTime;
  return {
    'id': id,
    'user_id': userId,
    'journal_entry_id': journalEntryId,
    'media_type': 'image',
    'storage_path': '/media/photo.jpg',
    'original_filename': 'photo.jpg',
    'file_size': 1024000,
    'mime_type': 'image/jpeg',
    'width': 1920,
    'height': 1080,
    'duration': null,
    'thumbnail_path': '/media/thumb_photo.jpg',
    'caption': 'Test caption',
    'upload_status': 'completed',
    'upload_progress': 100,
    'exif_data': {'camera': 'Canon', 'iso': 100},
    'is_cover': false,
    'order_index': 0,
    'sync_status': 'synced',
    'last_synced_at': now.toIso8601String(),
    'created_at': now.toIso8601String(),
    'updated_at': now.toIso8601String(),
  };
}

/// Helper to verify AppException was thrown
void verifyThrowsAppException(
  Future<void> Function() callable, {
  String? containsMessage,
}) {
  expect(
    callable,
    throwsA(isA<AppException>().having(
      (e) => e.message,
      'message',
      containsMessage == null ? anything : contains(containsMessage),
    )),
  );
}

/// Helper to verify ServerException was thrown from data source
void verifyThrowsServerException(
  Future<void> Function() callable, {
  String? containsMessage,
  int? statusCode,
}) {
  expect(
    callable,
    throwsA(isA<ServerException>().having(
      (e) => e.message,
      'message',
      containsMessage == null ? anything : contains(containsMessage),
    )),
  );
}
