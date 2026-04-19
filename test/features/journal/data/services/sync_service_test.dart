import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/journal/data/services/sync_service_impl.dart';
import 'package:soloadventurer/features/journal/domain/services/sync_service.dart';
import 'package:soloadventurer/features/journal/domain/entities/shared_link.dart';
import '../../helpers/sync_test_helpers.dart';

void main() {
  late SyncServiceImpl syncService;
  late MockJournalLocalDataSource mockJournalLocalDataSource;
  late MockJournalRemoteDataSource mockJournalRemoteDataSource;
  late MockTripLocalDataSource mockTripLocalDataSource;
  late MockTripRemoteDataSource mockTripRemoteDataSource;
  late MockTagLocalDataSource mockTagLocalDataSource;
  late MockTagRemoteDataSource mockTagRemoteDataSource;
  late MockConnectivityService mockConnectivityService;

  setUp(() {
    mockJournalLocalDataSource = MockJournalLocalDataSource();
    mockJournalRemoteDataSource = MockJournalRemoteDataSource();
    mockTripLocalDataSource = MockTripLocalDataSource();
    mockTripRemoteDataSource = MockTripRemoteDataSource();
    mockTagLocalDataSource = MockTagLocalDataSource();
    mockTagRemoteDataSource = MockTagRemoteDataSource();
    mockConnectivityService = MockConnectivityService();

    // Register fallback values for mocktail
    registerFallbackValue(createTestJournalEntryModel());
    registerFallbackValue(createTestTripModel());
    registerFallbackValue(createTestTagModel());

    syncService = SyncServiceImpl(
      journalLocalDataSource: mockJournalLocalDataSource,
      journalRemoteDataSource: mockJournalRemoteDataSource,
      tripLocalDataSource: mockTripLocalDataSource,
      tripRemoteDataSource: mockTripRemoteDataSource,
      tagLocalDataSource: mockTagLocalDataSource,
      tagRemoteDataSource: mockTagRemoteDataSource,
      connectivityService: mockConnectivityService,
    );

    // Default connectivity to be connected
    setupConnectivityConnected(mockConnectivityService);
  });

  group('SyncService - Initialization', () {
    test('should initialize without errors', () async {
      // Act & Assert
      expect(() => syncService.initialize(), returnsNormally);
    });

    test('should have correct initial state', () {
      // Assert
      expect(syncService.isSyncing, false);
      expect(syncService.lastSyncTime, null);
      expect(syncService.currentProgress.totalItems, 0);
    });

    test('should dispose correctly', () async {
      // Arrange
      await syncService.initialize();

      // Act & Assert
      expect(() => syncService.dispose(), returnsNormally);
    });
  });

  group('SyncService - syncAll', () {
    void setupEmptySyncStubs() {
      when(() => mockJournalLocalDataSource.getEntriesBySyncStatus('pending'))
          .thenAnswer((_) async => []);
      when(() => mockJournalRemoteDataSource.getEntries())
          .thenAnswer((_) async => []);
      when(() => mockTripLocalDataSource.getTripsBySyncStatus('pending'))
          .thenAnswer((_) async => []);
      when(() => mockTripRemoteDataSource.getTrips())
          .thenAnswer((_) async => []);
      when(() => mockTagLocalDataSource.getTagsBySyncStatus('pending'))
          .thenAnswer((_) async => []);
      when(() => mockTagRemoteDataSource.getTags())
          .thenAnswer((_) async => []);
      when(() => mockJournalLocalDataSource.getEntriesBySyncStatus('synced'))
          .thenAnswer((_) async => []);
      when(() => mockJournalLocalDataSource.getMediaBySyncStatus('pending'))
          .thenAnswer((_) async => []);
    }

    test('should sync all entities successfully when connected', () async {
      // Arrange
      setupEmptySyncStubs();

      // Act
      final result = await syncService.syncAll();

      // Assert
      expect(result.success, true);
      expect(result.operationType, SyncOperationType.full);
      expect(result.direction, SyncDirection.bidirectional);
      verify(() => mockJournalRemoteDataSource.getEntries()).called(1);
      verify(() => mockTripRemoteDataSource.getTrips()).called(1);
      verify(() => mockTagRemoteDataSource.getTags()).called(1);
    });

    test('should fail when not connected', () async {
      // Arrange
      setupConnectivityDisconnected(mockConnectivityService);

      // Act
      final result = await syncService.syncAll();

      // Assert
      expect(result.success, false);
      expect(result.errors.length, greaterThan(0));
      expect(result.errors.first, contains('No network connection'));
    });

    test('should sync entries, trips, tags, and media in order', () async {
      // Arrange
      setupEmptySyncStubs();

      final progressUpdates = <SyncProgress>[];
      syncService.progressStream.listen(progressUpdates.add);

      // Act
      await syncService.syncAll();

      // Assert
      expect(progressUpdates.length, greaterThanOrEqualTo(4));
      expect(
          progressUpdates[0].currentOperation, SyncOperationType.entries);
      expect(progressUpdates[1].currentOperation, SyncOperationType.trips);
      expect(progressUpdates[2].currentOperation, SyncOperationType.tags);
      expect(progressUpdates[3].currentOperation, SyncOperationType.media);
    });

    test('should update lastSyncTime on successful sync', () async {
      // Arrange
      setupEmptySyncStubs();

      expect(syncService.lastSyncTime, null);

      // Act
      await syncService.syncAll();

      // Assert
      expect(syncService.lastSyncTime, isNotNull);
      expect(syncService.lastSyncTime!.isBefore(DateTime.now()), true);
    });

    test('should use custom config when provided', () async {
      // Arrange
      const customConfig = SyncConfig(
        batchSize: 100,
        syncMedia: false,
        autoResolveConflicts: true,
      );

      when(() => mockJournalLocalDataSource.getEntriesBySyncStatus('pending'))
          .thenAnswer((_) async => []);
      when(() => mockJournalRemoteDataSource.getEntries())
          .thenAnswer((_) async => []);
      when(() => mockTripLocalDataSource.getTripsBySyncStatus('pending'))
          .thenAnswer((_) async => []);
      when(() => mockTripRemoteDataSource.getTrips())
          .thenAnswer((_) async => []);
      when(() => mockTagLocalDataSource.getTagsBySyncStatus('pending'))
          .thenAnswer((_) async => []);
      when(() => mockTagRemoteDataSource.getTags())
          .thenAnswer((_) async => []);

      // Act
      await syncService.syncAll(customConfig);

      // Assert - Media sync should be skipped
      verifyNever(
          () => mockJournalLocalDataSource.getMediaBySyncStatus('pending'));
    });
  });

  group('SyncService - syncEntries', () {
    test('should upload pending entries to remote', () async {
      // Arrange
      final pendingEntries = createPendingJournalEntries(count: 2);
      when(() => mockJournalLocalDataSource.getEntriesBySyncStatus('pending'))
          .thenAnswer((_) async => pendingEntries);

      // Setup remote to return 404 (entry doesn't exist)
      for (final entry in pendingEntries) {
        when(() => mockJournalRemoteDataSource.getEntry(entry.id)).thenThrow(
          const ServerException(message: 'Not found', statusCode: 404),
        );
        when(() => mockJournalRemoteDataSource.createEntry(entry))
            .thenAnswer((_) async => entry);
        when(() => mockJournalLocalDataSource.updateSyncStatus(
                entry.id, 'synced'))
            .thenAnswer((_) async => entry);
      }

      when(() => mockJournalRemoteDataSource.getEntries())
          .thenAnswer((_) async => []);

      // Act
      final result =
          await syncService.syncEntries(SyncDirection.upload);

      // Assert
      expect(result.success, true);
      expect(result.uploadedCount, 2);
      verify(() => mockJournalRemoteDataSource.createEntry(pendingEntries[0]))
          .called(1);
      verify(() => mockJournalRemoteDataSource.createEntry(pendingEntries[1]))
          .called(1);
      verify(() => mockJournalLocalDataSource.updateSyncStatus(
          pendingEntries[0].id, 'synced')).called(1);
      verify(() => mockJournalLocalDataSource.updateSyncStatus(
          pendingEntries[1].id, 'synced')).called(1);
    });

    test('should download remote entries', () async {
      // Arrange
      final remoteEntries = createSyncedJournalEntries(count: 2);
      when(() => mockJournalRemoteDataSource.getEntries())
          .thenAnswer((_) async => remoteEntries);

      // Setup local to return null (entry doesn't exist locally)
      for (final entry in remoteEntries) {
        when(() => mockJournalLocalDataSource.getEntry(entry.id))
            .thenAnswer((_) async => null);
        when(() => mockJournalLocalDataSource.createEntry(entry))
            .thenAnswer((_) async => entry);
      }

      // Act
      final result =
          await syncService.syncEntries(SyncDirection.download);

      // Assert
      expect(result.success, true);
      expect(result.downloadedCount, 2);
      verify(() => mockJournalLocalDataSource.createEntry(remoteEntries[0]))
          .called(1);
      verify(() => mockJournalLocalDataSource.createEntry(remoteEntries[1]))
          .called(1);
    });

    test(
        'should detect conflict when entry exists both locally and remotely',
        () async {
      // Arrange
      final pendingEntry = createTestJournalEntryModel(
        id: 'conflict-entry',
        syncStatus: SyncStatus.pending,
        updatedAt: testDateTime,
      );

      final remoteEntry = createTestJournalEntryModel(
        id: 'conflict-entry',
        title: 'Remote Title',
        updatedAt: testDateTimeLater,
      );

      when(() => mockJournalLocalDataSource.getEntriesBySyncStatus('pending'))
          .thenAnswer((_) async => [pendingEntry]);
      when(() => mockJournalRemoteDataSource.getEntry(pendingEntry.id))
          .thenAnswer((_) async => remoteEntry);

      final conflicts = <SyncConflict>[];
      syncService.conflictStream.listen(conflicts.add);

      // Act
      final result =
          await syncService.syncEntries(SyncDirection.upload);

      // Assert
      expect(result.success, true);
      expect(result.conflictCount, 1);

      // Allow stream events to propagate
      await Future.delayed(Duration.zero);
      expect(conflicts.length, 1);
      expect(conflicts.first.entityType, 'journal_entry');
      expect(conflicts.first.entityId, 'conflict-entry');
    });

    test('should update local entry if remote is newer', () async {
      // Arrange
      final localEntry = createTestJournalEntryModel(
        id: 'entry-1',
        title: 'Old Title',
        updatedAt: testDateTimeEarlier,
      );

      final remoteEntry = createTestJournalEntryModel(
        id: 'entry-1',
        title: 'New Title',
        updatedAt: testDateTimeLater,
      );

      when(() => mockJournalRemoteDataSource.getEntries())
          .thenAnswer((_) async => [remoteEntry]);
      when(() => mockJournalLocalDataSource.getEntry(localEntry.id))
          .thenAnswer((_) async => localEntry);
      when(() => mockJournalLocalDataSource.updateEntry(remoteEntry))
          .thenAnswer((_) async => remoteEntry);

      // Act
      final result =
          await syncService.syncEntries(SyncDirection.download);

      // Assert
      expect(result.success, true);
      expect(result.downloadedCount, 1);
      verify(() => mockJournalLocalDataSource.updateEntry(remoteEntry))
          .called(1);
    });

    test('should not update local entry if remote is older', () async {
      // Arrange
      final localEntry = createTestJournalEntryModel(
        id: 'entry-1',
        title: 'New Title',
        updatedAt: testDateTimeLater,
      );

      final remoteEntry = createTestJournalEntryModel(
        id: 'entry-1',
        title: 'Old Title',
        updatedAt: testDateTimeEarlier,
      );

      when(() => mockJournalRemoteDataSource.getEntries())
          .thenAnswer((_) async => [remoteEntry]);
      when(() => mockJournalLocalDataSource.getEntry(localEntry.id))
          .thenAnswer((_) async => localEntry);

      // Act
      final result =
          await syncService.syncEntries(SyncDirection.download);

      // Assert
      expect(result.success, true);
      expect(result.downloadedCount, 0);
      verifyNever(() => mockJournalLocalDataSource.updateEntry(any()));
    });

    test('should handle bidirectional sync correctly', () async {
      // Arrange
      final pendingEntries = createPendingJournalEntries(count: 1);
      final remoteEntries = createSyncedJournalEntries(count: 1);

      when(() => mockJournalLocalDataSource.getEntriesBySyncStatus('pending'))
          .thenAnswer((_) async => pendingEntries);
      when(() => mockJournalRemoteDataSource.getEntry(pendingEntries[0].id))
          .thenThrow(
        const ServerException(message: 'Not found', statusCode: 404),
      );
      when(() => mockJournalRemoteDataSource.createEntry(pendingEntries[0]))
          .thenAnswer((_) async => pendingEntries[0]);
      when(() => mockJournalLocalDataSource.updateSyncStatus(
              pendingEntries[0].id, 'synced'))
          .thenAnswer((_) async => pendingEntries[0]);

      when(() => mockJournalRemoteDataSource.getEntries())
          .thenAnswer((_) async => remoteEntries);
      when(() => mockJournalLocalDataSource.getEntry(remoteEntries[0].id))
          .thenAnswer((_) async => null);
      when(() => mockJournalLocalDataSource.createEntry(remoteEntries[0]))
          .thenAnswer((_) async => remoteEntries[0]);

      // Act
      final result = await syncService
          .syncEntries(SyncDirection.bidirectional);

      // Assert
      expect(result.success, true);
      expect(result.uploadedCount, 1);
      expect(result.downloadedCount, 1);
    });
  });

  group('SyncService - syncTrips', () {
    test('should upload pending trips to remote', () async {
      // Arrange
      final pendingTrips = createPendingTrips(count: 2);
      when(() => mockTripLocalDataSource.getTripsBySyncStatus('pending'))
          .thenAnswer((_) async => pendingTrips);

      for (final trip in pendingTrips) {
        when(() => mockTripRemoteDataSource.getTrip(trip.id))
            .thenThrow(const NotFoundException(message: 'Not found'));
        when(() => mockTripRemoteDataSource.createTrip(trip))
            .thenAnswer((_) async => trip);
        when(() => mockTripLocalDataSource.updateSyncStatus(
                trip.id, 'synced'))
            .thenAnswer((_) async => trip);
      }

      when(() => mockTripRemoteDataSource.getTrips())
          .thenAnswer((_) async => []);

      // Act
      final result = await syncService.syncTrips(SyncDirection.upload);

      // Assert
      expect(result.success, true);
      expect(result.uploadedCount, 2);
      verify(() => mockTripRemoteDataSource.createTrip(pendingTrips[0]))
          .called(1);
      verify(() => mockTripRemoteDataSource.createTrip(pendingTrips[1]))
          .called(1);
    });

    test('should download remote trips', () async {
      // Arrange
      final syncedTrips = createPendingTrips(count: 2)
          .map((t) => t.copyWith(syncStatus: SyncStatus.synced))
          .toList();

      when(() => mockTripRemoteDataSource.getTrips())
          .thenAnswer((_) async => syncedTrips);

      for (final trip in syncedTrips) {
        when(() => mockTripLocalDataSource.getTrip(trip.id))
            .thenAnswer((_) async => null);
        when(() => mockTripLocalDataSource.createTrip(trip))
            .thenAnswer((_) async => trip);
      }

      // Act
      final result = await syncService.syncTrips(SyncDirection.download);

      // Assert
      expect(result.success, true);
      expect(result.downloadedCount, 2);
      verify(() => mockTripLocalDataSource.createTrip(syncedTrips[0]))
          .called(1);
      verify(() => mockTripLocalDataSource.createTrip(syncedTrips[1]))
          .called(1);
    });

    test(
        'should detect conflict when trip exists both locally and remotely',
        () async {
      // Arrange
      final pendingTrip = createTestTripModel(
        id: 'conflict-trip',
        syncStatus: SyncStatus.pending,
        updatedAt: testDateTime,
      );

      final remoteTrip = createTestTripModel(
        id: 'conflict-trip',
        name: 'Remote Trip Name',
        updatedAt: testDateTimeLater,
      );

      when(() => mockTripLocalDataSource.getTripsBySyncStatus('pending'))
          .thenAnswer((_) async => [pendingTrip]);
      when(() => mockTripRemoteDataSource.getTrip(pendingTrip.id))
          .thenAnswer((_) async => remoteTrip);

      final conflicts = <SyncConflict>[];
      syncService.conflictStream.listen(conflicts.add);

      // Act
      final result = await syncService.syncTrips(SyncDirection.upload);

      // Assert
      expect(result.success, true);
      expect(result.conflictCount, 1);
      await Future.delayed(Duration.zero);
      expect(conflicts.length, 1);
      expect(conflicts.first.entityType, 'trip');
    });
  });

  group('SyncService - syncTags', () {
    test('should upload pending tags to remote', () async {
      // Arrange
      final pendingTags = createPendingTags(count: 2);
      when(() => mockTagLocalDataSource.getTagsBySyncStatus('pending'))
          .thenAnswer((_) async => pendingTags);

      for (final tag in pendingTags) {
        when(() => mockTagRemoteDataSource.getTag(tag.id))
            .thenThrow(const NotFoundException(message: 'Not found'));
        when(() => mockTagRemoteDataSource.createTag(tag))
            .thenAnswer((_) async => tag);
        when(() => mockTagLocalDataSource.updateSyncStatus(
                tag.id, 'synced'))
            .thenAnswer((_) async => tag);
      }

      when(() => mockTagRemoteDataSource.getTags())
          .thenAnswer((_) async => []);

      // Act
      final result = await syncService.syncTags(SyncDirection.upload);

      // Assert
      expect(result.success, true);
      expect(result.uploadedCount, 2);
      verify(() => mockTagRemoteDataSource.createTag(pendingTags[0]))
          .called(1);
    });

    test('should download remote tags', () async {
      // Arrange
      final syncedTags = createPendingTags(count: 2)
          .map((t) => t.copyWith(syncStatus: SyncStatus.synced))
          .toList();

      when(() => mockTagRemoteDataSource.getTags())
          .thenAnswer((_) async => syncedTags);

      for (final tag in syncedTags) {
        when(() => mockTagLocalDataSource.getTag(tag.id))
            .thenAnswer((_) async => null);
        when(() => mockTagLocalDataSource.createTag(tag))
            .thenAnswer((_) async => tag);
      }

      // Act
      final result = await syncService.syncTags(SyncDirection.download);

      // Assert
      expect(result.success, true);
      expect(result.downloadedCount, 2);
      verify(() => mockTagLocalDataSource.createTag(syncedTags[0]))
          .called(1);
    });

    test(
        'should detect conflict when tag exists both locally and remotely',
        () async {
      // Arrange
      final pendingTag = createTestTagModel(
        id: 'conflict-tag',
        syncStatus: SyncStatus.pending,
        createdAt: testDateTime,
      );

      final remoteTag = createTestTagModel(
        id: 'conflict-tag',
        name: 'Remote Tag Name',
        createdAt: testDateTimeLater,
      );

      when(() => mockTagLocalDataSource.getTagsBySyncStatus('pending'))
          .thenAnswer((_) async => [pendingTag]);
      when(() => mockTagRemoteDataSource.getTag(pendingTag.id))
          .thenAnswer((_) async => remoteTag);

      final conflicts = <SyncConflict>[];
      syncService.conflictStream.listen(conflicts.add);

      // Act
      final result = await syncService.syncTags(SyncDirection.upload);

      // Assert
      expect(result.success, true);
      expect(result.conflictCount, 1);
      await Future.delayed(Duration.zero);
      expect(conflicts.length, 1);
      expect(conflicts.first.entityType, 'tag');
    });
  });

  group('SyncService - syncMedia', () {
    test('should upload pending media to remote', () async {
      // Arrange
      final pendingMedia = createPendingMediaItems(count: 2);
      when(() => mockJournalLocalDataSource.getMediaBySyncStatus('pending'))
          .thenAnswer((_) async => pendingMedia);

      for (final media in pendingMedia) {
        when(() => mockJournalRemoteDataSource
                .getMediaForEntry(media.journalEntryId))
            .thenAnswer((_) async => []);
        when(() => mockJournalRemoteDataSource.addMedia(media))
            .thenAnswer((_) async => media);
        when(() => mockJournalLocalDataSource.updateMediaSyncStatus(
                media.id, 'synced'))
            .thenAnswer((_) async => media);
      }

      when(() => mockJournalLocalDataSource.getEntriesBySyncStatus('synced'))
          .thenAnswer((_) async => []);

      // Act
      final result = await syncService.syncMedia(SyncDirection.upload);

      // Assert
      expect(result.success, true);
      expect(result.uploadedCount, 2);
      verify(() => mockJournalRemoteDataSource.addMedia(pendingMedia[0]))
          .called(1);
      verify(() => mockJournalRemoteDataSource.addMedia(pendingMedia[1]))
          .called(1);
    });

    test('should download media for synced entries', () async {
      // Arrange
      final syncedEntries = createSyncedJournalEntries(count: 1);
      final remoteMedia = createPendingMediaItems(count: 2)
          .map((m) => m.copyWith(syncStatus: SyncStatus.synced))
          .toList();

      when(() => mockJournalLocalDataSource.getEntriesBySyncStatus('synced'))
          .thenAnswer((_) async => syncedEntries);
      when(() => mockJournalRemoteDataSource
              .getMediaForEntry(syncedEntries[0].id))
          .thenAnswer((_) async => remoteMedia);
      when(() => mockJournalLocalDataSource
              .getMediaForEntry(syncedEntries[0].id))
          .thenAnswer((_) async => []);

      for (final media in remoteMedia) {
        when(() => mockJournalLocalDataSource.addMedia(media))
            .thenAnswer((_) async => media);
      }

      // Act
      final result = await syncService.syncMedia(SyncDirection.download);

      // Assert
      expect(result.success, true);
      expect(result.downloadedCount, 2);
      verify(() => mockJournalLocalDataSource.addMedia(remoteMedia[0]))
          .called(1);
      verify(() => mockJournalLocalDataSource.addMedia(remoteMedia[1]))
          .called(1);
    });

    test('should handle media upload errors gracefully', () async {
      // Arrange
      final pendingMedia = createPendingMediaItems(count: 1);
      when(() => mockJournalLocalDataSource.getMediaBySyncStatus('pending'))
          .thenAnswer((_) async => pendingMedia);
      when(() => mockJournalRemoteDataSource
              .getMediaForEntry(pendingMedia[0].journalEntryId))
          .thenThrow(Exception('Network error'));
      when(() => mockJournalLocalDataSource.updateMediaSyncStatus(
              pendingMedia[0].id, 'pending'))
          .thenAnswer((_) async => pendingMedia[0]);

      when(() => mockJournalLocalDataSource.getEntriesBySyncStatus('synced'))
          .thenAnswer((_) async => []);

      // Act
      final result = await syncService.syncMedia(SyncDirection.upload);

      // Assert
      expect(result.success, true); // Success overall despite error
      expect(result.uploadedCount, 0);
      verify(() => mockJournalLocalDataSource.updateMediaSyncStatus(
            pendingMedia[0].id,
            'pending',
          )).called(1);
    });
  });

  group('SyncService - Conflict Resolution', () {
    test('should resolve conflict with mostRecent strategy', () async {
      // Arrange
      final conflict = createTestSyncConflict(
        localUpdatedAt: testDateTimeEarlier,
        remoteUpdatedAt: testDateTimeLater,
      );

      final localEntry = createTestJournalEntryModel(
        id: conflict.entityId,
        title: 'Local Title',
        updatedAt: testDateTimeEarlier,
      );
      final remoteEntry = createTestJournalEntryModel(
        id: conflict.entityId,
        title: 'Remote Title',
        updatedAt: testDateTimeLater,
      );

      when(() => mockJournalLocalDataSource.getEntry(conflict.entityId))
          .thenAnswer((_) async => localEntry);
      when(() => mockJournalLocalDataSource.updateEntry(any()))
          .thenAnswer((invocation) async => invocation.positionalArguments[0]);
      when(() => mockJournalLocalDataSource.updateSyncStatus(
              conflict.entityId, 'synced'))
          .thenAnswer((_) async => remoteEntry);

      // Act
      await syncService.resolveConflict(
        conflict,
        ConflictResolutionStrategy.mostRecent,
      );

      // Assert - Remote is newer, so local should be updated
      verify(() => mockJournalLocalDataSource.updateEntry(any())).called(1);
      verify(() => mockJournalLocalDataSource.updateSyncStatus(
          conflict.entityId, 'synced')).called(1);
    });

    test('should resolve conflict with localWins strategy', () async {
      // Arrange
      final conflict = createTestSyncConflict();

      final localEntry = createTestJournalEntryModel(
        id: conflict.entityId,
        title: 'Local Title',
        updatedAt: testDateTime,
      );

      when(() => mockJournalLocalDataSource.getEntry(conflict.entityId))
          .thenAnswer((_) async => localEntry);
      when(() => mockJournalRemoteDataSource.updateEntry(any()))
          .thenAnswer((invocation) async => invocation.positionalArguments[0]);
      when(() => mockJournalLocalDataSource.updateSyncStatus(
              conflict.entityId, 'synced'))
          .thenAnswer((_) async => localEntry);

      // Act
      await syncService.resolveConflict(
        conflict,
        ConflictResolutionStrategy.localWins,
      );

      // Assert - Local wins, so remote should be updated
      verify(() => mockJournalRemoteDataSource.updateEntry(any())).called(1);
      verify(() => mockJournalLocalDataSource.updateSyncStatus(
          conflict.entityId, 'synced')).called(1);
    });

    test('should resolve conflict with remoteWins strategy', () async {
      // Arrange
      final conflict = createTestSyncConflict();

      final remoteEntry = createTestJournalEntryModel(
        id: conflict.entityId,
        title: 'Remote Title',
        updatedAt: testDateTimeLater,
      );

      when(() => mockJournalLocalDataSource.updateEntry(any()))
          .thenAnswer((invocation) async => invocation.positionalArguments[0]);
      when(() => mockJournalLocalDataSource.updateSyncStatus(
              conflict.entityId, 'synced'))
          .thenAnswer((_) async => remoteEntry);

      // Act
      await syncService.resolveConflict(
        conflict,
        ConflictResolutionStrategy.remoteWins,
      );

      // Assert - Remote wins, so local should be updated
      verify(() => mockJournalLocalDataSource.updateEntry(any())).called(1);
      verify(() => mockJournalLocalDataSource.updateSyncStatus(
          conflict.entityId, 'synced')).called(1);
    });

    test('should resolve conflict with manual strategy', () async {
      // Arrange
      final conflict = createTestSyncConflict();
      final resolvedVersion = createTestJournalEntryModel(
        id: conflict.entityId,
        title: 'Merged Title',
        content: 'Merged content',
      ).toJson();

      when(() => mockJournalLocalDataSource.updateEntry(any()))
          .thenAnswer((invocation) async => invocation.positionalArguments[0]);
      when(() => mockJournalLocalDataSource.updateSyncStatus(
              conflict.entityId, 'synced'))
          .thenAnswer((_) async => createTestJournalEntryModel(id: conflict.entityId));

      // Act
      await syncService.resolveConflict(
        conflict,
        ConflictResolutionStrategy.manual,
        resolvedVersion: resolvedVersion,
      );

      // Assert
      verify(() => mockJournalLocalDataSource.updateEntry(any())).called(1);
      verify(() => mockJournalLocalDataSource.updateSyncStatus(
          conflict.entityId, 'synced')).called(1);
    });
  });

  group('SyncService - Statistics', () {
    void setupEmptySyncStubs() {
      when(() => mockJournalLocalDataSource.getEntriesBySyncStatus('pending'))
          .thenAnswer((_) async => []);
      when(() => mockJournalRemoteDataSource.getEntries())
          .thenAnswer((_) async => []);
      when(() => mockTripLocalDataSource.getTripsBySyncStatus('pending'))
          .thenAnswer((_) async => []);
      when(() => mockTripRemoteDataSource.getTrips())
          .thenAnswer((_) async => []);
      when(() => mockTagLocalDataSource.getTagsBySyncStatus('pending'))
          .thenAnswer((_) async => []);
      when(() => mockTagRemoteDataSource.getTags())
          .thenAnswer((_) async => []);
      when(() => mockJournalLocalDataSource.getEntriesBySyncStatus('synced'))
          .thenAnswer((_) async => []);
      when(() => mockJournalLocalDataSource.getMediaBySyncStatus('pending'))
          .thenAnswer((_) async => []);
    }

    test('should track sync statistics correctly', () async {
      // Arrange
      setupEmptySyncStubs();

      // Act
      await syncService.syncAll();
      final stats = syncService.getStatistics();

      // Assert
      expect(stats.totalSyncs, greaterThanOrEqualTo(1));
      expect(stats.successfulSyncs, greaterThanOrEqualTo(1));
      expect(stats.failedSyncs, 0);
      expect(stats.lastSyncTime, isNotNull);
    });

    test('should update statistics after failed sync', () async {
      // Arrange
      setupConnectivityDisconnected(mockConnectivityService);

      // Act
      await syncService.syncAll();
      final stats = syncService.getStatistics();

      // Assert
      expect(stats.totalSyncs, 1);
      expect(stats.successfulSyncs, 0);
      expect(stats.failedSyncs, 1);
    });

    test('should calculate average duration correctly', () async {
      // Arrange
      setupEmptySyncStubs();

      // Act
      await syncService.syncAll();
      final stats = syncService.getStatistics();

      // Assert
      expect(stats.averageDuration, isNotNull);
      expect(stats.averageDuration.inMilliseconds, greaterThanOrEqualTo(0));
    });

    test('should clear statistics', () async {
      // Arrange
      setupEmptySyncStubs();

      await syncService.syncAll();

      // Act
      await syncService.clearSyncState();
      final stats = syncService.getStatistics();

      // Assert
      expect(stats.totalSyncs, 0);
      expect(stats.successfulSyncs, 0);
      expect(stats.failedSyncs, 0);
      expect(stats.lastSyncTime, null);
    });
  });

  group('SyncService - Progress Tracking', () {
    void setupEmptySyncStubs() {
      when(() => mockJournalLocalDataSource.getEntriesBySyncStatus('pending'))
          .thenAnswer((_) async => []);
      when(() => mockJournalRemoteDataSource.getEntries())
          .thenAnswer((_) async => []);
      when(() => mockTripLocalDataSource.getTripsBySyncStatus('pending'))
          .thenAnswer((_) async => []);
      when(() => mockTripRemoteDataSource.getTrips())
          .thenAnswer((_) async => []);
      when(() => mockTagLocalDataSource.getTagsBySyncStatus('pending'))
          .thenAnswer((_) async => []);
      when(() => mockTagRemoteDataSource.getTags())
          .thenAnswer((_) async => []);
      when(() => mockJournalLocalDataSource.getEntriesBySyncStatus('synced'))
          .thenAnswer((_) async => []);
      when(() => mockJournalLocalDataSource.getMediaBySyncStatus('pending'))
          .thenAnswer((_) async => []);
    }

    test('should emit progress updates during sync', () async {
      // Arrange
      setupEmptySyncStubs();

      final progressUpdates = <SyncProgress>[];
      syncService.progressStream.listen(progressUpdates.add);

      // Act
      await syncService.syncAll();

      // Assert
      await Future.delayed(Duration.zero);
      expect(progressUpdates.length, greaterThan(0));
      expect(progressUpdates.last.currentOperation,
          SyncOperationType.full);
      expect(progressUpdates.last.syncedItems, 100);
      expect(progressUpdates.last.totalItems, 100);
    });

    test('should call progress callbacks', () async {
      // Arrange
      setupEmptySyncStubs();

      final callbackUpdates = <SyncProgress>[];
      syncService.onProgressUpdate((progress) {
        callbackUpdates.add(progress);
      });

      // Act
      await syncService.syncAll();

      // Assert
      expect(callbackUpdates.length, greaterThan(0));
    });

    test('should remove progress callbacks', () async {
      // Arrange
      setupEmptySyncStubs();

      var callbackCount = 0;
      void callback(SyncProgress _) {
        callbackCount++;
      }

      syncService.onProgressUpdate(callback);
      syncService.removeProgressCallback(callback);

      // Act
      await syncService.syncAll();

      // Assert
      expect(callbackCount, 0);
    });

    test('should call conflict callbacks', () async {
      // Arrange
      final pendingEntry = createTestJournalEntryModel(
        id: 'conflict-entry',
        syncStatus: SyncStatus.pending,
        updatedAt: testDateTime,
      );

      final remoteEntry = createTestJournalEntryModel(
        id: 'conflict-entry',
        title: 'Remote Title',
        updatedAt: testDateTimeLater,
      );

      when(() => mockJournalLocalDataSource.getEntriesBySyncStatus('pending'))
          .thenAnswer((_) async => [pendingEntry]);
      when(() => mockJournalRemoteDataSource.getEntry(pendingEntry.id))
          .thenAnswer((_) async => remoteEntry);

      var callbackConflictCount = 0;
      syncService.onConflictDetected((_) {
        callbackConflictCount++;
      });

      // Act
      await syncService.syncEntries(SyncDirection.upload);

      // Assert
      expect(callbackConflictCount, 1);
    });
  });

  group('SyncService - Cancellation', () {
    test('should cancel sync operation', () async {
      // Arrange
      final pendingEntries = createPendingJournalEntries(count: 100);

      when(() => mockJournalLocalDataSource.getEntriesBySyncStatus('pending'))
          .thenAnswer((_) async => pendingEntries);
      when(() => mockJournalRemoteDataSource.getEntry(any())).thenThrow(
        const ServerException(message: 'Not found', statusCode: 404),
      );
      when(() => mockJournalRemoteDataSource.createEntry(any()))
          .thenAnswer((_) async => pendingEntries.first);
      when(() => mockJournalLocalDataSource.updateSyncStatus(any(), any()))
          .thenAnswer((invocation) async => createTestJournalEntryModel(
              id: invocation.positionalArguments[0]));

      when(() => mockJournalRemoteDataSource.getEntries())
          .thenAnswer((_) async => []);

      // Act - Start sync and cancel immediately
      final syncFuture = syncService.syncAll();
      await syncService.cancelSync();
      final result = await syncFuture;

      // Assert
      expect(syncService.isSyncing, false);
    });
  });

  group('SyncService - Directional Sync', () {
    test('should upload all changes', () async {
      // Arrange
      when(() => mockJournalLocalDataSource.getEntriesBySyncStatus('pending'))
          .thenAnswer((_) async => []);
      when(() => mockTripLocalDataSource.getTripsBySyncStatus('pending'))
          .thenAnswer((_) async => []);
      when(() => mockTagLocalDataSource.getTagsBySyncStatus('pending'))
          .thenAnswer((_) async => []);
      when(() => mockJournalLocalDataSource.getMediaBySyncStatus('pending'))
          .thenAnswer((_) async => []);

      // Act
      final result = await syncService.uploadChanges();

      // Assert
      expect(result.success, true);
      expect(result.direction, SyncDirection.upload);
    });

    test('should download all changes', () async {
      // Arrange
      when(() => mockJournalRemoteDataSource.getEntries())
          .thenAnswer((_) async => []);
      when(() => mockTripRemoteDataSource.getTrips())
          .thenAnswer((_) async => []);
      when(() => mockTagRemoteDataSource.getTags())
          .thenAnswer((_) async => []);
      when(() => mockJournalLocalDataSource.getEntriesBySyncStatus('synced'))
          .thenAnswer((_) async => []);

      // Act
      final result = await syncService.downloadChanges();

      // Assert
      expect(result.success, true);
      expect(result.direction, SyncDirection.download);
    });

    test('should sync pending items only', () async {
      // Arrange
      when(() => mockJournalLocalDataSource.getEntriesBySyncStatus('pending'))
          .thenAnswer((_) async => []);
      when(() => mockJournalRemoteDataSource.getEntries())
          .thenAnswer((_) async => []);
      when(() => mockTripLocalDataSource.getTripsBySyncStatus('pending'))
          .thenAnswer((_) async => []);
      when(() => mockTripRemoteDataSource.getTrips())
          .thenAnswer((_) async => []);
      when(() => mockTagLocalDataSource.getTagsBySyncStatus('pending'))
          .thenAnswer((_) async => []);
      when(() => mockTagRemoteDataSource.getTags())
          .thenAnswer((_) async => []);
      when(() => mockJournalLocalDataSource.getEntriesBySyncStatus('synced'))
          .thenAnswer((_) async => []);
      when(() => mockJournalLocalDataSource.getMediaBySyncStatus('pending'))
          .thenAnswer((_) async => []);

      // Act
      final result = await syncService.syncPending();

      // Assert
      expect(result.success, true);
    });
  });
}
