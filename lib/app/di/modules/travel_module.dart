import 'package:get_it/get_it.dart';
import 'package:soloadventurer/features/core/infrastructure/api/dio_api_service.dart';
import 'package:soloadventurer/features/offline/domain/services/connectivity_service.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_queue_service.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/trip_dao.dart';
import 'package:soloadventurer/features/travel/domain/repositories/trip_repository.dart';
import 'package:soloadventurer/features/travel/infrastructure/repositories/trip_repository_impl.dart';

/// Register all travel feature dependencies
void registerTravelModule(GetIt getIt, {bool isTest = false}) {
  // Register repository
  getIt.registerLazySingleton<TripRepository>(
    () => TripRepositoryImpl(
      tripDao: getIt<TripDao>(),
      apiService: getIt<DioApiService>(),
      connectivityService: getIt<ConnectivityService>(),
      syncQueueService: getIt<SyncQueueService>(),
    ),
  );
}
