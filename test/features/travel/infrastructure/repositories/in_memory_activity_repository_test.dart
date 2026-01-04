import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/models/paginated_data.dart';
import 'package:soloadventurer/core/repositories/paginated_repository_mixin.dart';
import 'package:soloadventurer/features/travel/domain/models/activity.dart';
import 'package:soloadventurer/features/travel/infrastructure/repositories/in_memory_activity_repository.dart';

void main() {
  group('InMemoryActivityRepository', () {
    late InMemoryActivityRepository repository;
    late String testUserId;
    late String testTripId;
    late List<Activity> testActivities;

    setUp(() {
      repository = InMemoryActivityRepository();
      testUserId = 'test-user-123';
      testTripId = 'test-trip-456';

      // Create test activities
      testActivities = List.generate(
        50,
        (index) => Activity(
          id: 'activity-$index',
          tripId: testTripId,
          userId: testUserId,
          title: 'Activity $index',
          description: 'Description for activity $index',
          category: ActivityCategory.values[index % ActivityCategory.values.length],
          startDateTime: DateTime(2024, 1, 1, 10, 0).add(Duration(hours: index)),
          endDateTime: DateTime(2024, 1, 1, 12, 0).add(Duration(hours: index)),
          estimatedCost: 50.0 + (index * 10),
          locationName: 'Location $index',
          isCompleted: index % 2 == 0,
          isPriority: index % 3 == 0,
          createdAt: DateTime(2024, 1, 1).add(Duration(hours: index)),
          updatedAt: DateTime(2024, 1, 1).add(Duration(hours: index)),
        ),
      );

      // Insert test activities
      for (final activity in testActivities) {
        repository.createActivity(activity: activity);
      }
    });

    group('Cursor-based pagination', () {
      test('getActivitiesCursor returns first page correctly', () async {
        final result = await repository.getActivitiesCursor(
          userId: testUserId,
          tripId: testTripId,
          pageSize: 20,
        );

        expect(result.items.length, equals(20));
        expect(result.pageInfo.hasNextPage, isTrue);
        expect(result.pageInfo.hasPreviousPage, isFalse);
        expect(result.pageInfo.nextCursor, isNotNull);
      });

      test('getActivitiesCursor filters by category', () async {
        final result = await repository.getActivitiesCursor(
          userId: testUserId,
          tripId: testTripId,
          filters: {'category': ActivityCategory.food},
          pageSize: 20,
        );

        for (final activity in result.items) {
          expect(activity.category, equals(ActivityCategory.food));
        }
      });

      test('getActivitiesCursor filters by completion status', () async {
        final result = await repository.getActivitiesCursor(
          userId: testUserId,
          tripId: testTripId,
          filters: {'isCompleted': true},
          pageSize: 20,
        );

        for (final activity in result.items) {
          expect(activity.isCompleted, isTrue);
        }
      });

      test('getActivitiesCursor filters by priority', () async {
        final result = await repository.getActivitiesCursor(
          userId: testUserId,
          tripId: testTripId,
          filters: {'isPriority': true},
          pageSize: 20,
        );

        for (final activity in result.items) {
          expect(activity.isPriority, isTrue);
        }
      });
    });

    group('Offset-based pagination', () {
      test('getActivitiesOffset returns first page correctly', () async {
        final result = await repository.getActivitiesOffset(
          userId: testUserId,
          tripId: testTripId,
          page: 1,
          pageSize: 20,
        );

        expect(result.items.length, equals(20));
        expect(result.pageInfo.currentPage, equals(1));
        expect(result.pageInfo.totalItems, equals(50));
        expect(result.pageInfo.totalPages, equals(3));
      });

      test('getActivitiesOffset returns specific page', () async {
        final result = await repository.getActivitiesOffset(
          userId: testUserId,
          tripId: testTripId,
          page: 2,
          pageSize: 20,
        );

        expect(result.items.length, equals(20));
        expect(result.pageInfo.currentPage, equals(2));
      });
    });

    group('CRUD operations', () {
      test('createActivity generates ID and timestamps', () async {
        final newActivity = Activity(
          id: '',
          tripId: testTripId,
          userId: testUserId,
          title: 'New Activity',
          category: ActivityCategory.activity,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final created = await repository.createActivity(activity: newActivity);

        expect(created.id, startsWith('activity_'));
        expect(created.title, equals('New Activity'));
      });

      test('toggleActivityCompletion updates status', () async {
        final updated = await repository.toggleActivityCompletion(
          activityId: 'activity-0',
          isCompleted: true,
        );

        expect(updated.isCompleted, isTrue);
      });

      test('deleteActivity removes activity', () async {
        final result = await repository.deleteActivity(activityId: 'activity-0');

        expect(result, isTrue);

        final activity = await repository.getActivityById(activityId: 'activity-0');
        expect(activity, isNull);
      });
    });

    group('Search', () {
      test('searchActivities finds activities by title', () async {
        final result = await repository.searchActivities(
          userId: testUserId,
          tripId: testTripId,
          query: 'Activity 1',
          pageSize: 20,
        );

        expect(result.items.length, greaterThan(0));
        expect(
          result.items.every((activity) => activity.title.contains('Activity 1')),
          isTrue,
        );
      });

      test('searchActivities finds activities by location', () async {
        final result = await repository.searchActivities(
          userId: testUserId,
          tripId: testTripId,
          query: 'Location 2',
          pageSize: 20,
        );

        expect(result.items.length, greaterThan(0));
      });
    });

    group('Convenience methods', () {
      test('getActivitiesByCategory filters correctly', () async {
        final result = await repository.getActivitiesByCategory(
          userId: testUserId,
          tripId: testTripId,
          category: ActivityCategory.food,
          pageSize: 20,
        );

        for (final activity in result.items) {
          expect(activity.category, equals(ActivityCategory.food));
        }
      });

      test('getUpcomingActivities returns future activities', () async {
        final result = await repository.getUpcomingActivities(
          userId: testUserId,
          tripId: testTripId,
          pageSize: 10,
        );

        final now = DateTime.now();
        for (final activity in result.items) {
          if (activity.startDateTime != null) {
            expect(activity.startDateTime!.isAfter(now), isTrue);
          }
        }
      });

      test('getCompletedActivities returns completed activities', () async {
        final result = await repository.getCompletedActivities(
          userId: testUserId,
          tripId: testTripId,
          pageSize: 20,
        );

        for (final activity in result.items) {
          expect(activity.isCompleted, isTrue);
        }
      });

      test('getPriorityActivities returns priority activities', () async {
        final result = await repository.getPriorityActivities(
          userId: testUserId,
          tripId: testTripId,
          pageSize: 10,
        );

        for (final activity in result.items) {
          expect(activity.isPriority, isTrue);
        }
      });
    });

    group('Count', () {
      test('countActivities returns total count', () async {
        final count = await repository.countActivities(
          userId: testUserId,
          tripId: testTripId,
        );

        expect(count, equals(50));
      });

      test('countActivities with filters returns filtered count', () async {
        final count = await repository.countActivities(
          userId: testUserId,
          tripId: testTripId,
          filters: {'isCompleted': true},
        );

        expect(count, equals(25)); // Half are completed
      });
    });

    group('Bulk operations', () {
      test('bulkUpdateActivities updates multiple activities', () async {
        final updatedCount = await repository.bulkUpdateActivities(
          activityIds: ['activity-0', 'activity-1', 'activity-2'],
          updates: {'isCompleted': true},
        );

        expect(updatedCount, equals(3));

        final activity0 = await repository.getActivityById(activityId: 'activity-0');
        expect(activity0!.isCompleted, isTrue);
      });
    });

    group('Clear', () {
      test('clear removes all activities', () async {
        repository.clear();

        final count = await repository.countActivities(
          userId: testUserId,
          tripId: testTripId,
        );
        expect(count, equals(0));
      });
    });
  });
}
