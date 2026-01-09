# Media Compression & Upload Tests

Comprehensive test suite for media compression (image and video) and upload functionality in the SoloAdventurer travel journal feature.

## Overview

This test suite verifies the core media handling capabilities that prevent crashes when adding photos (addressing pain-2-2) and ensure smooth background uploads during travel.

## Test Files

### 1. `media_test_helpers.dart`
Test utilities, factories, and assertion helpers for media testing.

**Contents:**
- Test constants (dimensions, quality levels, file sizes)
- Test data factories (images, videos, upload tasks, media items)
- Assertion helpers for compressed results
- Mock file creation helpers
- Test scenarios and edge cases

**Key Helpers:**
```dart
// Create test data
createTestImageFile()
createTestImageBytes()
createTestCompressedImageResult()
createTestUploadTask()

// Assert results
assertCompressedImageResultValid()
assertCompressedVideoResultValid()
assertUploadTaskValid()
```

### 2. `media_compression_test.dart`
Tests for image compression functionality using `flutter_image_compress`.

**Test Groups:**

#### CompressedImageResult Tests
- Compression ratio calculation
- Size reduction percentage calculation
- Effectiveness determination (10% threshold)
- String formatting

#### ImageCompressionConfig Tests
- Preset validation (optimizedForTravel, highQuality, aggressive)
- Parameter validation (quality, dimensions, target size)
- copyWith method for creating modified configs

#### MediaCompression Static Methods
- `estimateCompressedSize()` - Estimates output size before compression
- `needsCompression()` - Determines if compression is needed
- `getRecommendedConfig()` - Suggests config based on image properties

#### MediaCompression Instance Methods
- `compressImage()` - Compresses image files
- `compressBytes()` - Compresses byte arrays
- File validation and format checking

#### Edge Cases
- Very small images (< 10KB)
- Very large images (> 50MB)
- Various aspect ratios (square, panoramic, portrait)
- EXIF rotation handling

#### Performance Tests
- Compression speed for small images
- Compression speed for large images
- Batch compression efficiency

### 3. `video_compression_test.dart`
Tests for video compression functionality.

**Test Groups:**

#### CompressedVideoResult Tests
- Compression ratio calculation
- Size reduction percentage calculation
- Effectiveness determination
- String formatting with duration

#### VideoCompressionConfig Tests
- Preset validation (optimizedForTravel, highQuality, aggressive)
- Parameter validation (quality, dimensions, frame rate, audio bitrate)
- copyWith method for creating modified configs

#### VideoCompressionProgress Tests
- Progress value storage
- Status message handling
- String formatting

#### VideoCompression Static Methods
- `estimateCompressedSize()` - Estimates video output size
- `needsCompression()` - Determines if compression is needed
- `getRecommendedConfig()` - Suggests config based on video properties

#### VideoCompression Instance Methods
- `compressVideo()` - Compresses video files
- Progress callback invocation
- File validation and format checking
- `cleanup()` - Temporary file deletion

#### Edge Cases
- Very short videos (1-2 seconds)
- Very long videos (> 10 minutes)
- 4K resolution videos
- Vertical/square videos
- Different frame rates (24, 30, 60 fps)
- Videos with/without audio

#### Format Support Tests
- MP4, MOV, AVI, MKV, WebM format validation

### 4. `media_upload_service_test.dart`
Tests for background media upload service.

**Test Groups:**

#### Initialization Tests
- Default configuration setup
- Config updates
- Background task registration

#### Queue Management Tests
- Retrieving all tasks
- Filtering tasks by journal entry
- Finding tasks by ID
- Empty queue handling

#### Enqueue Upload Tests
- Single upload enqueuing
- Multiple upload enqueuing
- Priority handling
- Journal entry association
- Compression settings

#### Upload Lifecycle Tests
- Starting uploads
- Pausing uploads
- Resuming uploads
- Canceling uploads (single/all)
- Retrying failed uploads

