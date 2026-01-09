import 'package:intl/intl.dart';
import 'package:soloadventurer/features/notifications/domain/entities/notification_preferences.dart';
import 'package:soloadventurer/features/notifications/domain/entities/travel_notification.dart';
import 'package:soloadventurer/features/notifications/domain/repositories/notification_repository.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary_item.dart';
import 'package:soloadventurer/features/travel/domain/repositories/itinerary_repository.dart';
import 'package:uuid/uuid.dart';

/// Service for scheduling notifications based on itinerary items
///
/// Automatically schedules relevant notifications for flights,
/// accommodations, activities, and daily briefings.
class NotificationSchedulerService {
  final NotificationRepository _notificationRepository;
  final ItineraryRepository _itineraryRepository;
  final Uuid _uuid = const Uuid();

  NotificationSchedulerService(
    this._notificationRepository,
    this._itineraryRepository,
  );

  /// Schedule all notifications for an itinerary
  Future<void> scheduleItineraryNotifications(String itineraryId) async {
    final itineraryResult =
        await _itineraryRepository.getItinerary(itineraryId);

    final itinerary = itineraryResult.fold(
      (failure) {
        // Log error
        print('Failed to get itinerary: $failure');
        return null;
      },
      (itinerary) => itinerary,
    );

    if (itinerary == null) {
      return;
    }

    // Get preferences
    final prefs = await _notificationRepository.getPreferences();

    // Schedule different types of notifications
    await _scheduleFlightNotifications(itinerary, prefs);
    await _scheduleAccommodationNotifications(itinerary, prefs);
    await _scheduleActivityReminders(itinerary, prefs);
    await _scheduleDailyBriefings(itinerary, prefs);
  }

  /// Cancel all notifications for an itinerary
  Future<void> cancelItineraryNotifications(String itineraryId) async {
    await _notificationRepository.cancelItineraryNotifications(itineraryId);
  }

  /// Schedule flight-related notifications
  Future<void> _scheduleFlightNotifications(
    Itinerary itinerary,
    NotificationPreferences prefs,
  ) async {
    if (!prefs.flightNotificationsEnabled) {
      return;
    }

    // Filter for flight arrival and departure items using map and checking for null
    final flights = itinerary.items.where((item) {
      final flightData = item.map(
        flightArrival: (data) => _FlightData(
          id: data.id,
          scheduledTime: data.time,
          flightNumber: data.flightNumber ?? 'Unknown',
          airport: data.airportCode ?? 'Unknown',
        ),
        flightDeparture: (data) => _FlightData(
          id: data.id,
          scheduledTime: data.time,
          flightNumber: data.flightNumber ?? 'Unknown',
          airport: data.airportCode ?? 'Unknown',
        ),
        hotelCheckIn: (_) => null,
        hotelCheckOut: (_) => null,
        activity: (_) => null,
        lunch: (_) => null,
        dinner: (_) => null,
      );
      return flightData != null;
    }).toList();

    for (final flight in flights) {
      // Extract flight details using pattern matching
      final flightData = flight.map(
        flightArrival: (data) => _FlightData(
          id: data.id,
          scheduledTime: data.time,
          flightNumber: data.flightNumber ?? 'Unknown',
          airport: data.airportCode ?? 'Unknown',
        ),
        flightDeparture: (data) => _FlightData(
          id: data.id,
          scheduledTime: data.time,
          flightNumber: data.flightNumber ?? 'Unknown',
          airport: data.airportCode ?? 'Unknown',
        ),
        hotelCheckIn: (_) => null,
        hotelCheckOut: (_) => null,
        activity: (_) => null,
        lunch: (_) => null,
        dinner: (_) => null,
      );

      if (flightData == null) continue;

      // Check-in reminder (24 hours before)
      if (prefs.flightCheckInReminders) {
        final checkInTime =
            flightData.scheduledTime.subtract(const Duration(hours: 24));
        if (checkInTime.isAfter(DateTime.now())) {
          await _notificationRepository.schedule(
            TravelNotification(
              id: _uuid.v4(),
              type: NotificationType.flightCheckInAvailable,
              category: NotificationCategory.flight,
              title: '✈️ Flight Check-In Available',
              body:
                  'Your flight ${flightData.flightNumber} to ${flightData.airport} '
                  'departs tomorrow at ${DateFormat.Hm().format(flightData.scheduledTime)}. '
                  'Check in now to select your seat.',
              scheduledAt: checkInTime,
              priority: NotificationPriority.high,
              isActionable: true,
              actions: [
                NotificationAction(
                  id: 'check_in',
                  label: 'Check In',
                  type: NotificationActionType.deepLink,
                  deepLink: 'soloadventurer://checkin/${flightData.id}',
                ),
              ],
              data: {
                'flightId': flightData.id,
                'itineraryId': itinerary.id,
                'flightNumber': flightData.flightNumber,
              },
            ),
          );
        }
      }

      // Boarding reminder (1 hour before)
      if (prefs.flightGateChanges) {
        final boardingTime =
            flightData.scheduledTime.subtract(const Duration(hours: 1));
        if (boardingTime.isAfter(DateTime.now())) {
          await _notificationRepository.schedule(
            TravelNotification(
              id: _uuid.v4(),
              type: NotificationType.flightBoarding,
              category: NotificationCategory.flight,
              title: '✈️ Boarding Soon',
              body: 'Your flight ${flightData.flightNumber} boards in 1 hour. '
                  'Gate: Check at airport',
              scheduledAt: boardingTime,
              priority: NotificationPriority.high,
              data: {
                'flightId': flightData.id,
                'itineraryId': itinerary.id,
              },
            ),
          );
        }
      }
    }
  }

