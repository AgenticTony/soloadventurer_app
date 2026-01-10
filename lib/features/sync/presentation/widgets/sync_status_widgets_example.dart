import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_status.dart';
import 'sync_status_icon.dart';
import 'sync_status_badge.dart';
import 'sync_progress_indicator.dart';

/// Example demonstrating all sync status indicator widgets
///
/// Run this widget to see visual demonstrations of:
/// - SyncOperationStatusIcon with different states
/// - SyncOperationStatusIndicator (circular dots)
/// - SyncOperationStatusBadge for pending counts
/// - SyncProgressBar with different configurations
/// - SyncCircularProgress
/// - SyncProgressCard
class SyncOperationStatusWidgetsExample extends ConsumerStatefulWidget {
  const SyncOperationStatusWidgetsExample({super.key});

  @override
  ConsumerState<SyncOperationStatusWidgetsExample> createState() =>
      _SyncOperationStatusWidgetsExampleState();
}

class _SyncOperationStatusWidgetsExampleState
    extends ConsumerState<SyncOperationStatusWidgetsExample> {
  SyncOperationStatus _currentStatus = SyncOperationStatus.idle;
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
            _buildIconRow(SyncOperationStatus.idle, 'Idle'),
            const Divider(),
            _buildIconRow(SyncOperationStatus.syncing, 'Syncing'),
            const Divider(),
            _buildIconRow(SyncOperationStatus.success, 'Success'),
            const Divider(),
            _buildIconRow(SyncOperationStatus.failed, 'Failed'),
            const Divider(),
            _buildIconRow(SyncOperationStatus.pending, 'Pending'),
          ],
        ),
      ),
    );
  }

  Widget _buildIconRow(SyncOperationStatus status, String label) {
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
          SyncOperationStatusIcon(status: status, size: 24),
          const SizedBox(width: 16),
          SyncOperationStatusIcon(
            status: status,
            size: 32,
            withBackground: true,
          ),
          const SizedBox(width: 16),
          SyncOperationStatusIcon(status: status, size: 24, showLabel: true),
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
            _buildIndicatorColumn(SyncOperationStatus.idle, 'Idle'),
            _buildIndicatorColumn(SyncOperationStatus.syncing, 'Syncing'),
            _buildIndicatorColumn(SyncOperationStatus.success, 'Success'),
            _buildIndicatorColumn(SyncOperationStatus.failed, 'Failed'),
            _buildIndicatorColumn(SyncOperationStatus.pending, 'Pending'),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorColumn(SyncOperationStatus status, String label) {
    return Column(
      children: [
        SyncOperationStatusIndicator(status: status, size: 12),
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
            const Row(
              children: [
                SyncOperationStatusBadge(
                  count: 1,
                  child: Icon(Icons.notifications),
                ),
                SizedBox(width: 24),
                SyncOperationStatusBadge(
                  count: 5,
                  child: Icon(Icons.notifications),
                ),
                SizedBox(width: 24),
                SyncOperationStatusBadge(
                  count: 99,
                  child: Icon(Icons.notifications),
                ),
                SizedBox(width: 24),
                SyncOperationStatusBadge(
                  count: 150,
                  child: Icon(Icons.notifications),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Standalone Badges:'),
            const SizedBox(height: 16),
            const Wrap(
              spacing: 16,
              children: [
                SyncOperationStatusBadge(count: 1),
                SyncOperationStatusBadge(count: 5),
                SyncOperationStatusBadge(count: 10),
                SyncOperationStatusBadge(count: 99),
                SyncOperationStatusBadge(count: 150),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Badge with Indicator:'),
            const SizedBox(height: 16),
            SyncOperationStatusBadgeWithIndicator(count: _pendingCount),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBarsSection() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SyncProgressBar(
              progress: 0.25,
              showPercentage: true,
              label: 'Uploading trips...',
            ),
            SizedBox(height: 16),
            SyncProgressBar(
              progress: 0.5,
              showPercentage: true,
              label: 'Syncing activities...',
            ),
            SizedBox(height: 16),
            SyncProgressBar(
              progress: 0.75,
              showPercentage: true,
              label: 'Downloading updates...',
            ),
            SizedBox(height: 16),
            SyncProgressBar(
              progress: 1.0,
              showPercentage: true,
              label: 'Completed',
            ),
            SizedBox(height: 16),
            SyncProgressBar(
              isIndeterminate: true,
              label: 'Connecting...',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularProgressSection() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                SyncCircularProgress(
                  progress: 0.25,
                  center: Text('25%'),
                ),
                SizedBox(height: 8),
                Text('25%'),
              ],
            ),
            Column(
              children: [
                SyncCircularProgress(
                  progress: 0.5,
                  center: Text('50%'),
                ),
                SizedBox(height: 8),
                Text('50%'),
              ],
            ),
            Column(
              children: [
                SyncCircularProgress(
                  progress: 0.75,
                  center: Text('75%'),
                ),
                SizedBox(height: 8),
                Text('75%'),
              ],
            ),
            Column(
              children: [
                SyncCircularProgress(
                  isIndeterminate: true,
                ),
                SizedBox(height: 8),
                Text('Loading'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCardsSection() {
    return const Column(
      children: [
        SyncProgressCard(
          title: 'Syncing Data',
          message: 'Uploading your changes to the server...',
          progress: 0.6,
          processed: 12,
          total: 20,
        ),
        SizedBox(height: 16),
        SyncProgressCard(
          title: 'Sync Complete',
          message: 'All data synchronized successfully',
          progress: 1.0,
          processed: 20,
          total: 20,
        ),
        SizedBox(height: 16),
        SyncProgressCard(
          title: 'Sync Failed',
          message: 'Unable to complete synchronization',
          error:
              'Network connection lost. Please check your internet connection.',
          processed: 8,
          total: 20,
        ),
        SizedBox(height: 16),
        SyncProgressCard(
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
              child: SyncOperationStatusIcon(
                status: _currentStatus,
                size: 48,
                withBackground: true,
              ),
            ),
            const SizedBox(height: 16),
            if (_currentStatus == SyncOperationStatus.syncing) ...[
              SyncProgressBar(
                progress: _isIndeterminate ? null : _progress,
                isIndeterminate: _isIndeterminate,
                showPercentage: !_isIndeterminate,
              ),
              const SizedBox(height: 8),
            ],
            if (_pendingCount > 0)
              SyncOperationStatusBadgeWithIndicator(count: _pendingCount),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _setStatus(SyncOperationStatus.idle),
                  child: const Text('Idle'),
                ),
                ElevatedButton(
                  onPressed: () => _setStatus(SyncOperationStatus.syncing),
                  child: const Text('Syncing'),
                ),
                ElevatedButton(
                  onPressed: () => _setStatus(SyncOperationStatus.success),
                  child: const Text('Success'),
                ),
                ElevatedButton(
                  onPressed: () => _setStatus(SyncOperationStatus.failed),
                  child: const Text('Failed'),
                ),
                ElevatedButton(
                  onPressed: () => _setStatus(SyncOperationStatus.pending),
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

  void _setStatus(SyncOperationStatus status) {
    setState(() {
      _currentStatus = status;
      if (status == SyncOperationStatus.syncing) {
        _progress = 0.0;
        _isIndeterminate = false;
        _animateProgress();
      }
    });
  }

  void _animateProgress() {
    if (_currentStatus != SyncOperationStatus.syncing) return;

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() {
        if (_progress < 1.0) {
          _progress += 0.05;
          _animateProgress();
        } else {
          _currentStatus = SyncOperationStatus.success;
        }
      });
    });
  }

  void _simulateStatusChange() {
    const statuses = SyncOperationStatus.values;
    final currentIndex = statuses.indexOf(_currentStatus);
    final nextIndex = (currentIndex + 1) % statuses.length;
    _setStatus(statuses[nextIndex]);
  }
}

/// Simple example widget showing sync status in app bar
class AppBarSyncOperationStatusExample extends StatelessWidget {
  final SyncOperationStatus status;
  final int pendingCount;

  const AppBarSyncOperationStatusExample({
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
          child: SyncOperationStatusIcon(
            status: status,
            size: 20,
          ),
        ),
        // Pending badge if needed
        if (pendingCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SyncOperationStatusBadge(
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
