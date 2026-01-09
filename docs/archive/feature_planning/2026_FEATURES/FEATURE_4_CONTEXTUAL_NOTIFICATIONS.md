# Feature 4: Contextual Safety & Travel Notifications

**Phase:** Phase 1 - Smart Engagement & Personalization
**Time:** 2 weeks
**Dependencies:** Feature 1 (Onboarding), Feature 2 (Itinerary Planner)
**Priority:** 🔥 High

---

## Overview

**The Core Value:** Deliver only useful, actionable notifications that matter for the traveler's trip - never spam. Notifications should feel like a helpful travel assistant, not a marketing channel.

**Why This Works:**
- **Context-aware**: Alerts based on user's actual itinerary (flight times, destinations, dates)
- **Time-sensitive**: Check-in reminders, delay alerts, gate changes
- **Location-aware**: Weather warnings, safety alerts, local deals near user
- **Respectful**: Easy to opt-out, granular preferences, never spam

**Key Philosophy:** "Add value or don't ping"

**Success Metric:** 60%+ notification open rate, <5% opt-out rate

---

## UI Wireframes

### Notification Preferences Screen

```
+------------------------------------------------+
|  ← Notification Settings                       |
+------------------------------------------------+
|                                                |
|  Control what notifications you receive        |
|                                                |
|  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      |
|                                                |
|  ✈️ Trip Notifications (Recommended ON)        |
|                                                |
|  ☑ Flight check-in reminders (24h before)      |
|  ☑ Flight delays & gate changes                |
|  ☑ Hotel booking confirmations                 |
|  ☑ Reservation reminders (24h before)          |
|                                                |
|  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      |
|                                                |
|  🌤️ Weather Alerts (Recommended ON)            |
|                                                |
|  ☑ Severe weather warnings                     |
|  ☑ Daily weather summary (7am each day)        |
|  ☐ Rain alerts for outdoor activities          |
|                                                |
|  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      |
|                                                |
|  🛡️ Safety Alerts (Always ON)                  |
|                                                |
|  ☑ Destination safety updates                  |
|  ☑ Travel advisories                           |
|  ☑ Emergency alerts                            |
|                                                |
|  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      |
|                                                |
|  📍 Local Recommendations (Optional)           |
|                                                |
|  ☐ Nearby deals & offers                       |
|  ☐ Events happening near you                   |
|  ☐ Restaurant suggestions                      |
|                                                |
|  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      |
|                                                |
|  📱 Notification Style                         |
|                                                |
|  Quiet Hours:                                  |
|  [10:00 PM] - [7:00 AM]                        |
|                                                |
|  ☑ Vibrate                                     |
|  ☑ Sound                                       |
|  ☐ Bypass Do Not Disturb                       |
|                                                |
+------------------------------------------------+
```

### Notification Examples

```
┌──────────────────────────────────────────────┐
│ ✈️ Flight Check-In Available!                │
│                                              │
│ Your AirFrance flight AF123 to Paris         │
│ departs tomorrow at 08:30                    │
│                                              │
│ Check in now to select your seat             │
│                                              │
│              [Check In Now]  [Later]          │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│ ⚠️ Flight Delayed                            │
│                                              │
│ AF123: Paris → CDG                           │
│ New departure: 10:15 AM (was 08:30)          │
│ Gate changed: K42 → K55                      │
│                                              │
│              [View Details]                   │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│ 🌧️ Weather Alert: Rain Expected             │
│                                              │
| Tomorrow (May 12) in Paris:                  │
| • 80% chance of rain                         │
│ • High of 16°C, low of 10°C                  │
│                                              │
│ 2 outdoor activities in your itinerary       │
│ may be affected.                             │
│                                              │
│    [View Indoor Alternatives]  [Dismiss]     │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│ 🛡️ Safety Alert: Paris                      │
│                                              │
| Travel advisory issued for your destination: │
│                                              │
| • Public transport strike scheduled          │
│   for May 15-16                              │
│ • Allow extra travel time                    │
│ • Consider alternative routes                 │
│                                              │
│              [View Details]  [Acknowledge]   │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│ 💡 Don't Forget: Louvre Tickets              │
│                                              │
│ Your visit to the Louvre is tomorrow:        │
│                                              │
│ ⚠️ Book tickets in advance to skip line!     │
│ • Tickets available online                   │
│ • Estimated wait without tickets: 2+ hours   │
│ • Recommended time: Morning (less crowded)   │
│                                              │
│           [Book Now]  [Already Booked]       │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│ 📍 Restaurant Near You                       │
│                                              │
| Le Comptoir du 7ème is 200m away             │
│ • Highly rated by locals                     │
│ • Open now • Serves dinner until 10 PM       │
│ • Special: Duck confit tonight               │
│                                              │
│              [Get Directions]  [Not Now]      │
└──────────────────────────────────────────────┘
```

