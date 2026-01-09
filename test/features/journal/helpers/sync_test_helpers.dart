import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/core/error/exceptions.dart';
import 'package:soloadventurer/core/errors/app_exception.dart';
import 'package:soloadventurer/features/core/domain/services/connectivity_service.dart';
import 'package:soloadventurer/features/journal/data/datasources/journal_local_data_source.dart';
import 'package:soloadventurer/features/journal/data/datasources/journal_remote_data_source.dart';
import 'package:soloadventurer/features/journal/data/datasources/trip_local_data_source.dart';
import 'package:soloadventurer/features/journal/data/datasources/trip_remote_data_source.dart';
import 'package:soloadventurer/features/journal/data/datasources/tag_local_data_source.dart';
import 'package:soloadventurer/features/journal/data/datasources/tag_remote_data_source.dart';
import 'package:soloadventurer/features/journal/data/models/journal_entry_model.dart';
import 'package:soloadventurer/features/journal/data/models/media_item_model.dart';
import 'package:soloadventurer/features/journal/data/models/trip_model.dart';
import 'package:soloadventurer/features/journal/data/models/tag_model.dart';
import 'package:soloadventurer/features/journal/domain/services/sync_service.dart';

// Mock classes
class MockJournalLocalDataSource extends Mock implements JournalLocalDataSource {}

class MockJournalRemoteDataSource extends Mock implements JournalRemoteDataSource {}

class MockTripLocalDataSource extends Mock implements TripLocalDataSource {}

class MockTripRemoteDataSource extends Mock implements TripRemoteDataSource {}

class MockTagLocalDataSource extends Mock implements TagLocalDataSource {}

class MockTagRemoteDataSource extends Mock implements TagRemoteDataSource {}

class MockConnectivityService extends Mock implements ConnectivityService {}

// Test constants
const testUserId = 'user-123';
const testEntryId = 'entry-123';
const testTripId = 'trip-123';
const testMediaId = 'media-123';
const testTagId = 'tag-123';

// Test data
DateTime get testDateTime => DateTime(2024, 1, 15, 10, 30);
DateTime get testDateTimeEarlier => DateTime(2024, 1, 14, 10, 30);
DateTime get testDateTimeLater => DateTime(2024, 1, 16, 10, 30);

/// Creates a test journal entry model with configurable sync status
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
  DateTime? updatedAt,
}) {
  final now = updatedAt ?? testDateTime;
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
    lastSyncedAt: syncStatus == SyncStatus.synced ? now : null,
    createdAt: testDateTimeEarlier,
    updatedAt: now,
  );
}

/// Creates a test trip model with configurable sync status
TripModel createTestTripModel({
  String id = testTripId,
  String userId = testUserId,
  String name = 'Test Trip',
  String? description = 'Test trip description',
  String? destination = 'Paris, France',
  DateTime? startDate,
  DateTime? endDate,
  String? coverImage,
  SyncStatus syncStatus = SyncStatus.synced,
  DateTime? updatedAt,
}) {
  final now = updatedAt ?? testDateTime;
  return TripModel(
    id: id,
    userId: userId,
    name: name,
    description: description,
    destination: destination,
    startDate: startDate ?? testDateTimeEarlier,
    endDate: endDate ?? testDateTimeLater,
    coverImage: coverImage,
    syncStatus: syncStatus,
    lastSyncedAt: syncStatus == SyncStatus.synced ? now : null,
    createdAt: testDateTimeEarlier,
    updatedAt: now,
  );
}

/// Creates a test tag model with configurable sync status
TagModel createTestTagModel({
  String id = testTagId,
  String userId = testUserId,
  String name = 'Test Tag',
  String? color = '#FF5722',
  String? icon = '🏷️',
  int usageCount = 5,
  SyncStatus syncStatus = SyncStatus.synced,
  DateTime? createdAt,
}) {
  final now = createdAt ?? testDateTime;
  return TagModel(
    id: id,
    userId: userId,
    name: name,
    color: color,
    icon: icon,
    usageCount: usageCount,
    syncStatus: syncStatus,
    lastSyncedAt: syncStatus == SyncStatus.synced ? now : null,
    createdAt: now,
    updatedAt: now,
  );
}