  /// Schedule accommodation notifications
  Future<void> _scheduleAccommodationNotifications(
    Itinerary itinerary,
    NotificationPreferences prefs,
  ) async {
    if (!prefs.bookingConfirmations && !prefs.checkInReminders) {
      return;
    }

    for (final item in itinerary.items) {
      // Handle hotel check-in notifications
      if (item
          case ItineraryItemHotelCheckIn(
            :final id,
            :final time,
            hotelName: final hotelName,
          )) {
        if (prefs.checkInReminders) {
          final reminderTime = DateTime(
            time.year,
            time.month,
            time.day,
            9, // 9 AM on day of check-in
          );

          if (reminderTime.isAfter(DateTime.now())) {
            await _notificationRepository.schedule(
              TravelNotification(
                id: _uuid.v4(),
                type: NotificationType.hotelCheckInReminder,
                category: NotificationCategory.accommodation,
                title: '🏨 Hotel Check-In Reminder',
                body: 'Your check-in at ${hotelName ?? "your hotel"} is today. '
                    'Remember to bring your confirmation and ID.',
                scheduledAt: reminderTime,
                priority: NotificationPriority.normal,
                data: {
                  'accommodationId': id,
                  'itineraryId': itinerary.id,
                  'hotelName': hotelName ?? '',
                },
              ),
            );
          }
        }
      }

      // Handle hotel check-out notifications
      if (item
          case ItineraryItemHotelCheckOut(
            :final id,
            :final time,
            hotelName: final hotelName,
          )) {
        if (prefs.reservationReminders) {
          final reminderTime = DateTime(
            time.year,
            time.month,
            time.day,
            8, // 8 AM on day of check-out
          );

          if (reminderTime.isAfter(DateTime.now())) {
            await _notificationRepository.schedule(
              TravelNotification(
                id: _uuid.v4(),
                type: NotificationType.hotelCheckOutReminder,
                category: NotificationCategory.accommodation,
                title: '🏨 Check-Out Reminder',
                body: 'Check-out from ${hotelName ?? "your hotel"} is today. '
                    'Don\'t forget to pack everything!',
                scheduledAt: reminderTime,
                priority: NotificationPriority.normal,
                data: {
                  'accommodationId': id,
                  'itineraryId': itinerary.id,
                },
              ),
            );
          }
        }
      }
    }
  }

  /// Schedule activity and reservation reminders
  Future<void> _scheduleActivityReminders(
    Itinerary itinerary,
    NotificationPreferences prefs,
  ) async {
    if (!prefs.reservationReminders) {
      return;
    }

    for (final item in itinerary.items) {
      // Handle activity reminders
      if (item
          case ItineraryItemActivity(
            :final id,
            :final time,
            :final name,
            bookingUrl: final bookingUrl,
            durationHours: final durationHours,
          )) {
        // Only schedule for activities with booking URLs
        if (bookingUrl == null) {
          continue;
        }

        // Reminder 24 hours before
        final reminderTime = time.subtract(const Duration(hours: 24));

        if (reminderTime.isAfter(DateTime.now())) {
          await _notificationRepository.schedule(
            TravelNotification(
              id: _uuid.v4(),
              type: NotificationType.reservationReminder,
              category: NotificationCategory.activity,
              title: '🎫 Don\'t Forget: $name',
              body: 'Your visit to $name is tomorrow. '
                  'Book tickets in advance!'
                  '${durationHours != null ? " Estimated duration: ${durationHours}h" : ""}',
              scheduledAt: reminderTime,
              priority: NotificationPriority.high,
              isActionable: true,
              actions: [
                NotificationAction(
                  id: 'book',
                  label: 'Book Now',
                  type: NotificationActionType.deepLink,
                  deepLink: bookingUrl,
                ),
              ],
              data: {
                'activityId': id,
                'itineraryId': itinerary.id,
              },
            ),
          );
        }
      }

      // Handle restaurant reminders (lunch)
      if (item
          case ItineraryItemLunch(
            :final id,
            :final time,
            :final name,
          )) {
        // Reservation reminder 24 hours before
        final reminderTime = time.subtract(const Duration(hours: 24));

        if (reminderTime.isAfter(DateTime.now())) {
          await _notificationRepository.schedule(
            TravelNotification(
              id: _uuid.v4(),
              type: NotificationType.reservationReminder,
              category: NotificationCategory.activity,
              title: '🍽️ Reservation Reminder: $name',
              body: 'You have a reservation at $name tomorrow '
                  'at ${DateFormat.Hm().format(time)}.',
              scheduledAt: reminderTime,
              priority: NotificationPriority.normal,
              data: {
                'restaurantId': id,
                'itineraryId': itinerary.id,
              },
            ),
          );
        }
      }

      // Handle restaurant reminders (dinner)
      if (item
          case ItineraryItemDinner(
            :final id,
            :final time,
            :final name,
          )) {
        // Reservation reminder 24 hours before
        final reminderTime = time.subtract(const Duration(hours: 24));

        if (reminderTime.isAfter(DateTime.now())) {
          await _notificationRepository.schedule(
            TravelNotification(
              id: _uuid.v4(),
              type: NotificationType.reservationReminder,
              category: NotificationCategory.activity,
              title: '🍽️ Reservation Reminder: $name',
              body: 'You have a reservation at $name tomorrow '
                  'at ${DateFormat.Hm().format(time)}.',
              scheduledAt: reminderTime,
              priority: NotificationPriority.normal,
              data: {
                'restaurantId': id,
                'itineraryId': itinerary.id,
              },
            ),
          );
        }
      }
    }
  }

