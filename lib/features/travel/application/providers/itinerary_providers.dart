import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary_item.dart';
import 'package:soloadventurer/features/travel/domain/providers/itinerary_domain_providers.dart'
    show
        getItineraryProvider,
        getItinerariesProvider,
        addItineraryItemProvider,
        updateItineraryItemProvider,
        removeItineraryItemProvider,
        reorderItineraryItemsProvider,
        toggleItemCompletionProvider;
import 'package:soloadventurer/features/travel/application/providers/itinerary_state.dart';

part 'itinerary_providers.g.dart';

/// Provider for ItineraryNotifier - manages itinerary state
///
/// Use this provider to watch itinerary state and perform actions.
///
/// Example:
/// dart
/// // Watch the state
/// final state = ref.watch(itineraryNotifierProvider('itinerary-'));
///
/// // Perform actions
/// ref.read(itineraryNotifierProvider('itinerary-').notifier)
///     .toggleItemCompletion('item-');
///
@riverpod
class ItineraryNotifier extends _$ItineraryNotifier {
  @override
  Future<Itinerary> build(String itineraryId) async {
    final getItineraryUseCase = ref.read(getItineraryProvider);
    final result = await getItineraryUseCase(itineraryId);

    return result.fold(
      (failure) => throw failure,
      (itinerary) => itinerary,
    );
  }

  /// Adds an item to the itinerary
  Future<void> addItem(ItineraryItem item) async {
    final addItineraryItemUseCase = ref.read(addItineraryItemProvider);

    final result = await addItineraryItemUseCase(
      itineraryId: itineraryId,
      item: item,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }

  /// Updates an item in the itinerary
  Future<void> updateItem(ItineraryItem item) async {
    final updateItineraryItemUseCase = ref.read(updateItineraryItemProvider);

    final result = await updateItineraryItemUseCase(
      itineraryId: itineraryId,
      item: item,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }

  /// Removes an item from the itinerary
  Future<void> removeItem(String itemId) async {
    final removeItineraryItemUseCase = ref.read(removeItineraryItemProvider);

    final result = await removeItineraryItemUseCase(
      itineraryId: itineraryId,
      itemId: itemId,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }

  /// Reorders items in the itinerary
  Future<void> reorderItems(List<String> itemIdsInNewOrder) async {
    final reorderItineraryItemsUseCase =
        ref.read(reorderItineraryItemsProvider);

    final result = await reorderItineraryItemsUseCase(
      itineraryId: itineraryId,
      itemIdsInNewOrder: itemIdsInNewOrder,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }

  /// Toggles the completion status of an item
  Future<void> toggleItemCompletion(String itemId) async {
    final toggleItemCompletionUseCase = ref.read(toggleItemCompletionProvider);

    final result = await toggleItemCompletionUseCase(
      itineraryId: itineraryId,
      itemId: itemId,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }
}

/// Provider for watching all itineraries
///
/// Example:
/// dart
/// final itinerariesAsync = ref.watch(itinerariesProvider(userId: 'user-'));
///
@riverpod
Future<List<ItineraryListState>> itineraries(
  Ref ref,
  String? userId,
) async {
  final getItinerariesUseCase = ref.read(getItinerariesProvider);

  final result = await getItinerariesUseCase(userId: userId);

  return result.fold(
    (failure) => throw failure,
    (itineraries) => itineraries.map(ItineraryListState.fromItinerary).toList(),
  );
}
