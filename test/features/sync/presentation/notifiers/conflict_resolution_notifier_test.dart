import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_info.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_resolution.dart';
// ManualResolutionChoice is in conflict_resolution.dart
import 'package:soloadventurer/features/sync/domain/models/entity_version.dart';
import 'package:soloadventurer/features/sync/domain/services/conflict_resolver.dart';
import 'package:soloadventurer/features/sync/domain/services/sync_service.dart';
import 'package:soloadventurer/features/sync/presentation/notifiers/conflict_resolution_notifier.dart';
import 'package:soloadventurer/features/sync/presentation/providers/conflict_resolution_providers.dart';
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
  late ProviderContainer container;
  ProviderSubscription<AsyncValue<ConflictResolutionState>>? crSubscription;

  setUp(() {
    mockConflictResolver = MockConflictResolver();
    mockSyncService = MockSyncService();
    mockLogger = MockLoggingService();

    when(mockLogger.logStateTransition(
      feature: anyNamed('feature'),
      fromState: anyNamed('fromState'),
      toState: anyNamed('toState'),
      metadata: anyNamed('metadata'),
      stackTrace: anyNamed('stackTrace'),
    )).thenReturn(null);

    when(mockLogger.logError(
      feature: anyNamed('feature'),
      error: anyNamed('error'),
      code: anyNamed('code'),
      metadata: anyNamed('metadata'),
      stackTrace: anyNamed('stackTrace'),
    )).thenReturn(null);

    when(mockSyncService.enqueueOperation(any))
        .thenAnswer((_) async => true);
    when(mockSyncService.processQueue())
        .thenAnswer((_) async => SyncResult.success());

    container = ProviderContainer.test(
      retry: (_, __) => null,
      overrides: [
        conflictResolverProvider.overrideWithValue(mockConflictResolver),
        syncServiceProvider.overrideWithValue(mockSyncService),
        loggingServiceProvider.overrideWithValue(mockLogger),
      ],
    );
  });

  tearDown(() {
    crSubscription?.close();
    crSubscription = null;
    container.dispose();
  });

  /// Read the current state, unwrapping from AsyncValue.
  /// Ensures the provider stays active via persistent listen.
  ConflictResolutionState readState() {
    crSubscription ??= container.listen<AsyncValue<ConflictResolutionState>>(
      conflictResolutionProvider,
      (_, __) {},
      fireImmediately: true,
    );
    return container.read(conflictResolutionProvider).value ??
        ConflictResolutionState.initial();
  }

  EntityVersion makeVersion({
    String entityId = 'entity-1',
    int version = 1,
    String deviceId = 'device-a',
  }) {
    return EntityVersion(
      entityId: entityId,
      entityType: 'trip',
      version: version,
      deviceId: deviceId,
      lastModified: DateTime.now(),
    );
  }

  ConflictInfo makeConflict({
    String conflictId = 'conflict-1',
    String entityId = 'entity-1',
    ConflictType type = ConflictType.versionConflict,
    ConflictSeverity severity = ConflictSeverity.medium,
  }) {
    return ConflictInfo(
      conflictId: conflictId,
      entityId: entityId,
      entityType: 'trip',
      conflictType: type,
      severity: severity,
      localVersion: makeVersion(deviceId: 'device-a'),
      remoteVersion: makeVersion(version: 2, deviceId: 'device-b'),
      localData: {'title': 'Local'},
      remoteData: {'title': 'Remote'},
      description: 'Test conflict',
      detectedAt: DateTime.now(),
    );
  }

  group('ConflictResolutionNotifier', () {
    test('starts with initial state', () async {
      // Allow async build to complete
      await container.pump();
      expect(readState(), isA<ConflictResolutionState>());
    });

    test('setConflicts updates pending conflicts', () async {
      await container.pump();
      final c1 = makeConflict(conflictId: 'c1');
      final c2 = makeConflict(conflictId: 'c2');

      final notifier = container.read(conflictResolutionProvider.notifier);
      notifier.setConflicts([c1, c2]);

      expect(readState().pendingConflicts.length, 2);
    });

    test('startResolution sets active conflict', () async {
      await container.pump();
      final conflict = makeConflict();
      final notifier = container.read(conflictResolutionProvider.notifier);
      notifier.setConflicts([conflict]);
      notifier.startResolution(conflict);

      expect(readState().activeConflict, isNotNull);
    });

    test('cancelResolution marks state as cancelled', () async {
      await container.pump();
      final conflict = makeConflict();
      final notifier = container.read(conflictResolutionProvider.notifier);
      notifier.setConflicts([conflict]);
      notifier.startResolution(conflict);
      notifier.cancelResolution();

      expect(readState().wasCancelled, true);
    });

    test('reset clears all state', () async {
      await container.pump();
      final conflict = makeConflict();
      final notifier = container.read(conflictResolutionProvider.notifier);
      notifier.setConflicts([conflict]);
      notifier.startResolution(conflict);
      notifier.reset();

      expect(readState().pendingConflicts, isEmpty);
      expect(readState().activeConflict, isNull);
    });

    test('applyUserChoice resolves with chosen strategy', () async {
      await container.pump();
      final conflict = makeConflict();
      // Ensure provider stays active for async operations
      readState();
      final notifier = container.read(conflictResolutionProvider.notifier);
      notifier.setConflicts([conflict]);
      notifier.startResolution(conflict);

      final resolution = ConflictResolution(
        conflictId: 'conflict-1',
        entityId: 'entity-1',
        entityType: 'trip',
        strategy: ConflictResolutionStrategy.lastWriteWins,
        resolvedData: {'title': 'Local'},
        resolvedVersion: makeVersion(version: 3),
        choseLocal: true,
        resolvedAt: DateTime.now(),
      );

      when(mockConflictResolver.resolveManually(
        conflict: anyNamed('conflict'),
        userChoice: anyNamed('userChoice'),
      )).thenAnswer((_) async => resolution);

      await notifier.applyUserChoice(
        choice: ManualResolutionChoice.keepLocal,
      );

      verify(mockConflictResolver.resolveManually(
        conflict: anyNamed('conflict'),
        userChoice: anyNamed('userChoice'),
      )).called(1);
    });

    test('autoResolveConflicts resolves multiple conflicts', () async {
      await container.pump();
      final c1 = makeConflict(conflictId: 'c1');
      final c2 = makeConflict(conflictId: 'c2');

      final r1 = ConflictResolution(
        conflictId: 'c1',
        entityId: 'entity-1',
        entityType: 'trip',
        strategy: ConflictResolutionStrategy.lastWriteWins,
        resolvedData: {'title': 'Resolved'},
        resolvedVersion: makeVersion(version: 3),
        resolvedAt: DateTime.now(),
      );
      final r2 = ConflictResolution(
        conflictId: 'c2',
        entityId: 'entity-1',
        entityType: 'trip',
        strategy: ConflictResolutionStrategy.lastWriteWins,
        resolvedData: {'title': 'Resolved'},
        resolvedVersion: makeVersion(version: 3),
        resolvedAt: DateTime.now(),
      );

      when(mockConflictResolver.canMergeAutomatically(
        conflict: anyNamed('conflict'),
      )).thenReturn(true);

      when(mockConflictResolver.resolveMultipleConflicts(
        conflicts: anyNamed('conflicts'),
      )).thenAnswer((_) async => BatchResolutionResult(
        totalConflicts: 2,
        resolvedCount: 2,
        failedCount: 0,
        resolutions: [r1, r2],
        failedConflicts: [],
        errors: {},
      ));

      final notifier = container.read(conflictResolutionProvider.notifier);
      // Ensure provider stays active
      readState();
      await notifier.autoResolveConflicts([c1, c2]);
    });

    test('handles resolution errors gracefully', () async {
      await container.pump();
      final conflict = makeConflict();
      final notifier = container.read(conflictResolutionProvider.notifier);
      notifier.setConflicts([conflict]);
      notifier.startResolution(conflict);

      when(mockConflictResolver.resolveManually(
        conflict: anyNamed('conflict'),
        userChoice: anyNamed('userChoice'),
      )).thenThrow(Exception('Resolution failed'));

      try {
        await notifier.applyUserChoice(
          choice: ManualResolutionChoice.keepLocal,
        );
      } catch (_) {
        // Expected - error is captured in AsyncValue
      }
    });
  });
}
