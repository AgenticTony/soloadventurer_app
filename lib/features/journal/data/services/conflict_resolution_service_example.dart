import 'package:flutter/material.dart';
import 'package:soloadventurer/features/journal/data/datasources/journal_local_data_source.dart';
import 'package:soloadventurer/features/journal/data/datasources/journal_remote_data_source.dart';
import 'package:soloadventurer/features/journal/data/datasources/trip_local_data_source.dart';
import 'package:soloadventurer/features/journal/data/datasources/trip_remote_data_source.dart';
import 'package:soloadventurer/features/journal/data/datasources/tag_local_data_source.dart';
import 'package:soloadventurer/features/journal/data/datasources/tag_remote_data_source.dart';
import 'package:soloadventurer/features/journal/data/models/journal_entry_model.dart';
import 'package:soloadventurer/features/journal/domain/services/conflict_resolution_service.dart';
import 'package:soloadventurer/features/journal/data/services/conflict_resolution_service_impl.dart';

/// Example demonstrating how to integrate and use the ConflictResolutionService
///
/// This file shows complete integration examples including:
/// - Service initialization
/// - Conflict detection
/// - Various resolution strategies
/// - UI integration
/// - Best practices
class ConflictResolutionServiceExample {
  late final ConflictResolutionService _conflictService;

  /// Example 1: Initialize the conflict resolution service
  ///
  /// This should be done during app initialization, typically in
  /// dependency injection or provider setup.
  Future<void> example1_Initialization({
    required JournalLocalDataSource journalLocalDataSource,
    required JournalRemoteDataSource journalRemoteDataSource,
    required TripLocalDataSource tripLocalDataSource,
    required TripRemoteDataSource tripRemoteDataSource,
    required TagLocalDataSource tagLocalDataSource,
    required TagRemoteDataSource tagRemoteDataSource,
  }) async {
    // Create the conflict resolution service
    _conflictService = ConflictResolutionServiceImpl(
      journalLocalDataSource: journalLocalDataSource,
      journalRemoteDataSource: journalRemoteDataSource,
      tripLocalDataSource: tripLocalDataSource,
      tripRemoteDataSource: tripRemoteDataSource,
      tagLocalDataSource: tagLocalDataSource,
      tagRemoteDataSource: tagRemoteDataSource,
    );

    // Initialize the service
    await _conflictService.initialize();

    print('Conflict resolution service initialized');
  }

  /// Example 2: Listen for new conflicts
  ///
  /// Demonstrates how to listen for conflict detection events
  /// and handle them appropriately.
  Future<void> example2_ListenForConflicts() async {
    // Listen to conflict stream
    final subscription = _conflictService.conflictStream.listen((conflict) {
      print('New conflict detected: ${conflict.conflictId}');
      print('Type: ${conflict.entityType}:${conflict.entityId}');
      print('Severity: ${conflict.severity}');
      print('Reason: ${conflict.reason}');

      // Handle based on severity
      switch (conflict.severity) {
        case ConflictSeverity.low:
        case ConflictSeverity.medium:
          // Auto-resolve low/medium severity conflicts
          _autoResolveConflict(conflict);
          break;

        case ConflictSeverity.high:
        case ConflictSeverity.critical:
          // Show UI for high/critical conflicts
          _showConflictResolutionUI(conflict);
          break;
      }
    });

    // Don't forget to cancel subscription when done
    // subscription.cancel();
  }

  /// Example 3: Listen for resolution results
  ///
  /// Demonstrates how to track when conflicts are resolved
  /// and handle success/failure cases.
  Future<void> example3_ListenForResolutionResults() async {
    final subscription = _conflictService.resolutionStream.listen((result) {
      if (result.success) {
        print('Conflict resolved successfully!');
        print('Strategy: ${result.strategy}');
        print('Conflict ID: ${result.conflict.conflictId}');

        // Show success notification
        _showSuccessNotification(result.conflict);
      } else {
        print('Conflict resolution failed!');
        print('Error: ${result.error}');

        // Show error notification
        _showErrorNotification(result.conflict, result.error!);
      }
    });

    // subscription.cancel();
  }

