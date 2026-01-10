import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soloadventurer/features/journal/presentation/providers/trip_providers.dart';

/// Screen for creating or editing a trip
class CreateTripScreen extends ConsumerStatefulWidget {
  final String? tripId;

  const CreateTripScreen({super.key, this.tripId});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.tripId != null) {
      // Load existing trip for editing
      Future.microtask(() {
        ref.read(tripFormProvider.notifier).loadTrip(widget.tripId!);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _destinationController.dispose();
    // Reset form state when leaving
    ref.read(tripFormProvider.notifier).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(tripFormProvider);
    final isEditing = widget.tripId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Trip' : 'Create Trip'),
        actions: [
          // Save button
          if (!formState.isLoading)
            TextButton(
              onPressed: formState.isValid ? _saveTrip : null,
              child: const Text('Save'),
            ),
          // Loading indicator
          if (formState.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Trip name
            TextFormField(
              controller: _nameController,
              initialValue: formState.name,
              decoration: const InputDecoration(
                labelText: 'Trip Name *',
                hintText: 'e.g., Summer Vacation in Japan',
                prefixIcon: Icon(Icons.label),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Trip name is required';
                }
                if (value.trim().length < 3) {
                  return 'Trip name must be at least 3 characters';
                }
                if (value.trim().length > 200) {
                  return 'Trip name must be less than 200 characters';
                }
                return null;
              },
              onChanged: (value) {
                ref.read(tripFormProvider.notifier).updateName(value);
              },
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 16),

            // Destination
            TextFormField(
              controller: _destinationController,
              initialValue: formState.destination,
              decoration: const InputDecoration(
                labelText: 'Destination',
                hintText: 'e.g., Tokyo, Japan',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != null && value.trim().length > 200) {
                  return 'Destination must be less than 200 characters';
                }
                return null;
              },
              onChanged: (value) {
                ref.read(tripFormProvider.notifier).updateDestination(value);
              },
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 16),

            // Start date
            InkWell(
              onTap: () => _selectStartDate(context, formState.startDate),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Start Date *',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  DateFormat('MMM dd, yyyy').format(formState.startDate),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // End date
            InkWell(
              onTap: () => _selectEndDate(
                  context, formState.endDate, formState.startDate),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'End Date (Optional)',
                  prefixIcon: const Icon(Icons.event),
                  border: const OutlineInputBorder(),
                  suffixIcon: formState.endDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            ref
                                .read(tripFormProvider.notifier)
                                .updateEndDate(null);
                          },
                        )
                      : null,
                ),
                child: Text(
                  formState.endDate != null
                      ? DateFormat('MMM dd, yyyy').format(formState.endDate!)
                      : 'Ongoing trip',
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              initialValue: formState.description,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Add a description for your trip...',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) {
                if (value != null && value.trim().length > 2000) {
                  return 'Description must be less than 2000 characters';
                }
                return null;
              },
              onChanged: (value) {
                ref.read(tripFormProvider.notifier).updateDescription(value);
              },
              textInputAction: TextInputAction.newline,
            ),

            const SizedBox(height: 16),

            // Cover image URL (for future implementation)
            TextFormField(
              initialValue: formState.coverImageUrl,
              decoration: const InputDecoration(
                labelText: 'Cover Image URL (Optional)',
                hintText: 'https://example.com/image.jpg',
                prefixIcon: Icon(Icons.image),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  // Basic URL validation
                  if (!value.startsWith('http://') &&
                      !value.startsWith('https://')) {
                    return 'Please enter a valid URL';
                  }
                }
                return null;
              },
              onChanged: (value) {
                final trimmed = value.trim().isEmpty ? null : value.trim();
                ref.read(tripFormProvider.notifier).updateCoverImage(trimmed);
              },
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 24),

            // Public trip switch
            SwitchListTile(
              title: const Text('Public Trip'),
              subtitle: const Text('Allow others to view this trip'),
              value: formState.isPublic,
              onChanged: (value) {
                ref.read(tripFormProvider.notifier).updatePublic(value);
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),

            const SizedBox(height: 16),

            // Error message
            if (formState.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        formState.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Save button (for convenience)
            if (!formState.isLoading)
              ElevatedButton.icon(
                onPressed: formState.isValid ? _saveTrip : null,
                icon: const Icon(Icons.save),
                label: Text(isEditing ? 'Update Trip' : 'Create Trip'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(
      BuildContext context, DateTime currentDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      ref.read(tripFormProvider.notifier).updateStartDate(picked);
    }
  }

  Future<void> _selectEndDate(
      BuildContext context, DateTime? currentDate, DateTime startDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? startDate,
      firstDate: startDate,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      ref.read(tripFormProvider.notifier).updateEndDate(picked);
    }
  }

  Future<void> _saveTrip() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Save trip
    final trip = await ref.read(tripFormProvider.notifier).saveTrip();

    if (trip != null && mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(widget.tripId != null ? 'Trip updated!' : 'Trip created!'),
          backgroundColor: Colors.green,
        ),
      );

      // Return the trip to the previous screen
      Navigator.pop(context, trip);
    }
  }
}
