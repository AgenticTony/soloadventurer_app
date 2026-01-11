import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';
import 'package:soloadventurer/features/journal/domain/entities/media_item.dart';
import 'package:soloadventurer/features/journal/domain/entities/trip.dart';
import 'package:soloadventurer/features/journal/domain/services/social_sharing_service.dart';
import 'package:soloadventurer/features/journal/presentation/providers/social_sharing_providers.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/social_share_sheet.dart';

/// Example 1: Basic Share Sheet for Journal Entry
///
/// Shows the simplest way to add sharing to a journal entry screen
class Example1_BasicShareSheet extends ConsumerWidget {
  const Example1_BasicShareSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock entry for demonstration
    final entry = JournalEntry(
      id: '1',
      userId: 'user1',
      title: 'Amazing Day in Paris',
      content: 'Today I visited the Eiffel Tower and it was breathtaking!',
      mood: 'happy',
      locationName: 'Paris, France',
      latitude: 48.8588443,
      longitude: 2.2943506,
      entryDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entry'),
        actions: [
          // Simple share button
          SocialShareButton(
            contentType: ShareableType.journalEntry,
            entry: entry,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            if (entry.locationName != null)
              Text(
                '📍 ${entry.locationName}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            const SizedBox(height: 16),
            Text(entry.content),
            const SizedBox(height: 16),
            if (entry.mood != null) Text('😊 Mood: ${entry.mood}'),
          ],
        ),
      ),
    );
  }
}

/// Example 2: Share with Custom Configuration
///
/// Demonstrates custom hashtags and message formatting
class Example2_CustomConfiguration extends ConsumerStatefulWidget {
  const Example2_CustomConfiguration({super.key});

  @override
  ConsumerState<Example2_CustomConfiguration> createState() =>
      _Example2CustomConfigurationState();
}

