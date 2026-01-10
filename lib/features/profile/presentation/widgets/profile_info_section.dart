import 'package:flutter/material.dart';
import '../../domain/entities/profile.dart';

class ProfileInfoSection extends StatelessWidget {
  final Profile profile;

  const ProfileInfoSection({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          context,
          'Interests',
          profile.interests.isEmpty
              ? [
                  Text(
                    'No interests added yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                ]
              : profile.interests.map((interest) {
                  return Chip(
                    label: Text(interest),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    labelStyle: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  );
                }).toList(),
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          'Preferences',
          profile.preferences.isEmpty
              ? [
                  Text(
                    'No preferences set',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                ]
              : profile.preferences.entries.map((entry) {
                  return ListTile(
                    title: Text(
                      entry.key,
                      style: theme.textTheme.titleSmall,
                    ),
                    subtitle: Text(
                      entry.value.toString(),
                      style: theme.textTheme.bodyMedium,
                    ),
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          'Account Info',
          [
            _buildInfoRow(
              context,
              'Created',
              _formatDate(profile.createdAt),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              'Last Updated',
              _formatDate(profile.updatedAt),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              'Profile ID',
              profile.id,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (children.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: children,
          ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
