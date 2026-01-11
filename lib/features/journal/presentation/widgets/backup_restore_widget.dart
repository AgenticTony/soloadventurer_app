import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/services/backup_service.dart';
import '../providers/backup_providers.dart';

/// Widget for backup and restore functionality
class BackupRestoreWidget extends ConsumerStatefulWidget {
  /// Whether to show backup section
  final bool showBackup;

  /// Whether to show restore section
  final bool showRestore;

  /// Callback when backup completes successfully
  final VoidCallback? onBackupComplete;

  /// Callback when restore completes successfully
  final VoidCallback? onRestoreComplete;

  const BackupRestoreWidget({
    super.key,
    this.showBackup = true,
    this.showRestore = true,
    this.onBackupComplete,
    this.onRestoreComplete,
  });

  @override
  ConsumerState<BackupRestoreWidget> createState() =>
      _BackupRestoreWidgetState();
}

class _BackupRestoreWidgetState extends ConsumerState<BackupRestoreWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        if (widget.showBackup && widget.showRestore) ...[
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Backup', icon: Icon(Icons.backup)),
              Tab(text: 'Restore', icon: Icon(Icons.restore)),
            ],
          ),
        ],
        Expanded(
          child: IndexedStack(
            index: widget.showBackup && widget.showRestore
                ? (_tabController.index == 0 ? 0 : 1)
                : 0,
            children: [
              if (widget.showBackup) const _BackupSection(),
              if (widget.showRestore) const _RestoreSection(),
            ],
          ),
        ),
      ],
    );
  }
}

/// Backup section widget
class _BackupSection extends ConsumerStatefulWidget {
  const _BackupSection();