### Notification History Screen

```
+------------------------------------------------+
|  ← Notification History            [Clear All]  |
+------------------------------------------------+
|                                                |
|  Today (5 notifications)                        |
|  ──────────────────────────────────────────    |
|  ✈️ 10:30 AM  Flight check-in available       |
|  🌧️ 7:00 AM   Weather alert: Rain expected    |
|  📅 6:00 AM   Daily trip summary               |
|                                                |
|  Yesterday (3 notifications)                   |
|  ──────────────────────────────────────────    |
|  💡 6:00 PM   Reminder: Book museum tickets     |
|  ✈️ 8:30 AM   Flight confirmation received     |
|                                                |
|  May 10 (2 notifications)                      |
|  ──────────────────────────────────────────    |
|  🏨 2:00 PM   Hotel booking confirmed          |
|  ✈️ 10:00 AM  Flight booked successfully      |
|                                                |
+------------------------------------------------+
```

---

## Architecture

### Domain Layer

```dart
// lib/features/notifications/domain/entities/travel_notification.dart
@freezed
class TravelNotification with _$TravelNotification {
  const factory TravelNotification({
    required String id,
    required NotificationType type,
    required NotificationCategory category,
    required String title,
    required String body,
    required DateTime scheduledAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    DateTime? dismissedAt,
    @Default(NotificationPriority.normal) NotificationPriority priority,
    Map<String, dynamic>? data,
    @Default(false) bool isActionable,
    List<NotificationAction>? actions,
    String? imageUrl,
    @Default(false) bool isOngoing,
  }) = _TravelNotification;

  const TravelNotification._();

  bool get isRead => readAt != null;
  bool get isDelivered => deliveredAt != null;
  bool get isDismissed => dismissedAt != null;
}

enum NotificationType {
  // Flight notifications
  flightCheckInAvailable,
  flightDelayed,
  flightCancelled,
  flightGateChange,
  flightBoarding,
  flightLanded,

  // Accommodation notifications
  hotelBookingConfirmed,
  hotelCheckInReminder,
  hotelCheckOutReminder,

  // Activity notifications
  reservationReminder,
  activityBookingReminder,
  ticketReminder,

  // Weather notifications
  weatherAlert,
  weatherSummary,
  severeWeatherWarning,

  // Safety notifications
  safetyAlert,
  travelAdvisory,
  emergencyAlert,

  // Recommendation notifications
  nearbyRecommendation,
  localDeal,
  eventSuggestion,

  // Trip notifications
  tripSummary,
  itineraryUpdate,
  dailyBriefing,
}

enum NotificationCategory {
  flight,
  accommodation,
  activity,
  weather,
  safety,
  recommendation,
  trip,
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

@freezed
class NotificationAction with _$NotificationAction {
  const factory NotificationAction({
    required String id,
    required String label,
    required NotificationActionType type,
    String? deepLink,
    Map<String, dynamic>? metadata,
  }) = _NotificationAction;
}

enum NotificationActionType {
  deepLink,
  dismiss,
  snooze,
  acknowledge,
  custom,
}

// lib/features/notifications/domain/entities/notification_preferences.dart
@freezed
class NotificationPreferences with _$NotificationPreferences {
  const factory NotificationPreferences({
    // Flight notifications
    @Default(true) bool flightCheckInReminders,
    @Default(true) bool flightDelaysAndCancellations,
    @Default(true) bool flightGateChanges,

    // Accommodation notifications
    @Default(true) bool bookingConfirmations,
    @Default(true) bool checkInReminders,
    @Default(true) bool reservationReminders,

    // Weather notifications
    @Default(true) bool severeWeatherAlerts,
    @Default(true) bool dailyWeatherSummary,
    @Default(false) bool rainAlertsForOutdoorActivities,

    // Safety notifications
    @Default(true) bool safetyAlerts,
    @Default(true) bool travelAdvisories,
    @Default(true) bool emergencyAlerts,

    // Recommendation notifications
    @Default(false) bool nearbyDeals,
    @Default(false) bool localEventSuggestions,
    @Default(false) bool restaurantRecommendations,

    // Notification style
    @Default(true) bool vibrateEnabled,
    @Default(true) bool soundEnabled,
    @Default(false) bool bypassDoNotDisturb,

    // Quiet hours
    @Default(TimeOfDay(hour: 22, minute: 0)) TimeOfDay quietHoursStart,
    @Default(TimeOfDay(hour: 7, minute: 0)) TimeOfDay quietHoursEnd,
  }) = _NotificationPreferences;

  const NotificationPreferences._();

  bool isQuietTime(DateTime now) {
    final current = TimeOfDay(hour: now.hour, minute: now.minute);
    return quietHoursStart.isAfter(current) ||
           quietHoursEnd.isBefore(current);
  }
}

// lib/features/notifications/domain/usecases/
class ScheduleNotification {
  final NotificationRepository _repository;

  ScheduleNotification(this._repository);

  Future<Either<Failure, Unit>> call(TravelNotification notification) async {
    return await _repository.schedule(notification);
  }
}

class SendNotificationNow {
  final NotificationRepository _repository;

  SendNotificationNow(this._repository);

  Future<Either<Failure, Unit>> call(TravelNotification notification) async {
    return await _repository.sendNow(notification);
  }
}

class DismissNotification {
  final NotificationRepository _repository;

  DismissNotification(this._repository);

  Future<Either<Failure, Unit>> call(String notificationId) async {
    return await _repository.dismiss(notificationId);
  }
}

class MarkNotificationRead {
  final NotificationRepository _repository;

  MarkNotificationRead(this._repository);

  Future<Either<Failure, Unit>> call(String notificationId) async {
    return await _repository.markAsRead(notificationId);
  }
}

class UpdateNotificationPreferences {
  final NotificationRepository _repository;

  UpdateNotificationPreferences(this._repository);

  Future<Either<Failure, Unit>> call(
    NotificationPreferences preferences,
  ) async {
    return await _repository.updatePreferences(preferences);
  }
}

class GetNotificationHistory {
  final NotificationRepository _repository;

  GetNotificationHistory(this._repository);

  Future<Either<Failure, List<TravelNotification>>> call({
    DateTime? startDate,
    DateTime? endDate,
    NotificationCategory? category,
  }) async {
    return await _repository.getHistory(
      startDate: startDate,
      endDate: endDate,
      category: category,
    );
  }
}
```