  /// Example 4: Detect conflicts manually
  ///
  /// Shows how to manually check for conflicts between
  /// local and remote versions of an entity.
  Future<void> example4_DetectConflictsManually() async {
    // Simulate local and remote versions
    final localEntry = JournalEntryModel(
      id: 'entry-123',
      tripId: 'trip-456',
      title: 'My Local Title',
      content: 'Content edited offline',
      entryDate: DateTime.now(),
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      updatedAt: DateTime.now().subtract(Duration(seconds: 30)),
    );

    final remoteEntry = JournalEntryModel(
      id: 'entry-123',
      tripId: 'trip-456',
      title: 'My Remote Title',
      content: 'Content edited online',
      entryDate: DateTime.now(),
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      updatedAt: DateTime.now().subtract(Duration(seconds: 20)),
    );

    // Detect conflict
    final conflict = await _conflictService.detectConflict(
      entityType: 'journal_entry',
      localVersion: localEntry.toJson(),
      remoteVersion: remoteEntry.toJson(),
    );

    if (conflict != null) {
      print('Conflict detected!');
      print('Type: ${conflict.conflictType}');
      print('Field conflicts: ${conflict.fieldConflicts.length}');

      for (final fieldConflict in conflict.fieldConflicts) {
        print('  Field: ${fieldConflict.fieldName}');
        print('    Local: ${fieldConflict.localValue}');
        print('    Remote: ${fieldConflict.remoteValue}');
      }
    } else {
      print('No conflict detected');
    }
  }

  /// Example 5: Resolve conflict using most recent strategy
  ///
  /// Most common strategy - uses the version with the most
  /// recent timestamp.
  Future<void> example5_ResolveMostRecent(SyncConflict conflict) async {
    final result = await _conflictService.resolveConflict(
      conflict,
      ConflictResolutionStrategy.mostRecent,
    );

    if (result.success) {
      print('Resolved using most recent strategy');
      print('Resolved version: ${result.resolvedVersion}');
    } else {
      print('Failed to resolve: ${result.error}');
    }
  }

  /// Example 6: Resolve conflict preferring local version
  ///
  /// Useful when user wants to keep their offline changes.
  Future<void> example6_ResolveLocalWins(SyncConflict conflict) async {
    final result = await _conflictService.resolveConflict(
      conflict,
      ConflictResolutionStrategy.localWins,
    );

    if (result.success) {
      print('Resolved using local version');
    } else {
      print('Failed to resolve: ${result.error}');
    }
  }

  /// Example 7: Resolve conflict preferring remote version
  ///
  /// Useful when server/other device data is more authoritative.
  Future<void> example7_ResolveRemoteWins(SyncConflict conflict) async {
    final result = await _conflictService.resolveConflict(
      conflict,
      ConflictResolutionStrategy.remoteWins,
    );

    if (result.success) {
      print('Resolved using remote version');
    } else {
      print('Failed to resolve: ${result.error}');
    }
  }

  /// Example 8: Manual conflict resolution
  ///
  /// User chooses which fields to keep from each version.
  Future<void> example8_ManualResolution(SyncConflict conflict) async {
    // In a real app, this would come from user input in a UI
    final resolvedVersion = {
      'id': conflict.entityId,
      'trip_id': conflict.localVersion['trip_id'],
      'title': conflict.remoteVersion['title'], // User chose remote title
      'content': conflict.localVersion['content'], // User chose local content
      'entry_date': conflict.localVersion['entry_date'],
      'mood': conflict.remoteVersion['mood'],
      'location_name': conflict.localVersion['location_name'],
      'latitude': conflict.localVersion['latitude'],
      'longitude': conflict.localVersion['longitude'],
      'created_at': conflict.localVersion['created_at'],
      'updated_at': DateTime.now().toIso8601String(),
    };

    final result = await _conflictService.resolveConflict(
      conflict,
      ConflictResolutionStrategy.manual,
      resolvedVersion: resolvedVersion,
    );

    if (result.success) {
      print('Manually resolved with custom version');
    } else {
      print('Failed to resolve: ${result.error}');
    }
  }

