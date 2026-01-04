import 'package:soloadventurer/core/errors/app_exception.dart';
import 'package:soloadventurer/features/journal/data/datasources/journal_remote_data_source.dart';
import 'package:soloadventurer/features/journal/data/models/journal_entry_model.dart';
import 'package:soloadventurer/features/journal/data/models/media_item_model.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';
import 'package:soloadventurer/features/journal/domain/entities/media_item.dart';
import 'package:soloadventurer/features/journal/domain/repositories/journal_repository.dart';

/// Implementation of [JournalRepository]
class JournalRepositoryImpl implements JournalRepository {
  final JournalRemoteDataSource _remoteDataSource;

  JournalRepositoryImpl({
    required JournalRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<JournalEntry> createEntry(JournalEntry entry) async {
    try {
      final model = JournalEntryModel.fromEntity(entry);
      final createdEntry = await _remoteDataSource.createEntry(model);
      return createdEntry.toEntity();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to create journal entry: $e');
    }
  }

  @override
  Future<JournalEntry> getEntry(String entryId) async {
    try {
      final model = await _remoteDataSource.getEntry(entryId);
      return model.toEntity();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to get journal entry: $e');
    }
  }

  @override
  Future<List<JournalEntry>> getEntries() async {
    try {
      final models = await _remoteDataSource.getEntries();
      return models.map((model) => model.toEntity()).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to get journal entries: $e');
    }
  }

  @override
  Future<List<JournalEntry>> getEntriesByTrip(String tripId) async {
    try {
      final models = await _remoteDataSource.getEntriesByTrip(tripId);
      return models.map((model) => model.toEntity()).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to get entries for trip: $e');
    }
  }

  @override
  Future<List<JournalEntry>> getEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final models = await _remoteDataSource.getEntriesByDateRange(
        startDate,
        endDate,
      );
      return models.map((model) => model.toEntity()).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to get entries by date range: $e');
    }
  }

  @override
  Future<List<JournalEntry>> searchEntries(String query) async {
    try {
      final models = await _remoteDataSource.searchEntries(query);
      return models.map((model) => model.toEntity()).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to search entries: $e');
    }
  }

  @override
  Future<List<JournalEntry>> getFavoriteEntries() async {
    try {
      final models = await _remoteDataSource.getFavoriteEntries();
      return models.map((model) => model.toEntity()).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to get favorite entries: $e');
    }
  }

  @override
  Future<JournalEntry> updateEntry(JournalEntry entry) async {
    try {
      final model = JournalEntryModel.fromEntity(entry);
      final updatedEntry = await _remoteDataSource.updateEntry(model);
      return updatedEntry.toEntity();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to update journal entry: $e');
    }
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    try {
      await _remoteDataSource.deleteEntry(entryId);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to delete journal entry: $e');
    }
  }

  @override
  Future<JournalEntry> toggleFavorite(String entryId) async {
    try {
      final model = await _remoteDataSource.toggleFavorite(entryId);
      return model.toEntity();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to toggle favorite: $e');
    }
  }

  @override
  Future<List<JournalEntry>> getEntriesWithLocation() async {
    try {
      final models = await _remoteDataSource.getEntriesWithLocation();
      return models.map((model) => model.toEntity()).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to get entries with location: $e');
    }
  }

  @override
  Future<List<JournalEntry>> getEntriesNearLocation(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      final models = await _remoteDataSource.getEntriesNearLocation(
        latitude,
        longitude,
        radiusKm,
      );
      return models.map((model) => model.toEntity()).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to get entries near location: $e');
    }
  }

  @override
  Future<MediaItem> addMedia(MediaItem media) async {
    try {
      final model = MediaItemModel.fromEntity(media);
      final createdMedia = await _remoteDataSource.addMedia(model);
      return createdMedia.toEntity();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to add media: $e');
    }
  }

  @override
  Future<MediaItem> updateMedia(MediaItem media) async {
    try {
      final model = MediaItemModel.fromEntity(media);
      final updatedMedia = await _remoteDataSource.updateMedia(model);
      return updatedMedia.toEntity();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to update media: $e');
    }
  }

  @override
  Future<void> deleteMedia(String mediaId) async {
    try {
      await _remoteDataSource.deleteMedia(mediaId);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to delete media: $e');
    }
  }

  @override
  Future<List<MediaItem>> getMediaForEntry(String entryId) async {
    try {
      final models = await _remoteDataSource.getMediaForEntry(entryId);
      return models.map((model) => model.toEntity()).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to get media for entry: $e');
    }
  }

  @override
  Future<List<MediaItem>> getMediaForTrip(String tripId) async {
    try {
      final models = await _remoteDataSource.getMediaForTrip(tripId);
      return models.map((model) => model.toEntity()).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to get media for trip: $e');
    }
  }

  @override
  Future<MediaItem> updateMediaUploadProgress(
    String mediaId,
    int progress,
  ) async {
    try {
      final model = await _remoteDataSource.updateMediaUploadProgress(
        mediaId,
        progress,
      );
      return model.toEntity();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to update upload progress: $e');
    }
  }

  @override
  Future<MediaItem> completeMediaUpload(
    String mediaId,
    String storagePath,
  ) async {
    try {
      final model = await _remoteDataSource.completeMediaUpload(
        mediaId,
        storagePath,
      );
      return model.toEntity();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to complete upload: $e');
    }
  }

  @override
  Future<MediaItem> failMediaUpload(
    String mediaId,
    String error,
  ) async {
    try {
      final model = await _remoteDataSource.failMediaUpload(
        mediaId,
        error,
      );
      return model.toEntity();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to mark upload as failed: $e');
    }
  }
}