#### Progress Tracking Tests
- Progress callback invocation
- Status change callbacks
- Task progress streams
- Queue status streams
- Callback removal

#### Queue Cleanup Tests
- Clearing completed tasks
- Clearing all tasks

#### Statistics Tests
- Upload counts (total, successful, failed)
- Active uploads count
- Byte calculations
- Average upload speed

#### Error Handling Tests
- File not found errors
- Network errors
- Authentication errors
- Retry logic with exponential backoff
- Max retries handling

#### Priority Management Tests
- Queue sorting by priority
- FIFO ordering for equal priority

#### Concurrent Upload Tests
- Concurrent upload limits
- Queue progression
- Parallel upload handling

#### Persistence Tests
- Queue saving to SharedPreferences
- Queue loading on initialization
- Corrupted data handling

#### Storage Integration Tests
- Bucket selection (photos/videos)
- Unique path generation
- Database updates after upload

#### UploadTask State Tests
- Status transitions
- State properties (isReady, isActive, isTerminal)
- Serialization/deserialization

## Running the Tests

### Run All Media Tests
```bash
flutter test test/utils/media_compression_test.dart
flutter test test/utils/video_compression_test.dart
flutter test test/features/journal/data/services/media_upload_service_test.dart
```

### Run Specific Test Group
```bash
flutter test test/utils/media_compression_test.dart --name "CompressedImageResult"
flutter test test/utils/video_compression_test.dart --name "estimateCompressedSize"
flutter test test/features/journal/data/services/media_upload_service_test.dart --name "Queue Management"
```

### Run with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Run with Verbose Output
```bash
flutter test --verbose
```

## Test Coverage

### Image Compression
- ✅ Result calculations (ratio, reduction, effectiveness)
- ✅ Config validation and presets
- ✅ Static helper methods
- ✅ File and byte compression
- ✅ Format support (JPEG, PNG)
- ✅ Edge cases (size, aspect ratio, orientation)
- ✅ Performance scenarios

### Video Compression
- ✅ Result calculations (ratio, reduction, effectiveness)
- ✅ Config validation and presets
- ✅ Progress tracking
- ✅ Static helper methods
- ✅ File compression
- ✅ Format support (MP4, MOV, AVI, MKV, WebM)
- ✅ Edge cases (duration, resolution, frame rate)
- ✅ Audio handling

### Media Upload
- ✅ Service initialization and configuration
- ✅ Queue management
- ✅ Upload lifecycle (start, pause, resume, cancel, retry)
- ✅ Progress tracking and callbacks
- ✅ Priority management
- ✅ Concurrent upload handling
- ✅ Error handling and retry logic
- ✅ Persistence and recovery
- ✅ Statistics and monitoring
- ✅ Storage integration
- ✅ Background processing

## Testing Approach

### Unit Testing Strategy
1. **Isolation**: Each test is independent and can run in any order
2. **AAA Pattern**: Arrange-Act-Assert structure for clarity
3. **Descriptive Names**: Test names clearly describe what is being tested
4. **Mocking**: External dependencies are mocked for fast, reliable tests
5. **Edge Cases**: Comprehensive coverage of edge cases and error scenarios

### Test Categories

#### Happy Path Tests
Verify normal operation with valid inputs:
- Successful compression
- Successful upload
- Correct state transitions

#### Error Handling Tests
Verify graceful failure handling:
- Invalid inputs
- Missing files
- Network failures
- Authentication errors

#### Edge Case Tests
Verify behavior at boundaries:
- Minimum/maximum values
- Empty/null inputs
- Very large/small files
- Unsupported formats

#### Performance Tests
Verify efficiency and speed:
- Compression time
- Upload progress
- Memory usage

#### Integration Tests
Verify component interactions:
- Queue + upload service
- Compression + upload
- Progress tracking + UI

## Test Data

### Test File Sizes
```dart
const testFileSizes = {
  'small': 500 * 1024,        // 500 KB
  'medium': 5 * 1024 * 1024,  // 5 MB
  'large': 50 * 1024 * 1024,  // 50 MB
  'veryLarge': 200 * 1024 * 1024, // 200 MB (exceeds max)
};
```