  @override
  ConsumerState<_BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends ConsumerState<_BackupSection> {
  bool _includeMedia = true;
  bool _encrypt = false;
  String? _encryptionPassword;
  bool _showPassword = false;
  int _compressionLevel = 6;
  bool _verifyIntegrity = true;
  bool _includeDeleted = false;

  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backupState = ref.watch(backupNotifierProvider);
    final estimatedSize =
        ref.watch(estimatedBackupSizeProvider(includeMedia: _includeMedia));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Create Backup',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          // Estimated size
          estimatedSize.when(
            data: (size) => Card(
              child: ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('Estimated Backup Size'),
                subtitle: Text(
                  'Approximately ${_formatBytes(size)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            loading: () => const Card(
              child: ListTile(
                leading: CircularProgressIndicator(strokeWidth: 2),
                title: Text('Calculating backup size...'),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),

          // Options
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Include Media Files'),
                  subtitle: const Text('Include photos and videos in backup'),
                  value: _includeMedia,
                  onChanged: (value) {
                    setState(() {
                      _includeMedia = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Encrypt Backup'),
                  subtitle: const Text('Password-protect your backup'),
                  value: _encrypt,
                  onChanged: (value) {
                    setState(() {
                      _encrypt = value;
                    });
                  },
                ),
                if (_encrypt)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        labelText: 'Encryption Password',
                        hintText: 'Enter at least 8 characters',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_showPassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _encryptionPassword = value;
                        });
                      },
                    ),
                  ),
                SwitchListTile(
                  title: const Text('Verify Integrity'),
                  subtitle: const Text('Verify backup after creation'),
                  value: _verifyIntegrity,
                  onChanged: (value) {
                    setState(() {
                      _verifyIntegrity = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Include Deleted Items'),
                  subtitle: const Text('Include soft-deleted items in backup'),
                  value: _includeDeleted,
                  onChanged: (value) {
                    setState(() {
                      _includeDeleted = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Compression level slider
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Compression Level: $_compressionLevel',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Higher = smaller file but slower',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Slider(
                    value: _compressionLevel.toDouble(),
                    min: 0,
                    max: 9,
                    divisions: 9,
                    label: '$_compressionLevel',
                    onChanged: (value) {
                      setState(() {
                        _compressionLevel = value.toInt();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Progress or action button
          if (backupState.isBackingUp)
            _BackupProgressCard(state: backupState)
          else if (backupState.isSuccess)
            _BackupSuccessCard(
              result: backupState.result!,
              onReset: () {
                ref.read(backupNotifierProvider.notifier).reset();
              },
            )
          else if (backupState.isFailed)
            _BackupErrorCard(
              error: backupState.error ?? 'Unknown error',
              onRetry: () {
                ref.read(backupNotifierProvider.notifier).reset();
                _createBackup();
              },
              onReset: () {
                ref.read(backupNotifierProvider.notifier).reset();
              },
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _canCreateBackup() ? _createBackup : null,
                icon: const Icon(Icons.backup),
                label: const Text('Create Backup'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _canCreateBackup() {
    if (_encrypt &&
        (_encryptionPassword == null || _encryptionPassword!.length < 8)) {
      return false;
    }
    return true;
  }

  Future<void> _createBackup() async {
    final config = BackupConfig(
      includeMedia: _includeMedia,
      encrypt: _encrypt,
      encryptionPassword: _encryptionPassword,
      compressionLevel: _compressionLevel,
      verifyIntegrity: _verifyIntegrity,
      includeDeleted: _includeDeleted,
    );

    try {
      await ref
          .read(backupNotifierProvider.notifier)
          .createBackup(config: config);
    } catch (e) {
      // Error is handled in state
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

/// Restore section widget
class _RestoreSection extends ConsumerStatefulWidget {
  const _RestoreSection();

  @override
  ConsumerState<_RestoreSection> createState() => _RestoreSectionState();
}

class _RestoreSectionState extends ConsumerState<_RestoreSection> {
  String? _encryptionPassword;
  bool _showPassword = false;
  RestoreMode _restoreMode = RestoreMode.merge;
  ConflictResolution _conflictResolution = ConflictResolution.keepNewest;
  bool _restoreMedia = true;
  bool _verifyBeforeRestore = true;
  bool _backupBeforeRestore = true;

  final _passwordController = TextEditingController();
  BackupInfo? _selectedBackup;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restoreState = ref.watch(restoreNotifierProvider);
    final backupsAsync = ref.watch(availableBackupsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Restore from Backup',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          // Available backups list
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Available Backups',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                backupsAsync.when(
                  data: (backups) {
                    if (backups.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No backups available'),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: backups.length,
                      itemBuilder: (context, index) {
                        final backup = backups[index];
                        final isSelected = _selectedBackup?.path == backup.path;
                        return _BackupListTile(
                          backup: backup,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedBackup = backup;
                            });
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error loading backups: $error',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Options
          if (_selectedBackup != null) ...[
            // Encrypted backup password input
            if (_selectedBackup!.isEncrypted)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      labelText: 'Backup Password',
                      hintText: 'Enter backup password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_showPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _encryptionPassword = value;
                      });
                    },
                  ),
                ),
              ),

            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Restore Mode'),
                    subtitle: Text(_getRestoreModeLabel(_restoreMode)),
                    trailing: DropdownButton<RestoreMode>(
                      value: _restoreMode,
                      items: const [
                        DropdownMenuItem(
                          value: RestoreMode.merge,
                          child: Text('Merge'),
                        ),
                        DropdownMenuItem(
                          value: RestoreMode.replace,
                          child: Text('Replace All'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _restoreMode = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Conflict Resolution'),
                    subtitle:
                        Text(_getConflictResolutionLabel(_conflictResolution)),
                    trailing: DropdownButton<ConflictResolution>(
                      value: _conflictResolution,
                      items: const [
                        DropdownMenuItem(
                          value: ConflictResolution.keepNewest,
                          child: Text('Keep Newest'),
                        ),
                        DropdownMenuItem(
                          value: ConflictResolution.keepExisting,
                          child: Text('Keep Existing'),
                        ),
                        DropdownMenuItem(
                          value: ConflictResolution.keepBackup,
                          child: Text('Keep Backup'),
                        ),
                        DropdownMenuItem(
                          value: ConflictResolution.keepBoth,
                          child: Text('Keep Both'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _conflictResolution = value!;
                        });
                      },
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Restore Media Files'),
                    subtitle: const Text('Restore photos and videos'),
                    value: _restoreMedia,
                    onChanged: (value) {
                      setState(() {
                        _restoreMedia = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Verify Before Restore'),
                    subtitle: const Text('Check backup integrity'),
                    value: _verifyBeforeRestore,
                    onChanged: (value) {
                      setState(() {
                        _verifyBeforeRestore = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Backup Before Restore'),
                    subtitle: const Text('Create backup of current data'),
                    value: _backupBeforeRestore,
                    onChanged: (value) {
                      setState(() {
                        _backupBeforeRestore = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Progress or action button
            if (restoreState.isRestoring)
              _RestoreProgressCard(state: restoreState)
            else if (restoreState.isSuccess)
              _RestoreSuccessCard(
                result: restoreState.result!,
                onReset: () {
                  ref.read(restoreNotifierProvider.notifier).reset();
                },
              )
            else if (restoreState.isFailed)
              _RestoreErrorCard(
                error: restoreState.error ?? 'Unknown error',
                onRetry: () {
                  ref.read(restoreNotifierProvider.notifier).reset();
                  _restoreBackup();
                },
                onReset: () {
                  ref.read(restoreNotifierProvider.notifier).reset();
                },
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _canRestore() ? _restoreBackup : null,
                  icon: const Icon(Icons.restore),
                  label: const Text('Restore Backup'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  bool _canRestore() {
    if (_selectedBackup == null) return false;
    if (_selectedBackup!.isEncrypted &&
        (_encryptionPassword == null || _encryptionPassword!.isEmpty)) {
      return false;
    }
    return true;
  }

  Future<void> _restoreBackup() async {
    if (_selectedBackup == null) return;

    final config = RestoreConfig(
      mode: _restoreMode,
      conflictResolution: _conflictResolution,
      restoreMedia: _restoreMedia,
      verifyBeforeRestore: _verifyBeforeRestore,
      backupBeforeRestore: _backupBeforeRestore,
      encryptionPassword: _encryptionPassword,
    );

    try {
      await ref.read(restoreNotifierProvider.notifier).restoreBackup(
            backupPath: _selectedBackup!.path,
            config: config,
          );
    } catch (e) {
      // Error is handled in state
    }
  }

  String _getRestoreModeLabel(RestoreMode mode) {
    switch (mode) {
      case RestoreMode.merge:
        return 'Merge with existing data';
      case RestoreMode.replace:
        return 'Replace all existing data';
      case RestoreMode.preview:
        return 'Preview only (no changes)';
    }
  }

  String _getConflictResolutionLabel(ConflictResolution resolution) {
    switch (resolution) {
      case ConflictResolution.keepNewest:
        return 'Keep the newest version';
      case ConflictResolution.keepExisting:
        return 'Keep existing data';
      case ConflictResolution.keepBackup:
        return 'Keep backup version';
      case ConflictResolution.keepBoth:
        return 'Keep both versions';
      case ConflictResolution.manual:
        return 'Manual resolution';
    }
  }
}

/// Backup list tile widget
class _BackupListTile extends StatelessWidget {
  final BackupInfo backup;
  final bool isSelected;
  final VoidCallback onTap;

  const _BackupListTile({
    required this.backup,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      title: Text(
        DateFormat('MMM dd, yyyy HH:mm').format(backup.createdAt),
        style: theme.textTheme.bodyLarge,
      ),
      subtitle: Text(
        '${backup.entryCount} entries, ${backup.tripCount} trips, '
        '${backup.mediaCount} media • ${backup.fileSizeReadable}'
        '${backup.isEncrypted ? ' • 🔒 Encrypted' : ''}',
      ),
      onTap: onTap,
      selected: isSelected,
    );
  }
}

/// Backup progress card
class _BackupProgressCard extends StatelessWidget {
  final BackupState state;

  const _BackupProgressCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircularProgressIndicator(strokeWidth: 2),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Creating Backup...',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (state.stage != null)
                        Text(
                          _getBackupStageLabel(state.stage!),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: state.progress),
            const SizedBox(height: 8),
            Text(
              '${(state.progress * 100).toStringAsFixed(1)}% '
              '${state.processedItems > 0 ? '(${state.processedItems}/${state.totalItems} items)' : ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _getBackupStageLabel(BackupStage stage) {
    switch (stage) {
      case BackupStage.initializing:
        return 'Initializing...';
      case BackupStage.gatheringData:
        return 'Gathering data...';
      case BackupStage.compressingData:
        return 'Compressing...';
      case BackupStage.encryptingData:
        return 'Encrypting...';
      case BackupStage.finalizing:
        return 'Finalizing...';
      case BackupStage.completed:
        return 'Completed!';
      case BackupStage.failed:
        return 'Failed';
    }
  }
}

/// Backup success card
class _BackupSuccessCard extends StatelessWidget {
  final BackupResult result;
  final VoidCallback onReset;

  const _BackupSuccessCard({
    required this.result,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Backup Created Successfully!',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _StatRow(
              label: 'Entries',
              value: '${result.entryCount}',
            ),
            _StatRow(
              label: 'Trips',
              value: '${result.tripCount}',
            ),
            _StatRow(
              label: 'Tags',
              value: '${result.tagCount}',
            ),
            _StatRow(
              label: 'Media Files',
              value: '${result.mediaCount}',
            ),
            _StatRow(
              label: 'File Size',
              value: result.fileSizeReadable,
            ),
            _StatRow(
              label: 'Duration',
              value: _formatDuration(result.duration),
            ),
            if (result.isEncrypted)
              const _StatRow(
                label: 'Encryption',
                value: 'Yes',
                icon: Icons.lock,
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: result.backupPath!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Path copied to clipboard')),
                      );
                    },
                    child: const Text('Copy Path'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onReset,
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
  }
}

/// Backup error card
class _BackupErrorCard extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final VoidCallback onReset;

  const _BackupErrorCard({
    required this.error,
    required this.onRetry,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Backup Failed',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReset,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Restore progress card
class _RestoreProgressCard extends StatelessWidget {
  final RestoreState state;

  const _RestoreProgressCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircularProgressIndicator(strokeWidth: 2),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restoring Backup...',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (state.stage != null)
                        Text(
                          _getRestoreStageLabel(state.stage!),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: state.progress),
            const SizedBox(height: 8),
            Text(
              '${(state.progress * 100).toStringAsFixed(1)}% '
              '${state.processedItems > 0 ? '(${state.processedItems}/${state.totalItems} items)' : ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _getRestoreStageLabel(RestoreStage stage) {
    switch (stage) {
      case RestoreStage.initializing:
        return 'Initializing...';
      case RestoreStage.validatingBackup:
        return 'Validating backup...';
      case RestoreStage.decryptingData:
        return 'Decrypting...';
      case RestoreStage.extractingData:
        return 'Extracting...';
      case RestoreStage.restoringData:
        return 'Restoring data...';
      case RestoreStage.finalizing:
        return 'Finalizing...';
      case RestoreStage.completed:
        return 'Completed!';
      case RestoreStage.failed:
        return 'Failed';
    }
  }
}

/// Restore success card
class _RestoreSuccessCard extends StatelessWidget {
  final RestoreResult result;
  final VoidCallback onReset;

  const _RestoreSuccessCard({
    required this.result,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Restore Completed Successfully!',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _StatRow(
              label: 'Entries Restored',
              value: '${result.entriesRestored}',
            ),
            _StatRow(
              label: 'Trips Restored',
              value: '${result.tripsRestored}',
            ),
            _StatRow(
              label: 'Tags Restored',
              value: '${result.tagsRestored}',
            ),
            _StatRow(
              label: 'Media Files',
              value: '${result.mediaRestored}',
            ),
            if (result.conflictCount > 0)
              _StatRow(
                label: 'Conflicts',
                value: '${result.conflictCount}',
                icon: Icons.warning,
              ),
            if (result.skippedCount > 0)
              _StatRow(
                label: 'Skipped',
                value: '${result.skippedCount}',
                icon: Icons.info,
              ),
            _StatRow(
              label: 'Duration',
              value: _formatDuration(result.duration),
            ),
            if (result.preRestoreBackupPath != null)
              const _StatRow(
                label: 'Backup Created',
                value: 'Yes',
                icon: Icons.backup,
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onReset,
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
  }
}

/// Restore error card
class _RestoreErrorCard extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final VoidCallback onReset;

  const _RestoreErrorCard({
    required this.error,
    required this.onRetry,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Restore Failed',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReset,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat row widget
class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const _StatRow({
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
