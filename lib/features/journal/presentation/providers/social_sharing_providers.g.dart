// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_sharing_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the social sharing service

@ProviderFor(socialSharingService)
const socialSharingServiceProvider = SocialSharingServiceProvider._();

/// Provider for the social sharing service

final class SocialSharingServiceProvider extends $FunctionalProvider<
    SocialSharingService,
    SocialSharingService,
    SocialSharingService> with $Provider<SocialSharingService> {
  /// Provider for the social sharing service
  const SocialSharingServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'socialSharingServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$socialSharingServiceHash();

  @$internal
  @override
  $ProviderElement<SocialSharingService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SocialSharingService create(Ref ref) {
    return socialSharingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SocialSharingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SocialSharingService>(value),
    );
  }
}

String _$socialSharingServiceHash() =>
    r'f633f7e3f13f328e3170837e74122fbfdfbac7db';

/// Notifier for social sharing state management

@ProviderFor(SocialSharingNotifier)
const socialSharingProvider = SocialSharingNotifierProvider._();

/// Notifier for social sharing state management
final class SocialSharingNotifierProvider
    extends $NotifierProvider<SocialSharingNotifier, SocialSharingState> {
  /// Notifier for social sharing state management
  const SocialSharingNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'socialSharingProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$socialSharingNotifierHash();

  @$internal
  @override
  SocialSharingNotifier create() => SocialSharingNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SocialSharingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SocialSharingState>(value),
    );
  }
}

String _$socialSharingNotifierHash() =>
    r'daef8e0b00893ec05938e82bb50c5f0dcbc0c91b';

/// Notifier for social sharing state management