### Data Layer - Services

```dart
// lib/features/notifications/data/services/notification_scheduler.dart
class NotificationScheduler {
  final NotificationRepository _repository;
  final FlightTrackingService _flightService;
  final WeatherService _weatherService;
  final ItineraryRepository _itineraryRepo;
  final NotificationPreferences _preferences;

  NotificationScheduler({
    required NotificationRepository repository,
    required FlightTrackingService flightService,
    required WeatherService weatherService,
    required ItineraryRepository itineraryRepo,
    required NotificationPreferences preferences,
  })  : _repository = repository,
        _flightService = flightService,
        _weatherService = weatherService,
        _itineraryRepo = itineraryRepo,
        _preferences = preferences;

  /// Schedule all notifications for an itinerary
  Future<void> scheduleItineraryNotifications(String itineraryId) async {
    final itineraryResult = await _itineraryRepo.getItinerary(itineraryId);

    await itineraryResult.fold(
      (failure) async {},
      (itinerary) async {
        // Schedule flight notifications
        await _scheduleFlightNotifications(itinerary);

        // Schedule accommodation notifications
        await _scheduleAccommodationNotifications(itinerary);

        // Schedule activity reminders
        await _scheduleActivityReminders(itinerary);

        // Schedule weather alerts
        await _scheduleWeatherAlerts(itinerary);

        // Schedule daily briefings
        await _scheduleDailyBriefings(itinerary);
      },
    );
  }

  Future<void> _scheduleFlightNotifications(Itinerary itinerary) async {
    if (!_preferences.flightCheckInReminders &&
        !_preferences.flightDelaysAndCancellations) {
      return;
    }

    final flights = itinerary.items
        .whereType<ItineraryItemFlight>()
        .toList();

    for (final flight in flights) {
      // Check-in reminder (24 hours before)
      if (_preferences.flightCheckInReminders) {
        final checkInTime = flight.scheduledAt.subtract(Duration(hours: 24));
        await _repository.schedule(
          TravelNotification(
            id: uuid.v4(),
            type: NotificationType.flightCheckInAvailable,
            category: NotificationCategory.flight,
            title: 'Flight Check-In Available',
            body: 'Your ${flight.airline} ${flight.flightNumber} flight '
                  'departs tomorrow at ${DateFormat.Hm().format(flight.scheduledAt)}. '
                  'Check in now to select your seat.',
            scheduledAt: checkInTime,
            priority: NotificationPriority.high,
            isActionable: true,
            actions: [
              NotificationAction(
                id: 'check_in',
                label: 'Check In',
                type: NotificationActionType.deepLink,
                deepLink: 'soloadventurer://checkin/${flight.id}',
              ),
            ],
            data: {'flightId': flight.id, 'itineraryId': itinerary.id},
          ),
        );
      }

      // Set up monitoring for delays/cancellations
      if (_preferences.flightDelaysAndCancellations) {
        await _flightService.monitorFlight(
          flightId: flight.id,
          flightNumber: flight.flightNumber,
          date: flight.scheduledAt,
          onDelay: (delay) => _sendFlightDelayNotification(flight, delay),
          onCancellation: () => _sendFlightCancellationNotification(flight),
          onGateChange: (gate) => _sendGateChangeNotification(flight, gate),
        );
      }
    }
  }

  Future<void> _scheduleAccommodationNotifications(Itinerary itinerary) async {
    if (!_preferences.bookingConfirmations &&
        !_preferences.checkInReminders) {
      return;
    }

    final accommodations = itinerary.items
        .where((item) => item.maybeWhen(
          accommodation: (_) => true,
          orElse: () => false,
        ))
        .toList();

    for (final accommodation in accommodations) {
      accommodation.maybeWhen(
        accommodation: (acc) async {
          if (acc.type == AccommodationType.checkIn) {
            // Check-in reminder (day of arrival, morning)
            if (_preferences.checkInReminders) {
              final reminderTime = DateTime(
                acc.scheduledAt.year,
                acc.scheduledAt.month,
                acc.scheduledAt.day,
                9, // 9 AM on day of check-in
              );

              await _repository.schedule(
                TravelNotification(
                  id: uuid.v4(),
                  type: NotificationType.hotelCheckInReminder,
                  category: NotificationCategory.accommodation,
                  title: 'Hotel Check-In Reminder',
                  body: 'Your check-in at ${acc.name} is today. '
                        'Remember to bring your confirmation and ID.',
                  scheduledAt: reminderTime,
                  priority: NotificationPriority.normal,
                  data: {
                    'accommodationId': acc.id,
                    'itineraryId': itinerary.id,
                    'hotelName': acc.name,
                  },
                ),
              );
            }
          }
        },
        orElse: () {},
      );
    }
  }

  Future<void> _scheduleActivityReminders(Itinerary itinerary) async {
    if (!_preferences.reservationReminders) {
      return;
    }

    final activities = itinerary.items.where((item) {
      return item.maybeWhen(
        activity: (activity) =>
            activity.requiresAdvanceBooking || activity.bookingUrl != null,
        orElse: () => false,
      );
    }).toList();

    for (final activityItem in activities) {
      activityItem.maybeWhen(
        activity: (activity) async {
          // Reminder 24 hours before
          final reminderTime = activity.scheduledAt.subtract(Duration(hours: 24));

          await _repository.schedule(
            TravelNotification(
              id: uuid.v4(),
              type: NotificationType.reservationReminder,
              category: NotificationCategory.activity,
              title: 'Don\'t Forget: ${activity.name}',
              body: 'Your visit to ${activity.name} is tomorrow. '
                    '${activity.requiresAdvanceBooking ? "Book tickets in advance!" : ""}'
                    '${activity.estimatedDuration != Duration.zero ? " Estimated duration: ${activity.estimatedDuration.inHours}h" : ""}',
              scheduledAt: reminderTime,
              priority: activity.requiresAdvanceBooking
                  ? NotificationPriority.high
                  : NotificationPriority.normal,
              isActionable: activity.bookingUrl != null,
              actions: activity.bookingUrl != null
                  ? [
                      NotificationAction(
                        id: 'book',
                        label: 'Book Now',
                        type: NotificationActionType.deepLink,
                        deepLink: activity.bookingUrl!,
                      ),
                    ]
                  : null,
              data: {
                'activityId': activity.id,
                'itineraryId': itinerary.id,
              },
            ),
          );
        },
        orElse: () {},
      );
    }
  }

  Future<void> _scheduleWeatherAlerts(Itinerary itinerary) async {
    if (!_preferences.severeWeatherAlerts &&
        !_preferences.dailyWeatherSummary &&
        !_preferences.rainAlertsForOutdoorActivities) {
      return;
    }

    // Schedule daily weather summaries at 7 AM each day
    if (_preferences.dailyWeatherSummary) {
      for (int i = 0; i < itinerary.totalDays; i++) {
        final date = itinerary.dateRange.start.add(Duration(days: i));
        final summaryTime = DateTime(date.year, date.month, date.day, 7);

        await _repository.schedule(
          TravelNotification(
            id: uuid.v4(),
            type: NotificationType.weatherSummary,
            category: NotificationCategory.weather,
            title: 'Weather for ${DateFormat.MMMd().format(date)}',
            body: 'Daily summary for ${itinerary.destination.name}. '
                  'High: 18°C, Low: 10°C, Partly cloudy.',
            scheduledAt: summaryTime,
            priority: NotificationPriority.low,
            data: {
              'itineraryId': itinerary.id,
              'date': date.toIso8601String(),
            },
          ),
        );
      }
    }

    // Set up weather monitoring for alerts
    await _weatherService.monitorWeather(
      destination: itinerary.destination,
      dateRange: itinerary.dateRange,
      onSevereWeather: (weather) => _sendSevereWeatherAlert(
        itinerary,
        weather,
      ),
      onRainForecast: (date, hasRain) => _sendRainAlert(
        itinerary,
        date,
        hasRain,
      ),
    );
  }

  Future<void> _scheduleDailyBriefings(Itinerary itinerary) async {
    // Schedule daily trip summary at 6 AM
    for (int i = 0; i < itinerary.totalDays; i++) {
      final date = itinerary.dateRange.start.add(Duration(days: i));
      final briefingTime = DateTime(date.year, date.month, date.day, 6);

      final itemsForDay = itinerary.getItemsForDate(date);
      final activityCount = itemsForDay.where((item) {
        return item.maybeWhen(
          activity: (_) => true,
          restaurant: (_) => true,
          orElse: () => false,
        );
      }).length;

      await _repository.schedule(
        TravelNotification(
          id: uuid.v4(),
          type: NotificationType.dailyBriefing,
          category: NotificationCategory.trip,
          title: 'Your ${itinerary.destination.name} Day ${i + 1}',
          body: 'Good morning! You have $activityCount activities planned '
                'for today. Weather: 16°C, partly cloudy.',
          scheduledAt: briefingTime,
          priority: NotificationPriority.low,
          isActionable: true,
          actions: [
            NotificationAction(
              id: 'view_itinerary',
              label: 'View Itinerary',
              type: NotificationActionType.deepLink,
              deepLink: 'soloadventurer://itinerary/${itinerary.id}?date=${date.toIso8601String()}',
            ),
          ],
          data: {
            'itineraryId': itinerary.id,
            'date': date.toIso8601String(),
          },
        ),
      );
    }
  }

  Future<void> _sendFlightDelayNotification(
    ItineraryItemFlight flight,
    Duration delay,
  ) async {
    await _repository.sendNow(
      TravelNotification(
        id: uuid.v4(),
        type: NotificationType.flightDelayed,
        category: NotificationCategory.flight,
        title: '⚠️ Flight Delayed',
        body: '${flight.airline} ${flight.flightNumber}: '
              'New departure time: ${DateFormat.Hm().format(flight.scheduledAt.add(delay))}',
        scheduledAt: DateTime.now(),
        priority: NotificationPriority.high,
        isActionable: true,
        actions: [
          NotificationAction(
            id: 'view_details',
            label: 'View Details',
            type: NotificationActionType.deepLink,
            deepLink: 'soloadventurer://flight/${flight.id}',
          ),
        ],
        data: {'flightId': flight.id},
      ),
    );
  }

  Future<void> _sendSevereWeatherAlert(
    Itinerary itinerary,
    WeatherForecast weather,
  ) async {
    final alertType = weather.precipitation > 10
        ? 'Heavy Rain Expected'
        : weather.temperature > 35
            ? 'Extreme Heat Warning'
            : 'Severe Weather Alert';

    await _repository.sendNow(
      TravelNotification(
        id: uuid.v4(),
        type: NotificationType.severeWeatherWarning,
        category: NotificationCategory.weather,
        title: '🌧️ $alertType',
        body: '${weather.temperature.toStringAsFixed(0)}°C and '
              '${weather.precipitation.toStringAsFixed(0)}mm rain expected '
              'on ${DateFormat.MMMd().format(weather.date)}. '
              'Consider indoor alternatives.',
        scheduledAt: DateTime.now(),
        priority: NotificationPriority.urgent,
        isActionable: true,
        actions: [
          NotificationAction(
            id: 'view_alternatives',
            label: 'View Indoor Activities',
            type: NotificationActionType.deepLink,
            deepLink: 'soloadventurer://recommendations/${itinerary.id}?filter=indoor',
          ),
        ],
        data: {
          'itineraryId': itinerary.id,
          'weatherDate': weather.date.toIso8601String(),
        },
      ),
    );
  }

  Future<void> _sendRainAlert(
    Itinerary itinerary,
    DateTime date,
    bool hasRain,
  ) async {
    if (!hasRain || !_preferences.rainAlertsForOutdoorActivities) {
      return;
    }

    final outdoorActivities = itinerary.getItemsForDate(date).where((item) {
      return item.maybeWhen(
        activity: (activity) =>
            activity.type == ActivityType.outdoor,
        orElse: () => false,
      );
    }).toList();

    if (outdoorActivities.isEmpty) {
      return;
    }

    await _repository.sendNow(
      TravelNotification(
        id: uuid.v4(),
        type: NotificationType.weatherAlert,
        category: NotificationCategory.weather,
        title: '🌧️ Rain Expected',
        body: 'Tomorrow ( ${DateFormat.MMMd().format(date)} ): '
              '${outdoorActivities.length} outdoor activity(ies) '
              'in your itinerary may be affected.',
        scheduledAt: DateTime.now(),
        priority: NotificationPriority.normal,
        isActionable: true,
        actions: [
          NotificationAction(
            id: 'view_alternatives',
            label: 'View Indoor Alternatives',
            type: NotificationActionType.deepLink,
            deepLink: 'soloadventurer://recommendations/${itinerary.id}?date=${date.toIso8601String()}',
          ),
        ],
        data: {
          'itineraryId': itinerary.id,
          'date': date.toIso8601String(),
          'affectedActivities': outdoorActivities.map((a) => a.getId()).toList(),
        },
      ),
    );
  }

  Future<void> _sendGateChangeNotification(
    ItineraryItemFlight flight,
    String newGate,
  ) async {
    await _repository.sendNow(
      TravelNotification(
        id: uuid.v4(),
        type: NotificationType.flightGateChange,
        category: NotificationCategory.flight,
        title: '⚠️ Gate Change',
        body: '${flight.airline} ${flight.flightNumber}: '
              'New gate: $newGate '
              '(was ${flight.gate ?? "TBD"})',
        scheduledAt: DateTime.now(),
        priority: NotificationPriority.high,
        data: {'flightId': flight.id},
      ),
    );
  }

  Future<void> _sendFlightCancellationNotification(
    ItineraryItemFlight flight,
  ) async {
    await _repository.sendNow(
      TravelNotification(
        id: uuid.v4(),
        type: NotificationType.flightCancelled,
        category: NotificationCategory.flight,
        title: '⚠️ Flight Cancelled',
        body: '${flight.airline} ${flight.flightNumber} has been cancelled. '
              'Please contact the airline for rebooking options.',
        scheduledAt: DateTime.now(),
        priority: NotificationPriority.urgent,
        data: {'flightId': flight.id},
      ),
    );
  }
}

// lib/features/notifications/data/services/location_based_notification_service.dart
class LocationBasedNotificationService {
  final NotificationRepository _notificationRepo;
  final LocationService _locationService;
  final PlacesService _placesService;
  final NotificationPreferences _preferences;

  LocationBasedNotificationService({
    required NotificationRepository notificationRepo,
    required LocationService locationService,
    required PlacesService placesService,
    required NotificationPreferences preferences,
  })  : _notificationRepo = notificationRepo,
        _locationService = locationService,
        _placesService = placesService,
        _preferences = preferences;

  /// Monitor user location and send proximity-based notifications
  Stream<TravelNotification> monitorProximityNotifications({
    required Destination destination,
    required List<ItineraryItem> itineraryItems,
  }) {
    return _locationService.getCurrentLocationStream().asyncMap((location) async {
      final notifications = <TravelNotification>[];

      // Check for nearby restaurants
      if (_preferences.restaurantRecommendations) {
        final nearbyRestaurants = await _placesService.findNearbyRestaurants(
          location: location,
          radiusKm: 0.5, // 500m
        );

        if (nearbyRestaurants.isNotEmpty) {
          final restaurant = nearbyRestaurants.first;
          final distance = await _locationService.calculateDistance(
            location,
            restaurant.location ?? location,
          );

          notifications.add(
            TravelNotification(
              id: uuid.v4(),
              type: NotificationType.nearbyRecommendation,
              category: NotificationCategory.recommendation,
              title: '📍 Restaurant Near You',
              body: '${restaurant.name} is ${distance.inMeters.toStringAsFixed(0)}m away. '
                    'Highly rated by locals. ${restaurant.isOpen ? 'Open now.' : 'Opens at ${restaurant.openingTime}'}',
              scheduledAt: DateTime.now(),
              priority: NotificationPriority.low,
              isActionable: true,
              actions: [
                NotificationAction(
                  id: 'directions',
                  label: 'Get Directions',
                  type: NotificationActionType.deepLink,
                  deepLink: 'soloadventurer://directions?to=${restaurant.id}',
                ),
              ],
              data: {
                'placeId': restaurant.id,
                'distance': distance.inMeters,
              },
            ),
          );
        }
      }

      // Check for nearby deals
      if (_preferences.nearbyDeals) {
        final deals = await _placesService.findNearbyDeals(
          location: location,
          radiusKm: 1,
        );

        for (final deal in deals) {
          notifications.add(
            TravelNotification(
              id: uuid.v4(),
              type: NotificationType.localDeal,
              category: NotificationCategory.recommendation,
              title: '💰 Special Offer Nearby',
              body: '${deal.title} at ${deal.merchantName}. '
                    '${deal.discount}% off - ${deal.distance.toStringAsFixed(0)}m away',
              scheduledAt: DateTime.now(),
              priority: NotificationPriority.low,
              imageUrl: deal.imageUrl,
              data: {
                'dealId': deal.id,
                'merchantId': deal.merchantId,
              },
            ),
          );
        }
      }

      // Return first notification only (rate limit)
      return notifications.isNotEmpty ? notifications.first : null;
    }).whereType<TravelNotification>();
  }
}
```

