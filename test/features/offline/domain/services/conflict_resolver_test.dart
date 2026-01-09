import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/offline/domain/services/conflict_resolver.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/trip_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/journal_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/user_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/sync/conflict_resolver_impl.dart';
import 'package:soloadventurer/test/mocks/dao_mocks.dart';

// Mock classes
class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late MockAppDatabase mockDatabase;
  late MockTripDao mockTripDao;
  late MockJournalDao mockJournalDao;
  late MockUserDao mockUserDao;
  late ConflictResolverImpl conflictResolver;

  setUp(() {
    mockDatabase = MockAppDatabase();
    mockTripDao = MockTripDao();
    mockJournalDao = MockJournalDao();
    mockUserDao = MockUserDao();

    // Setup database to return mocked DAOs
    when(() => mockDatabase.tripDao).thenReturn(mockTripDao);
    when(() => mockDatabase.journalDao).thenReturn(mockJournalDao);
    when(() => mockDatabase.userDao).thenReturn(mockUserDao);

    conflictResolver = ConflictResolverImpl(database: mockDatabase);
  });

  group('ConflictResolver - Last-Write-Wins Strategy', () {
    test('should resolve conflict by choosing client version when it is newer',
        () async {
      final clientTime = DateTime(2024, 1, 15, 10, 0);
      final serverTime = DateTime(2024, 1, 10, 10, 0);

      final conflict = Conflict(
        id: 'conflict-1',
        entityType: EntityType.trip,
        entityId: 'trip-1',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.medium,
        clientData: const {'version': 2, 'title': 'Client Title'},
        serverData: const {'version': 1, 'title': 'Server Title'},
        clientUpdatedAt: clientTime,
        serverUpdatedAt: serverTime,
        detectedAt: DateTime.now(),
      );

      // Record conflict
      await conflictResolver.recordConflict(conflict);

      // Mock successful update
      when(() => mockTripDao.updateTrip(any())).thenAnswer((_) async => 1);

      // Resolve with last-write-wins
      final result = await conflictResolver.resolveConflict(
        conflict.id,
        ConflictResolutionStrategy.lastWriteWins,
      );

      expect(result, isTrue);
      verify(() => mockTripDao.updateTrip(any())).called(1);

      final captured = verify(() => mockTripDao.updateTrip(captureAny()))
          .captured
          .single as TripsCompanion;
      expect(captured.hasPendingChanges.value, isTrue);
      expect(captured.updatedAt.value, equals(clientTime));
    });

    test('should resolve conflict by choosing server version when it is newer',
        () async {
      final clientTime = DateTime(2024, 1, 10, 10, 0);
      final serverTime = DateTime(2024, 1, 15, 10, 0);

      final conflict = Conflict(
        id: 'conflict-2',
        entityType: EntityType.trip,
        entityId: 'trip-2',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.medium,
        clientData: const {'version': 1, 'title': 'Client Title'},
        serverData: const {'version': 2, 'title': 'Server Title'},
        clientUpdatedAt: clientTime,
        serverUpdatedAt: serverTime,
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict);

      when(() => mockTripDao.updateTrip(any())).thenAnswer((_) async => 1);

      final result = await conflictResolver.resolveConflict(
        conflict.id,
        ConflictResolutionStrategy.lastWriteWins,
      );

      expect(result, isTrue);
      verify(() => mockTripDao.updateTrip(any())).called(1);

      final captured = verify(() => mockTripDao.updateTrip(captureAny()))
          .captured
          .single as TripsCompanion;
      expect(captured.isSynced.value, isTrue);
      expect(captured.hasPendingChanges.value, isFalse);
      expect(captured.updatedAt.value, equals(serverTime));
    });

    test('should handle last-write-wins with journal entity', () async {
      final clientTime = DateTime(2024, 1, 20, 10, 0);
      final serverTime = DateTime(2024, 1, 15, 10, 0);

      final conflict = Conflict(
        id: 'conflict-3',
        entityType: EntityType.journal,
        entityId: 'journal-1',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.low,
        clientData: const {'version': 2, 'content': 'Client content'},
        serverData: const {'version': 1, 'content': 'Server content'},
        clientUpdatedAt: clientTime,
        serverUpdatedAt: serverTime,
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict);
      when(() => mockJournalDao.updateJournal(any()))
          .thenAnswer((_) async => 1);

      final result = await conflictResolver.resolveConflict(
        conflict.id,
        ConflictResolutionStrategy.lastWriteWins,
      );

      expect(result, isTrue);
      verify(() => mockJournalDao.updateJournal(any())).called(1);
    });

    test('should handle last-write-wins with user profile entity', () async {
      final clientTime = DateTime(2024, 1, 25, 10, 0);
      final serverTime = DateTime(2024, 1, 20, 10, 0);

      final conflict = Conflict(
        id: 'conflict-4',
        entityType: EntityType.userProfile,
        entityId: 'user-1',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.low,
        clientData: const {'version': 2, 'username': 'newUsername'},
        serverData: const {'version': 1, 'username': 'oldUsername'},
        clientUpdatedAt: clientTime,
        serverUpdatedAt: serverTime,
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict);
      when(() => mockUserDao.updateUser(any())).thenAnswer((_) async => 1);

      final result = await conflictResolver.resolveConflict(
        conflict.id,
        ConflictResolutionStrategy.lastWriteWins,
      );

      expect(result, isTrue);
      verify(() => mockUserDao.updateUser(any())).called(1);
    });

    test('should return false when last-write-wins resolution fails', () async {
      final conflict = Conflict(
        id: 'conflict-5',
        entityType: EntityType.trip,
        entityId: 'trip-fail',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.medium,
        clientData: const {'version': 2},
        serverData: const {'version': 1},
        clientUpdatedAt: DateTime.now(),
        serverUpdatedAt: DateTime.now().subtract(const Duration(days: 1)),
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict);
      when(() => mockTripDao.updateTrip(any()))
          .thenThrow(Exception('Database error'));

      final result = await conflictResolver.resolveConflict(
        conflict.id,
        ConflictResolutionStrategy.lastWriteWins,
      );

      expect(result, isFalse);
    });
  });

  group('ConflictResolver - Server-Wins Strategy', () {
    test('should always choose server version regardless of timestamp',
        () async {
      final clientTime = DateTime(2024, 1, 20, 10, 0); // Client is newer
      final serverTime = DateTime(2024, 1, 15, 10, 0);

      final conflict = Conflict(
        id: 'conflict-6',
        entityType: EntityType.trip,
        entityId: 'trip-3',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.medium,
        clientData: const {'version': 2, 'title': 'Client Title'},
        serverData: const {'version': 1, 'title': 'Server Title'},
        clientUpdatedAt: clientTime,
        serverUpdatedAt: serverTime,
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict);
      when(() => mockTripDao.updateTrip(any())).thenAnswer((_) async => 1);

      final result = await conflictResolver.resolveConflict(
        conflict.id,
        ConflictResolutionStrategy.serverWins,
      );

      expect(result, isTrue);

      final captured = verify(() => mockTripDao.updateTrip(captureAny()))
          .captured
          .single as TripsCompanion;
      // Should apply server version
      expect(captured.isSynced.value, isTrue);
      expect(captured.hasPendingChanges.value, isFalse);
      expect(captured.version.value, equals(1));
    });

    test('should apply server-wins to journal entity', () async {
      final conflict = Conflict(
        id: 'conflict-7',
        entityType: EntityType.journal,
        entityId: 'journal-2',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.low,
        clientData: const {'version': 2, 'content': 'Client content'},
        serverData: const {'version': 1, 'content': 'Server content'},
        clientUpdatedAt: DateTime.now(),
        serverUpdatedAt: DateTime.now().subtract(const Duration(days: 1)),
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict);
      when(() => mockJournalDao.updateJournal(any()))
          .thenAnswer((_) async => 1);

      final result = await conflictResolver.resolveConflict(
        conflict.id,
        ConflictResolutionStrategy.serverWins,
      );

      expect(result, isTrue);
      verify(() => mockJournalDao.updateJournal(any())).called(1);

      final captured = verify(
        () => mockJournalDao.updateJournal(captureAny()),
      ).captured.single as JournalsCompanion;
      expect(captured.isSynced.value, isTrue);
      expect(captured.hasPendingChanges.value, isFalse);
    });

    test('should apply server-wins to user profile entity', () async {
      final conflict = Conflict(
        id: 'conflict-8',
        entityType: EntityType.userProfile,
        entityId: 'user-2',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.low,
        clientData: const {'version': 2, 'username': 'clientUser'},
        serverData: const {'version': 1, 'username': 'serverUser'},
        clientUpdatedAt: DateTime.now(),
        serverUpdatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict);
      when(() => mockUserDao.updateUser(any())).thenAnswer((_) async => 1);

      final result = await conflictResolver.resolveConflict(
        conflict.id,
        ConflictResolutionStrategy.serverWins,
      );

      expect(result, isTrue);
      verify(() => mockUserDao.updateUser(any())).called(1);

      final captured = verify(() => mockUserDao.updateUser(captureAny()))
          .captured
          .single as UsersCompanion;
      expect(captured.isSynced.value, isTrue);
      expect(captured.hasPendingChanges.value, isFalse);
    });

    test('should return false when server-wins resolution fails', () async {
      final conflict = Conflict(
        id: 'conflict-9',
        entityType: EntityType.trip,
        entityId: 'trip-server-fail',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.medium,
        clientData: const {'version': 2},
        serverData: const {'version': 1},
        clientUpdatedAt: DateTime.now(),
        serverUpdatedAt: DateTime.now().subtract(const Duration(days: 1)),
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict);
      when(() => mockTripDao.updateTrip(any()))
          .thenThrow(Exception('Update failed'));

      final result = await conflictResolver.resolveConflict(
        conflict.id,
        ConflictResolutionStrategy.serverWins,
      );

      expect(result, isFalse);
    });
  });

  group('ConflictResolver - Client-Wins Strategy', () {
    test('should always choose client version regardless of timestamp',
        () async {
      final clientTime = DateTime(2024, 1, 10, 10, 0); // Client is older
      final serverTime = DateTime(2024, 1, 15, 10, 0);

      final conflict = Conflict(
        id: 'conflict-10',
        entityType: EntityType.journal,
        entityId: 'journal-3',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.low,
        clientData: const {'version': 1, 'content': 'Client content'},
        serverData: const {'version': 2, 'content': 'Server content'},
        clientUpdatedAt: clientTime,
        serverUpdatedAt: serverTime,
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict);
      when(() => mockJournalDao.updateJournal(any()))
          .thenAnswer((_) async => 1);

      final result = await conflictResolver.resolveConflict(
        conflict.id,
        ConflictResolutionStrategy.clientWins,
      );

      expect(result, isTrue);

      final captured = verify(
        () => mockJournalDao.updateJournal(captureAny()),
      ).captured.single as JournalsCompanion;
      // Should apply client version
      expect(captured.hasPendingChanges.value, isTrue);
      expect(captured.version.value, equals(1));
    });

    test('should apply client-wins to trip entity', () async {
      final conflict = Conflict(
        id: 'conflict-11',
        entityType: EntityType.trip,
        entityId: 'trip-4',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.medium,
        clientData: const {'version': 1, 'title': 'Client Title'},
        serverData: const {'version': 2, 'title': 'Server Title'},
        clientUpdatedAt: DateTime.now().subtract(const Duration(days: 1)),
        serverUpdatedAt: DateTime.now(),
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict);
      when(() => mockTripDao.updateTrip(any())).thenAnswer((_) async => 1);

      final result = await conflictResolver.resolveConflict(
        conflict.id,
        ConflictResolutionStrategy.clientWins,
      );

      expect(result, isTrue);
      verify(() => mockTripDao.updateTrip(any())).called(1);

      final captured = verify(() => mockTripDao.updateTrip(captureAny()))
          .captured
          .single as TripsCompanion;
      expect(captured.hasPendingChanges.value, isTrue);
      expect(captured.version.value, equals(1));
    });

    test('should apply client-wins to user profile entity', () async {
      final conflict = Conflict(
        id: 'conflict-12',
        entityType: EntityType.userProfile,
        entityId: 'user-3',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.low,
        clientData: const {'version': 1, 'username': 'clientUsername'},
        serverData: const {'version': 2, 'username': 'serverUsername'},
        clientUpdatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        serverUpdatedAt: DateTime.now(),
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict);
      when(() => mockUserDao.updateUser(any())).thenAnswer((_) async => 1);

      final result = await conflictResolver.resolveConflict(
        conflict.id,
        ConflictResolutionStrategy.clientWins,
      );

      expect(result, isTrue);
      verify(() => mockUserDao.updateUser(any())).called(1);

      final captured = verify(() => mockUserDao.updateUser(captureAny()))
          .captured
          .single as UsersCompanion;
      expect(captured.hasPendingChanges.value, isTrue);
    });

    test('should return false when client-wins resolution fails', () async {
      final conflict = Conflict(
        id: 'conflict-13',
        entityType: EntityType.journal,
        entityId: 'journal-client-fail',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.low,
        clientData: const {'version': 1},
        serverData: const {'version': 2},
        clientUpdatedAt: DateTime.now().subtract(const Duration(days: 1)),
        serverUpdatedAt: DateTime.now(),
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict);
      when(() => mockJournalDao.updateJournal(any()))
          .thenThrow(Exception('Update failed'));

      final result = await conflictResolver.resolveConflict(
        conflict.id,
        ConflictResolutionStrategy.clientWins,
      );

      expect(result, isFalse);
    });
  });

  group('ConflictResolver - Manual Resolution Flow', () {
    test('should not auto-resolve manual conflicts', () async {
      final conflict = Conflict(
        id: 'conflict-14',
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

      // Manual resolution should return true but not apply any changes
      expect(result, isTrue);
      verifyNever(() => mockTripDao.updateTrip(any()));
    });

    test('should include manual conflicts in pending list', () async {
      final manualConflict = Conflict(
        id: 'conflict-15',
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

      // Create resolver with manual strategy for trips
      final manualResolver = ConflictResolverImpl(
        database: mockDatabase,
        defaultStrategies: {
          EntityType.trip: ConflictResolutionStrategy.manual,
        },
      );

      final result = await manualResolver.resolveAllConflicts();

      expect(result.manualResolutionRequired, equals(1));
      expect(result.pendingConflicts, contains(manualConflict));
      expect(result.resolvedCount, equals(0));
    });

    test('should allow manual resolution after auto-resolution fails',
        () async {
      final conflict = Conflict(
        id: 'conflict-16',
        entityType: EntityType.trip,
        entityId: 'trip-manual-retry',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.medium,
        clientData: const {'version': 1},
        serverData: const {'version': 2},
        clientUpdatedAt: DateTime.now(),
        serverUpdatedAt: DateTime.now(),
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict);

      // Try server-wins first
      when(() => mockTripDao.updateTrip(any()))
          .thenThrow(Exception('Network error'));

      final failedResult = await conflictResolver.resolveConflict(
        conflict.id,
        ConflictResolutionStrategy.serverWins,
      );

      expect(failedResult, isFalse);

      // Then mark as manual
      final manualResult = await conflictResolver.resolveConflict(
        conflict.id,
        ConflictResolutionStrategy.manual,
      );

      expect(manualResult, isTrue);
    });
  });

  group('ConflictResolver - Conflict Logging', () {
    test('should record conflicts to the log', () async {
      final conflict = Conflict(
        id: 'conflict-17',
        entityType: EntityType.trip,
        entityId: 'trip-5',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.medium,
        clientData: const {'version': 1},
        serverData: const {'version': 2},
        clientUpdatedAt: DateTime.now(),
        serverUpdatedAt: DateTime.now(),
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict);

      final conflicts = await conflictResolver.getUnresolvedConflicts();
      expect(conflicts, contains(conflict));
      expect(conflicts.length, equals(1));
    });

    test('should retrieve conflicts by entity type', () async {
      final tripConflict = Conflict(
        id: 'conflict-18',
        entityType: EntityType.trip,
        entityId: 'trip-6',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.medium,
        clientData: const {'version': 1},
        serverData: const {'version': 2},
        clientUpdatedAt: DateTime.now(),
        serverUpdatedAt: DateTime.now(),
        detectedAt: DateTime.now(),
      );

      final journalConflict = Conflict(
        id: 'conflict-19',
        entityType: EntityType.journal,
        entityId: 'journal-4',
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
        id: 'conflict-20',
        entityType: EntityType.trip,
        entityId: 'trip-7',
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

      // Resolve the conflict
      when(() => mockTripDao.updateTrip(any())).thenAnswer((_) async => 1);
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
        id: 'conflict-21',
        entityType: EntityType.trip,
        entityId: 'trip-8',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.medium,
        clientData: const {'version': 1},
        serverData: const {'version': 2},
        clientUpdatedAt: twoDaysAgo,
        serverUpdatedAt: twoDaysAgo,
        detectedAt: twoDaysAgo,
      );

      final recentConflict = Conflict(
        id: 'conflict-22',
        entityType: EntityType.journal,
        entityId: 'journal-5',
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

    test('should clear old conflicts', () async {
      final now = DateTime.now();
      final oldDate = now.subtract(const Duration(days: 10));

      final oldConflict = Conflict(
        id: 'conflict-23',
        entityType: EntityType.trip,
        entityId: 'trip-9',
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
        id: 'conflict-24',
        entityType: EntityType.journal,
        entityId: 'journal-6',
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

      // Clear conflicts older than 5 days
      final cutoffDate = now.subtract(const Duration(days: 5));
      await conflictResolver.clearOldConflicts(cutoffDate);

      final history = await conflictResolver.getConflictHistory();

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

  group('ConflictResolver - Batch Resolution', () {
    test('should resolve all conflicts with default strategies', () async {
      final tripConflict = Conflict(
        id: 'conflict-25',
        entityType: EntityType.trip,
        entityId: 'trip-batch-1',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.medium,
        clientData: const {'version': 1},
        serverData: const {'version': 2},
        clientUpdatedAt: DateTime.now(),
        serverUpdatedAt: DateTime.now(),
        detectedAt: DateTime.now(),
      );

      final journalConflict = Conflict(
        id: 'conflict-26',
        entityType: EntityType.journal,
        entityId: 'journal-batch-1',
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

      when(() => mockTripDao.updateTrip(any())).thenAnswer((_) async => 1);
      when(() => mockJournalDao.updateJournal(any()))
          .thenAnswer((_) async => 1);

      final result = await conflictResolver.resolveAllConflicts();

      expect(result.resolvedCount, equals(2));
      expect(result.manualResolutionRequired, equals(0));
      expect(result.failedCount, equals(0));
      expect(result.isSuccessful, isTrue);
    });

    test('should count failed resolutions', () async {
      final conflict1 = Conflict(
        id: 'conflict-27',
        entityType: EntityType.trip,
        entityId: 'trip-fail-1',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.medium,
        clientData: const {'version': 1},
        serverData: const {'version': 2},
        clientUpdatedAt: DateTime.now(),
        serverUpdatedAt: DateTime.now(),
        detectedAt: DateTime.now(),
      );

      final conflict2 = Conflict(
        id: 'conflict-28',
        entityType: EntityType.journal,
        entityId: 'journal-fail-1',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.low,
        clientData: const {'version': 1},
        serverData: const {'version': 2},
        clientUpdatedAt: DateTime.now(),
        serverUpdatedAt: DateTime.now(),
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict1);
      await conflictResolver.recordConflict(conflict2);

      // First succeeds, second fails
      when(() => mockTripDao.updateTrip(any())).thenAnswer((_) async => 1);
      when(() => mockJournalDao.updateJournal(any()))
          .thenThrow(Exception('Database error'));

      final result = await conflictResolver.resolveAllConflicts();

      expect(result.resolvedCount, equals(1));
      expect(result.failedCount, equals(1));
      expect(result.isSuccessful, isFalse);
      expect(result.pendingConflicts.length, equals(1));
    });

    test('should use custom default strategies', () async {
      final customResolver = ConflictResolverImpl(
        database: mockDatabase,
        defaultStrategies: {
          EntityType.trip: ConflictResolutionStrategy.clientWins,
          EntityType.journal: ConflictResolutionStrategy.serverWins,
        },
      );

      final tripConflict = Conflict(
        id: 'conflict-29',
        entityType: EntityType.trip,
        entityId: 'trip-custom',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.medium,
        clientData: const {'version': 1},
        serverData: const {'version': 2},
        clientUpdatedAt: DateTime.now(),
        serverUpdatedAt: DateTime.now(),
        detectedAt: DateTime.now(),
      );

      final journalConflict = Conflict(
        id: 'conflict-30',
        entityType: EntityType.journal,
        entityId: 'journal-custom',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.low,
        clientData: const {'version': 1},
        serverData: const {'version': 2},
        clientUpdatedAt: DateTime.now(),
        serverUpdatedAt: DateTime.now(),
        detectedAt: DateTime.now(),
      );

      await customResolver.recordConflict(tripConflict);
      await customResolver.recordConflict(journalConflict);

      when(() => mockTripDao.updateTrip(any())).thenAnswer((_) async => 1);
      when(() => mockJournalDao.updateJournal(any()))
          .thenAnswer((_) async => 1);

      await customResolver.resolveAllConflicts();

      // Verify trip used client-wins (hasPendingChanges = true)
      final tripUpdate = verify(() => mockTripDao.updateTrip(captureAny()))
          .captured
          .single as TripsCompanion;
      expect(tripUpdate.hasPendingChanges.value, isTrue);

      // Verify journal used server-wins (isSynced = true, hasPendingChanges = false)
      final journalUpdate = verify(
        () => mockJournalDao.updateJournal(captureAny()),
      ).captured.single as JournalsCompanion;
      expect(journalUpdate.isSynced.value, isTrue);
      expect(journalUpdate.hasPendingChanges.value, isFalse);
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

    test('should handle empty conflict list', () async {
      final unresolved = await conflictResolver.getUnresolvedConflicts();
      expect(unresolved, isEmpty);

      final result = await conflictResolver.resolveAllConflicts();
      expect(result.resolvedCount, equals(0));
      expect(result.manualResolutionRequired, equals(0));
      expect(result.failedCount, equals(0));
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

    test('should handle concurrent updates to same entity', () async {
      final conflict1 = Conflict(
        id: 'conflict-concurrent-1',
        entityType: EntityType.trip,
        entityId: 'trip-same',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.medium,
        clientData: const {'version': 2, 'title': 'First Update'},
        serverData: const {'version': 3, 'title': 'Second Update'},
        clientUpdatedAt: DateTime(2024, 1, 10, 10, 0),
        serverUpdatedAt: DateTime(2024, 1, 10, 11, 0),
        detectedAt: DateTime.now(),
      );

      final conflict2 = Conflict(
        id: 'conflict-concurrent-2',
        entityType: EntityType.trip,
        entityId: 'trip-same',
        type: ConflictType.concurrentUpdate,
        severity: ConflictSeverity.medium,
        clientData: const {'version': 3, 'title': 'Third Update'},
        serverData: const {'version': 4, 'title': 'Fourth Update'},
        clientUpdatedAt: DateTime(2024, 1, 10, 12, 0),
        serverUpdatedAt: DateTime(2024, 1, 10, 13, 0),
        detectedAt: DateTime.now(),
      );

      await conflictResolver.recordConflict(conflict1);
      await conflictResolver.recordConflict(conflict2);

      when(() => mockTripDao.updateTrip(any())).thenAnswer((_) async => 1);

      final result = await conflictResolver.resolveAllConflicts();

      expect(result.resolvedCount, equals(2));
      verify(() => mockTripDao.updateTrip(any())).called(2);
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
}
