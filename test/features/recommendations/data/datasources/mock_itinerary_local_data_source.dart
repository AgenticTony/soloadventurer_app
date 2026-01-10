import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/recommendations/data/datasources/itinerary_local_data_source.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary_item.dart';

/// Mock implementation of [ItineraryLocalDataSource] for testing
///
/// This mock uses in-memory storage for testing purposes only.
/// It should NOT be used in production code.
class MockItineraryLocalDataSource implements ItineraryLocalDataSource {
  // In-memory storage for mock data
  final Map<String, Itinerary> _itineraries = {};

  @override
  Future<ItineraryItem> addItem(String itineraryId, ItineraryItem item) async {
    final itinerary = await getItinerary(itineraryId);
    final updatedItems = [...itinerary.items, item];

    _itineraries[itineraryId] = itinerary.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );

    return item;
  }

  @override
  Future<Itinerary> getItinerary(String itineraryId) async {
    if (!_itineraries.containsKey(itineraryId)) {
      throw RepositoryException('Itinerary not found: $itineraryId');
    }
    return _itineraries[itineraryId]!;
  }

  /// Adds a mock itinerary for testing
  ///
  /// This method is specific to the mock implementation for testing purposes.
  void addMockItinerary(Itinerary itinerary) {
    _itineraries[itinerary.id] = itinerary;
  }

  /// Clears all mock data
  ///
  /// Useful for resetting state between tests.
  void clear() {
    _itineraries.clear();
  }
}
