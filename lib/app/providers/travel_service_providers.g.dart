// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_service_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dioApiServiceHash() => r'fa92ae2b59327ec38680bb80f3de3eb127548ad4';

/// Provider for DioApiService
///
/// Provides the Dio-based API service for network operations.
///
/// Copied from [dioApiService].
@ProviderFor(dioApiService)
final dioApiServiceProvider = Provider<DioApiService>.internal(
  dioApiService,
  name: r'dioApiServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dioApiServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DioApiServiceRef = ProviderRef<DioApiService>;
String _$tripRepositoryHash() => r'b001acb67558869c773d4df8c4adadeeedc3c4c6';

/// Provider for TripRepository
///
/// Manages trip data with offline-first sync support.
///
/// Copied from [tripRepository].
@ProviderFor(tripRepository)
final tripRepositoryProvider = Provider<TripRepository>.internal(
  tripRepository,
  name: r'tripRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tripRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TripRepositoryRef = ProviderRef<TripRepository>;
String _$journalRepositoryHash() => r'683a3dda6a001627ad4e3046d6d7e46896f5095b';

/// Provider for JournalRepository
///
/// Manages journal entries with offline-first sync support.
///
/// Copied from [journalRepository].
@ProviderFor(journalRepository)
final journalRepositoryProvider = Provider<JournalRepository>.internal(
  journalRepository,
  name: r'journalRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$journalRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef JournalRepositoryRef = ProviderRef<JournalRepository>;
String _$itineraryRepositoryHash() =>
    r'142c3c7cfee8637a13452293b1144d6f6eb5f27e';

/// Provider for ItineraryRepository
///
/// Manages itinerary data stored in local database.
///
/// Copied from [itineraryRepository].
@ProviderFor(itineraryRepository)
final itineraryRepositoryProvider = Provider<ItineraryRepository>.internal(
  itineraryRepository,
  name: r'itineraryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$itineraryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ItineraryRepositoryRef = ProviderRef<ItineraryRepository>;
String _$notificationLocalDataSourceHash() =>
    r'146302acce1dcdc51c2679df0f5444d6d991c5e0';

/// Provider for NotificationLocalDataSource
///
/// Handles local storage of notification data.
///
/// Copied from [notificationLocalDataSource].
@ProviderFor(notificationLocalDataSource)
final notificationLocalDataSourceProvider =
    Provider<NotificationLocalDataSource>.internal(
  notificationLocalDataSource,
  name: r'notificationLocalDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationLocalDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationLocalDataSourceRef
    = ProviderRef<NotificationLocalDataSource>;
String _$notificationRepositoryHash() =>
    r'f946fc57ba68f660f82bb7ff0ea60e317513ba9a';

/// Provider for NotificationRepository
///
/// Manages notification data with connectivity awareness.
///
/// Copied from [notificationRepository].
@ProviderFor(notificationRepository)
final notificationRepositoryProvider =
    Provider<NotificationRepository>.internal(
  notificationRepository,
  name: r'notificationRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationRepositoryRef = ProviderRef<NotificationRepository>;
String _$notificationSchedulerServiceHash() =>
    r'5a2ea75af2d1a3c082ed55eed5b183b4b6cc69ff';

/// Provider for NotificationSchedulerService
///
/// Schedules notifications based on itinerary events.
///
/// Copied from [notificationSchedulerService].
@ProviderFor(notificationSchedulerService)
final notificationSchedulerServiceProvider =
    Provider<NotificationSchedulerService>.internal(
  notificationSchedulerService,
  name: r'notificationSchedulerServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationSchedulerServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationSchedulerServiceRef
    = ProviderRef<NotificationSchedulerService>;
String _$locationBasedNotificationServiceHash() =>
    r'09c0aa535d9a1488321629ba38137bc4fcfa1b2c';

/// Provider for LocationBasedNotificationService
///
/// Triggers notifications based on user location changes.
///
/// Copied from [locationBasedNotificationService].
@ProviderFor(locationBasedNotificationService)
final locationBasedNotificationServiceProvider =
    Provider<LocationBasedNotificationService>.internal(
  locationBasedNotificationService,
  name: r'locationBasedNotificationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationBasedNotificationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocationBasedNotificationServiceRef
    = ProviderRef<LocationBasedNotificationService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