/// Creates a test media item model with configurable sync status
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
  SyncStatus syncStatus = SyncStatus.synced,
  DateTime? updatedAt,
}) {
  final now = updatedAt ?? testDateTime;
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
    syncStatus: syncStatus,
    lastSyncedAt: syncStatus == SyncStatus.synced ? now : null,
    createdAt: testDateTimeEarlier,
    updatedAt: now,
  );
}

/// Creates a test SyncResult
SyncResult createTestSyncResult({
  bool success = true,
  SyncOperationType operationType = SyncOperationType.entries,
  SyncDirection direction = SyncDirection.bidirectional,
  int uploadedCount = 5,
  int downloadedCount = 3,
  int conflictCount = 1,
  int failedCount = 0,
  List<String> errors = const [],
  DateTime? startedAt,
}) {
  final started = startedAt ?? testDateTimeEarlier;
  final completed = testDateTime;

  if (success) {
    return SyncResult(
      operationType: operationType,
      direction: direction,
      success: true,
      uploadedCount: uploadedCount,
      downloadedCount: downloadedCount,
      conflictCount: conflictCount,
      failedCount: failedCount,
      errors: errors,
      startedAt: started,
      completedAt: completed,
    );
  } else {
    return SyncResult(
      operationType: operationType,
      direction: direction,
      success: false,
      failedCount: failedCount,
      errors: errors,
      startedAt: started,
      completedAt: completed,
    );
  }
}

/// Creates a test SyncConflict
SyncConflict createTestSyncConflict({
  String entityType = 'journal_entry',
  String entityId = testEntryId,
  Map<String, dynamic>? localVersion,
  Map<String, dynamic>? remoteVersion,
  DateTime? localUpdatedAt,
  DateTime? remoteUpdatedAt,
  String reason = 'Entry modified both locally and remotely',
}) {
  final entry = createTestJournalEntryModel();
  return SyncConflict(
    entityType: entityType,
    entityId: entityId,
    localVersion: localVersion ?? entry.toJson(),
    remoteVersion: remoteVersion ?? entry.copyWith(title: 'Remote Title').toJson(),
    localUpdatedAt: localUpdatedAt ?? testDateTime,
    remoteUpdatedAt: remoteUpdatedAt ?? testDateTimeLater,
    reason: reason,
  );
}

/// Creates a test SyncProgress
SyncProgress createTestSyncProgress({
  int totalItems = 100,
  int syncedItems = 50,
  int syncingItems = 5,
  int conflictItems = 2,
  int failedItems = 1,
  SyncOperationType? currentOperation,
}) {
  return SyncProgress(
    totalItems: totalItems,
    syncedItems: syncedItems,
    syncingItems: syncingItems,
    conflictItems: conflictItems,
    failedItems: failedItems,
    currentOperation: currentOperation,
  );
}

/// Creates a list of pending journal entries
List<JournalEntryModel> createPendingJournalEntries({int count = 3}) {
  return List.generate(
    count,
    (index) => createTestJournalEntryModel(
      id: 'entry-pending-${index + 1}',
      title: 'Pending Entry ${index + 1}',
      syncStatus: SyncStatus.pending,
      updatedAt: testDateTime,
    ),
  );
}

/// Creates a list of synced journal entries
List<JournalEntryModel> createSyncedJournalEntries({int count = 3}) {
  return List.generate(
    count,
    (index) => createTestJournalEntryModel(
      id: 'entry-synced-${index + 1}',
      title: 'Synced Entry ${index + 1}',
      syncStatus: SyncStatus.synced,
      updatedAt: testDateTimeEarlier,
    ),
  );
}

/// Creates a list of pending trips
List<TripModel> createPendingTrips({int count = 2}) {
  return List.generate(
    count,
    (index) => createTestTripModel(
      id: 'trip-pending-${index + 1}',
      name: 'Pending Trip ${index + 1}',
      syncStatus: SyncStatus.pending,
      updatedAt: testDateTime,
    ),
  );
}

/// Creates a list of pending tags
List<TagModel> createPendingTags({int count = 2}) {
  return List.generate(
    count,
    (index) => createTestTagModel(
      id: 'tag-pending-${index + 1}',
      name: 'Pending Tag ${index + 1}',
      syncStatus: SyncStatus.pending,
      createdAt: testDateTime,
    ),
  );
}

