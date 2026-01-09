// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_service_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for TripRepository
///
/// Manages trip data with offline-first sync support.

@ProviderFor(tripRepository)
final tripRepositoryProvider = TripRepositoryProvider._();

/// Provider for TripRepository
///
/// Manages trip data with offline-first sync support.

final class TripRepositoryProvider
    extends $FunctionalProvider<TripRepository, TripRepository, TripRepository>
    with $Provider<TripRepository> {
  /// Provider for TripRepository
  ///
  /// Manages trip data with offline-first sync support.
  TripRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tripRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tripRepositoryHash();

  @$internal
  @override
  $ProviderElement<TripRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TripRepository create(Ref ref) {
    return tripRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TripRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TripRepository>(value),
    );
  }
}

String _$tripRepositoryHash() => r'a03a125167a0196883b5fe2bf509d76e9a599592';

/// Provider for JournalRepository
///
/// Manages journal entries with offline-first sync support.

@ProviderFor(journalRepository)
final journalRepositoryProvider = JournalRepositoryProvider._();

/// Provider for JournalRepository
///
/// Manages journal entries with offline-first sync support.

final class JournalRepositoryProvider extends $FunctionalProvider<
    JournalRepository,
    JournalRepository,
    JournalRepository> with $Provider<JournalRepository> {
  /// Provider for JournalRepository
  ///
  /// Manages journal entries with offline-first sync support.
  JournalRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'journalRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$journalRepositoryHash();

  @$internal
  @override
  $ProviderElement<JournalRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  JournalRepository create(Ref ref) {
    return journalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JournalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JournalRepository>(value),
    );
  }
}

String _$journalRepositoryHash() => r'5a9e53aa49db5715612bb29c95d1b0d8b05b83a5';

/// Provider for ItineraryRepository
///
/// Manages itinerary data stored in local database.

@ProviderFor(itineraryRepository)
final itineraryRepositoryProvider = ItineraryRepositoryProvider._();

/// Provider for ItineraryRepository
///
/// Manages itinerary data stored in local database.

final class ItineraryRepositoryProvider extends $FunctionalProvider<
    ItineraryRepository,
    ItineraryRepository,
    ItineraryRepository> with $Provider<ItineraryRepository> {
  /// Provider for ItineraryRepository
  ///
  /// Manages itinerary data stored in local database.
  ItineraryRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'itineraryRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$itineraryRepositoryHash();

  @$internal
  @override
  $ProviderElement<ItineraryRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ItineraryRepository create(Ref ref) {
    return itineraryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ItineraryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ItineraryRepository>(value),
    );
  }
}

String _$itineraryRepositoryHash() =>
    r'142c3c7cfee8637a13452293b1144d6f6eb5f27e';

/// Provider for NotificationLocalDataSource
///
/// Handles local storage of notification data.

@ProviderFor(notificationLocalDataSource)
final notificationLocalDataSourceProvider =
    NotificationLocalDataSourceProvider._();

/// Provider for NotificationLocalDataSource
///
/// Handles local storage of notification data.

final class NotificationLocalDataSourceProvider extends $FunctionalProvider<
    NotificationLocalDataSource,
    NotificationLocalDataSource,
    NotificationLocalDataSource> with $Provider<NotificationLocalDataSource> {
  /// Provider for NotificationLocalDataSource
  ///
  /// Handles local storage of notification data.
  NotificationLocalDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationLocalDataSourceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<NotificationLocalDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotificationLocalDataSource create(Ref ref) {
    return notificationLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationLocalDataSource>(value),
    );
  }
}

String _$notificationLocalDataSourceHash() =>
    r'146302acce1dcdc51c2679df0f5444d6d991c5e0';

/// Provider for NotificationRepository
///
/// Manages notification data with connectivity awareness.

@ProviderFor(notificationRepository)
final notificationRepositoryProvider = NotificationRepositoryProvider._();

/// Provider for NotificationRepository
///
/// Manages notification data with connectivity awareness.

final class NotificationRepositoryProvider extends $FunctionalProvider<
    NotificationRepository,
    NotificationRepository,
    NotificationRepository> with $Provider<NotificationRepository> {
  /// Provider for NotificationRepository
  ///
  /// Manages notification data with connectivity awareness.
  NotificationRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotificationRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotificationRepository create(Ref ref) {
    return notificationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationRepository>(value),
    );
  }
}

String _$notificationRepositoryHash() =>
    r'2a3595e41bcf077dadecdba790eca6572cdac08d';

/// Provider for NotificationSchedulerService
///
/// Schedules notifications based on itinerary events.

@ProviderFor(notificationSchedulerService)
final notificationSchedulerServiceProvider =
    NotificationSchedulerServiceProvider._();

/// Provider for NotificationSchedulerService
///
/// Schedules notifications based on itinerary events.

final class NotificationSchedulerServiceProvider extends $FunctionalProvider<
    NotificationSchedulerService,
    NotificationSchedulerService,
    NotificationSchedulerService> with $Provider<NotificationSchedulerService> {
  /// Provider for NotificationSchedulerService
  ///
  /// Schedules notifications based on itinerary events.
  NotificationSchedulerServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationSchedulerServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationSchedulerServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationSchedulerService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotificationSchedulerService create(Ref ref) {
    return notificationSchedulerService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationSchedulerService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationSchedulerService>(value),
    );
  }
}

String _$notificationSchedulerServiceHash() =>
    r'a0c2a196114b68b45a10a091e265fe3af16a1752';

/// Provider for LocationBasedNotificationService
///
/// Triggers notifications based on user location changes.

@ProviderFor(locationBasedNotificationService)
final locationBasedNotificationServiceProvider =
    LocationBasedNotificationServiceProvider._();

/// Provider for LocationBasedNotificationService
///
/// Triggers notifications based on user location changes.

final class LocationBasedNotificationServiceProvider
    extends $FunctionalProvider<LocationBasedNotificationService,
        LocationBasedNotificationService, LocationBasedNotificationService>
    with $Provider<LocationBasedNotificationService> {
  /// Provider for LocationBasedNotificationService
  ///
  /// Triggers notifications based on user location changes.
  LocationBasedNotificationServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'locationBasedNotificationServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$locationBasedNotificationServiceHash();

  @$internal
  @override
  $ProviderElement<LocationBasedNotificationService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocationBasedNotificationService create(Ref ref) {
    return locationBasedNotificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationBasedNotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<LocationBasedNotificationService>(value),
    );
  }
}

String _$locationBasedNotificationServiceHash() =>
    r'87ea6ce93e8471ca0956bcc54049bb5b63afeddb';
