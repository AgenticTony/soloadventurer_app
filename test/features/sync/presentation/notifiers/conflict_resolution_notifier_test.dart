import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_info.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_resolution.dart';
import 'package:soloadventurer/features/sync/domain/models/entity_version.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_operation.dart';
import 'package:soloadventurer/features/sync/domain/services/conflict_resolver.dart';
import 'package:soloadventurer/features/sync/domain/services/sync_service.dart';
import 'package:soloadventurer/features/sync/presentation/notifiers/conflict_resolution_notifier.dart';
import 'package:soloadventurer/features/sync/presentation/state/conflict_resolution_state.dart';
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';

@GenerateMocks([
  ConflictResolver,
  SyncService,
  LoggingService,
])
import 'conflict_resolution_notifier_test.mocks.dart';

void main() {
  late MockConflictResolver mockConflictResolver;
  late MockSyncService mockSyncService;
  late MockLoggingService mockLogger;

  setUp(() {
    mockConflictResolver = MockConflictResolver();
    mockSyncService = MockSyncService();
    mockLogger = MockLoggingService();

    // Setup default mock behaviors
    provideDummy<SyncService>(mockSyncService);
    provideDummy<ConflictResolver>(mockConflictResolver);
    provideDummy<LoggingService>(mockLogger);

    // Setup logging service to not throw
    when(mockLogger.logStateTransition(
      feature: anyNamed('feature'),
      fromState: anyNamed('fromState'),
      toState: anyNamed('toState'),
      metadata: anyNamed('metadata'),
      stackTrace: anyNamed('stackTrace'),
    )).thenReturn(null);

    when(mockLogger.logSyncEvent(
      event: anyNamed('event'),
      status: anyNamed('status'),
      metadata: anyNamed('metadata'),
    )).thenReturn(null);

    when(mockLogger.logError(
      feature: anyNamed('feature'),
      error: anyNamed('error'),
      code: anyNamed('code'),
      metadata: anyNamed('metadata'),
      stackTrace: anyNamed('stackTrace'),
    )).thenReturn(null);
  });

  group('ConflictResolutionNotifier', () {
    late ConflictResolutionNotifier notifier;

    setUp(() {
      notifier = ConflictResolutionNotifier(
        conflictResolver: mockConflictResolver,
        syncService: mockSyncService,
        logger: mockLogger,
      );
    });

    tearDown(() {
      notifier.dispose();
    });

    test('should start with initial state', () {
      expect(
        notifier.state.value,
        isA<ConflictResolutionState>()
            .having((s) => s.pendingConflicts, 'pendingConflicts', isEmpty)
            .having((s) => s.activeConflict, 'activeConflict', null)
            .having((s) => s.resolution, 'resolution', null)
            .having((s) => s.isResolving, 'isResolving', false),
      );
    });

    test('should set conflicts', () {
      final conflicts = [_createTestConflict()];

      notifier.setConflicts(conflicts);

      expect(
        notifier.state.value,
        isA<ConflictResolutionState>()
            .having((s) => s.pendingConflicts.length, 'pendingConflicts', 1)
            .having((s) => s.pendingConflicts.first.entityId, 'entityId',
                conflicts.first.entityId),
      );
    });

    test('should start resolution', () {
      final conflict = _createTestConflict();

      notifier.startResolution(conflict);

      expect(
        notifier.state.value,
        isA<ConflictResolutionState>()
            .having((s) => s.activeConflict?.entityId, 'activeConflict.entityId',
                conflict.entityId)
            .having((s) => s.isResolving, 'isResolving', true),
      );
    });

    test('should cancel resolution', () {
      final conflict = _createTestConflict();
      notifier.startResolution(conflict);

      notifier.cancelResolution();

      expect(
        notifier.state.value,
        isA<ConflictResolutionState>()
            .having((s) => s.wasCancelled, 'wasCancelled', true)
            .having((s) => s.isResolving, 'isResolving', false),
      );
    });

    test('should reset state', () {
      notifier.setConflicts([_createTestConflict()]);
      notifier.reset();

      expect(
        notifier.state.value,
        isA<ConflictResolutionState>()
            .having((s) => s.pendingConflicts, 'pendingConflicts', isEmpty)
            .having((s) => s.activeConflict, 'activeConflict', null),
      );
    });

    group('applyUserChoice - keepLocal', () {
      test('should apply keepLocal choice successfully', () async {
        final conflict = _createTestConflict();
        notifier.startResolution(conflict);

        final resolution = _createTestResolution(
          conflict: conflict,
          choseLocal: true,
        );

        when(mockConflictResolver.resolveManually(
          conflict: anyNamed('conflict'),
          userChoice: anyNamed('userChoice'),
          customData: anyNamed('customData'),
        )).thenAnswer((_) async => resolution);

        when(mockSyncService.enqueueOperation(any))
            .thenAnswer((_) async => true);

        when(mockSyncService.processQueue())
            .thenAnswer((_) async => SyncResult.success());

        await notifier.applyUserChoice(
          choice: ManualResolutionChoice.keepLocal,
        );

        expect(
          notifier.state.value?.isResolved,
          true,
        );

        verify(mockConflictResolver.resolveManually(
          conflict: argThat(same(conflict)),
          userChoice: ManualResolutionChoice.keepLocal,
          customData: null,
        )).called(1);

        verify(mockSyncService.enqueueOperation(
          argThat(
            isA<SyncOperation>()
                .having((op) => op.entityId, 'entityId', conflict.entityId)
                .having((op) => op.operationType, 'operationType',
                    SyncOperationType.update),
          ),
        )).called(1);

        verify(mockSyncService.processQueue()).called(1);
      });
    });

    group('applyUserChoice - keepRemote', () {
      test('should apply keepRemote choice successfully', () async {
        final conflict = _createTestConflict();
        notifier.startResolution(conflict);

        final resolution = _createTestResolution(
          conflict: conflict,
          choseRemote: true,
        );

        when(mockConflictResolver.resolveManually(
          conflict: anyNamed('conflict'),
          userChoice: anyNamed('userChoice'),
          customData: anyNamed('customData'),
        )).thenAnswer((_) async => resolution);

        when(mockSyncService.enqueueOperation(any))
            .thenAnswer((_) async => true);

        when(mockSyncService.processQueue())
            .thenAnswer((_) async => SyncResult.success());

        await notifier.applyUserChoice(
          choice: ManualResolutionChoice.keepRemote,
        );

        expect(notifier.state.value?.isResolved, true);

        verify(mockConflictResolver.resolveManually(
          conflict: argThat(same(conflict)),
          userChoice: ManualResolutionChoice.keepRemote,
          customData: null,
        )).called(1);
      });
    });

    group('applyUserChoice - customMerge', () {
      test('should apply customMerge choice successfully', () async {
        final conflict = _createTestConflict();
        notifier.startResolution(conflict);

        final customData = {'name': 'Merged Name'};
        final resolution = _createTestResolution(
          conflict: conflict,
          isMerged: true,
          resolvedData: customData,
        );

        when(mockConflictResolver.resolveManually(
          conflict: anyNamed('conflict'),
          userChoice: anyNamed('userChoice'),
          customData: anyNamed('customData'),
        )).thenAnswer((_) async => resolution);

        when(mockSyncService.enqueueOperation(any))
            .thenAnswer((_) async => true);

        when(mockSyncService.processQueue())
            .thenAnswer((_) async => SyncResult.success());

        await notifier.applyUserChoice(
          choice: ManualResolutionChoice.customMerge,
          customData: customData,
        );

        expect(notifier.state.value?.isResolved, true);
        expect(notifier.state.value?.resolution?.isMerged, true);

        verify(mockConflictResolver.resolveManually(
          conflict: argThat(same(conflict)),
          userChoice: ManualResolutionChoice.customMerge,
          customData: argThat(same(customData)),
        )).called(1);
      });
    });

    test('should handle resolution error', () async {
      final conflict = _createTestConflict();
      notifier.startResolution(conflict);

      when(mockConflictResolver.resolveManually(
        conflict: anyNamed('conflict'),
        userChoice: anyNamed('userChoice'),
        customData: anyNamed('customData'),
      )).thenThrow(
        ConflictResolutionException(
          message: 'Resolution failed',
          code: 'RESOLUTION_ERROR',
        ),
      );

      await notifier.applyUserChoice(
        choice: ManualResolutionChoice.keepLocal,
      );

      expect(notifier.state.value?.hasError, true);
      expect(notifier.state.value?.errorMessage, isNotNull);
    });

    test('should handle queue failure', () async {
      final conflict = _createTestConflict();
      notifier.startResolution(conflict);

      final resolution = _createTestResolution(conflict: conflict);

      when(mockConflictResolver.resolveManually(
        conflict: anyNamed('conflict'),
        userChoice: anyNamed('userChoice'),
        customData: anyNamed('customData'),
      )).thenAnswer((_) async => resolution);

      when(mockSyncService.enqueueOperation(any))
          .thenAnswer((_) async => false);

      await notifier.applyUserChoice(
        choice: ManualResolutionChoice.keepLocal,
      );

      expect(notifier.state.value?.hasError, true);
    });

    test('should resolve multiple conflicts', () async {
      final conflicts = [
        _createTestConflict(entityId: 'conflict-1'),
        _createTestConflict(entityId: 'conflict-2'),
      ];

      final resolution1 = _createTestResolution(
        conflict: conflicts[0],
      );
      final resolution2 = _createTestResolution(
        conflict: conflicts[1],
      );

      final batchResult = BatchResolutionResult.allResolved(
        resolutions: [resolution1, resolution2],
      );

      when(mockConflictResolver.resolveMultipleConflicts(
        conflicts: anyNamed('conflicts'),
      )).thenAnswer((_) async => batchResult);

      when(mockSyncService.enqueueOperation(any))
          .thenAnswer((_) async => true);

      when(mockSyncService.processQueue())
          .thenAnswer((_) async => SyncResult.success());

      await notifier.resolveMultipleConflicts(conflicts);

      expect(notifier.state.value?.pendingConflicts, isEmpty);
      verify(mockSyncService.processQueue()).called(1);
    });

    test('should auto-resolve conflicts', () async {
      final conflict = _createTestConflict();

      when(mockConflictResolver.canMergeAutomatically(conflict: anyNamed('conflict')))
          .thenReturn(true);

      final resolution = _createTestResolution(conflict: conflict);

      final batchResult = BatchResolutionResult.allResolved(
        resolutions: [resolution],
      );

      when(mockConflictResolver.resolveMultipleConflicts(
        conflicts: anyNamed('conflicts'),
      )).thenAnswer((_) async => batchResult);

      when(mockSyncService.enqueueOperation(any))
          .thenAnswer((_) async => true);

      when(mockSyncService.processQueue())
          .thenAnswer((_) async => SyncResult.success());

      await notifier.autoResolveConflicts([conflict]);

      verify(mockConflictResolver.resolveMultipleConflicts(
        conflicts: argThat(isListWithLength(1)),
      )).called(1);
    });

    test('should skip auto-resolve when no conflicts are resolvable', () async {
      final conflict = _createTestConflict();

      when(mockConflictResolver.canMergeAutomatically(conflict: anyNamed('conflict')))
          .thenReturn(false);

      await notifier.autoResolveConflicts([conflict]);

      verifyNever(mockConflictResolver.resolveMultipleConflicts(
        conflicts: anyNamed('conflicts'),
      ));
    });
  });
}

