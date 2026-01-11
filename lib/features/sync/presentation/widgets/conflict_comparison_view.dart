import 'package:flutter/material.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_info.dart';
import 'package:intl/intl.dart';

/// Side-by-side comparison view for conflicted data
///
/// Displays local and remote versions of the conflicted entity
/// with visual highlighting of differences.
class ConflictComparisonView extends StatelessWidget {
  /// The conflict information to display
  final ConflictInfo conflict;

  const ConflictComparisonView({
    super.key,
    required this.conflict,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Version Comparison',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Side-by-side comparison
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 500;

                if (isSmallScreen) {
                  // Vertical layout for small screens
                  return Column(
                    children: [
                      _buildVersionCard(
                        context,
                        title: 'Local Version',
                        version: conflict.localVersion,
                        data: conflict.localData,
                        icon: Icons.smartphone,
                        color: theme.colorScheme.primary,
                        isLocal: true,
                      ),
                      const SizedBox(height: 12),
                      _buildVersionCard(
                        context,
                        title: 'Remote Version',
                        version: conflict.remoteVersion,
                        data: conflict.remoteData,
                        icon: Icons.cloud,
                        color: theme.colorScheme.secondary,
                        isLocal: false,
                      ),
                    ],
                  );
                } else {
                  // Side-by-side layout for larger screens
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildVersionCard(
                          context,
                          title: 'Local Version',
                          version: conflict.localVersion,
                          data: conflict.localData,
                          icon: Icons.smartphone,
                          color: theme.colorScheme.primary,
                          isLocal: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildVersionCard(
                          context,
                          title: 'Remote Version',
                          version: conflict.remoteVersion,
                          data: conflict.remoteData,
                          icon: Icons.cloud,
                          color: theme.colorScheme.secondary,
                          isLocal: false,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a version card
  Widget _buildVersionCard(
    BuildContext context, {
    required String title,
    required dynamic version,
    required Map<String, dynamic>? data,
    required IconData icon,
    required Color color,
    required bool isLocal,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Version metadata
                _buildMetadataSection(context, version, color),
                const SizedBox(height: 12),

                // Data fields
                if (data != null && data.isNotEmpty) ...[
                  Divider(
                    color: color.withValues(alpha: 0.2),
                    height: 1,
                  ),
                  const SizedBox(height: 12),
                  _buildDataFields(context, data, color),
                ] else
                  Text(
                    'No data available',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds version metadata section
  Widget _buildMetadataSection(
    BuildContext context,
    dynamic version,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetadataRow(
          context,
          label: 'Version',
          value: version.version.toString(),
          icon: Icons.numbers,
          color: color,
        ),
        const SizedBox(height: 6),
        _buildMetadataRow(
          context,
          label: 'Modified',
          value: _formatDateTime(version.lastModified),
          icon: Icons.access_time,
          color: color,
        ),
        const SizedBox(height: 6),
        _buildMetadataRow(
          context,
          label: 'Device',
          value: version.deviceId,
          icon: Icons.devices,
          color: color,
        ),
        if (version.dataHash != null) ...[
          const SizedBox(height: 6),
          _buildMetadataRow(
            context,
            label: 'Hash',
            value: _truncateHash(version.dataHash!),
            icon: Icons.fingerprint,
            color: color,
          ),
        ],
      ],
    );
  }

  /// Builds a metadata row
  Widget _buildMetadataRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: color.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Text(
          '$label:',
          style: theme.textTheme.bodySmall?.copyWith(
            color: color.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontFamily: 'monospace',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Builds data fields section
  Widget _buildDataFields(
    BuildContext context,
    Map<String, dynamic> data,
    Color color,
  ) {
    final theme = Theme.of(context);

    // Show up to 10 fields to prevent overflow
    final fields = data.entries.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Fields',
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...fields.map((entry) => _buildDataField(
              context,
              key: entry.key,
              value: entry.value,
              color: color,
            )),
        if (data.length > 10) ...[
          const SizedBox(height: 4),
          Text(
            '... and ${data.length - 10} more fields',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  /// Builds a single data field
  Widget _buildDataField(
    BuildContext context, {
    required String key,
    required dynamic value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final displayValue = _formatValue(value);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  key,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayValue,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Formats a date time for display
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(dateTime);
    }
  }

  /// Truncates a hash for display
  String _truncateHash(String hash) {
    if (hash.length <= 12) return hash;
    return '${hash.substring(0, 6)}...${hash.substring(hash.length - 6)}';
  }

  /// Formats a value for display
  String _formatValue(dynamic value) {
    if (value == null) {
      return 'null';
    } else if (value is String) {
      return value.length > 50 ? '${value.substring(0, 47)}...' : value;
    } else if (value is DateTime) {
      return _formatDateTime(value);
    } else if (value is Map || value is List) {
      return value.toString().length > 50
          ? '${value.toString().substring(0, 47)}...'
          : value.toString();
    } else {
      return value.toString();
    }
  }
}