  /// Example 9: Keep both versions
  ///
  /// Creates a duplicate entry when both versions are important.
  Future<void> example9_KeepBothVersions(SyncConflict conflict) async {
    final result = await _conflictService.resolveConflict(
      conflict,
      ConflictResolutionStrategy.keepBoth,
    );

    if (result.success) {
      print('Created duplicate entry');
      print('New entry ID: ${result.resolvedVersion?['id']}');
    } else {
      print('Failed to resolve: ${result.error}');
    }
  }

  /// Example 10: Resolve all pending conflicts
  ///
  /// Batch resolve all conflicts with a specified strategy.
  Future<void> example10_ResolveAllPending() async {
    // Auto-resolve all low and medium severity conflicts
    final results = await _conflictService.resolveAllPending(
      ConflictResolutionStrategy.mostRecent,
      maxSeverity: ConflictSeverity.medium,
    );

    print('Resolved ${results.length} conflicts');
    print('Success: ${results.where((r) => r.success).length}');
    print('Failed: ${results.where((r) => !r.success).length}');
  }

  /// Example 11: Get conflict statistics
  ///
  /// Shows how to retrieve and display conflict statistics.
  Future<void> example11_GetStatistics() async {
    final stats = await _conflictService.getStatistics();

    print('=== Conflict Statistics ===');
    print('Total conflicts: ${stats.totalConflicts}');
    print('Resolved: ${stats.resolvedConflicts}');
    print('Pending: ${stats.pendingConflicts}');
    print('Failed: ${stats.failedConflicts}');
    print('Ignored: ${stats.ignoredConflicts}');
    print('Success rate: ${(stats.successRate * 100).toStringAsFixed(1)}%');
    print('Most common type: ${stats.mostCommonType}');
    print('Avg resolution time: ${stats.averageResolutionTime.inSeconds}s');
  }

  /// Example 12: Filter conflicts by type and severity
  ///
  /// Demonstrates filtering conflicts by various criteria.
  Future<void> example12_FilterConflicts() async {
    // Get all pending conflicts
    final pendingConflicts = await _conflictService.getPendingConflicts();
    print('Pending conflicts: ${pendingConflicts.length}');

    // Get conflicts by type
    final entryConflicts =
        await _conflictService.getConflictsByType('journal_entry');
    final tripConflicts = await _conflictService.getConflictsByType('trip');
    print('Entry conflicts: ${entryConflicts.length}');
    print('Trip conflicts: ${tripConflicts.length}');

    // Get conflicts by severity
    final criticalConflicts =
        await _conflictService.getConflictsBySeverity(ConflictSeverity.critical);
    final highConflicts =
        await _conflictService.getConflictsBySeverity(ConflictSeverity.high);
    print('Critical conflicts: ${criticalConflicts.length}');
    print('High severity conflicts: ${highConflicts.length}');
  }

  /// Example 13: Ignore a conflict
  ///
  /// Shows how to ignore a conflict without resolving it.
  Future<void> example13_IgnoreConflict(SyncConflict conflict) async {
    await _conflictService.ignoreConflict(conflict.conflictId);
    print('Conflict ${conflict.conflictId} ignored');
  }

  /// Example 14: Retry failed resolution
  ///
  /// Retry a conflict that previously failed to resolve.
  Future<void> example14_RetryFailedResolution(String conflictId) async {
    final result = await _conflictService.retryConflict(conflictId);

    if (result != null && result.success) {
      print('Retry successful!');
    } else {
      print('Retry failed');
    }
  }

