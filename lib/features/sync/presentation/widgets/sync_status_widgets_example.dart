import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/sync_status.dart';
import 'sync_status_icon.dart';
import 'sync_status_badge.dart';
import 'sync_progress_indicator.dart';

/// Example demonstrating all sync status indicator widgets
///
/// Run this widget to see visual demonstrations of:
/// - SyncStatusIcon with different states
/// - SyncStatusIndicator (circular dots)
/// - SyncStatusBadge for pending counts
/// - SyncProgressBar with different configurations
/// - SyncCircularProgress
/// - SyncProgressCard
class SyncStatusWidgetsExample extends ConsumerStatefulWidget {
  const SyncStatusWidgetsExample({super.key});

  @override
  ConsumerState<SyncStatusWidgetsExample> createState() =>
      _SyncStatusWidgetsExampleState();
}

class _SyncStatusWidgetsExampleState
    extends ConsumerState<SyncStatusWidgetsExample> {
  SyncStatus _currentStatus = SyncStatus.idle;
  double _progress = 0.0;
  int _pendingCount = 3;
  bool _isIndeterminate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Status Widgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _simulateStatusChange,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Icons Section
          _buildSectionHeader('Status Icons'),
          const SizedBox(height: 8),
          _buildStatusIconsGrid(),
          const SizedBox(height: 24),

          // Status Indicators Section
          _buildSectionHeader('Status Indicators'),
          const SizedBox(height: 8),
          _buildStatusIndicatorsRow(),
          const SizedBox(height: 24),

          // Badge Section
          _buildSectionHeader('Pending Count Badges'),
          const SizedBox(height: 8),
          _buildBadgesSection(),
          const SizedBox(height: 24),

          // Progress Bars Section
          _buildSectionHeader('Progress Bars'),
          const SizedBox(height: 8),
          _buildProgressBarsSection(),
          const SizedBox(height: 24),

          // Circular Progress Section
          _buildSectionHeader('Circular Progress'),
          const SizedBox(height: 8),
          _buildCircularProgressSection(),
          const SizedBox(height: 24),

          // Progress Cards Section
          _buildSectionHeader('Progress Cards'),
          const SizedBox(height: 8),
          _buildProgressCardsSection(),
          const SizedBox(height: 24),

          // Interactive Demo Section
          _buildSectionHeader('Interactive Demo'),
          const SizedBox(height: 8),
          _buildInteractiveDemo(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildStatusIconsGrid() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildIconRow(SyncStatus.idle, 'Idle'),
            const Divider(),
            _buildIconRow(SyncStatus.syncing, 'Syncing'),
            const Divider(),
            _buildIconRow(SyncStatus.success, 'Success'),
            const Divider(),
            _buildIconRow(SyncStatus.failed, 'Failed'),
            const Divider(),
            _buildIconRow(SyncStatus.pending, 'Pending'),
          ],
        ),
      ),
    );
  }

  Widget _buildIconRow(SyncStatus status, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          SyncStatusIcon(status: status, size: 24),
          const SizedBox(width: 16),
          SyncStatusIcon(
            status: status,
            size: 32,
            withBackground: true,
          ),
          const SizedBox(width: 16),
          SyncStatusIcon(status: status, size: 24, showLabel: true),
        ],
      ),
    );
  }

  Widget _buildStatusIndicatorsRow() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildIndicatorColumn(SyncStatus.idle, 'Idle'),
            _buildIndicatorColumn(SyncStatus.syncing, 'Syncing'),
            _buildIndicatorColumn(SyncStatus.success, 'Success'),
            _buildIndicatorColumn(SyncStatus.failed, 'Failed'),
            _buildIndicatorColumn(SyncStatus.pending, 'Pending'),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorColumn(SyncStatus status, String label) {
    return Column(
      children: [
        SyncStatusIndicator(status: status, size: 12),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildBadgesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Badges on Icons:'),
            const SizedBox(height: 16),
            Row(
              children: [
                SyncStatusBadge(
                  count: 1,
                  child: const Icon(Icons.notifications),
                ),
                const SizedBox(width: 24),
                SyncStatusBadge(
                  count: 5,
                  child: const Icon(Icons.notifications),
                ),
                const SizedBox(width: 24),
                SyncStatusBadge(
                  count: 99,
                  child: const Icon(Icons.notifications),
                ),
                const SizedBox(width: 24),
                SyncStatusBadge(
                  count: 150,
                  child: const Icon(Icons.notifications),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Standalone Badges:'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              children: [
                SyncStatusBadge(count: 1),
                SyncStatusBadge(count: 5),
                SyncStatusBadge(count: 10),
                SyncStatusBadge(count: 99),
                SyncStatusBadge(count: 150),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Badge with Indicator:'),
            const SizedBox(height: 16),
            SyncStatusBadgeWithIndicator(count: _pendingCount),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBarsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SyncProgressBar(
              progress: 0.25,
              showPercentage: true,
              label: 'Uploading trips...',
            ),
            const SizedBox(height: 16),
            SyncProgressBar(
              progress: 0.5,
              showPercentage: true,
              label: 'Syncing activities...',
            ),
            const SizedBox(height: 16),
            SyncProgressBar(
              progress: 0.75,
              showPercentage: true,
              label: 'Downloading updates...',
            ),
            const SizedBox(height: 16),
            SyncProgressBar(
              progress: 1.0,
              showPercentage: true,
              label: 'Completed',
            ),
            const SizedBox(height: 16),
            const SyncProgressBar(
              isIndeterminate: true,
              label: 'Connecting...',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularProgressSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                SyncCircularProgress(
                  progress: 0.25,
                  center: const Text('25%'),
                ),
                const SizedBox(height: 8),
                const Text('25%'),
              ],
            ),
            Column(
              children: [
                SyncCircularProgress(
                  progress: 0.5,
                  center: const Text('50%'),
                ),
                const SizedBox(height: 8),
                const Text('50%'),
              ],
            ),
            Column(
              children: [
                SyncCircularProgress(
                  progress: 0.75,
                  center: const Text('75%'),
                ),
                const SizedBox(height: 8),
                const Text('75%'),
              ],
            ),
            Column(
              children: [
                const SyncCircularProgress(
                  isIndeterminate: true,
                ),
                const SizedBox(height: 8),
                const Text('Loading'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCardsSection() {
    return Column(
      children: [
        SyncProgressCard(
          title: 'Syncing Data',
          message: 'Uploading your changes to the server...',
          progress: 0.6,
          processed: 12,
          total: 20,
        ),
        const SizedBox(height: 16),
        SyncProgressCard(
          title: 'Sync Complete',
          message: 'All data synchronized successfully',
          progress: 1.0,
          processed: 20,
          total: 20,
        ),
        const SizedBox(height: 16),
        SyncProgressCard(
          title: 'Sync Failed',
          message: 'Unable to complete synchronization',
          error: 'Network connection lost. Please check your internet connection.',
          processed: 8,
          total: 20,
        ),
        const SizedBox(height: 16),
        const SyncProgressCard(
          title: 'Connecting',
          message: 'Establishing connection to server...',
          isIndeterminate: true,
        ),
      ],
    );
  }

  Widget _buildInteractiveDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Status: ${_currentStatus.displayName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Center(
              child: SyncStatusIcon(
                status: _currentStatus,
                size: 48,
                withBackground: true,
              ),
            ),
            const SizedBox(height: 16),
            if (_currentStatus == SyncStatus.syncing) ...[
              SyncProgressBar(
                progress: _isIndeterminate ? null : _progress,
                isIndeterminate: _isIndeterminate,
                showPercentage: !_isIndeterminate,
              ),
              const SizedBox(height: 8),
            ],
            if (_pendingCount > 0)
              SyncStatusBadgeWithIndicator(count: _pendingCount),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _setStatus(SyncStatus.idle),
                  child: const Text('Idle'),
                ),
                ElevatedButton(
                  onPressed: () => _setStatus(SyncStatus.syncing),
                  child: const Text('Syncing'),
                ),
                ElevatedButton(
                  onPressed: () => _setStatus(SyncStatus.success),
                  child: const Text('Success'),
                ),
                ElevatedButton(
                  onPressed: () => _setStatus(SyncStatus.failed),
                  child: const Text('Failed'),
                ),
                ElevatedButton(
                  onPressed: () => _setStatus(SyncStatus.pending),
                  child: const Text('Pending'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Pending Count:'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _pendingCount > 0
                      ? () => setState(() => _pendingCount--)
                      : null,
                ),
                Text('$_pendingCount'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => _pendingCount++),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setStatus(SyncStatus status) {
    setState(() {
      _currentStatus = status;
      if (status == SyncStatus.syncing) {
        _progress = 0.0;
        _isIndeterminate = false;
        _animateProgress();
      }
    });
  }

  void _animateProgress() {
    if (_currentStatus != SyncStatus.syncing) return;

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() {
        if (_progress < 1.0) {
          _progress += 0.05;
          _animateProgress();
        } else {
          _currentStatus = SyncStatus.success;
        }
      });
    });
  }

  void _simulateStatusChange() {
    final statuses = SyncStatus.values;
    final currentIndex = statuses.indexOf(_currentStatus);
    final nextIndex = (currentIndex + 1) % statuses.length;
    _setStatus(statuses[nextIndex]);
  }
}

/// Simple example widget showing sync status in app bar
class AppBarSyncStatusExample extends StatelessWidget {
  final SyncStatus status;
  final int pendingCount;

  const AppBarSyncStatusExample({
    super.key,
    required this.status,
    this.pendingCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('SoloAdventurer'),
      actions: [
        // Sync status icon
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SyncStatusIcon(
            status: status,
            size: 20,
          ),
        ),
        // Pending badge if needed
        if (pendingCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SyncStatusBadge(
              count: pendingCount,
              child: const Icon(Icons.sync),
            ),
          ),
        // Menu
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
      ],
    );
  }
}
