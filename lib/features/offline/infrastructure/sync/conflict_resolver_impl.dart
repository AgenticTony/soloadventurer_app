import 'dart:async';
import 'package:drift/drift.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';
import 'package:soloadventurer/features/offline/domain/services/conflict_resolver.dart';

/// In-memory conflict log for tracking conflicts
///
/// In a production app, this would be persisted to the database.
/// For now, we store conflicts in memory with the ability to
/// persist critical conflicts to the database if needed.
class ConflictLog {
  /// All recorded conflicts
  final List<Conflict> _conflicts = [];

  /// Adds a conflict to the log
  void add(Conflict conflict) {
    _conflicts.add(conflict);
  }

  /// Gets all unresolved conflicts
  List<Conflict> getUnresolved() {
    return _conflicts.where((c) => !c.isResolved).toList();
  }

  /// Gets conflicts by entity type
  List<Conflict> getByType(EntityType type) {
    return _conflicts.where((c) => c.entityType == type).toList();
  }

  /// Gets conflict history
  List<Conflict> getHistory({DateTime? startDate, DateTime? endDate}) {
    var conflicts = _conflicts.toList();

    if (startDate != null) {
      conflicts =
          conflicts.where((c) => c.detectedAt.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      conflicts =
          conflicts.where((c) => c.detectedAt.isBefore(endDate)).toList();
    }

    return conflicts;
  }

  /// Clears old resolved conflicts
  void clearOld(DateTime beforeDate) {
    _conflicts.removeWhere((c) =>
        c.isResolved &&
        c.resolvedAt != null &&
        c.resolvedAt!.isBefore(beforeDate));

  }

  /// Gets total count
  int get length => _conflicts.length;

  /// Clears all conflicts
  void clear() {
    _conflicts.clear();
  }

  /// Gets all conflicts (for testing purposes)
  List<Conflict> get all => List.unmodifiable(_conflicts);
}

/// Implementation of [ConflictResolver]
///
/// This resolver provides multiple strategies for handling conflicts
/// that occur when the same entity is modified on both client and server.
///
/// Resolution strategies:
/// - **lastWriteWins**: Uses the most recently modified version
/// - **serverWins**: Always prefers the server version
/// - **clientWins**: Always prefers the client version
/// - **manual**: Requires user intervention
///
/// The resolver maintains a log of all conflicts for auditing purposes
/// and can automatically resolve conflicts based on entity type and severity.
class ConflictResolverImpl implements ConflictResolver {
  /// AppDatabase instance for data operations
  final AppDatabase _database;

  /// Conflict log for tracking all conflicts
  final ConflictLog _conflictLog;

  /// Default resolution strategy for each entity type
  final Map<EntityType, ConflictResolutionStrategy> _defaultStrategies;

  /// Creates a new [ConflictResolverImpl] instance
  ///
  /// [database] - AppDatabase instance for data operations
  /// [defaultStrategies] - Optional custom default strategies per entity type
  ConflictResolverImpl({
    required AppDatabase database,
    Map<EntityType, ConflictResolutionStrategy>? defaultStrategies,
  })  : _database = database,
        _conflictLog = ConflictLog(),
        _defaultStrategies = defaultStrategies ?? const {
              // For trips, prefer server version (more authoritative)
              EntityType.trip: ConflictResolutionStrategy.serverWins,

              // For journals, prefer client version (personal data)
              EntityType.journal: ConflictResolutionStrategy.clientWins,

              // For user profile, prefer last write
              EntityType.userProfile: ConflictResolutionStrategy.lastWriteWins,

              // For preferences, always prefer client
              EntityType.travelPreference:
                  ConflictResolutionStrategy.clientWins,
            };

  // ==============================================================================
  // PUBLIC API - CONFLICT RETRIEVAL
  // ==============================================================================

  @override
  Future<List<Conflict>> getUnresolvedConflicts() async {
    final conflicts = _conflictLog.getUnresolved();
    return conflicts;
  }

  @override
  Future<List<Conflict>> getConflictsByType(EntityType entityType) async {
    final conflicts = _conflictLog.getByType(entityType);
    return conflicts;
  }

  @override
  Future<List<Conflict>> getConflictHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final conflicts = _conflictLog.getHistory(
      startDate: startDate,
      endDate: endDate,
    );
    return conflicts;
  }

  // ==============================================================================
  // PUBLIC API - CONFLICT RESOLUTION
  // ==============================================================================