/// Creates a list of pending media items
List<MediaItemModel> createPendingMediaItems({int count = 2}) {
  return List.generate(
    count,
    (index) => createTestMediaItemModel(
      id: 'media-pending-${index + 1}',
      journalEntryId: testEntryId,
      storagePath: '/media/pending${index + 1}.jpg',
      syncStatus: SyncStatus.pending,
      updatedAt: testDateTime,
    ),
  );
}

/// Helper to verify SyncResult matches expected values
void assertSyncResultMatches(
  SyncResult actual, {
  bool? success,
  SyncOperationType? operationType,
  SyncDirection? direction,
  int? uploadedCount,
  int? downloadedCount,
  int? conflictCount,
  int? failedCount,
  List<String>? errors,
}) {
  if (success != null) {
    expect(actual.success, success, reason: 'Success status mismatch');
  }
  if (operationType != null) {
    expect(actual.operationType, operationType,
        reason: 'Operation type mismatch');
  }
  if (direction != null) {
    expect(actual.direction, direction, reason: 'Direction mismatch');
  }
  if (uploadedCount != null) {
    expect(actual.uploadedCount, uploadedCount,
        reason: 'Uploaded count mismatch');
  }
  if (downloadedCount != null) {
    expect(actual.downloadedCount, downloadedCount,
        reason: 'Downloaded count mismatch');
  }
  if (conflictCount != null) {
    expect(actual.conflictCount, conflictCount,
        reason: 'Conflict count mismatch');
  }
  if (failedCount != null) {
    expect(actual.failedCount, failedCount,
        reason: 'Failed count mismatch');
  }
  if (errors != null) {
    expect(actual.errors, errors, reason: 'Errors mismatch');
  }
}

/// Helper to verify SyncProgress matches expected values
void assertSyncProgressMatches(
  SyncProgress actual, {
  int? totalItems,
  int? syncedItems,
  int? syncingItems,
  int? conflictItems,
  int? failedItems,
  double? progress,
  bool? isComplete,
  bool? hasErrors,
  bool? hasConflicts,
  SyncOperationType? currentOperation,
}) {
  if (totalItems != null) {
    expect(actual.totalItems, totalItems, reason: 'Total items mismatch');
  }
  if (syncedItems != null) {
    expect(actual.syncedItems, syncedItems, reason: 'Synced items mismatch');
  }
  if (syncingItems != null) {
    expect(actual.syncingItems, syncingItems,
        reason: 'Syncing items mismatch');
  }
  if (conflictItems != null) {
    expect(actual.conflictItems, conflictItems,
        reason: 'Conflict items mismatch');
  }
  if (failedItems != null) {
    expect(actual.failedItems, failedItems,
        reason: 'Failed items mismatch');
  }
  if (progress != null) {
    expect(actual.progress, closeTo(progress, 0.01),
        reason: 'Progress mismatch');
  }
  if (isComplete != null) {
    expect(actual.isComplete, isComplete, reason: 'IsComplete mismatch');
  }
  if (hasErrors != null) {
    expect(actual.hasErrors, hasErrors, reason: 'HasErrors mismatch');
  }
  if (hasConflicts != null) {
    expect(actual.hasConflicts, hasConflicts, reason: 'HasConflicts mismatch');
  }
  if (currentOperation != null) {
    expect(actual.currentOperation, currentOperation,
        reason: 'Current operation mismatch');
  }
}

/// Helper to setup connectivity mock to return connected
void setupConnectivityConnected(MockConnectivityService mockConnectivity) {
  when(() => mockConnectivity.hasConnectivity).thenAnswer((_) async => true);
}

/// Helper to setup connectivity mock to return disconnected
void setupConnectivityDisconnected(MockConnectivityService mockConnectivity) {
  when(() => mockConnectivity.hasConnectivity).thenAnswer((_) async => false);
}

/// Helper to setup remote data source to throw 404
void setupRemoteThrows404<T>(T mockDataSource, Future Function() method) {
  when(method).thenThrow(
    const ServerException(message: 'Not found', statusCode: 404),
  );
}

/// Helper to setup remote data source to throw 500
void setupRemoteThrows500<T>(T mockDataSource, Future Function() method) {
  when(method).thenThrow(
    const ServerException(message: 'Server error', statusCode: 500),
  );
}

/// Helper to setup local data source to throw NotFoundException
void setupLocalThrowsNotFound<T>(T mockDataSource, Future Function() method) {
  when(method).thenThrow(
    NotFoundException(message: 'Not found locally'),
  );
}