  /// Schedule daily trip briefings
  Future<void> _scheduleDailyBriefings(
    Itinerary itinerary,
    NotificationPreferences prefs,
  ) async {
    if (!prefs.dailyWeatherSummary) {
      return;
    }

    // Schedule daily trip summary at 6 AM
    for (int i = 0; i < itinerary.numberOfDays; i++) {
      final date = itinerary.dateRange.start.add(Duration(days: i));
      final briefingTime = DateTime(date.year, date.month, date.day, 6);

      // Don't schedule if time has passed
      if (briefingTime.isBefore(DateTime.now())) {
        continue;
      }

      final itemsForDay = itinerary.getItemsForDay(i + 1);
      final activityCount = itemsForDay.where((item) {
        return switch (item) {
          ItineraryItemActivity() => true,
          ItineraryItemLunch() => true,
          ItineraryItemDinner() => true,
          _ => false,
        };
      }).length;

      await _notificationRepository.schedule(
        TravelNotification(
          id: _uuid.v4(),
          type: NotificationType.dailyBriefing,
          category: NotificationCategory.trip,
          title: '📅 Your ${itinerary.destination.name} Day ${i + 1}',
          body: 'Good morning! You have $activityCount activities planned '
              'for today in ${itinerary.destination.name}.',
          scheduledAt: briefingTime,
          priority: NotificationPriority.low,
          isActionable: true,
          actions: [
            NotificationAction(
              id: 'view_itinerary',
              label: 'View Itinerary',
              type: NotificationActionType.deepLink,
              deepLink:
                  'soloadventurer://itinerary/${itinerary.id}?date=${date.toIso8601String()}',
            ),
          ],
          data: {
            'itineraryId': itinerary.id,
            'date': date.toIso8601String(),
            'day': i + 1,
          },
        ),
      );
    }
  }

  /// Schedule a weather alert notification
  Future<void> scheduleWeatherAlert({
    required String itineraryId,
    required DateTime date,
    required String condition,
    required String description,
    required NotificationPriority priority,
  }) async {
    final itineraryResult =
        await _itineraryRepository.getItinerary(itineraryId);

    final itinerary = itineraryResult.fold(
      (failure) {
        // Log error - weather alert could not be tied to itinerary
        print('Failed to get itinerary for weather alert: $failure');
        return null;
      },
      (itinerary) => itinerary,
    );

    if (itinerary == null) {
      return;
    }

    await _notificationRepository.schedule(
      TravelNotification(
        id: _uuid.v4(),
        type: priority == NotificationPriority.urgent
            ? NotificationType.severeWeatherWarning
            : NotificationType.weatherAlert,
        category: NotificationCategory.weather,
        title: '🌤️ $condition',
        body:
            'Weather alert for ${DateFormat.MMMd().format(date)}: $description',
        scheduledAt: DateTime.now(),
        priority: priority,
        data: {
          'itineraryId': itineraryId,
          'date': date.toIso8601String(),
          'condition': condition,
        },
      ),
    );
  }

  /// Schedule a safety alert notification
  Future<void> scheduleSafetyAlert({
    required String itineraryId,
    required String title,
    required String message,
    required NotificationPriority priority,
  }) async {
    await _notificationRepository.schedule(
      TravelNotification(
        id: _uuid.v4(),
        type: NotificationType.safetyAlert,
        category: NotificationCategory.safety,
        title: '🛡️ $title',
        body: message,
        scheduledAt: DateTime.now(),
        priority: priority,
        isActionable: true,
        actions: [
          const NotificationAction(
            id: 'acknowledge',
            label: 'Acknowledge',
            type: NotificationActionType.acknowledge,
          ),
        ],
        data: {
          'itineraryId': itineraryId,
        },
      ),
    );
  }
}

/// Helper class for flight data extraction
class _FlightData {
  final String id;
  final DateTime scheduledTime;
  final String flightNumber;
  final String airport;

  const _FlightData({
    required this.id,
    required this.scheduledTime,
    required this.flightNumber,
    required this.airport,
  });
}
