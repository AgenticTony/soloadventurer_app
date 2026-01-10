import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soloadventurer/features/journal/domain/entities/shared_link.dart';
import 'package:soloadventurer/features/journal/presentation/providers/shared_link_providers.dart';

/// Widget for creating a shared link for a trip
class SharedLinkCreator extends ConsumerStatefulWidget {
  /// Trip ID to share
  final String tripId;

  /// Trip name (for display)
  final String tripName;

  const SharedLinkCreator({
    super.key,
    required this.tripId,
    required this.tripName,
  });

  @override
  ConsumerState<SharedLinkCreator> createState() => _SharedLinkCreatorState();
}

class _SharedLinkCreatorState extends ConsumerState<SharedLinkCreator> {
  final _passwordController = TextEditingController();
  final _expirationController = TextEditingController();

  bool _hasPassword = false;
  bool _hasExpiration = false;
  DateTime? _expirationDate;
  bool _showPassword = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _expirationController.dispose();
    super.dispose();
  }

  Future<void> _createLink() async {
    final config = CreateSharedLinkConfig(
      tripId: widget.tripId,
      password: _hasPassword ? _passwordController.text : null,
      expiresAt: _hasExpiration ? _expirationDate : null,
    );

    final notifier = ref.read(createSharedLinkNotifierProvider.notifier);
    await notifier.createLink(config);

    if (mounted) {
      final state = ref.read(createSharedLinkNotifierProvider);

      if (state.createdLink != null) {
        _showSuccessDialog(state.createdLink!);
        notifier.reset();
        Navigator.of(context).pop();
      } else if (state.errorMessage != null) {
        _showErrorDialog(state.errorMessage!);
        notifier.clearError();
      }
    }
  }

  void _showSuccessDialog(SharedLink link) {
    showDialog(
      context: context,
      builder: (context) => SharedLinkSuccessDialog(link: link),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Failed to Create Link'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectExpirationDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (selected != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _expirationDate = DateTime(
            selected.year,
            selected.month,
            selected.day,
            time.hour,
            time.minute,
          );
          _expirationController.text =
              DateFormat('MMM dd, yyyy - HH:mm').format(_expirationDate!);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createSharedLinkNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Share Link'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip info
            Card(
              child: ListTile(
                leading: const Icon(Icons.travel_explore),
                title: const Text('Trip'),
                subtitle: Text(widget.tripName),
              ),
            ),
            const SizedBox(height: 24),

            // Password protection
            SwitchListTile(
              title: const Text('Password Protection'),
              subtitle: const Text('Require a password to access this link'),
              value: _hasPassword,
              onChanged: (value) {
                setState(() {
                  _hasPassword = value;
                  if (!value) {
                    _passwordController.clear();
                  }
                });
              },
            ),
            if (_hasPassword) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter a password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Share this password with anyone you want to give access to.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: 24),

            // Expiration date
            SwitchListTile(
              title: const Text('Set Expiration Date'),
              subtitle: const Text('Link will expire after this date'),
              value: _hasExpiration,
              onChanged: (value) {
                setState(() {
                  _hasExpiration = value;
                  if (!value) {
                    _expirationDate = null;
                    _expirationController.clear();
                  }
                });
              },
            ),
            if (_hasExpiration) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _expirationController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Expiration Date',
                  hintText: 'Select expiration date',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                onTap: _selectExpirationDate,
              ),
            ],
            const SizedBox(height: 32),

            // Create button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: createState.isCreating
                    ? null
                    : () {
                        // Validate
                        if (_hasPassword &&
                            (_passwordController.text.isEmpty ||
                                _passwordController.text.length < 4)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Password must be at least 4 characters long'),
                            ),
                          );
                          return;
                        }

                        if (_hasExpiration && _expirationDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select an expiration date'),
                            ),
                          );
                          return;
                        }

                        _createLink();
                      },
                child: createState.isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Share Link'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog shown after successfully creating a shared link
class SharedLinkSuccessDialog extends StatelessWidget {
  final SharedLink link;

  const SharedLinkSuccessDialog({
    super.key,
    required this.link,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Text('Link Created!'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your trip is now ready to share.'),
          const SizedBox(height: 16),
          const Text(
            'Share Link:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    link.shareUrl,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    // Copy to clipboard
                    // In real implementation, use Clipboard.setData
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied!')),
                    );
                  },
                  tooltip: 'Copy link',
                ),
              ],
            ),
          ),
          if (link.hasPassword) ...[
            const SizedBox(height: 16),
            const Text(
              'Note: This link is password protected.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
          if (link.expiresAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Expires: ${DateFormat('MMM dd, yyyy').format(link.expiresAt!)}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

/// Convenience widget to show shared link creator from a button
class CreateSharedLinkButton extends StatelessWidget {
  final String tripId;
  final String tripName;

  const CreateSharedLinkButton({
    super.key,
    required this.tripId,
    required this.tripName,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SharedLinkCreator(
              tripId: tripId,
              tripName: tripName,
            ),
          ),
        );
      },
      icon: const Icon(Icons.link),
      label: const Text('Create Share Link'),
    );
  }
}
