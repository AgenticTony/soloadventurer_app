import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/schema.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';

class MockTripDao extends Mock implements TripDao {}

class MockJournalDao extends Mock implements JournalDao {}

class MockUserDao extends Mock implements UserDao {}

class MockSyncQueueDao extends Mock implements SyncQueueDao {}

class MockItineraryDao extends Mock implements ItineraryDao {}
