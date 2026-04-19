import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/safety/domain/entities/shared_meetup.dart';

void main() {
  group('SharedMeetup', () {
    final now = DateTime(2026, 4, 12, 14, 0);
    final future = DateTime(2026, 4, 12, 18, 0);

    test('isPast is true when meetup time is before now', () {
      final meetup = SharedMeetup(
        id: '1',
        userId: 'u1',
        meetingWith: 'Alice',
        locationName: 'Cafe',
        meetupTime: DateTime.now().subtract(const Duration(hours: 1)),
        createdAt: now,
      );
      expect(meetup.isPast, isTrue);
    });

    test('isPast is false when meetup time is in the future', () {
      final meetup = SharedMeetup(
        id: '1',
        userId: 'u1',
        meetingWith: 'Alice',
        locationName: 'Cafe',
        meetupTime: DateTime.now().add(const Duration(hours: 2)),
        createdAt: now,
      );
      expect(meetup.isPast, isFalse);
    });

    test('isImminent is true within 1 hour of meetup', () {
      final meetup = SharedMeetup(
        id: '1',
        userId: 'u1',
        meetingWith: 'Alice',
        locationName: 'Cafe',
        meetupTime: DateTime.now().add(const Duration(minutes: 30)),
        createdAt: now,
      );
      expect(meetup.isImminent, isTrue);
    });

    test('isImminent is false more than 1 hour before meetup', () {
      final meetup = SharedMeetup(
        id: '1',
        userId: 'u1',
        meetingWith: 'Alice',
        locationName: 'Cafe',
        meetupTime: DateTime.now().add(const Duration(hours: 3)),
        createdAt: now,
      );
      expect(meetup.isImminent, isFalse);
    });

    test('formattedTime produces expected format', () {
      final meetup = SharedMeetup(
        id: '1',
        userId: 'u1',
        meetingWith: 'Alice',
        locationName: 'Cafe',
        meetupTime: DateTime(2026, 4, 15, 14, 30),
        createdAt: now,
      );
      expect(meetup.formattedTime, contains('4/15/2026'));
      expect(meetup.formattedTime, contains('14:30'));
    });

    test('copyWith updates specified fields', () {
      final original = SharedMeetup(
        id: '1',
        userId: 'u1',
        meetingWith: 'Alice',
        locationName: 'Cafe',
        meetupTime: future,
        createdAt: now,
      );
      final updated = original.copyWith(
        meetingWith: 'Bob',
        plansChanged: true,
      );
      expect(updated.meetingWith, 'Bob');
      expect(updated.plansChanged, isTrue);
      expect(updated.locationName, 'Cafe'); // preserved
    });

    test('equality works correctly', () {
      final meetup1 = SharedMeetup(
        id: '1',
        userId: 'u1',
        meetingWith: 'Alice',
        locationName: 'Cafe',
        meetupTime: future,
        createdAt: now,
      );
      final meetup2 = SharedMeetup(
        id: '1',
        userId: 'u1',
        meetingWith: 'Alice',
        locationName: 'Cafe',
        meetupTime: future,
        createdAt: now,
      );
      expect(meetup1, equals(meetup2));
    });

    test('sharedWithContactIds defaults to empty', () {
      final meetup = SharedMeetup(
        id: '1',
        userId: 'u1',
        meetingWith: 'Alice',
        locationName: 'Cafe',
        meetupTime: future,
        createdAt: now,
      );
      expect(meetup.sharedWithContactIds, isEmpty);
    });
  });
}
