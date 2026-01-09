import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/core/services/location_service_impl.dart';
import 'package:soloadventurer/features/notifications/data/datasources/notification_local_data_source.dart';
import 'package:soloadventurer/features/notifications/data/datasources/notification_local_data_source_impl.dart';
import 'package:soloadventurer/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:soloadventurer/features/notifications/data/services/location_based_notification_service.dart';
import 'package:soloadventurer/features/notifications/data/services/notification_scheduler_service.dart';
import 'package:soloadventurer/features/notifications/domain/repositories/notification_repository.dart';
import 'package:soloadventurer/features/travel/domain/repositories/itinerary_repository.dart';
import 'package:soloadventurer/features/travel/domain/repositories/journal_repository.dart';
import 'package:soloadventurer/features/travel/domain/repositories/trip_repository.dart';
import 'package:soloadventurer/features/travel/data/repositories/itinerary_repository_impl.dart';
import 'package:soloadventurer/features/travel/infrastructure/repositories/journal_repository_impl.dart';
import 'package:soloadventurer/features/travel/infrastructure/repositories/trip_repository_impl.dart';
import 'package:soloadventurer/core/providers/api_providers.dart';
import 'package:soloadventurer/app/providers/core_service_providers.dart';
import 'package:soloadventurer/app/providers/offline_service_providers.dart';

part 'travel_service_providers.g.dart';

// ============================================================================
// Travel Repositories
// ============================================================================

/// Provider for TripRepository
///
/// Manages trip data with offline-first sync support.
@Riverpod(keepAlive: true)
TripRepository tripRepository(Ref ref) {
  final tripDao = ref.watch(tripDaoProvider);
  final dio = ref.watch(dioProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  final syncQueueService = ref.watch(syncQueueServiceProvider);
  return TripRepositoryImpl(
    tripDao: tripDao,
    apiService: dio,
    connectivityService: connectivityService,
    syncQueueService: syncQueueService,
  );
}

/// Provider for JournalRepository
///
/// Manages journal entries with offline-first sync support.
@Riverpod(keepAlive: true)
JournalRepository journalRepository(Ref ref) {
  final journalDao = ref.watch(journalDaoProvider);
  final dio = ref.watch(dioProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  final syncQueueService = ref.watch(syncQueueServiceProvider);
  return JournalRepositoryImpl(
    journalDao: journalDao,
    apiService: dio,
    connectivityService: connectivityService,
    syncQueueService: syncQueueService,
  );
}

/// Provider for ItineraryRepository
///
/// Manages itinerary data stored in local database.
@Riverpod(keepAlive: true)
ItineraryRepository itineraryRepository(Ref ref) {
  final itineraryDao = ref.watch(itineraryDaoProvider);
  final database = ref.watch(databaseServiceProvider).database;
  return ItineraryRepositoryImpl(
    dao: itineraryDao,
    database: database,
  );
}

// ============================================================================
// Notification Services
// ============================================================================

/// Provider for NotificationLocalDataSource
///
/// Handles local storage of notification data.
@Riverpod(keepAlive: true)
NotificationLocalDataSource notificationLocalDataSource(Ref ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return NotificationLocalDataSourceImpl(sharedPreferences);
}

/// Provider for NotificationRepository
///
/// Manages notification data with connectivity awareness.
@Riverpod(keepAlive: true)
NotificationRepository notificationRepository(Ref ref) {
  final localDataSource = ref.watch(notificationLocalDataSourceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  return NotificationRepositoryImpl(
    localDataSource: localDataSource,
    connectivityService: connectivityService,
  );
}

/// Provider for NotificationSchedulerService
///
/// Schedules notifications based on itinerary events.
@Riverpod(keepAlive: true)
NotificationSchedulerService notificationSchedulerService(Ref ref) {
  final notificationRepository = ref.watch(notificationRepositoryProvider);
  final itineraryRepository = ref.watch(itineraryRepositoryProvider);
  return NotificationSchedulerService(
    notificationRepository: notificationRepository,
    itineraryRepository: itineraryRepository,
  );
}

/// Provider for LocationBasedNotificationService
///
/// Triggers notifications based on user location changes.
@Riverpod(keepAlive: true)
LocationBasedNotificationService locationBasedNotificationService(Ref ref) {
  final notificationRepository = ref.watch(notificationRepositoryProvider);
  final locationService = ref.watch(locationServiceImplProvider);
  return LocationBasedNotificationService(
    notificationRepository: notificationRepository,
    locationService: locationService,
  );
}
