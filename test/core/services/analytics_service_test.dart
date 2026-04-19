import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/services/analytics_service.dart';

void main() {
  group('Sprint 1a.4 — Analytics Service', () {
    group('TestAnalyticsService', () {
      late TestAnalyticsService analytics;

      setUp(() {
        analytics = TestAnalyticsService();
      });

      test('track() records an event', () {
        analytics.track('test_event', properties: {'key': 'value'});

        expect(analytics.events.length, 1);
        expect(analytics.events.first.name, 'test_event');
        expect(analytics.events.first.properties['key'], 'value');
      });

      test('trackScreenView() records screen_view event with screen name', () {
        analytics.trackScreenView('home');

        expect(analytics.events.length, 1);
        expect(analytics.events.first.name, AnalyticsEvents.screenView);
        expect(
          analytics.events.first.properties[AnalyticsEvents.screenName],
          'home',
        );
      });

      test('trackScreenView() includes additional properties', () {
        analytics.trackScreenView(
          'chat',
          properties: {'connectionId': 'conn-123'},
        );

        final event = analytics.events.first;
        expect(event.properties[AnalyticsEvents.screenName], 'chat');
        expect(event.properties['connectionId'], 'conn-123');
      });

      test('identify() sets userId and traits', () {
        analytics.identify(
          userId: 'user-123',
          traits: {'name': 'Anthony', 'plan': 'pro'},
        );

        expect(analytics.userId, 'user-123');
        expect(analytics.userProperties['name'], 'Anthony');
        expect(analytics.userProperties['plan'], 'pro');
      });

      test('reset() clears userId and properties', () {
        analytics.identify(userId: 'user-123');
        analytics.reset();

        expect(analytics.userId, isNull);
        expect(analytics.userProperties, isEmpty);
      });

      test('setUserProperty() sets individual properties', () {
        analytics.setUserProperty('theme', 'dark');
        expect(analytics.userProperties['theme'], 'dark');
      });

      test('hasEvent() returns true when event exists', () {
        analytics.track('button_click');

        expect(analytics.hasEvent('button_click'), isTrue);
        expect(analytics.hasEvent('nonexistent'), isFalse);
      });

      test('getEvents() returns all events with matching name', () {
        analytics.track('click');
        analytics.track('scroll');
        analytics.track('click');

        final clickEvents = analytics.getEvents('click');
        expect(clickEvents.length, 2);
      });

      test('lastEvent returns most recent event', () {
        analytics.track('first');
        analytics.track('second');

        expect(analytics.lastEvent?.name, 'second');
      });

      test('lastEvent returns null when no events', () {
        expect(analytics.lastEvent, isNull);
      });

      test('clear() removes all events and user data', () {
        analytics.track('event1');
        analytics.identify(userId: 'user-123');

        analytics.clear();

        expect(analytics.events, isEmpty);
        expect(analytics.userId, isNull);
      });

      test('flush() completes without error', () async {
        await expectLater(analytics.flush(), completes);
      });

      test('AnalyticsEvent has timestamp', () {
        final before = DateTime.now();
        analytics.track('timed_event');
        final after = DateTime.now();

        final event = analytics.events.first;
        expect(
          event.timestamp.isAfter(before.subtract(const Duration(milliseconds: 1))),
          isTrue,
        );
        expect(
          event.timestamp.isBefore(after.add(const Duration(milliseconds: 1))),
          isTrue,
        );
      });
    });

    group('AnalyticsEvents constants', () {
      test('screen view constants exist', () {
        expect(AnalyticsEvents.screenView, 'screen_view');
        expect(AnalyticsEvents.screenName, 'screen_name');
      });

      test('auth event constants exist', () {
        expect(AnalyticsEvents.signUp, 'sign_up');
        expect(AnalyticsEvents.login, 'login');
        expect(AnalyticsEvents.signOut, 'sign_out');
      });

      test('matching event constants exist', () {
        expect(AnalyticsEvents.viewMatches, 'view_matches');
        expect(AnalyticsEvents.createTrip, 'create_trip');
        expect(AnalyticsEvents.sendConnectionRequest, 'send_connection_request');
        expect(AnalyticsEvents.acceptConnection, 'accept_connection');
      });

      test('chat event constants exist', () {
        expect(AnalyticsEvents.sendMessage, 'send_message');
        expect(AnalyticsEvents.receiveMessage, 'receive_message');
      });

      test('safety event constants exist', () {
        expect(AnalyticsEvents.triggerSOS, 'trigger_sos');
        expect(AnalyticsEvents.checkIn, 'check_in');
        expect(AnalyticsEvents.shareLocation, 'share_location');
      });
    });
  });
}
