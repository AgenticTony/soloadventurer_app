import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary_item.dart';

/// Local data source for itineraries
///
/// Handles persistence of itinerary data using the offline database.
/// Implementations should interact with the travel feature's database DAOs.
abstract class ItineraryLocalDataSource {
  /// Adds an item to an itinerary
  Future<ItineraryItem> addItem(String itineraryId, ItineraryItem item);

  /// Gets an itinerary by ID
  Future<Itinerary> getItinerary(String itineraryId);
}
