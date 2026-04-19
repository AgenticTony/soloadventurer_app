/// Common test constants used across multiple test files
///
/// This file centralizes test data to avoid duplication and
/// make it easier to maintain test fixtures.

library;

import 'package:soloadventurer/features/journal/domain/entities/shared_link.dart';

// User/Entity IDs
const String testUserId = 'user-123';
const String testEntryId = 'entry-123';
const String testMediaId = 'media-123';
const String testTagId = 'tag-123';
const String testTripId = 'trip-123';

// DateTime constants for testing
final DateTime testDateTime = DateTime(2024, 1, 1, 12, 0, 0);
final DateTime testDateTimeLater = DateTime(2024, 1, 2, 12, 0, 0);

// Image/Video constants
const int testImageWidth = 1920;
const int testImageHeight = 1080;
const int testImageQuality = 85;
const List<String> testImageFormats = ['.jpg', '.jpeg', '.png'];
const List<List<int>> testImageDimensions = [
  [640, 480],
  [1920, 1080],
  [3840, 2160],
];

const int testVideoWidth = 1920;
const int testVideoHeight = 1080;
const double testVideoDuration = 30.0;
const int testVideoQuality = 80;
const List<String> testVideoFormats = ['.mp4', '.mov', '.avi', '.mkv', '.webm'];

const int testFileSize = 5 * 1024 * 1024; // 5 MB
const Map<String, int> testFileSizes = {
  'small': 500 * 1024, // 500 KB
  'medium': 2 * 1024 * 1024, // 2 MB
  'large': 10 * 1024 * 1024, // 10 MB
};

const List<int> testQualityLevels = [50, 70, 85, 95, 100];

// Sync status constants for testing
const SyncStatus testSyncStatusSynced = SyncStatus.synced;
const SyncStatus testSyncStatusPending = SyncStatus.pending;
const SyncStatus testSyncStatusConflict = SyncStatus.conflict;
const SyncStatus testSyncStatusOfflineOnly = SyncStatus.offlineOnly;
const SyncStatus testSyncStatusSyncing = SyncStatus.syncing;

// Common test strings
const String testTitle = 'Test Title';
const String testContent = 'Test Content';
const String testDescription = 'Test Description';
const String testEmail = 'test@example.com';
const String testPassword = 'TestPassword123!';
const String testUsername = 'testuser';

// Pagination test constants
const int testDefaultLimit = 20;
const int testDefaultOffset = 0;
const int testSmallPageSize = 10;
const int testLargePageSize = 100;

// Network/API test constants
const String testBaseUrl = 'https://api.test.com';
const String testApiKey = 'test-api-key-123';
const Duration testTimeout = Duration(seconds: 30);

// Location test constants
const double testLatitude = 37.7749;
const double testLongitude = -122.4194;
const double testLocationAccuracy = 10.0;
const String testLocationName = 'San Francisco, CA';
const String testCountryCode = 'US';
