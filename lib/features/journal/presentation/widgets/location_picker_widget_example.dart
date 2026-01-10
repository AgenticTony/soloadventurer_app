import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_entry_providers.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/location_picker_widget.dart';

/// Example screen demonstrating the LocationPickerWidget usage
///
/// This example shows:
/// 1. Using the full LocationPickerWidget in a screen
/// 2. Using the compact LocationPickerButton
/// 3. Integration with journal entry creation provider
/// 4. Different modes and configurations
class LocationPickerExampleScreen extends ConsumerStatefulWidget {
  const LocationPickerExampleScreen({super.key});

  @override
  ConsumerState<LocationPickerExampleScreen> createState() =>
      _LocationPickerExampleScreenState();
}

class _LocationPickerExampleScreenState
    extends ConsumerState<LocationPickerExampleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Picker Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Example 1: Full location picker widget
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Example 1: Full Location Picker',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete widget with search, map, and current location features.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  const LocationPickerWidget(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Example 2: Location picker with initial location
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Example 2: Edit Mode',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Location picker initialized with existing location data.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  const LocationPickerWidget(
                    initialLocationName: 'Eiffel Tower, Paris',
                    initialLatitude: 48.8584,
                    initialLongitude: 2.2945,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Example 3: Compact button variant
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Example 3: Compact Button',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Inline button that opens picker in bottom sheet.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      LocationPickerButton(
                        label: 'Add Location',
                      ),
                      SizedBox(width: 16),
                      LocationPickerButton(
                        currentLocationName: 'Paris, France',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Example 4: Integration with journal entry
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Example 4: Journal Entry Integration',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Monitoring state changes from journal entry provider.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  const _JournalEntryLocationMonitor(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget that monitors and displays journal entry location state
class _JournalEntryLocationMonitor extends ConsumerWidget {
  const _JournalEntryLocationMonitor();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creationState = ref.watch(journalEntryCreationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location picker
        const LocationPickerWidget(),
        const SizedBox(height: 16),

        // State display
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Journal Entry State:',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Location Name: ${creationState.locationName ?? "Not set"}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Latitude: ${creationState.latitude?.toStringAsFixed(6) ?? "Not set"}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Longitude: ${creationState.longitude?.toStringAsFixed(6) ?? "Not set"}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Accuracy: ${creationState.locationAccuracy?.toStringAsFixed(1) ?? "Not set"} meters',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Example showing usage in a form
class LocationPickerFormExample extends ConsumerStatefulWidget {
  const LocationPickerFormExample({super.key});

  @override
  ConsumerState<LocationPickerFormExample> createState() =>
      _LocationPickerFormExampleState();
}

class _LocationPickerFormExampleState
    extends ConsumerState<LocationPickerFormExample> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final creationState = ref.read(journalEntryCreationProvider);

      // Check if location is set
      if (creationState.latitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a location'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Process form data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saved: ${_titleController.text}\n'
            'Location: ${creationState.locationName}',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entry Form'),
        actions: [
          TextButton(
            onPressed: _saveForm,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter journal entry title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Location picker
            const LocationPickerWidget(),

            const SizedBox(height: 24),

            // Additional form fields can go here
            // ...

            const SizedBox(height: 80), // Bottom padding
          ],
        ),
      ),
    );
  }
}

/// Example showing programmatic location setting
class ProgrammaticLocationExample extends ConsumerWidget {
  const ProgrammaticLocationExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programmatic Location'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LocationPickerWidget(
              initialLocationName: 'Golden Gate Bridge',
              initialLatitude: 37.8199,
              initialLongitude: -122.4783,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Programmatically set a location
                ref.read(journalEntryCreationProvider.notifier).updateLocation(
                      locationName: 'Statue of Liberty',
                      latitude: 40.6892,
                      longitude: -74.0445,
                      locationAccuracy: null,
                    );
              },
              child: const Text('Set Statue of Liberty'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Clear location
                ref.read(journalEntryCreationProvider.notifier).clearLocation();
              },
              child: const Text('Clear Location'),
            ),
          ],
        ),
      ),
    );
  }
}
