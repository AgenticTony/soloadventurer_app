import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/meetup_checkin_providers.dart';
import '../providers/trusted_contacts_provider.dart';

/// Bottom sheet for creating a new meetup check-in
class CreateCheckinSheet extends ConsumerStatefulWidget {
  const CreateCheckinSheet({super.key});

  @override
  ConsumerState<CreateCheckinSheet> createState() =>
      _CreateCheckinSheetState();
}

class _CreateCheckinSheetState extends ConsumerState<CreateCheckinSheet> {
  String? _selectedContactId;
  DateTime? _selectedDateTime;
  final _locationController = TextEditingController();
  int _bufferMinutes = 120;

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contactsAsync = ref.watch(trustedContactsProvider);
    final contacts = contactsAsync.value?.contacts ?? [];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title row
            Row(
              children: [
                Text(
                  'New meetup check-in',
                  style: theme.textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Trusted contact dropdown
            if (contactsAsync.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (contacts.isEmpty)
              Text(
                'No trusted contacts added yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              )
            else
              DropdownButtonFormField<String>(
                initialValue: _selectedContactId,
                decoration: const InputDecoration(
                  labelText: 'Trusted Contact',
                  border: OutlineInputBorder(),
                ),
                items: contacts
                    .map(
                      (contact) => DropdownMenuItem(
                        value: contact.id,
                        child: Text(contact.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedContactId = v),
              ),
            const SizedBox(height: 16),

            // Meetup date/time picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _selectedDateTime == null
                    ? 'Pick meetup time'
                    : _formatDateTime(_selectedDateTime!),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDateTime ??
                      DateTime.now().add(const Duration(hours: 2)),
                  firstDate: DateTime.now(),
                  lastDate:
                      DateTime.now().add(const Duration(days: 30)),
                );
                if (date == null) return;
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time == null) return;
                if (!mounted) return;
                setState(() {
                  _selectedDateTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                });
              },
            ),
            const SizedBox(height: 16),

            // Location field
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Check-in window
            Text(
              'Check-in Window',
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 30, label: Text('30m')),
                ButtonSegment(value: 60, label: Text('1h')),
                ButtonSegment(value: 120, label: Text('2h')),
                ButtonSegment(value: 240, label: Text('4h')),
              ],
              selected: {_bufferMinutes},
              onSelectionChanged: (s) =>
                  setState(() => _bufferMinutes = s.first),
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedContactId == null ||
                        _selectedDateTime == null
                    ? null
                    : _submit,
                child: const Text('Set check-in'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _submit() {
    ref.read(activeCheckinsProvider.notifier).createCheckin(
          trustedContactId: _selectedContactId!,
          meetupTime: _selectedDateTime!,
          locationName: _locationController.text.isEmpty
              ? null
              : _locationController.text,
          checkinBufferMins: _bufferMinutes,
        );
    Navigator.of(context).pop();
  }

  String _formatDateTime(DateTime dt) {
    final hour =
        dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.month}/${dt.day} $hour:$minute $amPm';
  }
}
