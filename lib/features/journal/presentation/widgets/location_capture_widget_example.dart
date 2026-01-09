import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_entry_providers.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/location_capture_widget.dart';

/// Example demonstrating LocationCaptureWidget usage
class LocationCaptureWidgetExample extends ConsumerStatefulWidget {
  const LocationCaptureWidgetExample({super.key});

  @override
  ConsumerState<LocationCaptureWidgetExample> createState() =>
      _LocationCaptureWidgetExampleState();
}

class _LocationCaptureWidgetExampleState
    extends ConsumerState<LocationCaptureWidgetExample> {
  @override
  Widget build(BuildContext context) {
    final creationState = ref.watch(journalEntryCreationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Capture Widget Examples'),
        actions: [
          // Simple button in app bar
          LocationCaptureButton(
            label: 'Location',
            capturedIcon: Icons.location_on,
            uncapturedIcon: Icons.location_on_outlined,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Example 1: Full widget
          const Text(
            'Full Location Widget',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const LocationCaptureWidget(),
          const SizedBox(height: 24),

          // Example 2: Compact widget
          const Text(
            'Compact Mode',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const LocationCaptureWidget(
            isCompact: true,
          ),
          const SizedBox(height: 24),

          // Example 3: Custom padding
          const Text(
            'Custom Padding',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const LocationCaptureWidget(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          ),
          const SizedBox(height: 24),

          // Example 4: Button only
          Row(
            children: [
              const Text(
                'Inline Buttons:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              LocationCaptureButton(
                label: 'Add Location',
                capturedIcon: Icons.my_location,
                uncapturedIcon: Icons.location_searching,
              ),
              const SizedBox(width: 16),
              LocationCaptureButton(
                capturedIcon: Icons.place,
                uncapturedIcon: Icons.place_outlined,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Debug info
          Text(
            'Debug Info',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Latitude: ${creationState.latitude ?? "Not set"}'),
                  Text('Longitude: ${creationState.longitude ?? "Not set"}'),
                  Text(
                      'Accuracy: ${creationState.locationAccuracy?.toStringAsFixed(1) ?? "Not set"} m'),
                  Text('Is Capturing: ${creationState.isCapturingLocation}'),
                  if (creationState.error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Error: ${creationState.error}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example: Integration with journal entry creation screen
class JournalEntryWithLocationExample extends ConsumerWidget {
  const JournalEntryWithLocationExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creationState = ref.watch(journalEntryCreationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Journal Entry'),
        actions: [
          // Quick location button in app bar
          LocationCaptureButton(),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show more options
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title field
            TextField(
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter a title for your entry',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                ref
                    .read(journalEntryCreationProvider.notifier)
                    .updateTitle(value);
              },
            ),

            const SizedBox(height: 16),

            // Date picker
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: creationState.entryDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (date != null) {
                  ref
                      .read(journalEntryCreationProvider.notifier)
                      .updateEntryDate(date);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  '${creationState.entryDate.day}/${creationState.entryDate.month}/${creationState.entryDate.year}',
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Content placeholder (would be RichTextEditor)
            TextField(
              decoration: const InputDecoration(
                labelText: 'Content *',
                hintText: 'Write your journal entry...',
                border: OutlineInputBorder(),
              ),
              maxLines: 8,
              onChanged: (value) {
                ref
                    .read(journalEntryCreationProvider.notifier)
                    .updateContent(value);
              },
            ),

            const SizedBox(height: 24),

            // Location section header
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Location',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Location capture widget (integrated)
            const LocationCaptureWidget(),

            const SizedBox(height: 24),

            // Mood section (placeholder)
            Row(
              children: [
                Icon(
                  Icons.emoji_emotions_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mood',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Mood placeholder
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Mood selector coming soon...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Favorite toggle
            SwitchListTile(
              title: const Text('Mark as Favorite'),
              subtitle: const Text('Add this entry to your favorites'),
              value: creationState.isFavorite,
              onChanged: (value) {
                ref
                    .read(journalEntryCreationProvider.notifier)
                    .toggleFavorite();
              },
            ),

            const SizedBox(height: 24),

            // Save button
            ElevatedButton(
              onPressed: creationState.isValid && !creationState.isSaving
                  ? () async {
                      final success = await ref
                          .read(journalEntryCreationProvider.notifier)
                          .saveEntry();
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Journal entry saved!'),
                          ),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: creationState.isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Entry'),
            ),

            // Show errors
            if (creationState.error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        creationState.error!,
                        style: TextStyle(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        ref
                            .read(journalEntryCreationProvider.notifier)
                            .clearError();
                      },
                      color: theme.colorScheme.error,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Minimal example with just the button
class MinimalLocationExample extends StatelessWidget {
  const MinimalLocationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minimal Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tap the button to capture location',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            // Simple button
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LocationCaptureButton(
                  label: 'Add Location',
                  capturedIcon: Icons.location_on,
                  uncapturedIcon: Icons.location_on_outlined,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Main example screen with navigation
class LocationCaptureMainExample extends StatelessWidget {
  const LocationCaptureMainExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location Widget Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Select an example:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _ExampleTile(
            title: 'Widget Gallery',
            subtitle: 'All widget variants and styles',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LocationCaptureWidgetExample(),
              ),
            ),
          ),
          _ExampleTile(
            title: 'Journal Entry Integration',
            subtitle: 'Full journal entry creation with location',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const JournalEntryWithLocationExample(),
              ),
            ),
          ),
          _ExampleTile(
            title: 'Minimal Example',
            subtitle: 'Simple button-only implementation',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MinimalLocationExample(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExampleTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