// Test helpers

ConflictInfo _createTestConflict({String entityId = 'test-entity-1'}) {
  final now = DateTime.now().toUtc();

  return ConflictInfo(
    conflictId: 'conflict-$entityId',
    entityId: entityId,
    entityType: 'trip',
    conflictType: ConflictType.diverged,
    severity: ConflictSeverity.medium,
    description: 'Test conflict',
    localVersion: EntityVersion(
      entityId: entityId,
      entityType: 'trip',
      version: 1,
      timestamp: now.subtract(const Duration(hours: 1)),
      deviceId: 'device-1',
      dataHash: 'hash-local',
    ),
    remoteVersion: EntityVersion(
      entityId: entityId,
      entityType: 'trip',
      version: 2,
      timestamp: now,
      deviceId: 'device-2',
      dataHash: 'hash-remote',
    ),
    localData: {'name': 'Local Trip'},
    remoteData: {'name': 'Remote Trip'},
    detectedAt: now,
  );
}

ConflictResolution _createTestResolution({
  required ConflictInfo conflict,
  bool choseLocal = false,
  bool choseRemote = false,
  bool isMerged = false,
  Map<String, dynamic>? resolvedData,
}) {
  return ConflictResolution(
    conflictId: conflict.conflictId,
    entityId: conflict.entityId,
    entityType: conflict.entityType,
    strategy: ConflictResolutionStrategy.manual,
    resolvedData: resolvedData ?? {'name': 'Resolved Trip'},
    resolvedVersion: EntityVersion(
      entityId: conflict.entityId,
      entityType: conflict.entityType,
      version: 3,
      timestamp: DateTime.now().toUtc(),
      deviceId: 'device-1',
      dataHash: 'resolved-hash',
    ),
    choseLocal: choseLocal,
    choseRemote: choseRemote,
    isMerged: isMerged,
    resolvedAt: DateTime.now().toUtc(),
  );
}
