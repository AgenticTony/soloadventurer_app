import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/notifications/data/datasources/notification_local_data_source.dart';
import 'package:soloadventurer/features/notifications/data/models/notification_model.dart';
import 'package:soloadventurer/features/notifications/data/models/notification_preferences_model.dart';
import 'package:soloadventurer/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:soloadventurer/features/notifications/domain/entities/notification_preferences.dart';
import 'package:soloadventurer/features/notifications/domain/entities/travel_notification.dart';

// Mocks
class MockNotificationLocalDataSource extends Mock
    implements NotificationLocalDataSource {}

void main() {
  late MockNotificationLocalDataSource mockLocalDataSource;
  late NotificationRepositoryImpl repository;

  // Test data
  final testNotification = TravelNotification(
    id: 'notif-1',
    type: NotificationType.flightCheckInAvailable,
    category: NotificationCategory.flight,
    title: 'Flight Check-In Available',
    body: 'Your flight AF1234 is ready for check-in',
    scheduledAt: DateTime(2024, 6, 1, 10, 0),
    priority: NotificationPriority.high,
    isActionable: true,
    actions: [
      const NotificationAction(
        id: 'check_in',
        label: 'Check In',
        type: NotificationActionType.deepLink,
        deepLink: 'soloadventurer://checkin/flight-1',
      ),
    ],
    data: {'flightId': 'flight-1', 'itineraryId': 'itinerary-1'},
  );

  final testNotificationModel = NotificationModel(
    id: 'notif-1',
    type: NotificationType.flightCheckInAvailable,
    category: NotificationCategory.flight,
    title: 'Flight Check-In Available',
    body: 'Your flight AF1234 is ready for check-in',
    scheduledAt: DateTime(2024, 6, 1, 10, 0),
    priority: NotificationPriority.high,
    isActionable: true,
    actions: [
      const NotificationAction(
        id: 'check_in',
        label: 'Check In',
        type: NotificationActionType.deepLink,
        deepLink: 'soloadventurer://checkin/flight-1',
      ),
    ],
    data: {'flightId': 'flight-1', 'itineraryId': 'itinerary-1'},
  );

  const testPreferences = NotificationPreferences(
    flightCheckInReminders: true,
    flightDelaysAndCancellations: true,
    flightGateChanges: true,
    bookingConfirmations: true,
    checkInReminders: true,
    reservationReminders: true,
    severeWeatherAlerts: true,
    dailyWeatherSummary: true,
    rainAlertsForOutdoorActivities: false,
    safetyAlerts: true,
    travelAdvisories: true,
    emergencyAlerts: true,
    nearbyDeals: false,
    localEventSuggestions: false,
    restaurantRecommendations: false,
    quietHoursStart: 0,
    quietHoursEnd: 0,
  );

  final testPreferencesModel =
      NotificationPreferencesModel.fromEntity(testPreferences);

  setUp(() {
    mockLocalDataSource = MockNotificationLocalDataSource();
    repository = NotificationRepositoryImpl(
      mockLocalDataSource,
    );

    // Register fallback values
    registerFallbackValue(testNotification);
    registerFallbackValue(testNotificationModel);
    registerFallbackValue(testPreferencesModel);

    // Setup default behaviors
    when(() => mockLocalDataSource.saveNotification(any()))
        .thenAnswer((_) async {});
    when(() => mockLocalDataSource.savePreferences(any()))
        .thenAnswer((_) async {});
    when(() => mockLocalDataSource.getPreferences())
        .thenAnswer((_) async => testPreferencesModel);
    when(() => mockLocalDataSource.getNotification(any()))
        .thenAnswer((_) async => testNotificationModel);
    when(() => mockLocalDataSource.updateNotification(any()))
        .thenAnswer((_) async {});
    when(() => mockLocalDataSource.deleteNotification(any()))
        .thenAnswer((_) async {});
    when(() => mockLocalDataSource.clearAllNotifications())
        .thenAnswer((_) async {});
    when(() => mockLocalDataSource.clearNotificationsBefore(any()))
        .thenAnswer((_) async {});
    when(() => mockLocalDataSource.getAllNotifications())
        .thenAnswer((_) async => [testNotificationModel]);
    when(() => mockLocalDataSource.getNotifications(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          category: any(named: 'category'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        )).thenAnswer((_) async => [testNotificationModel]);
    when(() => mockLocalDataSource.getUnreadNotifications(
            limit: any(named: 'limit')))
        .thenAnswer((_) async => [testNotificationModel]);
    when(() => mockLocalDataSource.getPendingNotifications())
        .thenAnswer((_) async => []);
  });

  group('NotificationRepositoryImpl', () {
    group('schedule', () {
      test('should save notification when type is enabled in preferences',
          () async {
        // Act
        await repository.schedule(testNotification);

        // Assert
        verify(() => mockLocalDataSource.saveNotification(any())).called(1);
      });

      test('should not save notification when type is disabled in preferences',
          () async {
        // Arrange
        final disabledPrefs = testPreferences.copyWith(
          flightCheckInReminders: false,
          flightDelaysAndCancellations: false,
          flightGateChanges: false,
        );
        final disabledPrefsModel =
            NotificationPreferencesModel.fromEntity(disabledPrefs);
        when(() => mockLocalDataSource.getPreferences())
            .thenAnswer((_) async => disabledPrefsModel);

        // Act
        await repository.schedule(testNotification);

        // Assert
        verifyNever(() => mockLocalDataSource.saveNotification(any()));
      });

      test('should not save notification during quiet hours for non-urgent',
          () async {
        // Arrange
        final quietTimePrefs = testPreferences.copyWith(
          quietHoursStart: 22,
          quietHoursEnd: 7,
        );
        final quietTimeModel =
            NotificationPreferencesModel.fromEntity(quietTimePrefs);
        when(() => mockLocalDataSource.getPreferences())
            .thenAnswer((_) async => quietTimeModel);

        final nightNotification = TravelNotification(
          id: 'night-notif',
          type: NotificationType.dailyBriefing,
          category: NotificationCategory.trip,
          title: 'Night Briefing',
          body: 'Scheduled at 11 PM',
          scheduledAt: DateTime(2024, 6, 1, 23, 0), // 11 PM
          priority: NotificationPriority.low,
        );

        // Act
        await repository.schedule(nightNotification);

        // Assert
        verifyNever(() => mockLocalDataSource.saveNotification(any()));
      });

      test('should save urgent notification during quiet hours', () async {
        // Arrange
        final quietTimePrefs = testPreferences.copyWith(
          quietHoursStart: 22,
          quietHoursEnd: 7,
        );
        final quietTimeModel =
            NotificationPreferencesModel.fromEntity(quietTimePrefs);
        when(() => mockLocalDataSource.getPreferences())
            .thenAnswer((_) async => quietTimeModel);

        final urgentNotification = TravelNotification(
          id: 'urgent-notif',
          type: NotificationType.emergencyAlert,
          category: NotificationCategory.safety,
          title: 'Emergency',
          body: 'Emergency alert',
          scheduledAt: DateTime(2024, 6, 1, 23, 0), // 11 PM during quiet hours
          priority: NotificationPriority.urgent,
        );

        // Act
        await repository.schedule(urgentNotification);

        // Assert
        verify(() => mockLocalDataSource.saveNotification(any())).called(1);
      });
    });

    group('sendNow', () {
      test('should mark notification as delivered and save', () async {
        // Act
        await repository.sendNow(testNotification);

        // Assert
        verify(() => mockLocalDataSource.saveNotification(any())).called(1);
      });

      test('should not send when type is disabled', () async {
        // Arrange
        final disabledPrefs = testPreferences.copyWith(
          flightCheckInReminders: false,
          flightDelaysAndCancellations: false,
          flightGateChanges: false,
        );
        when(() => mockLocalDataSource.getPreferences()).thenAnswer((_) async =>
            NotificationPreferencesModel.fromEntity(disabledPrefs));

        // Act
        await repository.sendNow(testNotification);

        // Assert
        verifyNever(() => mockLocalDataSource.saveNotification(any()));
      });

      test('should respect quiet hours for non-urgent notifications', () async {
        // Arrange
        final quietTimePrefs = testPreferences.copyWith(
          quietHoursStart: 22,
          quietHoursEnd: 7,
        );
        when(() => mockLocalDataSource.getPreferences()).thenAnswer((_) async =>
            NotificationPreferencesModel.fromEntity(quietTimePrefs));

        final nightNotification = TravelNotification(
          id: 'night-notif',
          type: NotificationType.dailyBriefing,
          category: NotificationCategory.trip,
          title: 'Night',
          body: 'Scheduled during quiet hours',
          scheduledAt: DateTime.now(), // During quiet hours
          priority: NotificationPriority.low,
        );

        // Act
        await repository.sendNow(nightNotification);

        // Assert
        verifyNever(() => mockLocalDataSource.saveNotification(any()));
      });
    });

    group('cancel', () {
      test('should delete notification from data source', () async {
        // Act
        await repository.cancel('notif-1');

        // Assert
        verify(() => mockLocalDataSource.deleteNotification('notif-1'))
            .called(1);
      });
    });

    group('cancelAll', () {
      test('should clear all notifications', () async {
        // Act
        await repository.cancelAll();

        // Assert
        verify(() => mockLocalDataSource.clearAllNotifications()).called(1);
      });
    });

    group('markAsRead', () {
      test('should get notification, mark as read, and update', () async {
        // Act
        await repository.markAsRead('notif-1');

        // Assert
        verify(() => mockLocalDataSource.getNotification('notif-1')).called(1);
        verify(() => mockLocalDataSource.updateNotification(any())).called(1);
      });
    });

    group('dismiss', () {
      test('should get notification, mark as dismissed, and update', () async {
        // Act
        await repository.dismiss('notif-1');

        // Assert
        verify(() => mockLocalDataSource.getNotification('notif-1')).called(1);
        verify(() => mockLocalDataSource.updateNotification(any())).called(1);
      });
    });

    group('getHistory', () {
      test('should return list of notifications from models', () async {
        // Act
        final result = await repository.getHistory();

        // Assert
        expect(result, isA<List<TravelNotification>>());
        expect(result.length, equals(1));
        expect(result.first.id, equals(testNotification.id));
        expect(result.first.type, equals(testNotification.type));
        verify(() => mockLocalDataSource.getNotifications(
              startDate: null,
              endDate: null,
              category: null,
              limit: 50,
              offset: 0,
            )).called(1);
      });

      test('should pass filters to data source', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 12, 31);

        // Act
        await repository.getHistory(
          startDate: startDate,
          endDate: endDate,
          category: NotificationCategory.flight,
          limit: 20,
          offset: 10,
        );

        // Assert
        verify(() => mockLocalDataSource.getNotifications(
              startDate: startDate,
              endDate: endDate,
              category: 'flight',
              limit: 20,
              offset: 10,
            )).called(1);
      });
    });

    group('getUnread', () {
      test('should return list of unread notifications', () async {
        // Arrange
        final unreadModel = testNotificationModel.copyWith(readAt: null);
        when(() => mockLocalDataSource.getUnreadNotifications(limit: 20))
            .thenAnswer((_) async => [unreadModel]);

        // Act
        final result = await repository.getUnread();

        // Assert
        expect(result, isA<List<TravelNotification>>());
        expect(result.length, equals(1));
        expect(result.first.isRead, isFalse);
        verify(() => mockLocalDataSource.getUnreadNotifications(limit: 20))
            .called(1);
      });

      test('should use custom limit', () async {
        // Act
        await repository.getUnread(limit: 50);

        // Assert
        verify(() => mockLocalDataSource.getUnreadNotifications(limit: 50))
            .called(1);
      });
    });

    group('getPending', () {
      test('should return list of pending notifications', () async {
        // Arrange
        final pendingModel = testNotificationModel.copyWith(
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          deliveredAt: null,
        );
        when(() => mockLocalDataSource.getPendingNotifications())
            .thenAnswer((_) async => [pendingModel]);

        // Act
        final result = await repository.getPending();

        // Assert
        expect(result, isA<List<TravelNotification>>());
        expect(result.length, equals(1));
        verify(() => mockLocalDataSource.getPendingNotifications()).called(1);
      });
    });

    group('updatePreferences', () {
      test('should convert and save preferences', () async {
        // Act
        await repository.updatePreferences(testPreferences);

        // Assert
        verify(() => mockLocalDataSource.savePreferences(any())).called(1);
      });
    });

    group('getPreferences', () {
      test('should return entity from model', () async {
        // Act
        final result = await repository.getPreferences();

        // Assert
        expect(result, isA<NotificationPreferences>());
        expect(result.flightCheckInReminders,
            equals(testPreferences.flightCheckInReminders));
        verify(() => mockLocalDataSource.getPreferences()).called(1);
      });
    });

    group('clearHistory', () {
      test('should clear all notifications when date not specified', () async {
        // Act
        await repository.clearHistory();

        // Assert
        verify(() => mockLocalDataSource.clearAllNotifications()).called(1);
        verifyNever(() => mockLocalDataSource.clearNotificationsBefore(any()));
      });

      test('should clear notifications before date when specified', () async {
        // Arrange
        final beforeDate = DateTime(2024, 6, 1);

        // Act
        await repository.clearHistory(beforeDate: beforeDate);

        // Assert
        verify(() => mockLocalDataSource.clearNotificationsBefore(beforeDate))
            .called(1);
        verifyNever(() => mockLocalDataSource.clearAllNotifications());
      });
    });

    group('getStats', () {
      test('should calculate statistics from all notifications', () async {
        // Arrange
        final deliveredModel = testNotificationModel.copyWith(
          id: 'notif-2',
          deliveredAt: DateTime(2024, 6, 1, 10, 0),
          readAt: DateTime(2024, 6, 1, 10, 5),
        );
        final dismissedModel = testNotificationModel.copyWith(
          id: 'notif-3',
          dismissedAt: DateTime(2024, 6, 1, 11, 0),
        );
        final pendingModel = testNotificationModel.copyWith(
          id: 'notif-4',
          scheduledAt: DateTime.now().add(const Duration(days: 30)),
          deliveredAt: null,
        );
        when(() => mockLocalDataSource.getAllNotifications())
            .thenAnswer((_) async => [
                  testNotificationModel,
                  deliveredModel,
                  dismissedModel,
                  pendingModel,
                ]);

        // Act
        final stats = await repository.getStats();

        // Assert
        expect(stats.totalSent, equals(4));
        expect(stats.totalRead, equals(1));
        expect(stats.totalDismissed, equals(1));
        expect(stats.unreadCount, equals(3));
        expect(stats.pendingCount, equals(1));
      });

      test('should group by category', () async {
        // Arrange
        final hotelNotif = testNotificationModel.copyWith(
          id: 'hotel-1',
          category: NotificationCategory.accommodation,
        );
        final weatherNotif = testNotificationModel.copyWith(
          id: 'weather-1',
          category: NotificationCategory.weather,
        );
        when(() => mockLocalDataSource.getAllNotifications())
            .thenAnswer((_) async => [
                  testNotificationModel, // flight
                  hotelNotif,
                  testNotificationModel, // flight (duplicate)
                  weatherNotif,
                ]);

        // Act
        final stats = await repository.getStats();

        // Assert
        expect(stats.byCategory[NotificationCategory.flight], equals(2));
        expect(stats.byCategory[NotificationCategory.accommodation], equals(1));
        expect(stats.byCategory[NotificationCategory.weather], equals(1));
      });
    });

    group('cancelItineraryNotifications', () {
      test('should cancel all notifications for itinerary', () async {
        // Arrange
        final notif1 = testNotificationModel.copyWith(
          id: 'notif-1',
          data: {'itineraryId': 'itinerary-123'},
        );
        final notif2 = testNotificationModel.copyWith(
          id: 'notif-2',
          data: {'itineraryId': 'itinerary-456'},
        );
        when(() => mockLocalDataSource.getAllNotifications())
            .thenAnswer((_) async => [notif1, notif2]);

        // Act
        await repository.cancelItineraryNotifications('itinerary-123');

        // Assert
        verify(() => mockLocalDataSource.deleteNotification('notif-1'))
            .called(1);
        verifyNever(() => mockLocalDataSource.deleteNotification('notif-2'));
      });

      test('should handle empty notification list', () async {
        // Arrange
        when(() => mockLocalDataSource.getAllNotifications())
            .thenAnswer((_) async => []);

        // Act & Assert - should not throw
        await repository.cancelItineraryNotifications('itinerary-123');

        verifyNever(() => mockLocalDataSource.deleteNotification(any()));
      });
    });

    group('isNotificationTypeEnabled', () {
      test('should return true for flight check-in when enabled', () async {
        // Act
        final result = await repository.isNotificationTypeEnabled(
          NotificationType.flightCheckInAvailable,
        );

        // Assert
        expect(result, isTrue);
      });

      test('should return false for flight check-in when disabled', () async {
        // Arrange
        final disabledPrefs = testPreferences.copyWith(
          flightCheckInReminders: false,
        );
        when(() => mockLocalDataSource.getPreferences()).thenAnswer((_) async =>
            NotificationPreferencesModel.fromEntity(disabledPrefs));

        // Act
        final result = await repository.isNotificationTypeEnabled(
          NotificationType.flightCheckInAvailable,
        );

        // Assert
        expect(result, isFalse);
      });

      test('should map weather alerts to correct preferences', () async {
        // Act
        final severeResult = await repository.isNotificationTypeEnabled(
          NotificationType.severeWeatherWarning,
        );

        // Assert
        expect(severeResult, isTrue);
      });

      test('should map safety alerts to correct preferences', () async {
        // Act
        final result = await repository.isNotificationTypeEnabled(
          NotificationType.safetyAlert,
        );

        // Assert
        expect(result, isTrue);
      });
    });

    group('sendTestNotification', () {
      test('should create and send test notification', () async {
        // Act
        await repository.sendTestNotification();

        // Assert
        verify(() => mockLocalDataSource.saveNotification(any())).called(1);
      });
    });

    group('scheduleItineraryNotifications', () {
      test('should be a no-op method', () async {
        // Act & Assert - should not throw
        await repository.scheduleItineraryNotifications('itinerary-1');

        verifyNever(() => mockLocalDataSource.saveNotification(any()));
      });
    });
  });

  group('NotificationRepositoryImpl - Edge Cases', () {
    test('should handle empty history gracefully', () async {
      // Arrange
      when(() => mockLocalDataSource.getNotifications(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            category: any(named: 'category'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => []);

      // Act
      final result = await repository.getHistory();

      // Assert
      expect(result, isEmpty);
    });

    test('should handle empty unread list', () async {
      // Arrange
      when(() => mockLocalDataSource.getUnreadNotifications(
          limit: any(named: 'limit'))).thenAnswer((_) async => []);

      // Act
      final result = await repository.getUnread();

      // Assert
      expect(result, isEmpty);
    });

    test('should calculate zero stats for empty notification list', () async {
      // Arrange
      when(() => mockLocalDataSource.getAllNotifications())
          .thenAnswer((_) async => []);

      // Act
      final stats = await repository.getStats();

      // Assert
      expect(stats.totalSent, equals(0));
      expect(stats.totalRead, equals(0));
      expect(stats.totalDismissed, equals(0));
      expect(stats.unreadCount, equals(0));
      expect(stats.pendingCount, equals(0));
      expect(stats.openRate, equals(0.0));
      expect(stats.dismissRate, equals(0.0));
    });

    test('should handle null data field in notification model', () async {
      // Arrange
      final modelWithoutData = testNotificationModel.copyWith(data: null);
      when(() => mockLocalDataSource.getAllNotifications())
          .thenAnswer((_) async => [modelWithoutData]);

      // Act
      final stats = await repository.getStats();

      // Assert
      expect(stats.totalSent, equals(1));
    });
  });
}
