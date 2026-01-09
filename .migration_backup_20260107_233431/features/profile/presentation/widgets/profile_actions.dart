import 'package:flutter/material.dart';

class ProfileActions extends StatelessWidget {
  final bool isPublic;
  final void Function(bool) onToggleVisibility;
  final VoidCallback onDeleteProfile;

  const ProfileActions({
    super.key,
    required this.isPublic,
    required this.onToggleVisibility,
    required this.onDeleteProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Settings',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Public Profile'),
                subtitle: Text(
                  isPublic
                      ? 'Your profile is visible to everyone'
                      : 'Your profile is private',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                value: isPublic,
                onChanged: onToggleVisibility,
              ),
              const Divider(height: 1),
              ListTile(
                title: Text(
                  'Delete Profile',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                  ),
                ),
                subtitle: Text(
                  'This action cannot be undone',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                leading: Icon(
                  Icons.delete_forever,
                  color: theme.colorScheme.error,
                ),
                onTap: onDeleteProfile,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
