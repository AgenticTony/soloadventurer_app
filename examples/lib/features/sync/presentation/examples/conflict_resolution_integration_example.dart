import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_info.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_resolution.dart';
import 'package:soloadventurer/features/sync/presentation/providers/conflict_resolution_providers.dart';
import 'package:soloadventurer/features/sync/presentation/widgets/conflict_resolution_dialog.dart';
import 'package:soloadventurer/features/sync/presentation/widgets/conflict_banner.dart';
import 'package:soloadventurer/features/sync/presentation/widgets/conflict_list_view.dart';

/// Example demonstrating how to integrate conflict resolution into your app
///
/// This example shows the complete flow of:
/// 1. Detecting conflicts
/// 2. Showing conflict UI to user
/// 3. Processing user's resolution choice
/// 4. Applying resolution to local and remote data
/// 5. Updating UI
class ConflictResolutionIntegrationExample extends ConsumerStatefulWidget {
  const ConflictResolutionIntegrationExample({super.key});

  @override
  ConsumerState<ConflictResolutionIntegrationExample> createState() =>
      _ConflictResolutionIntegrationExampleState();
}

class _ConflictResolutionIntegrationExampleState
    extends ConsumerState<ConflictResolutionIntegrationExample> {
  @override
  Widget build(BuildContext context) {
    // Watch the conflict resolution status
    final status = ref.watch(conflictResolutionStatusProvider);
    final pendingCount = ref.watch(pendingConflictsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conflict Resolution Example'),
        actions: [
          // Show badge if there are pending conflicts
          if (pendingCount > 0)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Badge(
                label: Text('$pendingCount'),
                child: const Icon(Icons.warning),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Example 1: Single conflict banner
          if (status == ConflictResolutionStatus.hasConflicts)
            const _ConflictBannerExample(),

          // Example 2: Conflict list view
          if (pendingCount > 1) const _ConflictListExample(),

          // Example 3: Resolution status display
          const _ResolutionStatusExample(),

          // Example 4: Action buttons
          const _ActionButtonsExample(),
        ],
      ),
    );
  }
}

/// Example 1: Single conflict banner
///
/// Shows a banner when there's an active conflict that needs resolution.
class _ConflictBannerExample extends ConsumerWidget {
  const _ConflictBannerExample();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeConflict = ref.watch(activeConflictProvider);

    if (activeConflict == null) {
      return const SizedBox.shrink();
    }

    return ConflictBanner.single(
      conflict: activeConflict,
      onResolve: () => _showResolutionDialog(context, ref, activeConflict),
      onDismiss: () {
        ref
            .read(conflictResolutionNotifierProvider.notifier)
            .cancelResolution();
      },
    );
  }

  Future<void> _showResolutionDialog(
    BuildContext context,
    WidgetRef ref,
    ConflictInfo conflict,
  ) async {
    // Check if merge is possible
    final canMerge = ref.read(conflictResolverProvider).canMergeAutomatically(
          conflict: conflict,
        );

    // Show dialog and get user's choice
    final choice = await ConflictResolutionDialog.show(
      context: context,
      conflict: conflict,
      canMerge: canMerge,
    );

    // Apply user's choice
    if (choice != null) {
      ref
          .read(conflictResolutionNotifierProvider.notifier)
          .applyUserChoice(choice: choice);
    }
  }
}

/// Example 2: Conflict list view
///
/// Shows a list of all pending conflicts when there are multiple.
class _ConflictListExample extends ConsumerWidget {
  const _ConflictListExample();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(currentConflictResolutionStateProvider);
    final conflicts = state?.pendingConflicts ?? [];

    if (conflicts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Expanded(
      child: ConflictListView(
        conflicts: conflicts,
        onConflictTap: (conflict) {
          _showResolutionDialog(context, ref, conflict);
        },
        onAutoResolve: () {
          ref
              .read(conflictResolutionNotifierProvider.notifier)
              .autoResolveConflicts(conflicts);
        },
      ),
    );
  }

