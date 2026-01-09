import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:soloadventurer/core/services/location_service.dart';
import 'package:soloadventurer/features/notifications/domain/entities/notification_preferences.dart';
import 'package:soloadventurer/features/notifications/domain/entities/travel_notification.dart';
import 'package:soloadventurer/features/notifications/domain/repositories/notification_repository.dart';

/// Simple place model for location-based recommendations
class NearbyPlace {
  final String id;
  final String name;
  final String type;
  final double rating;
  final String? description;
  final String? imageUrl;
  final bool isOpen;
  final Position? location;

  NearbyPlace({
    required this.id,
    required this.name,
    required this.type,
    required this.rating,
    this.description,
    this.imageUrl,
    required this.isOpen,
    this.location,
  });
}

/// Service for location-based notifications
///
/// Monitors user location and sends proximity-based notifications
/// for nearby restaurants, deals, and attractions.
class LocationBasedNotificationService {
  final NotificationRepository _notificationRepository;
  final LocationService _locationService;
  final Uuid _uuid = const Uuid();

  // Rate limiting
  DateTime? _lastNotificationTime;
  static const _minNotificationInterval = Duration(minutes: 30);

  LocationBasedNotificationService(
    this._notificationRepository,
    this._locationService,
  );

  /// Monitor location and send proximity notifications
  ///
  /// Returns a stream of notifications that should be sent based on location
  Stream<TravelNotification?> monitorProximityNotifications({
    required NearbyPlace destination,
    required NotificationPreferences preferences,
  }) async* {
    // Check if location-based notifications are enabled
    if (!preferences.locationBasedNotificationsEnabled) {
      return;
    }

    // Get current location
    final positionResult = await _locationService.getCurrentPosition();

    await positionResult.fold(
      (failure) async {
        // Cannot get location, skip
        return;
      },
      (position) async {
        // Calculate distance
        final distance = _calculateDistance(
          position.latitude,
          position.longitude,
          destination.location?.latitude ?? 0,
          destination.location?.longitude ?? 0,
        );

        final radiusMeters = preferences.proximityNotificationRadiusMeters.toDouble();

        // Check if within radius
        if (distance <= radiusMeters) {
          // Check rate limiting
          if (_lastNotificationTime != null &&
              DateTime.now().difference(_lastNotificationTime!) <
                  _minNotificationInterval) {
            return;
          }

          // Check preference for this type
          bool shouldNotify = false;
          TravelNotification? notification;

          if (destination.type == 'restaurant' &&
              preferences.restaurantRecommendations) {
            shouldNotify = true;
            notification = _createRestaurantNotification(destination, distance);
          } else if (destination.type == 'deal' && preferences.nearbyDeals) {
            shouldNotify = true;
            notification = _createDealNotification(destination, distance);
          } else if (destination.type == 'event' &&
              preferences.localEventSuggestions) {
            shouldNotify = true;
            notification = _createEventNotification(destination, distance);
          }

          if (shouldNotify && notification != null) {
            _lastNotificationTime = DateTime.now();
            yield notification;
          }
        }
      },
    );
  }

  /// Send a nearby restaurant notification
  Future<void> sendNearbyRestaurantNotification({
    required String name,
    required double distanceMeters,
    required String rating,
    bool isOpen = true,
    String? specialDish,
  }) async {
    final distanceText = _formatDistance(distanceMeters);
    final statusText = isOpen ? 'Open now' : 'Currently closed';

    final notification = TravelNotification(
      id: _uuid.v4(),
      type: NotificationType.nearbyRecommendation,
      category: NotificationCategory.recommendation,
      title: '📍 Restaurant Near You',
      body: '$name is $distanceText away. '
            'Rated $rating/5. $statusText. '
            '${specialDish != null ? "Special: $specialDish" : ""}',
      scheduledAt: DateTime.now(),
      priority: NotificationPriority.low,
      isActionable: true,
      actions: [
        NotificationAction(
          id: 'directions',
          label: 'Get Directions',
          type: NotificationActionType.deepLink,
          deepLink: 'soloadventurer://directions?to=$name',
        ),
      ],
      data: {
        'placeType': 'restaurant',
        'name': name,
        'distance': distanceMeters,
      },
    );

    await _notificationRepository.sendNow(notification);
  }

