import 'package:flutter/material.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_info.dart';
import 'package:soloadventurer/features/sync/domain/models/entity_version.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_info.dart'
    show ConflictType, ConflictSeverity;
import 'conflict_resolution_dialog.dart';
import 'conflict_banner.dart';
import 'conflict_list_view.dart';

/// Example usage of conflict resolution widgets
///
/// This file demonstrates how to use the conflict resolution UI components
/// in your application.
class ConflictWidgetsExample extends StatelessWidget {
  const ConflictWidgetsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conflict Resolution Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSingleConflictBanner(context),
          const SizedBox(height: 24),
          _buildMultipleConflictsBanner(context),
          const SizedBox(height: 24),
          _buildConflictList(context),
        ],
      ),
    );
  }

  /// Example: Single conflict banner
  Widget _buildSingleConflictBanner(BuildContext context) {
    final conflict = _createSampleConflict();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Single Conflict Banner',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ConflictBanner(
          conflict: conflict,
          onResolve: () {
            ConflictResolutionDialog.show(
              context: context,
              conflict: conflict,
              canMerge: true,
            ).then((choice) {
              if (choice != null) {
                // Handle user's choice
                _handleResolutionChoice(context, choice);
              }
            });
          },
          onDismiss: () {
            // Handle dismiss
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Conflict dismissed')),
            );
          },
        ),
      ],
    );
  }

  /// Example: Multiple conflicts banner
  Widget _buildMultipleConflictsBanner(BuildContext context) {
    final conflicts = [
      _createSampleConflict(),
      _createSampleConflict(),
      _createSampleConflict(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Multiple Conflicts Banner',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        MultipleConflictsBanner(
          conflicts: conflicts,
          onViewAll: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: const Text('All Conflicts'),
                  ),
                  body: ConflictListView(
                    conflicts: conflicts,
                    onConflictSelected: (conflict) {
                      ConflictResolutionDialog.show(
                        context: context,
                        conflict: conflict,
                        canMerge: false,
                      ).then((choice) {
                        if (choice != null) {
                          _handleResolutionChoice(context, choice);
                        }
                      });
                    },
                    onAutoResolve: () {
                      // Handle auto-resolve
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Auto-resolving conflicts...'),
                        ),
                      );
                    },
                    canAutoResolve: true,
                  ),
                ),
              ),
            );
          },
          onDismiss: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Banner dismissed')),
            );
          },
        ),
      ],
    );
  }

  /// Example: Conflict list view
  Widget _buildConflictList(BuildContext context) {
    final conflicts = [
      _createSampleConflict(),
      _createSampleConflict(severity: ConflictSeverity.high),
      _createSampleConflict(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conflict List View',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ConflictListView(
          conflicts: conflicts,
          onConflictSelected: (conflict) {
            ConflictResolutionDialog.show(
              context: context,
              conflict: conflict,
              canMerge: conflict.severity == ConflictSeverity.low,
            ).then((choice) {
              if (choice != null) {
                _handleResolutionChoice(context, choice);
              }
            });
          },
          onAutoResolve: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Auto-resolving conflicts...')),
            );
          },
          canAutoResolve: true,
        ),
      ],
    );
  }

  /// Handles user's resolution choice
  void _handleResolutionChoice(
    BuildContext context,
    choice,
  ) {
    String message;
    switch (choice) {
      case 'keepLocal':
        message = 'Keeping local version';
        break;
      case 'keepRemote':
        message = 'Keeping remote version';
        break;
      case 'customMerge':
        message = 'Merging versions';
        break;
      default:
        message = 'Unknown choice';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Creates a sample conflict for demonstration
  ConflictInfo _createSampleConflict({
    ConflictSeverity severity = ConflictSeverity.medium,
  }) {
    final now = DateTime.now();
    return ConflictInfo(
      conflictId: 'conflict_${DateTime.now().millisecondsSinceEpoch}',
      entityId: 'entity_${DateTime.now().millisecondsSinceEpoch}',
      entityType: 'travelPlan',
      conflictType: ConflictType.diverged,
      severity: severity,
      localVersion: EntityVersion(
        entityId: 'entity_123',
        entityType: 'travelPlan',
        version: 5,
        lastModified: now.subtract(const Duration(minutes: 30)),
        deviceId: 'device_001',
        dataHash: 'abc123def456',
      ),
      remoteVersion: EntityVersion(
        entityId: 'entity_123',
        entityType: 'travelPlan',
        version: 6,
        lastModified: now.subtract(const Duration(minutes: 15)),
        deviceId: 'device_002',
        dataHash: 'xyz789uvw012',
      ),
      localData: {
        'destination': 'Paris',
        'startDate': '2025-06-15',
        'endDate': '2025-06-22',
        'budget': 5000,
        'notes': 'Summer vacation',
      },
      remoteData: {
        'destination': 'Paris',
        'startDate': '2025-06-15',
        'endDate': '2025-06-25', // Different
        'budget': 6000, // Different
        'notes': 'Summer vacation with extended stay',
      },
      description: 'The travel plan was modified on another device',
      detectedAt: now,
    );
  }
}

/// Example screen showing how to integrate conflict resolution
/// into a real workflow
class ConflictResolutionIntegrationExample extends StatefulWidget {
  const ConflictResolutionIntegrationExample({super.key});

  @override
  State<ConflictResolutionIntegrationExample> createState() =>
      _ConflictResolutionIntegrationExampleState();
}

class _ConflictResolutionIntegrationExampleState
    extends State<ConflictResolutionIntegrationExample> {
  // Simulated state
  List<ConflictInfo> pendingConflicts = [];
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Simulate detecting conflicts on load
    _simulateConflictDetection();
  }

  Future<void> _simulateConflictDetection() async {
    // In a real app, you would get conflicts from your ConflictDetector service
    setState(() {
      pendingConflicts = [
        _createSampleConflict(),
        _createSampleConflict(severity: ConflictSeverity.high),
      ];
    });
  }

  Future<void> _resolveConflict(ConflictInfo conflict) async {
    setState(() {
      isProcessing = true;
    });

    try {
      // Show resolution dialog
      final choice = await ConflictResolutionDialog.show(
        context: context,
        conflict: conflict,
        canMerge: conflict.severity != ConflictSeverity.high,
      );

      if (choice != null) {
        // In a real app, you would use your ConflictResolver service here
        await _applyResolution(conflict, choice);

        // Remove from pending conflicts
        setState(() {
          pendingConflicts.removeWhere((c) => c.conflictId == conflict.conflictId);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Conflict resolved: ${choice.toString()}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  Future<void> _applyResolution(ConflictInfo conflict, choice) async {
    // Simulate async resolution
    await Future.delayed(const Duration(milliseconds: 500));

    // In a real app, you would:
    // 1. Call ConflictResolver.resolveManually()
    // 2. Update local data store
    // 3. Queue sync operation
    // 4. Update UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Status'),
      ),
      body: Column(
        children: [
          // Show banner if there are conflicts
          if (pendingConflicts.isNotEmpty)
            MultipleConflictsBanner(
              conflicts: pendingConflicts,
              onViewAll: () {
                // Navigate to conflict resolution screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: const Text('Resolve Conflicts'),
                      ),
                      body: ConflictListView(
                        conflicts: pendingConflicts,
                        onConflictSelected: _resolveConflict,
                        onAutoResolve: _autoResolveConflicts,
                        canAutoResolve: pendingConflicts.any(
                          (c) => c.canAutoResolve,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

          // Main content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    pendingConflicts.isEmpty
                        ? Icons.check_circle
                        : Icons.sync,
                    size: 64,
                    color: pendingConflicts.isEmpty
                        ? Colors.green
                        : Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    pendingConflicts.isEmpty
                        ? 'All synced'
                        : '${pendingConflicts.length} conflicts pending',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ConflictInfo _createSampleConflict({
    ConflictSeverity severity = ConflictSeverity.medium,
  }) {
    final now = DateTime.now();
    return ConflictInfo(
      conflictId: 'conflict_${DateTime.now().millisecondsSinceEpoch}',
      entityId: 'entity_${DateTime.now().millisecondsSinceEpoch}',
      entityType: 'travelPlan',
      conflictType: ConflictType.diverged,
      severity: severity,
      localVersion: EntityVersion(
        entityId: 'entity_123',
        entityType: 'travelPlan',
        version: 5,
        lastModified: now.subtract(const Duration(minutes: 30)),
        deviceId: 'device_001',
        dataHash: 'abc123def456',
      ),
      remoteVersion: EntityVersion(
        entityId: 'entity_123',
        entityType: 'travelPlan',
        version: 6,
        lastModified: now.subtract(const Duration(minutes: 15)),
        deviceId: 'device_002',
        dataHash: 'xyz789uvw012',
      ),
      localData: {
        'destination': 'Paris',
        'startDate': '2025-06-15',
      },
      remoteData: {
        'destination': 'Paris',
        'startDate': '2025-06-20',
      },
      description: 'The travel plan was modified on another device',
      detectedAt: now,
    );
  }

  Future<void> _autoResolveConflicts() async {
    setState(() {
      isProcessing = true;
    });

    try {
      // In a real app, you would call ConflictResolver.resolveMultipleConflicts()
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Auto-resolved low-severity conflicts'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }
}