### Presentation Layer

```dart
// lib/features/notifications/presentation/screens/notification_settings_screen.dart
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  late NotificationPreferences _preferences;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final result = await ref.watch(
      getNotificationPreferencesProvider.future,
    );
    result.fold(
      (failure) => null,
      (preferences) => setState(() => _preferences = preferences),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preferencesAsync = ref.watch(notificationPreferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Settings'),
      ),
      body: preferencesAsync.when(
        data: (preferences) => _buildSettings(context, preferences),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorWidget(error),
      ),
    );
  }

  Widget _buildSettings(
    BuildContext context,
    NotificationPreferences preferences,
  ) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Flight notifications
        _buildSectionHeader(
          context,
          '✈️ Trip Notifications',
          'Recommended: Keep ON',
        ),
        _buildSwitchTile(
          context,
          'Flight check-in reminders',
          '24 hours before departure',
          preferences.flightCheckInReminders,
          (value) => _updatePreference(
            preferences.copyWith(flightCheckInReminders: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Flight delays & cancellations',
          'Real-time updates',
          preferences.flightDelaysAndCancellations,
          (value) => _updatePreference(
            preferences.copyWith(flightDelaysAndCancellations: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Booking confirmations',
          'When reservations are confirmed',
          preferences.bookingConfirmations,
          (value) => _updatePreference(
            preferences.copyWith(bookingConfirmations: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Reservation reminders',
          '24 hours before activities',
          preferences.reservationReminders,
          (value) => _updatePreference(
            preferences.copyWith(reservationReminders: value),
          ),
        ),

        SizedBox(height: 24),

        // Weather notifications
        _buildSectionHeader(
          context,
          '🌤️ Weather Alerts',
          'Recommended: Keep ON',
        ),
        _buildSwitchTile(
          context,
          'Severe weather warnings',
          'Critical weather updates',
          preferences.severeWeatherAlerts,
          (value) => _updatePreference(
            preferences.copyWith(severeWeatherAlerts: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Daily weather summary',
          '7 AM each day',
          preferences.dailyWeatherSummary,
          (value) => _updatePreference(
            preferences.copyWith(dailyWeatherSummary: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Rain alerts for outdoor activities',
          'Suggest indoor alternatives',
          preferences.rainAlertsForOutdoorActivities,
          (value) => _updatePreference(
            preferences.copyWith(rainAlertsForOutdoorActivities: value),
          ),
        ),

        SizedBox(height: 24),

        // Safety notifications
        _buildSectionHeader(
          context,
          '🛡️ Safety Alerts',
          'Always ON for your protection',
        ),
        _buildSwitchTile(
          context,
          'Destination safety updates',
          'Travel advisories and alerts',
          preferences.safetyAlerts,
          (value) => _updatePreference(
            preferences.copyWith(safetyAlerts: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Travel advisories',
          'Government travel alerts',
          preferences.travelAdvisories,
          (value) => _updatePreference(
            preferences.copyWith(travelAdvisories: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Emergency alerts',
          'Critical emergency notifications',
          preferences.emergencyAlerts,
          (value) => _updatePreference(
            preferences.copyWith(emergencyAlerts: value),
          ),
        ),

        SizedBox(height: 24),

        // Recommendation notifications
        _buildSectionHeader(
          context,
          '📍 Local Recommendations',
          'Optional - Turn OFF for fewer notifications',
        ),
        _buildSwitchTile(
          context,
          'Nearby deals & offers',
          'Special offers near your location',
          preferences.nearbyDeals,
          (value) => _updatePreference(
            preferences.copyWith(nearbyDeals: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Local event suggestions',
          'Events happening near you',
          preferences.localEventSuggestions,
          (value) => _updatePreference(
            preferences.copyWith(localEventSuggestions: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Restaurant recommendations',
          'Highly rated places nearby',
          preferences.restaurantRecommendations,
          (value) => _updatePreference(
            preferences.copyWith(restaurantRecommendations: value),
          ),
        ),

        SizedBox(height: 24),

        // Notification style
        _buildSectionHeader(
          context,
          '📱 Notification Style',
          null,
        ),
        _buildTimeRangeTile(
          context,
          'Quiet Hours',
          preferences.quietHoursStart,
          preferences.quietHoursEnd,
        ),
        _buildSwitchTile(
          context,
          'Vibrate',
          null,
          preferences.vibrateEnabled,
          (value) => _updatePreference(
            preferences.copyWith(vibrateEnabled: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Sound',
          null,
          preferences.soundEnabled,
          (value) => _updatePreference(
            preferences.copyWith(soundEnabled: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Bypass Do Not Disturb',
          'For urgent notifications only',
          preferences.bypassDoNotDisturb,
          (value) => _updatePreference(
            preferences.copyWith(bypassDoNotDisturb: value),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String? subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String? subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildTimeRangeTile(
    BuildContext context,
    String title,
    TimeOfDay start,
    TimeOfDay end,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text('${_formatTime(start)} - ${_formatTime(end)}'),
      trailing: Icon(Icons.chevron_right),
      onTap: () => _selectTimeRange(context, start, end),
    );
  }

  Future<void> _selectTimeRange(
    BuildContext context,
    TimeOfDay start,
    TimeOfDay end,
  ) async {
    final newStart = await showTimePicker(
      context: context,
      initialTime: start,
    );

    if (newStart == null) return;

    final newEnd = await showTimePicker(
      context: context,
      initialTime: end,
    );

    if (newEnd == null) return;

    await _updatePreference(
      _preferences.copyWith(
        quietHoursStart: newStart,
        quietHoursEnd: newEnd,
      ),
    );
  }

  Future<void> _updatePreference(NotificationPreferences updated) async {
    setState(() => _preferences = updated);

    final result = await ref.read(
      updateNotificationPreferencesProvider(updated).future,
    );

    result.fold(
      (failure) => _showError(context, failure),
      (_) => ref.invalidate(notificationPreferencesProvider),
    );
  }

  void _showError(BuildContext context, Failure failure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(failure.toString())),
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}';
  }
}
```

