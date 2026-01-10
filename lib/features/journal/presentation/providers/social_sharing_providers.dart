import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/entities/trip.dart';
import '../../domain/services/social_sharing_service.dart';
import '../../data/services/social_sharing_service_impl.dart';

part 'social_sharing_providers.g.dart';

/// Provider for the social sharing service
@Riverpod(keepAlive: true)
SocialSharingService socialSharingService(Ref ref) {
  return SocialSharingServiceImpl();
}

/// State for social sharing operations
class SocialSharingState {
  /// Current status of sharing
  final SocialSharingStatus status;

  /// Share result if available
  final JournalShareResult? result;

  /// Error message if share failed
  final String? error;

  /// Timestamp when share was initiated
  final DateTime? startedAt;

  /// Timestamp when share completed
  final DateTime? completedAt;

  const SocialSharingState({
    this.status = SocialSharingStatus.idle,
    this.result,
    this.error,
    this.startedAt,
    this.completedAt,
  });

  /// Whether share is currently in progress
  bool get isSharing => status == SocialSharingStatus.sharing;

  /// Whether share completed successfully
  bool get isSuccess => status == SocialSharingStatus.success;

  /// Whether share failed
  bool get isFailed => status == SocialSharingStatus.failed;

  /// Whether share is idle (not started)
  bool get isIdle => status == SocialSharingStatus.idle;

  /// Get duration of share operation
  Duration? get shareDuration {
    if (startedAt == null || completedAt == null) return null;
    return completedAt!.difference(startedAt!);
  }

