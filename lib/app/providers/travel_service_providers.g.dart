// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_service_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for DioApiService
///
/// Provides the Dio-based API service for network operations.

@ProviderFor(dioApiService)
const dioApiServiceProvider = DioApiServiceProvider._();

/// Provider for DioApiService
///
/// Provides the Dio-based API service for network operations.

final class DioApiServiceProvider
    extends $FunctionalProvider<DioApiService, DioApiService, DioApiService>
    with $Provider<DioApiService> {
  /// Provider for DioApiService
  ///
  /// Provides the Dio-based API service for network operations.
  const DioApiServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dioApiServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dioApiServiceHash();

  @$internal
  @override
  $ProviderElement<DioApiService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DioApiService create(Ref ref) {
    return dioApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DioApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DioApiService>(value),
    );
  }
}

String _$dioApiServiceHash() => r'fa92ae2b59327ec38680bb80f3de3eb127548ad4';

/// Provider for TripRepository
///
/// Manages trip data with offline-first sync support.

@ProviderFor(tripRepository)
const tripRepositoryProvider = TripRepositoryProvider._();

/// Provider for TripRepository
///
/// Manages trip data with offline-first sync support.

final class TripRepositoryProvider
    extends $FunctionalProvider<TripRepository, TripRepository, TripRepository>
    with $Provider<TripRepository> {
  /// Provider for TripRepository
  ///
  /// Manages trip data with offline-first sync support.
  const TripRepositoryProvider._()
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

String _$tripRepositoryHash() => r'b001acb67558869c773d4df8c4adadeeedc3c4c6';

/// Provider for JournalRepository
///
/// Manages journal entries with offline-first sync support.

@ProviderFor(journalRepository)
const journalRepositoryProvider = JournalRepositoryProvider._();

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
  const JournalRepositoryProvider._()
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

String _$journalRepositoryHash() => r'683a3dda6a001627ad4e3046d6d7e46896f5095b';

/// Provider for ItineraryRepository
///
/// Manages itinerary data stored in local database.

@ProviderFor(itineraryRepository)
const itineraryRepositoryProvider = ItineraryRepositoryProvider._();

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
  const ItineraryRepositoryProvider._()
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
const notificationLocalDataSourceProvider =
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
  const NotificationLocalDataSourceProvider._()
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
const notificationRepositoryProvider = NotificationRepositoryProvider._();

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
  const NotificationRepositoryProvider._()
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
    r'c2db6fcd62b4be4e6fded14d5254d75d70276958';

/// Provider for NotificationSchedulerService
///
/// Schedules notifications based on itinerary events.

@ProviderFor(notificationSchedulerService)
const notificationSchedulerServiceProvider =
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
  const NotificationSchedulerServiceProvider._()
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
    r'5a2ea75af2d1a3c082ed55eed5b183b4b6cc69ff';

/// Provider for LocationBasedNotificationService
///
/// Triggers notifications based on user location changes.

@ProviderFor(locationBasedNotificationService)
const locationBasedNotificationServiceProvider =
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
  const LocationBasedNotificationServiceProvider._()
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
    r'09c0aa535d9a1488321629ba38137bc4fcfa1b2c';
