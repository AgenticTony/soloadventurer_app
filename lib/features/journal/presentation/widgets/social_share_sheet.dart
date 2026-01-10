import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/entities/trip.dart';
import '../../domain/services/social_sharing_service.dart';
import '../providers/social_sharing_providers.dart';

/// Bottom sheet for sharing journal content to social platforms
class SocialShareSheet extends ConsumerStatefulWidget {
  /// Type of content to share
  final ShareableType contentType;

  /// Journal entry to share (if contentType is journalEntry)
  final JournalEntry? entry;

  /// Media item to share (if contentType is mediaItem)
  final MediaItem? media;

  /// Trip to share (if contentType is trip)
  final Trip? trip;

  /// Multiple entries to share (if contentType is multipleEntries)
  final List<JournalEntry>? entries;

  /// Callback when sharing is complete
  final VoidCallback? onShareComplete;

  const SocialShareSheet({
    super.key,
    required this.contentType,
    this.entry,
    this.media,
    this.trip,
    this.entries,
    this.onShareComplete,
  });

  @override
  ConsumerState<SocialShareSheet> createState() => _SocialShareSheetState();

  /// Show the share sheet as a modal bottom sheet
  static Future<void> show({
    required BuildContext context,
    required ShareableType contentType,
    JournalEntry? entry,
    MediaItem? media,
    Trip? trip,
    List<JournalEntry>? entries,
    VoidCallback? onShareComplete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SocialShareSheet(
        contentType: contentType,
        entry: entry,
        media: media,
        trip: trip,
        entries: entries,
        onShareComplete: onShareComplete,
      ),
    );
  }
}

class _SocialShareSheetState extends ConsumerState<SocialShareSheet> {
  SharePlatform? _selectedPlatform;
  bool _includeMedia = true;

  @override
  Widget build(BuildContext context) {
    final sharingState = ref.watch(socialSharingNotifierProvider);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(context, theme),
              const SizedBox(height: 20),

              // Platform options
              _buildPlatformGrid(context, theme),
              const SizedBox(height: 20),

              // Media inclusion option (for entries)
              if (widget.contentType == ShareableType.journalEntry &&
                  widget.entry != null)
                _buildMediaOption(context, theme),

              const SizedBox(height: 20),

              // Share button or loading indicator
              if (sharingState.isSharing)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else
                ElevatedButton(
                  onPressed: _selectedPlatform != null ? _handleShare : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _selectedPlatform != null
                        ? 'Share to ${_getPlatformName(_selectedPlatform!)}'
                        : 'Select a Platform',
                  ),
                ),

              // Result message
              if (sharingState.isSuccess) _buildSuccessCard(context, theme),
              if (sharingState.isFailed) _buildErrorCard(context, theme),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    String title;
    switch (widget.contentType) {
      case ShareableType.journalEntry:
        title = 'Share Journal Entry';
        break;
      case ShareableType.mediaItem:
        title = 'Share ${widget.media?.isVideo == true ? "Video" : "Photo"}';
        break;
      case ShareableType.trip:
        title = 'Share Trip';
        break;
      case ShareableType.multipleEntries:
        title = 'Share ${widget.entries?.length ?? 0} Entries';
        break;
    }

