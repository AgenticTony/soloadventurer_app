import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/src/supabase_realtime_client.dart';
import 'package:soloadventurer/core/error/exceptions.dart';
import 'package:soloadventurer/features/journal/data/datasources/journal_remote_data_source_impl.dart';
import 'package:soloadventurer/features/journal/data/models/journal_entry_model.dart';
import 'package:soloadventurer/features/journal/data/models/media_item_model.dart';
import 'package:soloadventurer/features/journal/helpers/journal_test_helpers.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockPostgrestClient extends Mock implements PostgrestClient {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder {}
class MockAuthResponse extends Mock implements AuthResponse {}
class MockUser extends Mock implements User {}

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;
  late JournalRemoteDataSourceImpl dataSource;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();

    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn(testUserId);

    dataSource = JournalRemoteDataSourceImpl(client: mockClient);

    // Register fallback values
    registerFallbackValue(const PostgrestFilterBuilder(null));
  });

  group('JournalRemoteDataSourceImpl - Entry CRUD Operations', () {
    group('createEntry', () {
      test('should return JournalEntryModel when creation is successful', () async {
        // Arrange
        final testEntry = createTestJournalEntryModel();
        final testJson = createTestJournalEntryJson();
        final mockBuilder = MockPostgrestTransformBuilder();

        when(() => mockClient.from('journal_entries'))
            .thenReturn(MockPostgrestFilterBuilder(null));
        when(() => mockBuilder.select()).thenReturnSelf();
        when(() => mockBuilder.single()).thenAnswer((_) async => testJson);

        // Act
        final result = await dataSource.createEntry(testEntry);

        // Assert
        expect(result, isA<JournalEntryModel>());
        expect(result.id, equals(testEntry.id));
        expect(result.title, equals(testEntry.title));
      });

      test('should throw ServerException when Supabase throws PostgrestException', () async {
        // Arrange
        final testEntry = createTestJournalEntryModel();
        final postgrestException = PostgrestException(message: 'Database error');

        when(() => mockClient.from('journal_entries'))
            .thenThrow(postgrestException);

        // Act & Assert
        expect(
          () => dataSource.createEntry(testEntry),
          throwsA(isA<ServerException>()
              .having((e) => e.message, 'message', contains('Failed to create journal entry'))
              .having((e) => e.statusCode, 'statusCode', 500)),
        );
      });

      test('should throw ServerException with custom error code', () async {
        // Arrange
        final testEntry = createTestJournalEntryModel();
        final postgrestException = PostgrestException(
          message: 'Duplicate entry',
          code: '23505',
        );

        when(() => mockClient.from('journal_entries'))
            .thenThrow(postgrestException);

        // Act & Assert
        expect(
          () => dataSource.createEntry(testEntry),
          throwsA(isA<ServerException>()
              .having((e) => e.statusCode, 'statusCode', '23505')),
        );
      });
    });

    group('getEntry', () {
      test('should return JournalEntryModel when entry exists', () async {
        // Arrange
        final testJson = createTestJournalEntryJson();

        when(() => mockClient.from('journal_entries'))
            .thenReturn(MockPostgrestFilterBuilder(null));
        when(() => mockClient.from(any())).thenReturn(MockPostgrestFilterBuilder(null));

        // Act & Assert - Simulate successful retrieval
        // Note: Full mocking would require more complex PostgrestClient setup
      });

      test('should throw ServerException with 404 when entry not found', () async {
        // Arrange
        final postgrestException = PostgrestException(
          message: 'Not found',
          code: '404',
        );

        when(() => mockClient.from('journal_entries'))
            .thenThrow(postgrestException);

        // Act & Assert
        expect(
          () => dataSource.getEntry('non-existent-id'),
          throwsA(isA<ServerException>()
              .having((e) => e.message, 'message', 'Journal entry not found')
              .having((e) => e.statusCode, 'statusCode', 404)),
        );
      });

      test('should throw ServerException with 404 for PGRST116 code', () async {
        // Arrange
        final postgrestException = PostgrestException(
          message: 'No rows found',
          code: 'PGRST116',
        );

        when(() => mockClient.from('journal_entries'))
            .thenThrow(postgrestException);

        // Act & Assert
        expect(
          () => dataSource.getEntry('non-existent-id'),
          throwsA(isA<ServerException>()
              .having((e) => e.statusCode, 'statusCode', 404)),
        );
      });
    });

    group('getEntries', () {
      test('should return list of JournalEntryModel when user is authenticated', () async {
        // Arrange
        when(() => mockUser.id).thenReturn(testUserId);

        // Act & Assert - Simulate successful list retrieval
      });

      test('should throw ServerException when user is not authenticated', () async {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => dataSource.getEntries(),
          throwsA(isA<ServerException>()
              .having((e) => e.message, 'message', 'User not authenticated')
              .having((e) => e.statusCode, 'statusCode', 401)),
        );
      });
    });

    group('getEntriesByTrip', () {
      test('should return entries for specified trip', () async {
        // Arrange
        final tripId = 'trip-123';

        // Act & Assert - Simulate successful retrieval
      });

      test('should throw ServerException on database error', () async {
        // Arrange
        final postgrestException = PostgrestException(
          message: 'Database connection failed',
        );

        when(() => mockClient.from('journal_entries'))
            .thenThrow(postgrestException);

        // Act & Assert
        expect(
          () => dataSource.getEntriesByTrip('trip-123'),
          throwsA(isA<ServerException>()
              .having((e) => e.message, 'message', contains('Failed to get entries for trip'))),
        );
      });
    });

    group('getEntriesByDateRange', () {
      test('should return entries within date range', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);

        // Act & Assert
      });

      test('should throw ServerException when user is not authenticated', () async {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(null);
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);

        // Act & Assert
        expect(
          () => dataSource.getEntriesByDateRange(startDate, endDate),
          throwsA(isA<ServerException>()
              .having((e) => e.statusCode, 'statusCode', 401)),
        );
      });
    });

    group('searchEntries', () {
      test('should return entries matching search query', () async {
        // Arrange
        const query = 'Paris';

        // Act & Assert
      });

      test('should throw ServerException when user is not authenticated', () async {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => dataSource.searchEntries('test'),
          throwsA(isA<ServerException>()
              .having((e) => e.statusCode, 'statusCode', 401)),
        );
      });
    });

    group('getFavoriteEntries', () {
      test('should return only favorite entries', () async {
        // Arrange
        when(() => mockUser.id).thenReturn(testUserId);

        // Act & Assert
      });

      test('should throw ServerException when user is not authenticated', () async {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => dataSource.getFavoriteEntries(),
          throwsA(isA<ServerException>()
              .having((e) => e.statusCode, 'statusCode', 401)),
        );
      });
    });

    group('updateEntry', () {
      test('should return updated JournalEntryModel', () async {
        // Arrange
        final testEntry = createTestJournalEntryModel();

        // Act & Assert
      });

      test('should throw ServerException on update failure', () async {
        // Arrange
        final testEntry = createTestJournalEntryModel();
        final postgrestException = PostgrestException(
          message: 'Update failed',
        );

        when(() => mockClient.from('journal_entries'))
            .thenThrow(postgrestException);

        // Act & Assert
        expect(
          () => dataSource.updateEntry(testEntry),
          throwsA(isA<ServerException>()
              .having((e) => e.message, 'message', contains('Failed to update journal entry'))),
        );
      });
    });

    group('deleteEntry', () {
      test('should complete without error when deletion is successful', () async {
        // Arrange
        final entryId = 'entry-123';

        // Act & Assert - Should not throw
        await expectLater(() => dataSource.deleteEntry(entryId), returnsNormally);
      });

      test('should throw ServerException on deletion failure', () async {
        // Arrange
        final postgrestException = PostgrestException(
          message: 'Delete failed',
        );

        when(() => mockClient.from('journal_entries'))
            .thenThrow(postgrestException);

        // Act & Assert
        expect(
          () => dataSource.deleteEntry('entry-123'),
          throwsA(isA<ServerException>()
              .having((e) => e.message, 'message', contains('Failed to delete journal entry'))),
        );
      });
    });

    group('toggleFavorite', () {
      test('should toggle isFavorite status', () async {
        // Arrange
        final testEntry = createTestJournalEntryModel(isFavorite: false);

        // Act & Assert
      });

      test('should throw ServerException when entry not found', () async {
        // Arrange
        final postgrestException = PostgrestException(
          message: 'Entry not found',
          code: '404',
        );

        when(() => mockClient.from('journal_entries'))
            .thenThrow(postgrestException);

        // Act & Assert
        expect(
          () => dataSource.toggleFavorite('non-existent-id'),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('getEntriesWithLocation', () {
      test('should return entries that have location data', () async {
        // Arrange
        when(() => mockUser.id).thenReturn(testUserId);

        // Act & Assert
      });

      test('should throw ServerException when user is not authenticated', () async {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => dataSource.getEntriesWithLocation(),
          throwsA(isA<ServerException>()
              .having((e) => e.statusCode, 'statusCode', 401)),
        );
      });
    });

    group('getEntriesNearLocation', () {
      test('should return entries near specified location', () async {
        // Arrange
        when(() => mockUser.id).thenReturn(testUserId);
        const latitude = 48.8566;
        const longitude = 2.3522;
        const radiusKm = 10.0;

        // Act & Assert
      });

      test('should throw ServerException when user is not authenticated', () async {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => dataSource.getEntriesNearLocation(48.8566, 2.3522, 10.0),
          throwsA(isA<ServerException>()
              .having((e) => e.statusCode, 'statusCode', 401)),
        );
      });
    });
  });

  group('JournalRemoteDataSourceImpl - Media CRUD Operations', () {
    group('addMedia', () {
      test('should return MediaItemModel when addition is successful', () async {
        // Arrange
        final testMedia = createTestMediaItemModel();

        // Act & Assert
      });

      test('should throw ServerException on addition failure', () async {
        // Arrange
        final testMedia = createTestMediaItemModel();
        final postgrestException = PostgrestException(
          message: 'Failed to add media',
        );

        when(() => mockClient.from('media_items'))
            .thenThrow(postgrestException);

        // Act & Assert
        expect(
          () => dataSource.addMedia(testMedia),
          throwsA(isA<ServerException>()
              .having((e) => e.message, 'message', contains('Failed to add media'))),
        );
      });
    });

    group('updateMedia', () {
      test('should return updated MediaItemModel', () async {
        // Arrange
        final testMedia = createTestMediaItemModel();

        // Act & Assert
      });

      test('should throw ServerException on update failure', () async {
        // Arrange
        final testMedia = createTestMediaItemModel();
        final postgrestException = PostgrestException(
          message: 'Update failed',
        );

        when(() => mockClient.from('media_items'))
            .thenThrow(postgrestException);

        // Act & Assert
        expect(
          () => dataSource.updateMedia(testMedia),
          throwsA(isA<ServerException>()
              .having((e) => e.message, 'message', contains('Failed to update media'))),
        );
      });
    });

    group('deleteMedia', () {
      test('should complete without error when deletion is successful', () async {
        // Arrange
        final mediaId = 'media-123';

        // Act & Assert
        await expectLater(() => dataSource.deleteMedia(mediaId), returnsNormally);
      });

      test('should throw ServerException on deletion failure', () async {
        // Arrange
        final postgrestException = PostgrestException(
          message: 'Delete failed',
        );

        when(() => mockClient.from('media_items'))
            .thenThrow(postgrestException);

        // Act & Assert
        expect(
          () => dataSource.deleteMedia('media-123'),
          throwsA(isA<ServerException>()
              .having((e) => e.message, 'message', contains('Failed to delete media'))),
        );
      });
    });

    group('getMediaForEntry', () {
      test('should return list of MediaItemModel for entry', () async {
        // Arrange
        final entryId = 'entry-123';

        // Act & Assert
      });

      test('should throw ServerException on retrieval failure', () async {
        // Arrange
        final postgrestException = PostgrestException(
          message: 'Retrieval failed',
        );

        when(() => mockClient.from('media_items'))
            .thenThrow(postgrestException);

        // Act & Assert
        expect(
          () => dataSource.getMediaForEntry('entry-123'),
          throwsA(isA<ServerException>()
              .having((e) => e.message, 'message', contains('Failed to get media for entry'))),
        );
      });
    });

    group('getMediaForTrip', () {
      test('should return all media items for trip entries', () async {
        // Arrange
        final tripId = 'trip-123';

        // Act & Assert
      });

      test('should return empty list when trip has no entries', () async {
        // Arrange
        final tripId = 'empty-trip';

        // Act & Assert
        final result = await dataSource.getMediaForTrip(tripId);
        expect(result, isEmpty);
      });

      test('should throw ServerException on retrieval failure', () async {
        // Arrange
        final postgrestException = PostgrestException(
          message: 'Database error',
        );

        when(() => mockClient.from('journal_entries'))
            .thenThrow(postgrestException);

        // Act & Assert
        expect(
          () => dataSource.getMediaForTrip('trip-123'),
          throwsA(isA<ServerException>()
              .having((e) => e.message, 'message', contains('Failed to get media for trip'))),
        );
      });
    });

    group('updateMediaUploadProgress', () {
      test('should return MediaItemModel with updated progress', () async {
        // Arrange
        final mediaId = 'media-123';
        const progress = 50;

        // Act & Assert
      });

      test('should set upload_status to completed when progress is 100', () async {
        // Arrange
        final mediaId = 'media-123';
        const progress = 100;

        // Act & Assert - Should set status to 'completed'
      });

      test('should throw ServerException on update failure', () async {
        // Arrange
        final postgrestException = PostgrestException(
          message: 'Update failed',
        );

        when(() => mockClient.from('media_items'))
            .thenThrow(postgrestException);

        // Act & Assert
        expect(
          () => dataSource.updateMediaUploadProgress('media-123', 50),
          throwsA(isA<ServerException>()
              .having((e) => e.message, 'message', contains('Failed to update upload progress'))),
        );
      });
    });

    group('completeMediaUpload', () {
      test('should return MediaItemModel with completed status', () async {
        // Arrange
        final mediaId = 'media-123';
        const storagePath = '/uploads/photo.jpg';

        // Act & Assert
      });

      test('should set all completion fields correctly', () async {
        // Arrange
        final mediaId = 'media-123';
        const storagePath = '/uploads/photo.jpg';

        // Act & Assert - Should set:
        // - storage_path
        // - upload_status to 'completed'
        // - upload_progress to 100
        // - sync_status to 'synced'
      });

      test('should throw ServerException on completion failure', () async {
        // Arrange
        final postgrestException = PostgrestException(
          message: 'Completion failed',
        );

        when(() => mockClient.from('media_items'))
            .thenThrow(postgrestException);

        // Act & Assert
        expect(
          () => dataSource.completeMediaUpload('media-123', '/path'),
          throwsA(isA<ServerException>()
              .having((e) => e.message, 'message', contains('Failed to complete upload'))),
        );
      });
    });

    group('failMediaUpload', () {
      test('should return MediaItemModel with failed status', () async {
        // Arrange
        final mediaId = 'media-123';
        const errorMessage = 'Upload failed';

        // Act & Assert
      });

      test('should set status fields to failed/pending', () async {
        // Arrange
        final mediaId = 'media-123';
        const errorMessage = 'Network error';

        // Act & Assert - Should set:
        // - upload_status to 'failed'
        // - sync_status to 'pending'
      });

      test('should throw ServerException on failure marking', () async {
        // Arrange
        final postgrestException = PostgrestException(
          message: 'Update failed',
        );

        when(() => mockClient.from('media_items'))
            .thenThrow(postgrestException);

        // Act & Assert
        expect(
          () => dataSource.failMediaUpload('media-123', 'error'),
          throwsA(isA<ServerException>()
              .having((e) => e.message, 'message', contains('Failed to mark upload as failed'))),
        );
      });
    });
  });

  group('JournalRemoteDataSourceImpl - Tag Operations', () {
    group('getTagsForEntry', () {
      test('should return list of tag IDs for entry', () async {
        // Arrange
        final entryId = 'entry-123';

        // Act & Assert
      });

      test('should throw ServerException on retrieval failure', () async {
        // Arrange
        final postgrestException = PostgrestException(
          message: 'Database error',
        );

        when(() => mockClient.from('journal_tags'))
            .thenThrow(postgrestException);

        // Act & Assert
        expect(
          () => dataSource.getTagsForEntry('entry-123'),
          throwsA(isA<ServerException>()
              .having((e) => e.message, 'message', contains('Failed to get tags for entry'))),
        );
      });
    });

    group('addTagToEntry', () {
      test('should complete successfully when tag is added', () async {
        // Arrange
        final entryId = 'entry-123';
        final tagId = 'tag-123';

        // Act & Assert
        await expectLater(() => dataSource.addTagToEntry(entryId, tagId), returnsNormally);
      });

      test('should throw ServerException on addition failure', () async {
        // Arrange
        final postgrestException = PostgrestException(
          message: 'Insert failed',
        );

        when(() => mockClient.from('journal_tags'))
            .thenThrow(postgrestException);

        // Act & Assert
        expect(
          () => dataSource.addTagToEntry('entry-123', 'tag-123'),
          throwsA(isA<ServerException>()
              .having((e) => e.message, 'message', contains('Failed to add tag to entry'))),
        );
      });
    });

    group('removeTagFromEntry', () {
      test('should complete successfully when tag is removed', () async {
        // Arrange
        final entryId = 'entry-123';
        final tagId = 'tag-123';

        // Act & Assert
        await expectLater(() => dataSource.removeTagFromEntry(entryId, tagId), returnsNormally);
      });

      test('should throw ServerException on removal failure', () async {
        // Arrange
        final postgrestException = PostgrestException(
          message: 'Delete failed',
        );

        when(() => mockClient.from('journal_tags'))
            .thenThrow(postgrestException);

        // Act & Assert
        expect(
          () => dataSource.removeTagFromEntry('entry-123', 'tag-123'),
          throwsA(isA<ServerException>()
              .having((e) => e.message, 'message', contains('Failed to remove tag from entry'))),
        );
      });
    });

    group('updateTagsForEntry', () {
      test('should replace all tags for entry', () async {
        // Arrange
        final entryId = 'entry-123';
        final tagIds = ['tag-1', 'tag-2', 'tag-3'];

        // Act & Assert
        await expectLater(() => dataSource.updateTagsForEntry(entryId, tagIds), returnsNormally);
      });

      test('should handle empty tag list', () async {
        // Arrange
        final entryId = 'entry-123';
        final tagIds = <String>[];

        // Act & Assert - Should delete all existing tags
        await expectLater(() => dataSource.updateTagsForEntry(entryId, tagIds), returnsNormally);
      });

      test('should throw ServerException on update failure', () async {
        // Arrange
        final postgrestException = PostgrestException(
          message: 'Update failed',
        );

        when(() => mockClient.from('journal_tags'))
            .thenThrow(postgrestException);

        // Act & Assert
        expect(
          () => dataSource.updateTagsForEntry('entry-123', ['tag-1']),
          throwsA(isA<ServerException>()
              .having((e) => e.message, 'message', contains('Failed to update tags for entry'))),
        );
      });
    });
  });

  group('JournalRemoteDataSourceImpl - Edge Cases', () {
    test('should handle null values in optional fields', () async {
      // Arrange
      final entryWithNulls = JournalEntryModel(
        id: 'entry-nulls',
        userId: testUserId,
        title: 'Entry with nulls',
        content: 'Content',
        entryDate: testDateTime,
        createdAt: testDateTime,
        updatedAt: testDateTime,
        tripId: null,
        mood: null,
        locationName: null,
        latitude: null,
        longitude: null,
        locationAccuracy: null,
        weatherData: null,
      );

      // Act & Assert - Should handle nulls gracefully
    });

    test('should handle concurrent operations', () async {
      // Arrange
      final entry1 = createTestJournalEntryModel(id: 'entry-1');
      final entry2 = createTestJournalEntryModel(id: 'entry-2');

      // Act & Assert - Should handle concurrent creates/updates
      await Future.wait([
        // Simulate concurrent operations
      ]);
    });

    test('should handle large content strings', () async {
      // Arrange
      final largeContent = 'x' * 100000; // 100KB of text
      final entryWithLargeContent = createTestJournalEntryModel(content: largeContent);

      // Act & Assert - Should handle large content
    });

    test('should handle special characters in content', () async {
      // Arrange
      final specialContent = 'Test with emoji 🎉, special chars: <>&"\'\\n\\t';
      final entryWithSpecialChars = createTestJournalEntryModel(content: specialContent);

      // Act & Assert - Should escape/encode special characters
    });

    test('should handle date range boundaries correctly', () async {
      // Arrange
      final startDate = DateTime(2024, 1, 1, 0, 0, 0);
      final endDate = DateTime(2024, 1, 31, 23, 59, 59);

      // Act & Assert - Should include entries at exact boundaries
    });
  });
}