  /// Send a nearby deal notification
  Future<void> sendNearbyDealNotification({
    required String merchantName,
    required String dealTitle,
    required double discount,
    required double distanceMeters,
    String? imageUrl,
  }) async {
    final distanceText = _formatDistance(distanceMeters);

    final notification = TravelNotification(
      id: _uuid.v4(),
      type: NotificationType.localDeal,
      category: NotificationCategory.recommendation,
      title: '💰 Special Offer Nearby',
      body: '$discount% off $dealTitle at $merchantName. '
            'Only $distanceText away!',
      scheduledAt: DateTime.now(),
      priority: NotificationPriority.low,
      imageUrl: imageUrl,
      data: {
        'placeType': 'deal',
        'merchantName': merchantName,
        'distance': distanceMeters,
      },
    );

    await _notificationRepository.sendNow(notification);
  }

  /// Send a local event notification
  Future<void> sendLocalEventNotification({
    required String eventName,
    required String venue,
    required DateTime startTime,
    required double distanceMeters,
    String? description,
  }) async {
    final distanceText = _formatDistance(distanceMeters);
    final timeText = _formatEventTime(startTime);

    final notification = TravelNotification(
      id: _uuid.v4(),
      type: NotificationType.eventSuggestion,
      category: NotificationCategory.recommendation,
      title: '🎉 Event Happening Near You',
      body: '$eventName at $venue. '
            '$timeText. $distanceText away. '
            '${description ?? ""}',
      scheduledAt: DateTime.now(),
      priority: NotificationPriority.low,
      data: {
        'placeType': 'event',
        'eventName': eventName,
        'venue': venue,
        'distance': distanceMeters,
      },
    );

    await _notificationRepository.sendNow(notification);
  }

  // Private helper methods

  TravelNotification _createRestaurantNotification(
      NearbyPlace place, double distanceMeters) {
    final distanceText = _formatDistance(distanceMeters);
    final statusText = place.isOpen ? 'Open now' : 'Currently closed';

    return TravelNotification(
      id: _uuid.v4(),
      type: NotificationType.nearbyRecommendation,
      category: NotificationCategory.recommendation,
      title: '📍 Restaurant Near You',
      body: '${place.name} is $distanceText away. '
            'Rated ${place.rating}/5. $statusText. '
            '${place.description ?? ""}',
      scheduledAt: DateTime.now(),
      priority: NotificationPriority.low,
      imageUrl: place.imageUrl,
      isActionable: true,
      actions: [
        NotificationAction(
          id: 'directions',
          label: 'Get Directions',
          type: NotificationActionType.deepLink,
          deepLink: 'soloadventurer://directions?to=${place.id}',
        ),
      ],
      data: {
        'placeId': place.id,
        'placeType': 'restaurant',
        'distance': distanceMeters,
      },
    );
  }

  TravelNotification _createDealNotification(
      NearbyPlace place, double distanceMeters) {
    final distanceText = _formatDistance(distanceMeters);

    return TravelNotification(
      id: _uuid.v4(),
      type: NotificationType.localDeal,
      category: NotificationCategory.recommendation,
      title: '💰 Special Offer Nearby',
      body: '${place.name} - ${place.description ?? "Special deal available"}. '
            '$distanceText away.',
      scheduledAt: DateTime.now(),
      priority: NotificationPriority.low,
      imageUrl: place.imageUrl,
      data: {
        'placeId': place.id,
        'placeType': 'deal',
        'distance': distanceMeters,
      },
    );
  }

  TravelNotification _createEventNotification(
      NearbyPlace place, double distanceMeters) {
    final distanceText = _formatDistance(distanceMeters);

    return TravelNotification(
      id: _uuid.v4(),
      type: NotificationType.eventSuggestion,
      category: NotificationCategory.recommendation,
      title: '🎉 Event Happening Near You',
      body: '${place.name}. '
            '${place.description ?? ""} '
            '$distanceText away.',
      scheduledAt: DateTime.now(),
      priority: NotificationPriority.low,
      imageUrl: place.imageUrl,
      data: {
        'placeId': place.id,
        'placeType': 'event',
        'distance': distanceMeters,
      },
    );
  }

  /// Calculate distance between two coordinates in meters
  double _calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Format distance for display
  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toInt()}m';
    } else {
      final km = (meters / 1000).toStringAsFixed(1);
      return '$km km';
    }
  }

  /// Format event time for display
  String _formatEventTime(DateTime time) {
    final now = DateTime.now();
    final difference = time.difference(now);

    if (difference.inHours < 1) {
      return 'Starting in ${difference.inMinutes} minutes';
    } else if (difference.inHours < 24) {
      return 'Starting in ${difference.inHours} hours';
    } else {
      return 'Starting on ${time.day}/${time.month}';
    }
  }

  /// Reset rate limiting
  void resetRateLimit() {
    _lastNotificationTime = null;
  }
}