  /// Copy with method
  SocialSharingState copyWith({
    SocialSharingStatus? status,
    JournalShareResult? result,
    String? error,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return SocialSharingState(
      status: status ?? this.status,
      result: result ?? this.result,
      error: error ?? this.error,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  String toString() {
    return 'SocialSharingState(status: $status, '
        'result: $result, '
        'error: $error)';
  }
}

/// Status of social sharing
enum SocialSharingStatus {
  /// No share in progress
  idle,

  /// Share is in progress
  sharing,

  /// Share completed successfully
  success,

  /// Share failed
  failed,
}

/// Notifier for social sharing state management
@riverpod
class SocialSharingNotifier extends _$SocialSharingNotifier {
  @override
  SocialSharingState build() {
    return const SocialSharingState();
  }

  /// Share a journal entry
  Future<void> shareEntry({
    required JournalEntry entry,
    SharePlatform platform = SharePlatform.generic,
    ShareConfig? config,
    bool includeMedia = true,
    List<MediaItem>? mediaItems,
  }) async {
    final service = ref.read(socialSharingServiceProvider);

    state = state.copyWith(
      status: SocialSharingStatus.sharing,
      startedAt: DateTime.now(),
      error: null,
    );

    try {
      final result = await service.shareEntry(
        entry,
        platform: platform,
        config: config,
        includeMedia: includeMedia,
        mediaItems: mediaItems,
      );

      if (result.success) {
        state = state.copyWith(
          status: SocialSharingStatus.success,
          result: result,
          completedAt: DateTime.now(),
        );
      } else {
        state = state.copyWith(
          status: SocialSharingStatus.failed,
          error: result.errorMessage ?? 'Share failed',
          result: result,
          completedAt: DateTime.now(),
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: SocialSharingStatus.failed,
        error: e.toString(),
        completedAt: DateTime.now(),
      );
    }
  }

  /// Share a media item
  Future<void> shareMedia({
    required MediaItem media,
    SharePlatform platform = SharePlatform.generic,
    ShareConfig? config,
    JournalEntry? entry,
  }) async {
    final service = ref.read(socialSharingServiceProvider);

    state = state.copyWith(
      status: SocialSharingStatus.sharing,
      startedAt: DateTime.now(),
      error: null,
    );

    try {
      final result = await service.shareMedia(
        media,
        platform: platform,
        config: config,
        entry: entry,
      );

      if (result.success) {
        state = state.copyWith(
          status: SocialSharingStatus.success,
          result: result,
          completedAt: DateTime.now(),
        );
      } else {
        state = state.copyWith(
          status: SocialSharingStatus.failed,
          error: result.errorMessage ?? 'Share failed',
          result: result,
          completedAt: DateTime.now(),
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: SocialSharingStatus.failed,
        error: e.toString(),
        completedAt: DateTime.now(),
      );
    }
  }

  /// Share a trip
  Future<void> shareTrip({
    required Trip trip,
    SharePlatform platform = SharePlatform.generic,
    ShareConfig? config,
    int entryCount = 0,
  }) async {
    final service = ref.read(socialSharingServiceProvider);

    state = state.copyWith(
      status: SocialSharingStatus.sharing,
      startedAt: DateTime.now(),
      error: null,
    );

    try {
      final result = await service.shareTrip(
        trip,
        platform: platform,
        config: config,
        entryCount: entryCount,
      );

      if (result.success) {
        state = state.copyWith(
          status: SocialSharingStatus.success,
          result: result,
          completedAt: DateTime.now(),
        );
      } else {
        state = state.copyWith(
          status: SocialSharingStatus.failed,
          error: result.errorMessage ?? 'Share failed',
          result: result,
          completedAt: DateTime.now(),
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: SocialSharingStatus.failed,
        error: e.toString(),
        completedAt: DateTime.now(),
      );
    }
  }

  /// Share multiple entries
  Future<void> shareMultipleEntries({
    required List<JournalEntry> entries,
    SharePlatform platform = SharePlatform.generic,
    ShareConfig? config,
  }) async {
    final service = ref.read(socialSharingServiceProvider);

    state = state.copyWith(
      status: SocialSharingStatus.sharing,
      startedAt: DateTime.now(),
      error: null,
    );

    try {
      final result = await service.shareMultipleEntries(
        entries,
        platform: platform,
        config: config,
      );

      if (result.success) {
        state = state.copyWith(
          status: SocialSharingStatus.success,
          result: result,
          completedAt: DateTime.now(),
        );
      } else {
        state = state.copyWith(
          status: SocialSharingStatus.failed,
          error: result.errorMessage ?? 'Share failed',
          result: result,
          completedAt: DateTime.now(),
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: SocialSharingStatus.failed,
        error: e.toString(),
        completedAt: DateTime.now(),
      );
    }
  }

  /// Reset the state to idle
  void reset() {
    state = const SocialSharingState();
  }

  /// Clear error but keep result
  void clearError() {
    state = state.copyWith(
      error: null,
      status: state.result != null
          ? SocialSharingStatus.success
          : SocialSharingStatus.idle,
    );
  }
}

/// Provider for share configuration of an entry
@riverpod
ShareConfig entryShareConfig(
  Ref ref,
  JournalEntry entry, {
  List<String>? customHashtags,
  String? messageTemplate,
  bool includeLocation = true,
  bool includeDate = true,
  bool includeMood = true,
}) {
  final service = ref.watch(socialSharingServiceProvider);
  return service.generateEntryShareConfig(
    entry,
    customHashtags: customHashtags,
    messageTemplate: messageTemplate,
    includeLocation: includeLocation,
    includeDate: includeDate,
    includeMood: includeMood,
  );
}

/// Provider for share configuration of a media item
@riverpod
ShareConfig mediaShareConfig(
  Ref ref,
  MediaItem media, {
  JournalEntry? entry,
  List<String>? customHashtags,
  String? messageTemplate,
}) {
  final service = ref.watch(socialSharingServiceProvider);
  return service.generateMediaShareConfig(
    media,
    entry: entry,
    customHashtags: customHashtags,
    messageTemplate: messageTemplate,
  );
}

/// Provider for share configuration of a trip
@riverpod
ShareConfig tripShareConfig(
  Ref ref,
  Trip trip, {
  int entryCount = 0,
  List<String>? customHashtags,
  String? messageTemplate,
}) {
  final service = ref.watch(socialSharingServiceProvider);
  return service.generateTripShareConfig(
    trip,
    entryCount: entryCount,
    customHashtags: customHashtags,
    messageTemplate: messageTemplate,
  );
}

/// Provider for available share platforms
@riverpod
Future<List<SharePlatform>> availableSharePlatforms(Ref ref) async {
  final service = ref.watch(socialSharingServiceProvider);
  return service.getAvailablePlatforms();
}
