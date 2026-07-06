import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/services/analytics_service.dart';

void main() {
  group('Story 0.3 — north-star event (meetup_completed)', () {
    late TestAnalyticsService analytics;

    setUp(() => analytics = TestAnalyticsService());

    test('trackMeetupCompleted fires the locked north-star event name', () {
      analytics.trackMeetupCompleted(meetupId: 'm-123');

      expect(analytics.hasEvent(AnalyticsEvents.meetupCompleted), isTrue);
      expect(AnalyticsEvents.meetupCompleted, 'meetup_completed');
    });

    test('carries meetup_id and no PII', () {
      analytics.trackMeetupCompleted(
        meetupId: 'm-123',
        properties: {'city': 'Seoul'},
      );

      final event = analytics.getEvents(AnalyticsEvents.meetupCompleted).single;
      expect(event.properties['meetup_id'], 'm-123');
      expect(event.properties['city'], 'Seoul');
      // Guard: the helper must never require or attach identity PII.
      expect(event.properties.containsKey('email'), isFalse);
      expect(event.properties.containsKey('full_name'), isFalse);
    });
  });
}