class _Example2CustomConfigurationState
    extends ConsumerState<Example2_CustomConfiguration> {
  bool _includeMedia = true;
  bool _includeLocation = true;
  bool _includeDate = true;

  @override
  Widget build(BuildContext context) {
    final entry = _getMockEntry();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Share Config'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Entry preview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(entry.content),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Configuration options
          Text('Share Options', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Include Media'),
            subtitle: const Text('Share photos and videos'),
            value: _includeMedia,
            onChanged: (value) => setState(() => _includeMedia = value),
          ),
          SwitchListTile(
            title: const Text('Include Location'),
            value: _includeLocation,
            onChanged: (value) => setState(() => _includeLocation = value),
          ),
          SwitchListTile(
            title: const Text('Include Date'),
            value: _includeDate,
            onChanged: (value) => setState(() => _includeDate = value),
          ),

          const SizedBox(height: 20),

          // Share buttons for different platforms
          Text('Share To', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PlatformButton(
                label: 'Share Sheet',
                icon: Icons.share,
                platform: SharePlatform.generic,
                entry: entry,
                includeMedia: _includeMedia,
                includeLocation: _includeLocation,
                includeDate: _includeDate,
              ),
              _PlatformButton(
                label: 'Twitter',
                icon: Icons.flutter_dash,
                platform: SharePlatform.twitter,
                entry: entry,
                includeMedia: _includeMedia,
                includeLocation: _includeLocation,
                includeDate: _includeDate,
              ),
              _PlatformButton(
                label: 'Facebook',
                icon: Icons.facebook,
                platform: SharePlatform.facebook,
                entry: entry,
                includeMedia: _includeMedia,
                includeLocation: _includeLocation,
                includeDate: _includeDate,
              ),
              _PlatformButton(
                label: 'WhatsApp',
                icon: Icons.chat,
                platform: SharePlatform.whatsapp,
                entry: entry,
                includeMedia: _includeMedia,
                includeLocation: _includeLocation,
                includeDate: _includeDate,
              ),
              _PlatformButton(
                label: 'Copy',
                icon: Icons.content_copy,
                platform: SharePlatform.clipboard,
                entry: entry,
                includeMedia: false,
                includeLocation: _includeLocation,
                includeDate: _includeDate,
              ),
            ],
          ),
        ],
      ),
    );
  }

  JournalEntry _getMockEntry() {
    return JournalEntry(
      id: '1',
      userId: 'user1',
      title: 'Sunset at the Beach',
      content: 'Watched an amazing sunset today. The colors were incredible!',
      mood: 'peaceful',
      locationName: 'Malibu, California',
      entryDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

class _PlatformButton extends ConsumerWidget {
  final String label;
  final IconData icon;
  final SharePlatform platform;
  final JournalEntry entry;
  final bool includeMedia;
  final bool includeLocation;
  final bool includeDate;

  const _PlatformButton({
    required this.label,
    required this.icon,
    required this.platform,
    required this.entry,
    required this.includeMedia,
    required this.includeLocation,
    required this.includeDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () async {
        final service = ref.read(socialSharingServiceProvider);

        // Generate custom config
        final config = service.generateEntryShareConfig(
          entry,
          customHashtags: ['#travel', '#adventure', '#soloadventurer'],
          includeLocation: includeLocation,
          includeDate: includeDate,
          includeMood: true,
        );

        // Share
        final result = await service.shareEntry(
          entry,
          platform: platform,
          config: config,
          includeMedia: includeMedia,
        );

        // Show result
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.success
                    ? 'Shared successfully!'
                    : 'Share failed: ${result.errorMessage}',
              ),
              backgroundColor: result.success ? Colors.green : Colors.red,
            ),
          );
        }
      },
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

/// Example 3: Share Media Item
///
/// Demonstrates sharing individual photos/videos
class Example3_ShareMedia extends ConsumerWidget {
  const Example3_ShareMedia({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = MediaItem(
      id: '1',
      userId: 'user1',
      journalEntryId: 'entry1',
      mediaType: MediaType.photo,
      storagePath: '/path/to/photo.jpg',
      caption: 'Beautiful sunset at the beach',
      width: 1920,
      height: 1080,
      mimeType: 'image/jpeg',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final entry = JournalEntry(
      id: 'entry1',
      userId: 'user1',
      title: 'Beach Day',
      content: 'Amazing day at the beach',
      locationName: 'Santa Monica, CA',
      entryDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Viewer'),
        actions: [
          SocialShareButton(
            contentType: ShareableType.mediaItem,
            media: media,
            entry: entry,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo, size: 200, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              media.caption ?? 'No caption',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (entry.locationName != null)
              Text(
                '📍 ${entry.locationName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                SocialShareSheet.show(
                  context: context,
                  contentType: ShareableType.mediaItem,
                  media: media,
                  entry: entry,
                );
              },
              icon: const Icon(Icons.share),
              label: const Text('Share Photo'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 4: Share Trip
///
/// Demonstrates sharing an entire trip
class Example4_ShareTrip extends ConsumerWidget {
  const Example4_ShareTrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = Trip(
      id: '1',
      userId: 'user1',
      name: 'European Adventure',
      destination: 'Paris, France',
      startDate: DateTime(2024, 6, 1),
      endDate: DateTime(2024, 6, 15),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        actions: [
          SocialShareButton(
            contentType: ShareableType.trip,
            trip: trip,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trip.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '📍 ${trip.destination}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '📅 ${trip.startDate.day}/${trip.startDate.month}/${trip.startDate.year} - '
              '${trip.endDate.day}/${trip.endDate.month}/${trip.endDate.year}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                SocialShareSheet.show(
                  context: context,
                  contentType: ShareableType.trip,
                  trip: trip,
                );
              },
              icon: const Icon(Icons.share),
              label: const Text('Share Trip'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 5: Share Multiple Entries
///
/// Demonstrates batch sharing of multiple entries
class Example5_ShareMultipleEntries extends ConsumerWidget {
  const Example5_ShareMultipleEntries({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = List.generate(
      5,
      (index) => JournalEntry(
        id: 'entry$index',
        userId: 'user1',
        title: 'Day ${index + 1} Adventures',
        content: 'Amazing things happened on day ${index + 1}',
        entryDate: DateTime.now().subtract(Duration(days: 5 - index)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trip Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              SocialShareSheet.show(
                context: context,
                contentType: ShareableType.multipleEntries,
                entries: entries,
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: entries.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(entry.title),
              subtitle: Text(entry.content),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}

/// Example 6: Monitor Sharing State
///
/// Demonstrates how to monitor and display sharing progress
class Example6_StateMonitoring extends ConsumerWidget {
  const Example6_StateMonitoring({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharingState = ref.watch(socialSharingNotifierProvider);
    final entry = _getMockEntry();

    return Scaffold(
      appBar: AppBar(
        title: const Text('State Monitoring'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // State indicator
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: sharingState.isSharing
                    ? Colors.orange[100]
                    : sharingState.isSuccess
                        ? Colors.green[100]
                        : sharingState.isFailed
                            ? Colors.red[100]
                            : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: sharingState.isSharing
                  ? const CircularProgressIndicator()
                  : Icon(
                      sharingState.isSuccess
                          ? Icons.check_circle
                          : sharingState.isFailed
                              ? Icons.error
                              : Icons.share,
                      size: 60,
                      color: sharingState.isSuccess
                          ? Colors.green
                          : sharingState.isFailed
                              ? Colors.red
                              : Colors.grey,
                    ),
            ),
            const SizedBox(height: 20),

            Text(
              _getStateText(sharingState),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            if (sharingState.result != null)
              Text(
                'Platform: ${sharingState.result!.platform.name}\n'
                'Format: ${sharingState.result!.format.name}',
                textAlign: TextAlign.center,
              ),
            if (sharingState.error != null)
              Text(
                sharingState.error!,
                style: TextStyle(color: Colors.red[700]),
                textAlign: TextAlign.center,
              ),
            if (sharingState.shareDuration != null)
              Text(
                'Duration: ${sharingState.shareDuration!.inMilliseconds}ms',
                style: Theme.of(context).textTheme.bodySmall,
              ),

            const SizedBox(height: 40),

            // Share button
            ElevatedButton.icon(
              onPressed: sharingState.isSharing
                  ? null
                  : () {
                      ref
                          .read(socialSharingNotifierProvider.notifier)
                          .shareEntry(
                            entry: entry,
                            platform: SharePlatform.generic,
                          );
                    },
              icon: const Icon(Icons.share),
              label: const Text('Share Entry'),
            ),

            const SizedBox(height: 16),

            // Reset button
            if (sharingState.isSuccess || sharingState.isFailed)
              TextButton(
                onPressed: () {
                  ref.read(socialSharingNotifierProvider.notifier).reset();
                },
                child: const Text('Reset'),
              ),
          ],
        ),
      ),
    );
  }

  String _getStateText(SocialSharingState state) {
    if (state.isSharing) return 'Sharing...';
    if (state.isSuccess) return 'Shared Successfully!';
    if (state.isFailed) return 'Sharing Failed';
    return 'Ready to Share';
  }

  JournalEntry _getMockEntry() {
    return JournalEntry(
      id: '1',
      userId: 'user1',
      title: 'Test Entry',
      content: 'This is a test entry for sharing',
      entryDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

/// Example 7: Custom Share Sheet with Preview
///
/// Shows a custom implementation with content preview
class Example7_CustomShareSheet extends ConsumerStatefulWidget {
  const Example7_CustomShareSheet({super.key});

  @override
  ConsumerState<Example7_CustomShareSheet> createState() =>
      _Example7CustomShareSheetState();
}

class _Example7CustomShareSheetState
    extends ConsumerState<Example7_CustomShareSheet> {
  SharePlatform? _selectedPlatform;

  @override
  Widget build(BuildContext context) {
    final entry = _getMockEntry();
    final service = ref.read(socialSharingServiceProvider);
    final config = service.generateEntryShareConfig(entry);
    final previewText = config.getFormattedText(
      location: entry.locationName,
      date: entry.entryDate,
      mood: entry.mood,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Share Sheet'),
      ),
      body: Column(
        children: [
          // Content preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share Preview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(previewText),
                ),
              ],
            ),
          ),

          // Platform selection
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: SharePlatform.values.length,
              itemBuilder: (context, index) {
                final platform = SharePlatform.values[index];
                final isSelected = _selectedPlatform == platform;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedPlatform = platform;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getPlatformIcon(platform),
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[700],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          platform.name,
                          style: Theme.of(context).textTheme.labelSmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Share button
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _selectedPlatform != null
                  ? () async {
                      final notifier =
                          ref.read(socialSharingNotifierProvider.notifier);
                      await notifier.shareEntry(
                        entry: entry,
                        platform: _selectedPlatform!,
                      );

                      if (mounted) {
                        final state = ref.read(socialSharingNotifierProvider);
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              state.isSuccess
                                  ? 'Shared successfully!'
                                  : 'Share failed: ${state.error}',
                            ),
                          ),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                _selectedPlatform != null
                    ? 'Share to ${_selectedPlatform!.name}'
                    : 'Select Platform',
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlatformIcon(SharePlatform platform) {
    switch (platform) {
      case SharePlatform.generic:
        return Icons.share;
      case SharePlatform.facebook:
        return Icons.facebook;
      case SharePlatform.twitter:
        return Icons.flutter_dash;
      case SharePlatform.instagram:
        return Icons.camera_alt;
      case SharePlatform.whatsapp:
        return Icons.chat;
      case SharePlatform.telegram:
        return Icons.send;
      case SharePlatform.sms:
        return Icons.sms;
      case SharePlatform.email:
        return Icons.email;
      case SharePlatform.clipboard:
        return Icons.content_copy;
      case SharePlatform.more:
        return Icons.more_horiz;
    }
  }

  JournalEntry _getMockEntry() {
    return JournalEntry(
      id: '1',
      userId: 'user1',
      title: 'Mountain Hiking Adventure',
      content:
          'Reached the summit today! The view was absolutely breathtaking.',
      mood: 'accomplished',
      locationName: 'Rocky Mountains, Colorado',
      entryDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

/// Main menu for all examples
class SocialSharingExamplesMenu extends StatelessWidget {
  const SocialSharingExamplesMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Sharing Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ExampleCard(
            title: 'Example 1: Basic Share Sheet',
            description: 'Simplest way to add sharing to journal entries',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Example1_BasicShareSheet(),
              ),
            ),
          ),
          _ExampleCard(
            title: 'Example 2: Custom Configuration',
            description: 'Custom hashtags, message formatting, and options',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Example2_CustomConfiguration(),
              ),
            ),
          ),
          _ExampleCard(
            title: 'Example 3: Share Media',
            description: 'Share individual photos and videos',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Example3_ShareMedia(),
              ),
            ),
          ),
          _ExampleCard(
            title: 'Example 4: Share Trip',
            description: 'Share entire trip summaries',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Example4_ShareTrip(),
              ),
            ),
          ),
          _ExampleCard(
            title: 'Example 5: Share Multiple Entries',
            description: 'Batch share multiple journal entries',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Example5_ShareMultipleEntries(),
              ),
            ),
          ),
          _ExampleCard(
            title: 'Example 6: State Monitoring',
            description: 'Monitor sharing progress and state',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Example6_StateMonitoring(),
              ),
            ),
          ),
          _ExampleCard(
            title: 'Example 7: Custom Share Sheet',
            description: 'Custom UI with content preview',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Example7_CustomShareSheet(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ExampleCard({
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Entry point for running examples
void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        home: SocialSharingExamplesMenu(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