---

## Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter_local_notifications: ^16.0.0
  timezone: ^0.9.0
  awesome_notifications: ^0.7.0
```

---

## Testing Checklist

### Unit Tests
- [ ] Notification entity validation
- [ ] NotificationPreferences serialization
- [ ] NotificationScheduler flight notifications
- [ ] Weather alert scheduling
- [ ] Quiet hours calculation
- [ ] Priority-based filtering

### Integration Tests
- [ ] Schedule notification → receive at correct time
- [ ] Flight delay notification triggers
- [ ] Weather alert sends for severe weather
- [ ] Quiet hours respected
- [ ] Notification actions work correctly

### Widget Tests
- [ ] Settings screen renders all options
- [ ] Toggles update preferences
- [ ] Time picker works correctly
- [ ] Save persists changes

---

## Success Metrics

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Open rate | 60%+ | Notifications opened / sent |
| Action rate | 30%+ | Actions taken / notifications with actions |
| Opt-out rate | <5% | Users who disable / total users |
| Relevance score | 4.0/5 | Post-notification feedback |
| Quiet hours respect | 95%+ | Notifications during quiet hours blocked |

---

## Dependencies for Next Features

**Enables:**
- Feature 5: Offline-First Reliability (notifications queued for offline)
- Feature 6: Purpose-Driven Community (community activity notifications)
- Feature 8: Real-Time Chat (new message notifications)

---

## Sources

- [flutter_local_notifications documentation](https://pub.dev/packages/flutter_local_notifications)
- [Awesome Notifications package](https://pub.dev/packages/awesome_notifications)
- [Mobile Push Notification Best Practices 2026](https://www.vwo.com/blog/mobile-push-notifications-guide/)