### Test Quality Levels
```dart
const testQualityLevels = [50, 70, 85, 95, 100];
```

### Test Image Dimensions
```dart
const testImageDimensions = [
  (640, 480),    // VGA
  (1280, 720),   // 720p
  (1920, 1080),  // 1080p
  (2560, 1440),  // 1440p
  (3840, 2160),  // 4K
];
```

### Test Video Formats
```dart
const testVideoFormats = ['.mp4', '.mov', '.avi', '.mkv', '.webm'];
```

## Mocking Strategy

### External Dependencies
- **FlutterImageCompress**: Mocked for image compression tests
- **Video Compress**: Mocked for video compression tests
- **Supabase Client**: Mocked for upload service tests
- **SharedPreferences**: Mocked for persistence tests
- **File System**: Mocked or uses temp files for I/O tests

### Mock Benefits
- Fast test execution
- Deterministic results
- No external service dependencies
- Can test error scenarios easily

## Future Enhancements

### Additional Tests to Add
1. **Integration Tests**: End-to-end compression and upload workflow
2. **Performance Tests**: Benchmark compression speeds and ratios
3. **Memory Tests**: Verify memory usage during large file operations
4. **Concurrency Tests**: Stress test with many simultaneous uploads
5. **Network Tests**: Test on actual network conditions
6. **Device Tests**: Test on real devices with camera files

### Test Infrastructure Improvements
1. **Golden File Tests**: Compare compressed images with reference outputs
2. **Property-Based Testing**: Generate random inputs for edge case discovery
3. **Performance Baselines**: Set minimum performance thresholds
4. **Mock Server**: Run local Supabase instance for integration tests

## Troubleshooting

### Common Issues

#### Tests Fail with "File not found"
- Ensure test files are created before use
- Check file paths are correct for your platform

#### Mock Verification Fails
- Verify all mock interactions are properly set up
- Check that `registerFallbackValue` is called for generic types

#### Timeout Errors
- Increase timeout for long-running compression tests
- Optimize test data sizes

#### Platform-Specific Failures
- Some tests may behave differently on iOS vs Android
- Check platform-specific file system permissions

## Best Practices

### When Adding New Tests
1. Keep tests focused and independent
2. Use descriptive test names
3. Follow AAA pattern
4. Add test helpers for common operations
5. Document complex scenarios

### When Modifying Media Code
1. Run all tests before committing
2. Update tests for new features
3. Add tests for edge cases
4. Maintain test coverage above 80%
5. Document breaking changes

### When Debugging Test Failures
1. Run tests with `--verbose` flag
2. Check mock setup and verification
3. Verify test data is valid
4. Use debuggers to step through code
5. Check logs for detailed error messages

## Related Documentation

- [Media Compression Implementation](../../../lib/utils/README_MEDIA_COMPRESSION.md)
- [Video Compression Implementation](../../../lib/utils/README_VIDEO_COMPRESSION.md)
- [Media Upload Service](../../../lib/features/journal/data/services/README_MEDIA_UPLOAD.md)
- [Journal Feature Tests](../features/journal/README_JOURNAL_TESTS.md)

## Test Maintenance

### Regular Tasks
- Update test helpers when adding new properties
- Review and optimize slow tests
- Keep mocks in sync with actual implementations
- Document any test limitations or known issues

### Test Metrics
- Target coverage: 80%+
- Target execution time: < 30 seconds for all tests
- Target flake rate: 0%
- Target test count: 100+ tests across all files

## Contributing

When contributing new media features:
1. Write tests before or alongside implementation (TDD)
2. Include unit tests for all public methods
3. Add integration tests for workflows
4. Test error cases and edge cases
5. Update this README with new test descriptions
6. Ensure all tests pass before submitting PR

---

**Last Updated**: 2026-01-06
**Test Suite Version**: 1.0.0
**Maintainer**: SoloAdventurer Development Team
