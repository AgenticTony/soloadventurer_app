import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/itinerary_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';
import 'package:soloadventurer/features/travel/data/repositories/itinerary_repository_impl.dart';
import 'package:soloadventurer/features/travel/domain/repositories/itinerary_repository.dart';
import 'package:soloadventurer/features/travel/domain/usecases/add_itinerary_item.dart';
import 'package:soloadventurer/features/travel/domain/usecases/create_itinerary.dart';
import 'package:soloadventurer/features/travel/domain/usecases/get_itinerary.dart';
import 'package:soloadventurer/features/travel/domain/usecases/get_itineraries.dart';
import 'package:soloadventurer/features/travel/domain/usecases/get_items_for_day.dart';
import 'package:soloadventurer/features/travel/domain/usecases/remove_itinerary_item.dart';
import 'package:soloadventurer/features/travel/domain/usecases/reorder_itinerary_items.dart';
import 'package:soloadventurer/features/travel/domain/usecases/toggle_item_completion.dart';
import 'package:soloadventurer/features/travel/domain/usecases/update_itinerary_item.dart';

part 'itinerary_domain_providers.g.dart';

/// Provider for the AppDatabase
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  throw UnimplementedError(
    'AppDatabase must be provided in the DI module',
  );
}

/// Provider for the ItineraryDao
@Riverpod(keepAlive: true)
ItineraryDao itineraryDao(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return ItineraryDao(db);
}

/// Provider for the ItineraryRepository
@Riverpod(keepAlive: true)
ItineraryRepository itineraryRepository(Ref ref) {
  final dao = ref.watch(itineraryDaoProvider);
  final db = ref.watch(appDatabaseProvider);

  return ItineraryRepositoryImpl(
    dao: dao,
    database: db,
  );
}

/// Provider for GetItinerary use case
@Riverpod(keepAlive: true)
GetItinerary getItinerary(Ref ref) {
  return GetItinerary(ref.watch(itineraryRepositoryProvider));
}

/// Provider for GetItineraries use case
@Riverpod(keepAlive: true)
GetItineraries getItineraries(Ref ref) {
  return GetItineraries(ref.watch(itineraryRepositoryProvider));
}

/// Provider for CreateItinerary use case
@Riverpod(keepAlive: true)
CreateItinerary createItinerary(Ref ref) {
  return CreateItinerary(ref.watch(itineraryRepositoryProvider));
}

/// Provider for AddItineraryItem use case
@Riverpod(keepAlive: true)
AddItineraryItem addItineraryItem(Ref ref) {
  return AddItineraryItem(ref.watch(itineraryRepositoryProvider));
}

/// Provider for UpdateItineraryItem use case
@Riverpod(keepAlive: true)
UpdateItineraryItem updateItineraryItem(Ref ref) {
  return UpdateItineraryItem(ref.watch(itineraryRepositoryProvider));
}

/// Provider for RemoveItineraryItem use case
@Riverpod(keepAlive: true)
RemoveItineraryItem removeItineraryItem(Ref ref) {
  return RemoveItineraryItem(ref.watch(itineraryRepositoryProvider));
}

/// Provider for ReorderItineraryItems use case
@Riverpod(keepAlive: true)
ReorderItineraryItems reorderItineraryItems(Ref ref) {
  return ReorderItineraryItems(ref.watch(itineraryRepositoryProvider));
}

/// Provider for ToggleItemCompletion use case
@Riverpod(keepAlive: true)
ToggleItemCompletion toggleItemCompletion(Ref ref) {
  return ToggleItemCompletion(ref.watch(itineraryRepositoryProvider));
}

/// Provider for GetItemsForDay use case
@Riverpod(keepAlive: true)
GetItemsForDay getItemsForDay(Ref ref) {
  return GetItemsForDay(ref.watch(itineraryRepositoryProvider));
}
