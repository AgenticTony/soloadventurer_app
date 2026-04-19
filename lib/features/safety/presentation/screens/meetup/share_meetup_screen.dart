import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloadventurer/features/safety/presentation/providers/safety_providers.dart';
import 'package:soloadventurer/features/safety/presentation/widgets/liability_disclaimer_modal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Screen for creating a Share My Meetup entry.
///
/// Lets the user specify who they're meeting, where, and when,
/// then shares the details with selected trusted contacts.
class ShareMeetupScreen extends ConsumerStatefulWidget {
  /// Route name for navigation
  static const routeName = '/safety/meetup/share';

  /// Creates a new [ShareMeetupScreen]
  const ShareMeetupScreen({super.key});

  @override
  ConsumerState<ShareMeetupScreen> createState() =>
      _ShareMeetupScreenState();
}

class _ShareMeetupScreenState extends ConsumerState<ShareMeetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _meetingWithController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _meetupTime = DateTime.now().add(const Duration(hours: 2));
  Set<String> _selectedContactIds = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Load trusted contacts
    Future.microtask(() {
      ref.read(trustedContactsProvider.notifier).loadContacts();
    });
  }

  @override
  void dispose() {
    _meetingWithController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contactsState = ref.watch(trustedContactsProvider);
    final contacts = contactsState.value?.contacts ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share My Meetup'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Explanation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Share your meetup details with trusted contacts '
                        'so they know where you\'ll be and who you\'re meeting.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Who you're meeting
              TextFormField(
                controller: _meetingWithController,
                decoration: const InputDecoration(
                  labelText: 'Meeting With *',
                  hintText: 'Name of the person',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Meeting Location *',
                  hintText: 'Restaurant name, address, or landmark',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Date & Time picker
              _buildDateTimePicker(context, theme),
              const SizedBox(height: 16),

              // Notes (optional)
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Any additional details',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Trusted contacts selection
              Text(
                'Share With',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              if (contacts.isEmpty)
                _buildEmptyContactsState(context)
              else
                ...contacts.map((contact) => CheckboxListTile(
                      value: _selectedContactIds.contains(contact.id),
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedContactIds.add(contact.id);
                          } else {
                            _selectedContactIds.remove(contact.id);
                          }
                        });
                      },
                      title: Text(contact.name),
                      subtitle: contact.notes != null
                          ? Text(contact.notes!,
                              style: theme.textTheme.bodySmall)
                          : null,
                      secondary: CircleAvatar(
                        child: Text(contact.name[0].toUpperCase()),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    )),

              const SizedBox(height: 32),

              // Submit button
              ElevatedButton(
                onPressed: _canSubmit() && !_isSubmitting
                    ? _handleSubmit
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Share Meetup Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context, ThemeData theme) {
    return InkWell(
      onTap: () => _pickDateTime(context),
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Meetup Time *',
          prefixIcon: Icon(Icons.schedule),
          border: OutlineInputBorder(),
        ),
        child: Text(
          _formatDateTime(_meetupTime),
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _buildEmptyContactsState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text('No trusted contacts yet.'),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () =>
                context.push('/safety/trusted-contacts'),
            child: const Text('Add Trusted Contacts'),
          ),
        ],
      ),
    );
  }

  bool _canSubmit() {
    return _meetingWithController.text.trim().isNotEmpty &&
        _locationController.text.trim().isNotEmpty &&
        _selectedContactIds.isNotEmpty;
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _meetupTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_meetupTime),
    );
    if (time == null || !mounted) return;

    setState(() {
      _meetupTime = DateTime(
        date.year, date.month, date.day,
        time.hour, time.minute,
      );
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Show liability disclaimer on first use
    final acknowledged = await LiabilityDisclaimerModal.showIfNeeded(
      context,
      feature: LiabilityFeature.shareMeetup,
      onAcknowledged: () {},
    );
    if (!acknowledged) return;

    setState(() => _isSubmitting = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      // Save to Supabase
      await Supabase.instance.client.from('shared_meetups').insert({
        'user_id': user.id,
        'meeting_with': _meetingWithController.text.trim(),
        'location_name': _locationController.text.trim(),
        'meetup_time': _meetupTime.toIso8601String(),
        'notes': _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        'shared_with_contact_ids': _selectedContactIds.toList(),
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Meetup details shared with your trusted contacts.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _formatDateTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.month}/${dt.day}/${dt.year} at $hour:$minute';
  }
}
