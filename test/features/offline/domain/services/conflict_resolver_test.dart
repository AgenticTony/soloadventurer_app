import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/offline/domain/services/conflict_resolver.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';
import 'package:soloadventurer/features/offline/infrastructure/sync/conflict_resolver_impl.dart';

// Mock classes
class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late MockAppDatabase mockDatabase;
  late ConflictResolverImpl conflictResolver;

  setUp(() {
    mockDatabase = MockAppDatabase();
    conflictResolver = ConflictResolverImpl(database: mockDatabase);
  });

  group('ConflictResolver - Conflict Recording', () {
    test('should record and retrieve conflicts', () async {
      final conflict = Conflict(
        id: 'conflict-1',
        entityType: EntityType.trip,
        entityId: 'trip-1',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.medium,
        clientData: const {'version': 2, 'title': 'Client Title'},
        serverData: const {'version': 1, 'title': 'Server Title'},
        clientUpdatedAt: DateTime(2024, 1, 15, 10, 0),
        serverUpdatedAt: DateTime(2024, 1, 10, 10, 0),
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict);

      final conflicts = await conflictResolver.getUnresolvedConflicts();
      expect(conflicts, contains(conflict));
      expect(conflicts.length, equals(1));
    });

    test('should retrieve conflicts by entity type', () async {
      final tripConflict = Conflict(
        id: 'conflict-trip',
        entityType: EntityType.trip,
        entityId: 'trip-1',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.medium,
        clientData: const {'version': 1},
        serverData: const {'version': 2},
        clientUpdatedAt: DateTime.now(),
        serverUpdatedAt: DateTime.now(),
        detectedAt: DateTime.now(),
      );

      final journalConflict = Conflict(
        id: 'conflict-journal',
        entityType: EntityType.journal,
        entityId: 'journal-1',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.low,
        clientData: const {'version': 1},
        serverData: const {'version': 2},
        clientUpdatedAt: DateTime.now(),
        serverUpdatedAt: DateTime.now(),
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(tripConflict);
      await conflictResolver.recordConflict(journalConflict);

      final tripConflicts =
          await conflictResolver.getConflictsByType(EntityType.trip);
      final journalConflicts =
          await conflictResolver.getConflictsByType(EntityType.journal);

      expect(tripConflicts, contains(tripConflict));
      expect(tripConflicts, isNot(contains(journalConflict)));
      expect(journalConflicts, contains(journalConflict));
      expect(journalConflicts, isNot(contains(tripConflict)));
    });

    test('should track conflict resolution status', () async {
      final conflict = Conflict(
        id: 'conflict-status',
        entityType: EntityType.travelPreference,
        entityId: 'pref-1',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.medium,
        clientData: const {'version': 1},
        serverData: const {'version': 2},
        clientUpdatedAt: DateTime.now(),
        serverUpdatedAt: DateTime.now(),
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict);

      // Initially unresolved
      var unresolved = await conflictResolver.getUnresolvedConflicts();
      expect(unresolved, contains(conflict));
      expect(unresolved.first.isResolved, isFalse);

      // Resolve with serverWins strategy
      await conflictResolver.resolveConflict(
        conflict.id,
        ConflictResolutionStrategy.serverWins,
      );

      // Should no longer be in unresolved list
      unresolved = await conflictResolver.getUnresolvedConflicts();
      expect(unresolved, isEmpty);
    });

    test('should retrieve conflict history with date range', () async {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final twoDaysAgo = now.subtract(const Duration(days: 2));

      final oldConflict = Conflict(
        id: 'conflict-old',
        entityType: EntityType.trip,
        entityId: 'trip-1',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.medium,
        clientData: const {'version': 1},
        serverData: const {'version': 2},
        clientUpdatedAt: twoDaysAgo,
        serverUpdatedAt: twoDaysAgo,
        detectedAt: twoDaysAgo,
      );

      final recentConflict = Conflict(
        id: 'conflict-recent',
        entityType: EntityType.journal,
        entityId: 'journal-1',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.low,
        clientData: const {'version': 1},
        serverData: const {'version': 2},
        clientUpdatedAt: now,
        serverUpdatedAt: now,
        detectedAt: now,
      );

      await conflictResolver.recordConflict(oldConflict);
      await conflictResolver.recordConflict(recentConflict);

      // Get history from yesterday onwards
      final history =
          await conflictResolver.getConflictHistory(startDate: yesterday);

      expect(history, contains(recentConflict));
      expect(history, isNot(contains(oldConflict)));
    });

    test('should record multiple conflicts and track all of them', () async {
      final conflicts = List.generate(
        10,
        (i) => Conflict(
          id: 'conflict-batch-$i',
          entityType: EntityType.trip,
          entityId: 'trip-$i',
          type: ConflictType.concurrentUpdate,
          severity: ConflictSeverity.medium,
          clientData: {'version': i},
          serverData: {'version': i + 1},
          clientUpdatedAt: DateTime.now(),
          serverUpdatedAt: DateTime.now(),
          detectedAt: DateTime.now(),
        ),
      );

      for (final conflict in conflicts) {
        await conflictResolver.recordConflict(conflict);
      }

      final allConflicts = await conflictResolver.getUnresolvedConflicts();
      expect(allConflicts.length, equals(10));
      for (final conflict in conflicts) {
        expect(allConflicts, contains(conflict));
      }
    });
  });

  group('ConflictResolver - Manual Resolution', () {
    test('should not auto-resolve manual conflicts', () async {
      final conflict = Conflict(
        id: 'conflict-manual',
        entityType: EntityType.trip,
        entityId: 'trip-manual',
        type: ConflictType.deleteModify,
        severity: ConflictSeverity.high,
        clientData: const {'version': 1, 'title': 'Client Title'},
        serverData: const {'version': 2, 'isDeleted': true},
        clientUpdatedAt: DateTime.now(),
        serverUpdatedAt: DateTime.now(),
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict);

      final result = await conflictResolver.resolveConflict(
        conflict.id,
        ConflictResolutionStrategy.manual,
      );

      expect(result, isTrue);
    });

    test('should include manual conflicts in pending list', () async {
      final manualConflict = Conflict(
        id: 'conflict-manual-pending',
        entityType: EntityType.trip,
        entityId: 'trip-manual-2',
        type: ConflictType.duplicateCreate,
        severity: ConflictSeverity.high,
        clientData: const {'version': 1, 'title': 'Client Trip'},
        serverData: const {'version': 1, 'title': 'Server Trip'},
        clientUpdatedAt: DateTime.now(),
        serverUpdatedAt: DateTime.now(),
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(manualConflict);

      final manualResolver = ConflictResolverImpl(
        database: mockDatabase,
        defaultStrategies: {
          EntityType.trip: ConflictResolutionStrategy.manual,
        },
      );

      // Record with the manual resolver
      await manualResolver.recordConflict(manualConflict);

      final result = await manualResolver.resolveAllConflicts();

      expect(result.manualResolutionRequired, equals(1));
      expect(result.pendingConflicts, contains(manualConflict));
      expect(result.resolvedCount, equals(0));
    });
  });

  group('ConflictResolver - Edge Cases', () {
    test('should return false when resolving non-existent conflict', () async {
      final result = await conflictResolver.resolveConflict(
        'non-existent-id',
        ConflictResolutionStrategy.serverWins,
      );

      expect(result, isFalse);
    });

    test('should handle empty conflict list', () async {
      final unresolved = await conflictResolver.getUnresolvedConflicts();
      expect(unresolved, isEmpty);

      final result = await conflictResolver.resolveAllConflicts();
      expect(result.resolvedCount, equals(0));
      expect(result.manualResolutionRequired, equals(0));
      expect(result.failedCount, equals(0));
    });

    test('should handle unknown entity types gracefully', () async {
      final conflict = Conflict(
        id: 'conflict-unknown',
        entityType: EntityType.other,
        entityId: 'unknown-1',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.low,
        clientData: const {'version': 1},
        serverData: const {'version': 2},
        clientUpdatedAt: DateTime.now(),
        serverUpdatedAt: DateTime.now(),
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict);

      final result = await conflictResolver.resolveConflict(
        conflict.id,
        ConflictResolutionStrategy.clientWins,
      );

      expect(result, isFalse);
    });

    test('should handle travel preference entity with skip', () async {
      final conflict = Conflict(
        id: 'conflict-pref',
        entityType: EntityType.travelPreference,
        entityId: 'pref-1',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.low,
        clientData: const {'version': 1},
        serverData: const {'version': 2},
        clientUpdatedAt: DateTime.now(),
        serverUpdatedAt: DateTime.now(),
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict);

      // Should return true (skip) even though there's no DAO
      final result = await conflictResolver.resolveConflict(
        conflict.id,
        ConflictResolutionStrategy.clientWins,
      );

      expect(result, isTrue);
    });
  });

  group('ConflictResolver - Conflict Types', () {
    test('should handle delete-modify conflicts', () async {
      final conflict = Conflict(
        id: 'conflict-delete-modify',
        entityType: EntityType.trip,
        entityId: 'trip-deleted',
        type: ConflictType.deleteModify,
        severity: ConflictSeverity.high,
        clientData: const {'version': 1, 'isDeleted': false},
        serverData: const {'version': 2, 'isDeleted': true},
        clientUpdatedAt: DateTime.now(),
        serverUpdatedAt: DateTime.now(),
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict);

      final unresolved = await conflictResolver.getUnresolvedConflicts();
      expect(unresolved.first.type, equals(ConflictType.deleteModify));
      expect(unresolved.first.severity, equals(ConflictSeverity.high));
    });

    test('should handle duplicate create conflicts', () async {
      final conflict = Conflict(
        id: 'conflict-duplicate',
        entityType: EntityType.trip,
        entityId: 'trip-duplicate',
        type: ConflictType.duplicateCreate,
        severity: ConflictSeverity.high,
        clientData: const {'version': 1, 'title': 'Client Trip'},
        serverData: const {'version': 1, 'title': 'Server Trip'},
        clientUpdatedAt: DateTime.now(),
        serverUpdatedAt: DateTime.now(),
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict);

      final byType = await conflictResolver.getConflictsByType(EntityType.trip);
      expect(byType.first.type, equals(ConflictType.duplicateCreate));
    });

    test('should handle version mismatch conflicts', () async {
      final conflict = Conflict(
        id: 'conflict-version',
        entityType: EntityType.journal,
        entityId: 'journal-version',
        type: ConflictType.versionMismatch,
        severity: ConflictSeverity.low,
        clientData: const {'version': 5},
        serverData: const {'version': 10},
        clientUpdatedAt: DateTime.now(),
        serverUpdatedAt: DateTime.now(),
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict);

      final unresolved = await conflictResolver.getUnresolvedConflicts();
      expect(unresolved.first.type, equals(ConflictType.versionMismatch));
      expect(unresolved.first.severity, equals(ConflictSeverity.low));
    });
  });

  group('ConflictResolver - Clear Old Conflicts', () {
    test('should clear old conflicts', () async {
      final now = DateTime.now();
      final oldDate = now.subtract(const Duration(days: 10));

      final oldConflict = Conflict(
        id: 'conflict-old-clear',
        entityType: EntityType.trip,
        entityId: 'trip-1',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.medium,
        clientData: const {'version': 1},
        serverData: const {'version': 2},
        clientUpdatedAt: oldDate,
        serverUpdatedAt: oldDate,
        detectedAt: oldDate,
        isResolved: true,
        resolvedAt: oldDate.add(const Duration(hours: 1)),
        resolvedWith: ConflictResolutionStrategy.serverWins,
      );

      final recentConflict = Conflict(
        id: 'conflict-recent-clear',
        entityType: EntityType.journal,
        entityId: 'journal-1',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.low,
        clientData: const {'version': 1},
        serverData: const {'version': 2},
        clientUpdatedAt: now,
        serverUpdatedAt: now,
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(oldConflict);
      await conflictResolver.recordConflict(recentConflict);

      final cutoffDate = now.subtract(const Duration(days: 5));
      await conflictResolver.clearOldConflicts(cutoffDate);

      final history = await conflictResolver.getConflictHistory();

      expect(history, contains(recentConflict));
      expect(history, isNot(contains(oldConflict)));
    });
  });
}