abstract class _$SocialSharingNotifier extends $Notifier<SocialSharingState> {
  SocialSharingState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SocialSharingState, SocialSharingState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SocialSharingState, SocialSharingState>,
        SocialSharingState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

/// Provider for share configuration of an entry

@ProviderFor(entryShareConfig)
const entryShareConfigProvider = EntryShareConfigFamily._();

/// Provider for share configuration of an entry

final class EntryShareConfigProvider
    extends $FunctionalProvider<ShareConfig, ShareConfig, ShareConfig>
    with $Provider<ShareConfig> {
  /// Provider for share configuration of an entry
  const EntryShareConfigProvider._(
      {required EntryShareConfigFamily super.from,
      required (
        JournalEntry, {
        List<String>? customHashtags,
        String? messageTemplate,
        bool includeLocation,
        bool includeDate,
        bool includeMood,
      })
          super.argument})
      : super(
          retry: null,
          name: r'entryShareConfigProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$entryShareConfigHash();

  @override
  String toString() {
    return r'entryShareConfigProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<ShareConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ShareConfig create(Ref ref) {
    final argument = this.argument as (
      JournalEntry, {
      List<String>? customHashtags,
      String? messageTemplate,
      bool includeLocation,
      bool includeDate,
      bool includeMood,
    });
    return entryShareConfig(
      ref,
      argument.$1,
      customHashtags: argument.customHashtags,
      messageTemplate: argument.messageTemplate,
      includeLocation: argument.includeLocation,
      includeDate: argument.includeDate,
      includeMood: argument.includeMood,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShareConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShareConfig>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EntryShareConfigProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$entryShareConfigHash() => r'9fb69a7ec4fb92e8944095342c9ba3429f873570';

/// Provider for share configuration of an entry

final class EntryShareConfigFamily extends $Family
    with
        $FunctionalFamilyOverride<
            ShareConfig,
            (
              JournalEntry, {
              List<String>? customHashtags,
              String? messageTemplate,
              bool includeLocation,
              bool includeDate,
              bool includeMood,
            })> {
  const EntryShareConfigFamily._()
      : super(
          retry: null,
          name: r'entryShareConfigProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for share configuration of an entry

  EntryShareConfigProvider call(
    JournalEntry entry, {
    List<String>? customHashtags,
    String? messageTemplate,
    bool includeLocation = true,
    bool includeDate = true,
    bool includeMood = true,
  }) =>
      EntryShareConfigProvider._(argument: (
        entry,
        customHashtags: customHashtags,
        messageTemplate: messageTemplate,
        includeLocation: includeLocation,
        includeDate: includeDate,
        includeMood: includeMood,
      ), from: this);

  @override
  String toString() => r'entryShareConfigProvider';
}

/// Provider for share configuration of a media item

@ProviderFor(mediaShareConfig)
const mediaShareConfigProvider = MediaShareConfigFamily._();

/// Provider for share configuration of a media item

final class MediaShareConfigProvider
    extends $FunctionalProvider<ShareConfig, ShareConfig, ShareConfig>
    with $Provider<ShareConfig> {
  /// Provider for share configuration of a media item
  const MediaShareConfigProvider._(
      {required MediaShareConfigFamily super.from,
      required (
        MediaItem, {
        JournalEntry? entry,
        List<String>? customHashtags,
        String? messageTemplate,
      })
          super.argument})
      : super(
          retry: null,
          name: r'mediaShareConfigProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mediaShareConfigHash();

  @override
  String toString() {
    return r'mediaShareConfigProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<ShareConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ShareConfig create(Ref ref) {
    final argument = this.argument as (
      MediaItem, {
      JournalEntry? entry,
      List<String>? customHashtags,
      String? messageTemplate,
    });
    return mediaShareConfig(
      ref,
      argument.$1,
      entry: argument.entry,
      customHashtags: argument.customHashtags,
      messageTemplate: argument.messageTemplate,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShareConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShareConfig>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MediaShareConfigProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mediaShareConfigHash() => r'f8127bd46c2018495637458b49957db3180e0d85';

/// Provider for share configuration of a media item

final class MediaShareConfigFamily extends $Family
    with
        $FunctionalFamilyOverride<
            ShareConfig,
            (
              MediaItem, {
              JournalEntry? entry,
              List<String>? customHashtags,
              String? messageTemplate,
            })> {
  const MediaShareConfigFamily._()
      : super(
          retry: null,
          name: r'mediaShareConfigProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for share configuration of a media item

  MediaShareConfigProvider call(
    MediaItem media, {
    JournalEntry? entry,
    List<String>? customHashtags,
    String? messageTemplate,
  }) =>
      MediaShareConfigProvider._(argument: (
        media,
        entry: entry,
        customHashtags: customHashtags,
        messageTemplate: messageTemplate,
      ), from: this);

  @override
  String toString() => r'mediaShareConfigProvider';
}

/// Provider for share configuration of a trip

@ProviderFor(tripShareConfig)
const tripShareConfigProvider = TripShareConfigFamily._();

/// Provider for share configuration of a trip

final class TripShareConfigProvider
    extends $FunctionalProvider<ShareConfig, ShareConfig, ShareConfig>
    with $Provider<ShareConfig> {
  /// Provider for share configuration of a trip
  const TripShareConfigProvider._(
      {required TripShareConfigFamily super.from,
      required (
        Trip, {
        int entryCount,
        List<String>? customHashtags,
        String? messageTemplate,
      })
          super.argument})
      : super(
          retry: null,
          name: r'tripShareConfigProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tripShareConfigHash();

  @override
  String toString() {
    return r'tripShareConfigProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<ShareConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ShareConfig create(Ref ref) {
    final argument = this.argument as (
      Trip, {
      int entryCount,
      List<String>? customHashtags,
      String? messageTemplate,
    });
    return tripShareConfig(
      ref,
      argument.$1,
      entryCount: argument.entryCount,
      customHashtags: argument.customHashtags,
      messageTemplate: argument.messageTemplate,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShareConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShareConfig>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TripShareConfigProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripShareConfigHash() => r'42f1d2a06a1de99140393d34637bc11042384282';

/// Provider for share configuration of a trip

final class TripShareConfigFamily extends $Family
    with
        $FunctionalFamilyOverride<
            ShareConfig,
            (
              Trip, {
              int entryCount,
              List<String>? customHashtags,
              String? messageTemplate,
            })> {
  const TripShareConfigFamily._()
      : super(
          retry: null,
          name: r'tripShareConfigProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for share configuration of a trip

  TripShareConfigProvider call(
    Trip trip, {
    int entryCount = 0,
    List<String>? customHashtags,
    String? messageTemplate,
  }) =>
      TripShareConfigProvider._(argument: (
        trip,
        entryCount: entryCount,
        customHashtags: customHashtags,
        messageTemplate: messageTemplate,
      ), from: this);

  @override
  String toString() => r'tripShareConfigProvider';
}

/// Provider for available share platforms

@ProviderFor(availableSharePlatforms)
const availableSharePlatformsProvider = AvailableSharePlatformsProvider._();

/// Provider for available share platforms

final class AvailableSharePlatformsProvider extends $FunctionalProvider<
        AsyncValue<List<SharePlatform>>,
        List<SharePlatform>,
        FutureOr<List<SharePlatform>>>
    with
        $FutureModifier<List<SharePlatform>>,
        $FutureProvider<List<SharePlatform>> {
  /// Provider for available share platforms
  const AvailableSharePlatformsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'availableSharePlatformsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$availableSharePlatformsHash();

  @$internal
  @override
  $FutureProviderElement<List<SharePlatform>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<SharePlatform>> create(Ref ref) {
    return availableSharePlatforms(ref);
  }
}

String _$availableSharePlatformsHash() =>
    r'4e54d9e52f6157c1da61ea4155cafd937d747e4f';