  /// Example 15: Progressive conflict resolution
  ///
  /// Demonstrates a common pattern: auto-resolve simple conflicts,
  /// show UI for complex ones.
  Future<void> example15_ProgressiveResolution() async {
    // Step 1: Auto-resolve low severity conflicts
    await _conflictService.resolveAllPending(
      ConflictResolutionStrategy.mostRecent,
      maxSeverity: ConflictSeverity.low,
    );

    // Step 2: Check remaining conflicts
    final remaining = await _conflictService.getPendingConflicts();

    if (remaining.isEmpty) {
      print('All conflicts resolved automatically');
      return;
    }

    // Step 3: Group by severity
    final medium = remaining.where((c) => c.severity == ConflictSeverity.medium);
    final high = remaining.where((c) => c.severity == ConflictSeverity.high);
    final critical = remaining.where((c) => c.severity == ConflictSeverity.critical);

    print('Remaining conflicts:');
    print('  Medium: ${medium.length}');
    print('  High: ${high.length}');
    print('  Critical: ${critical.length}');

    // Step 4: Show UI for remaining conflicts
    // In a real app, this would navigate to a conflicts screen
    _showConflictsListScreen(remaining.toList());
  }

  // Helper methods

  Future<void> _autoResolveConflict(SyncConflict conflict) async {
    await _conflictService.resolveConflict(
      conflict,
      ConflictResolutionStrategy.mostRecent,
    );
  }

  void _showConflictResolutionUI(SyncConflict conflict) {
    // In a real app, this would show a dialog or navigate to a screen
    print('TODO: Show conflict resolution UI for ${conflict.conflictId}');
  }

  void _showConflictsListScreen(List<SyncConflict> conflicts) {
    // In a real app, this would navigate to a conflicts list screen
    print('TODO: Show conflicts list with ${conflicts.length} conflicts');
  }

  void _showSuccessNotification(SyncConflict conflict) {
    // In a real app, this would show a snackbar or toast
    print('SUCCESS: Conflict ${conflict.conflictId} resolved');
  }

  void _showErrorNotification(SyncConflict conflict, String error) {
    // In a real app, this would show an error dialog
    print('ERROR: Failed to resolve ${conflict.conflictId}: $error');
  }
}

/// Example Flutter widgets demonstrating UI integration
class ConflictResolutionUIExample extends StatelessWidget {
  final ConflictResolutionService conflictService;

  const ConflictResolutionUIExample({required this.conflictService});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExampleConflictListScreen(conflictService: conflictService),
        ExampleConflictResolutionDialog(),
        ExampleConflictStatisticsCard(conflictService: conflictService),
      ],
    );
  }
}

/// Example: Conflicts list screen
class ExampleConflictListScreen extends StatelessWidget {
  final ConflictResolutionService conflictService;

  const ExampleConflictListScreen({required this.conflictService});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SyncConflict>>(
      future: conflictService.getPendingConflicts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final conflicts = snapshot.data!;

        if (conflicts.isEmpty) {
          return Center(
            child: Text('No pending conflicts'),
          );
        }

        return ListView.builder(
          itemCount: conflicts.length,
          itemBuilder: (context, index) {
            final conflict = conflicts[index];
            return ConflictCard(
              conflict: conflict,
              onResolve: (strategy) async {
                final result = await conflictService.resolveConflict(
                  conflict,
                  strategy,
                );

                if (result.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Conflict resolved')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed: ${result.error}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              onIgnore: () async {
                await conflictService.ignoreConflict(conflict.conflictId);
              },
            );
          },
        );
      },
    );
  }
}

/// Example: Individual conflict card widget
class ConflictCard extends StatelessWidget {
  final SyncConflict conflict;
  final Function(ConflictResolutionStrategy) onResolve;
  final VoidCallback onIgnore;

