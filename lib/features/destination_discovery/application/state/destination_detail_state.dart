import '../../domain/models/destination.dart';

/// State class for destination detail
class DestinationDetailState {
  /// The destination detail data
  final Destination? destination;

  /// Related/suggested destinations
  final List<Destination> relatedDestinations;

  /// Whether this is the initial state (no data loaded yet)
  final bool isInitial;

  /// Creates an initial destination detail state
  const DestinationDetailState.initial()
      : destination = null,
        relatedDestinations = const [],
        isInitial = true;

  /// Creates a destination detail state with the given fields
  const DestinationDetailState({
    required this.destination,
    this.relatedDestinations = const [],
    this.isInitial = false,
  });

  /// Creates a copy of this state with the given fields replaced
  DestinationDetailState copyWith({
    Destination? destination,
    List<Destination>? relatedDestinations,
    bool? isInitial,
  }) {
    return DestinationDetailState(
      destination: destination ?? this.destination,
      relatedDestinations: relatedDestinations ?? this.relatedDestinations,
      isInitial: isInitial ?? this.isInitial,
    );
  }

  /// Returns true if no destination has been loaded
  bool get isEmpty => destination == null && !isInitial;

  /// Returns true if a destination has been loaded
  bool get hasDestination => destination != null;

  /// Returns true if related destinations are available
  bool get hasRelatedDestinations => relatedDestinations.isNotEmpty;

  /// Returns the number of related destinations
  int get relatedDestinationCount => relatedDestinations.length;
}
