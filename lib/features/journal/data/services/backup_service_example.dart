import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/backup_service.dart';
import '../../presentation/providers/backup_providers.dart';
import '../../presentation/widgets/backup_restore_widget.dart';

/// Example 1: Basic backup creation with default settings
class Example1_BasicBackup extends ConsumerWidget {
  const Example1_BasicBackup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(backupNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Basic Backup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (backupState.isBackingUp) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Progress: ${(backupState.progress * 100).toStringAsFixed(1)}%'),
              if (backupState.stage != null)
                Text('Stage: ${backupState.stage}'),
            ] else if (backupState.isSuccess) ...[
              const Icon(Icons.check_circle, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              Text('Backup created: ${backupState.result!.backupPath}'),
              Text('Size: ${backupState.result!.fileSizeReadable}'),
              ElevatedButton(
                onPressed: () {
                  ref.read(backupNotifierProvider.notifier).reset();
                },
                child: const Text('Done'),
              ),
            ] else if (backupState.isFailed) ...[
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${backupState.error}'),
              ElevatedButton(
                onPressed: () {
                  ref.read(backupNotifierProvider.notifier).reset();
                },
                child: const Text('Reset'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () async {
                  await ref.read(backupNotifierProvider.notifier).createBackup();
                },
                child: const Text('Create Backup'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Example 2: Encrypted backup with custom settings
class Example2_EncryptedBackup extends ConsumerStatefulWidget {
  const Example2_EncryptedBackup({super.key});

  @override
  ConsumerState<Example2_EncryptedBackup> createState() =>
      _Example2_EncryptedBackupState();
}

class _Example2_EncryptedBackupState
    extends ConsumerState<Example2_EncryptedBackup> {
  final _passwordController = TextEditingController();
  bool _includeMedia = true;
  int _compressionLevel = 9;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encrypted Backup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Encryption Password',
                hintText: 'Enter at least 8 characters',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Include Media'),
              value: _includeMedia,
              onChanged: (value) => setState(() => _includeMedia = value),
            ),
            const SizedBox(height: 16),
            Text('Compression: $_compressionLevel'),
            Slider(
              value: _compressionLevel.toDouble(),
              min: 0,
              max: 9,
              divisions: 9,
              onChanged: (value) {
                setState(() => _compressionLevel = value.toInt());
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _passwordController.text.length >= 8
                  ? () async {
                      await ref.read(backupNotifierProvider.notifier).createBackup(
                            config: BackupConfig(
                              includeMedia: _includeMedia,
                              encrypt: true,
                              encryptionPassword: _passwordController.text,
                              compressionLevel: _compressionLevel,
                              verifyIntegrity: true,
                            ),
                          );
                    }
                  : null,
              child: const Text('Create Encrypted Backup'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 3: Restore from backup
class Example3_RestoreBackup extends ConsumerWidget {
  const Example3_RestoreBackup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restoreState = ref.watch(restoreNotifierProvider);
    final backupsAsync = ref.watch(availableBackupsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Restore Backup')),
      body: backupsAsync.when(
        data: (backups) {
          if (backups.isEmpty) {
            return const Center(child: Text('No backups available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: backups.length,
            itemBuilder: (context, index) {
              final backup = backups[index];

              return Card(
                child: ListTile(
                  title: Text(
                    backup.createdAt.toString().split('.')[0],
                  ),
                  subtitle: Text(
                    '${backup.entryCount} entries, '
                    '${backup.fileSizeReadable}'
                    '${backup.isEncrypted ? ' • 🔒' : ''}',
                  ),
                  trailing: restoreState.isRestoring
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : const Icon(Icons.restore),
                  onTap: restoreState.isRestoring
                      ? null
                      : () async {
                          // Show restore options
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Restore Backup?'),
                              content: Text(
                                'Restore ${backup.entryCount} entries from '
                                '${DateFormat('MMM dd, yyyy').format(backup.createdAt)}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Restore'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            await ref
                                .read(restoreNotifierProvider.notifier)
                                .restoreBackup(
                                  backupPath: backup.path,
                                  config: RestoreConfig.safeRestoreConfig,
                                );
                          }
                        },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

/// Example 4: Full backup/restore UI widget
class Example4_FullUI extends StatelessWidget {
  const Example4_FullUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: const BackupRestoreWidget(
        showBackup: true,
        showRestore: true,
      ),
    );
  }
}

/// Example 5: State monitoring with detailed progress
class Example5_StateMonitoring extends ConsumerWidget {
  const Example5_StateMonitoring({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(backupNotifierProvider);
    final restoreState = ref.watch(restoreNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('State Monitoring')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup State',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Status: ${backupState.status}'),
            Text('Progress: ${(backupState.progress * 100).toStringAsFixed(1)}%'),
            if (backupState.stage != null) Text('Stage: ${backupState.stage}'),
            if (backupState.currentItem != null)
              Text('Item: ${backupState.currentItem}'),
            Text('Processed: ${backupState.processedItems}/${backupState.totalItems}'),
            if (backupState.result != null) ...[
              Text('Path: ${backupState.result!.backupPath}'),
              Text('Size: ${backupState.result!.fileSizeReadable}'),
              Text('Duration: ${backupState.backupDuration}'),
            ],
            if (backupState.error != null) Text('Error: ${backupState.error}'),
            const Divider(height: 32),
            Text(
              'Restore State',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Status: ${restoreState.status}'),
            Text('Progress: ${(restoreState.progress * 100).toStringAsFixed(1)}%'),
            if (restoreState.stage != null) Text('Stage: ${restoreState.stage}'),
            if (restoreState.result != null) ...[
              Text('Restored: ${restoreState.result!.totalItemsRestored} items'),
              Text('Conflicts: ${restoreState.result!.conflictCount}'),
              Text('Skipped: ${restoreState.result!.skippedCount}'),
            ],
            if (restoreState.error != null) Text('Error: ${restoreState.error}'),
          ],
        ),
      ),
    );
  }
}

/// Example 6: Backup size estimation
class Example6_BackupEstimation extends ConsumerWidget {
  const Example6_BackupEstimation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizeWithMedia = ref.watch(estimatedBackupSizeProvider(includeMedia: true));
    final sizeWithoutMedia = ref.watch(estimatedBackupSizeProvider(includeMedia: false));

    return Scaffold(
      appBar: AppBar(title: const Text('Backup Size Estimation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estimated Backup Size',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            sizeWithMedia.when(
              data: (size) => _SizeCard(
                label: 'With Media',
                sizeInBytes: size,
                icon: Icons.photo_library,
              ),
              loading: () => const Card(
                child: ListTile(
                  leading: CircularProgressIndicator(strokeWidth: 2),
                  title: Text('Calculating with media...'),
                ),
              ),
              error: (error, _) => Text('Error: $error'),
            ),
            const SizedBox(height: 16),
            sizeWithoutMedia.when(
              data: (size) => _SizeCard(
                label: 'Without Media',
                sizeInBytes: size,
                icon: Icons.text_snippet,
              ),
              loading: () => const Card(
                child: ListTile(
                  leading: CircularProgressIndicator(strokeWidth: 2),
                  title: Text('Calculating without media...'),
                ),
              ),
              error: (error, _) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeCard extends StatelessWidget {
  final String label;
  final int sizeInBytes;
  final IconData icon;

  const _SizeCard({
    required this.label,
    required this.sizeInBytes,
    required this.icon,
  });

  String get readableSize {
    if (sizeInBytes < 1024) return '$sizeInBytes B';
    if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    }
    if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text('$sizeInBytes bytes'),
        trailing: Text(
          readableSize,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

/// Example 7: Conflict resolution strategies
class Example7_ConflictResolution extends ConsumerStatefulWidget {
  const Example7_ConflictResolution({super.key});

  @override
  ConsumerState<Example7_ConflictResolution> createState() =>
      _Example7_ConflictResolutionState();
}

class _Example7_ConflictResolutionState
    extends ConsumerState<Example7_ConflictResolution> {
  ConflictResolution _selectedStrategy = ConflictResolution.keepNewest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conflict Resolution')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Conflict Resolution Strategy',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Keep Newest'),
              subtitle: const Text('Keep the version with the most recent update'),
              leading: Radio<ConflictResolution>(
                value: ConflictResolution.keepNewest,
                groupValue: _selectedStrategy,
                onChanged: (value) => setState(() => _selectedStrategy = value!),
              ),
            ),
            ListTile(
              title: const Text('Keep Existing'),
              subtitle: const Text('Keep the current data in the app'),
              leading: Radio<ConflictResolution>(
                value: ConflictResolution.keepExisting,
                groupValue: _selectedStrategy,
                onChanged: (value) => setState(() => _selectedStrategy = value!),
              ),
            ),
            ListTile(
              title: const Text('Keep Backup'),
              subtitle: const Text('Use the version from the backup file'),
              leading: Radio<ConflictResolution>(
                value: ConflictResolution.keepBackup,
                groupValue: _selectedStrategy,
                onChanged: (value) => setState(() => _selectedStrategy = value!),
              ),
            ),
            ListTile(
              title: const Text('Keep Both'),
              subtitle: const Text('Create duplicates for conflicting items'),
              leading: Radio<ConflictResolution>(
                value: ConflictResolution.keepBoth,
                groupValue: _selectedStrategy,
                onChanged: (value) => setState(() => _selectedStrategy = value!),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Selected: ${_selectedStrategy.toString().split('.').last}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 8: Pre-restore backup creation
class Example8_PreRestoreBackup extends ConsumerWidget {
  const Example8_PreRestoreBackup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restoreState = ref.watch(restoreNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pre-Restore Backup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'This example demonstrates creating a backup before restore. '
                  'If the restore fails or has issues, you can restore from '
                  'the pre-restore backup.',
                ),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Create Pre-Restore Backup'),
              subtitle: const Text('Recommended for safety'),
              value: true,
              onChanged: null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await ref.read(restoreNotifierProvider.notifier).restoreBackup(
                      backupPath: '/path/to/backup.zip',
                      config: RestoreConfig(
                        backupBeforeRestore: true,
                        mode: RestoreMode.merge,
                        conflictResolution: ConflictResolution.keepNewest,
                      ),
                    );
              },
              child: const Text('Restore with Pre-Backup'),
            ),
            if (restoreState.isSuccess &&
                restoreState.result?.preRestoreBackupPath != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.green.shade50,
                child: ListTile(
                  leading: const Icon(Icons.backup, color: Colors.green),
                  title: const Text('Pre-Restore Backup Created'),
                  subtitle: Text(restoreState.result!.preRestoreBackupPath!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Main menu for backup/restore examples
class BackupRestoreExamplesMenu extends StatelessWidget {
  const BackupRestoreExamplesMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _ExampleCard(
            title: 'Example 1: Basic Backup',
            description: 'Create a simple backup with default settings',
            icon: Icons.backup,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Example1_BasicBackup(),
                ),
              );
            },
          ),
          _ExampleCard(
            title: 'Example 2: Encrypted Backup',
            description: 'Create a password-protected backup',
            icon: Icons.lock,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Example2_EncryptedBackup(),
                ),
              );
            },
          ),
          _ExampleCard(
            title: 'Example 3: Restore Backup',
            description: 'Restore from available backups',
            icon: Icons.restore,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Example3_RestoreBackup(),
                ),
              );
            },
          ),
          _ExampleCard(
            title: 'Example 4: Full UI',
            description: 'Complete backup and restore widget',
            icon: Icons.widgets,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Example4_FullUI(),
                ),
              );
            },
          ),
          _ExampleCard(
            title: 'Example 5: State Monitoring',
            description: 'Monitor backup and restore states',
            icon: Icons.monitor_heart,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Example5_StateMonitoring(),
                ),
              );
            },
          ),
          _ExampleCard(
            title: 'Example 6: Backup Estimation',
            description: 'Estimate backup size before creating',
            icon: Icons.calculate,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Example6_BackupEstimation(),
                ),
              );
            },
          ),
          _ExampleCard(
            title: 'Example 7: Conflict Resolution',
            description: 'Choose conflict resolution strategy',
            icon: Icons.merge_type,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Example7_ConflictResolution(),
                ),
              );
            },
          ),
          _ExampleCard(
            title: 'Example 8: Pre-Restore Backup',
            description: 'Create backup before restoring',
            icon: Icons.history,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Example8_PreRestoreBackup(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ExampleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