  const ConflictCard({
    required this.conflict,
    required this.onResolve,
    required this.onIgnore,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getSeverityIcon(conflict.severity),
                  color: _getSeverityColor(conflict.severity),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    conflict.entityType,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(conflict.severity.name),
                  backgroundColor: _getSeverityColor(conflict.severity),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(conflict.reason),
            SizedBox(height: 8),
            if (conflict.fieldConflicts.isNotEmpty) ...[
              Text('Field conflicts:',
                  style: Theme.of(context).textTheme.labelLarge),
              ...conflict.fieldConflicts.map(
                (fc) => Padding(
                  padding: EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                    '${fc.fieldName}: local="${fc.localValue}" remote="${fc.remoteValue}"',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              SizedBox(height: 8),
            ],
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => onResolve(ConflictResolutionStrategy.localWins),
                  child: Text('Keep Local'),
                ),
                ElevatedButton(
                  onPressed: () => onResolve(ConflictResolutionStrategy.remoteWins),
                  child: Text('Keep Remote'),
                ),
                ElevatedButton(
                  onPressed: () => onResolve(ConflictResolutionStrategy.mostRecent),
                  child: Text('Most Recent'),
                ),
                TextButton(
                  onPressed: onIgnore,
                  child: Text('Ignore'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSeverityIcon(ConflictSeverity severity) {
    switch (severity) {
      case ConflictSeverity.low:
        return Icons.info;
      case ConflictSeverity.medium:
        return Icons.warning;
      case ConflictSeverity.high:
        return Icons.error;
      case ConflictSeverity.critical:
        return Icons.dangerous;
    }
  }

  Color _getSeverityColor(ConflictSeverity severity) {
    switch (severity) {
      case ConflictSeverity.low:
        return Colors.blue;
      case ConflictSeverity.medium:
        return Colors.orange;
      case ConflictSeverity.high:
        return Colors.red;
      case ConflictSeverity.critical:
        return Colors.red.shade900;
    }
  }
}

/// Example: Conflict resolution dialog
class ExampleConflictResolutionDialog extends StatefulWidget {
  const ExampleConflictResolutionDialog();

  @override
  _ExampleConflictResolutionDialogState createState() =>
      _ExampleConflictResolutionDialogState();
}

class _ExampleConflictResolutionDialogState
    extends State<ExampleConflictResolutionDialog> {
  ConflictResolutionStrategy? _selectedStrategy;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Resolve Conflict'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This entry was modified on multiple devices.'),
          SizedBox(height: 16),
          Text('Which version would you like to keep?'),
          SizedBox(height: 16),
          RadioListTile<ConflictResolutionStrategy>(
            title: Text('Local version (your changes)'),
            subtitle: Text('Keep the version edited on this device'),
            value: ConflictResolutionStrategy.localWins,
            groupValue: _selectedStrategy,
            onChanged: (value) => setState(() => _selectedStrategy = value),
          ),
          RadioListTile<ConflictResolutionStrategy>(
            title: Text('Remote version (server changes)'),
            subtitle: Text('Keep the version from the server'),
            value: ConflictResolutionStrategy.remoteWins,
            groupValue: _selectedStrategy,
            onChanged: (value) => setState(() => _selectedStrategy = value),
          ),
          RadioListTile<ConflictResolutionStrategy>(
            title: Text('Most recent'),
            subtitle: Text('Keep the most recently edited version'),
            value: ConflictResolutionStrategy.mostRecent,
            groupValue: _selectedStrategy,
            onChanged: (value) => setState(() => _selectedStrategy = value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedStrategy != null
              ? () => Navigator.pop(context, _selectedStrategy)
              : null,
          child: Text('Resolve'),
        ),
      ],
    );
  }
}

/// Example: Conflict statistics card
class ExampleConflictStatisticsCard extends StatelessWidget {
  final ConflictResolutionService conflictService;

  const ExampleConflictStatisticsCard({required this.conflictService});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ConflictResolutionStatistics>(
      future: conflictService.getStatistics(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final stats = snapshot.data!;

        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Conflict Statistics',
                    style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 16),
                _StatRow('Total conflicts', '${stats.totalConflicts}'),
                _StatRow('Resolved', '${stats.resolvedConflicts}'),
                _StatRow('Pending', '${stats.pendingConflicts}'),
                _StatRow('Failed', '${stats.failedConflicts}'),
                _StatRow('Success rate',
                    '${(stats.successRate * 100).toStringAsFixed(1)}%'),
                if (stats.averageResolutionTime > Duration.zero)
                  _StatRow('Avg resolution time',
                      '${stats.averageResolutionTime.inSeconds}s'),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
