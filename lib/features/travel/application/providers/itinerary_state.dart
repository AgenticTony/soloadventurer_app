import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';

/// State class for itinerary list items
class ItineraryListState {
  final String id;
  final String name;
  final String destination;
  final String dateRange;
  final int numberOfDays;
  final int itemsCount;
  final double completionPercentage;

  const ItineraryListState({
    required this.id,
    required this.name,
    required this.destination,
    required this.dateRange,
    required this.numberOfDays,
    required this.itemsCount,
    required this.completionPercentage,
  });

  /// Creates ItineraryListState from an Itinerary domain entity
  factory ItineraryListState.fromItinerary(Itinerary itinerary) {
    return ItineraryListState(
      id: itinerary.id,
      name: itinerary.name,
      destination: itinerary.destination.name,
      dateRange:
          '${_formatDate(itinerary.dateRange.start)} - ${_formatDate(itinerary.dateRange.end)}',
      numberOfDays: itinerary.numberOfDays,
      itemsCount: itinerary.items.length,
      completionPercentage: itinerary.completionPercentage,
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}

/// Combined state class for itinerary
class ItineraryState {
  final Itinerary? itinerary;
  final Object? error;

  const ItineraryState({this.itinerary, this.error});

  const ItineraryState.withData(Itinerary value)
      : itinerary = value,
        error = null;

  const ItineraryState.withError(Object this.error)
      : itinerary = null;

  bool get isLoading => itinerary == null && error == null;
  bool get hasError => error != null;

  Itinerary? get value => itinerary;
}
