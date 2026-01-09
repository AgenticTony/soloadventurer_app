import 'package:soloadventurer/features/offline/data/repositories/offline_aware_repository.dart';
import 'package:soloadventurer/features/travel/domain/models/journal.dart';

/// Repository interface for Journal data management with offline-first support
///
/// This repository provides methods for managing journal entries with full
/// offline-first capabilities. All operations return [RepositoryOperationResult]
/// to indicate whether operations were executed immediately or queued for sync.
abstract class JournalRepository {
  /// Get a single journal by ID
  ///
  /// Returns the journal from local cache if available, otherwise fetches from remote.
  /// Throws [CacheException] if offline and not in local cache.
  Future<Journal> getJournalById(String id);

  /// Get all journals for a trip
  ///
  /// Returns journals from local cache if available, otherwise fetches from remote.
  /// The [tripId] parameter is required to filter journals by trip.
  Future<List<Journal>> getJournals({required String tripId});

  /// Create a new journal
  ///
  /// Creates the journal in local database immediately, then:
  /// - If online: executes on remote API immediately
  /// - If offline: queues for sync and returns optimistic response
  ///
  /// Returns [RepositoryOperationResult] indicating sync status.
  Future<RepositoryOperationResult<Journal>> createJournal(Journal journal);

  /// Update an existing journal
  ///
  /// Updates the journal in local database immediately, then:
  /// - If online: executes on remote API immediately
  /// - If offline: queues for sync and returns optimistic response
  ///
  /// Returns [RepositoryOperationResult] indicating sync status.
  Future<RepositoryOperationResult<Journal>> updateJournal(
    String id,
    Journal journal,
  );

  /// Delete a journal
  ///
  /// Soft deletes the journal in local database immediately, then:
  /// - If online: executes on remote API immediately
  /// - If offline: queues for sync
  ///
  /// Returns [RepositoryOperationResult] indicating sync status.
  Future<RepositoryOperationResult<void>> deleteJournal(String id);

  /// Get journals by mood
  ///
  /// Filters journals by mood. Only works with local data.
  Future<List<Journal>> getJournalsByMood(String mood, {String? userId});

  /// Get journals by date range
  ///
  /// Filters journals within the specified date range. Only works with local data.
  Future<List<Journal>> getJournalsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? tripId,
  });

  /// Get journals by location
  ///
  /// Filters journals by location. Only works with local data.
  Future<List<Journal>> getJournalsByLocation(String location,
      {String? userId});

  /// Search journals by title or content
  ///
  /// Searches journals for the given search term. Only works with local data.
  Future<List<Journal>> searchJournals(String searchTerm, {String? userId});

  /// Get journals with pagination
  ///
  /// Returns paginated journals for a trip. Only works with local data.
  Future<List<Journal>> getJournalsPaginated({
    int limit = 20,
    int offset = 0,
    String? tripId,
  });
}