  Future<void> _showResolutionDialog(
    BuildContext context,
    WidgetRef ref,
    ConflictInfo conflict,
  ) async {
    final notifier = ref.read(conflictResolutionNotifierProvider.notifier);
    final resolver = ref.read(conflictResolverProvider);

    // Start resolution
    notifier.startResolution(conflict);

    // Check if merge is possible
    final canMerge = resolver.canMergeAutomatically(conflict: conflict);

    // Show dialog and get user's choice
    final choice = await ConflictResolutionDialog.show(
      context: context,
      conflict: conflict,
      canMerge: canMerge,
    );

    // Apply user's choice
    if (choice != null) {
      await notifier.applyUserChoice(choice: choice);
    } else {
      notifier.cancelResolution();
    }
  }
}

/// Example 3: Resolution status display
///
/// Shows the current status of conflict resolution.
class _ResolutionStatusExample extends ConsumerWidget {
  const _ResolutionStatusExample();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(conflictResolutionStatusProvider);
    final state = ref.watch(currentConflictResolutionStateProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resolution Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildStatusRow(context, 'Status', _getStatusText(status)),
            if (state?.activeConflict != null) ...[
              const SizedBox(height: 4),
              _buildStatusRow(
                context,
                'Active Conflict',
                state!.activeConflict!.entityId,
              ),
            ],
            if (state?.resolution != null) ...[
              const SizedBox(height: 4),
              _buildStatusRow(
                context,
                'Strategy',
                state!.resolution!.strategy.name,
              ),
              const SizedBox(height: 4),
              _buildStatusRow(
                context,
                'Resolved At',
                state.resolution!.resolvedAt.toIso8601String(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context, String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  String _getStatusText(ConflictResolutionStatus status) {
    switch (status) {
      case ConflictResolutionStatus.idle:
        return 'Idle';
      case ConflictResolutionStatus.hasConflicts:
        return 'Has Conflicts';
      case ConflictResolutionStatus.resolving:
        return 'Resolving...';
      case ConflictResolutionStatus.resolved:
        return 'Resolved';
      case ConflictResolutionStatus.failed:
        return 'Failed';
      case ConflictResolutionStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Example 4: Action buttons
///
/// Provides buttons to trigger various conflict resolution actions.
class _ActionButtonsExample extends ConsumerWidget {
  const _ActionButtonsExample();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(conflictResolutionStatusProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // Simulate detecting conflicts
          ElevatedButton.icon(
            onPressed: () => _simulateConflicts(ref),
            icon: const Icon(Icons.add_alert),
            label: const Text('Simulate Conflicts'),
          ),

          // Auto-resolve conflicts
          if (status == ConflictResolutionStatus.hasConflicts)
            ElevatedButton.icon(
              onPressed: () => _autoResolve(ref),
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('Auto-Resolve'),
            ),

          // Reset state
          if (status == ConflictResolutionStatus.resolved ||
              status == ConflictResolutionStatus.failed ||
              status == ConflictResolutionStatus.cancelled)
            ElevatedButton.icon(
              onPressed: () => _reset(ref),
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
            ),
        ],
      ),
    );
  }

  void _simulateConflicts(WidgetRef ref) {
    // Create sample conflict
    final sampleConflict = _createSampleConflict();

    // Add to pending conflicts
    ref.read(conflictResolutionNotifierProvider.notifier).setConflicts([
      sampleConflict,
    ]);
  }

  void _autoResolve(WidgetRef ref) {
    final state = ref.read(currentConflictResolutionStateProvider);
    final conflicts = state?.pendingConflicts ?? [];

    ref
        .read(conflictResolutionNotifierProvider.notifier)
        .autoResolveConflicts(conflicts);
  }

  void _reset(WidgetRef ref) {
    ref.read(conflictResolutionNotifierProvider.notifier).reset();
  }

  ConflictInfo _createSampleConflict() {
    // This is a simplified example
    // In real code, you would create actual conflicts from sync detection
    return ConflictInfo(
      conflictId: 'sample-conflict-1',
      entityId: 'trip-123',
      entityType: 'trip',
      conflictType: ConflictType.diverged,
      severity: ConflictSeverity.medium,
      description: 'This trip was modified on multiple devices',
      localVersion: EntityVersion(
        entityId: 'trip-123',
        entityType: 'trip',
        version: 2,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        deviceId: 'device-1',
        dataHash: 'abc123',
      ),
      remoteVersion: EntityVersion(
        entityId: 'trip-123',
        entityType: 'trip',
        version: 3,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        deviceId: 'device-2',
        dataHash: 'def456',
      ),
      localData: const {
        'name': 'Trip to Paris',
        'startDate': '2024-06-01',
      },
      remoteData: const {
        'name': 'Trip to Paris',
        'startDate': '2024-06-15', // Modified on remote
      },
      detectedAt: DateTime.now().toUtc(),
    );
  }
}

/// Example: Using conflict resolution in a real sync flow
///
/// This shows how you would integrate conflict resolution
/// into your actual sync service or data layer.
class SyncFlowExample {
  /// Example method that would be called during sync
  static Future<void> handleDetectedConflicts(
    BuildContext context,
    WidgetRef ref,
    List<ConflictInfo> conflicts,
  ) async {
    if (conflicts.isEmpty) return;

    final notifier = ref.read(conflictResolutionNotifierProvider.notifier);

    // Filter auto-resolvable conflicts
    final autoResolvable = conflicts.where((conflict) {
      return ref.read(conflictResolverProvider).canMergeAutomatically(
            conflict: conflict,
          );
    }).toList();

    final manualConflicts = conflicts.where((conflict) {
      return !autoResolvable.contains(conflict);
    }).toList();

    // Auto-resolve what we can
    if (autoResolvable.isNotEmpty) {
      await notifier.autoResolveConflicts(autoResolvable);
    }

    // Set remaining conflicts for manual resolution
    if (manualConflicts.isNotEmpty) {
      notifier.setConflicts(manualConflicts);

      // If only one conflict, show dialog immediately
      if (manualConflicts.length == 1) {
        final conflict = manualConflicts.first;
        notifier.startResolution(conflict);

        final canMerge =
            ref.read(conflictResolverProvider).canMergeAutomatically(
                  conflict: conflict,
                );

        final choice = await ConflictResolutionDialog.show(
          context: context,
          conflict: conflict,
          canMerge: canMerge,
        );

        if (choice != null) {
          await notifier.applyUserChoice(choice: choice);
        }
      }
      // If multiple conflicts, show list view
      // (The UI will handle this via watching the state)
    }
  }
}

/// Example: Listening to resolution results
///
/// This shows how to listen for resolution completion
/// and trigger follow-up actions.
class ResolutionListenerExample extends ConsumerStatefulWidget {
  const ResolutionListenerExample({super.key});

  @override
  ConsumerState<ResolutionListenerExample> createState() =>
      _ResolutionListenerExampleState();
}

class _ResolutionListenerExampleState
    extends ConsumerState<ResolutionListenerExample> {
  @override
  Widget build(BuildContext context) {
    // Listen to state changes
    ref.listen<AsyncValue<ConflictResolutionState>>(
      conflictResolutionNotifierProvider,
      (previous, next) {
        final previousValue = previous?.value;
        final nextValue = next.value;

        // Check if resolution just completed
        if (previousValue?.isResolved == false &&
            nextValue?.isResolved == true) {
          _onResolutionComplete(nextValue!.resolution!);
        }

        // Check if resolution just failed
        if (next.hasError) {
          _onResolutionFailed(next.error.toString());
        }

        // Check if resolution was cancelled
        if (nextValue?.wasCancelled == true &&
            previousValue?.wasCancelled == false) {
          _onResolutionCancelled();
        }
      },
    );

    return const SizedBox.shrink();
  }

  void _onResolutionComplete(ConflictResolution resolution) {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Resolved ${resolution.entityType} ${resolution.entityId}'),
        backgroundColor: Colors.green,
      ),
    );

    // Trigger follow-up actions
    // For example, refresh UI, navigate away, etc.
  }

  void _onResolutionFailed(String error) {
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to resolve: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _onResolutionCancelled() {
    // Handle cancellation
    debugPrint('Resolution was cancelled by user');
  }
}
