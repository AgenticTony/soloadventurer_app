import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/trip_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/journal_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/user_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/sync_queue_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/itinerary_dao.dart';

class MockTripDao extends Mock implements TripDao {}

class MockJournalDao extends Mock implements JournalDao {}

class MockUserDao extends Mock implements UserDao {}

class MockSyncQueueDao extends Mock implements SyncQueueDao {}

class MockItineraryDao extends Mock implements ItineraryDao {}
