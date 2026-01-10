import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/journal/data/datasources/journal_remote_data_source.dart';
import 'package:soloadventurer/features/journal/data/models/journal_entry_model.dart';
import 'package:soloadventurer/features/journal/data/models/media_item_model.dart';
import 'package:soloadventurer/features/journal/data/repositories/journal_repository_impl.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';
import 'package:soloadventurer/features/journal/domain/entities/media_item.dart';
import 'package:soloadventurer/features/journal/helpers/journal_test_helpers.dart';
import '../../../../test_constants.dart';

class MockJournalRemoteDataSource extends Mock
    implements JournalRemoteDataSource {}

void main() {
  late MockJournalRemoteDataSource mockRemoteDataSource;
  late JournalRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockJournalRemoteDataSource();
    repository = JournalRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
    );

    // Register fallback values
    registerFallbackValue(createTestJournalEntryModel());
    registerFallbackValue(createTestMediaItemModel());
  });

  group('JournalRepositoryImpl - Entry CRUD Operations', () {
    group('createEntry', () {
      test('should return JournalEntry when creation is successful', () async {
        // Arrange
        final testEntity = createTestJournalEntry();
        final testModel = createTestJournalEntryModel();
        when(() => mockRemoteDataSource.createEntry(any()))
            .thenAnswer((_) async => testModel);

        // Act
        final result = await repository.createEntry(testEntity);

        // Assert
        expect(result, isA<JournalEntry>());
        expect(result.id, equals(testEntity.id));
        expect(result.title, equals(testEntity.title));
        expect(result.content, equals(testEntity.content));
        verify(() => mockRemoteDataSource.createEntry(any())).called(1);
      });

      test('should throw AppException when data source throws ServerException',
          () async {
        // Arrange
        final testEntity = createTestJournalEntry();
        when(() => mockRemoteDataSource.createEntry(any())).thenThrow(
            const ServerException(message: 'Database error', statusCode: 500));

        // Act & Assert
        expect(
          () => repository.createEntry(testEntity),
          throwsA(isA<AppException>().having((e) => e.message, 'message',
              contains('Failed to create journal entry'))),
        );
      });

      test(
          'should throw AppException when data source throws generic exception',
          () async {
        // Arrange
        final testEntity = createTestJournalEntry();
        when(() => mockRemoteDataSource.createEntry(any()))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => repository.createEntry(testEntity),
          throwsA(isA<AppException>()),
        );
      });

      test('should convert entity to model before calling data source',
          () async {
        // Arrange
        final testEntity = createTestJournalEntry(title: 'Original Title');
        final testModel = createTestJournalEntryModel(title: 'Original Title');
        when(() => mockRemoteDataSource.createEntry(any()))
            .thenAnswer((_) async => testModel);

        // Act
        await repository.createEntry(testEntity);

        // Assert
        final captured =
            verify(() => mockRemoteDataSource.createEntry(captureAny()))
                .captured
                .single as JournalEntryModel;
        expect(captured.title, equals('Original Title'));
      });
    });

    group('getEntry', () {
      test('should return JournalEntry when entry exists', () async {
        // Arrange
        final testModel = createTestJournalEntryModel();
        when(() => mockRemoteDataSource.getEntry(any()))
            .thenAnswer((_) async => testModel);

        // Act
        final result = await repository.getEntry(testEntryId);

        // Assert
        expect(result, isA<JournalEntry>());
        expect(result.id, equals(testEntryId));
        verify(() => mockRemoteDataSource.getEntry(testEntryId)).called(1);
      });

      test('should throw AppException when entry not found', () async {
        // Arrange
        when(() => mockRemoteDataSource.getEntry(any())).thenThrow(
            const ServerException(message: 'Not found', statusCode: 404));

        // Act & Assert
        expect(
          () => repository.getEntry('non-existent-id'),
          throwsA(isA<AppException>().having((e) => e.message, 'message',
              contains('Failed to get journal entry'))),
        );
      });

      test('should rethrow AppException from data source', () async {
        // Arrange
        when(() => mockRemoteDataSource.getEntry(any()))
            .thenThrow(const AppException('Custom error'));

        // Act & Assert
        expect(
          () => repository.getEntry(testEntryId),
          throwsA(isA<AppException>()
              .having((e) => e.message, 'message', 'Custom error')),
        );
      });
    });

    group('getEntries', () {
      test('should return list of JournalEntry when entries exist', () async {
        // Arrange
        final testModels = createTestJournalEntryList(count: 3);
        when(() => mockRemoteDataSource.getEntries())
            .thenAnswer((_) async => testModels);

        // Act
        final result = await repository.getEntries();

        // Assert
        expect(result, isA<List<JournalEntry>>());
        expect(result.length, equals(3));
        expect(result, everyElement(isA<JournalEntry>()));
        verify(() => mockRemoteDataSource.getEntries()).called(1);
      });

      test('should return empty list when no entries exist', () async {
        // Arrange
        when(() => mockRemoteDataSource.getEntries())
            .thenAnswer((_) async => <JournalEntryModel>[]);

        // Act
        final result = await repository.getEntries();

        // Assert
        expect(result, isEmpty);
      });

      test('should throw AppException on data source error', () async {
        // Arrange
        when(() => mockRemoteDataSource.getEntries()).thenThrow(
            const ServerException(message: 'Database error', statusCode: 500));

        // Act & Assert
        expect(
          () => repository.getEntries(),
          throwsA(isA<AppException>()),
        );
      });

      test('should convert all models to entities', () async {
        // Arrange
        final testModels = createTestJournalEntryList(count: 3);
        when(() => mockRemoteDataSource.getEntries())
            .thenAnswer((_) async => testModels);

        // Act
        final result = await repository.getEntries();

        // Assert
        for (var i = 0; i < result.length; i++) {
          expect(result[i].id, equals(testModels[i].id));
          expect(result[i].title, equals(testModels[i].title));
        }
      });
    });

    group('getEntriesByTrip', () {
      test('should return entries for specified trip', () async {
        // Arrange
        final testModels = createTestJournalEntryList(count: 2);
        when(() => mockRemoteDataSource.getEntriesByTrip(any()))
            .thenAnswer((_) async => testModels);

        // Act
        final result = await repository.getEntriesByTrip(testTripId);

        // Assert
        expect(result.length, equals(2));
        verify(() => mockRemoteDataSource.getEntriesByTrip(testTripId))
            .called(1);
      });

      test('should throw AppException on error', () async {
        // Arrange
        when(() => mockRemoteDataSource.getEntriesByTrip(any())).thenThrow(
            const ServerException(message: 'Trip not found', statusCode: 404));

        // Act & Assert
        expect(
          () => repository.getEntriesByTrip('invalid-trip-id'),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('getEntriesByDateRange', () {
      test('should return entries within date range', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);
        final testModels = createTestJournalEntryList(count: 2);
        when(() => mockRemoteDataSource.getEntriesByDateRange(any(), any()))
            .thenAnswer((_) async => testModels);

        // Act
        final result =
            await repository.getEntriesByDateRange(startDate, endDate);

        // Assert
        expect(result.length, equals(2));
        verify(() =>
                mockRemoteDataSource.getEntriesByDateRange(startDate, endDate))
            .called(1);
      });

      test('should handle invalid date ranges', () async {
        // Arrange
        final startDate = DateTime(2024, 12, 31);
        final endDate = DateTime(2024, 1, 1); // End before start
        when(() => mockRemoteDataSource.getEntriesByDateRange(any(), any()))
            .thenAnswer((_) async => <JournalEntryModel>[]);

        // Act
        final result =
            await repository.getEntriesByDateRange(startDate, endDate);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('searchEntries', () {
      test('should return entries matching search query', () async {
        // Arrange
        const query = 'Paris';
        final testModels = createTestJournalEntryList(count: 1);
        when(() => mockRemoteDataSource.searchEntries(any()))
            .thenAnswer((_) async => testModels);

        // Act
        final result = await repository.searchEntries(query);

        // Assert
        expect(result.length, equals(1));
        verify(() => mockRemoteDataSource.searchEntries(query)).called(1);
      });

      test('should handle empty search query', () async {
        // Arrange
        const query = '';
        when(() => mockRemoteDataSource.searchEntries(any()))
            .thenAnswer((_) async => <JournalEntryModel>[]);

        // Act
        final result = await repository.searchEntries(query);

        // Assert
        expect(result, isEmpty);
      });

      test('should handle special characters in query', () async {
        // Arrange
        const query = 'test & query + "quotes"';
        when(() => mockRemoteDataSource.searchEntries(any()))
            .thenAnswer((_) async => <JournalEntryModel>[]);

        // Act
        final result = await repository.searchEntries(query);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getFavoriteEntries', () {
      test('should return only favorite entries', () async {
        // Arrange
        final testModels = [
          createTestJournalEntryModel(id: 'entry-1', isFavorite: true),
          createTestJournalEntryModel(id: 'entry-2', isFavorite: true),
        ];
        when(() => mockRemoteDataSource.getFavoriteEntries())
            .thenAnswer((_) async => testModels);

        // Act
        final result = await repository.getFavoriteEntries();

        // Assert
        expect(result.length, equals(2));
        expect(result, everyElement(predicate((e) => e.isFavorite)));
      });

      test('should return empty list when no favorites exist', () async {
        // Arrange
        when(() => mockRemoteDataSource.getFavoriteEntries())
            .thenAnswer((_) async => <JournalEntryModel>[]);

        // Act
        final result = await repository.getFavoriteEntries();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('updateEntry', () {
      test('should return updated JournalEntry', () async {
        // Arrange
        final testEntity = createTestJournalEntry(title: 'Updated Title');
        final testModel = createTestJournalEntryModel(title: 'Updated Title');
        when(() => mockRemoteDataSource.updateEntry(any()))
            .thenAnswer((_) async => testModel);

        // Act
        final result = await repository.updateEntry(testEntity);

        // Assert
        expect(result.title, equals('Updated Title'));
        verify(() => mockRemoteDataSource.updateEntry(any())).called(1);
      });

      test('should throw AppException on update failure', () async {
        // Arrange
        final testEntity = createTestJournalEntry();
        when(() => mockRemoteDataSource.updateEntry(any())).thenThrow(
            const ServerException(message: 'Update failed', statusCode: 500));

        // Act & Assert
        expect(
          () => repository.updateEntry(testEntity),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('deleteEntry', () {
      test('should complete successfully when deletion works', () async {
        // Arrange
        when(() => mockRemoteDataSource.deleteEntry(any()))
            .thenAnswer((_) async {});

        // Act & Assert
        await expectLater(
            () => repository.deleteEntry(testEntryId), returnsNormally);
        verify(() => mockRemoteDataSource.deleteEntry(testEntryId)).called(1);
      });

      test('should throw AppException on deletion failure', () async {
        // Arrange
        when(() => mockRemoteDataSource.deleteEntry(any())).thenThrow(
            const ServerException(message: 'Delete failed', statusCode: 500));

        // Act & Assert
        expect(
          () => repository.deleteEntry(testEntryId),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('toggleFavorite', () {
      test('should toggle isFavorite from false to true', () async {
        // Arrange
        final originalModel = createTestJournalEntryModel(isFavorite: false);
        final updatedModel = createTestJournalEntryModel(isFavorite: true);
        when(() => mockRemoteDataSource.toggleFavorite(any()))
            .thenAnswer((_) async => updatedModel);

        // Act
        final result = await repository.toggleFavorite(testEntryId);

        // Assert
        expect(result.isFavorite, isTrue);
        verify(() => mockRemoteDataSource.toggleFavorite(testEntryId))
            .called(1);
      });

      test('should toggle isFavorite from true to false', () async {
        // Arrange
        final originalModel = createTestJournalEntryModel(isFavorite: true);
        final updatedModel = createTestJournalEntryModel(isFavorite: false);
        when(() => mockRemoteDataSource.toggleFavorite(any()))
            .thenAnswer((_) async => updatedModel);

        // Act
        final result = await repository.toggleFavorite(testEntryId);

        // Assert
        expect(result.isFavorite, isFalse);
      });

      test('should throw AppException when entry not found', () async {
        // Arrange
        when(() => mockRemoteDataSource.toggleFavorite(any())).thenThrow(
            const ServerException(message: 'Not found', statusCode: 404));

        // Act & Assert
        expect(
          () => repository.toggleFavorite('non-existent-id'),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('getEntriesWithLocation', () {
      test('should return entries with location data', () async {
        // Arrange
        final testModels = [
          createTestJournalEntryModel(
            id: 'entry-1',
            latitude: 48.8566,
            longitude: 2.3522,
          ),
        ];
        when(() => mockRemoteDataSource.getEntriesWithLocation())
            .thenAnswer((_) async => testModels);

        // Act
        final result = await repository.getEntriesWithLocation();

        // Assert
        expect(result.length, equals(1));
        expect(result.first.latitude, equals(48.8566));
        expect(result.first.longitude, equals(2.3522));
      });

      test('should return empty list when no entries have location', () async {
        // Arrange
        when(() => mockRemoteDataSource.getEntriesWithLocation())
            .thenAnswer((_) async => <JournalEntryModel>[]);

        // Act
        final result = await repository.getEntriesWithLocation();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getEntriesNearLocation', () {
      test('should return entries within radius', () async {
        // Arrange
        const latitude = 48.8566;
        const longitude = 2.3522;
        const radiusKm = 10.0;
        final testModels = createTestJournalEntryList(count: 2);
        when(() => mockRemoteDataSource.getEntriesNearLocation(
            any(), any(), any())).thenAnswer((_) async => testModels);

        // Act
        final result = await repository.getEntriesNearLocation(
          latitude,
          longitude,
          radiusKm,
        );

        // Assert
        expect(result.length, equals(2));
        verify(() => mockRemoteDataSource.getEntriesNearLocation(
              latitude,
              longitude,
              radiusKm,
            )).called(1);
      });

      test('should handle zero radius', () async {
        // Arrange
        when(() => mockRemoteDataSource.getEntriesNearLocation(
                any(), any(), any()))
            .thenAnswer((_) async => <JournalEntryModel>[]);

        // Act
        final result =
            await repository.getEntriesNearLocation(48.8566, 2.3522, 0.0);

        // Assert
        expect(result, isEmpty);
      });

      test('should handle very large radius', () async {
        // Arrange
        const largeRadius = 100000.0; // 100,000 km
        when(() => mockRemoteDataSource.getEntriesNearLocation(
                any(), any(), any()))
            .thenAnswer((_) async => <JournalEntryModel>[]);

        // Act
        final result = await repository.getEntriesNearLocation(
          48.8566,
          2.3522,
          largeRadius,
        );

        // Assert
        expect(result, isEmpty);
      });
    });
  });

  group('JournalRepositoryImpl - Media CRUD Operations', () {
    group('addMedia', () {
      test('should return MediaItem when addition is successful', () async {
        // Arrange
        final testEntity = createTestMediaItem();
        final testModel = createTestMediaItemModel();
        when(() => mockRemoteDataSource.addMedia(any()))
            .thenAnswer((_) async => testModel);

        // Act
        final result = await repository.addMedia(testEntity);

        // Assert
        expect(result, isA<MediaItem>());
        expect(result.id, equals(testEntity.id));
        verify(() => mockRemoteDataSource.addMedia(any())).called(1);
      });

      test('should throw AppException on addition failure', () async {
        // Arrange
        final testEntity = createTestMediaItem();
        when(() => mockRemoteDataSource.addMedia(any())).thenThrow(
            const ServerException(message: 'Add failed', statusCode: 500));

        // Act & Assert
        expect(
          () => repository.addMedia(testEntity),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('updateMedia', () {
      test('should return updated MediaItem', () async {
        // Arrange
        final testEntity = createTestMediaItem(caption: 'Updated caption');
        final testModel = createTestMediaItemModel(caption: 'Updated caption');
        when(() => mockRemoteDataSource.updateMedia(any()))
            .thenAnswer((_) async => testModel);

        // Act
        final result = await repository.updateMedia(testEntity);

        // Assert
        expect(result.caption, equals('Updated caption'));
      });

      test('should throw AppException on update failure', () async {
        // Arrange
        final testEntity = createTestMediaItem();
        when(() => mockRemoteDataSource.updateMedia(any())).thenThrow(
            const ServerException(message: 'Update failed', statusCode: 500));

        // Act & Assert
        expect(
          () => repository.updateMedia(testEntity),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('deleteMedia', () {
      test('should complete successfully when deletion works', () async {
        // Arrange
        when(() => mockRemoteDataSource.deleteMedia(any()))
            .thenAnswer((_) async {});

        // Act & Assert
        await expectLater(
            () => repository.deleteMedia(testMediaId), returnsNormally);
        verify(() => mockRemoteDataSource.deleteMedia(testMediaId)).called(1);
      });

      test('should throw AppException on deletion failure', () async {
        // Arrange
        when(() => mockRemoteDataSource.deleteMedia(any())).thenThrow(
            const ServerException(message: 'Delete failed', statusCode: 500));

        // Act & Assert
        expect(
          () => repository.deleteMedia(testMediaId),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('getMediaForEntry', () {
      test('should return list of MediaItem for entry', () async {
        // Arrange
        final testModels = createTestMediaItemList(count: 3);
        when(() => mockRemoteDataSource.getMediaForEntry(any()))
            .thenAnswer((_) async => testModels);

        // Act
        final result = await repository.getMediaForEntry(testEntryId);

        // Assert
        expect(result.length, equals(3));
        expect(result, everyElement(isA<MediaItem>()));
        verify(() => mockRemoteDataSource.getMediaForEntry(testEntryId))
            .called(1);
      });

      test('should return empty list when entry has no media', () async {
        // Arrange
        when(() => mockRemoteDataSource.getMediaForEntry(any()))
            .thenAnswer((_) async => <MediaItemModel>[]);

        // Act
        final result = await repository.getMediaForEntry(testEntryId);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getMediaForTrip', () {
      test('should return all media for trip entries', () async {
        // Arrange
        final testModels = createTestMediaItemList(count: 5);
        when(() => mockRemoteDataSource.getMediaForTrip(any()))
            .thenAnswer((_) async => testModels);

        // Act
        final result = await repository.getMediaForTrip(testTripId);

        // Assert
        expect(result.length, equals(5));
        verify(() => mockRemoteDataSource.getMediaForTrip(testTripId))
            .called(1);
      });

      test('should return empty list when trip has no media', () async {
        // Arrange
        when(() => mockRemoteDataSource.getMediaForTrip(any()))
            .thenAnswer((_) async => <MediaItemModel>[]);

        // Act
        final result = await repository.getMediaForTrip(testTripId);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('updateMediaUploadProgress', () {
      test('should return MediaItem with updated progress', () async {
        // Arrange
        const progress = 50;
        final testModel = createTestMediaItemModel(uploadProgress: progress);
        when(() => mockRemoteDataSource.updateMediaUploadProgress(any(), any()))
            .thenAnswer((_) async => testModel);

        // Act
        final result =
            await repository.updateMediaUploadProgress(testMediaId, progress);

        // Assert
        expect(result.uploadProgress, equals(progress));
        verify(() => mockRemoteDataSource.updateMediaUploadProgress(
            testMediaId, progress)).called(1);
      });

      test('should handle progress = 0', () async {
        // Arrange
        const progress = 0;
        final testModel = createTestMediaItemModel(uploadProgress: progress);
        when(() => mockRemoteDataSource.updateMediaUploadProgress(any(), any()))
            .thenAnswer((_) async => testModel);

        // Act
        final result =
            await repository.updateMediaUploadProgress(testMediaId, progress);

        // Assert
        expect(result.uploadProgress, equals(0));
      });

      test('should handle progress = 100', () async {
        // Arrange
        const progress = 100;
        final testModel = createTestMediaItemModel(uploadProgress: progress);
        when(() => mockRemoteDataSource.updateMediaUploadProgress(any(), any()))
            .thenAnswer((_) async => testModel);

        // Act
        final result =
            await repository.updateMediaUploadProgress(testMediaId, progress);

        // Assert
        expect(result.uploadProgress, equals(100));
      });
    });

    group('completeMediaUpload', () {
      test('should return MediaItem with completed status', () async {
        // Arrange
        const storagePath = '/uploads/photo.jpg';
        final testModel = createTestMediaItemModel(
          storagePath: storagePath,
          uploadStatus: UploadStatus.completed,
        );
        when(() => mockRemoteDataSource.completeMediaUpload(any(), any()))
            .thenAnswer((_) async => testModel);

        // Act
        final result =
            await repository.completeMediaUpload(testMediaId, storagePath);

        // Assert
        expect(result.storagePath, equals(storagePath));
        expect(result.uploadStatus, equals(UploadStatus.completed));
        verify(() => mockRemoteDataSource.completeMediaUpload(
            testMediaId, storagePath)).called(1);
      });

      test('should throw AppException on completion failure', () async {
        // Arrange
        when(() => mockRemoteDataSource.completeMediaUpload(any(), any()))
            .thenThrow(const ServerException(
                message: 'Completion failed', statusCode: 500));

        // Act & Assert
        expect(
          () => repository.completeMediaUpload(testMediaId, '/path'),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('failMediaUpload', () {
      test('should return MediaItem with failed status', () async {
        // Arrange
        const errorMessage = 'Network error';
        final testModel =
            createTestMediaItemModel(uploadStatus: UploadStatus.failed);
        when(() => mockRemoteDataSource.failMediaUpload(any(), any()))
            .thenAnswer((_) async => testModel);

        // Act
        final result =
            await repository.failMediaUpload(testMediaId, errorMessage);

        // Assert
        expect(result.uploadStatus, equals(UploadStatus.failed));
        verify(() =>
                mockRemoteDataSource.failMediaUpload(testMediaId, errorMessage))
            .called(1);
      });
    });
  });

  group('JournalRepositoryImpl - Tag Operations', () {
    group('getTagsForEntry', () {
      test('should return list of tag IDs', () async {
        // Arrange
        final tagIds = ['tag-1', 'tag-2', 'tag-3'];
        when(() => mockRemoteDataSource.getTagsForEntry(any()))
            .thenAnswer((_) async => tagIds);

        // Act
        final result = await repository.getTagsForEntry(testEntryId);

        // Assert
        expect(result.length, equals(3));
        expect(result, equals(tagIds));
        verify(() => mockRemoteDataSource.getTagsForEntry(testEntryId))
            .called(1);
      });

      test('should return empty list when entry has no tags', () async {
        // Arrange
        when(() => mockRemoteDataSource.getTagsForEntry(any()))
            .thenAnswer((_) async => <String>[]);

        // Act
        final result = await repository.getTagsForEntry(testEntryId);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('addTagToEntry', () {
      test('should complete successfully', () async {
        // Arrange
        when(() => mockRemoteDataSource.addTagToEntry(any(), any()))
            .thenAnswer((_) async {});

        // Act & Assert
        await expectLater(
          () => repository.addTagToEntry(testEntryId, testTagId),
          returnsNormally,
        );
        verify(() => mockRemoteDataSource.addTagToEntry(testEntryId, testTagId))
            .called(1);
      });

      test('should throw AppException on failure', () async {
        // Arrange
        when(() => mockRemoteDataSource.addTagToEntry(any(), any())).thenThrow(
            const ServerException(message: 'Add failed', statusCode: 500));

        // Act & Assert
        expect(
          () => repository.addTagToEntry(testEntryId, testTagId),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('removeTagFromEntry', () {
      test('should complete successfully', () async {
        // Arrange
        when(() => mockRemoteDataSource.removeTagFromEntry(any(), any()))
            .thenAnswer((_) async {});

        // Act & Assert
        await expectLater(
          () => repository.removeTagFromEntry(testEntryId, testTagId),
          returnsNormally,
        );
        verify(() =>
                mockRemoteDataSource.removeTagFromEntry(testEntryId, testTagId))
            .called(1);
      });

      test('should throw AppException on failure', () async {
        // Arrange
        when(() => mockRemoteDataSource.removeTagFromEntry(any(), any()))
            .thenThrow(const ServerException(
                message: 'Remove failed', statusCode: 500));

        // Act & Assert
        expect(
          () => repository.removeTagFromEntry(testEntryId, testTagId),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('updateTagsForEntry', () {
      test('should replace all tags successfully', () async {
        // Arrange
        final tagIds = ['tag-1', 'tag-2', 'tag-3'];
        when(() => mockRemoteDataSource.updateTagsForEntry(any(), any()))
            .thenAnswer((_) async {});

        // Act & Assert
        await expectLater(
          () => repository.updateTagsForEntry(testEntryId, tagIds),
          returnsNormally,
        );
        verify(() =>
                mockRemoteDataSource.updateTagsForEntry(testEntryId, tagIds))
            .called(1);
      });

      test('should handle empty tag list', () async {
        // Arrange
        final tagIds = <String>[];
        when(() => mockRemoteDataSource.updateTagsForEntry(any(), any()))
            .thenAnswer((_) async {});

        // Act & Assert
        await expectLater(
          () => repository.updateTagsForEntry(testEntryId, tagIds),
          returnsNormally,
        );
      });

      test('should throw AppException on failure', () async {
        // Arrange
        when(() => mockRemoteDataSource.updateTagsForEntry(any(), any()))
            .thenThrow(const ServerException(
                message: 'Update failed', statusCode: 500));

        // Act & Assert
        expect(
          () => repository.updateTagsForEntry(testEntryId, ['tag-1']),
          throwsA(isA<AppException>()),
        );
      });
    });
  });

  group('JournalRepositoryImpl - Edge Cases', () {
    test('should handle null optional fields in entry', () async {
      // Arrange
      final entryWithNulls = JournalEntry(
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
      final testModel = JournalEntryModel.fromEntity(entryWithNulls);
      when(() => mockRemoteDataSource.createEntry(any()))
          .thenAnswer((_) async => testModel);

      // Act
      final result = await repository.createEntry(entryWithNulls);

      // Assert
      expect(result.id, equals('entry-nulls'));
      expect(result.tripId, isNull);
      expect(result.mood, isNull);
    });

    test('should handle large content in entry', () async {
      // Arrange
      final largeContent = 'x' * 100000; // 100KB
      final entryWithLargeContent =
          createTestJournalEntry(content: largeContent);
      final testModel = createTestJournalEntryModel(content: largeContent);
      when(() => mockRemoteDataSource.createEntry(any()))
          .thenAnswer((_) async => testModel);

      // Act
      final result = await repository.createEntry(entryWithLargeContent);

      // Assert
      expect(result.content.length, equals(100000));
    });

    test('should handle special characters in content', () async {
      // Arrange
      const specialContent =
          'Test with emoji 🎉 and special chars: <>&"\'\\n\\t';
      final entryWithSpecial = createTestJournalEntry(content: specialContent);
      final testModel = createTestJournalEntryModel(content: specialContent);
      when(() => mockRemoteDataSource.createEntry(any()))
          .thenAnswer((_) async => testModel);

      // Act
      final result = await repository.createEntry(entryWithSpecial);

      // Assert
      expect(result.content, equals(specialContent));
    });

    test('should handle rapid successive operations', () async {
      // Arrange
      final entry1 = createTestJournalEntry(id: 'entry-1');
      final entry2 = createTestJournalEntry(id: 'entry-2');
      when(() => mockRemoteDataSource.createEntry(any()))
          .thenAnswer((_) async => createTestJournalEntryModel());

      // Act
      await repository.createEntry(entry1);
      await repository.createEntry(entry2);

      // Assert
      verify(() => mockRemoteDataSource.createEntry(any())).called(2);
    });

    test('should handle media with all null optional fields', () async {
      // Arrange
      final mediaWithNulls = MediaItem(
        id: 'media-nulls',
        userId: testUserId,
        journalEntryId: testEntryId,
        mediaType: MediaType.image,
        storagePath: '/path',
        createdAt: testDateTime,
        updatedAt: testDateTime,
        originalFilename: null,
        fileSize: null,
        mimeType: null,
        width: null,
        height: null,
        duration: null,
        thumbnailPath: null,
        caption: null,
        uploadStatus: UploadStatus.pending,
        uploadProgress: 0,
        exifData: null,
        isCover: false,
        orderIndex: 0,
      );
      final testModel = MediaItemModel.fromEntity(mediaWithNulls);
      when(() => mockRemoteDataSource.addMedia(any()))
          .thenAnswer((_) async => testModel);

      // Act
      final result = await repository.addMedia(mediaWithNulls);

      // Assert
      expect(result.id, equals('media-nulls'));
      expect(result.width, isNull);
      expect(result.height, isNull);
    });
  });
}