  @override
  Future<bool> resolveConflict(
    String conflictId,
    ConflictResolutionStrategy strategy,
  ) async {
    try {

      // Find the conflict
      final conflicts = await getUnresolvedConflicts();
      final conflict = conflicts.where((c) => c.id == conflictId).firstOrNull;

      if (conflict == null) {
        return false;
      }

      // Apply the resolution strategy
      bool success;
      switch (strategy) {
        case ConflictResolutionStrategy.lastWriteWins:
          success = await _resolveWithLastWriteWins(conflict);
          break;
        case ConflictResolutionStrategy.serverWins:
          success = await _resolveWithServerWins(conflict);
          break;
        case ConflictResolutionStrategy.clientWins:
          success = await _resolveWithClientWins(conflict);
          break;
        case ConflictResolutionStrategy.manual:
          // For manual resolution, we don't auto-resolve
          // The user will need to handle this through UI
          return true;
      }

      if (success) {
        // Mark conflict as resolved in the log
        final resolvedConflict = conflict.markAsResolved(strategy);
        _updateConflictInLog(resolvedConflict);
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<ConflictResolutionResult> resolveAllConflicts() async {

    final conflicts = await getUnresolvedConflicts();

    int resolvedCount = 0;
    int manualCount = 0;
    int failedCount = 0;
    final pendingConflicts = <Conflict>[];

    for (final conflict in conflicts) {
      // Get the default strategy for this entity type
      final strategy = _defaultStrategies[conflict.entityType] ??
          ConflictResolutionStrategy.lastWriteWins;

      // Skip manual resolution
      if (strategy == ConflictResolutionStrategy.manual) {
        manualCount++;
        pendingConflicts.add(conflict);
        continue;
      }

      // Try to resolve the conflict
      final success = await resolveConflict(conflict.id, strategy);

      if (success) {
        resolvedCount++;
      } else {
        failedCount++;
        pendingConflicts.add(conflict);
      }
    }

    return ConflictResolutionResult(
      resolvedCount: resolvedCount,
      manualResolutionRequired: manualCount,
      failedCount: failedCount,
      pendingConflicts: pendingConflicts,
    );
  }

  // ==============================================================================
  // PUBLIC API - CONFLICT RECORDING
  // ==============================================================================

  @override
  Future<void> recordConflict(Conflict conflict) async {
    _conflictLog.add(conflict);
  }

  @override
  Future<void> clearOldConflicts(DateTime beforeDate) async {
    _conflictLog.clearOld(beforeDate);
  }

  // ==============================================================================
  // PRIVATE METHODS - RESOLUTION STRATEGIES
  // ==============================================================================

  /// Resolves conflict by choosing the most recently modified version
  ///
  /// This strategy compares the updatedAt timestamps of the client
  /// and server versions, and chooses the most recent one.
  Future<bool> _resolveWithLastWriteWins(Conflict conflict) async {
    try {
      final clientIsNewer =
          conflict.clientUpdatedAt.isAfter(conflict.serverUpdatedAt);

      if (clientIsNewer) {
        return await _applyClientVersion(conflict);
      } else {
        return await _applyServerVersion(conflict);
      }
    } catch (e) {
      return false;
    }
  }

  /// Resolves conflict by always choosing the server version
  ///
  /// This strategy is appropriate for authoritative data where
  /// the server is considered the source of truth.
  Future<bool> _resolveWithServerWins(Conflict conflict) async {
    try {
      return await _applyServerVersion(conflict);
    } catch (e) {
      return false;
    }
  }

  /// Resolves conflict by always choosing the client version
  ///
  /// This strategy is appropriate for user-specific data where
  /// the client's changes should take precedence.
  Future<bool> _resolveWithClientWins(Conflict conflict) async {
    try {
      return await _applyClientVersion(conflict);
    } catch (e) {
      return false;
    }
  }

  /// Applies the client version of the conflicted entity
  ///
  /// Updates the local database with the client version and
  /// queues a sync operation to upload it to the server.
  Future<bool> _applyClientVersion(Conflict conflict) async {
    try {
      switch (conflict.entityType) {
        case EntityType.trip:
          return await _applyClientTripVersion(conflict);
        case EntityType.journal:
          return await _applyClientJournalVersion(conflict);
        case EntityType.userProfile:
          return await _applyClientUserVersion(conflict);
        case EntityType.travelPreference:
          // For now, skip preferences as they're not fully implemented
          return true;
        case EntityType.other:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Applies the server version of the conflicted entity
  ///
  /// Updates the local database with the server version.
  Future<bool> _applyServerVersion(Conflict conflict) async {
    try {
      switch (conflict.entityType) {
        case EntityType.trip:
          return await _applyServerTripVersion(conflict);
        case EntityType.journal:
          return await _applyServerJournalVersion(conflict);
        case EntityType.userProfile:
          return await _applyServerUserVersion(conflict);
        case EntityType.travelPreference:
          // For now, skip preferences
          return true;
        case EntityType.other:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  // ==============================================================================
  // PRIVATE METHODS - ENTITY-SPECIFIC RESOLUTION
  // ==============================================================================

  /// Applies client version for a trip conflict
  Future<bool> _applyClientTripVersion(Conflict conflict) async {
    try {
      // Update the trip with client data using database write method
      await (_database.update(_database.trips)
            ..where((t) => t.id.equals(conflict.entityId)))
          .write(TripsCompanion(
        hasPendingChanges: const Value(true),
        version: Value(conflict.clientData['version'] as int? ?? 0),
        updatedAt: Value(conflict.clientUpdatedAt),
      ));

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Applies server version for a trip conflict
  Future<bool> _applyServerTripVersion(Conflict conflict) async {
    try {
      // Update the trip with server data using database write method
      await (_database.update(_database.trips)
            ..where((t) => t.id.equals(conflict.entityId)))
          .write(TripsCompanion(
        hasPendingChanges: const Value(false),
        isSynced: const Value(true),
        version: Value(conflict.serverData['version'] as int? ?? 0),
        updatedAt: Value(conflict.serverUpdatedAt),
        lastSyncedAt: Value(DateTime.now()),
      ));

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Applies client version for a journal conflict
  Future<bool> _applyClientJournalVersion(Conflict conflict) async {
    try {
      // Update the journal with client data using database write method
      await (_database.update(_database.journals)
            ..where((j) => j.id.equals(conflict.entityId)))
          .write(JournalsCompanion(
        hasPendingChanges: const Value(true),
        version: Value(conflict.clientData['version'] as int? ?? 0),
        updatedAt: Value(conflict.clientUpdatedAt),
      ));

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Applies server version for a journal conflict
  Future<bool> _applyServerJournalVersion(Conflict conflict) async {
    try {
      // Update the journal with server data using database write method
      await (_database.update(_database.journals)
            ..where((j) => j.id.equals(conflict.entityId)))
          .write(JournalsCompanion(
        hasPendingChanges: const Value(false),
        isSynced: const Value(true),
        version: Value(conflict.serverData['version'] as int? ?? 0),
        updatedAt: Value(conflict.serverUpdatedAt),
        lastSyncedAt: Value(DateTime.now()),
      ));

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Applies client version for a user profile conflict
  Future<bool> _applyClientUserVersion(Conflict conflict) async {
    try {
      // Update the user with client data using database write method
      await (_database.update(_database.users)
            ..where((u) => u.id.equals(conflict.entityId)))
          .write(UsersCompanion(
        hasPendingChanges: const Value(true),
        version: Value(conflict.clientData['version'] as int? ?? 0),
        updatedAt: Value(conflict.clientUpdatedAt),
      ));

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Applies server version for a user profile conflict
  Future<bool> _applyServerUserVersion(Conflict conflict) async {
    try {
      // Update the user with server data using database write method
      await (_database.update(_database.users)
            ..where((u) => u.id.equals(conflict.entityId)))
          .write(UsersCompanion(
        hasPendingChanges: const Value(false),
        isSynced: const Value(true),
        version: Value(conflict.serverData['version'] as int? ?? 0),
        updatedAt: Value(conflict.serverUpdatedAt),
        lastSyncedAt: Value(DateTime.now()),
      ));

      return true;
    } catch (e) {
      return false;
    }
  }

  // ==============================================================================
  // PRIVATE METHODS - LOGGING
  // ==============================================================================

  /// Updates a conflict in the log
  void _updateConflictInLog(Conflict updatedConflict) {
    // Find and replace the conflict in the log
    final index = _conflictLog._conflicts.indexWhere(
      (c) => c.id == updatedConflict.id,
    );

    if (index != -1) {
      _conflictLog._conflicts[index] = updatedConflict;
    }
  }

  // ==============================================================================
  // UTILITY METHODS
  // ==============================================================================

}