    return Column(
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: theme.textTheme.headlineSmall,
        ),
      ],
    );
  }

  Widget _buildPlatformGrid(BuildContext context, ThemeData theme) {
    final platforms = _getAvailablePlatforms();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: platforms.length,
      itemBuilder: (context, index) {
        final platform = platforms[index];
        final isSelected = _selectedPlatform == platform;

        return _PlatformButton(
          platform: platform,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              _selectedPlatform = platform;
            });
          },
        );
      },
    );
  }

  Widget _buildMediaOption(BuildContext context, ThemeData theme) {
    return SwitchListTile(
      title: const Text('Include Media'),
      subtitle: const Text('Share photos and videos with this entry'),
      value: _includeMedia,
      onChanged: (value) {
        setState(() {
          _includeMedia = value;
        });
      },
    );
  }

  Widget _buildSuccessCard(BuildContext context, ThemeData theme) {
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Shared successfully!',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                ref.read(socialSharingNotifierProvider.notifier).reset();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, ThemeData theme) {
    final sharingState = ref.watch(socialSharingNotifierProvider);
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.error,
              color: theme.colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                sharingState.error ?? 'Sharing failed',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                ref.read(socialSharingNotifierProvider.notifier).clearError();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleShare() async {
    if (_selectedPlatform == null) return;

    final notifier = ref.read(socialSharingNotifierProvider.notifier);

    switch (widget.contentType) {
      case ShareableType.journalEntry:
        if (widget.entry != null) {
          await notifier.shareEntry(
            entry: widget.entry!,
            platform: _selectedPlatform!,
            includeMedia: _includeMedia,
          );
        }
        break;
      case ShareableType.mediaItem:
        if (widget.media != null) {
          await notifier.shareMedia(
            media: widget.media!,
            platform: _selectedPlatform!,
            entry: widget.entry,
          );
        }
        break;
      case ShareableType.trip:
        if (widget.trip != null) {
          await notifier.shareTrip(
            trip: widget.trip!,
            platform: _selectedPlatform!,
          );
        }
        break;
      case ShareableType.multipleEntries:
        if (widget.entries != null && widget.entries!.isNotEmpty) {
          await notifier.shareMultipleEntries(
            entries: widget.entries!,
            platform: _selectedPlatform!,
          );
        }
        break;
    }

    // Close after successful share
    if (mounted) {
      final state = ref.read(socialSharingNotifierProvider);
      if (state.isSuccess) {
        Navigator.of(context).pop();
        widget.onShareComplete?.call();
      }
    }
  }

  List<SharePlatform> _getAvailablePlatforms() {
    return [
      SharePlatform.generic,
      SharePlatform.facebook,
      SharePlatform.twitter,
      SharePlatform.instagram,
      SharePlatform.whatsapp,
      SharePlatform.telegram,
      SharePlatform.sms,
      SharePlatform.email,
      SharePlatform.clipboard,
    ];
  }

  String _getPlatformName(SharePlatform platform) {
    switch (platform) {
      case SharePlatform.generic:
        return 'Share';
      case SharePlatform.facebook:
        return 'Facebook';
      case SharePlatform.twitter:
        return 'Twitter';
      case SharePlatform.instagram:
        return 'Instagram';
      case SharePlatform.whatsapp:
        return 'WhatsApp';
      case SharePlatform.telegram:
        return 'Telegram';
      case SharePlatform.sms:
        return 'SMS';
      case SharePlatform.email:
        return 'Email';
      case SharePlatform.clipboard:
        return 'Clipboard';
      case SharePlatform.more:
        return 'More';
    }
  }
}

/// Platform selection button
class _PlatformButton extends StatelessWidget {
  final SharePlatform platform;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlatformButton({
    required this.platform,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getPlatformIcon(platform),
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              _getPlatformShortName(platform),
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
        return Icons.flutter_dash; // Twitter bird placeholder
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

  String _getPlatformShortName(SharePlatform platform) {
    switch (platform) {
      case SharePlatform.generic:
        return 'Share';
      case SharePlatform.facebook:
        return 'Facebook';
      case SharePlatform.twitter:
        return 'Twitter';
      case SharePlatform.instagram:
        return 'Instagram';
      case SharePlatform.whatsapp:
        return 'WhatsApp';
      case SharePlatform.telegram:
        return 'Telegram';
      case SharePlatform.sms:
        return 'SMS';
      case SharePlatform.email:
        return 'Email';
      case SharePlatform.clipboard:
        return 'Copy';
      case SharePlatform.more:
        return 'More';
    }
  }
}

/// Simple share button for quick access
class SocialShareButton extends ConsumerWidget {
  final ShareableType contentType;
  final JournalEntry? entry;
  final MediaItem? media;
  final Trip? trip;
  final List<JournalEntry>? entries;
  final VoidCallback? onShareComplete;

  const SocialShareButton({
    super.key,
    required this.contentType,
    this.entry,
    this.media,
    this.trip,
    this.entries,
    this.onShareComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.share),
      onPressed: () {
        SocialShareSheet.show(
          context: context,
          contentType: contentType,
          entry: entry,
          media: media,
          trip: trip,
          entries: entries,
          onShareComplete: onShareComplete,
        );
      },
    );
  }
}
